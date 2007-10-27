From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 4/5][ATM]: [br2864] routed support
Date: Sat, 27 Oct 2007 08:43:08 -0400
Message-ID: <200710271243.l9RCh8G6002908@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:51170 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328AbXJ0NXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 09:23:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit fea6b121bcc150fc91186e5012466c91944ce64d
Author: Eric Kinzie <ekinzie@cmf.nrl.navy.mil>
Date:   Fri Oct 26 08:05:08 2007 -0400

    [ATM]: [br2864] routed support
    
    From: Eric Kinzie <ekinzie@cmf.nrl.navy.mil>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/include/linux/atmbr2684.h b/include/linux/atmbr2684.h
index 969fb6c..ccdab6c 100644
--- a/include/linux/atmbr2684.h
+++ b/include/linux/atmbr2684.h
@@ -14,6 +14,9 @@
 #define BR2684_MEDIA_FDDI	(3)
 #define BR2684_MEDIA_802_6	(4)	/* 802.6 */
 
+					/* used only at device creation:  */
+#define BR2684_FLAG_ROUTED	(1<<16) /* payload is routed, not bridged */
+
 /*
  * Is there FCS inbound on this VC?  This currently isn't supported.
  */
@@ -36,13 +39,21 @@
 #define BR2684_ENCAPS_AUTODETECT (2)	/* Unsuported */
 
 /*
+ * Is this VC bridged or routed?
+ */
+
+#define BR2684_PAYLOAD_ROUTED   (0)
+#define BR2684_PAYLOAD_BRIDGED  (1)
+
+
+/*
  * This is for the ATM_NEWBACKENDIF call - these are like socket families:
  * the first element of the structure is the backend number and the rest
  * is per-backend specific
  */
 struct atm_newif_br2684 {
 	atm_backend_t	backend_num;	/* ATM_BACKEND_BR2684 */
-	int		media;		/* BR2684_MEDIA_* */
+	int		media;		/* BR2684_MEDIA_*, flags in upper bits */
 	char		ifname[IFNAMSIZ];
 	int		mtu;
 };
@@ -95,6 +106,11 @@ struct br2684_filter_set {
 	struct br2684_filter filter;
 };
 
+enum br2684_payload {
+        p_routed = BR2684_PAYLOAD_ROUTED,
+        p_bridged = BR2684_PAYLOAD_BRIDGED,
+};
+
 #define BR2684_SETFILT	_IOW( 'a', ATMIOC_BACKEND + 0, \
 				struct br2684_filter_set)
 
diff --git a/include/linux/atmdev.h b/include/linux/atmdev.h
index 2096e5c..a3d07c2 100644
--- a/include/linux/atmdev.h
+++ b/include/linux/atmdev.h
@@ -359,7 +359,7 @@ struct atm_dev {
 	struct proc_dir_entry *proc_entry; /* proc entry */
 	char *proc_name;		/* proc entry name */
 #endif
-	struct class_device class_dev;	/* sysfs class device */
+	struct device class_dev;	/* sysfs device */
 	struct list_head dev_list;	/* linkage */
 };
 
@@ -461,7 +461,7 @@ static inline void atm_dev_put(struct atm_dev *dev)
 		BUG_ON(!test_bit(ATM_DF_REMOVED, &dev->flags));
 		if (dev->ops->dev_close)
 			dev->ops->dev_close(dev);
-		class_device_put(&dev->class_dev);
+		put_device(&dev->class_dev);
 	}
 }
 
diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index ba6428f..d9bb2a1 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -1,7 +1,8 @@
 /*
-Experimental ethernet netdevice using ATM AAL5 as underlying carrier
-(RFC1483 obsoleted by RFC2684) for Linux 2.4
-Author: Marcell GAL, 2000, XDSL Ltd, Hungary
+Ethernet netdevice using ATM AAL5 as underlying carrier
+(RFC1483 obsoleted by RFC2684) for Linux
+Authors: Marcell GAL, 2000, XDSL Ltd, Hungary
+         Eric Kinzie, 2006-2007, US Naval Research Laboratory
 */
 
 #include <linux/module.h>
@@ -39,9 +40,27 @@ static void skb_debug(const struct sk_buff *skb)
 #define skb_debug(skb)	do {} while (0)
 #endif
 
+#define BR2684_ETHERTYPE_LEN	2
+#define BR2684_PAD_LEN		2
+
+#define LLC		0xaa, 0xaa, 0x03
+#define SNAP_BRIDGED	0x00, 0x80, 0xc2
+#define SNAP_ROUTED	0x00, 0x00, 0x00
+#define PID_ETHERNET	0x00, 0x07
+#define ETHERTYPE_IPV4	0x08, 0x00
+#define ETHERTYPE_IPV6	0x86, 0xdd
+#define PAD_BRIDGED	0x00, 0x00
+
+static unsigned char ethertype_ipv4[] =
+	{ ETHERTYPE_IPV4 };
+static unsigned char ethertype_ipv6[] =
+	{ ETHERTYPE_IPV6 };
 static unsigned char llc_oui_pid_pad[] =
