From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH] caif: Remove OOM messages, use kzalloc
Date: Thu, 25 Aug 2011 16:22:24 -0700
Message-ID: <1314314545.4637.19.camel@Joe-Laptop>
References: <1314305243.4637.10.camel@Joe-Laptop>
	 <20110825150456.fc8720c4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110825150456.fc8720c4.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove per site OOM messages because they duplicate
the generic mm subsystem OOM message.

Use kzalloc instead of kmalloc/memset
when next to the OOM message removals.

Reduces object size (allyesconfig ~2%)

$ size -t drivers/net/caif/built-in.o.old net/caif/built-in.o.old
   text	   data	    bss	    dec	    hex	filename
  32297	    700	   8224	  41221	   a105	drivers/net/caif/built-in.o.old
  72159	   1317	  20552	  94028	  16f4c	net/caif/built-in.o.old
 104456	   2017	  28776	 135249	  21051	(TOTALS)
$ size -t drivers/net/caif/built-in.o.new net/caif/built-in.o.new
   text	   data	    bss	    dec	    hex	filename
  31975	    700	   8184	  40859	   9f9b	drivers/net/caif/built-in.o.new
  70748	   1317	  20152	  92217	  16839	net/caif/built-in.o.new
 102723	   2017	  28336	 133076	  207d4	(TOTALS)

Signed-off-by: Joe Perches <joe@perches.com>

---

This is a sample of OOM message removal.

On Thu, 2011-08-25 at 15:04 -0700, Andrew Morton wrote:
> On Thu, 25 Aug 2011 13:47:23 -0700 Joe Perches <joe@perches.com> wrote:
> > There are many thousands of printks for OOM conditions
> > in kernel sources.
> > These are almost always a duplication of a generic
> > OOM message from the mm subsystem.
> > The biggest difference between the generic OOM and
> > the specific OOM uses is that most of the specific
> > messages are emitted at KERN_ERR but the generic
> > message is at KERN_WARNING.
> > Many KB of code/text could be removed from the kernel.
> > Removal can be gradual and done by subsystem.
> > Some kmalloc's that are followed on failure by vmalloc
> > may need to add GFP_NOWARN.
> > Does anyone really believe the per site failure
> > messages are useful or really want them to keep them?
> Kill 'em.

 drivers/net/caif/caif_hsi.c |    9 +--------
 drivers/net/caif/caif_spi.c |    4 ----
 net/caif/cfcnfg.c           |   15 +++------------
 net/caif/cfctrl.c           |   23 ++++++-----------------
 net/caif/cfdbgl.c           |    7 ++-----
 net/caif/cfdgml.c           |    7 ++-----
 net/caif/cffrml.c           |    7 ++-----
 net/caif/cfrfml.c           |    7 ++-----
 net/caif/cfserl.c           |    7 ++-----
 net/caif/cfsrvl.c           |    8 ++------
 net/caif/cfutill.c          |    7 ++-----
 net/caif/cfveil.c           |    7 ++-----
 net/caif/cfvidl.c           |    7 ++-----
 13 files changed, 28 insertions(+), 87 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index b41c2fc..2fcabba 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -937,11 +937,8 @@ int cfhsi_probe(struct platform_device *pdev)
 	int res;
 
 	ndev = alloc_netdev(sizeof(struct cfhsi), "cfhsi%d", cfhsi_setup);
-	if (!ndev) {
-		dev_err(&pdev->dev, "%s: alloc_netdev failed.\n",
-			__func__);
+	if (!ndev)
 		return -ENODEV;
-	}
 
 	cfhsi = netdev_priv(ndev);
 	cfhsi->ndev = ndev;
@@ -969,8 +966,6 @@ int cfhsi_probe(struct platform_device *pdev)
 	 */
 	cfhsi->tx_buf = kzalloc(CFHSI_BUF_SZ_TX, GFP_KERNEL);
 	if (!cfhsi->tx_buf) {
-		dev_err(&ndev->dev, "%s: Failed to allocate TX buffer.\n",
-			__func__);
 		res = -ENODEV;
 		goto err_alloc_tx;
 	}
