From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sfc: get rid of custom busy polling code
Date: Thu, 02 Feb 2017 17:13:19 -0800
Message-ID: <1486084399.21871.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33267 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751508AbdBCBNW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 20:13:22 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so349771pfg.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 17:13:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In linux-4.5, busy polling was implemented in core
NAPI stack, meaning that all custom implementation can
be removed from drivers.

Not only we remove lot's of tricky code, we also remove
one lock operation in fast path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Edward Cree <ecree@solarflare.com>
Cc: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |   42 --------
 drivers/net/ethernet/sfc/net_driver.h |  125 ------------------------
 drivers/net/ethernet/sfc/rx.c         |    3 
 3 files changed, 1 insertion(+), 169 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 466c02805f72a7d1d19a6a342cd8026f20e43a28..fcd4eeecfef4201d4e0b205a14fba2f57a1041ed 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -308,9 +308,6 @@ static int efx_poll(struct napi_struct *napi, int budget)
 	struct efx_nic *efx = channel->efx;
 	int spent;
 
-	if (!efx_channel_lock_napi(channel))
-		return budget;
-
 	netif_vdbg(efx, intr, efx->net_dev,
 		   "channel %d NAPI poll executing on CPU %d\n",
 		   channel->channel, raw_smp_processor_id());
@@ -335,7 +332,6 @@ static int efx_poll(struct napi_struct *napi, int budget)
 		efx_nic_eventq_read_ack(channel);
 	}
 
-	efx_channel_unlock_napi(channel);
 	return spent;
 }
 
@@ -391,7 +387,6 @@ void efx_start_eventq(struct efx_channel *channel)
 	channel->enabled = true;
 	smp_wmb();
 
-	efx_channel_enable(channel);
 	napi_enable(&channel->napi_str);
 	efx_nic_eventq_read_ack(channel);
 }
@@ -403,8 +398,6 @@ void efx_stop_eventq(struct efx_channel *channel)
 		return;
 
 	napi_disable(&channel->napi_str);
-	while (!efx_channel_disable(channel))
-		usleep_range(1000, 20000);
 	channel->enabled = false;
 }
 
@@ -2088,7 +2081,6 @@ static void efx_init_napi_channel(struct efx_channel *channel)
 	channel->napi_dev = efx->net_dev;
 	netif_napi_add(channel->napi_dev, &channel->napi_str,
 		       efx_poll, napi_weight);
-	efx_channel_busy_poll_init(channel);
 }
 
 static void efx_init_napi(struct efx_nic *efx)