-    { 0xAA, 0xAA, 0x03, 0x00, 0x80, 0xC2, 0x00, 0x07, 0x00, 0x00 };
-#define PADLEN	(2)
+	{ LLC, SNAP_BRIDGED, PID_ETHERNET, PAD_BRIDGED };
+static unsigned char llc_oui_ipv4[] =
+	{ LLC, SNAP_ROUTED, ETHERTYPE_IPV4 };
+static unsigned char llc_oui_ipv6[] =
+	{ LLC, SNAP_ROUTED, ETHERTYPE_IPV6 };
 
 enum br2684_encaps {
 	e_vc  = BR2684_ENCAPS_VC,
@@ -69,6 +88,7 @@ struct br2684_dev {
 	struct list_head brvccs; /* one device <=> one vcc (before xmas) */
 	struct net_device_stats stats;
 	int mac_was_set;
+	enum br2684_payload payload;
 };
 
 /*
@@ -136,6 +156,7 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
 {
 	struct atm_vcc *atmvcc;
 	int minheadroom = (brvcc->encaps == e_llc) ? 10 : 2;
+
 	if (skb_headroom(skb) < minheadroom) {
 		struct sk_buff *skb2 = skb_realloc_headroom(skb, minheadroom);
 		brvcc->copies_needed++;
@@ -146,11 +167,32 @@ static int br2684_xmit_vcc(struct sk_buff *skb, struct br2684_dev *brdev,
 		}
 		skb = skb2;
 	}
-	skb_push(skb, minheadroom);
-	if (brvcc->encaps == e_llc)
-		skb_copy_to_linear_data(skb, llc_oui_pid_pad, 10);
-	else
-		memset(skb->data, 0, 2);
+
+	if (brvcc->encaps == e_llc) {
+		if (brdev->payload == p_bridged) {
+			skb_push(skb, sizeof(llc_oui_pid_pad));
+			skb_copy_to_linear_data(skb, llc_oui_pid_pad, sizeof(llc_oui_pid_pad));
+		} else if (brdev->payload == p_routed) {
+			unsigned short prot = ntohs(skb->protocol);
+
+			skb_push(skb, sizeof(llc_oui_ipv4));
+			switch (prot) {
+				case ETH_P_IP:
+					skb_copy_to_linear_data(skb, llc_oui_ipv4, sizeof(llc_oui_ipv4));
+					break;
+				case ETH_P_IPV6:
+					skb_copy_to_linear_data(skb, llc_oui_ipv6, sizeof(llc_oui_ipv6));
+					break;
+				default:
+					dev_kfree_skb(skb);
+					return 0;
+			}
+		}
+	} else {
+		skb_push(skb, 2);
+		if (brdev->payload == p_bridged)
+			memset(skb->data, 0, 2);
+	}
 	skb_debug(skb);
 
 	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
@@ -299,7 +341,6 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 	struct br2684_vcc *brvcc = BR2684_VCC(atmvcc);
 	struct net_device *net_dev = brvcc->device;
 	struct br2684_dev *brdev = BRPRIV(net_dev);
-	int plen = sizeof(llc_oui_pid_pad) + ETH_HLEN;
 
 	pr_debug("br2684_push\n");
 
@@ -320,35 +361,50 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 	atm_return(atmvcc, skb->truesize);
 	pr_debug("skb from brdev %p\n", brdev);
 	if (brvcc->encaps == e_llc) {
+
+		if (skb->len > 7 && skb->data[7] == 0x01)
+			__skb_trim(skb, skb->len - 4);
+
+		/* accept packets that have "ipv[46]" in the snap header */
+		if ((skb->len >= (sizeof(llc_oui_ipv4)))
+		    && (memcmp(skb->data, llc_oui_ipv4, sizeof(llc_oui_ipv4) - BR2684_ETHERTYPE_LEN) == 0)) {
+			if (memcmp(skb->data + 6, ethertype_ipv6, sizeof(ethertype_ipv6)) == 0)
+				skb->protocol = __constant_htons(ETH_P_IPV6);
+			else if (memcmp(skb->data + 6, ethertype_ipv4, sizeof(ethertype_ipv4)) == 0)
+				skb->protocol = __constant_htons(ETH_P_IP);
+			else {
+				brdev->stats.rx_errors++;
+				dev_kfree_skb(skb);
+				return;
+			}
+			skb_pull(skb, sizeof(llc_oui_ipv4));
+			skb_reset_network_header(skb);
+			skb->pkt_type = PACKET_HOST;
+
 		/* let us waste some time for checking the encapsulation.
 		   Note, that only 7 char is checked so frames with a valid FCS
 		   are also accepted (but FCS is not checked of course) */
-		if (memcmp(skb->data, llc_oui_pid_pad, 7)) {
+		} else if ((skb->len >= sizeof(llc_oui_pid_pad)) &&
+		           (memcmp(skb->data, llc_oui_pid_pad, 7) == 0)) {
+			skb_pull(skb, sizeof(llc_oui_pid_pad));
+			skb->protocol = eth_type_trans(skb, net_dev);
+		} else {
 			brdev->stats.rx_errors++;
 			dev_kfree_skb(skb);
 			return;
 		}
 
-		/* Strip FCS if present */
-		if (skb->len > 7 && skb->data[7] == 0x01)
-			__skb_trim(skb, skb->len - 4);
 	} else {
-		plen = PADLEN + ETH_HLEN;	/* pad, dstmac,srcmac, ethtype */
 		/* first 2 chars should be 0 */
 		if (*((u16 *) (skb->data)) != 0) {
 			brdev->stats.rx_errors++;
 			dev_kfree_skb(skb);
 			return;
 		}
-	}
-	if (skb->len < plen) {
-		brdev->stats.rx_errors++;
-		dev_kfree_skb(skb);	/* dev_ not needed? */
-		return;
+		skb_pull(skb, BR2684_PAD_LEN + ETH_HLEN); /* pad, dstmac, srcmac, ethtype */
+		skb->protocol = eth_type_trans(skb, net_dev);
 	}
 
-	skb_pull(skb, plen - ETH_HLEN);
-	skb->protocol = eth_type_trans(skb, net_dev);
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 	if (unlikely(packet_fails_filter(skb->protocol, brvcc, skb))) {
 		brdev->stats.rx_dropped++;
@@ -482,25 +538,52 @@ static void br2684_setup(struct net_device *netdev)
 	INIT_LIST_HEAD(&brdev->brvccs);
 }
 
+static void br2684_setup_routed(struct net_device *netdev)
+{
+	struct br2684_dev *brdev = BRPRIV(netdev);
+	brdev->net_dev = netdev;
+
+	netdev->hard_header_len = 0;
+	my_eth_mac_addr = netdev->set_mac_address;
+	netdev->set_mac_address = br2684_mac_addr;
+	netdev->hard_start_xmit = br2684_start_xmit;
+	netdev->get_stats = br2684_get_stats;
+	netdev->addr_len = 0;
+	netdev->mtu = 1500;
+	netdev->type = ARPHRD_PPP;
+	netdev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
+	netdev->tx_queue_len = 100;
+	INIT_LIST_HEAD(&brdev->brvccs);
+}
+
 static int br2684_create(void __user *arg)
 {
 	int err;
 	struct net_device *netdev;
 	struct br2684_dev *brdev;
 	struct atm_newif_br2684 ni;
+	enum br2684_payload payload;
 
 	pr_debug("br2684_create\n");
 
 	if (copy_from_user(&ni, arg, sizeof ni)) {
 		return -EFAULT;
 	}
+
+	if (ni.media & BR2684_FLAG_ROUTED)
+		payload = p_routed;
+	else
+		payload = p_bridged;
+	ni.media &= 0xffff; /* strip flags */
+
 	if (ni.media != BR2684_MEDIA_ETHERNET || ni.mtu != 1500) {
 		return -EINVAL;
 	}
 
 	netdev = alloc_netdev(sizeof(struct br2684_dev),
 			      ni.ifname[0] ? ni.ifname : "nas%d",
-			      br2684_setup);
+			      (payload == p_routed) ?
+			       br2684_setup_routed : br2684_setup);
 	if (!netdev)
 		return -ENOMEM;
 
@@ -516,6 +599,7 @@ static int br2684_create(void __user *arg)
 	}
 
 	write_lock_irq(&devs_lock);
