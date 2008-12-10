From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 4/9] netns: ip6mr: dynamically allocates mfc6_cache_array
Date: Wed, 10 Dec 2008 17:03:05 +0100
Message-ID: <20081210160302.733418821@theryb.frec.bull.fr>
References: <20081210160301.883947374@theryb.frec.bull.fr>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42414 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754377AbYLJQEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 11:04:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preliminary work to make IPv6 multicast forwarding netns-aware.

Dynamically allocates IPv6 multicast forwarding cache, mfc6_cache_array,
and moves it to struct netns_ipv6. 

At the moment, mfc6_cache_array is only referenced in init_net.

Replace 'ARRAY_SIZE(mfc6_cache_array)' with mfc6_cache_array size: MFC6_LINES.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/netns/ipv6.h |    1 +
 net/ipv6/ip6mr.c         |   47 +++++++++++++++++++++++++++++++----------------
 2 files changed, 32 insertions(+), 16 deletions(-)

Index: net-next-2.6/include/net/netns/ipv6.h
===================================================================
--- net-next-2.6.orig/include/net/netns/ipv6.h
+++ net-next-2.6/include/net/netns/ipv6.h
@@ -57,6 +57,7 @@ struct netns_ipv6 {
 	struct sock             *igmp_sk;
 #ifdef CONFIG_IPV6_MROUTE
 	struct sock		*mroute6_sk;
+	struct mfc6_cache	**mfc6_cache_array;
 	struct mif_device	*vif6_table;
 	int			maxvif;
 #endif
Index: net-next-2.6/net/ipv6/ip6mr.c
===================================================================
--- net-next-2.6.orig/net/ipv6/ip6mr.c
+++ net-next-2.6/net/ipv6/ip6mr.c
@@ -68,8 +68,6 @@ static int mroute_do_pim;
 #define mroute_do_pim 0
 #endif
 
-static struct mfc6_cache *mfc6_cache_array[MFC6_LINES];	/* Forwarding cache	*/
-
 static struct mfc6_cache *mfc_unres_queue;		/* Queue of unresolved entries */
 static atomic_t cache_resolve_queue_len;		/* Size of unresolved	*/
 
@@ -109,10 +107,11 @@ static struct mfc6_cache *ipmr_mfc_seq_i
 {
 	struct mfc6_cache *mfc;
 
-	it->cache = mfc6_cache_array;
+	it->cache = init_net.ipv6.mfc6_cache_array;
 	read_lock(&mrt_lock);
-	for (it->ct = 0; it->ct < ARRAY_SIZE(mfc6_cache_array); it->ct++)
-		for (mfc = mfc6_cache_array[it->ct]; mfc; mfc = mfc->next)
+	for (it->ct = 0; it->ct < MFC6_LINES; it->ct++)
+		for (mfc = init_net.ipv6.mfc6_cache_array[it->ct];
+		     mfc; mfc = mfc->next)
 			if (pos-- == 0)
 				return mfc;
 	read_unlock(&mrt_lock);
@@ -243,10 +242,10 @@ static void *ipmr_mfc_seq_next(struct se
 	if (it->cache == &mfc_unres_queue)
 		goto end_of_list;
 
-	BUG_ON(it->cache != mfc6_cache_array);
+	BUG_ON(it->cache != init_net.ipv6.mfc6_cache_array);
 
-	while (++it->ct < ARRAY_SIZE(mfc6_cache_array)) {
-		mfc = mfc6_cache_array[it->ct];
+	while (++it->ct < MFC6_LINES) {
+		mfc = init_net.ipv6.mfc6_cache_array[it->ct];
 		if (mfc)
 			return mfc;
 	}
@@ -274,7 +273,7 @@ static void ipmr_mfc_seq_stop(struct seq
 
 	if (it->cache == &mfc_unres_queue)
 		spin_unlock_bh(&mfc_unres_lock);
-	else if (it->cache == mfc6_cache_array)
+	else if (it->cache == init_net.ipv6.mfc6_cache_array)
 		read_unlock(&mrt_lock);
 }
 
@@ -680,7 +679,7 @@ static struct mfc6_cache *ip6mr_cache_fi
 	int line = MFC6_HASH(mcastgrp, origin);
 	struct mfc6_cache *c;
 
-	for (c = mfc6_cache_array[line]; c; c = c->next) {
+	for (c = init_net.ipv6.mfc6_cache_array[line]; c; c = c->next) {
 		if (ipv6_addr_equal(&c->mf6c_origin, origin) &&
 		    ipv6_addr_equal(&c->mf6c_mcastgrp, mcastgrp))
 			break;
@@ -925,7 +924,8 @@ static int ip6mr_mfc_delete(struct mf6cc
 
 	line = MFC6_HASH(&mfc->mf6cc_mcastgrp.sin6_addr, &mfc->mf6cc_origin.sin6_addr);
 
-	for (cp = &mfc6_cache_array[line]; (c = *cp) != NULL; cp = &c->next) {
+	for (cp = &init_net.ipv6.mfc6_cache_array[line];
+	     (c = *cp) != NULL; cp = &c->next) {
 		if (ipv6_addr_equal(&c->mf6c_origin, &mfc->mf6cc_origin.sin6_addr) &&
 		    ipv6_addr_equal(&c->mf6c_mcastgrp, &mfc->mf6cc_mcastgrp.sin6_addr)) {
 			write_lock_bh(&mrt_lock);
@@ -978,12 +978,26 @@ static int __net_init ip6mr_net_init(str
 		err = -ENOMEM;
 		goto fail;
 	}
+
+	/* Forwarding cache */
+	net->ipv6.mfc6_cache_array = kcalloc(MFC6_LINES,
+					     sizeof(struct mfc6_cache *),
+					     GFP_KERNEL);
+	if (!net->ipv6.mfc6_cache_array) {
+		err = -ENOMEM;
+		goto fail_mfc6_cache;
+	}
+	return 0;
+
+fail_mfc6_cache:
+	kfree(net->ipv6.vif6_table);
 fail:
 	return err;
 }
 
 static void __net_exit ip6mr_net_exit(struct net *net)
 {
+	kfree(net->ipv6.mfc6_cache_array);
 	kfree(net->ipv6.vif6_table);
 }
 
@@ -1062,7 +1076,8 @@ static int ip6mr_mfc_add(struct mf6cctl 
 
 	line = MFC6_HASH(&mfc->mf6cc_mcastgrp.sin6_addr, &mfc->mf6cc_origin.sin6_addr);
 
-	for (cp = &mfc6_cache_array[line]; (c = *cp) != NULL; cp = &c->next) {
+	for (cp = &init_net.ipv6.mfc6_cache_array[line];
+	     (c = *cp) != NULL; cp = &c->next) {
 		if (ipv6_addr_equal(&c->mf6c_origin, &mfc->mf6cc_origin.sin6_addr) &&
 		    ipv6_addr_equal(&c->mf6c_mcastgrp, &mfc->mf6cc_mcastgrp.sin6_addr))
 			break;
@@ -1093,8 +1108,8 @@ static int ip6mr_mfc_add(struct mf6cctl 
 		c->mfc_flags |= MFC_STATIC;
 
 	write_lock_bh(&mrt_lock);
-	c->next = mfc6_cache_array[line];
-	mfc6_cache_array[line] = c;
+	c->next = init_net.ipv6.mfc6_cache_array[line];
+	init_net.ipv6.mfc6_cache_array[line] = c;
 	write_unlock_bh(&mrt_lock);
 
 	/*
@@ -1140,10 +1155,10 @@ static void mroute_clean_tables(struct s
 	/*
 	 *	Wipe the cache
 	 */
-	for (i = 0; i < ARRAY_SIZE(mfc6_cache_array); i++) {
+	for (i = 0; i < MFC6_LINES; i++) {
 		struct mfc6_cache *c, **cp;
 
-		cp = &mfc6_cache_array[i];
+		cp = &init_net.ipv6.mfc6_cache_array[i];
 		while ((c = *cp) != NULL) {
 			if (c->mfc_flags & MFC_STATIC) {
 				cp = &c->next;

