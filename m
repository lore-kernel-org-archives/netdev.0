From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] netfilter: xt_physdev fixes
Date: Wed, 18 Feb 2009 18:36:57 +0100
Message-ID: <499C4739.3000800@cosmosbay.com>
References: <497F4C2F.9000804@hp.com> <497F5BCD.9060807@hp.com> <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org> <498330B2.4060004@cosmosbay.com> <20090130172705.GB18453@one.firstfloor.org> <499032A4.9090301@trash.net> <499C24FF.90302@cosmosbay.com> <499C2766.5090904@trash.net> <499C3871.4030600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <499C3871.4030600@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick

Please find following patch to prepare next one (loop unrolling)

I am not sure xt_physdev_info is aligned, either on an int or a long,
so please check my assertion before applying :)



Thank you

[PATCH] netfilter: xt_physdev fixes

1) physdev_mt() incorrectly assumes nulldevname[] is aligned on an int

2) It also uses word comparisons, while it could use long word ones.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
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
