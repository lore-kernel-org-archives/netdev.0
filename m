From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 2/3] netns: add dummy struct inside "struct net_generic"
Date: Fri, 2 Dec 2016 04:12:58 +0300
Message-ID: <20161202011258.GC31170@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:35802 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757476AbcLAXNJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 18:13:09 -0500
Received: by mail-lf0-f66.google.com with SMTP id p100so20469341lfg.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 15:13:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is precursor to fixing "[id - 1]" bloat inside net_generic().

Name "s" is chosen to complement name "u" often used for dummy unions.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/generic.h |    6 ++++--
 net/core/net_namespace.c    |    8 ++++----
 2 files changed, 8 insertions(+), 6 deletions(-)

--- a/include/net/netns/generic.h
+++ b/include/net/netns/generic.h
@@ -25,8 +25,10 @@
  */
 
 struct net_generic {
-	unsigned int len;
-	struct rcu_head rcu;
+	struct {
+		unsigned int len;
+		struct rcu_head rcu;
+	} s;
 
 	void *ptr[0];
 };
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -50,7 +50,7 @@ static struct net_generic *net_alloc_generic(void)
 
 	ng = kzalloc(generic_size, GFP_KERNEL);
 	if (ng)
-		ng->len = max_gen_ptrs;
+		ng->s.len = max_gen_ptrs;
 
 	return ng;
 }
@@ -64,7 +64,7 @@ static int net_assign_generic(struct net *net, unsigned int id, void *data)
 
 	old_ng = rcu_dereference_protected(net->gen,
 					   lockdep_is_held(&net_mutex));
-	if (old_ng->len >= id) {
+	if (old_ng->s.len >= id) {
 		old_ng->ptr[id - 1] = data;
 		return 0;
 	}
@@ -84,11 +84,11 @@ static int net_assign_generic(struct net *net, unsigned int id, void *data)
 	 * the old copy for kfree after a grace period.
 	 */
 
-	memcpy(&ng->ptr, &old_ng->ptr, old_ng->len * sizeof(void*));
+	memcpy(&ng->ptr, &old_ng->ptr, old_ng->s.len * sizeof(void*));
 	ng->ptr[id - 1] = data;
 
 	rcu_assign_pointer(net->gen, ng);
-	kfree_rcu(old_ng, rcu);
+	kfree_rcu(old_ng, s.rcu);
 	return 0;
 }
 
