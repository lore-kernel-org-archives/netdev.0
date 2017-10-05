From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net/wireless/ray_cs: Convert timers to use
Date: Wed, 4 Oct 2017 17:50:20 -0700
Message-ID: <20171005005020.GA23219@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/wireless/ray_cs.c | 53 ++++++++++++++++++++-----------------------
 1 file changed, 24 insertions(+), 29 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 170cd504e8ff..d8afcdfca1ed 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -92,7 +92,7 @@ static const struct iw_handler_def ray_handler_def;
 /***** Prototypes for raylink functions **************************************/
 static void authenticate(ray_dev_t *local);
 static int build_auth_frame(ray_dev_t *local, UCHAR *dest, int auth_type);
-static void authenticate_timeout(u_long);
+static void authenticate_timeout(struct timer_list *t);
 static int get_free_ccs(ray_dev_t *local);
 static int get_free_tx_ccs(ray_dev_t *local);
 static void init_startup_params(ray_dev_t *local);
@@ -102,7 +102,7 @@ static int ray_init(struct net_device *dev);
 static int interrupt_ecf(ray_dev_t *local, int ccs);
 static void ray_reset(struct net_device *dev);
 static void ray_update_parm(struct net_device *dev, UCHAR objid, UCHAR *value, int len);
-static void verify_dl_startup(u_long);
+static void verify_dl_startup(struct timer_list *t);
 
 /* Prototypes for interrpt time functions **********************************/
 static irqreturn_t ray_interrupt(int reg, void *dev_id);
@@ -120,9 +120,8 @@ static void associate(ray_dev_t *local);
 
 /* Card command functions */
 static int dl_startup_params(struct net_device *dev);
-static void join_net(u_long local);
-static void start_net(u_long local);
-/* void start_net(ray_dev_t *local); */
+static void join_net(struct timer_list *t);
+static void start_net(struct timer_list *t);
 
 /*===========================================================================*/
 /* Parameters that can be set with 'insmod' */
@@ -323,7 +322,7 @@ static int ray_probe(struct pcmcia_device *p_dev)
 	dev_dbg(&p_dev->dev, "ray_cs ray_attach calling ether_setup.)\n");
 	netif_stop_queue(dev);
 
-	init_timer(&local->timer);
+	timer_setup(&local->timer, NULL, 0);
 
 	this_device = p_dev;
 	return ray_config(p_dev);
@@ -570,8 +569,7 @@ static int dl_startup_params(struct net_device *dev)
 	local->card_status = CARD_DL_PARAM;
 	/* Start kernel timer to wait for dl startup to complete. */
 	local->timer.expires = jiffies + HZ / 2;
-	local->timer.data = (long)local;
-	local->timer.function = verify_dl_startup;
+	local->timer.function = (TIMER_FUNC_TYPE)verify_dl_startup;
 	add_timer(&local->timer);
 	dev_dbg(&link->dev,
 	      "ray_cs dl_startup_params started timer for verify_dl_startup\n");
@@ -641,9 +639,9 @@ static void init_startup_params(ray_dev_t *local)
 } /* init_startup_params */
 
 /*===========================================================================*/
-static void verify_dl_startup(u_long data)
+static void verify_dl_startup(struct timer_list *t)
 {
-	ray_dev_t *local = (ray_dev_t *) data;
+	ray_dev_t *local = from_timer(local, t, timer);
 	struct ccs __iomem *pccs = ccs_base(local) + local->dl_param_ccs;
 	UCHAR status;
 	struct pcmcia_device *link = local->finder;
@@ -676,16 +674,16 @@ static void verify_dl_startup(u_long data)
 		return;
 	}
 	if (local->sparm.b4.a_network_type == ADHOC)
-		start_net((u_long) local);
+		start_net(&local->timer);
 	else
-		join_net((u_long) local);
+		join_net(&local->timer);
 } /* end verify_dl_startup */
 
 /*===========================================================================*/
 /* Command card to start a network */
