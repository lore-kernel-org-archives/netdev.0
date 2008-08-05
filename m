From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Tue, 05 Aug 2008 15:43:50 +0300
Message-ID: <20080805154350.27523juch31xgjcw@hayate.ip6>
References: <20080731171431.GA9464@ami.dom.local>
	<4892AA16.40706@trash.net> <20080801101929.GA12735@ff.dom.local>
	<20080803.182524.240976246.davem@davemloft.net>
	<20080804062813.GA4570@ff.dom.local>
	<20080804213535.14214iqhxkx3v3so@hayate.ip6>
	<20080804210333.GA2849@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:35718 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292AbYHEMnx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 08:43:53 -0400
In-Reply-To: <20080804210333.GA2849@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Jarek Poplawski" <jarkao2@gmail.com>:

> On Mon, Aug 04, 2008 at 09:35:35PM +0300, Jussi Kivilinna wrote:
>> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
>>
>> This seems to also make sure that when returning 'full'
>> NET_XMIT_SUCCESS, skb pointer is safe(r?) to use now.
>
> I guess so... At least theoretically - I was mainly afraid of
> redirecting, which isn't fully implemented yet. On the other hand,
> outwards of qdiscs there is still no difference.
>

How about making skb shared before passing into qdisc tree?
That would make skb usage safe after qdisc enqueues.

---

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index c5bb130..9cf06fc 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -352,10 +352,16 @@ static inline int qdisc_enqueue(struct sk_buff  
*skb, struct Qdisc *sch)
         return sch->enqueue(skb, sch);
  }

-static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
+static inline int qdisc_enqueue_root(struct sk_buff *__skb, struct  
Qdisc *sch)
  {
+       struct sk_buff *skb = skb_get(__skb);
+       int ret;
+
         qdisc_skb_cb(skb)->pkt_len = skb->len;
-       return qdisc_enqueue(skb, sch);
+       ret = qdisc_enqueue(skb, sch);
+       kfree_skb(skb);
+
+       return ret;
  }

  static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct  
Qdisc *sch,

