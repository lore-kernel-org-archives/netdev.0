From: Kai Germaschewski <kai-germaschewski@uiowa.edu>
Subject: [BK PATCH] Make eth.c independent of dev->hard_header_len
Date: Sun, 29 Sep 2002 13:34:59 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0209291325460.28578-100000@chaos.physics.uiowa.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Dave,

I'd like to submit to small changes to net/ethernet/eth.c, which makes
it work independently of the value of dev->hard_header_len.

It does not change any existing behavior, since for eth_header(),
only the sign of the return value is changed anyway and eth_type_trans() 
is only used for devices where dev->hard_header_len == ETH_HLEN anyway.

This patch makes (IMO) eth.c more robust by using ETH_HLEN instead.
eth_header() already does a skb_push(, ETH_HLEN) anyway, so it makes 
more sense to return ETH_HLEN instead of ->hard_header_len.

eth_trans_type() does a skb_pull(, dev->hard_header_len), which is 
inconsistent, since it interprets the pulled header as struct ethhdr,
which is ETH_HLEN long. It does not really make a difference currently,
since dev->hard_header_len == ETH_HLEN for all users. However, there are
(at least) two places in the tree which use their private copy of
eth_type_trans() since they have a non-standard dev->hard_header_len and
thus cannot use the generic function.

These two csets do not change the behavior for existing code, but remove
all references to dev->hard_header_len in net/ethernet/eth.c and thus make
these functions useful for other devices which have a non-standard
dev->hard_header_len ("ethernet over ISDN", e.g.).

--Kai


Pull from http://linux-isdn.bkbits.net/linux-2.5.net

(Merging changesets omitted for clarity)

-----------------------------------------------------------------------------
ChangeSet@1.635, 2002-09-29 13:00:13-05:00, kai@tp1.ruhr-uni-bochum.de
  NET: Do not use dev->hard_header_len in eth_header()
  
  The actual return value of eth_header() is never used, only its sign.
  So it does not make a difference if we return dev->hard_header_len or
  ETH_HLEN, but the latter makes more sense as that is the number of bytes
  we added to the front of the frame.
  
  For 99% of the drivers, dev->hard_header_len == ETH_HLEN, so no difference
  at all, but if a driver actually needs additional headroom and thus
  has dev->hard_header_len > ETH_HLEN, the process of building the ethernet
  header should not care at all. 

 ----------------------------------------------------------------------------
 eth.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

-----------------------------------------------------------------------------
ChangeSet@1.636, 2002-09-29 13:08:19-05:00, kai@tp1.ruhr-uni-bochum.de
  NET: Do not use dev->hard_header_len in eth_type_trans()
  
  eth_type_trans() currently pulls dev->hard_header_len off a frame
  passed to it, however always interpreting it as a ethernet header.
  
  Grepping shows that it is only used on net devices where
  dev->hard_header_len == ETH_HLEN. It makes more sense to actually
  pull of ETH_HLEN for the header (it's treated as a struct of the length
  anyway), not changing the behavior for the existing users but allowing
  two places which had to use their private copies of eth_trans_type to
  use the generic routine now.
  
  One place is in drivers/net/hamachi.c and converted in this cset, the other
  one is in the ISDN network code, patch will follow.

 ----------------------------------------------------------------------------
 drivers/net/hamachi.c |   63 --------------------------------------------------
 net/ethernet/eth.c    |    2 -
 2 files changed, 1 insertion(+), 64 deletions(-)





=============================================================================
unified diffs follow for reference
=============================================================================

-----------------------------------------------------------------------------
ChangeSet@1.635, 2002-09-29 13:00:13-05:00, kai@tp1.ruhr-uni-bochum.de
  NET: Do not use dev->hard_header_len in eth_header()
  
  The actual return value of eth_header() is never used, only its sign.
  So it does not make a difference if we return dev->hard_header_len or
  ETH_HLEN, but the latter makes more sense as that is the number of bytes
  we added to the front of the frame.
  
  For 99% of the drivers, dev->hard_header_len == ETH_HLEN, so no difference
  at all, but if a driver actually needs additional headroom and thus
  has dev->hard_header_len > ETH_HLEN, the process of building the ethernet
  header should not care at all. 

  ---------------------------------------------------------------------------

diff -Nru a/net/ethernet/eth.c b/net/ethernet/eth.c
--- a/net/ethernet/eth.c	Sun Sep 29 13:10:35 2002
+++ b/net/ethernet/eth.c	Sun Sep 29 13:10:35 2002
@@ -103,16 +103,16 @@
 	if (dev->flags & (IFF_LOOPBACK|IFF_NOARP)) 
 	{
 		memset(eth->h_dest, 0, dev->addr_len);
-		return(dev->hard_header_len);
+		return ETH_HLEN;
 	}
 	
 	if(daddr)
 	{
 		memcpy(eth->h_dest,daddr,dev->addr_len);
-		return dev->hard_header_len;
+		return ETH_HLEN;
 	}
 	
