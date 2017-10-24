From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: ethernet/sfc: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 01:45:59 -0700
Message-ID: <20171024084559.GA23827@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>,
        Eric Dumazet <edumazet@google.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Cc: Edward Cree <ecree@solarflare.com>
Cc: Bert Kenward <bkenward@solarflare.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jiri Pirko <jiri@mellanox.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/sfc/efx.c           |  6 ++----
 drivers/net/ethernet/sfc/efx.h           |  2 +-
 drivers/net/ethernet/sfc/falcon/efx.c    |  6 ++----
 drivers/net/ethernet/sfc/falcon/efx.h    |  2 +-
 drivers/net/ethernet/sfc/falcon/falcon.c | 11 ++++++-----
 drivers/net/ethernet/sfc/falcon/nic.h    |  2 ++
 drivers/net/ethernet/sfc/falcon/rx.c     |  4 ++--
 drivers/net/ethernet/sfc/mcdi.c          |  9 ++++-----
 drivers/net/ethernet/sfc/rx.c            |  4 ++--
 9 files changed, 22 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b9cb697b2818..8fdcf7aaf997 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -471,8 +471,7 @@ efx_alloc_channel(struct efx_nic *efx, int i, struct efx_channel *old_channel)
 
 	rx_queue = &channel->rx_queue;
 	rx_queue->efx = efx;
-	setup_timer(&rx_queue->slow_fill, efx_rx_slow_fill,
-		    (unsigned long)rx_queue);
+	timer_setup(&rx_queue->slow_fill, efx_rx_slow_fill, 0);
 
 	return channel;
 }
@@ -511,8 +510,7 @@ efx_copy_channel(const struct efx_channel *old_channel)
 	rx_queue = &channel->rx_queue;
 	rx_queue->buffer = NULL;
 	memset(&rx_queue->rxd, 0, sizeof(rx_queue->rxd));
-	setup_timer(&rx_queue->slow_fill, efx_rx_slow_fill,
-		    (unsigned long)rx_queue);
+	timer_setup(&rx_queue->slow_fill, efx_rx_slow_fill, 0);
 
 	return channel;
 }
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index d407adf59610..52c84b782901 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -46,7 +46,7 @@ void efx_remove_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_init_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_fini_rx_queue(struct efx_rx_queue *rx_queue);
 void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue, bool atomic);
-void efx_rx_slow_fill(unsigned long context);
+void efx_rx_slow_fill(struct timer_list *t);
 void __efx_rx_packet(struct efx_channel *channel);
 void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 		   unsigned int n_frags, unsigned int len, u16 flags);
diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
index 29614da91cbf..6685a66ee1a3 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.c
+++ b/drivers/net/ethernet/sfc/falcon/efx.c
@@ -449,8 +449,7 @@ ef4_alloc_channel(struct ef4_nic *efx, int i, struct ef4_channel *old_channel)
 
 	rx_queue = &channel->rx_queue;
 	rx_queue->efx = efx;
-	setup_timer(&rx_queue->slow_fill, ef4_rx_slow_fill,
-		    (unsigned long)rx_queue);
+	timer_setup(&rx_queue->slow_fill, ef4_rx_slow_fill, 0);
 
 	return channel;
 }
@@ -489,8 +488,7 @@ ef4_copy_channel(const struct ef4_channel *old_channel)
 	rx_queue = &channel->rx_queue;
 	rx_queue->buffer = NULL;
 	memset(&rx_queue->rxd, 0, sizeof(rx_queue->rxd));
-	setup_timer(&rx_queue->slow_fill, ef4_rx_slow_fill,
-		    (unsigned long)rx_queue);
+	timer_setup(&rx_queue->slow_fill, ef4_rx_slow_fill, 0);
 
 	return channel;
 }
diff --git a/drivers/net/ethernet/sfc/falcon/efx.h b/drivers/net/ethernet/sfc/falcon/efx.h
index 4f3bb30661ea..a4e4d8ea4078 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.h
+++ b/drivers/net/ethernet/sfc/falcon/efx.h
@@ -45,7 +45,7 @@ void ef4_remove_rx_queue(struct ef4_rx_queue *rx_queue);
 void ef4_init_rx_queue(struct ef4_rx_queue *rx_queue);
 void ef4_fini_rx_queue(struct ef4_rx_queue *rx_queue);
 void ef4_fast_push_rx_descriptors(struct ef4_rx_queue *rx_queue, bool atomic);
-void ef4_rx_slow_fill(unsigned long context);
+void ef4_rx_slow_fill(struct timer_list *t);
 void __ef4_rx_packet(struct ef4_channel *channel);
 void ef4_rx_packet(struct ef4_rx_queue *rx_queue, unsigned int index,
 		   unsigned int n_frags, unsigned int len, u16 flags);
diff --git a/drivers/net/ethernet/sfc/falcon/falcon.c b/drivers/net/ethernet/sfc/falcon/falcon.c
index 93c713c1f627..ccda017b6794 100644
--- a/drivers/net/ethernet/sfc/falcon/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon/falcon.c
@@ -1454,10 +1454,11 @@ static void falcon_stats_complete(struct ef4_nic *efx)
 	}
 }
 
