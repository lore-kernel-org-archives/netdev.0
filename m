From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 08:43:06 +0000
Message-ID: <20090825084306.GA7879@ff.dom.local>
References: <20090825062203.GA5381@ff.dom.local> <200908251034.09581.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:51506 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbZHYInL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 04:43:11 -0400
Received: by fxm17 with SMTP id 17so1915466fxm.37
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 01:43:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200908251034.09581.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2009 at 10:34:09AM +0300, Denys Fedoryschenko wrote:
> On Tuesday 25 August 2009 09:22:03 Jarek Poplawski wrote:
> 
> >
> > Right, it's about an overflow and it was expected (theoretically) for
> > very low rates (as for current times) while doing this resolution
> > change. Probably this kind of warning should be useful if we expect
> > there're more people who can actually use something like this yet ;-)
> >
> > Alas INT_MAX could still be not enough to prevent similar issues
> > because in tbf_dequeue such a value (buffer) is increased with tokens.
> > I guess we could try to change some variables to 64 bits there, but
> > the main question is why anybody needs such strange settings today?
> > Did you try e.g. to browse Internet with that rate and the buffer
> > e.g. 1500kb or you punish some users only? ;-) Btw, why do you think
> > 'buffer 2000kb' is better "for you" with that rate than e.g. 20kb?
> >
> > Thanks,
> > Jarek P.
> Life in Lebanon:
> Backbone for ISP - $2200 per Mbit and higher.
> 
> Accounts 256Kbit/s cost $66/month in some areas.
> 96 Kbits/s for people with low income costs cheaper.
> 
> From government "alternative" solution - pay $20 for 2GB, but they charge 
> (without any understandable notice for non-tech end-user) extra traffic :-) 
> Some people ending month with bills $200/month. Surprise!
> 
> Try to browse with 96Kbit/s? U can't actually on this days, with pages that 
> weight up to 5-10Mbyte...
> 
> The only solution - first 2-10Mbyte, for example, for user will be transferred 
> on high speed, let's say 512Kbit/s, but if he put downloads - he will have 
> his 96Kbit/s. If he just browse occasionally, his large bucket will 
> be "recharged" with 96 Kbit/s, and next page will open again fast.

To make it clear: I didn't wonder about using 96Kbit rate nowdays
(I'm not that modern at all ;-), but 96Kbit with such a big buffer.
I didn't try this but I can imagine the burstiness; but maybe I still
need to figure out your trick...

> That's how this TBF configuration that i show works. But sure if it is 
> difficult to solve i will implement something similar in userspace, that will 
> track user consumption, and just change discipline settings... but sure it 
> will be different thing. Actually because there is noone else complained 
> about this except me, i guess i have to solve it by myself. Because better 
> resolution for high bandwidth traffic shaping much more important even for 
> me :-)

It shouldn't be so difficult just for 2000kb buffer here, but of course
there're some limits. "Noone else" doesn't matter here, because I know
there are not so much -rc networking testers beside you ;-)

There is some inconsistency in schedulers e.g. with using u32 buffers
in configs and 'long' variables to process them. Maybe there should
be some warnings in iproute like you suggested: feel free to send some
patch if you like (I still can't see my 'resolution' patches merged,
btw :-( ). Probably tc_core_time2big might be used for this. But,
since these 64 bits will be needed soon for higher rates anyway, I
guess we could try some change like the patch below, if you find it
works for you (I didn't test it yet.)

Jarek P.
---

 net/sched/sch_tbf.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index e22dfe8..2c74450 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -160,8 +160,8 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 
 	if (skb) {
 		psched_time_t now;
-		long toks;
-		long ptoks = 0;
+		long long toks;
+		long long ptoks = 0;
 		unsigned int len = qdisc_pkt_len(skb);
 
 		now = psched_get_time();


