From: Jiri Benc <jbenc@suse.cz>
Subject: [4/9] ieee80211: ieee80211_device alignment fix and cleanup
Date: Fri, 3 Jun 2005 18:31:49 +0200
Message-ID: <20050603183149.228ab747@griffin.suse.cz>
References: <20050603182625.64d33be3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
In-Reply-To: <20050603182625.64d33be3@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Changes to the ieee80211 layer:
- fixes a serious alignment problem of the driver's private data
- makes the drivers use the ieee80211_device instead of the net_device where
  appropriate (will ease further development of ieee80211 as a self-contained
  layer)


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

Index: netdev/include/net/ieee80211.h
===================================================================
--- netdev.orig/include/net/ieee80211.h	2005-06-01 11:05:06.000000000 +0200
+++ netdev/include/net/ieee80211.h	2005-06-03 13:20:46.000000000 +0200
@@ -704,15 +704,13 @@
 	int abg_ture;   /* ABG flag              */
 
 	/* Callback functions */
-	void (*set_security)(struct net_device *dev,
+	void (*set_security)(struct ieee80211_device *ieee,
 			     struct ieee80211_security *sec);
 	int (*hard_start_xmit)(struct ieee80211_txb *txb,
-			       struct net_device *dev);
-	int (*reset_port)(struct net_device *dev);
+			       struct ieee80211_device *ieee);
+	int (*reset_port)(struct ieee80211_device *ieee);
 
-	/* This must be the last item so that it points to the data
-	 * allocated beyond this structure by alloc_ieee80211 */
-	u8 priv[0];
+	void *priv;
 };
 
 #define IEEE_A            (1<<0)
@@ -720,9 +718,27 @@
 #define IEEE_G            (1<<2)
 #define IEEE_MODE_MASK    (IEEE_A|IEEE_B|IEEE_G)
 
-extern inline void *ieee80211_priv(struct net_device *dev)
+static inline void *ieee80211_priv(struct ieee80211_device *ieee)
 {
-	return ((struct ieee80211_device *)netdev_priv(dev))->priv;
+	 return (char *)ieee + 
+	 	((sizeof(struct ieee80211_device) + NETDEV_ALIGN_CONST)
+			& ~NETDEV_ALIGN_CONST);
+}
+
+static inline void *ieee80211_dev_to_priv(struct net_device *dev)
+{
+	return (char *)dev +
+		((sizeof(struct net_device) + NETDEV_ALIGN_CONST)
+			& ~NETDEV_ALIGN_CONST) +
+		((sizeof(struct ieee80211_device) + NETDEV_ALIGN_CONST)
+			& ~NETDEV_ALIGN_CONST);
+}
+
+static inline struct net_device *ieee80211_dev(struct ieee80211_device *ieee)
+{
+	 return (struct net_device *)((char *)ieee - 
+	 	((sizeof(struct net_device) + NETDEV_ALIGN_CONST)
+			& ~NETDEV_ALIGN_CONST));
 }
 
 extern inline int ieee80211_is_empty_essid(const char *essid, int essid_len)
@@ -795,8 +811,8 @@
 
 
 /* ieee80211.c */
-extern void free_ieee80211(struct net_device *dev);
-extern struct net_device *alloc_ieee80211(int sizeof_priv);
+extern void free_ieee80211(struct ieee80211_device *ieee);
+extern struct ieee80211_device *alloc_ieee80211(int sizeof_priv);
 
 extern int ieee80211_set_encryption(struct ieee80211_device *ieee);
 
Index: netdev/net/ieee80211/ieee80211_module.c
===================================================================
--- netdev.orig/net/ieee80211/ieee80211_module.c	2005-06-03 13:20:40.000000000 +0200
+++ netdev/net/ieee80211/ieee80211_module.c	2005-06-03 13:20:46.000000000 +0200
@@ -69,7 +69,7 @@
 		GFP_KERNEL);
 	if (!ieee->networks) {
 		printk(KERN_WARNING "%s: Out of memory allocating beacons\n",
-		       ieee->dev->name);
+		       ieee80211_dev(ieee)->name);
 		return -ENOMEM;
 	}
 
@@ -98,23 +98,28 @@
 }
 
 
