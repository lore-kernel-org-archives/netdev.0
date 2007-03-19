From: Deepak Saxena <dsaxena@plexity.net>
Subject: [PATCH] Netpoll support for Sibyte MAC
Date: Mon, 19 Mar 2007 15:43:11 -0700
Message-ID: <20070319224311.GA10176@plexity.net>
Reply-To: dsaxena@plexity.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralf@linux-mips.org, jeff@garzik.org, linux-mips@linux-mips.org,
	Manish Lachwani <mlachwani@mvista.com>
To: netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org


NETPOLL support for Sibyte MAC

Signed-off-by: Manish Lachwani <mlachwani@mvista.com>
Signed-off-by: Deepak Saxena <dsaxena@mvista.com>

---

 Applies cleanly to 2.6.21-rc4

 drivers/net/sb1250-mac.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+)

Index: linux-2.6.18/drivers/net/sb1250-mac.c
===================================================================
--- linux-2.6.18.orig/drivers/net/sb1250-mac.c
+++ linux-2.6.18/drivers/net/sb1250-mac.c
@@ -1128,6 +1128,26 @@ static void sbdma_fillring(sbmacdma_t *d
 	}
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void sbmac_netpoll(struct net_device *netdev)
+{
+	struct sbmac_softc *sc = netdev_priv(netdev);
+	int irq = sc->sbm_dev->irq;
+
+	__raw_writeq(0, sc->sbm_imr);
+
+	sbmac_intr(irq, netdev, NULL);
+
+#ifdef CONFIG_SBMAC_COALESCE
+	__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_TX_CH0) |
+	((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_RX_CH0),
+	sc->sbm_imr);
+#else
+	__raw_writeq((M_MAC_INT_CHANNEL << S_MAC_TX_CH0) | 
+	(M_MAC_INT_CHANNEL << S_MAC_RX_CH0), sc->sbm_imr);
+#endif
+}
+#endif
 
 /**********************************************************************
  *  SBDMA_RX_PROCESS(sc,d)
@@ -2402,6 +2422,9 @@ static int sbmac_init(struct net_device 
 	dev->watchdog_timeo     = TX_TIMEOUT;
 
 	dev->change_mtu         = sb1250_change_mtu;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = sbmac_netpoll;
+#endif
 
 	/* This is needed for PASS2 for Rx H/W checksum feature */
 	sbmac_set_iphdr_offset(sc);

-- 
Deepak Saxena - dsaxena@plexity.net - http://www.plexity.net

In the end, they will not say, "those were dark times,"  they will ask
"why were their poets silent?" - Bertolt Brecht
