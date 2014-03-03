From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC v3 5/6] xen-netback: use a random MAC address and force bridge root block
Date: Mon,  3 Mar 2014 14:47:04 -0800
Message-ID: <1393886825-24323-6-git-send-email-mcgrof@do-not-panic.com>
References: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xen-devel@lists.xenproject.org, mcgrof@suse.com,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

The purpose of using a static MAC address of FE:FF:FF:FF:FF:FF
was to prevent our backend interfaces from being used by the
bridge and nominating our interface as a root port on the bridge.
This was possible given that the bridge code will use the lowest MAC
address for a port once a new interface gets added to the bridge.

Sticking to a static MAC address is undesirable for a few reasons:

  a) using a static MAC address by default on all interfaces can
     lead to possible conflicts with IPv6 SLAAC and DAD

  b) The bridge code has a generic bridge port 'root block' feature
     to allow interfaces to opt out from root bridge port nominations.
     We want to help stop spreading the use of a high MAC address
     as a hack to do root port block, and instead get folks to
     use the proper APIs for this.

This modifies xen-netback to use a random MAC address with the xen OUI
prefix and enables the bridge root block feature since initialization.
Although toggling the root block feature requires the iproute2 bridge
tool [0] or sysfs [1] xen-netback users would only need to toggle this
off in the case that the net_device is required to be a candidate for
root port nomination on the bridge. This is an acceptable compromise
in order to avoid the possible conflicts with IPv6 SLAAC and DAD.

[0] bridge link set dev vif2.0 root_block off
[1] echo 1 > /sys/devices/vif-2-0/net/vif2.0/brport/root_block

Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: bridge@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
Cc: kvm@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 drivers/net/xen-netback/interface.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 7669d49..79d71ec 100644
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
@@ -346,15 +348,9 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
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
+	dev->priv_flags |= IFF_BRIDGE_ROOT_BLOCK;
 	netif_napi_add(dev, &vif->napi, xenvif_poll, XENVIF_NAPI_WEIGHT);
 
 	netif_carrier_off(dev);
-- 
1.9.0

