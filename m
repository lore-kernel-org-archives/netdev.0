From: "Zhu, Yi" <yi.zhu@intel.com>
Subject: Re: [PATCH] Merge p80211 to ieee80211 subsystem
Date: Fri, 25 Mar 2005 17:41:30 +0800 (CST)
Message-ID: <Pine.LNX.4.44.0503251737020.4767-100000@mazda.sh.intel.com>
Reply-To: "Zhu, Yi" <yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S.Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Resend patch.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

 include/linux/if_ether.h         |    1 
 include/net/ieee80211.h          |  144 ++++++----
 net/ieee80211/Makefile           |    6 
 net/ieee80211/ieee80211_crypt.c  |   14 -
 net/ieee80211/ieee80211_header.c |  369 +++++++++++++++++++++++++++
 net/ieee80211/ieee80211_impl.h   |   55 ++++
 net/ieee80211/ieee80211_input.c  |  389 ++++++++++++++++++++++++++++
 net/ieee80211/ieee80211_mgmt.c   |  265 +++++++++++++++++++
 net/ieee80211/ieee80211_module.c |  162 ++----------
 net/ieee80211/ieee80211_output.c |  416 +++++++++++++++++++++++++++++++
 net/ieee80211/ieee80211_rx.c     |   59 +---
 net/ieee80211/ieee80211_tx.c     |  128 +++------
 net/ieee80211/ieee80211_wx.c     |   12 
 13 files changed, 1713 insertions(+), 307 deletions(-)


diff -Nru a/include/linux/if_ether.h b/include/linux/if_ether.h
--- a/include/linux/if_ether.h	2005-03-02 15:00:13 +08:00
+++ b/include/linux/if_ether.h	2005-03-02 15:00:13 +08:00
@@ -92,6 +92,7 @@
 #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
 #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
 #define ETH_P_ARCNET	0x001A		/* 1A for ArcNet :-)            */
+#define ETH_P_802_11	0x001B		/* 802.11 frames		*/
 
 /*
  *	This is an Ethernet frame header.
diff -Nru a/include/net/ieee80211.h b/include/net/ieee80211.h
--- a/include/net/ieee80211.h	2005-03-02 15:00:13 +08:00
+++ b/include/net/ieee80211.h	2005-03-02 15:00:13 +08:00
@@ -101,21 +101,28 @@
 #define	MAX_FRAG_THRESHOLD     2346U
 
 /* Frame control field constants */
-#define IEEE80211_FCTL_VERS		0x0002
+#define IEEE80211_FCTL_VERS_0		0x0000
 #define IEEE80211_FCTL_FTYPE		0x000c
 #define IEEE80211_FCTL_STYPE		0x00f0
+#define IEEE80211_FCTL_NODS		0x0000
 #define IEEE80211_FCTL_TODS		0x0100
 #define IEEE80211_FCTL_FROMDS		0x0200
+#define IEEE80211_FCTL_DSTODS		0x0300
+#define IEEE80211_FCTL_DIRMASK		0x0300
 #define IEEE80211_FCTL_MOREFRAGS	0x0400
 #define IEEE80211_FCTL_RETRY		0x0800
 #define IEEE80211_FCTL_PM		0x1000
-#define IEEE80211_FCTL_MOREDATA	0x2000
+#define IEEE80211_FCTL_MOREDATA		0x2000
 #define IEEE80211_FCTL_WEP		0x4000
 #define IEEE80211_FCTL_ORDER		0x8000
 
+#define IEEE80211_FTYPE_SHIFT		2
+#define IEEE80211_STYPE_SHIFT		4
+
 #define IEEE80211_FTYPE_MGMT		0x0000
 #define IEEE80211_FTYPE_CTL		0x0004
 #define IEEE80211_FTYPE_DATA		0x0008
+#define IEEE80211_FTYPE_INVALID		0x000C
 
 /* management */
 #define IEEE80211_STYPE_ASSOC_REQ	0x0000
@@ -230,24 +237,29 @@
 
 #define ETH_P_PREAUTH 0x88C7 /* IEEE 802.11i pre-authentication */
 
-#ifndef ETH_P_80211_RAW
-#define ETH_P_80211_RAW (ETH_P_ECONET + 1)
-#endif
-
 /* IEEE 802.11 defines */
 
 #define P80211_OUI_LEN 3
 
 struct ieee80211_snap_hdr {
+        u8	dsap;   /* always 0xAA */
+        u8	ssap;   /* always 0xAA */
+        u8	ctrl;   /* always 0x03 */
+        u8	oui[P80211_OUI_LEN];    /* organizational universal id */
+	u16	ethertype;
+} __attribute__ ((packed));
 
-        u8    dsap;   /* always 0xAA */
-        u8    ssap;   /* always 0xAA */
-        u8    ctrl;   /* always 0x03 */
-        u8    oui[P80211_OUI_LEN];    /* organizational universal id */
+#define SNAP_SIZE sizeof(struct ieee80211_snap_hdr)
 
+/* Actually, 802.11 + LLC header.  */
+struct ieee80211_data_header {
+	/* 802.11 */
+	struct ieee80211_hdr_3addr hdr;
+	/* LLC */
+	struct ieee80211_snap_hdr  snap;
 } __attribute__ ((packed));
 
-#define SNAP_SIZE sizeof(struct ieee80211_snap_hdr)
+#define IEEE80211_HEADER_LEN  sizeof(struct ieee80211_data_header)
 
 #define WLAN_FC_GET_TYPE(fc) ((fc) & IEEE80211_FCTL_FTYPE)
 #define WLAN_FC_GET_STYPE(fc) ((fc) & IEEE80211_FCTL_STYPE)
@@ -300,6 +312,8 @@
 
 
 /* Information Element IDs */
+#define WLAN_EID_SIZE 2
+
 #define WLAN_EID_SSID 0
 #define WLAN_EID_SUPP_RATES 1
 #define WLAN_EID_FH_PARAMS 2
@@ -309,6 +323,7 @@
 #define WLAN_EID_IBSS_PARAMS 6
 #define WLAN_EID_CHALLENGE 16
 #define WLAN_EID_RSN 48
+#define WLAN_EID_EX_RATES 50
 #define WLAN_EID_GENERIC 221
 
 #define IEEE80211_MGMT_HDR_LEN 24
@@ -489,15 +504,6 @@
 
 */
 
-struct ieee80211_header_data {
-	u16 frame_ctl;
-	u16 duration_id;
-	u8 addr1[6];
-	u8 addr2[6];
-	u8 addr3[6];
-	u16 seq_ctrl;
-};
-
 #define BEACON_PROBE_SSID_ID_POSITION 12
 
 /* Management Frame Information Element Types */
@@ -542,16 +548,22 @@
 */
 
 struct ieee80211_authentication {
-	struct ieee80211_header_data header;
+	struct ieee80211_hdr_3addr header;
 	u16 algorithm;
 	u16 transaction;
 	u16 status;
 	struct ieee80211_info_element info_element;
 } __attribute__ ((packed));
 
+struct ieee80211_beacon {
+	u32 time_stamp[2];
+	u16 beacon_interval;
+	u16 capability;
+	struct ieee80211_info_element info_element;
+} __attribute__ ((packed));
 
 struct ieee80211_probe_response {
-	struct ieee80211_header_data header;
+	struct ieee80211_hdr_3addr header;
 	u32 time_stamp[2];
 	u16 beacon_interval;
 	u16 capability;
@@ -632,15 +644,13 @@
 	size_t rsn_ie_len;
 	struct list_head list;
 };
+#define ieee80211_network_entry(entry) \
+	list_entry(entry, struct ieee80211_network, list)
 
 enum ieee80211_state {
-	IEEE80211_UNINITIALIZED = 0,
-	IEEE80211_INITIALIZED,
-	IEEE80211_ASSOCIATING,
-	IEEE80211_ASSOCIATED,
-	IEEE80211_AUTHENTICATING,
+	IEEE80211_INITIALIZED = 0,
 	IEEE80211_AUTHENTICATED,
-	IEEE80211_SHUTDOWN
+	IEEE80211_ASSOCIATED,
 };
 
 #define DEFAULT_MAX_SCAN_AGE (15 * HZ)
@@ -663,23 +673,47 @@
 #define CFG_IEEE80211_RESERVE_FCS (1<<0)
 #define CFG_IEEE80211_COMPUTE_FCS (1<<1)
 
+#define WIRELESS_MAX_RATES	MAX_RATES_LENGTH + MAX_RATES_EX_LENGTH
+struct wireless_rates {
+	u8 num;
+	u8 rates[WIRELESS_MAX_RATES];
+};
+
+struct wireless_ops {
+	int (*hard_start_xmit)(struct ieee80211_txb *txb,
+			       struct net_device *dev);
+	void (*set_security)(struct net_device *dev,
+			     struct ieee80211_security *sec);
+	int (*reset_port)(struct net_device *dev);
+};
+
 struct ieee80211_device {
+	struct list_head all_device;
+
 	struct net_device *dev;
+	struct wireless_ops *ops;
 
 	/* Bookkeeping structures */
 	struct net_device_stats stats;
 	struct ieee80211_stats ieee_stats;
 
 	/* Probe / Beacon management */
+	spinlock_t network_lock;
 	struct list_head network_free_list;
 	struct list_head network_list;
 	struct ieee80211_network *networks;
 	int scans;
 	int scan_age;
+	struct wireless_rates supp;	/**< software defined */
+	struct wireless_rates extended;	/**< use for corresp. IE, AP only */
+	u8 essid[IW_ESSID_MAX_SIZE];
+	u8 essid_len;
+	u8 channel;
+	u32 capability;
 
 	int iw_mode; /* operating mode (IW_MODE_*) */
 
-	spinlock_t lock;
+	atomic_t refcnt;
 
 	int tx_headroom; /* Set to size of any additional room needed at front
 			  * of allocated Tx SKBs */
@@ -704,6 +738,7 @@
 	size_t wpa_ie_len;
 	u8 *wpa_ie;
 
+	spinlock_t crypt_lock;
 	struct list_head crypt_deinit_list;
 	struct ieee80211_crypt_data *crypt[WEP_KEYS];
 	int tx_keyidx; /* default TX key index (crypt[tx_keyidx]) */
@@ -720,35 +755,35 @@
 	/* Association info */
 	u8 bssid[ETH_ALEN];
 
+	spinlock_t state_lock;
 	enum ieee80211_state state;
 
 	int mode;       /* A, B, G */
 	int modulation; /* CCK, OFDM */
 	int freq_band;  /* 2.4Ghz, 5.2Ghz, Mixed */
 	int abg_ture;   /* ABG flag              */
-
-	/* Callback functions */
-	void (*set_security)(struct net_device *dev,
-			     struct ieee80211_security *sec);
-	int (*hard_start_xmit)(struct ieee80211_txb *txb,
-			       struct net_device *dev);
-	int (*reset_port)(struct net_device *dev);
-
-	/* This must be the last item so that it points to the data
-	 * allocated beyond this structure by alloc_ieee80211 */
-	u8 priv[0];
 };
 
