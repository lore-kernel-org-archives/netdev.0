From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: Update flags and features settings
Date: Mon, 13 Jun 2016 17:14:12 -0700
Message-ID: <1465863252-17288-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:32924 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161338AbcFNAOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 20:14:31 -0400
Received: by mail-pf0-f175.google.com with SMTP id y124so51079622pfy.0
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 17:14:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Default VRF devices to not having a qdisc (IFF_NO_QUEUE). Users
   can add one as desired.

2. Disable adding a VLAN to a VRF device.

3. Enable offloads and hardware features similar to other logical
   devices (e.g., dummy, veth)

Change provides a significant boost in TCP stream Tx performance,
from ~2,700 Mbps to ~18,100 Mbps and makes throughput close to the
performance without a VRF (18,500 Mbps). netperf TCP_STREAM benchmark
using qemu with virtio+vhost for the NICs

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 0b5b3c258c2b..e3fc6d32a289 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1099,6 +1099,20 @@ static void vrf_setup(struct net_device *dev)
 
 	/* don't allow vrf devices to change network namespaces. */
 	dev->features |= NETIF_F_NETNS_LOCAL;
+
+	/* does not make sense for a VLAN to be added to a vrf device */
+	dev->features   |= NETIF_F_VLAN_CHALLENGED;
+
+	/* enable offload features */
+	dev->features   |= NETIF_F_GSO_SOFTWARE;
+	dev->features   |= NETIF_F_RXCSUM | NETIF_F_HW_CSUM;
+	dev->features   |= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA;
+
+	dev->hw_features = dev->features;
+	dev->hw_enc_features = dev->features;
+
+	/* default to no qdisc; user can add if desired */
+	dev->priv_flags |= IFF_NO_QUEUE;
 }
 
 static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
-- 
2.1.4
