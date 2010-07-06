From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridge br_multicast: BUG: unable to handle kernel NULL pointer
	dereference
Date: Tue, 6 Jul 2010 08:50:08 +0800
Message-ID: <20100706005008.GA11699@gondor.apana.org.au>
References: <1278356737.2163.45.camel@mendozza.osrc.amd.com> <20100706004835.GA11611@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Frank Arnold <frank.arnold@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59370 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757264Ab0GFAuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 20:50:13 -0400
Content-Disposition: inline
In-Reply-To: <20100706004835.GA11611@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 06, 2010 at 08:48:35AM +0800, Herbert Xu wrote:
> 
> bridge: Restore NULL check in br_mdb_ip_get

Resend with proper attribution.

bridge: Restore NULL check in br_mdb_ip_get

Somewhere along the line the NULL check in br_mdb_ip_get went
AWOL, causing crashes when we receive an IGMP packet with no
multicast table allocated.

This patch restores it and ensures all br_mdb_*_get functions
use it.

Reported-by: Frank Arnold <frank.arnold@amd.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 9d21d98..27ae946 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -99,6 +99,15 @@ static struct net_bridge_mdb_entry *__br_mdb_ip_get(
 	return NULL;
 }
 
+static struct net_bridge_mdb_entry *br_mdb_ip_get(
+	struct net_bridge_mdb_htable *mdb, struct br_ip *dst)
+{
+	if (!mdb)
+		return NULL;
+
+	return __br_mdb_ip_get(mdb, dst, br_ip_hash(mdb, dst));
+}
+
 static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 	struct net_bridge_mdb_htable *mdb, __be32 dst)
 {
@@ -107,7 +116,7 @@ static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 	br_dst.u.ip4 = dst;
 	br_dst.proto = htons(ETH_P_IP);
 
-	return __br_mdb_ip_get(mdb, &br_dst, __br_ip4_hash(mdb, dst));
+	return br_mdb_ip_get(mdb, &br_dst);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -119,23 +128,17 @@ static struct net_bridge_mdb_entry *br_mdb_ip6_get(
 	ipv6_addr_copy(&br_dst.u.ip6, dst);
 	br_dst.proto = htons(ETH_P_IPV6);
 
-	return __br_mdb_ip_get(mdb, &br_dst, __br_ip6_hash(mdb, dst));
+	return br_mdb_ip_get(mdb, &br_dst);
 }
 #endif
 
-static struct net_bridge_mdb_entry *br_mdb_ip_get(
-	struct net_bridge_mdb_htable *mdb, struct br_ip *dst)
-{
-	return __br_mdb_ip_get(mdb, dst, br_ip_hash(mdb, dst));
-}
-
 struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 					struct sk_buff *skb)
 {
 	struct net_bridge_mdb_htable *mdb = br->mdb;
 	struct br_ip ip;
 
-	if (!mdb || br->multicast_disabled)
+	if (br->multicast_disabled)
 		return NULL;
 
 	if (BR_INPUT_SKB_CB(skb)->igmp)

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
