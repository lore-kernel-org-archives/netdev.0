From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Thu, 1 Nov 2007 16:05:58 -0400
Message-ID: <20071101200558.GA4108@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:47614 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752941AbXKAUF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 16:05:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/Kconfig             |    4 +---
 drivers/net/fec_mpc52xx.c       |    4 ++--
 drivers/net/myri10ge/myri10ge.c |    6 +++---
 3 files changed, 6 insertions(+), 8 deletions(-)

Andrew Gallatin (1):
      Fix myri10ge NAPI oops & warnings

Grant Likely (2):
      mpc5200: Fix Kconfig dependancies on MPC5200 FEC device driver
      Fix region size check in mpc5200 FEC driver

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 867cb73..5f800a6 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1883,9 +1883,7 @@ config FEC2
 
 config FEC_MPC52xx
 	tristate "MPC52xx FEC driver"
-	depends on PPC_MPC52xx
-	select PPC_BESTCOMM
-	select PPC_BESTCOMM_FEC
+	depends on PPC_MERGE && PPC_MPC52xx && PPC_BESTCOMM_FEC
 	select CRC32
 	select PHYLIB
 	---help---
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index fc1cf0b..a8a0ee2 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -879,9 +879,9 @@ mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
 				"Error while parsing device node resource\n" );
 		return rv;
 	}
-	if ((mem.end - mem.start + 1) != sizeof(struct mpc52xx_fec)) {
+	if ((mem.end - mem.start + 1) < sizeof(struct mpc52xx_fec)) {
 		printk(KERN_ERR DRIVER_NAME
-			" - invalid resource size (%lx != %x), check mpc52xx_devices.c\n",
+			" - invalid resource size (%lx < %x), check mpc52xx_devices.c\n",
 			(unsigned long)(mem.end - mem.start + 1), sizeof(struct mpc52xx_fec));
 		return -EINVAL;
 	}
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 366e62a..0f306dd 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1151,7 +1151,7 @@ static inline int myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int budget)
 	u16 length;
 	__wsum checksum;
 
-	while (rx_done->entry[idx].length != 0 && work_done++ < budget) {
+	while (rx_done->entry[idx].length != 0 && work_done < budget) {
 		length = ntohs(rx_done->entry[idx].length);
 		rx_done->entry[idx].length = 0;
 		checksum = csum_unfold(rx_done->entry[idx].checksum);
@@ -1167,6 +1167,7 @@ static inline int myri10ge_clean_rx_done(struct myri10ge_priv *mgp, int budget)
 		rx_bytes += rx_ok * (unsigned long)length;
 		cnt++;
 		idx = cnt & (myri10ge_max_intr_slots - 1);
+		work_done++;
 	}
 	rx_done->idx = idx;
 	rx_done->cnt = cnt;
@@ -1233,13 +1234,12 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	struct myri10ge_priv *mgp =
 	    container_of(napi, struct myri10ge_priv, napi);
 	struct net_device *netdev = mgp->dev;
-	struct myri10ge_rx_done *rx_done = &mgp->rx_done;
 	int work_done;
 
 	/* process as many rx events as NAPI will allow */
 	work_done = myri10ge_clean_rx_done(mgp, budget);
 
-	if (rx_done->entry[rx_done->idx].length == 0 || !netif_running(netdev)) {
+	if (work_done < budget || !netif_running(netdev)) {
 		netif_rx_complete(netdev, napi);
 		put_be32(htonl(3), mgp->irq_claim);
 	}
