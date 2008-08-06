From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb (Was: Re: [PATCH
	take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag)
Date: Wed, 06 Aug 2008 22:42:48 +0300
Message-ID: <20080806224248.18266k9ahc5nkk8w@hayate.ip6>
References: <20080731171431.GA9464@ami.dom.local>
	<4892AA16.40706@trash.net> <20080801101929.GA12735@ff.dom.local>
	<20080803.182524.240976246.davem@davemloft.net>
	<20080804062813.GA4570@ff.dom.local>
	<20080804213535.14214iqhxkx3v3so@hayate.ip6>
	<20080804210333.GA2849@ami.dom.local>
	<20080805154350.27523juch31xgjcw@hayate.ip6>
	<20080805155001.GA2526@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:47476 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247AbYHFTmv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 15:42:51 -0400
In-Reply-To: <20080805155001.GA2526@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Jarek Poplawski" <jarkao2@gmail.com>:

>>
>> How about making skb shared before passing into qdisc tree?
>> That would make skb usage safe after qdisc enqueues.
>
> It's a bit costly (atomics), so there should be a good reason for this.
> It should be first checked if there is real danger. And if it's only
> for more exact stats, I'm not sure it's worth of it.
>

Ok, I went throught all enqueue (and requeue) functions for any case of
freeing skb and returning full NET_XMIT_SUCCESS without new flags and
found only in sch_blackhole (qdisc_drop + return NET_XMIT_SUCCESS).
This could be fixed by delaying kfree_skb to exit on qdisc_enqueue_root,
here's (completely untested) patch:
---
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a7abfda..ca083c6 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -175,6 +175,7 @@ struct tcf_proto

  struct qdisc_skb_cb {
         unsigned int            pkt_len;
+       __u8                    delayed_enqueue_free:1;
         char                    data[];
  };

@@ -364,10 +365,23 @@ static inline int qdisc_enqueue(struct sk_buff  
*skb, struct Qdisc *sch)
         return sch->enqueue(skb, sch);
  }

+static inline void qdisc_delayed_kfree_skb(struct sk_buff *skb)
+{
+       qdisc_skb_cb(skb)->delayed_enqueue_free = 1;
+}
+
  static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
  {
+       int ret;
+
+       qdisc_skb_cb(skb)->delayed_enqueue_free = 0;
         qdisc_skb_cb(skb)->pkt_len = skb->len;
-       return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
+       ret = qdisc_enqueue(skb, sch);
+
+       if (ret == NET_XMIT_SUCCESS &&  
qdisc_skb_cb(skb)->delayed_enqueue_free)
+               kfree_skb(skb);
+
+       return ret & NET_XMIT_MASK;
  }

  static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct  
Qdisc *sch,
diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index 507fb48..13230bd 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -19,7 +19,8 @@

  static int blackhole_enqueue(struct sk_buff *skb, struct Qdisc *sch)
  {
-       qdisc_drop(skb, sch);
+       qdisc_delayed_kfree_skb(skb);
+       sch->qstats.drops++;
         return NET_XMIT_SUCCESS;
  }
---

If this isn't good way to solve this, qdisc_pkt_len use for stats could be
fixed with either passing packet length pointer throught qdisc tree or adding
new qdisc_pkt_len_diff and adding difference in at dequeue as you said  
(but here
inner dequeue could return NULL and difference wouldn't be added after all but
well it is just stats).

As I went throught code I found two cases where skb pointer is used  
after inner
enqueue with full NET_XMIT_SUCCESS (other than qdisc_pkt_len for stats): HTB
uses skb_is_gso(), HFSC uses packet length for set_active(). HTB is trivial
(for me) to fix while HFSC isn't. Because HFSC part it would be easier for me
to declare full NET_XMIT_SUCCESS as safe zone for skb pointer.

  - Jussi

PS. I noticed something fishy in HTB; HTB always returns NET_XMIT_DROP if
qdisc_enqueue doesn't return full NET_XMIT_SUCCESS, shouldn't it return return
value from qdisc_enqueue. Same in HTB requeue. That can't be right, right?

