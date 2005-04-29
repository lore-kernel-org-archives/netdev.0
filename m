From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 1/6] e100: Execute tx_timeout task
 outside interrupt context
Date: Thu, 28 Apr 2005 19:16:58 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281911490.29008-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Execute tx_timeout task outside the interrupt context

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e100.c.new
--- net-drivers-2.6/drivers/net/e100.c	2005-04-07 03:22:36.805273784 -0700
+++ net-drivers-2.6/drivers/net/e100.c.new	2005-04-07 03:22:37.251205992 -0700
@@ -539,6 +539,7 @@ struct nic {
 	struct timer_list watchdog;
 	struct timer_list blink_timer;
 	struct mii_if_info mii;
+	struct work_struct tx_timeout_task;
 	enum loopback loopback;
 
 	struct mem *mem;
@@ -1716,6 +1717,15 @@ static void e100_tx_timeout(struct net_d
 {
 	struct nic *nic = netdev_priv(netdev);
 
+	/* Reset outside of interrupt context, to avoid request_irq 
+	 * in interrupt context */
+	schedule_work(&nic->tx_timeout_task);
+}
+
+static void e100_tx_timeout_task(struct net_device *netdev)
+{
+	struct nic *nic = netdev_priv(netdev);
+
 	DPRINTK(TX_ERR, DEBUG, "scb.status=0x%02X\n",
 		readb(&nic->csr->scb.status));
 	e100_down(netdev_priv(netdev));
@@ -2240,6 +2250,9 @@ static int __devinit e100_probe(struct p
 	nic->blink_timer.function = e100_blink_led;
 	nic->blink_timer.data = (unsigned long)nic;
 
+	INIT_WORK(&nic->tx_timeout_task,
+		(void (*)(void *))e100_tx_timeout_task, netdev);
+
 	if((err = e100_alloc(nic))) {
 		DPRINTK(PROBE, ERR, "Cannot alloc driver memory, aborting.\n");
 		goto err_out_iounmap;