-struct net_device *alloc_ieee80211(int sizeof_priv)
+struct ieee80211_device *alloc_ieee80211(int sizeof_priv)
 {
 	struct ieee80211_device *ieee;
 	struct net_device *dev;
+	int alloc_size;
 	int err;
 
 	IEEE80211_DEBUG_INFO("Initializing...\n");
 
-	dev = alloc_etherdev(sizeof(struct ieee80211_device) + sizeof_priv);
+	alloc_size = ((sizeof(struct ieee80211_device) + NETDEV_ALIGN_CONST) 
+			& ~NETDEV_ALIGN_CONST) 
+			+ sizeof_priv;
+	dev = alloc_etherdev(alloc_size);
 	if (!dev) {
 		IEEE80211_ERROR("Unable to network device.\n");
 		goto failed;
 	}
 	ieee = netdev_priv(dev);
-	dev->hard_start_xmit = ieee80211_xmit;
-
 	ieee->dev = dev;
+	ieee->priv = ieee80211_priv(ieee);
+	
+	dev->hard_start_xmit = ieee80211_xmit;
 
 	err = ieee80211_networks_allocate(ieee);
 	if (err) {
@@ -147,7 +152,7 @@
  	ieee->privacy_invoked = 0;
  	ieee->ieee802_1x = 1;
 
-	return dev;
+	return ieee;
 
  failed:
 	if (dev)
@@ -156,10 +161,8 @@
 }
 
 
-void free_ieee80211(struct net_device *dev)
+void free_ieee80211(struct ieee80211_device *ieee)
 {
-	struct ieee80211_device *ieee = netdev_priv(dev);
-
 	int i;
 
 	del_timer_sync(&ieee->crypt_deinit_timer);
@@ -178,7 +181,7 @@
 	}
 
 	ieee80211_networks_free(ieee);
-	free_netdev(dev);
+	free_netdev(ieee80211_dev(ieee));
 }
 
 #ifdef CONFIG_IEEE80211_DEBUG
