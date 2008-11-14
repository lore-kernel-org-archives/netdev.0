From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] isdn: use %pI4, remove get_{u8/u16/u32} and
 put_{u8/u16/u32} inlines
Date: Thu, 13 Nov 2008 21:17:25 -0800
Message-ID: <1226639846.5483.3.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>, Karsten Keil <kkeil@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:20007 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbYKNFRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 00:17:30 -0500
Received: by wf-out-1314.google.com with SMTP id 27so1254188wfd.4
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2008 21:17:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They would have been better named as get_be16, put_be16, etc.
as they were hiding an endian shift inside.

They don't add much over explicitly coding the byteshifting
and gcc sometimes has a problem with builtin_constant_p inside
inline functions, so it may do a better job of byteswapping
at compile time rather than runtime.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, this started as a trivial use %pI4 patch, but I took a quick
look at the sparse warnings for this file and saw all the ones from
isdn_net.h and they were only a handlfull of users of the inlines,
so I zapped them as well, let me know if you want a split patch, but
I didn't think it was worth it.

 drivers/isdn/i4l/isdn_net.c |   91 ++++++++++++++++++++++---------------------
 drivers/isdn/i4l/isdn_net.h |   43 --------------------
 2 files changed, 46 insertions(+), 88 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 60c82d7..8fff0bd 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -890,15 +890,15 @@ isdn_net_log_skb(struct sk_buff * skb, isdn_net_local * lp)
 		proto = ETH_P_IP;
 		switch (lp->p_encap) {
 			case ISDN_NET_ENCAP_IPTYP:
-				proto = ntohs(*(unsigned short *) &buf[0]);
+				proto = ntohs(*(__be16 *)&buf[0]);
 				p = &buf[2];
 				break;
 			case ISDN_NET_ENCAP_ETHER:
-				proto = ntohs(*(unsigned short *) &buf[12]);
+				proto = ntohs(*(__be16 *)&buf[12]);
 				p = &buf[14];
 				break;
 			case ISDN_NET_ENCAP_CISCOHDLC:
-				proto = ntohs(*(unsigned short *) &buf[2]);
+				proto = ntohs(*(__be16 *)&buf[2]);
 				p = &buf[4];
 				break;
 #ifdef CONFIG_ISDN_PPP
@@ -942,18 +942,12 @@ isdn_net_log_skb(struct sk_buff * skb, isdn_net_local * lp)
 					strcpy(addinfo, " IDP");
 					break;
 			}
-			printk(KERN_INFO
-				"OPEN: %d.%d.%d.%d -> %d.%d.%d.%d%s\n",
-
-			       p[12], p[13], p[14], p[15],
-			       p[16], p[17], p[18], p[19],
-			       addinfo);
+			printk(KERN_INFO "OPEN: %pI4 -> %pI4%s\n",
+			       p + 12, p + 16, addinfo);
 			break;
 		case ETH_P_ARP:
-			printk(KERN_INFO
-				"OPEN: ARP %d.%d.%d.%d -> *.*.*.* ?%d.%d.%d.%d\n",
-			       p[14], p[15], p[16], p[17],
-			       p[24], p[25], p[26], p[27]);
+			printk(KERN_INFO "OPEN: ARP %pI4 -> *.*.*.* ?%pI4\n",
+			       p + 14, p + 24);
 			break;
 	}
 }
@@ -1539,15 +1533,16 @@ isdn_net_ciscohdlck_slarp_send_keepalive(unsigned long data)
 	p = skb_put(skb, 4 + 14);
 
 	/* cisco header */
-	p += put_u8 (p, CISCO_ADDR_UNICAST);
-	p += put_u8 (p, CISCO_CTRL);
-	p += put_u16(p, CISCO_TYPE_SLARP);
+	*(u8 *)(p + 0) = CISCO_ADDR_UNICAST;
+	*(u8 *)(p + 1) = CISCO_CTRL;
+	*(__be16 *)(p + 2) = cpu_to_be16(CISCO_TYPE_SLARP);
 
 	/* slarp keepalive */
