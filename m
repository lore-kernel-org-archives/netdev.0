From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH 1/3] r8169: non-NAPI netif_poll_disable removal
Date: Tue, 2 Nov 2004 12:03:17 -0600
Message-ID: <200411021203.17013.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_lv8hBxmERC1vq5H"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_lv8hBxmERC1vq5H
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

rtl8169_close contains a call to netif_poll_disable.  This call sets and spins 
on the __LINK_STATE_RX_SCHED bit, which isn't really a problem if this 
function is only called in close (as that bit is off with NAPI off).  
However, if the driver hits a transmit timeout (or any other call that 
references rtl8169_wait_for_quiescence), the the module will hang 
indefinitely during any subsequent call to netif_poll_disable or dev_close 
function call because this bit is now set.

Since this function should not really be called with NAPI off, I chose to 
remove the calls if NAPI is not defined (See patch below).  The patch is 
against the 2.6.10-rc1-mm2 version of the driver.  I have verified that this 
fixes the problem on ppc64 and x86_64.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>

--- r8169.c.orig        2004-11-02 10:21:31.305104272 -0600
+++ r8169.c     2004-11-02 10:25:56.849735352 -0600
@@ -85,10 +85,12 @@ VERSION 1.6LK       <2004/04/14>
 #define rtl8169_rx_skb                 netif_receive_skb
 #define rtl8169_rx_hwaccel_skb         vlan_hwaccel_rx
 #define rtl8169_rx_quota(count, quota) min(count, quota)
+#define rtl8169_poll_disable(dev)      netif_poll_disable(dev)
 #else
 #define rtl8169_rx_skb                 netif_rx
 #define rtl8169_rx_hwaccel_skb         vlan_hwaccel_receive_skb
 #define rtl8169_rx_quota(count, quota) count
+#define rtl8169_poll_disable(dev)
 #endif

 /* media options */
@@ -1745,7 +1747,7 @@ static void rtl8169_wait_for_quiescence(
        synchronize_irq(dev->irq);

        /* Wait for any pending NAPI task to complete */
-       netif_poll_disable(dev);
+       rtl8169_poll_disable(dev);
 }

 static void rtl8169_reinit_task(void *_data)
@@ -2284,7 +2286,7 @@ rtl8169_close(struct net_device *dev)

        free_irq(dev->irq, dev);

-       netif_poll_disable(dev);
+       rtl8169_poll_disable(dev);

        rtl8169_tx_clear(tp);

--Boundary-00=_lv8hBxmERC1vq5H
Content-Type: text/x-diff;
  charset="us-ascii";
  name="r8169-close-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="r8169-close-1.patch"

--- r8169.c.orig	2004-11-02 10:21:31.305104272 -0600
+++ r8169.c	2004-11-02 10:25:56.849735352 -0600
@@ -85,10 +85,12 @@ VERSION 1.6LK	<2004/04/14>
 #define rtl8169_rx_skb			netif_receive_skb
 #define rtl8169_rx_hwaccel_skb		vlan_hwaccel_rx
 #define rtl8169_rx_quota(count, quota)	min(count, quota)
+#define rtl8169_poll_disable(dev)	netif_poll_disable(dev)
 #else
 #define rtl8169_rx_skb			netif_rx
 #define rtl8169_rx_hwaccel_skb		vlan_hwaccel_receive_skb
 #define rtl8169_rx_quota(count, quota)	count
+#define rtl8169_poll_disable(dev)
 #endif
 
 /* media options */
@@ -1745,7 +1747,7 @@ static void rtl8169_wait_for_quiescence(
 	synchronize_irq(dev->irq);
 
 	/* Wait for any pending NAPI task to complete */
-	netif_poll_disable(dev);
+	rtl8169_poll_disable(dev);
 }
 
 static void rtl8169_reinit_task(void *_data)
@@ -2284,7 +2286,7 @@ rtl8169_close(struct net_device *dev)
 
 	free_irq(dev->irq, dev);
 
-	netif_poll_disable(dev);
+	rtl8169_poll_disable(dev);
 
 	rtl8169_tx_clear(tp);
 

--Boundary-00=_lv8hBxmERC1vq5H--