@@ -981,8 +976,6 @@ int cfhsi_probe(struct platform_device *pdev)
 	 */
 	cfhsi->rx_buf = kzalloc(CFHSI_BUF_SZ_RX, GFP_KERNEL);
 	if (!cfhsi->rx_buf) {
-		dev_err(&ndev->dev, "%s: Failed to allocate RX buffer.\n",
-			__func__);
 		res = -ENODEV;
 		goto err_alloc_rx;
 	}
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 0f8defc..05e791f 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -664,8 +664,6 @@ int cfspi_spi_probe(struct platform_device *pdev)
 	/* Allocate DMA buffers. */
 	cfspi->xfer.va_tx = dma_alloc(&cfspi->xfer.pa_tx);
 	if (!cfspi->xfer.va_tx) {
-		printk(KERN_WARNING
-		       "CFSPI: failed to allocate dma TX buffer.\n");
 		res = -ENODEV;
 		goto err_dma_alloc_tx;
 	}
@@ -673,8 +671,6 @@ int cfspi_spi_probe(struct platform_device *pdev)
 	cfspi->xfer.va_rx = dma_alloc(&cfspi->xfer.pa_rx);
 
 	if (!cfspi->xfer.va_rx) {
-		printk(KERN_WARNING
-		       "CFSPI: failed to allocate dma TX buffer.\n");
 		res = -ENODEV;
 		goto err_dma_alloc_rx;
 	}
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 52fe33b..f07ab8c 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -78,10 +78,8 @@ struct cfcnfg *cfcnfg_create(void)
 
 	/* Initiate this layer */
 	this = kzalloc(sizeof(struct cfcnfg), GFP_ATOMIC);
-	if (!this) {
-		pr_warn("Out of memory\n");
+	if (!this)
 		return NULL;
-	}
 	this->mux = cfmuxl_create();
 	if (!this->mux)
 		goto out_of_mem;
@@ -108,8 +106,6 @@ struct cfcnfg *cfcnfg_create(void)
 
 	return this;
 out_of_mem:
-	pr_warn("Out of memory\n");
-
 	synchronize_rcu();
 
 	kfree(this->mux);
@@ -448,10 +444,8 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 				"- unknown channel type\n");
 		goto unlock;
 	}
-	if (!servicel) {
-		pr_warn("Out of memory\n");
+	if (!servicel)
 		goto unlock;
-	}
 	layer_set_dn(servicel, cnfg->mux);
 	cfmuxl_set_uplayer(cnfg->mux, servicel, channel_id);
 	layer_set_up(servicel, adapt_layer);
@@ -497,10 +491,8 @@ got_phyid:
 	case CFPHYTYPE_FRAG:
 		phy_driver =
 		    cfserl_create(CFPHYTYPE_FRAG, phyid, stx);
-		if (!phy_driver) {
-			pr_warn("Out of memory\n");
+		if (!phy_driver)
 			goto out;
-		}
 		break;
 	case CFPHYTYPE_CAIF:
 		phy_driver = NULL;
@@ -521,7 +513,6 @@ got_phyid:
 	frml = cffrml_create(phyid, fcs);
 
 	if (!frml) {
-		pr_warn("Out of memory\n");
 		kfree(phyinfo);
 		goto out;
 	}
diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index e22671b..5cf5222 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -35,15 +35,12 @@ struct cflayer *cfctrl_create(void)
 {
 	struct dev_info dev_info;
 	struct cfctrl *this =
-		kmalloc(sizeof(struct cfctrl), GFP_ATOMIC);
-	if (!this) {
-		pr_warn("Out of memory\n");
+		kzalloc(sizeof(struct cfctrl), GFP_ATOMIC);
+	if (!this)
 		return NULL;
-	}
 	caif_assert(offsetof(struct cfctrl, serv.layer) == 0);
 	memset(&dev_info, 0, sizeof(dev_info));
 	dev_info.id = 0xff;
-	memset(this, 0, sizeof(*this));
 	cfsrvl_init(&this->serv, 0, &dev_info, false);
 	atomic_set(&this->req_seq_no, 1);
 	atomic_set(&this->rsp_seq_no, 1);
@@ -180,10 +177,8 @@ void cfctrl_enum_req(struct cflayer *layer, u8 physlinkid)
 	struct cfctrl *cfctrl = container_obj(layer);
 	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	struct cflayer *dn = cfctrl->serv.layer.dn;
-	if (!pkt) {
-		pr_warn("Out of memory\n");
+	if (!pkt)
 		return;
-	}
 	if (!dn) {
 		pr_debug("not able to send enum request\n");
 		return;
@@ -224,10 +219,8 @@ int cfctrl_linkup_request(struct cflayer *layer,
 	}
 
 	pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
-	if (!pkt) {
-		pr_warn("Out of memory\n");
+	if (!pkt)
 		return -ENOMEM;
-	}
 	cfpkt_addbdy(pkt, CFCTRL_CMD_LINK_SETUP);
 	cfpkt_addbdy(pkt, (param->chtype << 4) | param->linktype);
 	cfpkt_addbdy(pkt, (param->priority << 3) | param->phyid);
@@ -275,10 +268,8 @@ int cfctrl_linkup_request(struct cflayer *layer,
 		return -EINVAL;
 	}
 	req = kzalloc(sizeof(*req), GFP_KERNEL);
-	if (!req) {
-		pr_warn("Out of memory\n");
+	if (!req)
 		return -ENOMEM;
-	}
 	req->client_layer = user_layer;
 	req->cmd = CFCTRL_CMD_LINK_SETUP;
 	req->param = *param;
@@ -312,10 +303,8 @@ int cfctrl_linkdown_req(struct cflayer *layer, u8 channelid,
 	struct cfpkt *pkt = cfpkt_create(CFPKT_CTRL_PKT_LEN);
 	struct cflayer *dn = cfctrl->serv.layer.dn;
 
-	if (!pkt) {
-		pr_warn("Out of memory\n");
+	if (!pkt)
 		return -ENOMEM;
-	}
 
 	if (!dn) {
 		pr_debug("not able to send link-down request\n");
diff --git a/net/caif/cfdbgl.c b/net/caif/cfdbgl.c
index 11a2af4..65d6ef3 100644
--- a/net/caif/cfdbgl.c
+++ b/net/caif/cfdbgl.c
@@ -19,13 +19,10 @@ static int cfdbgl_transmit(struct cflayer *layr, struct cfpkt *pkt);
 
 struct cflayer *cfdbgl_create(u8 channel_id, struct dev_info *dev_info)
 {
-	struct cfsrvl *dbg = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
-	if (!dbg) {
-		pr_warn("Out of memory\n");
+	struct cfsrvl *dbg = kzalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!dbg)
 		return NULL;
-	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
-	memset(dbg, 0, sizeof(struct cfsrvl));
 	cfsrvl_init(dbg, channel_id, dev_info, false);
 	dbg->layer.receive = cfdbgl_receive;
 	dbg->layer.transmit = cfdbgl_transmit;
diff --git a/net/caif/cfdgml.c b/net/caif/cfdgml.c
index 0382dec..0f5ff27 100644
--- a/net/caif/cfdgml.c
+++ b/net/caif/cfdgml.c
@@ -26,13 +26,10 @@ static int cfdgml_transmit(struct cflayer *layr, struct cfpkt *pkt);
 
 struct cflayer *cfdgml_create(u8 channel_id, struct dev_info *dev_info)
 {
-	struct cfsrvl *dgm = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
-	if (!dgm) {
-		pr_warn("Out of memory\n");
+	struct cfsrvl *dgm = kzalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!dgm)
 		return NULL;
-	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
-	memset(dgm, 0, sizeof(struct cfsrvl));
 	cfsrvl_init(dgm, channel_id, dev_info, true);
 	dgm->layer.receive = cfdgml_receive;
 	dgm->layer.transmit = cfdgml_transmit;
diff --git a/net/caif/cffrml.c b/net/caif/cffrml.c
index 04204b2..f399211 100644
--- a/net/caif/cffrml.c
+++ b/net/caif/cffrml.c
@@ -34,11 +34,9 @@ static u32 cffrml_rcv_error;
 static u32 cffrml_rcv_checsum_error;
 struct cflayer *cffrml_create(u16 phyid, bool use_fcs)
 {
-	struct cffrml *this = kmalloc(sizeof(struct cffrml), GFP_ATOMIC);
-	if (!this) {
-		pr_warn("Out of memory\n");
+	struct cffrml *this = kzalloc(sizeof(struct cffrml), GFP_ATOMIC);
+	if (!this)
 		return NULL;
-	}
 	this->pcpu_refcnt = alloc_percpu(int);
 	if (this->pcpu_refcnt == NULL) {
 		kfree(this);
@@ -47,7 +45,6 @@ struct cflayer *cffrml_create(u16 phyid, bool use_fcs)
 
 	caif_assert(offsetof(struct cffrml, layer) == 0);
 
-	memset(this, 0, sizeof(struct cflayer));
 	this->layer.receive = cffrml_receive;
 	this->layer.transmit = cffrml_transmit;
 	this->layer.ctrlcmd = cffrml_ctrlcmd;
diff --git a/net/caif/cfrfml.c b/net/caif/cfrfml.c
index 0deabb4..81660f8 100644
--- a/net/caif/cfrfml.c
+++ b/net/caif/cfrfml.c
@@ -46,13 +46,10 @@ struct cflayer *cfrfml_create(u8 channel_id, struct dev_info *dev_info,
 					int mtu_size)
 {
 	int tmp;
-	struct cfrfml *this =
-		kzalloc(sizeof(struct cfrfml), GFP_ATOMIC);
+	struct cfrfml *this = kzalloc(sizeof(struct cfrfml), GFP_ATOMIC);
 
-	if (!this) {
-		pr_warn("Out of memory\n");
+	if (!this)
 		return NULL;
-	}
 
 	cfsrvl_init(&this->serv, channel_id, dev_info, false);
 	this->serv.release = cfrfml_release;
diff --git a/net/caif/cfserl.c b/net/caif/cfserl.c
index 2715c84..797c8d1 100644
--- a/net/caif/cfserl.c
+++ b/net/caif/cfserl.c
@@ -33,13 +33,10 @@ static void cfserl_ctrlcmd(struct cflayer *layr, enum caif_ctrlcmd ctrl,
 
 struct cflayer *cfserl_create(int type, int instance, bool use_stx)
 {
-	struct cfserl *this = kmalloc(sizeof(struct cfserl), GFP_ATOMIC);
-	if (!this) {
-		pr_warn("Out of memory\n");
+	struct cfserl *this = kzalloc(sizeof(struct cfserl), GFP_ATOMIC);
+	if (!this)
 		return NULL;
-	}
 	caif_assert(offsetof(struct cfserl, layer) == 0);
-	memset(this, 0, sizeof(struct cfserl));
 	this->layer.receive = cfserl_receive;
 	this->layer.transmit = cfserl_transmit;
 	this->layer.ctrlcmd = cfserl_ctrlcmd;
diff --git a/net/caif/cfsrvl.c b/net/caif/cfsrvl.c
index 535a1e7..b99f5b2 100644
--- a/net/caif/cfsrvl.c
+++ b/net/caif/cfsrvl.c
@@ -108,10 +108,8 @@ static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 			struct caif_payload_info *info;
 			u8 flow_on = SRVL_FLOW_ON;
 			pkt = cfpkt_create(SRVL_CTRL_PKT_SIZE);
-			if (!pkt) {
-				pr_warn("Out of memory\n");
+			if (!pkt)
 				return -ENOMEM;
-			}
 
 			if (cfpkt_add_head(pkt, &flow_on, 1) < 0) {
 				pr_err("Packet is erroneous!\n");
@@ -130,10 +128,8 @@ static int cfservl_modemcmd(struct cflayer *layr, enum caif_modemcmd ctrl)
 			struct caif_payload_info *info;
 			u8 flow_off = SRVL_FLOW_OFF;
 			pkt = cfpkt_create(SRVL_CTRL_PKT_SIZE);
-			if (!pkt) {
-				pr_warn("Out of memory\n");
+			if (!pkt)
 				return -ENOMEM;
-			}
 
 			if (cfpkt_add_head(pkt, &flow_off, 1) < 0) {
 				pr_err("Packet is erroneous!\n");
diff --git a/net/caif/cfutill.c b/net/caif/cfutill.c
index 98e027d..53e49f3 100644
--- a/net/caif/cfutill.c
+++ b/net/caif/cfutill.c
@@ -26,13 +26,10 @@ static int cfutill_transmit(struct cflayer *layr, struct cfpkt *pkt);
 
 struct cflayer *cfutill_create(u8 channel_id, struct dev_info *dev_info)
 {
-	struct cfsrvl *util = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
-	if (!util) {
-		pr_warn("Out of memory\n");
+	struct cfsrvl *util = kzalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!util)
 		return NULL;
-	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
-	memset(util, 0, sizeof(struct cfsrvl));
 	cfsrvl_init(util, channel_id, dev_info, true);
 	util->layer.receive = cfutill_receive;
 	util->layer.transmit = cfutill_transmit;
diff --git a/net/caif/cfveil.c b/net/caif/cfveil.c
index 3ec83fb..910ab06 100644
--- a/net/caif/cfveil.c
+++ b/net/caif/cfveil.c
@@ -25,13 +25,10 @@ static int cfvei_transmit(struct cflayer *layr, struct cfpkt *pkt);
 
 struct cflayer *cfvei_create(u8 channel_id, struct dev_info *dev_info)
 {
-	struct cfsrvl *vei = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
-	if (!vei) {
-		pr_warn("Out of memory\n");
+	struct cfsrvl *vei = kzalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!vei)
 		return NULL;
-	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
-	memset(vei, 0, sizeof(struct cfsrvl));
 	cfsrvl_init(vei, channel_id, dev_info, true);
 	vei->layer.receive = cfvei_receive;
 	vei->layer.transmit = cfvei_transmit;
diff --git a/net/caif/cfvidl.c b/net/caif/cfvidl.c
index b2f5989..e3f37db 100644
--- a/net/caif/cfvidl.c
+++ b/net/caif/cfvidl.c
@@ -21,14 +21,11 @@ static int cfvidl_transmit(struct cflayer *layr, struct cfpkt *pkt);
 
 struct cflayer *cfvidl_create(u8 channel_id, struct dev_info *dev_info)
 {
-	struct cfsrvl *vid = kmalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
-	if (!vid) {
-		pr_warn("Out of memory\n");
+	struct cfsrvl *vid = kzalloc(sizeof(struct cfsrvl), GFP_ATOMIC);
+	if (!vid)
 		return NULL;
-	}
 	caif_assert(offsetof(struct cfsrvl, layer) == 0);
 
-	memset(vid, 0, sizeof(struct cfsrvl));
 	cfsrvl_init(vid, channel_id, dev_info, false);
 	vid->layer.receive = cfvidl_receive;
 	vid->layer.transmit = cfvidl_transmit;
-- 
1.7.6.405.gc1be0
