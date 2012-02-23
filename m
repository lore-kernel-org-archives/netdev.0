From: pablo@netfilter.org
Subject: [PATCH 3/4] netfilter: ebtables: fix alignment problem in ppc
Date: Thu, 23 Feb 2012 01:02:25 +0100
Message-ID: <1329955346-2615-4-git-send-email-pablo@netfilter.org>
References: <1329955346-2615-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48651 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752971Ab2BWACq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 19:02:46 -0500
In-Reply-To: <1329955346-2615-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joerg Willmann <joe@clnt.de>

ebt_among extension of ebtables uses __alignof__(_xt_align) while the
corresponding kernel module uses __alignof__(ebt_replace) to determine
the alignment in EBT_ALIGN().

These are the results of these values on different platforms:

x86 x86_64 ppc
__alignof__(_xt_align) 4 8 8
__alignof__(ebt_replace) 4 8 4

ebtables fails to add rules which use the among extension.

I'm using kernel 2.6.33 and ebtables 2.0.10-4

According to Bart De Schuymer, userspace alignment was changed to
_xt_align to fix an alignment issue on a userspace32-kernel64 system
(he thinks it was for an ARM device). So userspace must be right.
The kernel alignment macro needs to change so it also uses _xt_align
instead of ebt_replace. The userspace changes date back from
June 29, 2009.

Signed-off-by: Joerg Willmann <joe@clnt.de>
Signed-off by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge/ebtables.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 8797ed1..4dd5bd6 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -285,8 +285,8 @@ struct ebt_table {
 	struct module *me;
 };
 
-#define EBT_ALIGN(s) (((s) + (__alignof__(struct ebt_replace)-1)) & \
-		     ~(__alignof__(struct ebt_replace)-1))
+#define EBT_ALIGN(s) (((s) + (__alignof__(struct _xt_align)-1)) & \
+		     ~(__alignof__(struct _xt_align)-1))
 extern struct ebt_table *ebt_register_table(struct net *net,
 					    const struct ebt_table *table);
 extern void ebt_unregister_table(struct net *net, struct ebt_table *table);
-- 
1.7.7.3
