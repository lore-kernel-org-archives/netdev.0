From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] d80211: respect extra_tx_headroom
Date: Tue, 6 Feb 2007 00:47:13 +0100
Message-ID: <200702060047.13500.IvDoorn@gmail.com>
References: <200702051632.24949.IvDoorn@gmail.com> <20070205223724.51398750@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070205223724.51398750-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 22:37, Jiri Benc wrote:
> On Mon, 5 Feb 2007 16:32:24 +0100, Ivo van Doorn wrote:
> > When a driver requested additional header room
> > through the extra_tx_headroom field, the stack
> > should respect that and make sure that all frames
> > that are being send to the stack actually have
> > that extra header room.
> > 
> > [...]
> > --- dscape/net/d80211/ieee80211_sta.c	2007-02-05 16:18:41.000000000 +0100
> > [...]
> > @@ -2007,6 +2017,8 @@
> >  		if (!skb)
> >  			break;
> >  
> > +		skb_reserve(skb, local->hw.extra_tx_headroom);
> > +
> >  		mgmt = (struct ieee80211_mgmt *)
> >  			skb_put(skb, 24 + sizeof(mgmt->u.beacon));
> >  		memset(mgmt, 0, 24 + sizeof(mgmt->u.beacon));
> 
> Please enlarge that dev_alloc_skb(400) few lines above by
> extra_tx_headroom as well.

Ok.

> Btw, it would be nice if you could use -p option for diff as it makes
> reviewing easier for me.

Not a problem, I'll try to remember it for future patches.

Here is the updated patch.


When a driver requested additional header room
through the extra_tx_headroom field, the stack
should respect that and make sure that all frames
that are being send to the stack actually have
that extra header room.
Besides the additional bytes for the beacon template, this patch
is no longer depends on the rts patch to be applied.

Signed-off-by Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

---

diff -rpU3 dscape.control/net/d80211/ieee80211.c dscape.skb/net/d80211/ieee80211.c
--- dscape.control/net/d80211/ieee80211.c	2007-02-06 00:25:26.000000000 +0100
+++ dscape.skb/net/d80211/ieee80211.c	2007-02-06 00:39:07.000000000 +0100
@@ -470,10 +470,9 @@ ieee80211_tx_h_fragment(struct ieee80211
 
 		/* reserve enough extra head and tail room for possible
 		 * encryption */
-#define IEEE80211_ENCRYPT_HEADROOM 8
-#define IEEE80211_ENCRYPT_TAILROOM 12
 		frag = frags[i] =
-			dev_alloc_skb(frag_threshold +
+			dev_alloc_skb(tx->local->hw.extra_tx_headroom +
+				      frag_threshold +
 				      IEEE80211_ENCRYPT_HEADROOM +
 				      IEEE80211_ENCRYPT_TAILROOM);
 		if (!frag)
@@ -481,7 +480,8 @@ ieee80211_tx_h_fragment(struct ieee80211
 		/* Make sure that all fragments use the same priority so
 		 * that they end up using the same TX queue */
 		frag->priority = first->priority;
-		skb_reserve(frag, IEEE80211_ENCRYPT_HEADROOM);
+		skb_reserve(frag, tx->local->hw.extra_tx_headroom +
+			IEEE80211_ENCRYPT_HEADROOM);
 		fhdr = (struct ieee80211_hdr *) skb_put(frag, hdrlen);
 		memcpy(fhdr, first->data, hdrlen);
 		if (i == num_fragm - 2)
@@ -1362,6 +1362,7 @@ static int ieee80211_master_start_xmit(s
 	struct ieee80211_tx_packet_data *pkt_data;
 	struct net_device *odev = NULL;
 	struct ieee80211_sub_if_data *osdata;
+	int headroom;
 	int ret;
 
 	/*
@@ -1386,6 +1387,15 @@ static int ieee80211_master_start_xmit(s
 	}
 	osdata = IEEE80211_DEV_TO_SUB_IF(odev);
 
+	headroom = osdata->local->hw.extra_tx_headroom +
+		IEEE80211_ENCRYPT_HEADROOM;
+	if (skb_headroom(skb) < headroom) {
+		if (pskb_expand_head(skb, headroom, 0, GFP_ATOMIC)) {
+			dev_kfree_skb(skb);
+			return 0;
+		}
+	}
+
 	control.ifindex = odev->ifindex;
 	control.type = osdata->type;
 	if (pkt_data->req_tx_status)
@@ -1615,6 +1625,14 @@ ieee80211_mgmt_start_xmit(struct sk_buff
 		return 0;
 	}
 
+	if (skb_headroom(skb) < sdata->local->hw.extra_tx_headroom) {
+		if (pskb_expand_head(skb,
+		    sdata->local->hw.extra_tx_headroom, 0, GFP_ATOMIC)) {
+			dev_kfree_skb(skb);
+			return 0;
+		}
+	}
+
 	hdr = (struct ieee80211_hdr *) skb->data;
 	fc = le16_to_cpu(hdr->frame_control);
 
@@ -1748,10 +1766,12 @@ struct sk_buff * ieee80211_beacon_get(st
 	bh_len = ap->beacon_head_len;
 	bt_len = ap->beacon_tail_len;
 
-	skb = dev_alloc_skb(bh_len + bt_len + 256 /* maximum TIM len */);
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
+		bh_len + bt_len + 256 /* maximum TIM len */);
 	if (!skb)
 		return NULL;
 
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 	memcpy(skb_put(skb, bh_len), b_head, bh_len);
 
 	ieee80211_beacon_add_tim(local, ap, skb);
diff -rpU3 dscape.control/net/d80211/ieee80211_i.h dscape.skb/net/d80211/ieee80211_i.h
--- dscape.control/net/d80211/ieee80211_i.h	2007-02-06 00:19:38.000000000 +0100
+++ dscape.skb/net/d80211/ieee80211_i.h	2007-02-06 00:39:28.000000000 +0100
@@ -49,6 +49,9 @@ struct ieee80211_local;
  * frame can be up to about 2 kB long. */
 #define TOTAL_MAX_TX_BUFFER 512
 
+/* Required encryption head and tailroom */
+#define IEEE80211_ENCRYPT_HEADROOM 8
+#define IEEE80211_ENCRYPT_TAILROOM 12
 
 /* IEEE 802.11 (Ch. 9.5 Defragmentation) requires support for concurrent
  * reception of at least three fragmented frames. This limit can be increased
diff -rpU3 dscape.control/net/d80211/ieee80211_scan.c dscape.skb/net/d80211/ieee80211_scan.c
--- dscape.control/net/d80211/ieee80211_scan.c	2007-02-06 00:19:38.000000000 +0100
+++ dscape.skb/net/d80211/ieee80211_scan.c	2007-02-06 00:39:56.000000000 +0100
@@ -280,7 +280,7 @@ void ieee80211_init_scan(struct ieee8021
 {
 	struct ieee80211_hdr hdr;
 	u16 fc;
-	int len = 10;
+	int len = 10 + local->hw.extra_tx_headroom;
 	struct rate_control_extra extra;
 
 	/* Only initialize passive scanning if the hardware supports it */
@@ -309,6 +309,7 @@ void ieee80211_init_scan(struct ieee8021
 		       "passive scan\n", local->mdev->name);
 		return;
 	}
+	skb_reserve(local->scan.skb, local->hw.extra_tx_headroom);
 
 	fc = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_CTS;
 	hdr.frame_control = cpu_to_le16(fc);
diff -rpU3 dscape.control/net/d80211/ieee80211_sta.c dscape.skb/net/d80211/ieee80211_sta.c
--- dscape.control/net/d80211/ieee80211_sta.c	2007-02-06 00:19:38.000000000 +0100
+++ dscape.skb/net/d80211/ieee80211_sta.c	2007-02-06 00:42:06.000000000 +0100
@@ -415,15 +415,18 @@ static void ieee80211_send_auth(struct n
 				int transaction, u8 *extra, size_t extra_len,
 				int encrypt)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 
-	skb = dev_alloc_skb(sizeof(*mgmt) + 6 + extra_len);
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
+			    sizeof(*mgmt) + 6 + extra_len);
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for auth "
 		       "frame\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24 + 6);
 	memset(mgmt, 0, 24 + 6);
