From: Ingo Molnar <mingo@elte.hu>
Subject: net/mac80211/rx.c: fix build error
Date: Mon, 13 Oct 2008 08:41:35 +0200
Message-ID: <20081013064135.GA19719@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Davide Pesavento <davidepesa@gmail.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:43807 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910AbYJMGln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 02:41:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


FYI, the fixlet below is still needed, even after b0dee578 ("Fix modpost 
failure when rx handlers are not inlined."). The build error triggered 
on a -tip testbox.

	Ingo

-------------->
>From da854dfe310ff62fda6866e13bd8588effaee51f Mon Sep 17 00:00:00 2001
From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 13 Oct 2008 08:37:08 +0200
Subject: [PATCH] net/mac80211/rx.c: fix build error

older versions of gcc do not recognize that ieee80211_rx_h_mesh_fwding()
is unused when CONFIG_MAC80211_MESH is disabled:

  net/built-in.o: In function `ieee80211_rx_h_mesh_fwding':
  rx.c:(.text+0xd89af): undefined reference to `mpp_path_lookup'
  rx.c:(.text+0xd89c6): undefined reference to `mpp_path_add'

as this code construct:

        if (ieee80211_vif_is_mesh(&sdata->vif))
                CALL_RXH(ieee80211_rx_h_mesh_fwding);

still causes ieee80211_rx_h_mesh_fwding() to be linked in.

Protect these places with an #ifdef.

commit b0dee578 ("Fix modpost failure when rx handlers are not inlined.")
solved part of this problem - this patch is still needed.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 net/mac80211/rx.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 77e7b01..cf6b121 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1379,6 +1379,7 @@ ieee80211_rx_h_amsdu(struct ieee80211_rx_data *rx)
 	return RX_QUEUED;
 }
 
+#ifdef CONFIG_MAC80211_MESH
 static ieee80211_rx_result
 ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 {
@@ -1453,7 +1454,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *rx)
 	else
 		return RX_DROP_MONITOR;
 }
-
+#endif
 
 static ieee80211_rx_result debug_noinline
 ieee80211_rx_h_data(struct ieee80211_rx_data *rx)
@@ -1780,8 +1781,10 @@ static void ieee80211_invoke_rx_handlers(struct ieee80211_sub_if_data *sdata,
 	/* must be after MMIC verify so header is counted in MPDU mic */
 	CALL_RXH(ieee80211_rx_h_remove_qos_control)
 	CALL_RXH(ieee80211_rx_h_amsdu)
+#ifdef CONFIG_MAC80211_MESH
 	if (ieee80211_vif_is_mesh(&sdata->vif))
 		CALL_RXH(ieee80211_rx_h_mesh_fwding);
+#endif
 	CALL_RXH(ieee80211_rx_h_data)
 	CALL_RXH(ieee80211_rx_h_ctrl)
 	CALL_RXH(ieee80211_rx_h_action)
