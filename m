From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] ethernet: optimize memcpy and memset
Date: Fri, 17 Aug 2007 16:29:50 -0700
Message-ID: <20070817162950.6d8d07cd@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43207 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755067AbXHQXav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 19:30:51 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethernet header management only needs to handle a fixed
size address (6 bytes). If the memcpy/memset are changed to
be passed a constant length, then compiler can optimize for
this case (and if it is smart eliminate string instructions).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ethernet/eth.c	2007-08-17 12:08:51.000000000 -0400
+++ b/net/ethernet/eth.c	2007-08-17 12:16:33.000000000 -0400
@@ -91,10 +91,10 @@ int eth_header(struct sk_buff *skb, stru
 
 	if (!saddr)
 		saddr = dev->dev_addr;
-	memcpy(eth->h_source, saddr, dev->addr_len);
+	memcpy(eth->h_source, saddr, ETH_ALEN);
 
 	if (daddr) {
-		memcpy(eth->h_dest, daddr, dev->addr_len);
+		memcpy(eth->h_dest, daddr, ETH_ALEN);
 		return ETH_HLEN;
 	}
 
@@ -103,7 +103,7 @@ int eth_header(struct sk_buff *skb, stru
 	 */
 
 	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP)) {
-		memset(eth->h_dest, 0, dev->addr_len);
+		memset(eth->h_dest, 0, ETH_ALEN);
 		return ETH_HLEN;
 	}
 
@@ -135,7 +135,7 @@ int eth_rebuild_header(struct sk_buff *s
 		       "%s: unable to resolve type %X addresses.\n",
 		       dev->name, (int)eth->h_proto);
 
-		memcpy(eth->h_source, dev->dev_addr, dev->addr_len);
+		memcpy(eth->h_source, dev->dev_addr, ETH_ALEN);
 		break;
 	}
 
@@ -233,8 +233,8 @@ int eth_header_cache(struct neighbour *n
 		return -1;
 
 	eth->h_proto = type;
-	memcpy(eth->h_source, dev->dev_addr, dev->addr_len);
-	memcpy(eth->h_dest, neigh->ha, dev->addr_len);
+	memcpy(eth->h_source, dev->dev_addr, ETH_ALEN);
+	memcpy(eth->h_dest, neigh->ha, ETH_ALEN);
 	hh->hh_len = ETH_HLEN;
 	return 0;
 }
@@ -251,7 +251,7 @@ void eth_header_cache_update(struct hh_c
 			     unsigned char *haddr)
 {
 	memcpy(((u8 *) hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
-	       haddr, dev->addr_len);
+	       haddr, ETH_ALEN);
 }
 
 /**
@@ -271,7 +271,7 @@ static int eth_mac_addr(struct net_devic
 		return -EBUSY;
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
-	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	return 0;
 }
 
