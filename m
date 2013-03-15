From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] net core: optimize netdev_create_hash()
Date: Sat, 16 Mar 2013 00:32:11 +0800
Message-ID: <1363365131-7906-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:46408 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab3COQcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 12:32:21 -0400
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Sat, 16 Mar 2013 02:27:12 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 831332CE804C
	for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 03:32:15 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2FGJJal10223928
	for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 03:19:19 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2FGWEH6006287
	for <netdev@vger.kernel.org>; Sat, 16 Mar 2013 03:32:15 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev_create_hash() is divded into two steps:
1. allocate space for hash_head
2. initialize hash_head->first to NULL for each hash_head

This patch merge the two steps into one step.

When allocating the space for hash_head, it will use kzalloc() instead of
kmalloc(). Then hash_head->first is set to NULL during the allocation step,
which means it is not necessary to call INIT_HLIST_HEAD() for each hash_head.

This will:
1. reduce the code size
2. reduce the run time of iteration on initializing hash_head array
---
 net/core/dev.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index f64e439..79f0666 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6564,13 +6564,15 @@ EXPORT_SYMBOL(netdev_increment_features);
 
 static struct hlist_head *netdev_create_hash(void)
 {
-	int i;
 	struct hlist_head *hash;
 
-	hash = kmalloc(sizeof(*hash) * NETDEV_HASHENTRIES, GFP_KERNEL);
-	if (hash != NULL)
-		for (i = 0; i < NETDEV_HASHENTRIES; i++)
-			INIT_HLIST_HEAD(&hash[i]);
+	hash = kzalloc(sizeof(*hash) * NETDEV_HASHENTRIES, GFP_KERNEL);
+
+	/*
+	 * hash[i]->first is set to NULL in kzalloc()
+	 *
+	 * INIT_HLIST_HEAD(&hash[i]) is not necessary now
+	 */
 
 	return hash;
 }
-- 
1.7.5.4
