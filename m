From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 07:46:04 +0000
Message-ID: <20081008074604.GC4174@ff.dom.local>
References: <48EB5A92.6010704@trash.net> <48EBFF5E.1090902@trash.net> <20081008065551.GB4174@ff.dom.local> <200810081006.38840.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:34966 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753487AbYJHHqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 03:46:11 -0400
Received: by ug-out-1314.google.com with SMTP id k3so487212ugf.37
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2008 00:46:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200810081006.38840.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 10:06:38AM +0300, Denys Fedoryshchenko wrote:
> On Wednesday 08 October 2008, Jarek Poplawski wrote:
> > On Wed, Oct 08, 2008 at 02:31:26AM +0200, Patrick McHardy wrote:
> > ...
> >
> > > I'm pretty sure that the differences are caused by HTB not being
> > > in control of the queue since the device is the real bottleneck
> > > in this configuration.
> >
> > Yes, otherwise there would be no requeuing. And, btw. the golden rule
> > of scheduling/shaping is limiting below "hardware" limits.
> By the way, HTB counting ethernet headers (e.g. if you send 1500 byte ping, it 
> will be 1514 in tc counters) . So possible ethernet overhead counted.
> 

Right, that's why stats from the other host could differ and these
tc stats mentioned by Patrick could be useful.

BTW, current requeuing isn't true requeuing, but we should have some
info about this, so something like this patch is needed.

Jarek P.

-------------->

pkt_sched: Update qdisc requeue stats in dev_requeue_skb()

After the last change of requeuing there is no info about such
incidents in tc stats. This patch updates the counter, but we should
consider this should differ from previous stats because of additional
checks preventing to repeat this. On the other hand, previous stats
didn't include requeuing of gso_segmented skbs.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 net/sched/sch_generic.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 31f6b61..7b5572d 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -45,6 +45,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	q->gso_skb = skb;
+	q->qstats.requeues++;
 	__netif_schedule(q);
 
 	return 0;
