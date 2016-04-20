From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 3/3] net: Add support for IP ID mangling TSO in
 cases that require encapsulation
Date: Wed, 20 Apr 2016 10:49:18 -0400
Message-ID: <20160420144918.3100.8621.stgit@ahduyck-xeon-server>
References: <20160420144720.3100.74116.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33516 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754431AbcDTOt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 10:49:28 -0400
Received: by mail-pf0-f174.google.com with SMTP id 184so19215086pff.0
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 07:49:28 -0700 (PDT)
In-Reply-To: <20160420144720.3100.74116.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for NETIF_F_TSO_MANGLEID if a given tunnel supports
NETIF_F_TSO.  This way if needed a device can then later enable the TSO
with IP ID mangling and the tunnels on top of that device can then also
make use of the IP ID mangling as well.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/dev.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 52d446b2cb99..6324bc9267f7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7029,8 +7029,19 @@ int register_netdevice(struct net_device *dev)
 	if (!(dev->flags & IFF_LOOPBACK))
 		dev->hw_features |= NETIF_F_NOCACHE_COPY;
 
+	/* If IPv4 TCP segmentation offload is supported we should also
+	 * allow the device to enable segmenting the frame with the option
+	 * of ignoring a static IP ID value.  This doesn't enable the
+	 * feature itself but allows the user to enable it later.
+	 */
 	if (dev->hw_features & NETIF_F_TSO)
 		dev->hw_features |= NETIF_F_TSO_MANGLEID;
+	if (dev->vlan_features & NETIF_F_TSO)
+		dev->vlan_features |= NETIF_F_TSO_MANGLEID;
+	if (dev->mpls_features & NETIF_F_TSO)
+		dev->mpls_features |= NETIF_F_TSO_MANGLEID;
+	if (dev->hw_enc_features & NETIF_F_TSO)
+		dev->hw_enc_features |= NETIF_F_TSO_MANGLEID;
 
 	/* Make NETIF_F_HIGHDMA inheritable to VLAN devices.
 	 */
