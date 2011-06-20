From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 04/17] ixgbevf: provide 64 bit statistics
Date: Mon, 20 Jun 2011 17:46:28 +0200
Message-ID: <1308584788.26922.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1308531518-17298-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308531518-17298-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1308545992.3539.114.camel@edumazet-laptop>
	 <1308572991.22851.50.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33438 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045Ab1FTNqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 09:46:42 -0400
Received: by wyb38 with SMTP id 38so1663991wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 06:46:41 -0700 (PDT)
In-Reply-To: <1308572991.22851.50.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 05:29 -0700, Jeff Kirsher a =C3=A9crit :

> I will drop Stephen's patch from this series and look forward to your
> fixes.  Thanks Eric.
>=20
>=20

Here is an updated patch :

[PATCH net-next] ixgbevf: provide 64 bit statistics

Compute statistics per ring using 64 bits, and provide
network device stats in 64 bits.

It should make this driver multiqueue operations faster (no more cache
line ping pongs on netdev->stats structure)

Use u64_stats_sync infrastructure so that its safe on 32bit arches as
well.

Based on a prior patch from Stephen Hemminger

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/ixgbevf/ixgbevf.h      |    8 ++--
 drivers/net/ixgbevf/ixgbevf_main.c |   52 ++++++++++++++++++++++-----
 2 files changed, 48 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ixgbevf/ixgbev=
f.h
index b703f60..162cff1 100644
--- a/drivers/net/ixgbevf/ixgbevf.h
+++ b/drivers/net/ixgbevf/ixgbevf.h
@@ -32,6 +32,7 @@
 #include <linux/timer.h>
 #include <linux/io.h>
 #include <linux/netdevice.h>
+#include <linux/u64_stats_sync.h>
=20
 #include "vf.h"
=20
@@ -69,12 +70,13 @@ struct ixgbevf_ring {
 		struct ixgbevf_rx_buffer *rx_buffer_info;
 	};
=20
+	u64			total_bytes;
+	u64			total_packets;
+	struct u64_stats_sync	syncp;
+
 	u16 head;
 	u16 tail;
=20
-	unsigned int total_bytes;
-	unsigned int total_packets;
-
 	u16 reg_idx; /* holds the special value that gets the hardware regist=
er
 		      * offset associated with this ring, which is different
 		      * for DCB and RSS modes */
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/i=
xgbevf_main.c
index b2c5ecd..ee13e26 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -264,11 +264,10 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_a=
dapter *adapter,
 		IXGBE_WRITE_REG(hw, IXGBE_VTEICS, tx_ring->v_idx);
 	}
=20
+	u64_stats_update_begin(&tx_ring->syncp);
 	tx_ring->total_bytes +=3D total_bytes;
 	tx_ring->total_packets +=3D total_packets;
-
-	netdev->stats.tx_bytes +=3D total_bytes;
-	netdev->stats.tx_packets +=3D total_packets;
+	u64_stats_update_end(&tx_ring->syncp);
=20
 	return count < tx_ring->work_limit;
 }
@@ -595,10 +594,10 @@ next_desc:
 	if (cleaned_count)
 		ixgbevf_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
=20
+	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->total_packets +=3D total_rx_packets;
 	rx_ring->total_bytes +=3D total_rx_bytes;
-	adapter->netdev->stats.rx_bytes +=3D total_rx_bytes;
-	adapter->netdev->stats.rx_packets +=3D total_rx_packets;
+	u64_stats_update_end(&rx_ring->syncp);
=20
 	return cleaned;
 }
@@ -2288,10 +2287,6 @@ void ixgbevf_update_stats(struct ixgbevf_adapter=
 *adapter)
 				adapter->stats.vfgotc);
 	UPDATE_VF_COUNTER_32bit(IXGBE_VFMPRC, adapter->stats.last_vfmprc,
 				adapter->stats.vfmprc);
-
-	/* Fill out the OS statistics structure */
-	adapter->netdev->stats.multicast =3D adapter->stats.vfmprc -
-		adapter->stats.base_vfmprc;
 }
=20
 /**
@@ -3248,11 +3243,50 @@ static void ixgbevf_shutdown(struct pci_dev *pd=
ev)
 	pci_disable_device(pdev);
 }
=20
+static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *=
netdev,
+						   struct rtnl_link_stats64 *stats)
+{
+	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
+	unsigned int start;
+	u64 bytes, packets;
+	const struct ixgbevf_ring *ring;
+	int i;
+
+	ixgbevf_update_stats(adapter);
+
+	stats->multicast =3D adapter->stats.vfmprc - adapter->stats.base_vfmp=
rc;
+
+	for (i =3D 0; i < adapter->num_rx_queues; i++) {
+		ring =3D &adapter->rx_ring[i];
+		do {
+			start =3D u64_stats_fetch_begin_bh(&ring->syncp);
+			bytes =3D ring->total_bytes;
+			packets =3D ring->total_packets;
+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		stats->rx_bytes +=3D bytes;
+		stats->rx_packets +=3D packets;
+	}
+
+	for (i =3D 0; i < adapter->num_tx_queues; i++) {
+		ring =3D &adapter->tx_ring[i];
+		do {
+			start =3D u64_stats_fetch_begin_bh(&ring->syncp);
+			bytes =3D ring->total_bytes;
+			packets =3D ring->total_packets;
+		} while (u64_stats_fetch_retry_bh(&ring->syncp, start));
+		stats->tx_bytes +=3D bytes;
+		stats->tx_packets +=3D packets;
+	}
+
+	return stats;
+}
+
 static const struct net_device_ops ixgbe_netdev_ops =3D {
 	.ndo_open		=3D &ixgbevf_open,
 	.ndo_stop		=3D &ixgbevf_close,
 	.ndo_start_xmit		=3D &ixgbevf_xmit_frame,
 	.ndo_set_rx_mode	=3D &ixgbevf_set_rx_mode,
+	.ndo_get_stats64	=3D ixgbevf_get_stats,
 	.ndo_set_multicast_list	=3D &ixgbevf_set_rx_mode,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_set_mac_address	=3D &ixgbevf_set_mac,


