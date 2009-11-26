From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 14/16] sfc: Change MAC promiscuity and multicast hash at
	the same time
Date: Thu, 26 Nov 2009 02:12:16 +0000
Message-ID: <1259201536.2806.31.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31352 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbZKZCMM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:12:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=EF=BB=BFFrom: Steve Hodgson <shodgson@solarflare.com>

Currently we can set multicast hash immediately (in atomic context)
but must delay setting MAC promiscuity.  There is not that much
point in deferring one but not the other, and setting the multicast
hash on Siena will involve a firmware request.  So process them
both in efx_mac_work().

Also, set the broadcast bit in the multicast hash in
efx_set_multicast_list(), since this is required for both Falcon and
Siena.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   38 ++++++++++++++++++++++++----------=
----
 drivers/net/sfc/falcon.c     |   10 +++-------
 drivers/net/sfc/falcon.h     |    2 +-
 drivers/net/sfc/net_driver.h |    2 +-
 4 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 15616dd..1009d1e 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -688,11 +688,18 @@ static void efx_phy_work(struct work_struct *data=
)
 	mutex_unlock(&efx->mac_lock);
 }
=20
+/* Asynchronous work item for changing MAC promiscuity and multicast
+ * hash.  Avoid a drain/rx_ingress enable by reconfiguring the current
+ * MAC directly. */
 static void efx_mac_work(struct work_struct *data)
 {
 	struct efx_nic *efx =3D container_of(data, struct efx_nic, mac_work);
=20
 	mutex_lock(&efx->mac_lock);
+	if (efx->port_enabled) {
+		falcon_push_multicast_hash(efx);
+		efx->mac_op->reconfigure(efx);
+	}
 	mutex_unlock(&efx->mac_lock);
 }
=20
@@ -771,7 +778,12 @@ static void efx_start_port(struct efx_nic *efx)
=20
 	mutex_lock(&efx->mac_lock);
 	efx->port_enabled =3D true;
-	__efx_reconfigure_port(efx);
+
+	/* efx_mac_work() might have been scheduled after efx_stop_port(),
+	 * and then cancelled by efx_flush_all() */
+	falcon_push_multicast_hash(efx);
+	efx->mac_op->reconfigure(efx);
+
 	mutex_unlock(&efx->mac_lock);
 }
=20
@@ -1534,16 +1546,14 @@ static void efx_set_multicast_list(struct net_d=
evice *net_dev)
 	struct efx_nic *efx =3D netdev_priv(net_dev);
 	struct dev_mc_list *mc_list =3D net_dev->mc_list;
 	union efx_multicast_hash *mc_hash =3D &efx->multicast_hash;
-	bool promiscuous =3D !!(net_dev->flags & IFF_PROMISC);
-	bool changed =3D (efx->promiscuous !=3D promiscuous);
 	u32 crc;
 	int bit;
 	int i;
=20
-	efx->promiscuous =3D promiscuous;
+	efx->promiscuous =3D !!(net_dev->flags & IFF_PROMISC);
=20
 	/* Build multicast hash table */
-	if (promiscuous || (net_dev->flags & IFF_ALLMULTI)) {
+	if (efx->promiscuous || (net_dev->flags & IFF_ALLMULTI)) {
 		memset(mc_hash, 0xff, sizeof(*mc_hash));
 	} else {
 		memset(mc_hash, 0x00, sizeof(*mc_hash));
@@ -1553,17 +1563,17 @@ static void efx_set_multicast_list(struct net_d=
evice *net_dev)
 			set_bit_le(bit, mc_hash->byte);
 			mc_list =3D mc_list->next;
 		}
-	}
=20
-	if (!efx->port_enabled)
-		/* Delay pushing settings until efx_start_port() */
-		return;
-
-	if (changed)
-		queue_work(efx->workqueue, &efx->phy_work);
+		/* Broadcast packets go through the multicast hash filter.
+		 * ether_crc_le() of the broadcast address is 0xbe2612ff
+		 * so we always add bit 0xff to the mask.
+		 */
+		set_bit_le(0xff, mc_hash->byte);
+	}
=20
-	/* Create and activate new global multicast hash table */
-	falcon_set_multicast_hash(efx);
+	if (efx->port_enabled)
+		queue_work(efx->workqueue, &efx->mac_work);
+	/* Otherwise efx_start_port() will do this */
 }
=20
 static const struct net_device_ops efx_netdev_ops =3D {
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index fac534a..e26043e 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1993,7 +1993,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_ni=
c *efx)
 	efx_writeo(efx, &reg, FR_AB_MAC_CTRL);
=20
 	/* Restore the multicast hash registers. */
-	falcon_set_multicast_hash(efx);
+	falcon_push_multicast_hash(efx);
=20
 	/* Transmission of pause frames when RX crosses the threshold is
 	 * covered by RX_XOFF_MAC_EN and XM_TX_CFG_REG:XM_FCNTL.
@@ -2327,15 +2327,11 @@ void falcon_remove_port(struct efx_nic *efx)
  *********************************************************************=
*****
  */
=20
-void falcon_set_multicast_hash(struct efx_nic *efx)
+void falcon_push_multicast_hash(struct efx_nic *efx)
 {
 	union efx_multicast_hash *mc_hash =3D &efx->multicast_hash;
=20
-	/* Broadcast packets go through the multicast hash filter.
-	 * ether_crc_le() of the broadcast address is 0xbe2612ff
-	 * so we always add bit 0xff to the mask.
-	 */
-	set_bit_le(0xff, mc_hash->byte);
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
=20
 	efx_writeo(efx, &mc_hash->oword[0], FR_AB_MAC_MC_HASH_REG0);
 	efx_writeo(efx, &mc_hash->oword[1], FR_AB_MAC_MC_HASH_REG1);
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 9ae1b6c..c70bb08 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -163,7 +163,7 @@ extern void falcon_remove_nic(struct efx_nic *efx);
 extern void falcon_update_nic_stats(struct efx_nic *efx);
 extern void falcon_start_nic_stats(struct efx_nic *efx);
 extern void falcon_stop_nic_stats(struct efx_nic *efx);
-extern void falcon_set_multicast_hash(struct efx_nic *efx);
+extern void falcon_push_multicast_hash(struct efx_nic *efx);
 extern int falcon_reset_xaui(struct efx_nic *efx);
=20
 /* Tests */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.=
h
index cc1a97b..ead1c98 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -730,7 +730,7 @@ union efx_multicast_hash {
  * @multicast_hash: Multicast hash table
  * @wanted_fc: Wanted flow control flags
  * @phy_work: work item for dealing with PHY events
- * @mac_work: work item for dealing with MAC events
+ * @mac_work: Work item for changing MAC promiscuity and multicast has=
h
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
  * @loopback_selftest: Offline self-test private state

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

