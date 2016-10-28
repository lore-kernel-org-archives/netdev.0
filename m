From: Filip Matusiak <filip.matusiak@tieto.com>
Subject: [PATCH] mac80211: Ignore VHT IE from peer with wrong rx_mcs_map
Date: Fri, 28 Oct 2016 16:38:43 +0200
Message-ID: <1477665523-8970-1-git-send-email-filip.matusiak@tieto.com>
Cc: filip.matusiak@tieto.com, marek.kwaczynski@tieto.com,
        johannes@sipsolutions.net, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a workaround for VHT-enabled STAs which break the spec
and have the VHT-MCS Rx map filled in with value 3 for all eight
spacial streams.

As per spec, in section 22.1.1 Introduction to the VHT PHY
A VHT STA shall support at least single spactial stream VHT-MCSs
0 to 7 (transmit and receive) in all supported channel widths.

For some devices firmware asserts if such situation occurs.

Signed-off-by: Filip Matusiak <filip.matusiak@tieto.com>
---
 net/mac80211/vht.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/mac80211/vht.c b/net/mac80211/vht.c
index ee71576..ce93cff 100644
--- a/net/mac80211/vht.c
+++ b/net/mac80211/vht.c
@@ -270,6 +270,22 @@ ieee80211_vht_cap_ie_to_sta_vht_cap(struct ieee80211_sub_if_data *sdata,
 		vht_cap->vht_mcs.tx_mcs_map |= cpu_to_le16(peer_tx << i * 2);
 	}
 
+	/*
+	 * This is a workaround for VHT-enabled STAs which break the spec
+	 * and have the VHT-MCS Rx map filled in with value 3 for all eight
+	 * spacial streams.
+	 *
+	 * As per spec, in section 22.1.1 Introduction to the VHT PHY
+	 * A VHT STA shall support at least single spactial stream VHT-MCSs
+	 * 0 to 7 (transmit and receive) in all supported channel widths.
+	 */
+	if (vht_cap->vht_mcs.rx_mcs_map == cpu_to_le16(0xFFFF)) {
+		vht_cap->vht_supported = false;
+		sdata_info(sdata, "Ignoring VHT IE from %pM due to invalid rx_mcs_map\n",
+			   sta->addr);
+		return;
+	}
+
 	/* finally set up the bandwidth */
 	switch (vht_cap->cap & IEEE80211_VHT_CAP_SUPP_CHAN_WIDTH_MASK) {
 	case IEEE80211_VHT_CAP_SUPP_CHAN_WIDTH_160MHZ:
-- 
2.7.4