Index: netdev/net/ieee80211/ieee80211_rx.c
===================================================================
--- netdev.orig/net/ieee80211/ieee80211_rx.c	2005-06-03 13:20:40.000000000 +0200
+++ netdev/net/ieee80211/ieee80211_rx.c	2005-06-03 13:20:46.000000000 +0200
@@ -99,7 +99,7 @@
 
 	if (frag == 0) {
 		/* Reserve enough space to fit maximum frame length */
-		skb = dev_alloc_skb(ieee->dev->mtu +
+		skb = dev_alloc_skb(ieee80211_dev(ieee)->mtu +
 				    sizeof(struct ieee80211_hdr) +
 				    8 /* LLC */ +
 				    2 /* alignment */ +
@@ -175,7 +175,7 @@
 {
 	if (ieee->iw_mode == IW_MODE_MASTER) {
 		printk(KERN_DEBUG "%s: Master mode not yet suppported.\n",
-		       ieee->dev->name);
+		       ieee80211_dev(ieee)->name);
 		return 0;
 /*
   hostap_update_sta_ps(ieee, (struct hostap_ieee80211_hdr *)
@@ -233,7 +233,7 @@
 static int ieee80211_is_eapol_frame(struct ieee80211_device *ieee,
 				    struct sk_buff *skb)
 {
-	struct net_device *dev = ieee->dev;
+	struct net_device *dev = ieee80211_dev(ieee);
 	u16 fc, ethertype;
 	struct ieee80211_hdr *hdr;
 	u8 *pos;
@@ -289,7 +289,7 @@
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
 			       "received packet from " MAC_FMT "\n",
-			       ieee->dev->name, MAC_ARG(hdr->addr2));
+			       ieee80211_dev(ieee)->name, MAC_ARG(hdr->addr2));
 		}
 		return -1;
 	}
@@ -334,7 +334,7 @@
 	if (res < 0) {
 		printk(KERN_DEBUG "%s: MSDU decryption/MIC verification failed"
 		       " (SA=" MAC_FMT " keyidx=%d)\n",
-		       ieee->dev->name, MAC_ARG(hdr->addr2), keyidx);
+		       ieee80211_dev(ieee)->name, MAC_ARG(hdr->addr2), keyidx);
 		return -1;
 	}
 
@@ -348,7 +348,7 @@
 int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 		 struct ieee80211_rx_stats *rx_stats)
 {
-	struct net_device *dev = ieee->dev;
+	struct net_device *dev = ieee80211_dev(ieee);
 	struct ieee80211_hdr *hdr;
 	size_t hdrlen;
 	u16 fc, type, stype, sc;
@@ -1194,7 +1194,7 @@
 		IEEE80211_DEBUG_MGMT("received UNKNOWN (%d)\n",
 				     WLAN_FC_GET_STYPE(header->frame_ctl));
 		IEEE80211_WARNING("%s: Unknown management packet: %d\n",
-				  ieee->dev->name,
+				  ieee80211_dev(ieee)->name,
 				  WLAN_FC_GET_STYPE(header->frame_ctl));
 		break;
 	}
Index: netdev/net/ieee80211/ieee80211_tx.c
===================================================================
--- netdev.orig/net/ieee80211/ieee80211_tx.c	2005-06-03 13:20:40.000000000 +0200
+++ netdev/net/ieee80211/ieee80211_tx.c	2005-06-03 13:20:46.000000000 +0200
@@ -171,7 +171,7 @@
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
 			       "TX packet to " MAC_FMT "\n",
-			       ieee->dev->name, MAC_ARG(header->addr1));
+			       ieee80211_dev(ieee)->name, MAC_ARG(header->addr1));
 		}
 		return -1;
 	}
@@ -192,7 +192,7 @@
 	atomic_dec(&crypt->refcnt);
 	if (res < 0) {
 		printk(KERN_INFO "%s: Encryption failed: len=%d.\n",
-		       ieee->dev->name, frag->len);
+		       ieee80211_dev(ieee)->name, frag->len);
 		ieee->ieee_stats.tx_discards++;
 		return -1;
 	}
@@ -269,13 +269,13 @@
 	 * creating it... */
 	if (!ieee->hard_start_xmit) {
 		printk(KERN_WARNING "%s: No xmit handler.\n",
-		       ieee->dev->name);
+		       dev->name);
 		goto success;
 	}
 
 	if (unlikely(skb->len < SNAP_SIZE + sizeof(u16))) {
 		printk(KERN_WARNING "%s: skb too small (%d).\n",
-		       ieee->dev->name, skb->len);
+		       dev->name, skb->len);
 		goto success;
 	}
 
@@ -371,7 +371,7 @@
 	txb = ieee80211_alloc_txb(nr_frags, frag_size, GFP_ATOMIC);
 	if (unlikely(!txb)) {
 		printk(KERN_WARNING "%s: Could not allocate TXB\n",
-		       ieee->dev->name);
+		       dev->name);
 		goto failed;
 	}
 	txb->encrypted = encrypt;
@@ -426,7 +426,7 @@
 	dev_kfree_skb_any(skb);
 
 	if (txb) {
-		if ((*ieee->hard_start_xmit)(txb, dev) == 0) {
+		if ((*ieee->hard_start_xmit)(txb, ieee) == 0) {
 			stats->tx_packets++;
 			stats->tx_bytes += txb->payload_size;
 			return 0;
Index: netdev/net/ieee80211/ieee80211_wx.c
===================================================================
--- netdev.orig/net/ieee80211/ieee80211_wx.c	2005-06-01 11:05:14.000000000 +0200
+++ netdev/net/ieee80211/ieee80211_wx.c	2005-06-03 13:20:46.000000000 +0200
@@ -252,7 +252,7 @@
 			    union iwreq_data *wrqu, char *keybuf)
 {
 	struct iw_point *erq = &(wrqu->encoding);
-	struct net_device *dev = ieee->dev;
+	struct net_device *dev = ieee80211_dev(ieee);
 	struct ieee80211_security sec = {
 		.flags = 0
 	};
@@ -402,7 +402,7 @@
 	sec.level = SEC_LEVEL_1; /* 40 and 104 bit WEP */
 
 	if (ieee->set_security)
-		ieee->set_security(dev, &sec);
+		ieee->set_security(ieee, &sec);
 
 	/* Do not reset port if card is in Managed mode since resetting will
 	 * generate new IEEE 802.11 authentication which may end up in looping
@@ -411,7 +411,7 @@
 	 * the callbacks structures used to initialize the 802.11 stack. */
 	if (ieee->reset_on_keychange &&
 	    ieee->iw_mode != IW_MODE_INFRA &&
-	    ieee->reset_port && ieee->reset_port(dev)) {
+	    ieee->reset_port && ieee->reset_port(ieee)) {
 		printk(KERN_DEBUG "%s: reset_port failed\n", dev->name);
 		return -EINVAL;
 	}


-- 
Jiri Benc
SUSE Labs