-static void falcon_stats_timer_func(unsigned long context)
+static void falcon_stats_timer_func(struct timer_list *t)
 {
-	struct ef4_nic *efx = (struct ef4_nic *)context;
-	struct falcon_nic_data *nic_data = efx->nic_data;
+	struct falcon_nic_data *nic_data = from_timer(nic_data, t,
+						      stats_timer);
+	struct ef4_nic *efx = nic_data->efx;
 
 	spin_lock(&efx->stats_lock);
 
@@ -2295,6 +2296,7 @@ static int falcon_probe_nic(struct ef4_nic *efx)
 	if (!nic_data)
 		return -ENOMEM;
 	efx->nic_data = nic_data;
+	nic_data->efx = efx;
 
 	rc = -ENODEV;
 
@@ -2402,8 +2404,7 @@ static int falcon_probe_nic(struct ef4_nic *efx)
 	}
 
 	nic_data->stats_disable_count = 1;
-	setup_timer(&nic_data->stats_timer, &falcon_stats_timer_func,
-		    (unsigned long)efx);
+	timer_setup(&nic_data->stats_timer, falcon_stats_timer_func, 0);
 
 	return 0;
 
diff --git a/drivers/net/ethernet/sfc/falcon/nic.h b/drivers/net/ethernet/sfc/falcon/nic.h
index a4c4592f6023..e2e3c008d073 100644
--- a/drivers/net/ethernet/sfc/falcon/nic.h
+++ b/drivers/net/ethernet/sfc/falcon/nic.h
@@ -267,6 +267,7 @@ enum {
 /**
  * struct falcon_nic_data - Falcon NIC state
  * @pci_dev2: Secondary function of Falcon A
+ * @efx: ef4_nic pointer
  * @board: Board state and functions
  * @stats: Hardware statistics
  * @stats_disable_count: Nest count for disabling statistics fetches
@@ -280,6 +281,7 @@ enum {
  */
 struct falcon_nic_data {
 	struct pci_dev *pci_dev2;
+	struct ef4_nic *efx;
 	struct falcon_board board;
 	u64 stats[FALCON_STAT_COUNT];
 	unsigned int stats_disable_count;
diff --git a/drivers/net/ethernet/sfc/falcon/rx.c b/drivers/net/ethernet/sfc/falcon/rx.c
index 6a8406dc0c2b..382019b302db 100644
--- a/drivers/net/ethernet/sfc/falcon/rx.c
+++ b/drivers/net/ethernet/sfc/falcon/rx.c
@@ -376,9 +376,9 @@ void ef4_fast_push_rx_descriptors(struct ef4_rx_queue *rx_queue, bool atomic)
 		ef4_nic_notify_rx_desc(rx_queue);
 }
 
-void ef4_rx_slow_fill(unsigned long context)
+void ef4_rx_slow_fill(struct timer_list *t)
 {
-	struct ef4_rx_queue *rx_queue = (struct ef4_rx_queue *)context;
+	struct ef4_rx_queue *rx_queue = from_timer(rx_queue, t, slow_fill);
 
 	/* Post an event to cause NAPI to run and refill the queue */
 	ef4_nic_generate_fill_event(rx_queue);
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 3df872f56289..9c2567b0d93e 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -48,7 +48,7 @@ struct efx_mcdi_async_param {
 	/* followed by request/response buffer */
 };
 
-static void efx_mcdi_timeout_async(unsigned long context);
+static void efx_mcdi_timeout_async(struct timer_list *t);
 static int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 			       bool *was_attached_out);
 static bool efx_mcdi_poll_once(struct efx_nic *efx);
@@ -87,8 +87,7 @@ int efx_mcdi_init(struct efx_nic *efx)
 	mcdi->mode = MCDI_MODE_POLL;
 	spin_lock_init(&mcdi->async_lock);
 	INIT_LIST_HEAD(&mcdi->async_list);
-	setup_timer(&mcdi->async_timer, efx_mcdi_timeout_async,
-		    (unsigned long)mcdi);
+	timer_setup(&mcdi->async_timer, efx_mcdi_timeout_async, 0);
 
 	(void) efx_mcdi_poll_reboot(efx);
 	mcdi->new_epoch = true;
@@ -608,9 +607,9 @@ static void efx_mcdi_ev_cpl(struct efx_nic *efx, unsigned int seqno,
 	}
 }
 
-static void efx_mcdi_timeout_async(unsigned long context)
+static void efx_mcdi_timeout_async(struct timer_list *t)
 {
-	struct efx_mcdi_iface *mcdi = (struct efx_mcdi_iface *)context;
+	struct efx_mcdi_iface *mcdi = from_timer(mcdi, t, async_timer);
 
 	efx_mcdi_complete_async(mcdi, true);
 }
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 42443f434569..8cb60513dca2 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -376,9 +376,9 @@ void efx_fast_push_rx_descriptors(struct efx_rx_queue *rx_queue, bool atomic)
 		efx_nic_notify_rx_desc(rx_queue);
 }
 
-void efx_rx_slow_fill(unsigned long context)
+void efx_rx_slow_fill(struct timer_list *t)
 {
-	struct efx_rx_queue *rx_queue = (struct efx_rx_queue *)context;
+	struct efx_rx_queue *rx_queue = from_timer(rx_queue, t, slow_fill);
 
 	/* Post an event to cause NAPI to run and refill the queue */
 	efx_nic_generate_fill_event(rx_queue);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
