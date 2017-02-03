From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 26/27] ipvs: free ip_vs_dest structs when refcnt=0
Date: Fri,  3 Feb 2017 13:25:37 +0100
Message-ID: <1486124738-3013-27-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59050 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753304AbdBCM2t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:49 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E08A6E04C6
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CF3BFDA801
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:47 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 5FC00DA81B
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:44 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Windsor <dwindsor@gmail.com>

Currently, the ip_vs_dest cache frees ip_vs_dest objects when their
reference count becomes < 0.  Aside from not being semantically sound,
this is problematic for the new type refcount_t, which will be introduced
shortly in a separate patch. refcount_t is the new kernel type for
holding reference counts, and provides overflow protection and a
constrained interface relative to atomic_t (the type currently being
used for kernel reference counts).

Per Julian Anastasov: "The problem is that dest_trash currently holds
deleted dests (unlinked from RCU lists) with refcnt=0."  Changing
dest_trash to hold dest with refcnt=1 will allow us to free ip_vs_dest
structs when their refcnt=0, in ip_vs_dest_put_and_free().

Signed-off-by: David Windsor <dwindsor@gmail.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/ip_vs.h            | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 8 +++-----
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 4b46c591b542..7bdfa7d78363 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1421,7 +1421,7 @@ static inline void ip_vs_dest_put(struct ip_vs_dest *dest)
 
 static inline void ip_vs_dest_put_and_free(struct ip_vs_dest *dest)
 {
-	if (atomic_dec_return(&dest->refcnt) < 0)
+	if (atomic_dec_and_test(&dest->refcnt))
 		kfree(dest);
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 55e0169caa4c..5fc4836e7c79 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -711,7 +711,6 @@ ip_vs_trash_get_dest(struct ip_vs_service *svc, int dest_af,
 		      dest->vport == svc->port))) {
 			/* HIT */
 			list_del(&dest->t_list);
-			ip_vs_dest_hold(dest);
 			goto out;
 		}
 	}
@@ -741,7 +740,7 @@ static void ip_vs_dest_free(struct ip_vs_dest *dest)
  *  When the ip_vs_control_clearup is activated by ipvs module exit,
  *  the service tables must have been flushed and all the connections
  *  are expired, and the refcnt of each destination in the trash must
- *  be 0, so we simply release them here.
+ *  be 1, so we simply release them here.
  */
 static void ip_vs_trash_cleanup(struct netns_ipvs *ipvs)
 {
@@ -1080,11 +1079,10 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
 	if (list_empty(&ipvs->dest_trash) && !cleanup)
 		mod_timer(&ipvs->dest_trash_timer,
 			  jiffies + (IP_VS_DEST_TRASH_PERIOD >> 1));
-	/* dest lives in trash without reference */
+	/* dest lives in trash with reference */
 	list_add(&dest->t_list, &ipvs->dest_trash);
 	dest->idle_start = 0;
 	spin_unlock_bh(&ipvs->dest_trash_lock);
-	ip_vs_dest_put(dest);
 }
 
 
@@ -1160,7 +1158,7 @@ static void ip_vs_dest_trash_expire(unsigned long data)
 
 	spin_lock(&ipvs->dest_trash_lock);
 	list_for_each_entry_safe(dest, next, &ipvs->dest_trash, t_list) {
-		if (atomic_read(&dest->refcnt) > 0)
+		if (atomic_read(&dest->refcnt) > 1)
 			continue;
 		if (dest->idle_start) {
 			if (time_before(now, dest->idle_start +
-- 
2.1.4