-#define IEEE_A            (1<<0)
-#define IEEE_B            (1<<1)
-#define IEEE_G            (1<<2)
-#define IEEE_MODE_MASK    (IEEE_A|IEEE_B|IEEE_G)
-
-extern inline void *ieee80211_priv(struct net_device *dev)
-{
-	return ((struct ieee80211_device *)netdev_priv(dev))->priv;
-}
+#define ieee80211_device_entry(entry) \
+	list_entry(entry, struct ieee80211_device, all_device)
 
+#define IEEE80211_PHY_CUR_INV	0
+#define IEEE_A			(1<<0)
+#define IEEE_B			(1<<1)
+#define IEEE_G			(1<<2)
+#define IEEE_MODE_MASK		(IEEE_A|IEEE_B|IEEE_G)
+
+extern void ieee80211_setup(struct net_device *dev);
+extern struct ieee80211_device *ieee80211_open(struct net_device *,
+					       struct wireless_ops *);
+extern void ieee80211_close(struct net_device *, struct ieee80211_device *);
+extern int ieee80211_set_mode(struct ieee80211_device *, u8);
+extern int ieee80211_start_scan(struct ieee80211_device *);
+extern enum ieee80211_state ieee80211_get_state(struct ieee80211_device *wp);
+extern void ieee80211_set_state(struct ieee80211_device *wp,
+				enum ieee80211_state st);
+extern unsigned short ieee80211_type_trans(struct sk_buff *,struct net_device*);
+ 
 extern inline int ieee80211_is_empty_essid(const char *essid, int essid_len)
 {
 	/* Single white space is for Linksys APs */
@@ -819,22 +854,21 @@
 
 
 /* ieee80211.c */
-extern void free_ieee80211(struct net_device *dev);
-extern struct net_device *alloc_ieee80211(int sizeof_priv);
 
 extern int ieee80211_set_encryption(struct ieee80211_device *ieee);
 
 /* ieee80211_tx.c */
 
 
-extern int ieee80211_xmit(struct sk_buff *skb,
-			  struct net_device *dev);
+extern int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev);
 extern void ieee80211_txb_free(struct ieee80211_txb *);
 
 
 /* ieee80211_rx.c */
-extern int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
-			struct ieee80211_rx_stats *rx_stats);
+extern int ieee80211_rx(struct sk_buff *skb, struct ieee80211_device *ieee);
+extern void ieee80211_process_probe_response(struct ieee80211_device *ieee,
+			struct ieee80211_probe_response *beacon,
+			struct ieee80211_rx_stats *stats);
 extern void ieee80211_rx_mgt(struct ieee80211_device *ieee,
 			     struct ieee80211_hdr *header,
 			     struct ieee80211_rx_stats *stats);
diff -Nru a/net/ieee80211/Makefile b/net/ieee80211/Makefile
--- a/net/ieee80211/Makefile	2005-03-02 15:00:13 +08:00
+++ b/net/ieee80211/Makefile	2005-03-02 15:00:13 +08:00
@@ -7,5 +7,9 @@
 	ieee80211_module.o \
 	ieee80211_tx.o \
 	ieee80211_rx.o \
-	ieee80211_wx.o
+	ieee80211_wx.o \
+	ieee80211_header.o \
+	ieee80211_mgmt.o \
+	ieee80211_input.o \
+	ieee80211_output.o
 
diff -Nru a/net/ieee80211/ieee80211_crypt.c b/net/ieee80211/ieee80211_crypt.c
--- a/net/ieee80211/ieee80211_crypt.c	2005-03-02 15:00:13 +08:00
+++ b/net/ieee80211/ieee80211_crypt.c	2005-03-02 15:00:13 +08:00
@@ -43,7 +43,9 @@
 {
 	struct list_head *ptr, *n;
 	struct ieee80211_crypt_data *entry;
+	unsigned long flags;
 
+	spin_lock_irqsave(&ieee->crypt_lock, flags);
 	for (ptr = ieee->crypt_deinit_list.next, n = ptr->next;
 	     ptr != &ieee->crypt_deinit_list; ptr = n, n = ptr->next) {
 		entry = list_entry(ptr, struct ieee80211_crypt_data, list);
@@ -59,6 +61,7 @@
 		}
 		kfree(entry);
 	}
+	spin_unlock_irqrestore(&ieee->crypt_lock, flags);
 }
 
 void ieee80211_crypt_deinit_handler(unsigned long data)
@@ -66,7 +69,7 @@
 	struct ieee80211_device *ieee = (struct ieee80211_device *)data;
 	unsigned long flags;
 
-	spin_lock_irqsave(&ieee->lock, flags);
+	spin_lock_irqsave(&ieee->crypt_lock, flags);
 	ieee80211_crypt_deinit_entries(ieee, 0);
 	if (!list_empty(&ieee->crypt_deinit_list)) {
 		printk(KERN_DEBUG "%s: entries remaining in delayed crypt "
@@ -74,7 +77,7 @@
 		ieee->crypt_deinit_timer.expires = jiffies + HZ;
 		add_timer(&ieee->crypt_deinit_timer);
 	}
-	spin_unlock_irqrestore(&ieee->lock, flags);
+	spin_unlock_irqrestore(&ieee->crypt_lock, flags);
 
 }
 
@@ -94,13 +97,13 @@
 	 * decrypt operations. Use a list of delayed deinits to avoid needing
 	 * locking. */
 
-	spin_lock_irqsave(&ieee->lock, flags);
+	spin_lock_irqsave(&ieee->crypt_lock, flags);
 	list_add(&tmp->list, &ieee->crypt_deinit_list);
 	if (!timer_pending(&ieee->crypt_deinit_timer)) {
 		ieee->crypt_deinit_timer.expires = jiffies + HZ;
 		add_timer(&ieee->crypt_deinit_timer);
 	}
-	spin_unlock_irqrestore(&ieee->lock, flags);
+	spin_unlock_irqrestore(&ieee->crypt_lock, flags);
 }
 
 int ieee80211_register_crypto_ops(struct ieee80211_crypto_ops *ops)
@@ -230,10 +233,12 @@
 static void __exit ieee80211_crypto_deinit(void)
 {
 	struct list_head *ptr, *n;
+	unsigned long flags;
 
 	if (hcrypt == NULL)
 		return;
 
+	spin_lock_irqsave(&hcrypt->lock, flags);
 	for (ptr = hcrypt->algs.next, n = ptr->next; ptr != &hcrypt->algs;
 	     ptr = n, n = ptr->next) {
 		struct ieee80211_crypto_alg *alg =
@@ -243,6 +248,7 @@
 		       "'%s' (deinit)\n", alg->ops->name);
 		kfree(alg);
 	}
+	spin_unlock_irqrestore(&hcrypt->lock, flags);
 
 	kfree(hcrypt);
 }
