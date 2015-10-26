From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v2 1/1] sfc: replace spinlocks with bit ops for busy
 poll locking
Date: Mon, 26 Oct 2015 14:23:42 +0000
Message-ID: <562E376E.40904@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:55078 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754176AbbJZOX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 10:23:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>

This patch reduces the overhead of locking for busy poll.
Previously the state was protected by a lock, whereas now
it's manipulated solely with atomic operations.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |   4 +-
 drivers/net/ethernet/sfc/net_driver.h | 129 +++++++++++++++-------------------
 2 files changed, 58 insertions(+), 75 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 974637d..6e11ee6 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2062,7 +2062,7 @@ static void efx_init_napi_channel(struct efx_channel *channel)
 	netif_napi_add(channel->napi_dev, &channel->napi_str,
 		       efx_poll, napi_weight);
 	napi_hash_add(&channel->napi_str);
-	efx_channel_init_lock(channel);
+	efx_channel_busy_poll_init(channel);
 }
 
 static void efx_init_napi(struct efx_nic *efx)
@@ -2125,7 +2125,7 @@ static int efx_busy_poll(struct napi_struct *napi)
 	if (!netif_running(efx->net_dev))
 		return LL_FLUSH_FAILED;
 
-	if (!efx_channel_lock_poll(channel))
+	if (!efx_channel_try_lock_poll(channel))
 		return LL_FLUSH_BUSY;
 
 	old_rx_packets = channel->rx_queue.rx_packets;
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index ad56231..229e68c 100644
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
