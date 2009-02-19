From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: unfold two loops in physdev_mt()
Date: Thu, 19 Feb 2009 09:00:11 +0100
Message-ID: <499D118B.1040309@cosmosbay.com>
References: <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org> <498330B2.4060004@cosmosbay.com> <20090130172705.GB18453@one.firstfloor.org> <499032A4.9090301@trash.net> <499C24FF.90302@cosmosbay.com> <499C2766.5090904@trash.net> <499C3871.4030600@cosmosbay.com> <499C4739.3000800@cosmosbay.com> <499C4FEB.7040706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44836 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbZBSIAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 03:00:24 -0500
In-Reply-To: <499C4FEB.7040706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xt_physdev netfilter module can use an ifname_compare() helper
so that two loops are unfolded.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/netfilter/xt_physdev.c |   32 +++++++++++++++++++++-----------
 1 files changed, 21 insertions(+), 11 deletions(-)

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
 
