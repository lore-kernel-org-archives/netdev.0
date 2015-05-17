From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net v2] switchdev: don't abort hardware ipv4 fib offload on failure to program fib entry in hardware
Date: Sat, 16 May 2015 20:46:42 -0700
Message-ID: <1431834402-4031-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sfeldma@gmail.com, john.fastabend@gmail.com,
	jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34137 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbbEQDqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 23:46:49 -0400
Received: by pdeq5 with SMTP id q5so90098151pde.1
        for <netdev@vger.kernel.org>; Sat, 16 May 2015 20:46:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch removes the calls to netdev_switch_fib_ipv4_abort when
there is an error in programming fib entry in hardware.

On most systems where you can offload routes to hardware,
doing routing in software is not an option (the cpu limitations
make routing impossible in software).

I understand that this was added to keep the first fib offload support
simple.

As discussed in the RFC patch, available options:
a) Fail fib entry add on hardware offload failure on switch devices, and
return appropriate error to the user by default (this patch)
b) make the behaviour in a) conditional on a global flag/sysctl (a per fib
entry flag will not work because by default user/routing-daemons dont care
if they are hardware offloaded)
c) for users/routing-daemons interested in controlling hardware
offload behaviour there is always the per fib entry flag RTNH_F_OFFLOAD

Considering the characteristics of the systems that support fib offloads,
this patch implements a). Also making a) the default will enable easier/faster
migration of existing routing apps to switch devices.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
RFC to v1:
  - rebase to net
  - remove fib_offload_disabled flag and all associated code as suggested by
    scott feldman

(This patch is currently against net. If there is any reason to move it to
net-next, I can respin)

 include/net/netns/ipv4.h  |    1 -
 net/ipv4/fib_trie.c       |    5 +----
 net/switchdev/switchdev.c |   23 -----------------------
 3 files changed, 1 insertion(+), 28 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 614a49b..31919b1 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -47,7 +47,6 @@ struct netns_ipv4 {
 	int			fib_num_tclassid_users;
 #endif
 	struct hlist_head	*fib_table_hash;
-	bool			fib_offload_disabled;
 	struct sock		*fibnl;
 
 	struct sock  * __percpu	*icmp_sk;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 64c2076..ef523d3 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1171,7 +1171,6 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 							 cfg->fc_nlflags,
 							 tb->tb_id);
 			if (err) {
-				netdev_switch_fib_ipv4_abort(fi);
 				kmem_cache_free(fn_alias_kmem, new_fa);
 				goto out;
 			}
@@ -1219,10 +1218,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 					 cfg->fc_type,
 					 cfg->fc_nlflags,
 					 tb->tb_id);
-	if (err) {
-		netdev_switch_fib_ipv4_abort(fi);
+	if (err)
 		goto out_free_new_fa;
-	}
 
 	/* Insert new entry to the list. */
 	err = fib_insert_alias(t, tp, l, new_fa, fa, key);
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 055453d..d1269c4 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -325,9 +325,6 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 		return 0;
 #endif
 
-	if (fi->fib_net->ipv4.fib_offload_disabled)
-		return 0;
-
 	dev = netdev_switch_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
@@ -382,23 +379,3 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	return err;
 }
 EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_del);
-
-/**
- *	netdev_switch_fib_ipv4_abort - Abort an IPv4 FIB operation
- *
- *	@fi: route FIB info structure
- */
-void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
-{
-	/* There was a problem installing this route to the offload
-	 * device.  For now, until we come up with more refined
-	 * policy handling, abruptly end IPv4 fib offloading for
-	 * for entire net by flushing offload device(s) of all
-	 * IPv4 routes, and mark IPv4 fib offloading broken from
-	 * this point forward.
-	 */
-
-	fib_flush_external(fi->fib_net);
-	fi->fib_net->ipv4.fib_offload_disabled = true;
-}
-EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_abort);
-- 
1.7.10.4
