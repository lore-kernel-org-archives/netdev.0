From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 33/62: xtables: symmetric COMPAT_XT_ALIGN definition
Date: Tue, 16 Feb 2010 15:56:04 +0100 (MET)
Message-ID: <20100216145602.2796.15889.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52020 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932368Ab0BPO4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:05 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 42107f5009da223daa800d6da6904d77297ae829
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Wed Feb 10 15:03:27 2010 +0100

    netfilter: xtables: symmetric COMPAT_XT_ALIGN definition
    
    Rewrite COMPAT_XT_ALIGN in terms of dummy structure hack.
    Compat counters logically have nothing to do with it.
    Use ALIGN() macro while I'm at it for same types.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 8b6c0e7..9d671eb 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -93,8 +93,7 @@ struct _xt_align {
 	__u64 u64;
 };
 
-#define XT_ALIGN(s) (((s) + (__alignof__(struct _xt_align)-1)) 	\
-			& ~(__alignof__(struct _xt_align)-1))
+#define XT_ALIGN(s) ALIGN((s), __alignof__(struct _xt_align))
 
 /* Standard return verdict, or do jump. */
 #define XT_STANDARD_TARGET ""
@@ -571,8 +570,14 @@ struct compat_xt_counters_info {
 	struct compat_xt_counters counters[0];
 };
 
-#define COMPAT_XT_ALIGN(s) (((s) + (__alignof__(struct compat_xt_counters)-1)) \
-		& ~(__alignof__(struct compat_xt_counters)-1))
+struct _compat_xt_align {
+	__u8 u8;
+	__u16 u16;
+	__u32 u32;
+	compat_u64 u64;
+};
+
+#define COMPAT_XT_ALIGN(s) ALIGN((s), __alignof__(struct _compat_xt_align))
 
 extern void xt_compat_lock(u_int8_t af);
 extern void xt_compat_unlock(u_int8_t af);
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index f01955c..5c564ff 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -364,7 +364,7 @@ int xt_check_match(struct xt_mtchk_param *par,
 		 * ebt_among is exempt from centralized matchsize checking
 		 * because it uses a dynamic-size data set.
 		 */
-		pr_err("%s_tables: %s match: invalid size %Zu != %u\n",
+		pr_err("%s_tables: %s match: invalid size %u != %u\n",
 		       xt_prefix[par->family], par->match->name,
 		       XT_ALIGN(par->match->matchsize), size);
 		return -EINVAL;
@@ -514,7 +514,7 @@ int xt_check_target(struct xt_tgchk_param *par,
 		    unsigned int size, u_int8_t proto, bool inv_proto)
 {
 	if (XT_ALIGN(par->target->targetsize) != size) {
-		pr_err("%s_tables: %s target: invalid size %Zu != %u\n",
+		pr_err("%s_tables: %s target: invalid size %u != %u\n",
 		       xt_prefix[par->family], par->target->name,
 		       XT_ALIGN(par->target->targetsize), size);
 		return -EINVAL;
