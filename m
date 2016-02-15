From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 2/3] RDMA/nes: Replace LRO with GRO
Date: Mon, 15 Feb 2016 21:25:44 +0000
Message-ID: <20160215212544.GD5231@decadent.org.uk>
References: <20160215212351.GB5231@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="9dgjiU4MmWPVapMU"
Cc: Faisal Latif <faisal.latif@intel.com>, linux-rdma@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36456 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751373AbcBOVZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 16:25:47 -0500
Content-Disposition: inline
In-Reply-To: <20160215212351.GB5231@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9dgjiU4MmWPVapMU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

GRO is simpler to use than the old inet_lro library, and is compatible
with forwarding and bridging configurations.

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/infiniband/hw/nes/Kconfig   |  1 -
 drivers/infiniband/hw/nes/nes_hw.c  | 44 +--------------------------------=
----
 drivers/infiniband/hw/nes/nes_hw.h  |  7 ------
 drivers/infiniband/hw/nes/nes_nic.c |  7 ------
 4 files changed, 1 insertion(+), 58 deletions(-)

diff --git a/drivers/infiniband/hw/nes/Kconfig b/drivers/infiniband/hw/nes/=
Kconfig
index 846dc97cf260..7964eba8e7ed 100644
--- a/drivers/infiniband/hw/nes/Kconfig
+++ b/drivers/infiniband/hw/nes/Kconfig
@@ -2,7 +2,6 @@ config INFINIBAND_NES
 	tristate "NetEffect RNIC Driver"
 	depends on PCI && INET && INFINIBAND
 	select LIBCRC32C
-	select INET_LRO
 	---help---
 	  This is the RDMA Network Interface Card (RNIC) driver for
 	  NetEffect Ethernet Cluster Server Adapters.
diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw/nes=
/nes_hw.c
index 4713dd7ed764..a1c6481d8038 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -35,18 +35,11 @@
 #include <linux/moduleparam.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/ip.h>
-#include <linux/tcp.h>
 #include <linux/if_vlan.h>
-#include <linux/inet_lro.h>
 #include <linux/slab.h>
=20
 #include "nes.h"
=20
-static unsigned int nes_lro_max_aggr =3D NES_LRO_MAX_AGGR;
-module_param(nes_lro_max_aggr, uint, 0444);
-MODULE_PARM_DESC(nes_lro_max_aggr, "NIC LRO max packet aggregation");
-
 static int wide_ppm_offset;
 module_param(wide_ppm_offset, int, 0644);
 MODULE_PARM_DESC(wide_ppm_offset, "Increase CX4 interface clock ppm offset=
, 0=3D100ppm (default), 1=3D300ppm");
@@ -1642,25 +1635,6 @@ static void nes_rq_wqes_timeout(unsigned long parm)
 }
=20
=20
-static int nes_lro_get_skb_hdr(struct sk_buff *skb, void **iphdr,
-			       void **tcph, u64 *hdr_flags, void *priv)
-{
-	unsigned int ip_len;
-	struct iphdr *iph;
-	skb_reset_network_header(skb);
-	iph =3D ip_hdr(skb);
-	if (iph->protocol !=3D IPPROTO_TCP)
-		return -1;
-	ip_len =3D ip_hdrlen(skb);
-	skb_set_transport_header(skb, ip_len);
-	*tcph =3D tcp_hdr(skb);
-
-	*hdr_flags =3D LRO_IPV4 | LRO_TCP;
-	*iphdr =3D iph;
-	return 0;
-}
-
-
 /**
  * nes_init_nic_qp
  */
@@ -1895,14 +1869,6 @@ int nes_init_nic_qp(struct nes_device *nesdev, struc=
t net_device *netdev)
 		return -ENOMEM;
 	}
=20
-	nesvnic->lro_mgr.max_aggr       =3D nes_lro_max_aggr;
-	nesvnic->lro_mgr.max_desc       =3D NES_MAX_LRO_DESCRIPTORS;
-	nesvnic->lro_mgr.lro_arr        =3D nesvnic->lro_desc;
-	nesvnic->lro_mgr.get_skb_header =3D nes_lro_get_skb_hdr;
-	nesvnic->lro_mgr.features       =3D LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
-	nesvnic->lro_mgr.dev            =3D netdev;
-	nesvnic->lro_mgr.ip_summed      =3D CHECKSUM_UNNECESSARY;
-	nesvnic->lro_mgr.ip_summed_aggr =3D CHECKSUM_UNNECESSARY;
 	return 0;
 }
=20
@@ -2809,13 +2775,10 @@ void nes_nic_ce_handler(struct nes_device *nesdev, =
struct nes_hw_nic_cq *cq)
 	u16 pkt_type;
 	u16 rqes_processed =3D 0;
 	u8 sq_cqes =3D 0;
-	u8 nes_use_lro =3D 0;
=20
 	head =3D cq->cq_head;
 	cq_size =3D cq->cq_size;
 	cq->cqes_pending =3D 1;
-	if (nesvnic->netdev->features & NETIF_F_LRO)
-		nes_use_lro =3D 1;
 	do {
 		if (le32_to_cpu(cq->cq_vbase[head].cqe_words[NES_NIC_CQE_MISC_IDX]) &
 				NES_NIC_CQE_VALID) {
@@ -2950,10 +2913,7 @@ void nes_nic_ce_handler(struct nes_device *nesdev, s=
truct nes_hw_nic_cq *cq)
=20
 					__vlan_hwaccel_put_tag(rx_skb, htons(ETH_P_8021Q), vlan_tag);
 				}
-				if (nes_use_lro)
-					lro_receive_skb(&nesvnic->lro_mgr, rx_skb, NULL);
-				else
-					netif_receive_skb(rx_skb);
+				napi_gro_receive(&nesvnic->napi, rx_skb);
=20
 skip_rx_indicate0:
 				;
@@ -2984,8 +2944,6 @@ skip_rx_indicate0:
=20
 	} while (1);
