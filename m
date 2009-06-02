From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Tue, 02 Jun 2009 09:16:27 -0400
Message-ID: <1243948587.3966.393.camel@dogo.mojatatu.com>
References: <20090529225929.GD2753@ami.dom.local>
	 <1243684218.3966.83.camel@dogo.mojatatu.com>
	 <20090531081213.GC2756@ami.dom.local>
	 <1243776293.3966.241.camel@dogo.mojatatu.com>
	 <20090531195557.GA2777@ami.dom.local>
	 <1243813216.3966.254.camel@dogo.mojatatu.com>
	 <20090601060638.GA4256@ff.dom.local>
	 <1243861410.3966.268.camel@dogo.mojatatu.com>
	 <20090601204957.GA2760@ami.dom.local>
	 <1243893963.3966.325.camel@dogo.mojatatu.com>
	 <20090602062623.GA4239@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-tAd8Y73qgvSSB8671amH"
Cc: Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:40895 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbZFBNR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 09:17:29 -0400
Received: by qw-out-2122.google.com with SMTP id 5so5563344qwd.37
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 06:17:30 -0700 (PDT)
In-Reply-To: <20090602062623.GA4239@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tAd8Y73qgvSSB8671amH
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2009-06-02 at 06:26 +0000, Jarek Poplawski wrote:

> The patch #2 is obviously worse and fixes less (of course it still
> needs testing for Minoru's case), but I'm 100% confident it can't
> introduce any regression (neither take 1 nor 2), which is much harder
> to say about patch #1, considering various "rude" configs we could
> miss (but we could give them some time to show off). But, as I've
> written before, I'm really (really) OK with your decision.

Thanks for the courtesy.
I note Dave already swallowed Minoru's patch; so lets move from there.
Yes, there's a possibility of a regression - I (and so are you) are only
recently evolved humans; we are not perfect... yet ;->
So i would agree with Minoru testing your patch as plan B in case the
applied one starts causing trouble.
BTW, ok - here's a quick untested, uncompiled fix to the u32 classifier
to fix the first rock (which you already worked around in your changes
to the included patch). No rush to submit for now..

On the second rock you threw so violently, after some reflection, I
think it is ok to send a replace twice with different priorities.
The second one will be added and the old not deleted, but if the user
has chosen the correct priority, then things will work out just fine.
And if they want they have to explicitly delete the one they dont want.
It is also not illegal to do a "replace" for installing instead of
"add".

So the only other things left to do from this exercise are (no rush in
any of them):
a) remove all "buckets" from underneath other classifiers
b) get consistency across all classifiers in usage of setup API

If you want to do this - go ahead; else i plan on tackling it probably
when stable 2.6.31 kicks in.

cheers,
jamal

--=-tAd8Y73qgvSSB8671amH
Content-Disposition: attachment; filename=u32-init-fix
Content-Type: text/x-patch; name=u32-init-fix; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 07372f6..5ad0b98 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -249,6 +249,9 @@ static unsigned long u32_get(struct tcf_proto *tp, u32 handle)
 	struct tc_u_hnode *ht;
 	struct tc_u_common *tp_c = tp->data;
 
+	if (!tp_c)
+		return 0;
+
 	if (TC_U32_HTID(handle) == TC_U32_ROOT)
 		ht = tp->root;
 	else
@@ -311,7 +314,6 @@ static int u32_init(struct tcf_proto *tp)
 	root_ht->tp_c = tp_c;
 
 	tp->root = root_ht;
-	tp->data = tp_c;
 	return 0;
 }
 
@@ -524,7 +526,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 		      struct nlattr **tca,
 		      unsigned long *arg)
 {
-	struct tc_u_common *tp_c = tp->data;
+	struct tc_u_common *tp_c = tp->root->tp_c;
 	struct tc_u_hnode *ht;
 	struct tc_u_knode *n;
 	struct tc_u32_sel *s;
@@ -540,6 +542,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	if (err < 0)
 		return err;
 
+	tp->data = tp_c;
 	if ((n = (struct tc_u_knode*)*arg) != NULL) {
 		if (TC_U32_KEY(n->handle) == 0)
 			return -EINVAL;

--=-tAd8Y73qgvSSB8671amH--

