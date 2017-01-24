From: David Windsor <dwindsor@gmail.com>
Subject: [PATCH net] net: free ip_vs_dest structs when refcnt=0
Date: Tue, 24 Jan 2017 07:48:20 -0500
Message-ID: <1485262100-12366-1-git-send-email-dwindsor@gmail.com>
Cc: keescook@chromium.org, elena.reshetova@intel.com, ja@ssi.bg,
        dwindsor@gmail.com, ishkamiel@gmail.com
To: netdev@vger.kernel.org, kernel-hardening@lists.openwall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:36596 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750833AbdAXMs3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 07:48:29 -0500
Received: by mail-qt0-f195.google.com with SMTP id l7so24941186qtd.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 04:48:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the ip_vs_dest cache frees ip_vs_dest objects when their reference
count becomes < 0.  Aside from not being semantically sound, this is problematic
for the new type refcount_t, which will be introduced shortly in a separate patch.
refcount_t is the new kernel type for holding reference counts, and provides
overflow protection and a constrained interface relative to atomic_t (the type
currently being used for kernel reference counts).

Per Juilan Anastasov: "The problem is that dest_trash currently holds deleted
dests (unlinked from RCU lists) with refcnt=0."  Changing dest_trash to hold
dest with refcnt=1 will allow us to free ip_vs_dest structs when their refcnt=0,
in ip_vs_dest_put_and_free().

Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/ip_vs.h            | 2 +-
 net/netfilter/ipvs/ip_vs_ctl.c | 4 +---
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index cd6018a..a3e78ad 100644
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
index 55e0169..6b5492e 100644
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
@@ -1084,7 +1083,6 @@ static void __ip_vs_del_dest(struct netns_ipvs *ipvs, struct ip_vs_dest *dest,
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
2.7.4