-	p += put_u32(p, CISCO_SLARP_KEEPALIVE);
-	p += put_u32(p, lp->cisco_myseq);
-	p += put_u32(p, lp->cisco_yourseq);
-	p += put_u16(p, 0xffff); // reliablity, always 0xffff
+	*(__be32 *)(p +  4) = cpu_to_be32(CISCO_SLARP_KEEPALIVE);
+	*(__be32 *)(p +  8) = cpu_to_be32(lp->cisco_myseq);
+	*(__be32 *)(p + 12) = cpu_to_be32(lp->cisco_yourseq);
+	*(__be16 *)(p + 16) = cpu_to_be16(0xffff); // reliablity, always 0xffff
+	p += 18;
 
 	isdn_net_write_super(lp, skb);
 
@@ -1569,15 +1564,16 @@ isdn_net_ciscohdlck_slarp_send_request(isdn_net_local *lp)
 	p = skb_put(skb, 4 + 14);
 
 	/* cisco header */
-	p += put_u8 (p, CISCO_ADDR_UNICAST);
-	p += put_u8 (p, CISCO_CTRL);
-	p += put_u16(p, CISCO_TYPE_SLARP);
+	*(u8 *)(p + 0) = CISCO_ADDR_UNICAST;
+	*(u8 *)(p + 1) = CISCO_CTRL;
+	*(__be16 *)(p + 2) = cpu_to_be16(CISCO_TYPE_SLARP);
 
 	/* slarp request */
-	p += put_u32(p, CISCO_SLARP_REQUEST);
-	p += put_u32(p, 0); // address
-	p += put_u32(p, 0); // netmask
-	p += put_u16(p, 0); // unused
+	*(__be32 *)(p +  4) = cpu_to_be32(CISCO_SLARP_REQUEST);
+	*(__be32 *)(p +  8) = cpu_to_be32(0); // address
+	*(__be32 *)(p + 12) = cpu_to_be32(0); // netmask
+	*(__be16 *)(p + 16) = cpu_to_be16(0); // unused
+	p += 18;
 
 	isdn_net_write_super(lp, skb);
 }
@@ -1634,16 +1630,17 @@ isdn_net_ciscohdlck_slarp_send_reply(isdn_net_local *lp)
 	p = skb_put(skb, 4 + 14);
 
 	/* cisco header */
-	p += put_u8 (p, CISCO_ADDR_UNICAST);
-	p += put_u8 (p, CISCO_CTRL);
-	p += put_u16(p, CISCO_TYPE_SLARP);
+	*(u8 *)(p + 0) = CISCO_ADDR_UNICAST;
+	*(u8 *)(p + 1) = CISCO_CTRL;
+	*(__be16 *)(p + 2) = cpu_to_be16(CISCO_TYPE_SLARP);
 
 	/* slarp reply, send own ip/netmask; if values are nonsense remote
 	 * should think we are unable to provide it with an address via SLARP */
-	p += put_u32(p, CISCO_SLARP_REPLY);
-	p += put_u32(p, addr);	// address
-	p += put_u32(p, mask);	// netmask
-	p += put_u16(p, 0);	// unused
+	*(__be32 *)(p +  4) = cpu_to_be32(CISCO_SLARP_REPLY);
+	*(__be32 *)(p +  8) = cpu_to_be32(addr); // address
+	*(__be32 *)(p + 12) = cpu_to_be32(mask); // netmask
+	*(__be16 *)(p + 16) = cpu_to_be16(0); // unused
+	p += 18;
 
 	isdn_net_write_super(lp, skb);
 }
@@ -1664,8 +1661,9 @@ isdn_net_ciscohdlck_slarp_in(isdn_net_local *lp, struct sk_buff *skb)
 		return;
 
 	p = skb->data;
