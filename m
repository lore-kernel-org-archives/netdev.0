From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 19/31] timer: Remove open-coded casts for .data and .function
Date: Thu, 31 Aug 2017 16:29:31 -0700
Message-ID: <1504222183-61202-20-git-send-email-keescook@chromium.org>
References: <1504222183-61202-1-git-send-email-keescook@chromium.org>
Cc: Samuel Ortiz <samuel@sortiz.org>,
 "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
 Kees Cook <keescook@chromium.org>,
 "Martin K. Petersen" <martin.petersen@oracle.com>,
 linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org,
 netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
 Tyrel Datwyler <tyreld@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1504222183-61202-1-git-send-email-keescook@chromium.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

This standardizes the callback and data prototypes in several places that
perform casting, in an effort to remove more open-coded .data and
.function uses in favor of setup_timer().

Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: Tyrel Datwyler <tyreld@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: netdev@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/irda/bfin_sir.c      |  5 +++--
 drivers/scsi/ibmvscsi/ibmvfc.c   | 14 ++++++--------
 drivers/scsi/ibmvscsi/ibmvscsi.c |  8 ++++----
 3 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index 3151b580dbd6..c9413bd580a7 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -317,8 +317,9 @@ static void bfin_sir_dma_rx_chars(struct net_device *dev)
 		async_unwrap_char(dev, &self->stats, &self->rx_buff, port->rx_dma_buf.buf[i]);
 }
 
-void bfin_sir_rx_dma_timeout(struct net_device *dev)
+void bfin_sir_rx_dma_timeout(unsigned long data)
 {
+	struct net_device *dev = (struct net_device *)data;
 	struct bfin_sir_self *self = netdev_priv(dev);
 	struct bfin_sir_port *port = self->sir_port;
 	int x_pos, pos;
@@ -406,7 +407,7 @@ static int bfin_sir_startup(struct bfin_sir_port *port, struct net_device *dev)
 	enable_dma(port->rx_dma_channel);
 
 	port->rx_dma_timer.data = (unsigned long)(dev);
-	port->rx_dma_timer.function = (void *)bfin_sir_rx_dma_timeout;
+	port->rx_dma_timer.function = bfin_sir_rx_dma_timeout;
 
 #else
 
diff --git a/drivers/scsi/ibmvscsi/ibmvfc.c b/drivers/scsi/ibmvscsi/ibmvfc.c
index cc4e05be8d4a..1be20688dd1f 100644
--- a/drivers/scsi/ibmvscsi/ibmvfc.c
+++ b/drivers/scsi/ibmvscsi/ibmvfc.c
@@ -1393,8 +1393,9 @@ static int ibmvfc_map_sg_data(struct scsi_cmnd *scmd,
  *
  * Called when an internally generated command times out
  **/
-static void ibmvfc_timeout(struct ibmvfc_event *evt)
+static void ibmvfc_timeout(unsigned long data)
 {
+	struct ibmvfc_event *evt = (struct ibmvfc_event *)data;
 	struct ibmvfc_host *vhost = evt->vhost;
 	dev_err(vhost->dev, "Command timed out (%p). Resetting connection\n", evt);
 	ibmvfc_reset_host(vhost);
@@ -1424,12 +1425,10 @@ static int ibmvfc_send_event(struct ibmvfc_event *evt,
 		BUG();
 
 	list_add_tail(&evt->queue, &vhost->sent);
-	init_timer(&evt->timer);
+	setup_timer(&evt->timer, ibmvfc_timeout, (unsigned long)evt);
 
 	if (timeout) {
-		evt->timer.data = (unsigned long) evt;
 		evt->timer.expires = jiffies + (timeout * HZ);
-		evt->timer.function = (void (*)(unsigned long))ibmvfc_timeout;
 		add_timer(&evt->timer);
 	}
 
@@ -3696,8 +3695,9 @@ static void ibmvfc_tgt_adisc_cancel_done(struct ibmvfc_event *evt)
  * out, reset the CRQ. When the ADISC comes back as cancelled,
  * log back into the target.
  **/
-static void ibmvfc_adisc_timeout(struct ibmvfc_target *tgt)
+static void ibmvfc_adisc_timeout(unsigned long data)
 {
+	struct ibmvfc_target *tgt = (struct ibmvfc_target *)data;
 	struct ibmvfc_host *vhost = tgt->vhost;
 	struct ibmvfc_event *evt;
 	struct ibmvfc_tmf *tmf;
@@ -3782,9 +3782,7 @@ static void ibmvfc_tgt_adisc(struct ibmvfc_target *tgt)
 	if (timer_pending(&tgt->timer))
 		mod_timer(&tgt->timer, jiffies + (IBMVFC_ADISC_TIMEOUT * HZ));
 	else {
-		tgt->timer.data = (unsigned long) tgt;
 		tgt->timer.expires = jiffies + (IBMVFC_ADISC_TIMEOUT * HZ);
-		tgt->timer.function = (void (*)(unsigned long))ibmvfc_adisc_timeout;
 		add_timer(&tgt->timer);
 	}
 
@@ -3916,7 +3914,7 @@ static int ibmvfc_alloc_target(struct ibmvfc_host *vhost, u64 scsi_id)
 	tgt->vhost = vhost;
 	tgt->need_login = 1;
 	tgt->cancel_key = vhost->task_set++;
-	init_timer(&tgt->timer);
+	setup_timer(&tgt->timer, ibmvfc_adisc_timeout, (unsigned long)tgt);
 	kref_init(&tgt->kref);
 	ibmvfc_init_tgt(tgt, ibmvfc_tgt_implicit_logout);
 	spin_lock_irqsave(vhost->host->host_lock, flags);
diff --git a/drivers/scsi/ibmvscsi/ibmvscsi.c b/drivers/scsi/ibmvscsi/ibmvscsi.c
index da22b3665cb0..44ae85903a00 100644
--- a/drivers/scsi/ibmvscsi/ibmvscsi.c
+++ b/drivers/scsi/ibmvscsi/ibmvscsi.c
@@ -837,8 +837,9 @@ static void ibmvscsi_reset_host(struct ibmvscsi_host_data *hostdata)
  *
  * Called when an internally generated command times out
 */
-static void ibmvscsi_timeout(struct srp_event_struct *evt_struct)
+static void ibmvscsi_timeout(unsigned long data)
 {
+	struct srp_event_struct *evt_struct = (struct srp_event_struct *)data;
 	struct ibmvscsi_host_data *hostdata = evt_struct->hostdata;
 
 	dev_err(hostdata->dev, "Command timed out (%x). Resetting connection\n",
@@ -927,11 +928,10 @@ static int ibmvscsi_send_srp_event(struct srp_event_struct *evt_struct,
 	 */
 	list_add_tail(&evt_struct->list, &hostdata->sent);
 
-	init_timer(&evt_struct->timer);
+	setup_timer(&evt_struct->timer, ibmvscsi_timeout,
+		    (unsigned long)evt_struct);
 	if (timeout) {
-		evt_struct->timer.data = (unsigned long) evt_struct;
 		evt_struct->timer.expires = jiffies + (timeout * HZ);
-		evt_struct->timer.function = (void (*)(unsigned long))ibmvscsi_timeout;
 		add_timer(&evt_struct->timer);
 	}
 
-- 
2.7.4
