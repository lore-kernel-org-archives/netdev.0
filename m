From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 2 Oct 2007 13:18:24 -0400
Message-ID: <20071002171824.GA28514@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:40745 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754573AbXJBRSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 13:18:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/mv643xx_eth.c |    1 -
 drivers/net/qla3xxx.c     |    7 +++++++
 drivers/net/usb/dm9601.c  |    2 +-
 3 files changed, 8 insertions(+), 2 deletions(-)

Dale Farnsworth (1):
      mv643xx_eth: Do not modify struct netdev tx_queue_len

Peter Korsgaard (1):
      dm9601: Fix receive MTU

Ron Mercer (2):
      qla3xxx: bugfix: Add memory barrier before accessing rx completion.
      qla3xxx: bugfix: Fix VLAN rx completion handling.

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 34288fe..3153356 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1357,7 +1357,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 #endif
 
 	dev->watchdog_timeo = 2 * HZ;
-	dev->tx_queue_len = mp->tx_ring_size;
 	dev->base_addr = 0;
 	dev->change_mtu = mv643xx_eth_change_mtu;
 	dev->do_ioctl = mv643xx_eth_do_ioctl;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 69da95b..ea15131 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2248,6 +2248,13 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 		qdev->rsp_consumer_index) && (work_done < work_to_do)) {
 
 		net_rsp = qdev->rsp_current;
+		rmb();
+		/*
+		 * Fix 4032 chipe undocumented "feature" where bit-8 is set if the
+		 * inbound completion is for a VLAN.
+		 */
+		if (qdev->device_id == QL3032_DEVICE_ID)
+			net_rsp->opcode &= 0x7f;
 		switch (net_rsp->opcode) {
 
 		case OPCODE_OB_MAC_IOCB_FN0:
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 16c7a0e..a2de32f 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -405,7 +405,7 @@ static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->ethtool_ops = &dm9601_ethtool_ops;
 	dev->net->hard_header_len += DM_TX_OVERHEAD;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
-	dev->rx_urb_size = dev->net->mtu + DM_RX_OVERHEAD;
+	dev->rx_urb_size = dev->net->mtu + ETH_HLEN + DM_RX_OVERHEAD;
 
 	dev->mii.dev = dev->net;
 	dev->mii.mdio_read = dm9601_mdio_read;
