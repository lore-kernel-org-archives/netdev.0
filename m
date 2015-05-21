From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 2/6] IB/mlx4: Convert slave port before building address-handle
Date: Thu, 21 May 2015 15:14:06 +0300
Message-ID: <1432210450-23408-3-git-send-email-ogerlitz@mellanox.com>
References: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:56565 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754489AbbEUMOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 08:14:40 -0400
In-Reply-To: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When multiplexling a MAD sent from VF, we should convert the port used
by the guest to send the packet to the actual physical port which will be
used to transmit the packet, before building the relevant address-handle (AH).

This is needed under VPI for single ported VFs, since the code that builds
the AH (mlx4_ib_query_ah()) makes decisions based on the input port. If we
use the port number provided by the guest, it might have different protocol
vs. the one this packat has to go from, and hence the result could be wrong.

So far, the conversion was done after the AH was built and it worked for
single ported Eth VFs which were not enabled under VPI. When adding support
for single ported IB VFs and VPI, we hit that.

Fixes: 449fc48866f7 ('net/mlx4: Adapt code for N-Port VF')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx4/mad.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index 9cd2b00..ad6a881 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -1365,14 +1365,17 @@ static void mlx4_ib_multiplex_mad(struct mlx4_ib_demux_pv_ctx *ctx, struct ib_wc
 	 * stadard address handle by decoding the tunnelled mlx4_ah fields */
 	memcpy(&ah.av, &tunnel->hdr.av, sizeof (struct mlx4_av));
 	ah.ibah.device = ctx->ib_dev;
+
+	port = be32_to_cpu(ah.av.ib.port_pd) >> 24;
+	port = mlx4_slave_convert_port(dev->dev, slave, port);
+	if (port < 0)
+		return;
+	ah.av.ib.port_pd = cpu_to_be32(port << 24 | (be32_to_cpu(ah.av.ib.port_pd) & 0xffffff));
+
 	mlx4_ib_query_ah(&ah.ibah, &ah_attr);
 	if (ah_attr.ah_flags & IB_AH_GRH)
 		fill_in_real_sgid_index(dev, slave, ctx->port, &ah_attr);
 
-	port = mlx4_slave_convert_port(dev->dev, slave, ah_attr.port_num);
-	if (port < 0)
-		return;
-	ah_attr.port_num = port;
 	memcpy(ah_attr.dmac, tunnel->hdr.mac, 6);
 	ah_attr.vlan_id = be16_to_cpu(tunnel->hdr.vlan);
 	/* if slave have default vlan use it */
-- 
1.7.1
