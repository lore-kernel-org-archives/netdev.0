From: Aaron Young <Aaron.Young@oracle.com>
Subject: [PATCH net-next]ldmvsw: tx queue stuck in stopped state after LDC reset
Date: Wed, 26 Oct 2016 20:15:22 -0400
Message-ID: <b8d6abc7188e5cac885905854067444cb89a5f3b.1477503707.git.Aaron.Young@oracle.com>
Cc: sowmini.varadhan@oracle.com, aaron.young@oracle.com,
        Aaron Young <Aaron.Young@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46770 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935233AbcJ0ARQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 20:17:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   From: Aaron Young <aaron.young@oracle.com>

   The following patch fixes an issue with the ldmvsw driver where
   the network connection of a guest domain becomes non-functional after
   a guest domain has panic'd and rebooted (resulting in a LDC reset).

  The root cause was determined to be from the following series of
  events:

  1. Guest domain panics - resulting in the guest no longer fielding
     network packets from the ldmvsw driver
  2. The ldmvsw driver (in the control domain) eventually exerts flow
     control due to no more available tx drings and stops the tx queue
     for the guest domain
  3. The LDC of the network connection for the guest is reset when
     the guest domain reboots after the panic.
  4. The LDC reset event is received by the ldmvsw driver and the ldmvsw
     responds by clearing the tx queue for the guest.
  5. The guest is eventually rebooted and ldmvsw waits indefinitely for a
     DATA ACK from the guest - which is the normal method to re-enable
     the tx queue. But the ACK never comes because the tx queue was cleared
     due to the LDC reset.

  Fix is, in addition to clearing the tx queue, to re-enable the tx queue
  on a LDC reset. This prevents the ldmvsw from getting caught in this deadlocked
  state of waiting for a DATA ACK which will never come.

Signed-off-by: Aaron Young <Aaron.Young@oracle.com>
Acked-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet_common.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index 58efe69..8878b75 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -704,9 +704,8 @@ static int handle_mcast(struct vnet_port *port, void *msgbuf)
 	return 0;
 }
 
-/* Got back a STOPPED LDC message on port. If the queue is stopped,
- * wake it up so that we'll send out another START message at the
- * next TX.
+/* If the queue is stopped, wake it up so that we'll
+ * send out another START message at the next TX.
  */
 static void maybe_tx_wakeup(struct vnet_port *port)
 {
@@ -734,6 +733,7 @@ bool sunvnet_port_is_up_common(struct vnet_port *vnet)
 
 static int vnet_event_napi(struct vnet_port *port, int budget)
 {
+	struct net_device *dev = VNET_PORT_TO_NET_DEVICE(port);
 	struct vio_driver_state *vio = &port->vio;
 	int tx_wakeup, err;
 	int npkts = 0;
@@ -747,6 +747,16 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
 		if (event == LDC_EVENT_RESET) {
 			vnet_port_reset(port);
 			vio_port_up(vio);
+
+			/* If the device is running but its tx queue was
+			 * stopped (due to flow control), restart it.
+			 * This is necessary since vnet_port_reset()
+			 * clears the tx drings and thus we may never get
+			 * back a VIO_TYPE_DATA ACK packet - which is
+			 * the normal mechanism to restart the tx queue.
+			 */
+			if (netif_running(dev))
+				maybe_tx_wakeup(port);
 		}
 		port->rx_event = 0;
 		return 0;
-- 
1.7.1
