From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 1/2] ipvlan: don't loose broadcast MAC when setting MAC
 filters
Date: Thu, 26 Mar 2015 17:41:38 -0500
Message-ID: <1427409698.18540.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51883 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbbCZWle (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 18:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The broadcast MAC is supposed to be allowed whenever the device
has an IPv4 address, otherwise ARP requests get dropped on the
floor.  If ndo_set_rx_mode (and thus
ipvlan_set_multicast_mac_filter()) gets called after the address
was added, it blows away the broadcast MAC address in
mac_filters that was added at IPv4 address addition.  Fix that.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 4f4099d..d34f580 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -241,6 +241,9 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
 
 		bitmap_copy(ipvlan->mac_filters, mc_filters,
 			    IPVLAN_MAC_FILTER_SIZE);
+
+		if (ipvlan->ipv4cnt)
+			ipvlan_set_broadcast_mac_filter(ipvlan, true);
 	}
 	dev_uc_sync(ipvlan->phy_dev, dev);
 	dev_mc_sync(ipvlan->phy_dev, dev);
-- 
2.1.0