@@ -478,13 +481,15 @@ static void ieee80211_send_assoc(struct 
 	struct ieee80211_sta_bss *bss;
 	int wmm = 0;
 
-	skb = dev_alloc_skb(sizeof(*mgmt) + 200 + ifsta->extra_ie_len +
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom +
+			    sizeof(*mgmt) + 200 + ifsta->extra_ie_len +
 			    ifsta->ssid_len);
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for assoc "
 		       "frame\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	capab = ifsta->capab;
 	if (local->hw.conf.phymode == MODE_IEEE80211G) {
@@ -585,15 +590,17 @@ static void ieee80211_send_assoc(struct 
 static void ieee80211_send_deauth(struct net_device *dev,
 				  struct ieee80211_if_sta *ifsta, u16 reason)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 
-	skb = dev_alloc_skb(sizeof(*mgmt));
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*mgmt));
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for deauth "
 		       "frame\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
 	memset(mgmt, 0, 24);
@@ -612,15 +619,17 @@ static void ieee80211_send_deauth(struct
 static void ieee80211_send_disassoc(struct net_device *dev,
 				    struct ieee80211_if_sta *ifsta, u16 reason)
 {
+	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 	struct ieee80211_mgmt *mgmt;
 
-	skb = dev_alloc_skb(sizeof(*mgmt));
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*mgmt));
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for disassoc "
 		       "frame\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
 	memset(mgmt, 0, 24);
@@ -758,12 +767,13 @@ static void ieee80211_send_probe_req(str
 	u8 *pos, *supp_rates, *esupp_rates = NULL;
 	int i;
 
-	skb = dev_alloc_skb(sizeof(*mgmt) + 200);
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom + sizeof(*mgmt) + 200);
 	if (!skb) {
 		printk(KERN_DEBUG "%s: failed to allocate buffer for probe "
 		       "request\n", dev->name);
 		return;
 	}
+	skb_reserve(skb, local->hw.extra_tx_headroom);
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
 	memset(mgmt, 0, 24);
@@ -2002,11 +2012,13 @@ static int ieee80211_sta_join_ibss(struc
 	}
 
 	/* Set beacon template based on scan results */
-	skb = dev_alloc_skb(400);
+	skb = dev_alloc_skb(local->hw.extra_tx_headroom + 400);
 	do {
 		if (!skb)
 			break;
 
+		skb_reserve(skb, local->hw.extra_tx_headroom);
+
 		mgmt = (struct ieee80211_mgmt *)
 			skb_put(skb, 24 + sizeof(mgmt->u.beacon));
 		memset(mgmt, 0, 24 + sizeof(mgmt->u.beacon));
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
