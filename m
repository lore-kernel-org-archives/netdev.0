From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 3/6] e100: Synchronize interface link
 state with poll routine
Date: Thu, 28 Apr 2005 19:17:42 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281913380.29008-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Synchronize interface link state with e100 poll routine

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e100.c.new
--- net-drivers-2.6/drivers/net/e100.c	2005-04-07 03:22:36.805273784 -0700
+++ net-drivers-2.6/drivers/net/e100.c.new	2005-04-07 03:22:37.251205992 -0700
@@ -1743,8 +1743,11 @@ static int e100_up(struct nic *nic)
 	if((err = request_irq(nic->pdev->irq, e100_intr, SA_SHIRQ,
 		nic->netdev->name, nic->netdev)))
 		goto err_no_irq;
-	e100_enable_irq(nic);
 	netif_wake_queue(nic->netdev);
+	netif_poll_enable(nic->netdev);
+	/* enable ints _after_ enabling poll, preventing a race between
+	 * disable ints+schedule */
+	e100_enable_irq(nic);
 	return 0;
 
 err_no_irq:
@@ -1758,11 +1758,13 @@ err_rx_clean_list:
 
 static void e100_down(struct nic *nic)
 {
+	/* wait here for poll to complete */
+	netif_poll_disable(nic->netdev);
+	netif_stop_queue(nic->netdev);
 	e100_hw_reset(nic);
 	free_irq(nic->pdev->irq, nic->netdev);
 	del_timer_sync(&nic->watchdog);
 	netif_carrier_off(nic->netdev);
-	netif_stop_queue(nic->netdev);
 	e100_clean_cbs(nic);
 	e100_rx_clean_list(nic);
 }
