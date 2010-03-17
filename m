From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] net: ipmr/ip6mr: fix potential out-of-bounds vif_table access
Date: Wed, 17 Mar 2010 17:00:50 +0100
Message-ID: <4BA0FCB2.7010009@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020805010408060304020109"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60824 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161Ab0CQQAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 12:00:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020805010408060304020109
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------020805010408060304020109
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 65782983286f43e2b14eec2d7287171a9957a754
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Mar 17 16:54:20 2010 +0100

    net: ipmr/ip6mr: fix potential out-of-bounds vif_table access
    
    mfc_parent of cache entries is used to index into the vif_table and is
    initialised from mfcctl->mfcc_parent. This can take values of to 2^16-1,
    while the vif_table has only MAXVIFS (32) entries. The same problem
    affects ip6mr.
    
    Refuse invalid values to fix a potential out-of-bounds access. Unlike
    the other validity checks, this is checked in ipmr_mfc_add() instead of
    the setsockopt handler since its unused in the delete path and might be
    uninitialized.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 8582e12..0b9d03c 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -802,6 +802,9 @@ static int ipmr_mfc_add(struct net *net, struct mfcctl *mfc, int mrtsock)
 	int line;
 	struct mfc_cache *uc, *c, **cp;
 
+	if (mfc->mfcc_parent >= MAXVIFS)
+		return -ENFILE;
+
 	line = MFC_HASH(mfc->mfcc_mcastgrp.s_addr, mfc->mfcc_origin.s_addr);
 
 	for (cp = &net->ipv4.mfc_cache_array[line];
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 52e0f74..23e4ac0 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1113,6 +1113,9 @@ static int ip6mr_mfc_add(struct net *net, struct mf6cctl *mfc, int mrtsock)
 	unsigned char ttls[MAXMIFS];
 	int i;
 
+	if (mfc->mf6cc_parent >= MAXMIFS)
+		return -ENFILE;
+
 	memset(ttls, 255, MAXMIFS);
 	for (i = 0; i < MAXMIFS; i++) {
 		if (IF_ISSET(i, &mfc->mf6cc_ifset))

--------------020805010408060304020109--
