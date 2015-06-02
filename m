From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 9/9] net: dsa: fix EDSA frame from hwaccel frame
Date: Mon,  1 Jun 2015 21:27:50 -0400
Message-ID: <1433208470-25338-10-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"Scott Feldman" <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"Chris Healy" <cphealy@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index 9aeda59..c1c9548 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/etherdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/list.h>
 #include <linux/slab.h>
 #include "dsa_priv.h"
@@ -24,6 +25,10 @@ static netdev_tx_t edsa_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_packets++;
 	dev->stats.tx_bytes += skb->len;
 
+	skb = vlan_hwaccel_push_inside(skb);
+	if (unlikely(!skb))
+		return -ENOMEM;
+
 	/*
 	 * Convert the outermost 802.1q tag to a DSA tag and prepend
 	 * a DSA ethertype field is the packet is tagged, or insert
-- 
2.4.1
