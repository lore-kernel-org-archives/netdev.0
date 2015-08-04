From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: dsa: fix EDSA frame from hwaccel frame
Date: Tue,  4 Aug 2015 02:35:11 -0400
Message-ID: <1438670111-31051-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:63805 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbbHDGgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 02:36:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the underlying network device features NETIF_F_HW_VLAN_CTAG_TX,
an EDSA frame is prepended with a 802.1q header once queued.

To fix this, push the VLAN tag to the payload if present, before
checking the frame protocol.

[note: we may prefer to access directly VLAN TCI from hwaccel frames,
but this approach is simpler.]

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/tag_edsa.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 2288c80..3ada4eb 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/list.h>
 #include <linux/slab.h>
 #include "dsa_priv.h"
@@ -21,6 +22,10 @@ static struct sk_buff *edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	u8 *edsa_header;
 
+	skb = vlan_hwaccel_push_inside(skb);
+	if (unlikely(!skb))
+		return NULL;
+
 	/*
 	 * Convert the outermost 802.1q tag to a DSA tag and prepend
 	 * a DSA ethertype field is the packet is tagged, or insert
-- 
2.4.6
