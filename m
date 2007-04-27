From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Generic HDLC sparse annotations
Date: Fri, 27 Apr 2007 13:13:33 +0200
Message-ID: <m3ps5qqdcy.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38810 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753530AbXD0LiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 07:38:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sparse annotations, including two minor bugfixes.

Signed-off-by: Krzysztof Halasa <khc@pm.waw.pl>

diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index c9664fd..a7a12d6 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -37,16 +37,16 @@
 struct hdlc_header {
 	u8 address;
 	u8 control;
-	u16 protocol;
+	__be16 protocol;
 }__attribute__ ((packed));
 
 
 struct cisco_packet {
-	u32 type;		/* code */
-	u32 par1;
-	u32 par2;
-	u16 rel;		/* reliability */
-	u32 time;
+	__be32 type;		/* code */
+	__be32 par1;
+	__be32 par2;
+	__be16 rel;		/* reliability */
+	__be32 time;
 }__attribute__ ((packed));
 #define	CISCO_PACKET_LEN	18
 #define	CISCO_BIG_PACKET_LEN	20
@@ -97,7 +97,7 @@ static int cisco_hard_header(struct sk_buff *skb, struct net_device *dev,
 
 
 static void cisco_keepalive_send(struct net_device *dev, u32 type,
-				 u32 par1, u32 par2)
+				 __be32 par1, __be32 par2)
 {
 	struct sk_buff *skb;
 	struct cisco_packet *data;
@@ -115,9 +115,9 @@ static void cisco_keepalive_send(struct net_device *dev, u32 type,
 	data = (struct cisco_packet*)(skb->data + 4);
 
 	data->type = htonl(type);
-	data->par1 = htonl(par1);
-	data->par2 = htonl(par2);
-	data->rel = 0xFFFF;
+	data->par1 = par1;
+	data->par2 = par2;
+	data->rel = __constant_htons(0xFFFF);
 	/* we will need do_div here if 1000 % HZ != 0 */
 	data->time = htonl((jiffies - INITIAL_JIFFIES) * (1000 / HZ));
 
@@ -193,7 +193,7 @@ static int cisco_rx(struct sk_buff *skb)
 		case CISCO_ADDR_REQ: /* Stolen from syncppp.c :-) */
 			in_dev = dev->ip_ptr;
 			addr = 0;
-			mask = ~0; /* is the mask correct? */
+			mask = __constant_htonl(~0); /* is the mask correct? */
 
 			if (in_dev != NULL) {
 				struct in_ifaddr **ifap = &in_dev->ifa_list;
@@ -245,7 +245,7 @@ static int cisco_rx(struct sk_buff *skb)
 	} /* switch(protocol) */
 
 	printk(KERN_INFO "%s: Unsupported protocol %x\n", dev->name,
-	       data->protocol);
+	       ntohs(data->protocol));
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 
@@ -270,8 +270,9 @@ static void cisco_timer(unsigned long arg)
 		netif_dormant_on(dev);
 	}
 
-	cisco_keepalive_send(dev, CISCO_KEEPALIVE_REQ, ++state(hdlc)->txseq,
-			     state(hdlc)->rxseq);
+	cisco_keepalive_send(dev, CISCO_KEEPALIVE_REQ,
+			     htonl(++state(hdlc)->txseq),
+			     htonl(state(hdlc)->rxseq));
 	state(hdlc)->request_sent = 1;
 	state(hdlc)->timer.expires = jiffies +
 		state(hdlc)->settings.interval * HZ;
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index c6c3c75..24fe2d3 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -288,31 +288,31 @@ static int fr_hard_header(struct sk_buff **skb_p, u16 dlci)
 	struct sk_buff *skb = *skb_p;
 
 	switch (skb->protocol) {
-	case __constant_ntohs(NLPID_CCITT_ANSI_LMI):
+	case __constant_htons(NLPID_CCITT_ANSI_LMI):
 		head_len = 4;
 		skb_push(skb, head_len);
 		skb->data[3] = NLPID_CCITT_ANSI_LMI;
 		break;
 
-	case __constant_ntohs(NLPID_CISCO_LMI):
+	case __constant_htons(NLPID_CISCO_LMI):
 		head_len = 4;
 		skb_push(skb, head_len);
 		skb->data[3] = NLPID_CISCO_LMI;
 		break;
 
-	case __constant_ntohs(ETH_P_IP):
+	case __constant_htons(ETH_P_IP):
 		head_len = 4;
 		skb_push(skb, head_len);
 		skb->data[3] = NLPID_IP;
 		break;
 
-	case __constant_ntohs(ETH_P_IPV6):
+	case __constant_htons(ETH_P_IPV6):
 		head_len = 4;
 		skb_push(skb, head_len);
 		skb->data[3] = NLPID_IPV6;
 		break;
 
-	case __constant_ntohs(ETH_P_802_3):
+	case __constant_htons(ETH_P_802_3):
 		head_len = 10;
 		if (skb_headroom(skb) < head_len) {
 			struct sk_buff *skb2 = skb_realloc_headroom(skb,
@@ -340,7 +340,7 @@ static int fr_hard_header(struct sk_buff **skb_p, u16 dlci)
 		skb->data[5] = FR_PAD;
 		skb->data[6] = FR_PAD;
 		skb->data[7] = FR_PAD;
-		*(u16*)(skb->data + 8) = skb->protocol;
+		*(__be16*)(skb->data + 8) = skb->protocol;
 	}
 
 	dlci_to_q922(skb->data, dlci);
@@ -974,8 +974,8 @@ static int fr_rx(struct sk_buff *skb)
 
 	} else if (skb->len > 10 && data[3] == FR_PAD &&
 		   data[4] == NLPID_SNAP && data[5] == FR_PAD) {
-		u16 oui = ntohs(*(u16*)(data + 6));
-		u16 pid = ntohs(*(u16*)(data + 8));
+		u16 oui = ntohs(*(__be16*)(data + 6));
+		u16 pid = ntohs(*(__be16*)(data + 8));
 		skb_pull(skb, 10);
 
 		switch ((((u32)oui) << 16) | pid) {
@@ -1128,7 +1128,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 		memcpy(dev->dev_addr, "\x00\x01", 2);
                 get_random_bytes(dev->dev_addr + 2, ETH_ALEN - 2);
 	} else {
-		*(u16*)dev->dev_addr = htons(dlci);
+		*(__be16*)dev->dev_addr = htons(dlci);
 		dlci_to_q922(dev->broadcast, dlci);
 	}
 	dev->hard_start_xmit = pvc_xmit;
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index d4b3339..5cd7b5a 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -43,8 +43,7 @@ struct hdlc_proto {
 	void (*stop)(struct net_device *dev); /* if open & !DCD */
 	void (*detach)(struct net_device *dev);
 	int (*ioctl)(struct net_device *dev, struct ifreq *ifr);
-	unsigned short (*type_trans)(struct sk_buff *skb,
-				     struct net_device *dev);
+	__be16 (*type_trans)(struct sk_buff *skb, struct net_device *dev);
 	struct module *module;
 	struct hdlc_proto *next; /* next protocol in the list */
 };
