From: Jiri Benc <jbenc@suse.cz>
Subject: [9/9] ieee80211: ETH_P_802_11 ethertype
Date: Fri, 3 Jun 2005 18:37:26 +0200
Message-ID: <20050603183726.482a91d2@griffin.suse.cz>
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

Introduced new ETH_P_802_11 ethertype. Fixed ieee80211_type_trans() to
return ETH_P_802_11 in case of non-data frame.


Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Jirka Bohac <jbohac@suse.cz>

Index: netdev/include/linux/if_ether.h
===================================================================
--- netdev.orig/include/linux/if_ether.h	2005-06-01 11:04:59.000000000 +0200
+++ netdev/include/linux/if_ether.h	2005-06-03 13:21:15.000000000 +0200
@@ -92,6 +92,7 @@
 #define ETH_P_ECONET	0x0018		/* Acorn Econet			*/
 #define ETH_P_HDLC	0x0019		/* HDLC frames			*/
 #define ETH_P_ARCNET	0x001A		/* 1A for ArcNet :-)            */
+#define ETH_P_802_11	0x001B		/* 802.11 frames		*/
 
 /*
  *	This is an Ethernet frame header.
Index: netdev/include/net/ieee80211.h
===================================================================
--- netdev.orig/include/net/ieee80211.h	2005-06-03 13:21:10.000000000 +0200
+++ netdev/include/net/ieee80211.h	2005-06-03 13:21:15.000000000 +0200
@@ -232,10 +232,6 @@
 
 #define ETH_P_PREAUTH 0x88C7 /* IEEE 802.11i pre-authentication */
 
-#ifndef ETH_P_80211_RAW
-#define ETH_P_80211_RAW 0x0003
-#endif
-
 /* IEEE 802.11 defines */
 
 #define P80211_OUI_LEN 3
Index: netdev/net/ieee80211/ieee80211_rx.c
===================================================================
--- netdev.orig/net/ieee80211/ieee80211_rx.c	2005-06-03 13:21:00.000000000 +0200
+++ netdev/net/ieee80211/ieee80211_rx.c	2005-06-03 13:21:15.000000000 +0200
@@ -46,7 +46,7 @@
 	skb->mac.raw = skb->data;
 	skb_pull(skb, ieee80211_get_hdrlen(hdr));
 	skb->pkt_type = PACKET_OTHERHOST;
-	skb->protocol = __constant_htons(ETH_P_80211_RAW);
+	skb->protocol = __constant_htons(ETH_P_802_11);
 	memset(skb->cb, 0, sizeof(skb->cb));
 	netif_rx(skb);
 }
@@ -338,22 +338,33 @@
 	int hdrlen;
 	u8 *daddr = IEEE80211_GET_DADDR(hdr);
 	unsigned short type;
+	u16 fc;
 
 	skb->mac.raw = skb->data;
 
-	hdrlen = ieee80211_get_hdrlen(hdr);
-	snap = (struct ieee80211_snap_hdr *)(skb->data + hdrlen);
-	if (snap->dsap == 0xaa && snap->ssap == 0xaa &&
-			((IEEE80211_SNAP_IS_RFC1042(snap) &&
-			  snap->type != __constant_htons(ETH_P_AARP) &&
-			  snap->type != __constant_htons(ETH_P_IPX)) ||
-			 IEEE80211_SNAP_IS_BRIDGE_TUNNEL(snap))) {
-		type = snap->type;
-		skb_pull(skb, hdrlen + SNAP_SIZE);
+	fc = le16_to_cpu(hdr->frame_ctl);
+	if (WLAN_FC_GET_TYPE(fc) == IEEE80211_FTYPE_DATA &&
+			WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_DATA) {
+		hdrlen = __ieee80211_get_hdrlen(fc);
+		snap = (struct ieee80211_snap_hdr *)(skb->data + hdrlen);
+		if (snap->dsap == 0xaa && snap->ssap == 0xaa &&
+				((IEEE80211_SNAP_IS_RFC1042(snap) &&
+				snap->type != __constant_htons(ETH_P_AARP) &&
+				snap->type != __constant_htons(ETH_P_IPX)) ||
+				IEEE80211_SNAP_IS_BRIDGE_TUNNEL(snap))) {
+			type = snap->type;
+			skb_pull(skb, hdrlen + SNAP_SIZE);
+		}
+		else {
+			type = __constant_htons(ETH_P_802_2);
+			skb_pull(skb, hdrlen);
+		}
 	}
 	else {
-		type = __constant_htons(ETH_P_802_2);
-		skb_pull(skb, hdrlen);
+		/* If the type isn't data we want to keep the 802.11 header
+		 * in place.
+		 */
+		type = __constant_htons(ETH_P_802_11);
 	}
 
 	skb->input_dev = ieee->dev;
Index: netdev/net/ieee80211/ieee80211_proto.c
===================================================================
--- netdev.orig/net/ieee80211/ieee80211_proto.c	2005-06-03 13:21:00.000000000 +0200
+++ netdev/net/ieee80211/ieee80211_proto.c	2005-06-03 13:21:15.000000000 +0200
@@ -87,6 +87,8 @@
 	int fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA;
 	int hdr_len = IEEE80211_3ADDR_LEN;
 	
+	if (type == ETH_P_802_11)
+		return 0;
 	if (type != ETH_P_802_3 && type != ETH_P_802_2) {
 		ieee80211_put_snap(skb_push(skb, SNAP_SIZE), type);
 		hdr_len += SNAP_SIZE;


-- 
Jiri Benc
SUSE Labs
