From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc2] prism54 URGENT - Fix IRQ
	handling
Date: Fri, 30 Jul 2004 10:23:57 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407301023.58457.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_eWgCBKI6CxpnqJ1"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_eWgCBKI6CxpnqJ1
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-07-30 Margit Schubert-While <margitsw@t-online.de>

* We are handing back HANDLED even though the IRQ is not for us.
  We also change device state.
  This is plainly wrong.
  AFAICT we also need to take the spin lock early.
  Tested/running on UP/SMP for about a week now.
  (Discovered on one of my lappies that had the X driver on the same IRQ)
  (Proposed on Prism54 Devel with no objections)

* Jeff, I think we need to squeeze this one into 2.6.8

Margit









--Boundary-00=_eWgCBKI6CxpnqJ1
Content-Type: text/x-diff;
  charset="us-ascii";
  name="interrupt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="interrupt.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.8-02/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/islpci_dev.c	2004-07-28 13:58:06.000000000 +0200
+++ linux-2.6.8-02/drivers/net/wireless/prism54/islpci_dev.c	2004-07-28 14:04:08.000000000 +0200
@@ -186,6 +186,9 @@
 	void *device = priv->device_base;
 	int powerstate = ISL38XX_PSM_POWERSAVE_STATE;
 
+	/* lock the interrupt handler */
+	spin_lock(&priv->slock);
+
 	/* received an interrupt request on a shared IRQ line
 	 * first check whether the device is in sleep mode */
 	reg = readl(device + ISL38XX_CTRL_STAT_REG);
@@ -195,14 +198,10 @@
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		DEBUG(SHOW_TRACING, "Assuming someone else called the IRQ\n");
 #endif
+		spin_unlock(&priv->slock);
 		return IRQ_NONE;
 	}
 
-	if (islpci_get_state(priv) != PRV_STATE_SLEEP)
-		powerstate = ISL38XX_PSM_ACTIVE_STATE;
-
-	/* lock the interrupt handler */
-	spin_lock(&priv->slock);
 
 	/* check whether there is any source of interrupt on the device */
 	reg = readl(device + ISL38XX_INT_IDENT_REG);
@@ -213,6 +212,9 @@
 	reg &= ISL38XX_INT_SOURCES;
 
 	if (reg != 0) {
+		if (islpci_get_state(priv) != PRV_STATE_SLEEP)
+			powerstate = ISL38XX_PSM_ACTIVE_STATE;
+
 		/* reset the request bits in the Identification register */
 		isl38xx_w32_flush(device, reg, ISL38XX_INT_ACK_REG);
 
@@ -340,6 +342,12 @@
 			isl38xx_handle_wakeup(priv->control_block,
 					      &powerstate, priv->device_base);
 		}
+	} else {
+#if VERBOSE > SHOW_ERROR_MESSAGES
+		DEBUG(SHOW_TRACING, "Assuming someone else called the IRQ\n");
+#endif
+		spin_unlock(&priv->slock);
+		return IRQ_NONE;
 	}
 
 	/* sleep -> ready */

--Boundary-00=_eWgCBKI6CxpnqJ1
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_eWgCBKI6CxpnqJ1--
