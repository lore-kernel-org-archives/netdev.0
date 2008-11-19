From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] isdn: isdn_net.c annotate struct ip_ports and trivial
 sparse fixes
Date: Wed, 19 Nov 2008 09:21:52 -0800
Message-ID: <1227115312.13182.14.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>, Karsten Keil <kkeil@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:48460 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292AbYKSRV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 12:21:57 -0500
Received: by rn-out-0910.google.com with SMTP id k40so63355rnd.17
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 09:21:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, this is the last of the isdn sparse bits I have, resent now that
net-next/net/mainline have been merged up.

 drivers/isdn/i4l/isdn_net.c |   14 +++++++-------
 drivers/isdn/i4l/isdn_ppp.c |   12 ++++++------
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index ad17a47..4da81c1 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -865,8 +865,8 @@ isdn_net_hangup(struct net_device *d)
 }
 
 typedef struct {
-	unsigned short source;
-	unsigned short dest;
+	__be16 source;
+	__be16 dest;
 } ip_ports;
 
 static void
@@ -1355,7 +1355,7 @@ isdn_net_get_stats(struct net_device *dev)
  *      This is normal practice and works for any 'now in use' protocol.
  */
 
-static unsigned short
+static __be16
 isdn_net_type_trans(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ethhdr *eth;
@@ -1817,7 +1817,7 @@ isdn_net_receive(struct net_device *ndev, struct sk_buff *skb)
 			/* IP with type field */
 			olp->huptimer = 0;
 			lp->huptimer = 0;
-			skb->protocol = *(unsigned short *) &(skb->data[0]);
+			skb->protocol = *(__be16 *)&(skb->data[0]);
 			skb_pull(skb, 2);
 			if (*(unsigned short *) skb->data == 0xFFFF)
 				skb->protocol = htons(ETH_P_802_3);
@@ -1899,12 +1899,12 @@ static int isdn_net_header(struct sk_buff *skb, struct net_device *dev,
 			break;
 		case ISDN_NET_ENCAP_IPTYP:
 			/* ethernet type field */
-			*((ushort *) skb_push(skb, 2)) = htons(type);
+			*((__be16 *)skb_push(skb, 2)) = htons(type);
 			len = 2;
 			break;
 		case ISDN_NET_ENCAP_UIHDLC:
 			/* HDLC with UI-Frames (for ispa with -h1 option) */
-			*((ushort *) skb_push(skb, 2)) = htons(0x0103);
+			*((__be16 *)skb_push(skb, 2)) = htons(0x0103);
 			len = 2;
 			break;
 		case ISDN_NET_ENCAP_CISCOHDLC:
@@ -1978,7 +1978,7 @@ static void isdn_header_cache_update(struct hh_cache *hh,
 {
 	isdn_net_local *lp = dev->priv;
 	if (lp->p_encap == ISDN_NET_ENCAP_ETHER)
-		return eth_header_cache_update(hh, dev, haddr);
+		eth_header_cache_update(hh, dev, haddr);
 }
 
 static const struct header_ops isdn_header_ops = {
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 77c280e..bf5821e 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -1289,10 +1289,10 @@ isdn_ppp_xmit(struct sk_buff *skb, struct net_device *netdev)
 	*skb_push(skb, 4) = 1; /* indicate outbound */
 
 	{
-		u_int16_t *p = (u_int16_t *) skb->data;
+		__be16 *p = (__be16 *)skb->data;
 
 		p++;
-		*p   = htons(proto);
+		*p = htons(proto);
 	}
 
 	if (ipt->pass_filter
@@ -1487,10 +1487,10 @@ int isdn_ppp_autodial_filter(struct sk_buff *skb, isdn_net_local *lp)
 	*skb_pull(skb, IPPP_MAX_HEADER - 4) = 1; /* indicate outbound */
 
 	{
-		u_int16_t *p = (u_int16_t *) skb->data;
+		__be16 *p = (__be16 *)skb->data;
 
 		p++;
-		*p   = htons(proto);
+		*p = htons(proto);
 	}
 	
 	drop |= is->pass_filter
@@ -1810,14 +1810,14 @@ static u32 isdn_ppp_mp_get_seq( int short_seq,
    
    	if( !short_seq )
 	{
-		seq = ntohl(*(u32*)skb->data) & MP_LONGSEQ_MASK;
+		seq = ntohl(*(__be32 *)skb->data) & MP_LONGSEQ_MASK;
 		skb_push(skb,1);
 	}
 	else
 	{
 		/* convert 12-bit short seq number to 24-bit long one 
 	 	*/
-		seq = ntohs(*(u16*)skb->data) & MP_SHORTSEQ_MASK;
+		seq = ntohs(*(__be16 *)skb->data) & MP_SHORTSEQ_MASK;
 	
 		/* check for seqence wrap */
 		if( !(seq &  MP_SHORTSEQ_MAXBIT) && 
-- 
1.6.0.4.1013.gc6a01



