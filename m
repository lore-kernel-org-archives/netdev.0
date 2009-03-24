From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 12/41: xt_physdev: unfold two loops in physdev_mt()
Date: Tue, 24 Mar 2009 15:03:23 +0100 (MET)
Message-ID: <20090324140319.31401.12638.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34741 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758177AbZCXODZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:25 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit eacc17fb64f03b6c268aaf6cea320100d19d8af5
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Thu Feb 19 11:17:17 2009 +0100

    netfilter: xt_physdev: unfold two loops in physdev_mt()
    
    xt_physdev netfilter module can use an ifname_compare() helper
    so that two loops are unfolded.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 4b13ef7..44a234e 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -20,10 +20,27 @@ MODULE_DESCRIPTION("Xtables: Bridge physical device match");
 MODULE_ALIAS("ipt_physdev");
 MODULE_ALIAS("ip6t_physdev");
 
+static unsigned long ifname_compare(const char *_a, const char *_b, const char *_mask)
+{
+	const unsigned long *a = (const unsigned long *)_a;
+	const unsigned long *b = (const unsigned long *)_b;
+	const unsigned long *mask = (const unsigned long *)_mask;
+	unsigned long ret;
+
+	ret = (a[0] ^ b[0]) & mask[0];
+	if (IFNAMSIZ > sizeof(unsigned long))
+		ret |= (a[1] ^ b[1]) & mask[1];
+	if (IFNAMSIZ > 2 * sizeof(unsigned long))
+		ret |= (a[2] ^ b[2]) & mask[2];
+	if (IFNAMSIZ > 3 * sizeof(unsigned long))
+		ret |= (a[3] ^ b[3]) & mask[3];
+	BUILD_BUG_ON(IFNAMSIZ > 4 * sizeof(unsigned long));
+	return ret;
+}
+
 static bool
 physdev_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
-	int i;
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct xt_physdev_info *info = par->matchinfo;
 	unsigned long ret;
@@ -68,11 +85,7 @@ physdev_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (!(info->bitmask & XT_PHYSDEV_OP_IN))
 		goto match_outdev;
 	indev = nf_bridge->physindev ? nf_bridge->physindev->name : nulldevname;
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)indev)[i]
-			^ ((const unsigned long *)info->physindev)[i])
-			& ((const unsigned long *)info->in_mask)[i];
-	}
+	ret = ifname_compare(indev, info->physindev, info->in_mask);
 
 	if (!ret ^ !(info->invert & XT_PHYSDEV_OP_IN))
 		return false;
@@ -82,11 +95,8 @@ match_outdev:
 		return true;
 	outdev = nf_bridge->physoutdev ?
 		 nf_bridge->physoutdev->name : nulldevname;
-	for (i = 0, ret = 0; i < IFNAMSIZ/sizeof(unsigned long); i++) {
-		ret |= (((const unsigned long *)outdev)[i]
-			^ ((const unsigned long *)info->physoutdev)[i])
-			& ((const unsigned long *)info->out_mask)[i];
-	}
+	ret = ifname_compare(outdev, info->physoutdev, info->out_mask);
+
 	return (!!ret ^ !(info->invert & XT_PHYSDEV_OP_OUT));
 }
 
