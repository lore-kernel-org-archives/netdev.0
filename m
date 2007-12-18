From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] mac80211: warn when receiving frames with unaligned data
Date: Tue, 18 Dec 2007 15:11:35 +0100
Message-ID: <1197987095.4885.159.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch makes mac80211 warn (once) when the driver passes up a
frame in which the payload data is not aligned on a four-byte
boundary, with a long comment for people who run into the condition
and need to know what to do.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
---
 net/mac80211/rx.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

--- everything.orig/net/mac80211/rx.c	2007-12-18 14:47:18.433014323 +0100
+++ everything/net/mac80211/rx.c	2007-12-18 14:48:47.113014051 +0100
@@ -1619,6 +1619,7 @@ void __ieee80211_rx(struct ieee80211_hw 
 	struct ieee80211_sub_if_data *prev = NULL;
 	struct sk_buff *skb_new;
 	u8 *bssid;
+	int hdrlen;
 
 	/*
 	 * key references and virtual interfaces are protected using RCU
@@ -1648,6 +1649,18 @@ void __ieee80211_rx(struct ieee80211_hw 
 	rx.fc = le16_to_cpu(hdr->frame_control);
 	type = rx.fc & IEEE80211_FCTL_FTYPE;
 
+	/*
+	 * Drivers are required to align the payload data to a four-byte
+	 * boundary, so the last two bits of the address where it starts
+	 * may not be set. The header is required to be directly before
+	 * the payload data, padding like atheros hardware adds which is
+	 * inbetween the 802.11 header and the payload is not supported,
+	 * the driver is required to move the 802.11 header further back
+	 * in that case.
+	 */
+	hdrlen = ieee80211_get_hdrlen(rx.fc);
+	WARN_ON_ONCE(((unsigned long)(skb->data + hdrlen)) & 3);
+
 	if (type == IEEE80211_FTYPE_DATA || type == IEEE80211_FTYPE_MGMT)
 		local->dot11ReceivedFragmentCount++;
 