-	p += get_u32(p, &code);
-	
+	code = be32_to_cpup((__be32 *)p);
+	p += 4;
+
 	switch (code) {
 	case CISCO_SLARP_REQUEST:
 		lp->cisco_yourseq = 0;
@@ -1699,9 +1697,10 @@ isdn_net_ciscohdlck_slarp_in(isdn_net_local *lp, struct sk_buff *skb)
 				lp->cisco_keepalive_period);
 		}
 		lp->cisco_last_slarp_in = jiffies;
-		p += get_u32(p, &my_seq);
-		p += get_u32(p, &your_seq);
-		p += get_u16(p, &unused);
+		my_seq = be32_to_cpup((__be32 *)(p + 0));
+		your_seq = be32_to_cpup((__be32 *)(p + 4));
+		unused = be16_to_cpup((__be16 *)(p + 8));
+		p += 10;
 		lp->cisco_yourseq = my_seq;
 		lp->cisco_mineseen = your_seq;
 		break;
@@ -1720,9 +1719,10 @@ isdn_net_ciscohdlck_receive(isdn_net_local *lp, struct sk_buff *skb)
 		goto out_free;
 
 	p = skb->data;
-	p += get_u8 (p, &addr);
-	p += get_u8 (p, &ctrl);
-	p += get_u16(p, &type);
+	addr = *(u8 *)(p + 0);
+	ctrl = *(u8 *)(p + 1);
+	type = be16_to_cpup((__be16 *)(p + 2));
+	p += 4;
 	skb_pull(skb, 4);
 	
 	if (addr != CISCO_ADDR_UNICAST && addr != CISCO_ADDR_BROADCAST) {
@@ -1910,9 +1910,10 @@ static int isdn_net_header(struct sk_buff *skb, struct net_device *dev,
 		case ISDN_NET_ENCAP_CISCOHDLC:
 		case ISDN_NET_ENCAP_CISCOHDLCK:
 			p = skb_push(skb, 4);
-			p += put_u8 (p, CISCO_ADDR_UNICAST);
-			p += put_u8 (p, CISCO_CTRL);
-			p += put_u16(p, type);
+			*(u8 *)(p + 0) = CISCO_ADDR_UNICAST;
+			*(u8 *)(p + 1) = CISCO_CTRL;
+			*(__be16 *)(p + 2) = cpu_to_be16(type);
+			p += 4;
 			len = 4;
 			break;
 #ifdef CONFIG_ISDN_X25
diff --git a/drivers/isdn/i4l/isdn_net.h b/drivers/isdn/i4l/isdn_net.h
index be49497..2a6c370 100644
--- a/drivers/isdn/i4l/isdn_net.h
+++ b/drivers/isdn/i4l/isdn_net.h
@@ -145,46 +145,3 @@ static __inline__ void isdn_net_rm_from_bundle(isdn_net_local *lp)
 	spin_unlock_irqrestore(&master_lp->netdev->queue_lock, flags);
 }
 
-static inline int
-put_u8(unsigned char *p, u8 x)
-{
-	*p = x;
-	return 1;
-}
-
-static inline int
-put_u16(unsigned char *p, u16 x)
-{
-	*((u16 *)p) = htons(x);
-	return 2;
-}
-
-static inline int
-put_u32(unsigned char *p, u32 x)
-{
-	*((u32 *)p) = htonl(x);
-	return 4;
-}
-
-static inline int
-get_u8(unsigned char *p, u8 *x)
-{
-	*x = *p;
-	return 1;
-}
-
-static inline int
-get_u16(unsigned char *p, u16 *x)
-{
-	*x = ntohs(*((u16 *)p));
-	return 2;
-}
-
-static inline int
-get_u32(unsigned char *p, u32 *x)
-{
-	*x = ntohl(*((u32 *)p));
-	return 4;
-}
-
-
-- 
1.6.0.4.879.g9d19a



