From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/3] eth: use constant size address (revised)
Date: Thu, 13 Apr 2006 16:24:25 -0700
Message-ID: <20060413162425.4e50bec2@localhost.localdomain>
References: <20060411181053.862087000@localhost.localdomain>
	<20060411181136.913572000@localhost.localdomain>
	<20060411.172401.67034166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20386 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965041AbWDMXYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 19:24:43 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060411.172401.67034166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the ethernet support routines to use constant address size.
This generates smaller faster code.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- sky2-2.6.17.orig/net/ethernet/eth.c	2006-03-07 13:28:54.000000000 -0800
+++ sky2-2.6.17/net/ethernet/eth.c	2006-04-12 13:10:56.000000000 -0700
@@ -77,6 +77,8 @@
 {
 	struct ethhdr *eth = (struct ethhdr *)skb_push(skb,ETH_HLEN);
 
+	BUG_ON(dev->addr_len != ETH_ALEN);
+
 	/* 
 	 *	Set the protocol type. For a packet of type ETH_P_802_3 we put the length
 	 *	in here instead. It is up to the 802.2 layer to carry protocol information.
@@ -93,11 +95,11 @@
 	 
 	if(!saddr)
 		saddr = dev->dev_addr;
-	memcpy(eth->h_source,saddr,dev->addr_len);
+	memcpy(eth->h_source,saddr, ETH_ALEN);
 
 	if(daddr)
 	{
-		memcpy(eth->h_dest,daddr,dev->addr_len);
+		memcpy(eth->h_dest,daddr, ETH_ALEN);
 		return ETH_HLEN;
 	}
 	
@@ -107,7 +109,7 @@
 
 	if (dev->flags & (IFF_LOOPBACK|IFF_NOARP)) 
 	{
-		memset(eth->h_dest, 0, dev->addr_len);
+		memset(eth->h_dest, 0, ETH_ALEN);
 		return ETH_HLEN;
 	}
 	
@@ -140,7 +142,7 @@
 		       "%s: unable to resolve type %X addresses.\n", 
 		       dev->name, (int)eth->h_proto);
 		
-		memcpy(eth->h_source, dev->dev_addr, dev->addr_len);
+		memcpy(eth->h_source, dev->dev_addr, ETH_ALEN);
 		break;
 	}
 
@@ -223,8 +225,8 @@
 		return -1;
 
 	eth->h_proto = type;
-	memcpy(eth->h_source, dev->dev_addr, dev->addr_len);
-	memcpy(eth->h_dest, neigh->ha, dev->addr_len);
+	memcpy(eth->h_source, dev->dev_addr, ETH_ALEN);
+	memcpy(eth->h_dest, neigh->ha, ETH_ALEN);
 	hh->hh_len = ETH_HLEN;
 	return 0;
 }
@@ -236,7 +238,7 @@
 void eth_header_cache_update(struct hh_cache *hh, struct net_device *dev, unsigned char * haddr)
 {
 	memcpy(((u8*)hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
-	       haddr, dev->addr_len);
+	       haddr, ETH_ALEN);
 }
 
 EXPORT_SYMBOL(eth_type_trans);
@@ -246,7 +248,7 @@
 	struct sockaddr *addr=p;
 	if (netif_running(dev))
 		return -EBUSY;
-	memcpy(dev->dev_addr, addr->sa_data,dev->addr_len);
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	return 0;
 }
 
