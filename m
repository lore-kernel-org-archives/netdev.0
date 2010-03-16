From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] BUG: unable to handle kernel NULL pointer dereference
	at br_multicast_leave_group
Date: Tue, 16 Mar 2010 11:10:05 +0800
Message-ID: <20100316031005.GA17727@gondor.apana.org.au>
References: <4B9C49E7.1080703@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: michael-dev@fami-braun.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51578 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965922Ab0CPDKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 23:10:08 -0400
Content-Disposition: inline
In-Reply-To: <4B9C49E7.1080703@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

michael-dev@fami-braun.de wrote:
> 
> I'm currently using linux-next and have been running into an OOPs which
> I think might be caused by a patch you submitted on 2010-02-27.
> 
> It's a linux-next kernel from 2010-03-12 on an x86 system and it
> OOPs in the bridge module in br_mdp_ip_get (called by
> br_multicast_leave_group) because the br->mdb is null.

Thanks, there's actually another spot (the query handler) where
the same thing can happen.

Here's a patch to fix them both.

bridge: Move NULL mdb check into br_mdb_ip_get

Since all callers of br_mdb_ip_get need to check whether the
hash table is NULL, this patch moves the check into the function.

This fixes the two callers (query/leave handler) that didn't
check it.

Reported-by: Michael Braun <michael-dev@fami-braun.de>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index fd96a8d..398221e 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -49,22 +49,23 @@ static struct net_bridge_mdb_entry *__br_mdb_ip_get(
 static struct net_bridge_mdb_entry *br_mdb_ip_get(
 	struct net_bridge_mdb_htable *mdb, __be32 dst)
 {
+	if (!mdb)
+		return NULL;
+
 	return __br_mdb_ip_get(mdb, dst, br_ip_hash(mdb, dst));
 }
 
 struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 					struct sk_buff *skb)
 {
-	struct net_bridge_mdb_htable *mdb = br->mdb;
-
-	if (!mdb || br->multicast_disabled)
+	if (br->multicast_disabled)
 		return NULL;
 
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		if (BR_INPUT_SKB_CB(skb)->igmp)
 			break;
-		return br_mdb_ip_get(mdb, ip_hdr(skb)->daddr);
+		return br_mdb_ip_get(br->mdb, ip_hdr(skb)->daddr);
 	}
 
 	return NULL;

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
