From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v2 3/4] xen-netback: use a random MAC address
Date: Fri, 14 Feb 2014 18:59:39 -0800
Message-ID: <1392433180-16052-4-git-send-email-mcgrof@do-not-panic.com>
References: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
Cc: xen-devel@lists.xenproject.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392433180-16052-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

The purpose of using a static MAC address of FE:FF:FF:FF:FF:FF
was to prevent our backend interfaces from being used by the
bridge and nominating our interface as a root bridge. This was
possible given that the bridge code will use the lowest MAC
address for a port once a new interface gets added to the bridge.
The bridge code has a generic feature now to allow interfaces
to opt out from root bridge nominations, use that instead.

Cc: Paul Durrant <Paul.Durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: xen-devel@lists.xenproject.org
Cc: netdev@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 drivers/net/xen-netback/interface.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index fff8cdd..d380e3f 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -42,6 +42,8 @@
 #define XENVIF_QUEUE_LENGTH 32
 #define XENVIF_NAPI_WEIGHT  64
 
+static const u8 xen_oui[3] = { 0x00, 0x16, 0x3e };
+
 int xenvif_schedulable(struct xenvif *vif)
 {
 	return netif_running(vif->dev) && netif_carrier_ok(vif->dev);
@@ -347,15 +349,9 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	for (i = 0; i < MAX_PENDING_REQS; i++)
 		vif->mmap_pages[i] = NULL;
 
-	/*
-	 * Initialise a dummy MAC address. We choose the numerically
-	 * largest non-broadcast address to prevent the address getting
-	 * stolen by an Ethernet bridge for STP purposes.
-	 * (FE:FF:FF:FF:FF:FF)
-	 */
-	memset(dev->dev_addr, 0xFF, ETH_ALEN);
-	dev->dev_addr[0] &= ~0x01;
-
+	eth_hw_addr_random(dev);
+	memcpy(dev->dev_addr, xen_oui, 3);
+	dev->priv_flags |= IFF_BRIDGE_NON_ROOT;
 	netif_napi_add(dev, &vif->napi, xenvif_poll, XENVIF_NAPI_WEIGHT);
 
 	netif_carrier_off(dev);
-- 
1.8.5.2