-	return -dev->hard_header_len;
+	return -ETH_HLEN;
 }
 
 

-----------------------------------------------------------------------------
ChangeSet@1.636, 2002-09-29 13:08:19-05:00, kai@tp1.ruhr-uni-bochum.de
  NET: Do not use dev->hard_header_len in eth_type_trans()
  
  eth_type_trans() currently pulls dev->hard_header_len off a frame
  passed to it, however always interpreting it as a ethernet header.
  
  Grepping shows that it is only used on net devices where
  dev->hard_header_len == ETH_HLEN. It makes more sense to actually
  pull of ETH_HLEN for the header (it's treated as a struct of the length
  anyway), not changing the behavior for the existing users but allowing
  two places which had to use their private copies of eth_trans_type to
  use the generic routine now.
  
  One place is in drivers/net/hamachi.c and converted in this cset, the other
  one is in the ISDN network code, patch will follow.

  ---------------------------------------------------------------------------

diff -Nru a/drivers/net/hamachi.c b/drivers/net/hamachi.c
--- a/drivers/net/hamachi.c	Sun Sep 29 13:10:36 2002
+++ b/drivers/net/hamachi.c	Sun Sep 29 13:10:36 2002
@@ -1460,64 +1460,6 @@
 	spin_unlock(&hmp->lock);
 }
 
-#ifdef TX_CHECKSUM
-/*
- * Copied from eth_type_trans(), with reduced header, since we don't
- * get it on RX, only on TX.
- */
-static unsigned short hamachi_eth_type_trans(struct sk_buff *skb,
-  struct net_device *dev)
-{
-	struct ethhdr *eth;
-	unsigned char *rawp;
-	
-	skb->mac.raw=skb->data;
-	skb_pull(skb,dev->hard_header_len-8);  /* artificially enlarged on tx */
-	eth= skb->mac.ethernet;
-	
-	if(*eth->h_dest&1)
-	{
-		if(memcmp(eth->h_dest,dev->broadcast, ETH_ALEN)==0)
-			skb->pkt_type=PACKET_BROADCAST;
-		else
-			skb->pkt_type=PACKET_MULTICAST;
-	}
-	
-	/*
-	 *	This ALLMULTI check should be redundant by 1.4
-	 *	so don't forget to remove it.
-	 *
-	 *	Seems, you forgot to remove it. All silly devices
-	 *	seems to set IFF_PROMISC.
-	 */
-	 
-	else if(dev->flags&(IFF_PROMISC/*|IFF_ALLMULTI*/))
-	{
-		if(memcmp(eth->h_dest,dev->dev_addr, ETH_ALEN))
-			skb->pkt_type=PACKET_OTHERHOST;
-	}
-	
-	if (ntohs(eth->h_proto) >= 1536)
-		return eth->h_proto;
-		
-	rawp = skb->data;
-	
-	/*
-	 *	This is a magic hack to spot IPX packets. Older Novell breaks
-	 *	the protocol design and runs IPX over 802.3 without an 802.2 LLC
-	 *	layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
-	 *	won't work for fault tolerant netware but does for the rest.
-	 */
-	if (*(unsigned short *)rawp == 0xFFFF)
-		return htons(ETH_P_802_3);
-		
-	/*
-	 *	Real 802.2 LLC
-	 */
-	return htons(ETH_P_802_2);
-}
-#endif  /* TX_CHECKSUM */
-
 /* This routine is logically part of the interrupt handler, but seperated
    for clarity and better register allocation. */
 static int hamachi_rx(struct net_device *dev)
@@ -1622,12 +1564,7 @@
 				skb_put(skb = hmp->rx_skbuff[entry], pkt_len);
 				hmp->rx_skbuff[entry] = NULL;
 			}
-#ifdef TX_CHECKSUM
-			/* account for extra TX hard_header bytes */
-			skb->protocol = hamachi_eth_type_trans(skb, dev);
-#else
 			skb->protocol = eth_type_trans(skb, dev);
-#endif
 
 
 #ifdef RX_CHECKSUM
diff -Nru a/net/ethernet/eth.c b/net/ethernet/eth.c
--- a/net/ethernet/eth.c	Sun Sep 29 13:10:36 2002
+++ b/net/ethernet/eth.c	Sun Sep 29 13:10:36 2002
@@ -161,7 +161,7 @@
 	unsigned char *rawp;
 	
 	skb->mac.raw=skb->data;
-	skb_pull(skb,dev->hard_header_len);
+	skb_pull(skb,ETH_HLEN);
 	eth= skb->mac.ethernet;
 	
 	if(*eth->h_dest&1)
