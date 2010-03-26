From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipmr/ip6mr: prevent out-of-bounds vif_table access
Date: Fri, 26 Mar 2010 09:51:37 -0700 (PDT)
Message-ID: <20100326.095137.165317348.davem@davemloft.net>
References: <4BAC823F.8050409@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36251
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752422Ab0CZQvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 12:51:13 -0400
In-Reply-To: <4BAC823F.8050409@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Fri, 26 Mar 2010 10:45:35 +0100

> please consider the attached patch about IPv4 and IPv6 multicast.

Already fixed by Patrick McHardy recently:

commit a50436f2cd6e85794f7e1aad795ca8302177b896
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Mar 17 06:04:14 2010 +0000

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
    Signed-off-by: David S. Miller <davem@davemloft.net>

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
