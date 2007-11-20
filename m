From: David Miller <davem@davemloft.net>
Subject: ZD1211RW unaligned accesses...
Date: Tue, 20 Nov 2007 04:05:46 -0800 (PST)
Message-ID: <20071120.040546.222294375.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shaddy_baddah@hotmail.com
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35751
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754231AbXKTMFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 07:05:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The problem is drivers/net/wireless/zd1211/zd_mac.c:update_qual_rssi().
Specifically the compare_ether_addr() call.  Now, ieee80211_hdr_3addr
is marked with attribute((unaligned)) but compare_ether_addr() does
not know that and does "u16 *" dereferences in the optimized
comparison.

Shaddy I attach a hack patch that you can use which should get
rid of the warnings.

Wireless folks, I would suggest we do some auditing of the
compare_ether_addr() calls and for the ones that are operating
on these potentially unaligned structs we change it to either
a straight memcmp() or some new routine which will more reflect
the issue (say something like "compare_ether_addr_unaligned()"
or "ieee80211_compare_ether_addr()").

diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index a903645..4999869 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1047,8 +1047,13 @@ static void update_qual_rssi(struct zd_mac *mac,
 	hdr = (struct ieee80211_hdr_3addr *)buffer;
 	if (length < offsetof(struct ieee80211_hdr_3addr, addr3))
 		return;
+#if 1
+	if (memcmp(hdr->addr2, zd_mac_to_ieee80211(mac)->bssid, ETH_ALEN))
+		return;
+#else
 	if (compare_ether_addr(hdr->addr2, zd_mac_to_ieee80211(mac)->bssid) != 0)
 		return;
+#endif
 
 	spin_lock_irqsave(&mac->lock, flags);
 	i = mac->stats_count % ZD_MAC_STATS_BUFFER_SIZE;
