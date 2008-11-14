From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] isdn: bugfix in isdn_net_ciscohdlck_slarp_send_reply,
 trivial sparse fixes
Date: Fri, 14 Nov 2008 09:33:49 -0800
Message-ID: <1226684029.5483.12.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Karsten Keil <kkeil@suse.de>,
	linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:14238 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbYKNRkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 12:40:24 -0500
Received: by wf-out-1314.google.com with SMTP id 27so1516863wfd.4
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 09:40:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a144ea4b7a13087081ab5402fa9ad0bcfd249e67 [IPV4]: annotate struct in_ifaddr

Missed the extra byteswap because the previous isdn inline helpers
hid the extra htonl inside put_u32.  This was causing an extra byteswap
on little-endian arches.

While here, do the trivial annotation of the struct ip_ports and change
the remaining casts to __be16 where applicable.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, the yesterday's patch was a zero-change patch that exposed this
bug, this patch changes behavior in the above-referenced function.

 drivers/isdn/i4l/isdn_net.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 8fff0bd..8e51bfb 100644
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
@@ -1637,8 +1637,8 @@ isdn_net_ciscohdlck_slarp_send_reply(isdn_net_local *lp)
 	/* slarp reply, send own ip/netmask; if values are nonsense remote
 	 * should think we are unable to provide it with an address via SLARP */
 	*(__be32 *)(p +  4) = cpu_to_be32(CISCO_SLARP_REPLY);
-	*(__be32 *)(p +  8) = cpu_to_be32(addr); // address
-	*(__be32 *)(p + 12) = cpu_to_be32(mask); // netmask
+	*(__be32 *)(p +  8) = addr; // address
+	*(__be32 *)(p + 12) = mask; // netmask
 	*(__be16 *)(p + 16) = cpu_to_be16(0); // unused
 	p += 18;
 
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
-- 
1.6.0.4.879.g9d19a



