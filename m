From: Florian Westphal <fw@strlen.de>
Subject: Re: codel/fq_codel triggers heaps of WARNs in
 net/sched/sch_hfsc.c:1426
Date: Tue, 31 May 2016 12:00:52 +0200
Message-ID: <20160531100052.GA2431@breakpoint.cc>
References: <CAO0uZ+-SvYncQ+OUbDn5B7-_W3j6Wge8=t0EKi6xCb1ruXUwiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Miroslav Kratochvil <exa.exa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40064 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750730AbcEaKA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 06:00:56 -0400
Content-Disposition: inline
In-Reply-To: <CAO0uZ+-SvYncQ+OUbDn5B7-_W3j6Wge8=t0EKi6xCb1ruXUwiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miroslav Kratochvil <exa.exa@gmail.com> wrote:
> Hello everyone,
> 
> I've been trying to debug an issue that arises when I'm using codel
> (of fq_codel) qdiscs attached to a HFSC leaf class. Basic problem is
> that on random points in time, kernel log gets overfilled (tens of
> MB's of the messages) with many WARNINGs at net/sched/sch_hfsc.c:1426;
> full text of several is attached below. The warnings appear randomly
> in time, but always in (large) groups.
> 
> I was thinking that it is an issue relevant to a similar thing with
> SFQ, where it's been fixed by some trimming of stats produced by SFQ.
> Documented here:
> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=631945
> 
> Similar patch for codel and fq_codel was recommended me for trying out, here:
> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/net/sched/sch_fq_codel.c?h=linux-4.5.y&id=01465faa0e2d311512690724196042f9bb466034
> but the issue didn't get solved by it.
> 
> Also also, there's my original debian bugreport:
> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=824790
> 
> Is there any good approach I can debug this? I currently have a test
> system where I can trigger the message easily with any custom kernel;
> I'd appreciate any advice on what to try out next.
> 
> The messages from test kernel are from 4.5.5 on debian with ~20k hfsc
> classes; I'll try to test out 4.6 ASAP but there seems to be no
> relevant change in this direction. tg3 driver is not to blame (same
> happens with e1000, e1000e, igb and ixgbe). I'm not sure whether u32
> filter hashbuckets could trigger this behavior, but hope not
> (currently I have no method to try this without u32).
> 
> Thanks in advance for any thoughts on this.

Both HFSC and fq_codel have problems, but I'm not sure if these are
relevant for your 4.5.5 kernel.
I'll submit a hfsc patch soon (it does fix a real problem).

If you have any config knobs enabled on the fq_codel leaf qdiscs it
would be good to know what parameters are used.

Can you try this patch (it doesn't fix anything but might provide more info):

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index d783d7c..045169e 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -49,6 +49,8 @@
  * a class whose fit-time exceeds the current time.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/types.h>
@@ -1423,7 +1425,11 @@ hfsc_schedule_watchdog(struct Qdisc *sch)
 		if (next_time == 0 || next_time > q->root.cl_cfmin)
 			next_time = q->root.cl_cfmin;
 	}
-	WARN_ON(next_time == 0);
+	if (WARN_ON_ONCE(next_time == 0)) {
+		pr_warn_ratelimited("qlen %u droplist_empty: %d, cfmin %llu, minel %d, root_empty %d\n",
+				    sch->q.qlen, list_empty(&q->droplist),
+				    (unsigned long long)q->root.cl_cfmin, !!cl, RB_EMPTY_ROOT(&q->eligible));
+	}
 	qdisc_watchdog_schedule(&q->watchdog, next_time);
 }
 