=20
-	if (nes_use_lro)
-		lro_flush_all(&nesvnic->lro_mgr);
 	if (sq_cqes) {
 		barrier();
 		/* restart the queue if it had been stopped */
diff --git a/drivers/infiniband/hw/nes/nes_hw.h b/drivers/infiniband/hw/nes=
/nes_hw.h
index c9080208aad2..1b66ef1e9937 100644
--- a/drivers/infiniband/hw/nes/nes_hw.h
+++ b/drivers/infiniband/hw/nes/nes_hw.h
@@ -33,8 +33,6 @@
 #ifndef __NES_HW_H
 #define __NES_HW_H
=20
-#include <linux/inet_lro.h>
-
 #define NES_PHY_TYPE_CX4       1
 #define NES_PHY_TYPE_1G        2
 #define NES_PHY_TYPE_ARGUS     4
@@ -1049,8 +1047,6 @@ struct nes_hw_tune_timer {
 #define NES_TIMER_ENABLE_LIMIT      4
 #define NES_MAX_LINK_INTERRUPTS     128
 #define NES_MAX_LINK_CHECK          200
-#define NES_MAX_LRO_DESCRIPTORS     32
-#define NES_LRO_MAX_AGGR            64
=20
 struct nes_adapter {
 	u64              fw_ver;
@@ -1263,9 +1259,6 @@ struct nes_vnic {
 	u8  next_qp_nic_index;
 	u8  of_device_registered;
 	u8  rdma_enabled;
-	u32 lro_max_aggr;
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_desc[NES_MAX_LRO_DESCRIPTORS];
 	struct timer_list event_timer;
 	enum ib_event_type delayed_event;
 	enum ib_event_type last_dispatched_event;
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/ne=
s/nes_nic.c
index 6a0bdfa0ce2e..3ea9e055fdd3 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1085,9 +1085,6 @@ static const char nes_ethtool_stringset[][ETH_GSTRING=
_LEN] =3D {
 	"Free 4Kpbls",
 	"Free 256pbls",
 	"Timer Inits",
-	"LRO aggregated",
-	"LRO flushed",
-	"LRO no_desc",
 	"PAU CreateQPs",
 	"PAU DestroyQPs",
 };
@@ -1302,9 +1299,6 @@ static void nes_netdev_get_ethtool_stats(struct net_d=
evice *netdev,
 	target_stat_values[++index] =3D nesadapter->free_4kpbl;
 	target_stat_values[++index] =3D nesadapter->free_256pbl;
 	target_stat_values[++index] =3D int_mod_timer_init;
-	target_stat_values[++index] =3D nesvnic->lro_mgr.stats.aggregated;
-	target_stat_values[++index] =3D nesvnic->lro_mgr.stats.flushed;
-	target_stat_values[++index] =3D nesvnic->lro_mgr.stats.no_desc;
 	target_stat_values[++index] =3D atomic_read(&pau_qps_created);
 	target_stat_values[++index] =3D atomic_read(&pau_qps_destroyed);
 }
@@ -1709,7 +1703,6 @@ struct net_device *nes_netdev_init(struct nes_device =
*nesdev,
 		netdev->hw_features |=3D NETIF_F_TSO;
=20
 	netdev->features =3D netdev->hw_features | NETIF_F_HIGHDMA | NETIF_F_HW_V=
LAN_CTAG_TX;
-	netdev->hw_features |=3D NETIF_F_LRO;
=20
 	nes_debug(NES_DBG_INIT, "nesvnic =3D %p, reported features =3D 0x%lX, QPi=
d =3D %d,"
 			" nic_index =3D %d, logical_port =3D %d, mac_index =3D %d.\n",


--9dgjiU4MmWPVapMU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVsJCV+e/yOyVhhEJAQqSDg//Ul34zkO5V7LnXGCGPYcXhr9xv7ahmaNg
7XcSJ6PJ8ZUhxGYynas9BqBobIANkUorkFqlksx3fvmHgCmWtcpljYFQF80DCx2o
sVjr2/jcVssWjwqasBOM6FiFjyyxgwKs9WrTzFfL10dbC0V5zeZid5YymL/1I95x
09kZPlFlQHo/OzSXzaNx2aEgnpbhOwHMrBqPL09PTF4/lL/3B9WVVSdffZdZKmwx
JoyABXuFuKStph8qOmL2tH2xIRxyhD3zlibtHfRxbDVWNcO/airjPe5cXTJxLzcm
cS2REeT8pJ0lRqMu2V3fHQKEoVg4jPzRu6yfazLeRTAQTnY6GFHdio1ZuxI/4xhL
+d4IB8oXyvphwWGpOI+A5NBDLaQRI9bCrOQPDERoJjjV1p7NqzVuMYRg5fqiq4aR
KOSwtXG173Q3eFJK9PgzwVa6nOFo4v4e/uPF+fdq+AHUisnUoHnXnqPnkVJhzk8F
Of9asOHJazpsH8RuH+Zl26Axhd2wPTc3K4uBXYqfJ7VR5vOkg5+0SXGUriwegHu7
uwIT/NmLU7M+TMuDxkmbxZYJYhB7QPBXDFQ6FHf0IEnvnbuE/yCc6DEn8BY6xUph
Arcoosxc9sc9TFI6vziQoUs8dl1DQYm/fiokoX4Rq3aq/HS+AOcg+ZoXv/Tdlr9m
gYChlSw7/20=
=BMHH
-----END PGP SIGNATURE-----

--9dgjiU4MmWPVapMU--
