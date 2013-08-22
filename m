From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: RE: [PATCH 4/4] qlcnic: use standard NAPI weights
Date: Thu, 22 Aug 2013 06:51:29 +0000
Message-ID: <ADFE82A996F10145934E45547759F763311C753E@avmb3.qlogic.org>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com>,<1377103771-1590-5-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>
To: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:56425 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753645Ab3HVGvu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 02:51:50 -0400
In-Reply-To: <1377103771-1590-5-git-send-email-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

________________________________________
=46rom: Michal Schmidt [mschmidt@redhat.com]
Sent: Wednesday, August 21, 2013 9:49 AM
To: David Miller
Cc: netdev; Eric Dumazet; Himanshu Madhani; Rajesh Borundia; Shahed Sha=
ikh; Jitendra Kalsaria; Sony Chacko; Sucheta Chakraborty; Dept-Eng Linu=
x Driver
Subject: [PATCH 4/4] qlcnic: use standard NAPI weights

Since commit 82dc3c63 netif_napi_add() produces an error message if
a NAPI poll weight greater than 64 is requested.

qlcnic requests the weight as large as 256 for some of its rings, and
smaller values for other rings. For instance in qlcnic_82xx_napi_add()
I think the intention was to give the tx+rx ring a bigger weight than
to rx-only rings, but it's actually doing the opposite. So I'm assuming
the weights do not really matter much.

Just use the standard NAPI weights for all rings.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
CC: Himanshu Madhani <himanshu.madhani@qlogic.com>
CC: Rajesh Borundia <rajesh.borundia@qlogic.com>
CC: Shahed Shaikh <shahed.shaikh@qlogic.com>
CC: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
CC: Sony Chacko <sony.chacko@qlogic.com>
CC: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
CC: linux-driver@qlogic.com
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h    |  1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c | 25 ++++++++++--------=
-------
 2 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/=
ethernet/qlogic/qlcnic/qlcnic.h
index 3dcc666..47876a5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -926,7 +926,6 @@ struct qlcnic_ipaddr {
 #define QLCNIC_PCI_REG_MSIX_TBL        0x44
 #define QLCNIC_MSIX_TBL_PGSIZE         4096

-#define QLCNIC_NETDEV_WEIGHT   128
 #define QLCNIC_ADAPTER_UP_MAGIC 777

 #define __QLCNIC_FW_ATTACHED           0
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/n=
et/ethernet/qlogic/qlcnic/qlcnic_io.c
index cec0908..1a5915d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1408,23 +1408,21 @@ void qlcnic_82xx_process_rcv_ring_diag(struct q=
lcnic_host_sds_ring *sds_ring)
 int qlcnic_82xx_napi_add(struct qlcnic_adapter *adapter,
                         struct net_device *netdev)
 {
-       int ring, max_sds_rings;
+       int ring;
        struct qlcnic_host_sds_ring *sds_ring;
        struct qlcnic_recv_context *recv_ctx =3D adapter->recv_ctx;

        if (qlcnic_alloc_sds_rings(recv_ctx, adapter->max_sds_rings))
                return -ENOMEM;

-       max_sds_rings =3D adapter->max_sds_rings;
-
        for (ring =3D 0; ring < adapter->max_sds_rings; ring++) {
                sds_ring =3D &recv_ctx->sds_rings[ring];
                if (ring =3D=3D adapter->max_sds_rings - 1)
                        netif_napi_add(netdev, &sds_ring->napi, qlcnic_=
poll,
-                                      QLCNIC_NETDEV_WEIGHT / max_sds_r=
ings);
+                                      NAPI_POLL_WEIGHT);
                else
                        netif_napi_add(netdev, &sds_ring->napi, qlcnic_=
rx_poll,
-                                      QLCNIC_NETDEV_WEIGHT*2);
+                                      NAPI_POLL_WEIGHT);
        }

        if (qlcnic_alloc_tx_rings(adapter, netdev)) {
@@ -1861,7 +1859,7 @@ void qlcnic_83xx_napi_disable(struct qlcnic_adapt=
er *adapter)
 int qlcnic_83xx_napi_add(struct qlcnic_adapter *adapter,
                         struct net_device *netdev)
 {
-       int ring, max_sds_rings, temp;
+       int ring;
        struct qlcnic_host_sds_ring *sds_ring;
        struct qlcnic_host_tx_ring *tx_ring;
        struct qlcnic_recv_context *recv_ctx =3D adapter->recv_ctx;
@@ -1869,25 +1867,22 @@ int qlcnic_83xx_napi_add(struct qlcnic_adapter =
*adapter,
        if (qlcnic_alloc_sds_rings(recv_ctx, adapter->max_sds_rings))
                return -ENOMEM;

-       max_sds_rings =3D adapter->max_sds_rings;
        for (ring =3D 0; ring < adapter->max_sds_rings; ring++) {
                sds_ring =3D &recv_ctx->sds_rings[ring];
                if (adapter->flags & QLCNIC_MSIX_ENABLED) {
-                       if (!(adapter->flags & QLCNIC_TX_INTR_SHARED)) =
{
+                       if (!(adapter->flags & QLCNIC_TX_INTR_SHARED))
                                netif_napi_add(netdev, &sds_ring->napi,
                                               qlcnic_83xx_rx_poll,
-                                              QLCNIC_NETDEV_WEIGHT * 2=
);
-                       } else {
-                               temp =3D QLCNIC_NETDEV_WEIGHT / max_sds=
_rings;
+                                              NAPI_POLL_WEIGHT);
+                       else
                                netif_napi_add(netdev, &sds_ring->napi,
                                               qlcnic_83xx_msix_sriov_v=
f_poll,
-                                              temp);
-                       }
+                                              NAPI_POLL_WEIGHT);

                } else {
                        netif_napi_add(netdev, &sds_ring->napi,
                                       qlcnic_83xx_poll,
-                                      QLCNIC_NETDEV_WEIGHT / max_sds_r=
ings);
+                                      NAPI_POLL_WEIGHT);
                }
        }

@@ -1902,7 +1897,7 @@ int qlcnic_83xx_napi_add(struct qlcnic_adapter *a=
dapter,
                        tx_ring =3D &adapter->tx_ring[ring];
                        netif_napi_add(netdev, &tx_ring->napi,
                                       qlcnic_83xx_msix_tx_poll,
-                                      QLCNIC_NETDEV_WEIGHT);
+                                      NAPI_POLL_WEIGHT);
                }
        }

We are in process of running performance numbers with these changes. =A0=
I will respond once I have the performance data with the proposed chang=
es.

Thanks,
Himanshu
--
1.8.3.1