-static void start_net(u_long data)
+static void start_net(struct timer_list *t)
 {
-	ray_dev_t *local = (ray_dev_t *) data;
+	ray_dev_t *local = from_timer(local, t, timer);
 	struct ccs __iomem *pccs;
 	int ccsindex;
 	struct pcmcia_device *link = local->finder;
@@ -710,9 +708,9 @@ static void start_net(u_long data)
 
 /*===========================================================================*/
 /* Command card to join a network */
-static void join_net(u_long data)
+static void join_net(struct timer_list *t)
 {
-	ray_dev_t *local = (ray_dev_t *) data;
+	ray_dev_t *local = from_timer(local, t, timer);
 
 	struct ccs __iomem *pccs;
 	int ccsindex;
@@ -1639,13 +1637,13 @@ static int get_free_ccs(ray_dev_t *local)
 } /* get_free_ccs */
 
 /*===========================================================================*/
-static void authenticate_timeout(u_long data)
+static void authenticate_timeout(struct timer_list *t)
 {
-	ray_dev_t *local = (ray_dev_t *) data;
+	ray_dev_t *local = from_timer(local, t, timer);
 	del_timer(&local->timer);
 	printk(KERN_INFO "ray_cs Authentication with access point failed"
 	       " - timeout\n");
-	join_net((u_long) local);
+	join_net(&local->timer);
 }
 
 /*===========================================================================*/
@@ -1945,17 +1943,16 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 
 				del_timer(&local->timer);
 				local->timer.expires = jiffies + HZ * 5;
-				local->timer.data = (long)local;
 				if (status == CCS_START_NETWORK) {
 					dev_dbg(&link->dev,
 					      "ray_cs interrupt network \"%s\" start failed\n",
 					      memtmp);
-					local->timer.function = start_net;
+					local->timer.function = (TIMER_FUNC_TYPE)start_net;
 				} else {
 					dev_dbg(&link->dev,
 					      "ray_cs interrupt network \"%s\" join failed\n",
 					      memtmp);
-					local->timer.function = join_net;
+					local->timer.function = (TIMER_FUNC_TYPE)join_net;
 				}
 				add_timer(&local->timer);
 			}
@@ -1967,7 +1964,7 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 			} else {
 				dev_dbg(&link->dev, "ray_cs association failed,\n");
 				local->card_status = CARD_ASSOC_FAILED;
-				join_net((u_long) local);
+				join_net(&local->timer);
 			}
 			break;
 		case CCS_TX_REQUEST:
@@ -2420,12 +2417,11 @@ static void authenticate(ray_dev_t *local)
 
 	del_timer(&local->timer);
 	if (build_auth_frame(local, local->bss_id, OPEN_AUTH_REQUEST)) {
-		local->timer.function = join_net;
+		local->timer.function = (TIMER_FUNC_TYPE)join_net;
 	} else {
-		local->timer.function = authenticate_timeout;
+		local->timer.function = (TIMER_FUNC_TYPE)authenticate_timeout;
 	}
 	local->timer.expires = jiffies + HZ * 2;
-	local->timer.data = (long)local;
 	add_timer(&local->timer);
 	local->authentication_state = AWAITING_RESPONSE;
 } /* end authenticate */
@@ -2468,7 +2464,7 @@ static void rx_authenticate(ray_dev_t *local, struct rcs __iomem *prcs,
 				} else {
 					pr_debug("Authentication refused\n");
 					local->card_status = CARD_AUTH_REFUSED;
-					join_net((u_long) local);
+					join_net(&local->timer);
 					local->authentication_state =
 					    UNAUTHENTICATED;
 				}
@@ -2506,8 +2502,7 @@ static void associate(ray_dev_t *local)
 
 		del_timer(&local->timer);
 		local->timer.expires = jiffies + HZ * 2;
-		local->timer.data = (long)local;
-		local->timer.function = join_net;
+		local->timer.function = (TIMER_FUNC_TYPE)join_net;
 		add_timer(&local->timer);
 		local->card_status = CARD_ASSOC_FAILED;
 		return;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