diff -Nru a/net/ieee80211/ieee80211_header.c b/net/ieee80211/ieee80211_header.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ieee80211/ieee80211_header.c	2005-03-02 15:00:13 +08:00
@@ -0,0 +1,369 @@
+/* ieee80211_header.c: 802.11 type handling.
+ *
+ * Copyright (C) 2004-2005 Intel Corporation, Zhu Yi. All rights reserved.
+ *
+ * Portions of this file are based on p80211
+ *	Copyright (C) 2003 David S. Miller <davem@redhat.com>
+ *	Copyright (C) 2003 Arlando Carvalho de Melo <acme@conectiva.com.br>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * James P. Ketrenos <ipw2100-admin@linux.intel.com>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#ifndef EXPORT_SYMTAB
+#define	EXPORT_SYMTAB
+#endif
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/init.h>
+#include <net/neighbour.h>
+#include <net/arp.h>
+
+#include <net/ieee80211.h>
+#include "ieee80211_impl.h"
+
+/* Create the 802.11 MAC header for an arbitrary protocol layer.
+ *
+ * saddr == NULL means use device source address
+ * daddr == NULL means leave destination address (eg unresolved arp)
+ */
+
+static int ieee80211_header(struct sk_buff *skb, struct net_device *dev,
+			    unsigned short type, void *daddr, void *saddr,
+			    unsigned int len)
+{
+	struct ieee80211_data_header *p =
+		(struct ieee80211_data_header *) skb_push(skb, sizeof(*p));
+	void *s_ptr, *d_ptr, *bss_ptr;
+	u16 fctrl;
+	int ret, mode;
+	struct ieee80211_device *wp = ieee80211_find_by_dev(dev);
+
+	if (!wp)
+		return -1;
+
+	/* We fill in shost/dhost, wireless driver fills in self-node address.
+	 * This layout works for station mode only.
+	 */
+	mode = wp->iw_mode;
+	fctrl = cpu_to_le16(IEEE80211_FCTL_VERS_0 |
+			    IEEE80211_FTYPE_DATA |
+			    IEEE80211_STYPE_DATA);
+
+	switch (mode) {
+	case IW_MODE_INFRA:
+		fctrl |= cpu_to_le16(IEEE80211_FCTL_TODS);
+		s_ptr = p->hdr.addr2;
+		d_ptr = p->hdr.addr3;
+		bss_ptr = p->hdr.addr1;
+		break;
+
+	case IW_MODE_MASTER:
+		fctrl |= cpu_to_le16(IEEE80211_FCTL_FROMDS);
+		s_ptr = p->hdr.addr3;
+		d_ptr = p->hdr.addr1;
+		bss_ptr = p->hdr.addr2;
+		break;
+
+	case IW_MODE_ADHOC:
+		fctrl |= cpu_to_le16(0);
+		s_ptr = p->hdr.addr2;
+		d_ptr = p->hdr.addr1;
+		bss_ptr = p->hdr.addr3;
+		break;
+
+	default:
+		/* Unexpected... */
+		ret = -1;
+		goto out;
+	};
+	p->hdr.frame_ctl = fctrl;
+
+	/* Filled in by driver, if necessary. */
+	p->hdr.duration_id = 0;
+
+	if (daddr) {
+		memcpy(d_ptr, daddr, ETH_ALEN);
+		ret = dev->hard_header_len;
+	} else
+		ret = -dev->hard_header_len;
+
+	memcpy(bss_ptr, wp->bssid, ETH_ALEN);
+	memcpy(s_ptr, (saddr ? saddr : dev->dev_addr), ETH_ALEN);
+
+	p->snap.dsap = 0xaa;
+	p->snap.ssap = 0xaa;
+	p->snap.ctrl = 0x03;
+	p->snap.oui[0] = 0x00;
+	p->snap.oui[1] = 0x00;
+	if (type == ETH_P_IPX || type == ETH_P_AARP)
+		p->snap.oui[2] = 0x08;	/* P802_1H_OUI */
+	else
+		p->snap.oui[2] = 0x00;	/* RFC1042_OUI */
+
+	if (type != ETH_P_802_3)
+		p->snap.ethertype = htons(type);
+	else
+		p->snap.ethertype = htons(len);
+
+out:
+	wireless_put(wp);
+	return ret;
+}
+
+/* Rebuild the MAC header.  This is invoked after ARP completes.  */
+static int ieee80211_rebuild_header(struct sk_buff *skb)
+{
+	struct ieee80211_data_header *p =
+			(struct ieee80211_data_header *) skb->data;
+	struct net_device *dev = skb->dev;
+
+	switch (p->snap.ethertype) {
+#ifdef CONFIG_INET
+	case __constant_htons(ETH_P_IP):
+		return arp_find(p->hdr.addr3, skb);
+#endif
+	default:
+		printk(KERN_DEBUG
+		       "%s: unable to resolve type %X addresses.\n", 
+		       dev->name, (int) p->snap.ethertype);
+	};
+
+	return 0;
+}
+
+/* Determine the RX packet's protocol ID.  */
+unsigned short ieee80211_type_trans(struct sk_buff *skb, struct net_device *dev)
+{
+#if 0
+    struct ieee80211_data_header *p;
+	u8 *daddr;
+
+	skb->mac.raw = skb->data;
+	p = (struct ieee80211_data_header *) skb->mac.raw;
+
+	/* First, check the type, if it isn't data we want to
+	 * keep the 802.11 header in place.
+	 */
+	if (((p->hdr.frame_ctl & cpu_to_le16(IEEE80211_FCTL_FTYPE))
+	     != cpu_to_le16(IEEE80211_FTYPE_DATA)) ||
+	    ((p->hdr.frame_ctl & cpu_to_le16(IEEE80211_FCTL_STYPE))
+	     != cpu_to_le16(IEEE80211_STYPE_DATA))) {
+		return __constant_htons(ETH_P_802_11);
+	}
+#endif
+	skb->mac.raw = skb->data;
+	return __constant_htons(ETH_P_802_11);
+#if 0
+	skb_pull(skb, dev->hard_header_len);
+	skb_trim(skb, skb->len - 4); /* Zap trailing CRC */
+
+	switch (p->hdr.frame_ctl & cpu_to_le16(IEEE80211_FCTL_DIRMASK)) {
+	case cpu_to_le16(IEEE80211_FCTL_NODS):
+	case cpu_to_le16(IEEE80211_FCTL_TODS):
+		daddr = p->hdr.addr1;
+		break;
+
+	case cpu_to_le16(IEEE80211_FCTL_FROMDS):
+	case cpu_to_le16(IEEE80211_FCTL_DSTODS):
+	default:
+		daddr = p->hdr.addr3;
+		break;
+	};
+
+	if (daddr[0] & 0x1) {
+		if (memcmp(daddr, dev->broadcast, ETH_ALEN) == 0)
+			skb->pkt_type = PACKET_BROADCAST;
+		else
+			skb->pkt_type = PACKET_MULTICAST;
+	} else {
+		if (memcmp(daddr, dev->dev_addr, ETH_ALEN))
+			skb->pkt_type = PACKET_OTHERHOST;
+	}
+	if (p->snap.dsap == 0xaa &&
+	    p->snap.ssap == 0xaa &&
+	    p->snap.control == 0x03 &&
+	    p->snap.oui[0] == 0 && p->snap.oui[1] == 0 && p->snap.oui[2] == 0) {
+		if (ntohs(p->snap.ethertype) >= 1536)
+			return p->snap.ethertype;
+		if (*(unsigned short *)skb->data == 0xffff)
+			return __constant_htons(ETH_P_802_3);
+
+		/* XXX LLC-in-LLC, is it legal? -DaveM */
+		goto out_llc;
+	}
+
+	/* Put the LLC header back. */
+	skb_push(skb, sizeof(struct ieee802_11_snap));
+
+out_llc:
+	return __constant_htons(ETH_P_802_2);
+#endif
+}
+EXPORT_SYMBOL(ieee80211_type_trans);
+
+static int ieee80211_header_parse(struct sk_buff *skb, unsigned char *haddr)
+{
+	struct ieee80211_data_header *p =
+			(struct ieee80211_data_header *) skb->mac.raw;
+	u8 *saddr;
+
+	switch (p->hdr.frame_ctl & cpu_to_le16(IEEE80211_FCTL_DIRMASK)) {
+	case cpu_to_le16(IEEE80211_FCTL_NODS):
+	case cpu_to_le16(IEEE80211_FCTL_FROMDS):
+		saddr = p->hdr.addr2;
+		break;
+
+	case cpu_to_le16(IEEE80211_FCTL_TODS):
+		saddr = p->hdr.addr3;
+		break;
+
+	case cpu_to_le16(IEEE80211_FCTL_DSTODS):
+	default: {
+		struct ieee80211_hdr *p4 = (struct ieee80211_hdr *) p;
+		saddr = p4->addr4;
+		break;
+	}
+	};
+
+	memcpy(haddr, saddr, ETH_ALEN);
+	return ETH_ALEN;
+}
+
+extern void hh_data_is_too_small(void);
+
+static int ieee80211_header_cache(struct neighbour *neigh, struct hh_cache *hh)
+{
+	unsigned short type = hh->hh_type;
+	struct ieee80211_data_header *p = (struct ieee80211_data_header *)
+		(((u8*)hh->hh_data) + (HH_DATA_OFF(sizeof(*p)) % HH_DATA_MOD));
+	struct net_device *dev = neigh->dev;
+	void *s_ptr, *d_ptr, *bss_ptr;
+	u16 fctrl;
+	int mode;
+	struct ieee80211_device *wp = ieee80211_find_by_dev(dev);
+	int ret = 0;
+
+	if (!wp)
+		return -1;
+
+	if (sizeof(hh->hh_data) < sizeof(*p))
+		hh_data_is_too_small();
+
+	if (type == __constant_htons(ETH_P_802_11)) {
+		ret = -1;
+		goto out;
+	}
+
+	mode = wp->iw_mode;
+	fctrl = cpu_to_le16(IEEE80211_FCTL_VERS_0 |
+			    IEEE80211_FTYPE_DATA |
+			    IEEE80211_STYPE_DATA);
+	switch (mode) {
+	case IW_MODE_INFRA:
+		fctrl |= cpu_to_le16(IEEE80211_FCTL_TODS);
+		s_ptr = p->hdr.addr2;
+		d_ptr = p->hdr.addr3;
+		bss_ptr = p->hdr.addr1;
+		break;
+
+	case IW_MODE_MASTER:
+		fctrl |= cpu_to_le16(IEEE80211_FCTL_FROMDS);
+		s_ptr = p->hdr.addr3;
+		d_ptr = p->hdr.addr1;
+		bss_ptr = p->hdr.addr2;
+		break;
+
+	case IW_MODE_ADHOC:
+		fctrl |= cpu_to_le16(0);
+		s_ptr = p->hdr.addr2;
+		d_ptr = p->hdr.addr1;
+		bss_ptr = p->hdr.addr3;
+		break;
+
+	default:
+		/* Unexpected... */
+		ret = -1;
+		goto out;
+	};
+	p->hdr.frame_ctl = fctrl;
+
+	/* Filled in by driver, if necessary. */
+	p->hdr.duration_id = 0;
+
+	memcpy(d_ptr, neigh->ha, ETH_ALEN);
+	memcpy(bss_ptr, wp->bssid, ETH_ALEN);
+	memcpy(s_ptr, dev->dev_addr, ETH_ALEN);
+
+	/* Filled in by driver. */
+	p->hdr.seq_ctl = 0;
+
+	p->snap.dsap = 0xaa;
+	p->snap.ssap = 0xaa;
+	p->snap.ctrl = 0x03;
+	p->snap.oui[0] = 0x00;
+	p->snap.oui[1] = 0x00;
+	if (type == ETH_P_IPX || type == ETH_P_AARP)
+		p->snap.oui[2] = 0x08;	/* P802_1H_OUI */
+	else
+		p->snap.oui[2] = 0x00;	/* RFC1042_OUI */
+
+	p->snap.ethertype = type;
+
+	hh->hh_len = sizeof(*p);
+
+out:
+	wireless_put(wp);
+	return ret;
+}
+
+static void ieee80211_header_cache_update(struct hh_cache *hh,
+					  struct net_device *dev,
+					  unsigned char *haddr)
+{
+	struct ieee80211_data_header *p = (struct ieee80211_data_header *)
+			((u8*)hh->hh_data + LL_MAX_HEADER - sizeof(*p));
+
+	memcpy(p->hdr.addr3, haddr, dev->addr_len);
+}
+
+void ieee80211_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	dev->hard_header	= ieee80211_header;
+	dev->rebuild_header 	= ieee80211_rebuild_header;
+	dev->hard_header_cache	= ieee80211_header_cache;
+	dev->header_cache_update= ieee80211_header_cache_update;
+	dev->hard_header_parse	= ieee80211_header_parse;
+	dev->hard_header_len 	= sizeof(struct ieee80211_data_header);
+	dev->mtu                = 1500;
+	dev->hard_start_xmit	= ieee80211_xmit;
+	dev->type               = ARPHRD_ETHER; /* XXX: For APs don't support
+						 * ARPHRD_IEEE80211.*/
+}
+EXPORT_SYMBOL(ieee80211_setup);
diff -Nru a/net/ieee80211/ieee80211_impl.h b/net/ieee80211/ieee80211_impl.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ieee80211/ieee80211_impl.h	2005-03-02 15:00:13 +08:00
@@ -0,0 +1,55 @@
+/* ieee80211_impl.h: ieee80211 stack implementation specific header.
+ *
+ * Copyright (C) 2004-2005 Intel Corporation, Zhu Yi. All rights reserved.
+ *
+ * Portions of this file are based on p80211
+ *	Copyright (C) 2003 David S. Miller <davem@redhat.com>
+ *	Copyright (C) 2003 Arlando Carvalho de Melo <acme@conectiva.com.br>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * James P. Ketrenos <ipw2100-admin@linux.intel.com>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#ifndef _IEEE80211_IMPL_H
+#define _IEEE80211_IMPL_H
+
+/* Module init/cleanup */
+extern int ieee80211_input_init(void);
+extern void ieee80211_input_cleanup(void);
+
+int ieee80211_output(struct ieee80211_device *, u16);
+
+struct ieee80211_device *ieee80211_find_by_dev(struct net_device *);
+
+static inline void wireless_get(struct ieee80211_device *p)
+{
+	atomic_inc(&p->refcnt);
+}
+
+extern void __ieee80211_destroy(struct ieee80211_device *);
+
+static inline void wireless_put(struct ieee80211_device *p)
+{
+	if (atomic_dec_and_test(&p->refcnt))
+		__ieee80211_destroy(p);
+}
+
+#endif /* !(_IEEE80211_IMPL_H) */
diff -Nru a/net/ieee80211/ieee80211_input.c b/net/ieee80211/ieee80211_input.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ieee80211/ieee80211_input.c	2005-03-02 15:00:13 +08:00
@@ -0,0 +1,389 @@
+/* ieeee80211_input.c: 802.11 packet input processing.
+ *
+ * Copyright (C) 2004-2005 Intel Corporation, Zhu Yi. All rights reserved.
+ *
+ * Portions of this file are based on p80211
+ *	Copyright (C) 2003 David S. Miller <davem@redhat.com>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * James P. Ketrenos <ipw2100-admin@linux.intel.com>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/init.h>
+
+#include <net/ieee80211.h>
+#include "ieee80211_impl.h"
+
+typedef int (*ieee80211_recv_t)(struct sk_buff *, struct ieee80211_device *);
+
+static int ieee80211_recv_invalid(struct sk_buff *, struct ieee80211_device *);
+
+/* management */
+static int ieee80211_recv_assoc_req(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_assoc_resp(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_reassoc_req(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_reassoc_resp(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_probe_req(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_probe_resp(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_beacon(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_atim(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_disassoc(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_auth(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_deauth(struct sk_buff *, struct ieee80211_device *);
+
+/* control */
+static int ieee80211_recv_pspoll(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_rts(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_cts(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_ack(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_cfend(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_cfendack(struct sk_buff *, struct ieee80211_device *);
+
+/* data */
+extern int ieee80211_recv_data(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_data_cfack(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_data_cfpoll(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_data_cfackpoll(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_nullfunc(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_cfack(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_cfpoll(struct sk_buff *, struct ieee80211_device *);
+static int ieee80211_recv_cfackpoll(struct sk_buff *, struct ieee80211_device *);
+
+static ieee80211_recv_t input_methods[0x4][0x10] = {
+/* management */
+[IEEE80211_FTYPE_MGMT >> IEEE80211_FTYPE_SHIFT] = {
+	[IEEE80211_STYPE_ASSOC_REQ >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_assoc_req,
+	[IEEE80211_STYPE_ASSOC_RESP >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_assoc_resp,
+	[IEEE80211_STYPE_REASSOC_REQ >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_reassoc_req,
+	[IEEE80211_STYPE_REASSOC_RESP >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_reassoc_resp,
+	[IEEE80211_STYPE_PROBE_REQ >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_probe_req,
+	[IEEE80211_STYPE_PROBE_RESP >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_probe_resp,
+	[0x6] = ieee80211_recv_invalid,
+	[0x7] = ieee80211_recv_invalid,
+	[IEEE80211_STYPE_BEACON >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_beacon,
+	[IEEE80211_STYPE_ATIM >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_atim,
+	[IEEE80211_STYPE_DISASSOC >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_disassoc,
+	[IEEE80211_STYPE_AUTH >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_auth,
+	[IEEE80211_STYPE_DEAUTH >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_deauth,
+	[0xd] = ieee80211_recv_invalid,
+	[0xe] = ieee80211_recv_invalid,
+	[0xf] = ieee80211_recv_invalid,
+},
+/* control */
+[IEEE80211_FTYPE_CTL >> IEEE80211_FTYPE_SHIFT] = {
+	[0x0] = ieee80211_recv_invalid,
+	[0x1] = ieee80211_recv_invalid,
+	[0x2] = ieee80211_recv_invalid,
+	[0x3] = ieee80211_recv_invalid,
+	[0x4] = ieee80211_recv_invalid,
+	[0x5] = ieee80211_recv_invalid,
+	[0x6] = ieee80211_recv_invalid,
+	[0x7] = ieee80211_recv_invalid,
+	[0x8] = ieee80211_recv_invalid,
+	[0x9] = ieee80211_recv_invalid,
+	[IEEE80211_STYPE_PSPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_pspoll,
+	[IEEE80211_STYPE_RTS >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_rts,
+	[IEEE80211_STYPE_CTS >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_cts,
+	[IEEE80211_STYPE_ACK >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_ack,
+	[IEEE80211_STYPE_CFEND >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_cfend,
+	[IEEE80211_STYPE_CFENDACK >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_cfendack,
+},
+/* data */
+[IEEE80211_FTYPE_DATA >> IEEE80211_FTYPE_SHIFT] = {
+	[IEEE80211_STYPE_DATA >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_data,
+	[IEEE80211_STYPE_DATA_CFACK >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_data_cfack,
+	[IEEE80211_STYPE_DATA_CFPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_data_cfpoll,
+	[IEEE80211_STYPE_DATA_CFACKPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_data_cfackpoll,
+	[IEEE80211_STYPE_NULLFUNC >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_nullfunc,
+	[IEEE80211_STYPE_CFACK >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_cfack,
+	[IEEE80211_STYPE_CFPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_cfpoll,
+	[IEEE80211_STYPE_CFACKPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_recv_cfackpoll,
+	[0x8] = ieee80211_recv_invalid,
+	[0x9] = ieee80211_recv_invalid,
+	[0xa] = ieee80211_recv_invalid,
+	[0xb] = ieee80211_recv_invalid,
+	[0xc] = ieee80211_recv_invalid,
+	[0xd] = ieee80211_recv_invalid,
+	[0xe] = ieee80211_recv_invalid,
+	[0xf] = ieee80211_recv_invalid,
+},
+/* invalid ftype */
+[IEEE80211_FTYPE_INVALID >> 2] = {
+	[0x0] = ieee80211_recv_invalid,
+	[0x1] = ieee80211_recv_invalid,
+	[0x2] = ieee80211_recv_invalid,
+	[0x3] = ieee80211_recv_invalid,
+	[0x4] = ieee80211_recv_invalid,
+	[0x5] = ieee80211_recv_invalid,
+	[0x6] = ieee80211_recv_invalid,
+	[0x7] = ieee80211_recv_invalid,
+	[0x8] = ieee80211_recv_invalid,
+	[0x9] = ieee80211_recv_invalid,
+	[0xa] = ieee80211_recv_invalid,
+	[0xb] = ieee80211_recv_invalid,
+	[0xc] = ieee80211_recv_invalid,
+	[0xd] = ieee80211_recv_invalid,
+	[0xe] = ieee80211_recv_invalid,
+	[0xf] = ieee80211_recv_invalid,
+},
+};
+
+static inline int demultiplex(struct sk_buff *skb, struct ieee80211_device *wp, u16 ctl)
+{
+	int type, subtype;
+
+	type = (ctl & IEEE80211_FCTL_FTYPE) >> IEEE80211_FTYPE_SHIFT;
+	subtype = (ctl & IEEE80211_FCTL_STYPE) >> IEEE80211_STYPE_SHIFT;
+ 
+	return input_methods[type][subtype](skb, wp);
+}
+
+static int ieee80211_rcv(struct sk_buff *skb, struct net_device *dev,
+			 struct packet_type *pt)
+{
+	struct ieee80211_hdr_3addr *p = (struct ieee80211_hdr_3addr *)skb->data;
+	struct ieee80211_device *wp = ieee80211_find_by_dev(dev);
+	int ret;
+
+	if (wp) {
+		ret = demultiplex(skb, wp, le16_to_cpu(p->frame_ctl));
+		wireless_put(wp);
+	} else {
+		ret = NET_RX_DROP;
+		kfree_skb(skb);
+	}
+	return ret;
+}
+
+int ieee80211_recv_invalid(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+/* management */
+int ieee80211_recv_assoc_req(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_assoc_resp(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_reassoc_req(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_reassoc_resp(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_probe_req(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_probe_resp(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	struct ieee80211_probe_response *beacon =
+		(struct ieee80211_probe_response *)skb->data;
+	struct ieee80211_rx_stats *stats =
+		(struct ieee80211_rx_stats *)&(skb->cb[0]);
+
+	ieee80211_process_probe_response(wp, beacon, stats);
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_beacon(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	struct ieee80211_probe_response *beacon =
+		(struct ieee80211_probe_response *)skb->data;
+	struct ieee80211_rx_stats *stats =
+		(struct ieee80211_rx_stats *)&(skb->cb[0]);
+
+	ieee80211_process_probe_response(wp, beacon, stats);
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_atim(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_disassoc(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_auth(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_deauth(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+/* control */
+int ieee80211_recv_pspoll(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_rts(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_cts(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_ack(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_cfend(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_cfendack(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+/* data */
+int ieee80211_recv_data_cfack(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_data_cfpoll(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_data_cfackpoll(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_nullfunc(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	printk("In %s\n", __FUNCTION__);
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_cfack(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_cfpoll(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+int ieee80211_recv_cfackpoll(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+static struct packet_type ieee80211_packet_type = {
+	.type	=	__constant_htons(ETH_P_802_11),
+	.func	=	ieee80211_rcv,
+};
+
+int ieee80211_input_init(void)
+{
+	dev_add_pack(&ieee80211_packet_type);
+
+	return 0;
+}
+
+void ieee80211_input_cleanup(void)
+{
+	dev_remove_pack(&ieee80211_packet_type);
+}
diff -Nru a/net/ieee80211/ieee80211_mgmt.c b/net/ieee80211/ieee80211_mgmt.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ieee80211/ieee80211_mgmt.c	2005-03-02 15:00:13 +08:00
@@ -0,0 +1,265 @@
+/* ieee80211_mgmt.c: 802.11 management layer.
+ *
+ * Copyright (C) 2004-2005 Intel Corporation, Zhu Yi. All rights reserved.
+ *
+ * Portions of this file are based on:
+
+ * WEP enablement code provided by the Host AP project hostap-drivers v0.1.3
+ *	Copyright (C) 2001-2002, SSH Communications Security Corp and
+ *	Copyright (C) 2002-2003, Jouni Malinen <jkmaline@cc.hut.fi>
+ *
+ * p80211:
+ *	Copyright (C) 2003 David S. Miller <davem@redhat.com>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * James P. Ketrenos <ipw2100-admin@linux.intel.com>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#ifndef EXPORT_SYMTAB
+#define	EXPORT_SYMTAB
+#endif
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/init.h>
+
+#include <net/ieee80211.h>
+#include "ieee80211_impl.h"
+
+static LIST_HEAD(wireless_all);
+static spinlock_t wireless_lock = SPIN_LOCK_UNLOCKED;
+
+static struct ieee80211_device *__wireless_find_by_dev(struct net_device *dev)
+{
+	struct list_head *entry;
+
+	list_for_each(entry, &wireless_all) {
+		struct ieee80211_device *p = ieee80211_device_entry(entry);
+
+		if (p->dev == dev)
+			return p;
+	}
+	return NULL;
+}
+
+struct ieee80211_device *ieee80211_find_by_dev(struct net_device *dev)
+{
+	struct ieee80211_device *wp;
+
+	spin_lock_irq(&wireless_lock);
+	wp = __wireless_find_by_dev(dev);
+	if (wp)
+		wireless_get(wp);
+	spin_unlock_irq(&wireless_lock);
+
+	return wp;
+}
+
+static inline int ieee80211_networks_allocate(struct ieee80211_device *ieee)
+{
+	if (ieee->networks)
+		return 0;
+
+	ieee->networks = kmalloc(
+		MAX_NETWORK_COUNT * sizeof(struct ieee80211_network),
+		GFP_KERNEL);
+	if (!ieee->networks) {
+		printk(KERN_WARNING "%s: Out of memory allocating beacons\n",
+		       ieee->dev->name);
+		return -ENOMEM;
+	}
+
+	memset(ieee->networks, 0,
+	       MAX_NETWORK_COUNT * sizeof(struct ieee80211_network));
+
+	return 0;
+}
+
+static inline void ieee80211_networks_free(struct ieee80211_device *ieee)
+{
+	if (!ieee->networks)
+		return;
+	kfree(ieee->networks);
+	ieee->networks = NULL;
+}
+
+static inline void ieee80211_networks_initialize(struct ieee80211_device *ieee)
+{
+	int i;
+
+	INIT_LIST_HEAD(&ieee->network_free_list);
+	INIT_LIST_HEAD(&ieee->network_list);
+	for (i = 0; i < MAX_NETWORK_COUNT; i++)
+		list_add_tail(&ieee->networks[i].list,
+			      &ieee->network_free_list);
+}
+
+struct ieee80211_device *ieee80211_open(struct net_device *dev,
+					struct wireless_ops *ops)
+{
+	struct ieee80211_device *p;
+	int err;
+
+	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	if (!p)
+		return NULL;
+
+	memset(p, 0, sizeof(*p));
+
+	err = ieee80211_networks_allocate(p);
+	if (err) {
+		IEEE80211_ERROR("Unable to allocate beacon storage.\n");
+		return NULL;
+	}
+	ieee80211_networks_initialize(p);
+
+	atomic_set(&p->refcnt, 1);
+	spin_lock_init(&p->network_lock);
+	spin_lock_init(&p->crypt_lock);
+	spin_lock_init(&p->state_lock);
+	p->iw_mode = IW_MODE_AUTO;
+	p->state = IEEE80211_INITIALIZED;
+	p->scan_age = 0;
+	p->capability = 0;
+	p->mode = IEEE80211_PHY_CUR_INV;
+	p->essid_len = 0;
+
+	/* Default fragmentation threshold is maximum payload size */
+	p->fts = DEFAULT_FTS;
+	p->scan_age = DEFAULT_MAX_SCAN_AGE;
+	p->open_wep = 1;
+
+	/* Default to enabling full open WEP with host based encrypt/decrypt */
+	p->host_encrypt = 1;
+	p->host_decrypt = 1;
+	p->ieee802_1x = 1; /* Default to supporting 802.1x */
+
+	INIT_LIST_HEAD(&p->crypt_deinit_list);
+	init_timer(&p->crypt_deinit_timer);
+	p->crypt_deinit_timer.data = (unsigned long)p;
+	p->crypt_deinit_timer.function = ieee80211_crypt_deinit_handler;
+
+ 	p->wpa_enabled = 0;
+ 	p->tkip_countermeasures = 0;
+ 	p->drop_unencrypted = 0;
+ 	p->privacy_invoked = 0;
+
+	p->dev = dev;
+	p->ops = ops;
+
+	spin_lock_irq(&wireless_lock);
+	list_add(&p->all_device, &wireless_all);
+	spin_unlock_irq(&wireless_lock);
+
+	return p;
+}
+EXPORT_SYMBOL(ieee80211_open);
+
+void __ieee80211_destroy(struct ieee80211_device *p)
+{
+	int i;
+
+	if (atomic_read(&p->refcnt))
+		BUG();
+
+	del_timer_sync(&p->crypt_deinit_timer);
+	ieee80211_crypt_deinit_entries(p, 1);
+
+	for (i = 0; i < WEP_KEYS; i++) {
+		struct ieee80211_crypt_data *crypt = p->crypt[i];
+		if (crypt) {
+			if (crypt->ops) {
+				crypt->ops->deinit(crypt->priv);
+				module_put(crypt->ops->owner);
+			}
+			kfree(crypt);
+			p->crypt[i] = NULL;
+		}
+	}
+	p->state = IEEE80211_INITIALIZED;
+	p->mode = IEEE80211_PHY_CUR_INV;
+	memset(p->essid, 0, sizeof(p->essid));
+	p->essid_len = 0;
+	p->dev = NULL;
+	p->ops = NULL;
+	ieee80211_networks_free(p);
+	kfree(p);
+}
+
+void ieee80211_close(struct net_device *dev, struct ieee80211_device *p)
+{
+	spin_lock_irq(&wireless_lock);
+	list_del_init(&p->network_list);
+	spin_unlock_irq(&wireless_lock);
+
+	wireless_put(p);
+}
+EXPORT_SYMBOL(ieee80211_close);
+
+int ieee80211_set_mode(struct ieee80211_device *wp, u8 mode)
+{
+	switch (mode) {
+	case IW_MODE_AUTO:
+	case IW_MODE_INFRA:
+	case IW_MODE_MASTER:
+	case IW_MODE_ADHOC:
+		break;
+	default:
+		return -EINVAL;
+	};
+
+	/* XXX Flush everything here... */
+
+	wp->iw_mode = mode;
+	return 0;
+}
+EXPORT_SYMBOL(ieee80211_set_mode);
+
+int ieee80211_start_scan(struct ieee80211_device *wp)
+{
+	return 0;
+}
+EXPORT_SYMBOL(ieee80211_start_scan);
+
+enum ieee80211_state ieee80211_get_state(struct ieee80211_device *wp)
+{
+	unsigned long flags;
+	enum ieee80211_state st;
+
+	spin_lock_irqsave(&wp->state_lock, flags);
+	st = wp->state;
+	spin_unlock_irqrestore(&wp->state_lock, flags);
+
+	return st;
+}
+
+void ieee80211_set_state(struct ieee80211_device *wp, enum ieee80211_state st)
+{
+	spin_lock(&wp->state_lock);
+	wp->state = st;
+	spin_unlock(&wp->state_lock);
+}
+EXPORT_SYMBOL(ieee80211_set_state);
diff -Nru a/net/ieee80211/ieee80211_module.c b/net/ieee80211/ieee80211_module.c
--- a/net/ieee80211/ieee80211_module.c	2005-03-02 15:00:13 +08:00
+++ b/net/ieee80211/ieee80211_module.c	2005-03-02 15:00:13 +08:00
@@ -53,6 +53,7 @@
 #include <net/arp.h>
 
 #include <net/ieee80211.h>
+#include "ieee80211_impl.h"
 
 MODULE_DESCRIPTION("802.11 data/management/control stack");
 MODULE_AUTHOR("Copyright (C) 2004 Intel Corporation <jketreno@linux.intel.com>");
@@ -60,128 +61,6 @@
 
 #define DRV_NAME "ieee80211"
 
-static inline int ieee80211_networks_allocate(struct ieee80211_device *ieee)
-{
-	if (ieee->networks)
-		return 0;
-
-	ieee->networks = kmalloc(
-		MAX_NETWORK_COUNT * sizeof(struct ieee80211_network),
-		GFP_KERNEL);
-	if (!ieee->networks) {
-		printk(KERN_WARNING "%s: Out of memory allocating beacons\n",
-		       ieee->dev->name);
-		return -ENOMEM;
-	}
-
-	memset(ieee->networks, 0,
-	       MAX_NETWORK_COUNT * sizeof(struct ieee80211_network));
-
-	return 0;
-}
-
-static inline void ieee80211_networks_free(struct ieee80211_device *ieee)
-{
-	if (!ieee->networks)
-		return;
-	kfree(ieee->networks);
-	ieee->networks = NULL;
-}
-
-static inline void ieee80211_networks_initialize(struct ieee80211_device *ieee)
-{
-	int i;
-
-	INIT_LIST_HEAD(&ieee->network_free_list);
-	INIT_LIST_HEAD(&ieee->network_list);
-	for (i = 0; i < MAX_NETWORK_COUNT; i++)
-		list_add_tail(&ieee->networks[i].list, &ieee->network_free_list);
-}
-
-
-struct net_device *alloc_ieee80211(int sizeof_priv)
-{
-	struct ieee80211_device *ieee;
-	struct net_device *dev;
-	int err;
-
-	IEEE80211_DEBUG_INFO("Initializing...\n");
-
-	dev = alloc_etherdev(sizeof(struct ieee80211_device) + sizeof_priv);
-	if (!dev) {
-		IEEE80211_ERROR("Unable to network device.\n");
-		goto failed;
-	}
-	ieee = netdev_priv(dev);
-	dev->hard_start_xmit = ieee80211_xmit;
-
-	ieee->dev = dev;
-
-	err = ieee80211_networks_allocate(ieee);
-	if (err) {
-		IEEE80211_ERROR("Unable to allocate beacon storage: %d\n",
-				err);
-		goto failed;
-	}
-	ieee80211_networks_initialize(ieee);
-
-	/* Default fragmentation threshold is maximum payload size */
-	ieee->fts = DEFAULT_FTS;
-	ieee->scan_age = DEFAULT_MAX_SCAN_AGE;
-	ieee->open_wep = 1;
-
-	/* Default to enabling full open WEP with host based encrypt/decrypt */
-	ieee->host_encrypt = 1;
-	ieee->host_decrypt = 1;
-	ieee->ieee802_1x = 1; /* Default to supporting 802.1x */
-
-	INIT_LIST_HEAD(&ieee->crypt_deinit_list);
-	init_timer(&ieee->crypt_deinit_timer);
-	ieee->crypt_deinit_timer.data = (unsigned long)ieee;
-	ieee->crypt_deinit_timer.function = ieee80211_crypt_deinit_handler;
-
-	spin_lock_init(&ieee->lock);
-
- 	ieee->wpa_enabled = 0;
- 	ieee->tkip_countermeasures = 0;
- 	ieee->drop_unencrypted = 0;
- 	ieee->privacy_invoked = 0;
- 	ieee->ieee802_1x = 1;
-
-	return dev;
-
- failed:
-	if (dev)
-		free_netdev(dev);
-	return NULL;
-}
-
-
-void free_ieee80211(struct net_device *dev)
-{
-	struct ieee80211_device *ieee = netdev_priv(dev);
-
-	int i;
-
-	del_timer_sync(&ieee->crypt_deinit_timer);
-	ieee80211_crypt_deinit_entries(ieee, 1);
-
-	for (i = 0; i < WEP_KEYS; i++) {
-		struct ieee80211_crypt_data *crypt = ieee->crypt[i];
-		if (crypt) {
-			if (crypt->ops) {
-				crypt->ops->deinit(crypt->priv);
-				module_put(crypt->ops->owner);
-			}
-			kfree(crypt);
-			ieee->crypt[i] = NULL;
-		}
-	}
-
-	ieee80211_networks_free(ieee);
-	free_netdev(dev);
-}
-
 #ifdef CONFIG_IEEE80211_DEBUG
 
 static int debug = 0;
@@ -221,7 +100,7 @@
 	return strnlen(buf, count);
 }
 
-static int __init ieee80211_init(void)
+static int ieee80211_debug_init(void)
 {
 	struct proc_dir_entry *e;
 
@@ -246,7 +125,7 @@
 	return 0;
 }
 
-static void __exit ieee80211_exit(void)
+static void ieee80211_debug_cleanup(void)
 {
 	if (ieee80211_proc) {
 		remove_proc_entry("debug_level", ieee80211_proc);
@@ -259,10 +138,37 @@
 module_param(debug, int, 0444);
 MODULE_PARM_DESC(debug, "debug output mask");
 
+#endif	/* CONFIG_IEEE80211_DEBUG */
 
-module_exit(ieee80211_exit);
-module_init(ieee80211_init);
+static int __init ieee80211_init(void)
+{
+	int err;
+
+	printk(KERN_INFO "IEEE 802.11 protocol stack loading.\n");
+
+#ifdef CONFIG_IEEE80211_DEBUG
+	err = ieee80211_debug_init();
+	if (err)
+		goto out;
 #endif
+	err = ieee80211_input_init();
+	if (err) {
+		printk(KERN_ERR
+		       "ieee80211_init: Failed to init input processing.\n");
+		goto out;
+	}
 
-EXPORT_SYMBOL(alloc_ieee80211);
-EXPORT_SYMBOL(free_ieee80211);
+out:
+	return err;
+}
+
+static void __exit ieee80211_cleanup(void)
+{
+	ieee80211_input_cleanup();
+#ifdef CONFIG_IEEE80211_DEBUG
+	ieee80211_debug_cleanup();
+#endif
+}
+
+module_init(ieee80211_init);
+module_exit(ieee80211_cleanup);
diff -Nru a/net/ieee80211/ieee80211_output.c b/net/ieee80211/ieee80211_output.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/net/ieee80211/ieee80211_output.c	2005-03-02 15:00:13 +08:00
@@ -0,0 +1,416 @@
+/* ieee80211_output.c: 802.11 packet output processing.
+ *
+ * Copyright (C) 2004-2005 Intel Corporation, Zhu Yi. All rights reserved.
+ *
+ * Portions of this file are based on p80211
+ *	Copyright (C) 2003 David S. Miller <davem@redhat.com>
+ *
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of version 2 of the GNU General Public License as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ * Contact Information:
+ * James P. Ketrenos <ipw2100-admin@linux.intel.com>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/types.h>
+#include <linux/init.h>
+
+#include <net/ieee80211.h>
+#include "ieee80211_impl.h"
+
+typedef int (*ieee80211_send_t)(struct ieee80211_device *, u16);
+
+static int ieee80211_send_invalid(struct ieee80211_device *, u16);
+
+/* management */
+static int ieee80211_send_assoc_req(struct ieee80211_device *, u16);
+static int ieee80211_send_assoc_resp(struct ieee80211_device *, u16);
+static int ieee80211_send_reassoc_req(struct ieee80211_device *, u16);
+static int ieee80211_send_reassoc_resp(struct ieee80211_device *, u16);
+static int ieee80211_send_probe_req(struct ieee80211_device *, u16);
+static int ieee80211_send_probe_resp(struct ieee80211_device *, u16);
+static int ieee80211_send_beacon(struct ieee80211_device *, u16);
+static int ieee80211_send_atim(struct ieee80211_device *, u16);
+static int ieee80211_send_disassoc(struct ieee80211_device *, u16);
+static int ieee80211_send_auth(struct ieee80211_device *, u16);
+static int ieee80211_send_deauth(struct ieee80211_device *, u16);
+
+/* control */
+static int ieee80211_send_pspoll(struct ieee80211_device *, u16);
+static int ieee80211_send_rts(struct ieee80211_device *, u16);
+static int ieee80211_send_cts(struct ieee80211_device *, u16);
+static int ieee80211_send_ack(struct ieee80211_device *, u16);
+static int ieee80211_send_cfend(struct ieee80211_device *, u16);
+static int ieee80211_send_cfendack(struct ieee80211_device *, u16);
+
+/* data */
+static int ieee80211_send_data(struct ieee80211_device *, u16);
+static int ieee80211_send_data_cfack(struct ieee80211_device *, u16);
+static int ieee80211_send_data_cfpoll(struct ieee80211_device *, u16);
+static int ieee80211_send_data_cfackpoll(struct ieee80211_device *, u16);
+static int ieee80211_send_nullfunc(struct ieee80211_device *, u16);
+static int ieee80211_send_cfack(struct ieee80211_device *, u16);
+static int ieee80211_send_cfpoll(struct ieee80211_device *, u16);
+static int ieee80211_send_cfackpoll(struct ieee80211_device *, u16);
+
+static ieee80211_send_t output_methods[0x4][0x10] = {
+/* management */
+[IEEE80211_FTYPE_MGMT >> IEEE80211_FTYPE_SHIFT] = {
+	[IEEE80211_STYPE_ASSOC_REQ >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_assoc_req,
+	[IEEE80211_STYPE_ASSOC_RESP >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_assoc_resp,
+	[IEEE80211_STYPE_REASSOC_REQ >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_reassoc_req,
+	[IEEE80211_STYPE_REASSOC_RESP >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_reassoc_resp,
+	[IEEE80211_STYPE_PROBE_REQ >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_probe_req,
+	[IEEE80211_STYPE_PROBE_RESP >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_probe_resp,
+	[0x6] = ieee80211_send_invalid,
+	[0x7] = ieee80211_send_invalid,
+	[IEEE80211_STYPE_BEACON >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_beacon,
+	[IEEE80211_STYPE_ATIM >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_atim,
+	[IEEE80211_STYPE_DISASSOC >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_disassoc,
+	[IEEE80211_STYPE_AUTH >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_auth,
+	[IEEE80211_STYPE_DEAUTH >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_deauth,
+	[0xd] = ieee80211_send_invalid,
+	[0xe] = ieee80211_send_invalid,
+	[0xf] = ieee80211_send_invalid,
+},
+/* control */
+[IEEE80211_FTYPE_CTL >> IEEE80211_FTYPE_SHIFT] = {
+	[0x0] = ieee80211_send_invalid,
+	[0x1] = ieee80211_send_invalid,
+	[0x2] = ieee80211_send_invalid,
+	[0x3] = ieee80211_send_invalid,
+	[0x4] = ieee80211_send_invalid,
+	[0x5] = ieee80211_send_invalid,
+	[0x6] = ieee80211_send_invalid,
+	[0x7] = ieee80211_send_invalid,
+	[0x8] = ieee80211_send_invalid,
+	[0x9] = ieee80211_send_invalid,
+	[IEEE80211_STYPE_PSPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_pspoll,
+	[IEEE80211_STYPE_RTS >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_rts,
+	[IEEE80211_STYPE_CTS >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_cts,
+	[IEEE80211_STYPE_ACK >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_ack,
+	[IEEE80211_STYPE_CFEND >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_cfend,
+	[IEEE80211_STYPE_CFENDACK >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_cfendack,
+},
+/* data */
+[IEEE80211_FTYPE_DATA >> IEEE80211_FTYPE_SHIFT] = {
+	[IEEE80211_STYPE_DATA >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_data,
+	[IEEE80211_STYPE_DATA_CFACK >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_data_cfack,
+	[IEEE80211_STYPE_DATA_CFPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_data_cfpoll,
+	[IEEE80211_STYPE_DATA_CFACKPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_data_cfackpoll,
+	[IEEE80211_STYPE_NULLFUNC >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_nullfunc,
+	[IEEE80211_STYPE_CFACK >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_cfack,
+	[IEEE80211_STYPE_CFPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_cfpoll,
+	[IEEE80211_STYPE_CFACKPOLL >> IEEE80211_STYPE_SHIFT] =
+		ieee80211_send_cfackpoll,
+	[0x8] = ieee80211_send_invalid,
+	[0x9] = ieee80211_send_invalid,
+	[0xa] = ieee80211_send_invalid,
+	[0xb] = ieee80211_send_invalid,
+	[0xc] = ieee80211_send_invalid,
+	[0xd] = ieee80211_send_invalid,
+	[0xe] = ieee80211_send_invalid,
+	[0xf] = ieee80211_send_invalid,
+},
+/* invalid ftype */
+[IEEE80211_FTYPE_INVALID >> 2] = {
+	[0x0] = ieee80211_send_invalid,
+	[0x1] = ieee80211_send_invalid,
+	[0x2] = ieee80211_send_invalid,
+	[0x3] = ieee80211_send_invalid,
+	[0x4] = ieee80211_send_invalid,
+	[0x5] = ieee80211_send_invalid,
+	[0x6] = ieee80211_send_invalid,
+	[0x7] = ieee80211_send_invalid,
+	[0x8] = ieee80211_send_invalid,
+	[0x9] = ieee80211_send_invalid,
+	[0xa] = ieee80211_send_invalid,
+	[0xb] = ieee80211_send_invalid,
+	[0xc] = ieee80211_send_invalid,
+	[0xd] = ieee80211_send_invalid,
+	[0xe] = ieee80211_send_invalid,
+	[0xf] = ieee80211_send_invalid,
+},
+};
+
+int ieee80211_output(struct ieee80211_device *wp, u16 ctl)
+{
+	int type, subtype;
+
+	type = (ctl & IEEE80211_FCTL_FTYPE) >> IEEE80211_FTYPE_SHIFT;
+	subtype = (ctl & IEEE80211_FCTL_STYPE) >> IEEE80211_STYPE_SHIFT;
+
+	return output_methods[type][subtype](wp, ctl);
+}
+
+/* Packet building helpers. */
+static void mgmt_build_and_send(struct ieee80211_device *wp,
+				struct sk_buff *skb,
+				u16 stype)
+{
+	struct ieee80211_hdr_3addr *p;
+
+	p = (struct ieee80211_hdr_3addr *) skb_push(skb, sizeof(*p));
+
+	p->frame_ctl = cpu_to_le16(IEEE80211_FCTL_VERS_0 |
+				   IEEE80211_FTYPE_MGMT |
+				   stype |
+				   IEEE80211_FCTL_NODS);
+	p->duration_id = 0; /* Set by driver, if necessary */
+
+	memcpy(p->addr2, wp->dev->dev_addr, ETH_ALEN);
+	memcpy(p->addr3, wp->bssid, ETH_ALEN);
+
+	p->seq_ctl = 0; /* Set by driver, if necessary */
+
+	dev_queue_xmit(skb);
+}
+
+static void put_essid(struct sk_buff *skb, struct ieee80211_device *wp)
+{
+	u8 *p;
+
+	if (wp->essid_len > IW_ESSID_MAX_SIZE)
+		BUG();
+
+	p = (u8 *) skb_put(skb, WLAN_EID_SIZE + wp->essid_len);
+	*p++ = WLAN_EID_SSID;
+	*p++ = wp->essid_len;
+	if (wp->essid_len) {
+		memcpy(p, wp->essid, wp->essid_len);
+		p += wp->essid_len;
+	}
+	if (p != skb->tail)
+		BUG();
+}
+
+static void put_rates(struct sk_buff *skb, struct wireless_rates *rd,
+		      struct wireless_rates *xrd)
+{
+	u8 *p;
+	int base_num, ext_num, pkt_len;
+
+	base_num = rd->num;
+	ext_num = xrd->num;
+	pkt_len = rd->num + xrd->num;
+
+	p = (u8 *) skb_put(skb, pkt_len);
+	*p++ = WLAN_EID_SUPP_RATES;
+	*p++ = base_num;
+	memcpy(p, rd->rates, base_num);
+	p += base_num;
+
+	if (ext_num) {
+		*p++ = WLAN_EID_EX_RATES;
+		*p++ = ext_num;
+		memcpy(p, xrd->rates, ext_num);
+		p += ext_num;
+	}
+
+	if (p != skb->tail)
+		BUG();
+}
+
+static struct sk_buff *mgmt_alloc_skb(int len)
+{
+	struct sk_buff *skb = alloc_skb(len, GFP_ATOMIC);
+
+	if (skb)
+		skb_reserve(skb, sizeof(struct ieee80211_hdr_3addr));
+
+	return skb;
+}
+
+int ieee80211_send_invalid(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+/* management */
+int ieee80211_send_assoc_req(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_assoc_resp(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_reassoc_req(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_reassoc_resp(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_probe_req(struct ieee80211_device *wp, u16 ctl)
+{
+	struct ieee80211_hdr_3addr *p;
+	struct sk_buff *skb;
+	int len;
+
+	len = sizeof(*p) +
+		(WLAN_EID_SIZE + wp->essid_len) +
+		(WLAN_EID_SIZE + wp->supp.num + wp->extended.num);
+	skb = mgmt_alloc_skb(len);
+	if (skb) {
+		put_essid(skb, wp);
+		put_rates(skb, &wp->supp, &wp->extended);
+
+		mgmt_build_and_send(wp, skb, IEEE80211_STYPE_PROBE_REQ);
+		return 0;
+	}
+
+	return -ENOMEM;
+}
+
+int ieee80211_send_probe_resp(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_beacon(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_atim(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_disassoc(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_auth(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_deauth(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+/* control */
+int ieee80211_send_pspoll(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_rts(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_cts(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_ack(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_cfend(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_cfendack(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+/* data */
+int ieee80211_send_data(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_data_cfack(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_data_cfpoll(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_data_cfackpoll(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_nullfunc(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_cfack(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_cfpoll(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
+
+int ieee80211_send_cfackpoll(struct ieee80211_device *wp, u16 ctl)
+{
+	return -ENOSYS;
+}
diff -Nru a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
--- a/net/ieee80211/ieee80211_rx.c	2005-03-02 15:00:13 +08:00
+++ b/net/ieee80211/ieee80211_rx.c	2005-03-02 15:00:13 +08:00
@@ -48,7 +48,7 @@
 	skb->mac.raw = skb->data;
 	skb_pull(skb, ieee80211_get_hdrlen(fc));
 	skb->pkt_type = PACKET_OTHERHOST;
-	skb->protocol = __constant_htons(ETH_P_80211_RAW);
+	skb->protocol = __constant_htons(ETH_P_802_11);
 	memset(skb->cb, 0, sizeof(skb->cb));
 	netif_rx(skb);
 }
@@ -168,7 +168,7 @@
  *
  * Responsible for handling management control frames
  *
- * Called by ieee80211_rx */
+ * Called by ieee80211_recv_data */
 static inline int
 ieee80211_rx_frame_mgmt(struct ieee80211_device *ieee, struct sk_buff *skb,
 			struct ieee80211_rx_stats *rx_stats, u16 type,
@@ -270,7 +270,7 @@
 	return 0;
 }
 
-/* Called only as a tasklet (software IRQ), by ieee80211_rx */
+/* Called only as a tasklet (software IRQ), by ieee80211_recv_data */
 static inline int
 ieee80211_rx_frame_decrypt(struct ieee80211_device* ieee, struct sk_buff *skb,
 			   struct ieee80211_crypt_data *crypt)
@@ -315,7 +315,7 @@
 }
 
 
-/* Called only as a tasklet (software IRQ), by ieee80211_rx */
+/* Called only as a tasklet (software IRQ), by ieee80211_recv_data */
 static inline int
 ieee80211_rx_frame_decrypt_msdu(struct ieee80211_device* ieee, struct sk_buff *skb,
 			     int keyidx, struct ieee80211_crypt_data *crypt)
@@ -346,14 +346,14 @@
 /* All received frames are sent to this function. @skb contains the frame in
  * IEEE 802.11 format, i.e., in the format it was sent over air.
  * This function is called only as a tasklet (software IRQ). */
-int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
-		 struct ieee80211_rx_stats *rx_stats)
+int ieee80211_recv_data(struct sk_buff *skb, struct ieee80211_device *ieee)
 {
 	struct net_device *dev = ieee->dev;
 	struct ieee80211_hdr *hdr;
 	size_t hdrlen;
 	u16 fc, type, stype, sc;
 	struct net_device_stats *stats;
+	struct ieee80211_rx_stats *rx_stats;
 	unsigned int frag;
 	u8 *payload;
 	u16 ethertype;
@@ -372,10 +372,10 @@
 
 	hdr = (struct ieee80211_hdr *)skb->data;
 	stats = &ieee->stats;
+	rx_stats = (struct ieee80211_rx_stats *) &(skb->cb[0]);
 
 	if (skb->len < 10) {
-		printk(KERN_INFO "%s: SKB length < 10\n",
-		       dev->name);
+		printk(KERN_INFO "%s: SKB length < 10\n", dev->name);
 		goto rx_dropped;
 	}
 
@@ -697,24 +697,15 @@
 	}
 #endif
 
-	/* convert hdr + possible LLC headers into Ethernet header */
-	if (skb->len - hdrlen >= 8 &&
-	    ((memcmp(payload, rfc1042_header, SNAP_SIZE) == 0 &&
-	      ethertype != ETH_P_AARP && ethertype != ETH_P_IPX) ||
-	     memcmp(payload, bridge_tunnel_header, SNAP_SIZE) == 0)) {
+	/* get EtherType */
+	if (skb->len - hdrlen < 8 ||
+	    ((memcmp(payload, rfc1042_header, SNAP_SIZE - 2) ||
+	      ethertype == ETH_P_AARP || ethertype == ETH_P_IPX) &&
+	     memcmp(payload, bridge_tunnel_header, SNAP_SIZE - 2))) {
 		/* remove RFC1042 or Bridge-Tunnel encapsulation and
-		 * replace EtherType */
-		skb_pull(skb, hdrlen + SNAP_SIZE);
-		memcpy(skb_push(skb, ETH_ALEN), src, ETH_ALEN);
-		memcpy(skb_push(skb, ETH_ALEN), dst, ETH_ALEN);
-	} else {
-		u16 len;
-		/* Leave Ethernet header part of hdr and full payload */
-		skb_pull(skb, hdrlen);
-		len = htons(skb->len);
-		memcpy(skb_push(skb, 2), &len, 2);
-		memcpy(skb_push(skb, ETH_ALEN), src, ETH_ALEN);
-		memcpy(skb_push(skb, ETH_ALEN), dst, ETH_ALEN);
+		 * replace EtherType else Leave Ethernet header part
+		 * of hdr and full payload */
+		ethertype = skb->len;
 	}
 
 #ifdef NOT_YET
@@ -764,10 +755,11 @@
 #endif
 
 	if (skb) {
-		skb->protocol = eth_type_trans(skb, dev);
+		skb->mac.raw = skb->data;
+		skb_pull(skb, IEEE80211_HEADER_LEN);
+		skb->protocol = htons(ethertype);
 		memset(skb->cb, 0, sizeof(skb->cb));
-		skb->dev = dev;
-		skb->ip_summed = CHECKSUM_NONE; /* 802.11 crc not sufficient */
+
 		netif_rx(skb);
 	}
 
@@ -1049,7 +1041,7 @@
 	/* dst->last_associate is not overwritten */
 }
 
-static inline void ieee80211_process_probe_response(
+void ieee80211_process_probe_response(
 	struct ieee80211_device *ieee,
 	struct ieee80211_probe_response *beacon,
 	struct ieee80211_rx_stats *stats)
@@ -1057,10 +1049,10 @@
 	struct ieee80211_network network;
 	struct ieee80211_network *target;
 	struct ieee80211_network *oldest = NULL;
+	unsigned long flags;
 #ifdef CONFIG_IEEE80211_DEBUG
 	struct ieee80211_info_element *info_element = &beacon->info_element;
 #endif
-	unsigned long flags;
 
 	IEEE80211_DEBUG_SCAN(
 		"'%s' (" MAC_FMT "): %c%c%c%c %c%c%c%c-%c%c%c%c %c%c%c%c\n",
@@ -1104,8 +1096,7 @@
 	/* Search for this entry in the list and update it if it is
 	 * already there. */
 
-	spin_lock_irqsave(&ieee->lock, flags);
-
+	spin_lock_irqsave(&ieee->network_lock, flags);
 	list_for_each_entry(target, &ieee->network_list, list) {
 		if (is_same_network(target, &network))
 			break;
@@ -1157,7 +1148,7 @@
 		update_network(target, &network);
 	}
 
-	spin_unlock_irqrestore(&ieee->lock, flags);
+	spin_unlock_irqrestore(&ieee->network_lock, flags);
 }
 
 void ieee80211_rx_mgt(struct ieee80211_device *ieee,
@@ -1203,4 +1194,4 @@
 
 
 EXPORT_SYMBOL(ieee80211_rx_mgt);
-EXPORT_SYMBOL(ieee80211_rx);
+EXPORT_SYMBOL(ieee80211_recv_data);
diff -Nru a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
--- a/net/ieee80211/ieee80211_tx.c	2005-03-02 15:00:13 +08:00
+++ b/net/ieee80211/ieee80211_tx.c	2005-03-02 15:00:13 +08:00
@@ -45,6 +45,7 @@
 #include <asm/uaccess.h>
 
 #include <net/ieee80211.h>
+#include "ieee80211_impl.h"
 
 
 /*
@@ -150,9 +151,9 @@
 	snap->oui[1] = oui[1];
 	snap->oui[2] = oui[2];
 
-	*(u16 *)(data + SNAP_SIZE) = htons(h_proto);
+	snap->ethertype = htons(h_proto);
 
-	return SNAP_SIZE + sizeof(u16);
+	return SNAP_SIZE;
 }
 
 static inline int ieee80211_encrypt_fragment(
@@ -244,48 +245,39 @@
 }
 
 /* SKBs are added to the ieee->tx_queue. */
-int ieee80211_xmit(struct sk_buff *skb,
-		   struct net_device *dev)
+int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ieee80211_device *ieee = netdev_priv(dev);
+	struct ieee80211_device *ieee = ieee80211_find_by_dev(dev);
 	struct ieee80211_txb *txb = NULL;
-	struct ieee80211_hdr *frag_hdr;
+	struct ieee80211_data_header *frag_hdr;
 	int i, bytes_per_frag, nr_frags, bytes_last_frag, frag_size;
-	unsigned long flags;
 	struct net_device_stats *stats = &ieee->stats;
 	int ether_type, encrypt;
-	int bytes, fc, hdr_len;
+	int bytes, fc;
 	struct sk_buff *skb_frag;
-	struct ieee80211_hdr header = { /* Ensure zero initialized */
-		.duration_id = 0,
-		.seq_ctl = 0
-	};
-	u8 dest[ETH_ALEN], src[ETH_ALEN];
-
+	struct ieee80211_data_header header;
+	u8 dest[ETH_ALEN];
 	struct ieee80211_crypt_data* crypt;
 
-	spin_lock_irqsave(&ieee->lock, flags);
+	if (!ieee)
+		return -1;
 
 	/* If there is no driver handler to take the TXB, dont' bother
 	 * creating it... */
-	if (!ieee->hard_start_xmit) {
+	if (!ieee->ops->hard_start_xmit) {
 		printk(KERN_WARNING "%s: No xmit handler.\n",
 		       ieee->dev->name);
 		goto success;
 	}
 
-	if (unlikely(skb->len < SNAP_SIZE + sizeof(u16))) {
-		printk(KERN_WARNING "%s: skb too small (%d).\n",
-		       ieee->dev->name, skb->len);
-		goto success;
-	}
-
-	ether_type = ntohs(((struct ethhdr *)skb->data)->h_proto);
+	memcpy(&header, skb->data, IEEE80211_HEADER_LEN);
+	skb_pull(skb, IEEE80211_HEADER_LEN);
+	ether_type = ntohs(header.snap.ethertype);
 
 	crypt = ieee->crypt[ieee->tx_keyidx];
 
 	encrypt = !(ether_type == ETH_P_PAE && ieee->ieee802_1x) &&
-		ieee->host_encrypt && crypt && crypt->ops;
+			ieee->host_encrypt && crypt && crypt->ops;
 
 	if (!encrypt && ieee->ieee802_1x &&
 	    ieee->drop_unencrypted && ether_type != ETH_P_PAE) {
@@ -295,45 +287,22 @@
 
 #ifdef CONFIG_IEEE80211_DEBUG
 	if (crypt && !encrypt && ether_type == ETH_P_PAE) {
+		/* FIXME: eap is wrong */
 		struct eapol *eap = (struct eapol *)(skb->data +
-			sizeof(struct ethhdr) - SNAP_SIZE - sizeof(u16));
+			sizeof(struct ethhdr) - SNAP_SIZE);
 		IEEE80211_DEBUG_EAP("TX: IEEE 802.11 EAPOL frame: %s\n",
 			eap_get_type(eap->type));
 	}
 #endif
 
-	/* Save source and destination addresses */
-	memcpy(&dest, skb->data, ETH_ALEN);
-	memcpy(&src, skb->data+ETH_ALEN, ETH_ALEN);
-
-	/* Advance the SKB to the start of the payload */
-	skb_pull(skb, sizeof(struct ethhdr));
-
-	/* Determine total amount of storage required for TXB packets */
-	bytes = skb->len + SNAP_SIZE + sizeof(u16);
-
-	if (encrypt)
-		fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA |
-			IEEE80211_FCTL_WEP;
-	else
-		fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA;
-
-	if (ieee->iw_mode == IW_MODE_INFRA) {
-		fc |= IEEE80211_FCTL_TODS;
-		/* To DS: Addr1 = BSSID, Addr2 = SA,
-		   Addr3 = DA */
-		memcpy(&header.addr1, ieee->bssid, ETH_ALEN);
-		memcpy(&header.addr2, &src, ETH_ALEN);
-		memcpy(&header.addr3, &dest, ETH_ALEN);
-	} else if (ieee->iw_mode == IW_MODE_ADHOC) {
-		/* not From/To DS: Addr1 = DA, Addr2 = SA,
-		   Addr3 = BSSID */
-		memcpy(&header.addr1, dest, ETH_ALEN);
-		memcpy(&header.addr2, src, ETH_ALEN);
-		memcpy(&header.addr3, ieee->bssid, ETH_ALEN);
+	fc = le16_to_cpu(header.hdr.frame_ctl);
+	if (encrypt) {
+		fc |= IEEE80211_FCTL_WEP;
+		header.hdr.frame_ctl = cpu_to_le16(fc);
 	}
-	header.frame_ctl = cpu_to_le16(fc);
-	hdr_len = IEEE80211_3ADDR_LEN;
+
+	/* TODO: handle IBSS (and WDS?) here */
+	memcpy(&dest, &header.hdr.addr3, ETH_ALEN);
 
 	/* Determine fragmentation size based on destination (multicast
 	 * and broadcast are not fragmented) */
@@ -357,6 +326,9 @@
 		bytes_per_frag -= crypt->ops->extra_prefix_len +
 			crypt->ops->extra_postfix_len;
 
+	/* Determine total amount of storage required for TXB packets */
+	bytes = skb->len + SNAP_SIZE;
+
 	/* Number of fragments is the total bytes_per_frag /
 	 * payload_per_fragment */
 	nr_frags = bytes / bytes_per_frag;
@@ -376,7 +348,7 @@
 		goto failed;
 	}
 	txb->encrypted = encrypt;
-	txb->payload_size = bytes;
+	txb->payload_size = skb->len;
 
 	for (i = 0; i < nr_frags; i++) {
 		skb_frag = txb->fragments[i];
@@ -384,26 +356,27 @@
 		if (encrypt)
 			skb_reserve(skb_frag, crypt->ops->extra_prefix_len);
 
-		frag_hdr = (struct ieee80211_hdr *)skb_put(skb_frag, hdr_len);
-		memcpy(frag_hdr, &header, hdr_len);
+		frag_hdr = (struct ieee80211_data_header *)
+				skb_put(skb_frag, IEEE80211_3ADDR_LEN);
+		memcpy(frag_hdr, &header.hdr, IEEE80211_3ADDR_LEN);
+
+		bytes = 0;
+		/* Only put a SNAP header on the first fragment */
+		if (i == 0) {
+			skb_put(skb_frag, SNAP_SIZE);
+			memcpy(&frag_hdr->snap, &header.snap, SNAP_SIZE);
+			bytes = -SNAP_SIZE;
+		}
 
 		/* If this is not the last fragment, then add the MOREFRAGS
 		 * bit to the frame control */
 		if (i != nr_frags - 1) {
-			frag_hdr->frame_ctl = cpu_to_le16(
-				fc | IEEE80211_FCTL_MOREFRAGS);
-			bytes = bytes_per_frag;
+			fc |= IEEE80211_FCTL_MOREFRAGS;
+			frag_hdr->hdr.frame_ctl = cpu_to_le16(fc);
+			bytes += bytes_per_frag;
 		} else {
 			/* The last fragment takes the remaining length */
-			bytes = bytes_last_frag;
-		}
-
-	       	/* Put a SNAP header on the first fragment */
-		if (i == 0) {
-			ieee80211_put_snap(
-				skb_put(skb_frag, SNAP_SIZE + sizeof(u16)),
-				ether_type);
-			bytes -= SNAP_SIZE + sizeof(u16);
+			bytes += bytes_last_frag;
 		}
 
 		memcpy(skb_put(skb_frag, bytes), skb->data, bytes);
@@ -414,20 +387,20 @@
 		/* Encryption routine will move the header forward in order
 		 * to insert the IV between the header and the payload */
 		if (encrypt)
-			ieee80211_encrypt_fragment(ieee, skb_frag, hdr_len);
+			ieee80211_encrypt_fragment(ieee, skb_frag,
+						   IEEE80211_3ADDR_LEN);
 		if (ieee->config &
 		    (CFG_IEEE80211_COMPUTE_FCS | CFG_IEEE80211_RESERVE_FCS))
-			skb_put(skb_frag, 4);
+			skb_put(skb_frag, IEEE80211_FCS_LEN);
 	}
 
 
  success:
-	spin_unlock_irqrestore(&ieee->lock, flags);
-
 	dev_kfree_skb_any(skb);
+	wireless_put(ieee);
 
 	if (txb) {
-		if ((*ieee->hard_start_xmit)(txb, dev) == 0) {
+		if (ieee->ops->hard_start_xmit(txb, dev) == 0) {
 			stats->tx_packets++;
 			stats->tx_bytes += txb->payload_size;
 			return 0;
@@ -438,11 +411,10 @@
 	return 0;
 
  failed:
-	spin_unlock_irqrestore(&ieee->lock, flags);
 	netif_stop_queue(dev);
 	stats->tx_errors++;
+	wireless_put(ieee);
 	return 1;
-
 }
 
 EXPORT_SYMBOL(ieee80211_txb_free);
diff -Nru a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.c
--- a/net/ieee80211/ieee80211_wx.c	2005-03-02 15:00:13 +08:00
+++ b/net/ieee80211/ieee80211_wx.c	2005-03-02 15:00:13 +08:00
@@ -220,8 +220,7 @@
 
 	IEEE80211_DEBUG_WX("Getting scan\n");
 
-	spin_lock_irqsave(&ieee->lock, flags);
-
+	spin_lock_irqsave(&ieee->network_lock, flags);
 	list_for_each_entry(network, &ieee->network_list, list) {
 		i++;
 		if (ieee->scan_age == 0 ||
@@ -236,8 +235,7 @@
 				MAC_ARG(network->bssid),
 				(jiffies - network->last_scanned) / (HZ / 100));
 	}
-
-	spin_unlock_irqrestore(&ieee->lock, flags);
+	spin_unlock_irqrestore(&ieee->network_lock, flags);
 
 	wrqu->data.length = ev -  extra;
 	wrqu->data.flags = 0;
@@ -401,8 +399,8 @@
 	sec.flags |= SEC_LEVEL;
 	sec.level = SEC_LEVEL_1; /* 40 and 104 bit WEP */
 
-	if (ieee->set_security)
-		ieee->set_security(dev, &sec);
+	if (ieee->ops->set_security)
+		ieee->ops->set_security(dev, &sec);
 
 	/* Do not reset port if card is in Managed mode since resetting will
 	 * generate new IEEE 802.11 authentication which may end up in looping
@@ -411,7 +409,7 @@
 	 * the callbacks structures used to initialize the 802.11 stack. */
 	if (ieee->reset_on_keychange &&
 	    ieee->iw_mode != IW_MODE_INFRA &&
-	    ieee->reset_port && ieee->reset_port(dev)) {
+	    ieee->ops->reset_port && ieee->ops->reset_port(dev)) {
 		printk(KERN_DEBUG "%s: reset_port failed\n", dev->name);
 		return -EINVAL;
 	}
