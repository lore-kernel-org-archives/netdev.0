From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2.6.20-rc7 2/2] atl1: add ethtool set ring params functionality
Date: Wed, 31 Jan 2007 19:12:27 -0600
Message-ID: <20070201011227.GB1752@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf25aec.mail.bellsouth.net ([205.152.59.73]:58204 "EHLO
	imf25aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161175AbXBABM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 20:12:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Cliburn <jacliburn@bellsouth.net>

Fix up some constants relating to max and min ring descriptor counts.
Also add functionality to enable ethtool to set tx and rx ring parameters.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1.h         |    4 +-
 drivers/net/atl1/atl1_ethtool.c |   78 ++++++++++++++++++++++++++++++++++++++-
 2 files changed, 78 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atl1/atl1.h
index cc18016..da4bf87 100644
--- a/drivers/net/atl1/atl1.h
+++ b/drivers/net/atl1/atl1.h
@@ -44,11 +44,11 @@ struct atl1_adapter;
 #define ATL1_MAX_INTR		3
 
 #define ATL1_DEFAULT_TPD	256
-#define ATL1_MAX_TPD		1023
+#define ATL1_MAX_TPD		1024
 #define ATL1_MIN_TPD		64
 #define ATL1_DEFAULT_RFD	512
 #define ATL1_MIN_RFD		128
-#define ATL1_MAX_RFD		2047
+#define ATL1_MAX_RFD		2048
 
 #define ATL1_GET_DESC(R, i, type)	(&(((type *)((R)->desc))[i]))
 #define ATL1_RFD_DESC(R, i)	ATL1_GET_DESC(R, i, struct rx_free_desc)
diff --git a/drivers/net/atl1/atl1_ethtool.c b/drivers/net/atl1/atl1_ethtool.c
index 8ce4d06..b7cd7b3 100644
--- a/drivers/net/atl1/atl1_ethtool.c
+++ b/drivers/net/atl1/atl1_ethtool.c
@@ -308,8 +308,8 @@ static void atl1_get_ringparam(struct net_device *netdev,
 	struct atl1_tpd_ring *txdr = &adapter->tpd_ring;
 	struct atl1_rfd_ring *rxdr = &adapter->rfd_ring;
 
-	ring->rx_max_pending = 2048;
-	ring->tx_max_pending = 1024;
+	ring->rx_max_pending = ATL1_MAX_RFD;
+	ring->tx_max_pending = ATL1_MAX_TPD;
 	ring->rx_mini_max_pending = 0;
 	ring->rx_jumbo_max_pending = 0;
 	ring->rx_pending = rxdr->count;
@@ -318,6 +318,79 @@ static void atl1_get_ringparam(struct net_device *netdev,
 	ring->rx_jumbo_pending = 0;
 }
 
+static int atl1_set_ringparam (struct net_device *netdev,
+				struct ethtool_ringparam *ring)
+{
+	struct atl1_adapter *adapter = netdev_priv(netdev);
+	struct atl1_tpd_ring *tpdr = &adapter->tpd_ring;
+	struct atl1_rrd_ring *rrdr = &adapter->rrd_ring;
+	struct atl1_rfd_ring *rfdr = &adapter->rfd_ring;
+
+	struct atl1_tpd_ring tpd_old, tpd_new;
+	struct atl1_rfd_ring rfd_old, rfd_new;
+	struct atl1_rrd_ring rrd_old, rrd_new;
+	struct atl1_ring_header rhdr_old, rhdr_new;
+	int err;
+
+	tpd_old = adapter->tpd_ring;
+	rfd_old = adapter->rfd_ring;
+	rrd_old = adapter->rrd_ring;
+	rhdr_old = adapter->ring_header;
+
+	if (netif_running(adapter->netdev))
+		atl1_down(adapter);
+
+	rfdr->count = (u16) max(ring->rx_pending, (u32) ATL1_MIN_RFD);
+	rfdr->count = rfdr->count > ATL1_MAX_RFD ? ATL1_MAX_RFD :
+			rfdr->count;
+	rfdr->count = (rfdr->count + 3) & ~3;
+	rrdr->count = rfdr->count;
+
+	tpdr->count = (u16) max(ring->tx_pending, (u32) ATL1_MIN_TPD);
+	tpdr->count = tpdr->count > ATL1_MAX_TPD ? ATL1_MAX_TPD :
+			tpdr->count;
+	tpdr->count = (tpdr->count + 3) & ~3;
+
+	if (netif_running(adapter->netdev)) {
+		/* try to get new resources before deleting old */
+		err = atl1_setup_ring_resources(adapter);
+		if (err)
+			goto err_setup_ring;
+
+		/*
+		 * save the new, restore the old in order to free it,
+		 * then restore the new back again
+		 */
+
+		rfd_new = adapter->rfd_ring;
+		rrd_new = adapter->rrd_ring;
+		tpd_new = adapter->tpd_ring;
+		rhdr_new = adapter->ring_header;
+		adapter->rfd_ring = rfd_old;
+		adapter->rrd_ring = rrd_old;
+		adapter->tpd_ring = tpd_old;
+		adapter->ring_header = rhdr_old;
+		atl1_free_ring_resources(adapter);
+		adapter->rfd_ring = rfd_new;
+		adapter->rrd_ring = rrd_new;
+		adapter->tpd_ring = tpd_new;
+		adapter->ring_header = rhdr_new;
+
+		err = atl1_up(adapter);
+		if (err)
+			return err;
+	}
+	return 0;
+
+err_setup_ring:
+	adapter->rfd_ring = rfd_old;
+	adapter->rrd_ring = rrd_old;
+	adapter->tpd_ring = tpd_old;
+	adapter->ring_header = rhdr_old;
+	atl1_up(adapter);
+	return err;
+}
+
 static void atl1_get_pauseparam(struct net_device *netdev,
 			     struct ethtool_pauseparam *epause)
 {
@@ -417,6 +490,7 @@ const struct ethtool_ops atl1_ethtool_ops = {
 	.get_wol		= atl1_get_wol,
 	.set_wol		= atl1_set_wol,
 	.get_ringparam		= atl1_get_ringparam,
+	.set_ringparam		= atl1_set_ringparam,
 	.get_pauseparam		= atl1_get_pauseparam,
 	.set_pauseparam 	= atl1_set_pauseparam,
 	.get_rx_csum		= atl1_get_rx_csum,
