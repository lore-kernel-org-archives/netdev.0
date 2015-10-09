From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/1] sfc: replace spinlocks with bit ops for busy
 poll locking
Date: Fri, 9 Oct 2015 10:18:56 +0100
Message-ID: <56178680.9020702@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:63769 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965180AbbJIJ2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 05:28:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

This patch reduces the overhead of locking for busy poll.
Previously the state was protected by a lock, whereas now
it's manipulated solely with atomic operations.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |  31 +++++---
 drivers/net/ethernet/sfc/net_driver.h | 129 +++++++++++++++-------------------
 2 files changed, 78 insertions(+), 82 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 974637d..8d943cd 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -205,7 +205,7 @@ static void efx_remove_channel(struct efx_channel *channel);
 static void efx_remove_channels(struct efx_nic *efx);
 static const struct efx_channel_type efx_default_channel_type;
 static void efx_remove_port(struct efx_nic *efx);
-static void efx_init_napi_channel(struct efx_channel *channel);
+static int efx_init_napi_channel(struct efx_channel *channel);
 static void efx_fini_napi(struct efx_nic *efx);
 static void efx_fini_napi_channel(struct efx_channel *channel);
 static void efx_fini_struct(struct efx_nic *efx);
@@ -834,7 +834,9 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 		rc = efx_probe_channel(channel);
 		if (rc)
 			goto rollback;
-		efx_init_napi_channel(efx->channel[i]);
+		rc = efx_init_napi_channel(efx->channel[i]);
+		if (rc)
+			goto rollback;
 	}
 
 out:
@@ -2054,7 +2056,7 @@ static int efx_ioctl(struct net_device *net_dev, struct ifreq *ifr, int cmd)
  *
  **************************************************************************/
 
-static void efx_init_napi_channel(struct efx_channel *channel)
+static int efx_init_napi_channel(struct efx_channel *channel)
 {
 	struct efx_nic *efx = channel->efx;
 
@@ -2062,15 +2064,23 @@ static void efx_init_napi_channel(struct efx_channel *channel)
 	netif_napi_add(channel->napi_dev, &channel->napi_str,
 		       efx_poll, napi_weight);
 	napi_hash_add(&channel->napi_str);
-	efx_channel_init_lock(channel);
+	efx_channel_busy_poll_init(channel);
+
+	return 0;
 }
 
-static void efx_init_napi(struct efx_nic *efx)
+static int efx_init_napi(struct efx_nic *efx)
 {
 	struct efx_channel *channel;
+	int rc;
 
-	efx_for_each_channel(channel, efx)
-		efx_init_napi_channel(channel);
+	efx_for_each_channel(channel, efx) {
+		rc = efx_init_napi_channel(channel);
+		if (rc)
+			return rc;
+	}
+
+	return 0;
 }
 
 static void efx_fini_napi_channel(struct efx_channel *channel)
@@ -2125,7 +2135,7 @@ static int efx_busy_poll(struct napi_struct *napi)
 	if (!netif_running(efx->net_dev))
 		return LL_FLUSH_FAILED;
 
-	if (!efx_channel_lock_poll(channel))
+	if (!efx_channel_try_lock_poll(channel))
 		return LL_FLUSH_BUSY;
 
 	old_rx_packets = channel->rx_queue.rx_packets;
@@ -3061,7 +3071,9 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	if (rc)
 		goto fail1;
 
