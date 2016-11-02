From: Filip Matusiak <filip.matusiak@tieto.com>
Subject: [PATCH V2] mac80211: Ignore VHT IE from peer with wrong rx_mcs_map
Date: Wed,  2 Nov 2016 10:04:26 +0100
Message-ID: <1478077466-4308-1-git-send-email-filip.matusiak@tieto.com>
Cc: filip.matusiak@tieto.com, marek.kwaczynski@tieto.com,
        johannes@sipsolutions.net, davem@davemloft.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a workaround for VHT-enabled STAs which break the spec
and have the VHT-MCS Rx map filled in with value 3 for all eight
spacial streams, an example is AR9462 in AP mode.

As per spec, in section 22.1.1 Introduction to the VHT PHY
A VHT STA shall support at least single spactial stream VHT-MCSs
0 to 7 (transmit and receive) in all supported channel widths.

Some devices in STA mode will get firmware assert when trying to
associate, examples are QCA9377 & QCA6174.

Packet example of broken VHT Cap IE of AR9462:

Tag: VHT Capabilities (IEEE Std 802.11ac/D3.1)
    Tag Number: VHT Capabilities (IEEE Std 802.11ac/D3.1) (191)
    Tag length: 12
    VHT Capabilities Info: 0x00000000
    VHT Supported MCS Set
        Rx MCS Map: 0xffff
            .... .... .... ..11 = Rx 1 SS: Not Supported (0x0003)
            .... .... .... 11.. = Rx 2 SS: Not Supported (0x0003)
            .... .... ..11 .... = Rx 3 SS: Not Supported (0x0003)
            .... .... 11.. .... = Rx 4 SS: Not Supported (0x0003)
            .... ..11 .... .... = Rx 5 SS: Not Supported (0x0003)
            .... 11.. .... .... = Rx 6 SS: Not Supported (0x0003)
            ..11 .... .... .... = Rx 7 SS: Not Supported (0x0003)
            11.. .... .... .... = Rx 8 SS: Not Supported (0x0003)
        ...0 0000 0000 0000 = Rx Highest Long GI Data Rate (in Mb/s, 0 = subfield not in use): 0x0000
        Tx MCS Map: 0xffff
        ...0 0000 0000 0000 = Tx Highest Long GI Data Rate  (in Mb/s, 0 = subfield not in use): 0x0000

Signed-off-by: Filip Matusiak <filip.matusiak@tieto.com>
---
 net/mac80211/vht.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/mac80211/vht.c b/net/mac80211/vht.c
index ee71576..6832bf6 100644
--- a/net/mac80211/vht.c
+++ b/net/mac80211/vht.c
@@ -270,6 +270,22 @@ ieee80211_vht_cap_ie_to_sta_vht_cap(struct ieee80211_sub_if_data *sdata,
 		vht_cap->vht_mcs.tx_mcs_map |= cpu_to_le16(peer_tx << i * 2);
 	}
 
+	/*
+	 * This is a workaround for VHT-enabled STAs which break the spec
+	 * and have the VHT-MCS Rx map filled in with value 3 for all eight
+	 * spacial streams, an example is AR9462.
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
