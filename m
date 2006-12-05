From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 2/5] ipw2200: Add IEEE80211_RADIOTAP_TSFT for promiscuous mode
Date: Tue, 5 Dec 2006 14:42:14 +0800
Message-ID: <20061205064214.GA18328@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14646 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759421AbWLEHJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 02:09:52 -0500
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ipw2200 BSS firmware passes on the TSF information within ipw_rx_frame,
but monitor firmware doesn't. I add back the IEEE80211_RADIOTAP_TSFT flags
so that we can get the MAC timestamp if we use the rtap interface. We will
see the MAC timestamp equals to zero if we capture the packets with a
monitor mode interface. But this is the expected behaviour.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

25bc0563ab6d6c5f64b92d944b85a08af1c84beb
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index a60714e..980758c 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -7656,7 +7656,8 @@ static void ipw_handle_data_packet_monit
 
 	/* Big bitfield of all the fields we provide in radiotap */
 	ipw_rt->rt_hdr.it_present =
-	    ((1 << IEEE80211_RADIOTAP_FLAGS) |
+	    ((1 << IEEE80211_RADIOTAP_TSFT) |
+	     (1 << IEEE80211_RADIOTAP_FLAGS) |
 	     (1 << IEEE80211_RADIOTAP_RATE) |
 	     (1 << IEEE80211_RADIOTAP_CHANNEL) |
 	     (1 << IEEE80211_RADIOTAP_DBM_ANTSIGNAL) |
@@ -7665,10 +7666,14 @@ static void ipw_handle_data_packet_monit
 
 	/* Zero the flags, we'll add to them as we go */
 	ipw_rt->rt_flags = 0;
-	ipw_rt->rt_tsf = 0ULL;
+	ipw_rt->rt_tsf = (u64)(frame->parent_tsf[3] << 24 |
+			       frame->parent_tsf[2] << 16 |
+			       frame->parent_tsf[1] << 8  |
+			       frame->parent_tsf[0]);
 
 	/* Convert signal to DBM */
 	ipw_rt->rt_dbmsignal = antsignal;
+	ipw_rt->rt_dbmnoise = frame->noise;
 
 	/* Convert the channel data and set the flags */
 	ipw_rt->rt_channel = cpu_to_le16(ieee80211chan2mhz(received_channel));
@@ -7868,7 +7873,8 @@ static void ipw_handle_promiscuous_rx(st
 
 	/* Big bitfield of all the fields we provide in radiotap */
 	ipw_rt->rt_hdr.it_present =
-	    ((1 << IEEE80211_RADIOTAP_FLAGS) |
+	    ((1 << IEEE80211_RADIOTAP_TSFT) |
+	     (1 << IEEE80211_RADIOTAP_FLAGS) |
 	     (1 << IEEE80211_RADIOTAP_RATE) |
 	     (1 << IEEE80211_RADIOTAP_CHANNEL) |
 	     (1 << IEEE80211_RADIOTAP_DBM_ANTSIGNAL) |
@@ -7877,7 +7883,10 @@ static void ipw_handle_promiscuous_rx(st
 
 	/* Zero the flags, we'll add to them as we go */
 	ipw_rt->rt_flags = 0;
-	ipw_rt->rt_tsf = 0ULL;
+	ipw_rt->rt_tsf = (u64)(frame->parent_tsf[3] << 24 |
+			       frame->parent_tsf[2] << 16 |
+			       frame->parent_tsf[1] << 8  |
+			       frame->parent_tsf[0]);
 
 	/* Convert to DBM */
 	ipw_rt->rt_dbmsignal = signal;
-- 
1.2.6
