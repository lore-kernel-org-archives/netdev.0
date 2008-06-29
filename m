From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: SFQ depth limit
Date: Sun, 29 Jun 2008 21:11:13 +0200
Message-ID: <20080629191113.GA8817@ami.dom.local>
References: <200806282202.59581.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.176]:56521 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbYF2TMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2008 15:12:17 -0400
Received: by ik-out-1112.google.com with SMTP id c28so536742ika.5
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2008 12:12:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200806282202.59581.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote, On 06/28/2008 09:02 PM:

> Hi
> 
> Is there any particular reason to limit SFQ depth to 127 packets?
> #define SFQ_DEPTH               128
> 
> Just to buffer data on 1Gbps rate for 1 second i need 87k packets, let's say just for 10ms buffer - 873 packets, which is out of limit.
> Also if i will use external SFQ flow classifier made by Patrick McHardy, let's say for 4096 ip's, i am not sure also if i hit this limit. 
> As i understand, if i increase it - it will increase also data structures size in memory.

Hi,

Yes, this 128 limit is extremely low, but changing this is not enough:
you've to change at least sfq_index typedef too, eg. to unsigned short,
but I didn't check if this is all.

> And probably i hit some unknown issue.
> Example:
> tc qdisc add dev eth0 handle 1 root sfq
> tc filter add dev eth0 protocol ip pref 1 parent 1: handle 1 flow hash keys dst divisor 1024
...
> MegaRouterCore-KARAM ~ #tc -s -d qdisc show dev eth0
> qdisc sfq 1: root limit 127p quantum 1514b flows 127/1024
>  Sent 16232 bytes 118 pkt (dropped 9, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> 
> after that host is dead...

If it's with vanilla kernel something is wrong, but I couldn't
reproduce this: probably some additianal data is needed. BTW,
I see this "flows" number above isn't very useful, as it always
repeats "limit". I attach a patch proposal to change this.

Regards,
Jarek P.

----------------------->

sch_sfq: dump a real number of flows

Dump the "flows" number according to the number of active flows
instead of repeating the "limit".


Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_sfq.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index f0463d7..5bc78c3 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -536,7 +536,14 @@ static int sfq_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	opt.limit = q->limit;
 	opt.divisor = SFQ_HASH_DIVISOR;
-	opt.flows = q->limit;
+	opt.flows = 0;
+	if (q->tail != SFQ_DEPTH) {
+		unsigned int i;
+
+		for (i = 0; i < SFQ_HASH_DIVISOR; i++)
+			if (q->ht[i] != SFQ_DEPTH)
+				opt.flows++;
+	}
 
 	NLA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
 
