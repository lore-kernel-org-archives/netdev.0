From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 10/41: xt_physdev fixes
Date: Tue, 24 Mar 2009 15:03:20 +0100 (MET)
Message-ID: <20090324140316.31401.31990.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34762 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755461AbZCXODX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:23 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4f1c3b7e7ee4d841c8af3a074dc361d6a7a77803
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Wed Feb 18 19:11:39 2009 +0100

    netfilter: xt_physdev fixes
    
    1) physdev_mt() incorrectly assumes nulldevname[] is aligned on an int
    
    2) It also uses word comparisons, while it could use long word ones.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 1bcdfc1..4b13ef7 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -24,9 +24,9 @@ static bool
 physdev_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	int i;
-	static const char nulldevname[IFNAMSIZ];
+	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct xt_physdev_info *info = par->matchinfo;
-	bool ret;
+	unsigned long ret;
 	const char *indev, *outdev;
 	const struct nf_bridge_info *nf_bridge;
 
@@ -68,10 +68,10 @@ physdev_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (!(info->bitmask & XT_PHYSDEV_OP_IN))
 		goto match_outdev;
 	indev = nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	for (i = 0, ret = false; i < IFNAMSIZ/sizeof(unsigned int); i++) {
-		ret |= (((const unsigned int *)indev)[i]
-			^ ((const unsigned int *)info->physindev)[i])
-			& ((const unsigned int *)info->in_mask)[i];
+	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
+		ret |= (((const unsigned long *)indev)[i]
+			^ ((const unsigned long *)info->physindev)[i])
+			& ((const unsigned long *)info->in_mask)[i];
 	}
 
 	if (!ret ^ !(info->invert & XT_PHYSDEV_OP_IN))
@@ -82,13 +82,12 @@ match_outdev:
 		return true;
 	outdev = nf_bridge->physoutdev ?
 		 nf_bridge->physoutdev->name : nulldevname;
-	for (i = 0, ret = false; i < IFNAMSIZ/sizeof(unsigned int); i++) {
-		ret |= (((const unsigned int *)outdev)[i]
-			^ ((const unsigned int *)info->physoutdev)[i])
-			& ((const unsigned int *)info->out_mask)[i];
+	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
+		ret |= (((const unsigned long *)outdev)[i]
+			^ ((const unsigned long *)info->physoutdev)[i])
+			& ((const unsigned long *)info->out_mask)[i];
 	}
-
-	return ret ^ !(info->invert & XT_PHYSDEV_OP_OUT);
+	return (!!ret ^ !(info->invert & XT_PHYSDEV_OP_OUT));
 }
 
 static bool physdev_mt_check(const struct xt_mtchk_param *par)
