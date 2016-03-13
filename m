From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: do not call netif_start_queue() from sh_eth_dev_init()
Date: Mon, 14 Mar 2016 01:09:53 +0300
Message-ID: <2129265.GisCEHHzPr@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Iff  sh_eth_phy_start() call fails in sh_eth_open(), the netif_start_queue()
call done by sh_eth_dev_init()  is not undone.  In order to deal with that,
stop calling netif_start_queue()  from there, so that it can be called only
when the device is fully opened and sh_eth_dev_init() only deals with the
hardware initialization, symmetrically to sh_eth_dev_exit()...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
DaveM, I'm not sure whether it's a bug to leave TX queue started when the
device opening fails... anyway since  the 'net,git' repo is closed,  this
patch  is against your 'net-next.git' repo.

 drivers/net/ethernet/renesas/sh_eth.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1312,8 +1312,6 @@ static int sh_eth_dev_init(struct net_de
 	if (start) {
 		/* Setting the Rx mode will start the Rx process. */
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
-
-		netif_start_queue(ndev);
 	}
 
 	return ret;
@@ -2261,6 +2259,8 @@ static int sh_eth_open(struct net_device
 	if (ret)
 		goto out_free_irq;
 
+	netif_start_queue(ndev);
+
 	mdp->is_opened = 1;
 
 	return ret;
@@ -2304,6 +2304,8 @@ static void sh_eth_tx_timeout(struct net
 
 	/* device init */
 	sh_eth_dev_init(ndev, true);
+
+	netif_start_queue(ndev);
 }
 
 /* Packet transmit function */