-	efx_init_napi(efx);
+	rc = efx_init_napi(efx);
+	if (rc)
+		goto fail2;
 
 	rc = efx->type->init(efx);
 	if (rc) {
@@ -3094,6 +3106,7 @@ static int efx_pci_probe_main(struct efx_nic *efx)
 	efx->type->fini(efx);
  fail3:
 	efx_fini_napi(efx);
+ fail2:
 	efx_remove_all(efx);
  fail1:
 	return rc;
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index c530e1c..19eda8c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -431,21 +431,8 @@ struct efx_channel {
 	struct net_device *napi_dev;
 	struct napi_struct napi_str;
 #ifdef CONFIG_NET_RX_BUSY_POLL
-	unsigned int state;
-	spinlock_t state_lock;
-#define EFX_CHANNEL_STATE_IDLE		0
-#define EFX_CHANNEL_STATE_NAPI		(1 << 0)  /* NAPI owns this channel */
-#define EFX_CHANNEL_STATE_POLL		(1 << 1)  /* poll owns this channel */
-#define EFX_CHANNEL_STATE_DISABLED	(1 << 2)  /* channel is disabled */
-#define EFX_CHANNEL_STATE_NAPI_YIELD	(1 << 3)  /* NAPI yielded this channel */
-#define EFX_CHANNEL_STATE_POLL_YIELD	(1 << 4)  /* poll yielded this channel */
-#define EFX_CHANNEL_OWNED \
-	(EFX_CHANNEL_STATE_NAPI | EFX_CHANNEL_STATE_POLL)
-#define EFX_CHANNEL_LOCKED \
-	(EFX_CHANNEL_OWNED | EFX_CHANNEL_STATE_DISABLED)
-#define EFX_CHANNEL_USER_PEND \
-	(EFX_CHANNEL_STATE_POLL | EFX_CHANNEL_STATE_POLL_YIELD)
-#endif /* CONFIG_NET_RX_BUSY_POLL */
+	unsigned long busy_poll_state;
+#endif
 	struct efx_special_buffer eventq;
 	unsigned int eventq_mask;
 	unsigned int eventq_read_ptr;
@@ -480,98 +467,94 @@ struct efx_channel {
 };
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
-static inline void efx_channel_init_lock(struct efx_channel *channel)
+enum efx_channel_busy_poll_state {
+	EFX_CHANNEL_STATE_IDLE = 0,
+	EFX_CHANNEL_STATE_NAPI = BIT(0),
+	EFX_CHANNEL_STATE_NAPI_REQ_BIT = 1,
+	EFX_CHANNEL_STATE_NAPI_REQ = BIT(1),
+	EFX_CHANNEL_STATE_POLL_BIT = 2,
+	EFX_CHANNEL_STATE_POLL = BIT(2),
+	EFX_CHANNEL_STATE_DISABLE_BIT = 3,
+};
+
+static inline void efx_channel_busy_poll_init(struct efx_channel *channel)
 {
-	spin_lock_init(&channel->state_lock);
+	WRITE_ONCE(channel->busy_poll_state, EFX_CHANNEL_STATE_IDLE);
 }
 
 /* Called from the device poll routine to get ownership of a channel. */
 static inline bool efx_channel_lock_napi(struct efx_channel *channel)
 {
-	bool rc = true;
-
-	spin_lock_bh(&channel->state_lock);
-	if (channel->state & EFX_CHANNEL_LOCKED) {
-		WARN_ON(channel->state & EFX_CHANNEL_STATE_NAPI);
-		channel->state |= EFX_CHANNEL_STATE_NAPI_YIELD;
-		rc = false;
-	} else {
-		/* we don't care if someone yielded */
-		channel->state = EFX_CHANNEL_STATE_NAPI;
+	unsigned long prev, old = READ_ONCE(channel->busy_poll_state);
+
+	while (1) {
+		switch (old) {
+		case EFX_CHANNEL_STATE_POLL:
+			/* Ensure efx_channel_try_lock_poll() wont starve us */
+			set_bit(EFX_CHANNEL_STATE_NAPI_REQ_BIT,
+				&channel->busy_poll_state);
+			/* fallthrough */
+		case EFX_CHANNEL_STATE_POLL | EFX_CHANNEL_STATE_NAPI_REQ:
+			return false;
+		default:
+			break;
+		}
+		prev = cmpxchg(&channel->busy_poll_state, old,
+			       EFX_CHANNEL_STATE_NAPI);
+		if (unlikely(prev != old)) {
+			/* This is likely to mean we've just entered polling
+			 * state. Go back round to set the REQ bit.
+			 */
+			old = prev;
+			continue;
+		}
+		return true;
 	}
-	spin_unlock_bh(&channel->state_lock);
-	return rc;
 }
 
 static inline void efx_channel_unlock_napi(struct efx_channel *channel)
 {
-	spin_lock_bh(&channel->state_lock);
-	WARN_ON(channel->state &
-		(EFX_CHANNEL_STATE_POLL | EFX_CHANNEL_STATE_NAPI_YIELD));
-
-	channel->state &= EFX_CHANNEL_STATE_DISABLED;
-	spin_unlock_bh(&channel->state_lock);
+	/* Make sure write has completed from efx_channel_lock_napi() */
+	smp_wmb();
+	WRITE_ONCE(channel->busy_poll_state, EFX_CHANNEL_STATE_IDLE);
 }
 
 /* Called from efx_busy_poll(). */
-static inline bool efx_channel_lock_poll(struct efx_channel *channel)
+static inline bool efx_channel_try_lock_poll(struct efx_channel *channel)
 {
-	bool rc = true;
-
-	spin_lock_bh(&channel->state_lock);
-	if ((channel->state & EFX_CHANNEL_LOCKED)) {
-		channel->state |= EFX_CHANNEL_STATE_POLL_YIELD;
-		rc = false;
-	} else {
-		/* preserve yield marks */
-		channel->state |= EFX_CHANNEL_STATE_POLL;
-	}
-	spin_unlock_bh(&channel->state_lock);
-	return rc;
+	return cmpxchg(&channel->busy_poll_state, EFX_CHANNEL_STATE_IDLE,
+			EFX_CHANNEL_STATE_POLL) == EFX_CHANNEL_STATE_IDLE;
 }
 
-/* Returns true if NAPI tried to get the channel while it was locked. */
 static inline void efx_channel_unlock_poll(struct efx_channel *channel)
 {
-	spin_lock_bh(&channel->state_lock);
-	WARN_ON(channel->state & EFX_CHANNEL_STATE_NAPI);
-
-	/* will reset state to idle, unless channel is disabled */
-	channel->state &= EFX_CHANNEL_STATE_DISABLED;
-	spin_unlock_bh(&channel->state_lock);
+	clear_bit_unlock(EFX_CHANNEL_STATE_POLL_BIT, &channel->busy_poll_state);
 }
 
-/* True if a socket is polling, even if it did not get the lock. */
 static inline bool efx_channel_busy_polling(struct efx_channel *channel)
 {
-	WARN_ON(!(channel->state & EFX_CHANNEL_OWNED));
-	return channel->state & EFX_CHANNEL_USER_PEND;
+	return test_bit(EFX_CHANNEL_STATE_POLL_BIT, &channel->busy_poll_state);
 }
 
 static inline void efx_channel_enable(struct efx_channel *channel)
 {
-	spin_lock_bh(&channel->state_lock);
-	channel->state = EFX_CHANNEL_STATE_IDLE;
-	spin_unlock_bh(&channel->state_lock);
+	clear_bit_unlock(EFX_CHANNEL_STATE_DISABLE_BIT,
+			 &channel->busy_poll_state);
 }
 
-/* False if the channel is currently owned. */
+/* Stop further polling or napi access.
+ * Returns false if the channel is currently busy polling.
+ */
 static inline bool efx_channel_disable(struct efx_channel *channel)
 {
-	bool rc = true;
-
-	spin_lock_bh(&channel->state_lock);
-	if (channel->state & EFX_CHANNEL_OWNED)
-		rc = false;
-	channel->state |= EFX_CHANNEL_STATE_DISABLED;
-	spin_unlock_bh(&channel->state_lock);
-
-	return rc;
+	set_bit(EFX_CHANNEL_STATE_DISABLE_BIT, &channel->busy_poll_state);
+	/* Implicit barrier in efx_channel_busy_polling() */
+	return !efx_channel_busy_polling(channel);
 }
 
 #else /* CONFIG_NET_RX_BUSY_POLL */
 
-static inline void efx_channel_init_lock(struct efx_channel *channel)
+static inline void efx_channel_busy_poll_init(struct efx_channel *channel)
 {
 }
 
@@ -584,7 +567,7 @@ static inline void efx_channel_unlock_napi(struct efx_channel *channel)
 {
 }
 
-static inline bool efx_channel_lock_poll(struct efx_channel *channel)
+static inline bool efx_channel_try_lock_poll(struct efx_channel *channel)
 {
 	return false;
 }
