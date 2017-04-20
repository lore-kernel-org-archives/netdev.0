From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH net] mac80211: reject ToDS broadcast data frames
Date: Thu, 20 Apr 2017 21:32:16 +0200
Message-ID: <20170420193216.17087-1-johannes@sipsolutions.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

AP/AP_VLAN modes don't accept any real 802.11 multicast data
frames, but since they do need to accept broadcast management
frames the same is currently permitted for data frames. This
opens a security problem because such frames would be decrypted
with the GTK, and could even contain unicast L3 frames.

Since the spec says that ToDS frames must always have the BSSID
as the RA (addr1), reject any other data frames.

The problem was originally reported in "Predicting, Decrypting,
and Abusing WPA2/802.11 Group Keys" at usenix
https://www.usenix.org/conference/usenixsecurity16/technical-sessions/presentation/vanhoef
and brought to my attention by Jouni.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reported-by: Jouni Malinen <j@w1.fi>
Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
--
Dave, I didn't want to send you a new pull request for a single
commit yet again - can you apply this one patch as is?
---
 net/mac80211/rx.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 4b12c70c85f0..4d7543d1a62c 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -3639,6 +3639,27 @@ static bool ieee80211_accept_frame(struct ieee80211_rx_data *rx)
 			    !ether_addr_equal(bssid, hdr->addr1))
 				return false;
 		}
+
+		/*
+		 * 802.11-2016 Table 9-26 says that for data frames, A1 must be
+		 * the BSSID - we've checked that already but may have accepted
+		 * the wildcard (ff:ff:ff:ff:ff:ff).
+		 *
+		 * It also says:
+		 *	The BSSID of the Data frame is determined as follows:
+		 *	a) If the STA is contained within an AP or is associated
+		 *	   with an AP, the BSSID is the address currently in use
+		 *	   by the STA contained in the AP.
+		 *
+		 * So we should not accept data frames with an address that's
+		 * multicast.
+		 *
+		 * Accepting it also opens a security problem because stations
+		 * could encrypt it with the GTK and inject traffic that way.
+		 */
+		if (ieee80211_is_data(hdr->frame_control) && multicast)
+			return false;
+
 		return true;
 	case NL80211_IFTYPE_WDS:
 		if (bssid || !ieee80211_is_data(hdr->frame_control))
-- 
2.11.0
