From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net/sched/sch_hfsc.c: initialize parent's cl_cfmin properly
 in init_vf()
Date: Wed, 15 Sep 2010 19:54:49 +0200
Message-ID: <4C910869.1050800@trash.net>
References: <cover.1283197803.git.soltys@ziu.info>	<8100ed4475ac7a301a3d69611e97d510ea498c5d.1283197803.git.soltys@ziu.info> <20100901.143038.170100274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050303030401090903070708"
Cc: soltys@ziu.info, denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55361 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373Ab0IORyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 13:54:51 -0400
In-Reply-To: <20100901.143038.170100274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050303030401090903070708
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Am 01.09.2010 23:30, schrieb David Miller:
> From: Michal Soltys <soltys@ziu.info>
> Date: Mon, 30 Aug 2010 23:34:10 +0200
> 
>> This patch fixes init_vf() function, so on each new backlog period parent's
>> cl_cfmin is properly updated (including further propgation towards the root),
>> even if the activated leaf has no upperlimit curve defined.
>>
>> Signed-off-by: Michal Soltys <soltys@ziu.info>
> 
> Applied, thanks.

For the record, the patch seems fine to me. The root cause seems to be
an optimization I introduced (pre-git, even history.git unfortunately)
in vttree_get_minvt() that wasn't present in the original version:

static struct hfsc_class *
vttree_get_minvt(struct hfsc_class *cl, u64 cur_time)
{
        /* if root-class's cfmin is bigger than cur_time nothing to do */
        if (cl->cl_cfmin > cur_time)
                return NULL;

I'd prefer to remove this check since it's obviously not correct and
might cause other problems. Michal, could you please test whether this
patch fixes the problem as well? Thanks!

--------------050303030401090903070708
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="x"

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 4749609..466518e 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -312,10 +312,6 @@ vttree_firstfit(struct hfsc_class *cl, u64 cur_time)
 static struct hfsc_class *
 vttree_get_minvt(struct hfsc_class *cl, u64 cur_time)
 {
-	/* if root-class's cfmin is bigger than cur_time nothing to do */
-	if (cl->cl_cfmin > cur_time)
-		return NULL;
-
 	while (cl->level > 0) {
 		cl = vttree_firstfit(cl, cur_time);
 		if (cl == NULL)

--------------050303030401090903070708--