+	brdev->payload = payload;
 	brdev->number = list_empty(&br2684_devs) ? 1 :
 	    BRPRIV(list_entry_brdev(br2684_devs.prev))->number + 1;
 	list_add_tail(&brdev->br2684_devs, &br2684_devs);
@@ -601,14 +685,14 @@ static int br2684_seq_show(struct seq_file *seq, void *v)
 		   brdev->mac_was_set ? "set" : "auto");
 
 	list_for_each_entry(brvcc, &brdev->brvccs, brvccs) {
-		seq_printf(seq, "  vcc %d.%d.%d: encaps=%s"
-				    ", failed copies %u/%u"
-				    "\n", brvcc->atmvcc->dev->number,
-				    brvcc->atmvcc->vpi, brvcc->atmvcc->vci,
-				    (brvcc->encaps == e_llc) ? "LLC" : "VC"
-				    , brvcc->copies_failed
-				    , brvcc->copies_needed
-				    );
+		seq_printf(seq, "  vcc %d.%d.%d: encaps=%s payload=%s"
+			        ", failed copies %u/%u"
+			        "\n", brvcc->atmvcc->dev->number,
+				      brvcc->atmvcc->vpi, brvcc->atmvcc->vci,
+				      (brvcc->encaps == e_llc) ? "LLC" : "VC",
+				      (brdev->payload == p_bridged) ? "bridged" : "routed",
+				      brvcc->copies_failed,
+				      brvcc->copies_needed);
 #ifdef CONFIG_ATM_BR2684_IPFILTER
 #define b1(var, byte)	((u8 *) &brvcc->filter.var)[byte]
 #define bs(var)		b1(var, 0), b1(var, 1), b1(var, 2), b1(var, 3)
