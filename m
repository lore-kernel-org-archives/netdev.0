From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 4/9] netns: ipmr: dynamically allocates mfc_cache_array
Date: Thu, 22 Jan 2009 15:56:18 +0100
Message-ID: <20090122145615.734518427@theryb.frec.bull.fr>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58916 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753666AbZAVO5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:57:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv4 multicast routing netns-aware.

Dynamically allocates IPv4 multicast forwarding cache, mfc_cache_array,
and moves it to struct netns_ipv4. 

At the moment, mfc_cache_array is only referenced in init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

---
 include/net/netns/ipv4.h |    1 +
 net/ipv4/ipmr.c          |   41 ++++++++++++++++++++++++++++-------------
 2 files changed, 29 insertions(+), 13 deletions(-)

Index: net-next-2.6/include/net/netns/ipv4.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv4.h
+++ net-next-2.6/include/net/netns/ipv4.h
@@ -57,6 +57,7 @@ struct netns_ipv4 {
 
 #ifdef CONFIG_IP_MROUTE
 	struct sock		*mroute_sk;
+	struct mfc_cache	**mfc_cache_array;
 	struct vif_device	*vif_table;
 	int			maxvif;
 #endif
Index: net-next-2.6/net/ipv4/ipmr.c
===================================================================
--- net-next-2.6.orig/net/ipv4/ipmr.c
+++ net-next-2.6/net/ipv4/ipmr.c
@@ -82,8 +82,6 @@ static DEFINE_RWLOCK(mrt_lock);
 static int mroute_do_assert;				/* Set in PIM assert	*/
 static int mroute_do_pim;
 
-static struct mfc_cache *mfc_cache_array[MFC_LINES];	/* Forwarding cache	*/
-
 static struct mfc_cache *mfc_unres_queue;		/* Queue of unresolved entries */
 static atomic_t cache_resolve_queue_len;		/* Size of unresolved	*/
 
@@ -524,7 +522,7 @@ static struct mfc_cache *ipmr_cache_find
 	int line = MFC_HASH(mcastgrp, origin);
 	struct mfc_cache *c;
 
-	for (c=mfc_cache_array[line]; c; c = c->next) {
+	for (c = init_net.ipv4.mfc_cache_array[line]; c; c = c->next) {
 		if (c->mfc_origin==origin && c->mfc_mcastgrp==mcastgrp)
 			break;
 	}
@@ -764,7 +762,8 @@ static int ipmr_mfc_delete(struct mfcctl
 
 	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	for (cp=&mfc_cache_array[line]; (c=*cp) != NULL; cp = &c->next) {
+	for (cp = &init_net.ipv4.mfc_cache_array[line];
+	     (c = *cp) != NULL; cp = &c->next) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr) {
 			write_lock_bh(&mrt_lock);
@@ -785,7 +784,8 @@ static int ipmr_mfc_add(struct mfcctl *m
 
 	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
-	for (cp=&mfc_cache_array[line]; (c=*cp) != NULL; cp = &c->next) {
+	for (cp = &init_net.ipv4.mfc_cache_array[line];
+	     (c = *cp) != NULL; cp = &c->next) {
 		if (c->mfc_origin == mfc->mfcc_origin.s_addr &&
 		    c->mfc_mcastgrp == mfc->mfcc_mcastgrp.s_addr)
 			break;
@@ -816,8 +816,8 @@ static int ipmr_mfc_add(struct mfcctl *m
 		c->mfc_flags |= MFC_STATIC;
 
 	write_lock_bh(&mrt_lock);
-	c->next = mfc_cache_array[line];
-	mfc_cache_array[line] = c;
+	c->next = init_net.ipv4.mfc_cache_array[line];
+	init_net.ipv4.mfc_cache_array[line] = c;
 	write_unlock_bh(&mrt_lock);
 
 	/*
@@ -866,7 +866,7 @@ static void mroute_clean_tables(struct s
 	for (i=0; i<MFC_LINES; i++) {
 		struct mfc_cache *c, **cp;
 
-		cp = &mfc_cache_array[i];
+		cp = &init_net.ipv4.mfc_cache_array[i];
 		while ((c = *cp) != NULL) {
 			if (c->mfc_flags&MFC_STATIC) {
 				cp = &c->next;
@@ -1767,10 +1767,11 @@ static struct mfc_cache *ipmr_mfc_seq_id
 {
 	struct mfc_cache *mfc;
 
-	it->cache = mfc_cache_array;
+	it->cache = init_net.ipv4.mfc_cache_array;
 	read_lock(&mrt_lock);
 	for (it->ct = 0; it->ct < MFC_LINES; it->ct++)
-		for (mfc = mfc_cache_array[it->ct]; mfc; mfc = mfc->next)
+		for (mfc = init_net.ipv4.mfc_cache_array[it->ct];
+		     mfc; mfc = mfc->next)
 			if (pos-- == 0)
 				return mfc;
 	read_unlock(&mrt_lock);
@@ -1812,10 +1813,10 @@ static void *ipmr_mfc_seq_next(struct se
 	if (it->cache == &mfc_unres_queue)
 		goto end_of_list;
 
-	BUG_ON(it->cache != mfc_cache_array);
+	BUG_ON(it->cache != init_net.ipv4.mfc_cache_array);
 
 	while (++it->ct < MFC_LINES) {
-		mfc = mfc_cache_array[it->ct];
+		mfc = init_net.ipv4.mfc_cache_array[it->ct];
 		if (mfc)
 			return mfc;
 	}
@@ -1843,7 +1844,7 @@ static void ipmr_mfc_seq_stop(struct seq
 
 	if (it->cache == &mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
-	else if (it->cache == mfc_cache_array)
+	else if (it->cache == init_net.ipv4.mfc_cache_array)
 		read_unlock(&mrt_lock);
 }
 
@@ -1929,12 +1930,26 @@ static int __net_init ipmr_net_init(stru
 		err = -ENOMEM;
 		goto fail;
 	}
+
+	/* Forwarding cache */
+	net->ipv4.mfc_cache_array = kcalloc(MFC_LINES,
+					    sizeof(struct mfc_cache *),
+					    GFP_KERNEL);
+	if (!net->ipv4.mfc_cache_array) {
+		err = -ENOMEM;
+		goto fail_mfc_cache;
+	}
+	return 0;
+
+fail_mfc_cache:
+	kfree(net->ipv4.vif_table);
 fail:
 	return err;
 }
 
 static void __net_exit ipmr_net_exit(struct net *net)
 {
+	kfree(net->ipv4.mfc_cache_array);
 	kfree(net->ipv4.vif_table);
 }
 

