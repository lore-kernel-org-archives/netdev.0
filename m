From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: net/eth/ibmveth: Fixup retrieval of MAC address
Date: Thu, 02 May 2013 11:35:20 +1000
Message-ID: <1367458520.4389.6.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	David Gibson <dwg@au1.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48557 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759114Ab3EBBfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 21:35:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some ancient pHyp versions used to create a 8 bytes local-mac-address
property in the device-tree instead of a 6 bytes one for veth.

The Linux driver code to deal with that is an insane hack which also
happens to break with some choices of MAC addresses in qemu by testing
for a bit in the address rather than just looking at the size of the
property.

Sanitize this by doing the latter instead.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: <stable@vger.kernel.org>
---

I CC'ed stable bcs I'd like to switch qemu/kvm to 6-bytes properties as
soon as possible. Unfortunately doing so breaks the horrible hack unless
qemu has the right magic bit in the MAC which it may or may not have...

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index c859771..579a03e 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1324,7 +1324,7 @@ static const struct net_device_ops ibmveth_netdev_ops = {
 
 static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 {
-	int rc, i;
+	int rc, i, mac_len;
 	struct net_device *netdev;
 	struct ibmveth_adapter *adapter;
 	unsigned char *mac_addr_p;
@@ -1334,11 +1334,19 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 		dev->unit_address);
 
 	mac_addr_p = (unsigned char *)vio_get_attribute(dev, VETH_MAC_ADDR,
-							NULL);
+							&mac_len);
 	if (!mac_addr_p) {
 		dev_err(&dev->dev, "Can't find VETH_MAC_ADDR attribute\n");
 		return -EINVAL;
 	}
+	/* Workaround for old/broken pHyp */
+	if (mac_len == 8)
+		mac_addr_p += 2;
+	if (mac_len != 6) {
+		dev_err(&dev->dev, "VETH_MAC_ADDR attribute wrong len %d\n",
+			mac_len);
+		return -EINVAL;
+	}
 
 	mcastFilterSize_p = (unsigned int *)vio_get_attribute(dev,
 						VETH_MCAST_FILTER_SIZE, NULL);
@@ -1363,17 +1371,6 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 
 	netif_napi_add(netdev, &adapter->napi, ibmveth_poll, 16);
 
-	/*
-	 * Some older boxes running PHYP non-natively have an OF that returns
-	 * a 8-byte local-mac-address field (and the first 2 bytes have to be
-	 * ignored) while newer boxes' OF return a 6-byte field. Note that
-	 * IEEE 1275 specifies that local-mac-address must be a 6-byte field.
-	 * The RPA doc specifies that the first byte must be 10b, so we'll
-	 * just look for it to solve this 8 vs. 6 byte field issue
-	 */
-	if ((*mac_addr_p & 0x3) != 0x02)
-		mac_addr_p += 2;
-
 	adapter->mac_addr = 0;
 	memcpy(&adapter->mac_addr, mac_addr_p, 6);
 