@@ -2138,37 +2130,6 @@ static void efx_netpoll(struct net_device *net_dev)
 
 #endif
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static int efx_busy_poll(struct napi_struct *napi)
-{
-	struct efx_channel *channel =
-		container_of(napi, struct efx_channel, napi_str);
-	struct efx_nic *efx = channel->efx;
-	int budget = 4;
-	int old_rx_packets, rx_packets;
-
-	if (!netif_running(efx->net_dev))
-		return LL_FLUSH_FAILED;
-
-	if (!efx_channel_try_lock_poll(channel))
-		return LL_FLUSH_BUSY;
-
-	old_rx_packets = channel->rx_queue.rx_packets;
-	efx_process_channel(channel, budget);
-
-	rx_packets = channel->rx_queue.rx_packets - old_rx_packets;
-
-	/* There is no race condition with NAPI here.
-	 * NAPI will automatically be rescheduled if it yielded during busy
-	 * polling, because it was not able to take the lock and thus returned
-	 * the full budget.
-	 */
-	efx_channel_unlock_poll(channel);
-
-	return rx_packets;
-}
-#endif
-
 /**************************************************************************
  *
  * Kernel net device interface
@@ -2402,9 +2363,6 @@ static const struct net_device_ops efx_netdev_ops = {
 	.ndo_poll_controller = efx_netpoll,
 #endif
 	.ndo_setup_tc		= efx_setup_tc,
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= efx_busy_poll,
-#endif
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= efx_filter_rfs,
 #endif
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 5927c20ba43fec866aa7249548e3daca9baa084b..73810d2d630ccf4b410002b2d3a72e04c955a7f9 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -491,131 +491,6 @@ struct efx_channel {
 	u32 sync_timestamp_minor;
 };
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-enum efx_channel_busy_poll_state {
-	EFX_CHANNEL_STATE_IDLE = 0,
-	EFX_CHANNEL_STATE_NAPI = BIT(0),
-	EFX_CHANNEL_STATE_NAPI_REQ_BIT = 1,
-	EFX_CHANNEL_STATE_NAPI_REQ = BIT(1),
-	EFX_CHANNEL_STATE_POLL_BIT = 2,
-	EFX_CHANNEL_STATE_POLL = BIT(2),
-	EFX_CHANNEL_STATE_DISABLE_BIT = 3,
-};
-
-static inline void efx_channel_busy_poll_init(struct efx_channel *channel)
-{
-	WRITE_ONCE(channel->busy_poll_state, EFX_CHANNEL_STATE_IDLE);
-}
-
-/* Called from the device poll routine to get ownership of a channel. */
-static inline bool efx_channel_lock_napi(struct efx_channel *channel)
-{
-	unsigned long prev, old = READ_ONCE(channel->busy_poll_state);
-
-	while (1) {
-		switch (old) {
-		case EFX_CHANNEL_STATE_POLL:
-			/* Ensure efx_channel_try_lock_poll() wont starve us */
-			set_bit(EFX_CHANNEL_STATE_NAPI_REQ_BIT,
-				&channel->busy_poll_state);
-			/* fallthrough */
-		case EFX_CHANNEL_STATE_POLL | EFX_CHANNEL_STATE_NAPI_REQ:
-			return false;
-		default:
-			break;
-		}
-		prev = cmpxchg(&channel->busy_poll_state, old,
-			       EFX_CHANNEL_STATE_NAPI);
-		if (unlikely(prev != old)) {
-			/* This is likely to mean we've just entered polling
-			 * state. Go back round to set the REQ bit.
-			 */
-			old = prev;
-			continue;
-		}
-		return true;
-	}
-}
-
-static inline void efx_channel_unlock_napi(struct efx_channel *channel)
-{
-	/* Make sure write has completed from efx_channel_lock_napi() */
-	smp_wmb();
-	WRITE_ONCE(channel->busy_poll_state, EFX_CHANNEL_STATE_IDLE);
-}
-
-/* Called from efx_busy_poll(). */
-static inline bool efx_channel_try_lock_poll(struct efx_channel *channel)
-{
-	return cmpxchg(&channel->busy_poll_state, EFX_CHANNEL_STATE_IDLE,
-			EFX_CHANNEL_STATE_POLL) == EFX_CHANNEL_STATE_IDLE;
-}
-
-static inline void efx_channel_unlock_poll(struct efx_channel *channel)
-{
-	clear_bit_unlock(EFX_CHANNEL_STATE_POLL_BIT, &channel->busy_poll_state);
-}
-
-static inline bool efx_channel_busy_polling(struct efx_channel *channel)
-{
-	return test_bit(EFX_CHANNEL_STATE_POLL_BIT, &channel->busy_poll_state);
-}
-
-static inline void efx_channel_enable(struct efx_channel *channel)
-{
-	clear_bit_unlock(EFX_CHANNEL_STATE_DISABLE_BIT,
-			 &channel->busy_poll_state);
-}
-
-/* Stop further polling or napi access.
- * Returns false if the channel is currently busy polling.
- */
-static inline bool efx_channel_disable(struct efx_channel *channel)
-{
-	set_bit(EFX_CHANNEL_STATE_DISABLE_BIT, &channel->busy_poll_state);
-	/* Implicit barrier in efx_channel_busy_polling() */
-	return !efx_channel_busy_polling(channel);
-}
-
-#else /* CONFIG_NET_RX_BUSY_POLL */
-
-static inline void efx_channel_busy_poll_init(struct efx_channel *channel)
-{
-}
-
-static inline bool efx_channel_lock_napi(struct efx_channel *channel)
-{
-	return true;
-}
-
-static inline void efx_channel_unlock_napi(struct efx_channel *channel)
-{
-}
-
-static inline bool efx_channel_try_lock_poll(struct efx_channel *channel)
-{
-	return false;
-}
-
-static inline void efx_channel_unlock_poll(struct efx_channel *channel)
-{
-}
-
-static inline bool efx_channel_busy_polling(struct efx_channel *channel)
-{
-	return false;
-}
-
-static inline void efx_channel_enable(struct efx_channel *channel)
-{
-}
-
-static inline bool efx_channel_disable(struct efx_channel *channel)
-{
-	return true;
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 /**
  * struct efx_msi_context - Context for each MSI
  * @efx: The associated NIC
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 5f4ad4f3518f22ad773e9af4767f065268d7e981..31587f4066ab08f52409b2c666df0b92b4707781 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -665,8 +665,7 @@ void __efx_rx_packet(struct efx_channel *channel)
 	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
 		rx_buf->flags &= ~EFX_RX_PKT_CSUMMED;
 
-	if ((rx_buf->flags & EFX_RX_PKT_TCP) && !channel->type->receive_skb &&
-	    !efx_channel_busy_polling(channel))
+	if ((rx_buf->flags & EFX_RX_PKT_TCP) && !channel->type->receive_skb)
 		efx_rx_packet_gro(channel, rx_buf, channel->rx_pkt_n_frags, eh);
 	else
 		efx_rx_deliver(channel, eh, rx_buf, channel->rx_pkt_n_frags);
