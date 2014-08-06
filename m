From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH] xen-netback: Change disable flag from bool to a
	bit
Date: Wed, 6 Aug 2014 19:16:13 +0100
Message-ID: <1407348973-2433-5-git-send-email-zoltan.kiss@citrix.com>
References: <1407348973-2433-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	David Vrabel <david.vrabel@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>, linux-kernel@vger.kernel.org
To: Wei Liu <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1407348973-2433-1-git-send-email-zoltan.kiss@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org 

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 5cb139a..f126920 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -106,7 +106,11 @@ enum vif_state_bit_shift {
 	/* This bit signals to the RX thread that queuing was stopped
 	 * (in start_xmit), and either the timer fired or an RX interrupt came
 	 */
-	VIF_STATUS_RX_PURGE_EVENT
+	VIF_STATUS_RX_PURGE_EVENT,
+	/* Is this interface disabled? True when backend discovers
+	 * frontend is rogue.
+	 */
+	VIF_STATUS_DISABLED
 };
 
 struct xenvif {
@@ -114,10 +118,6 @@ struct xenvif {
 	domid_t          domid;
 	unsigned int     handle;
 
-	/* Is this interface disabled? True when backend discovers
-	 * frontend is rogue.
-	 */
-	bool disabled;
 	unsigned long status;
 
 	/* Use NAPI for guest TX */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index e396d86..92e397c 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -70,7 +70,7 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 	 * We also turn off NAPI if the receive queue is stalled and the carrier
 	 * is turned off.
 	 */
-	if (unlikely(vif->disabled ||
+	if (unlikely(test_bit(VIF_STATUS_DISABLED, &vif->status) ||
 		     !netif_carrier_ok(vif->dev))) {
 		napi_complete(napi);
 		return 0;
@@ -352,8 +352,6 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif->ip_csum = 1;
 	vif->dev = dev;
 
-	vif->disabled = false;
-
 	vif->credit_bytes = vif->remaining_credit = ~0UL;
 	vif->credit_usec  = 0UL;
 	init_timer(&vif->credit_timeout);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 0737597..8b75b41 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -787,7 +787,7 @@ static void xenvif_tx_err(struct xenvif *vif,
 static void xenvif_fatal_tx_err(struct xenvif *vif)
 {
 	netdev_err(vif->dev, "fatal error; disabling device\n");
-	vif->disabled = true;
+	set_bit(VIF_STATUS_DISABLED, &vif->status);
 	xenvif_kick_thread(vif);
 }
 
@@ -1936,7 +1936,7 @@ int xenvif_kthread_guest_rx(void *data)
 	while (!kthread_should_stop()) {
 		wait_event_interruptible(vif->wq,
 					 rx_work_todo(vif) ||
-					 vif->disabled ||
+					 test_bit(VIF_STATUS_DISABLED, &vif->status) ||
 					 test_bit(VIF_STATUS_RX_PURGE_EVENT, &vif->status) ||
 					 kthread_should_stop());
 
@@ -1946,7 +1946,7 @@ int xenvif_kthread_guest_rx(void *data)
 		 * but we cannot disable the interface in softirq
 		 * context so we defer it here.
 		 */
-		if (unlikely(vif->disabled))
+		if (unlikely(test_and_clear_bit(VIF_STATUS_DISABLED, &vif->status)))
 			xenvif_carrier_off(vif);
 		else if (unlikely(test_and_clear_bit(VIF_STATUS_RX_PURGE_EVENT,
 						     &vif->status))) {
