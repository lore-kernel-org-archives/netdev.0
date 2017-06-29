From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/29] netfilter: ebt: Use new helper ebt_invalid_target to check target
Date: Fri, 30 Jun 2017 00:53:22 +0200
Message-ID: <1498776807-11124-25-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57674 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752426AbdF2WyA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:54:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 56050BDF5D
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 48113D2E4A
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:44 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 234CCD1CB1
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:42 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

Use the new helper function ebt_invalid_target instead of the old
macro INVALID_TARGET and other duplicated codes to enhance the readability.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge/ebtables.h | 2 --
 net/bridge/netfilter/ebt_dnat.c           | 2 +-
 net/bridge/netfilter/ebt_mark.c           | 2 +-
 net/bridge/netfilter/ebt_redirect.c       | 2 +-
 net/bridge/netfilter/ebt_snat.c           | 2 +-
 5 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index e0cbf17af780..2c2a5514b0df 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -122,8 +122,6 @@ extern unsigned int ebt_do_table(struct sk_buff *skb,
 #define BASE_CHAIN (par->hook_mask & (1 << NF_BR_NUMHOOKS))
 /* Clear the bit in the hook mask that tells if the rule is on a base chain */
 #define CLEAR_BASE_CHAIN_BIT (par->hook_mask &= ~(1 << NF_BR_NUMHOOKS))
-/* True if the target is not a standard target */
-#define INVALID_TARGET (info->target < -NUM_STANDARD_TARGETS || info->target >= 0)
 
 static inline bool ebt_invalid_target(int target)
 {
diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index e0bb624c3845..dfc86a0199da 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -61,7 +61,7 @@ static int ebt_dnat_tg_check(const struct xt_tgchk_param *par)
 	    (strcmp(par->table, "broute") != 0 ||
 	    hook_mask & ~(1 << NF_BR_BROUTING)))
 		return -EINVAL;
-	if (INVALID_TARGET)
+	if (ebt_invalid_target(info->target))
 		return -EINVAL;
 	return 0;
 }
diff --git a/net/bridge/netfilter/ebt_mark.c b/net/bridge/netfilter/ebt_mark.c
index 66697cbd0a8b..19f0f9592d32 100644
--- a/net/bridge/netfilter/ebt_mark.c
+++ b/net/bridge/netfilter/ebt_mark.c
@@ -44,7 +44,7 @@ static int ebt_mark_tg_check(const struct xt_tgchk_param *par)
 	tmp = info->target | ~EBT_VERDICT_BITS;
 	if (BASE_CHAIN && tmp == EBT_RETURN)
 		return -EINVAL;
-	if (tmp < -NUM_STANDARD_TARGETS || tmp >= 0)
+	if (ebt_invalid_target(tmp))
 		return -EINVAL;
 	tmp = info->target & ~EBT_VERDICT_BITS;
 	if (tmp != MARK_SET_VALUE && tmp != MARK_OR_VALUE &&
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 8d2a85e0594e..a7223eaf490b 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -47,7 +47,7 @@ static int ebt_redirect_tg_check(const struct xt_tgchk_param *par)
 	    (strcmp(par->table, "broute") != 0 ||
 	    hook_mask & ~(1 << NF_BR_BROUTING)))
 		return -EINVAL;
-	if (INVALID_TARGET)
+	if (ebt_invalid_target(info->target))
 		return -EINVAL;
 	return 0;
 }
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index e56ccd060d26..11cf9e9e9222 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -51,7 +51,7 @@ static int ebt_snat_tg_check(const struct xt_tgchk_param *par)
 	if (BASE_CHAIN && tmp == EBT_RETURN)
 		return -EINVAL;
 
-	if (tmp < -NUM_STANDARD_TARGETS || tmp >= 0)
+	if (ebt_invalid_target(tmp))
 		return -EINVAL;
 	tmp = info->target | EBT_VERDICT_BITS;
 	if ((tmp & ~NAT_ARP_BIT) != ~NAT_ARP_BIT)
-- 
2.1.4
