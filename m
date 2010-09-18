From: Michal Soltys <soltys@ziu.info>
Subject: Re: [PATCH] net/sched/sch_hfsc.c: initialize parent's cl_cfmin
 properly in init_vf()
Date: Sat, 18 Sep 2010 16:08:16 +0200
Message-ID: <20100918140816.GA974@mott.hasevolq.tld>
References: <cover.1283197803.git.soltys@ziu.info>
 <8100ed4475ac7a301a3d69611e97d510ea498c5d.1283197803.git.soltys@ziu.info>
 <20100901.143038.170100274.davem@davemloft.net>
 <4C910869.1050800@trash.net>
 <4C913DE1.6040401@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, denys@visp.net.lb,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.ppgk.com.pl ([80.53.243.36]:36357 "EHLO relay.ppgk.com.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755049Ab0IROIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Sep 2010 10:08:31 -0400
Content-Disposition: inline
In-Reply-To: <4C913DE1.6040401@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 15, 2010 at 11:42:57PM +0200, Michal Soltys wrote:
> On 10-09-15 19:54, Patrick McHardy wrote:
> >Am 01.09.2010 23:30, schrieb David Miller:
> >> From: Michal Soltys<soltys@ziu.info>
> >> Date: Mon, 30 Aug 2010 23:34:10 +0200
> >>
> >>> This patch fixes init_vf() function, so on each new backlog period parent's
> >>> cl_cfmin is properly updated (including further propgation towards the root),
> >>> even if the activated leaf has no upperlimit curve defined.
> >>>
> >>> Signed-off-by: Michal Soltys<soltys@ziu.info>
> >>
> >> Applied, thanks.
> >
> >For the record, the patch seems fine to me. The root cause seems to be
> >an optimization I introduced (pre-git, even history.git unfortunately)
> >in vttree_get_minvt() that wasn't present in the original version:
> >
> >static struct hfsc_class *
> >vttree_get_minvt(struct hfsc_class *cl, u64 cur_time)
> >{
> >         /* if root-class's cfmin is bigger than cur_time nothing to do */
> >         if (cl->cl_cfmin>  cur_time)
> >                 return NULL;
> >
> >I'd prefer to remove this check since it's obviously not correct and
> >might cause other problems. Michal, could you please test whether this
> >patch fixes the problem as well? Thanks!
> 
> Sure, will do. Although with a tad bit more complex scenario than
> from my cover email, I think there will still be problems.

Ok, did the tests. The results confirmed the earlier theory - namely, if I
removed my fix and your optimization, the only scenario it helped with was if
the leafs were directly attached to the root qdisc, eg.:

    root
    /  \
   A    B(u)

Here, making decision at root would go through childrens' 'vt's and 'f's times
and properly dequeue A without any delays.

Anything deeper though, like:

     |                / \
     A               A   B(u)
    / \             / \
   B   C(u)        C  D(u)

still cause problems - while the decision would go through 'vt's and 'f's - the
'f's are calculated as max(myf, cfmin), and cfmin won't be updated updwards
from the leafs that have no upperlimit.

Regarding your optimization - its results should be consistent with the first
vttree_firstfit() call (if cf_min is properly updated). I don't see how it
could cause any misbehaviour.

Speaking about hfsc, I have few other potential changes with reference to how
vt is handled and updated (especially cvtmin), but that's for different mail.

Additional 'if' condition (mentioned in previous mail) in my fix seemed to work
fine as well, namely:

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 4749609..e9768b2 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -761,8 +761,9 @@ init_vf(struct hfsc_class *cl, unsigned int len)
 		if (f != cl->cl_f) {
 			cl->cl_f = f;
 			cftree_update(cl);
-		}
-		update_cfmin(cl->cl_parent);
+			update_cfmin(cl->cl_parent);
+		} else if (go_active)
+			update_cfmin(cl->cl_parent);
 	}
 }

