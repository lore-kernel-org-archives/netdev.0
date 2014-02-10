From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFC 2/2] xen-netback: disable multicast and use a random hw MAC address
Date: Mon, 10 Feb 2014 14:29:51 -0800
Message-ID: <1392071391-13215-3-git-send-email-mcgrof@do-not-panic.com>
References: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
Cc: xen-devel@lists.xenproject.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39419 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbaBJWaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 17:30:16 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so6643568pde.6
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 14:30:15 -0800 (PST)
In-Reply-To: <1392071391-13215-1-git-send-email-mcgrof@do-not-panic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Although the xen-netback interfaces do not participate in the
link as a typical Ethernet device interfaces for them are
still required under the current archtitecture. IPv6 addresses
do not need to be created or assigned on the xen-netback interfaces
however, even if the frontend devices do need them, so clear the
multicast flag to ensure the net core does not initiate IPv6
Stateless Address Autoconfiguration. Clearing the multicast
flag is required given that the net_device is using the
ether_setup() helper.

There's also no good reason why the special MAC address of
FE:FF:FF:FF:FF:FF is being used other than to avoid issues
with STP, since using this can create an issue if a user
decides to enable multicast on the backend interfaces simply
use a random MAC address with the xen OUI prefix as is done
with the frontend through xen udev scripts.

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
index b9de31e..479fbd1 100644
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
+	dev->flags &= ~IFF_MULTICAST;
 	netif_napi_add(dev, &vif->napi, xenvif_poll, XENVIF_NAPI_WEIGHT);
 
 	netif_carrier_off(dev);
-- 
1.8.5.3
