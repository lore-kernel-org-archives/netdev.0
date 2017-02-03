From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sfc-falcon: get rid of custom busy polling code
Date: Thu, 02 Feb 2017 18:22:28 -0800
Message-ID: <1486088548.21871.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486084399.21871.46.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33363 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751622AbdBCCWb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 21:22:31 -0500
Received: by mail-pf0-f193.google.com with SMTP id e4so463504pfg.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 18:22:30 -0800 (PST)
In-Reply-To: <1486084399.21871.46.camel@edumazet-glaptop3.roam.corp.google.com>
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
 drivers/net/ethernet/sfc/falcon/efx.c        |   42 -----
 drivers/net/ethernet/sfc/falcon/net_driver.h |  125 -----------------
 drivers/net/ethernet/sfc/falcon/rx.c         |    3 
 3 files changed, 1 insertion(+), 169 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
index c4ff3bb1a1ef48724f851b571fd206ae72d2d49f..f5e5cd1659a148fb63ce2078ef13a5ae12d048bc 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.c
+++ b/drivers/net/ethernet/sfc/falcon/efx.c
@@ -304,9 +304,6 @@ static int ef4_poll(struct napi_struct *napi, int budget)
 	struct ef4_nic *efx = channel->efx;
 	int spent;
 
-	if (!ef4_channel_lock_napi(channel))
-		return budget;
-
 	netif_vdbg(efx, intr, efx->net_dev,
 		   "channel %d NAPI poll executing on CPU %d\n",
 		   channel->channel, raw_smp_processor_id());
@@ -331,7 +328,6 @@ static int ef4_poll(struct napi_struct *napi, int budget)
 		ef4_nic_eventq_read_ack(channel);
 	}
 
-	ef4_channel_unlock_napi(channel);
 	return spent;
 }
 
@@ -387,7 +383,6 @@ void ef4_start_eventq(struct ef4_channel *channel)
 	channel->enabled = true;
 	smp_wmb();
 
-	ef4_channel_enable(channel);
 	napi_enable(&channel->napi_str);
 	ef4_nic_eventq_read_ack(channel);
 }
@@ -399,8 +394,6 @@ void ef4_stop_eventq(struct ef4_channel *channel)
 		return;
 
 	napi_disable(&channel->napi_str);
-	while (!ef4_channel_disable(channel))
-		usleep_range(1000, 20000);
 	channel->enabled = false;
 }
 
@@ -2029,7 +2022,6 @@ static void ef4_init_napi_channel(struct ef4_channel *channel)
 	channel->napi_dev = efx->net_dev;
 	netif_napi_add(channel->napi_dev, &channel->napi_str,
 		       ef4_poll, napi_weight);
-	ef4_channel_busy_poll_init(channel);
 }
 
 static void ef4_init_napi(struct ef4_nic *efx)
@@ -2079,37 +2071,6 @@ static void ef4_netpoll(struct net_device *net_dev)
 
 #endif
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-static int ef4_busy_poll(struct napi_struct *napi)
-{
-	struct ef4_channel *channel =
-		container_of(napi, struct ef4_channel, napi_str);
-	struct ef4_nic *efx = channel->efx;
-	int budget = 4;
-	int old_rx_packets, rx_packets;
-
-	if (!netif_running(efx->net_dev))
-		return LL_FLUSH_FAILED;
-
-	if (!ef4_channel_try_lock_poll(channel))
-		return LL_FLUSH_BUSY;
-
-	old_rx_packets = channel->rx_queue.rx_packets;
-	ef4_process_channel(channel, budget);
-
-	rx_packets = channel->rx_queue.rx_packets - old_rx_packets;
-
-	/* There is no race condition with NAPI here.
-	 * NAPI will automatically be rescheduled if it yielded during busy
-	 * polling, because it was not able to take the lock and thus returned
-	 * the full budget.
-	 */
-	ef4_channel_unlock_poll(channel);
-
-	return rx_packets;
-}
-#endif
-
 /**************************************************************************
  *
  * Kernel net device interface
@@ -2289,9 +2250,6 @@ static const struct net_device_ops ef4_netdev_ops = {
 	.ndo_poll_controller = ef4_netpoll,
 #endif
 	.ndo_setup_tc		= ef4_setup_tc,
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	.ndo_busy_poll		= ef4_busy_poll,
-#endif
 #ifdef CONFIG_RFS_ACCEL
 	.ndo_rx_flow_steer	= ef4_filter_rfs,
 #endif
diff --git a/drivers/net/ethernet/sfc/falcon/net_driver.h b/drivers/net/ethernet/sfc/falcon/net_driver.h
index fe59dd67f9186bb9e2282ab00a3e04460ae80bc6..37a8bdf32206a44b82ff25d4111412062dd04a22 100644
--- a/drivers/net/ethernet/sfc/falcon/net_driver.h
+++ b/drivers/net/ethernet/sfc/falcon/net_driver.h
@@ -448,131 +448,6 @@ struct ef4_channel {
 	struct ef4_tx_queue tx_queue[EF4_TXQ_TYPES];
 };
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-enum ef4_channel_busy_poll_state {
-	EF4_CHANNEL_STATE_IDLE = 0,
-	EF4_CHANNEL_STATE_NAPI = BIT(0),
-	EF4_CHANNEL_STATE_NAPI_REQ_BIT = 1,
-	EF4_CHANNEL_STATE_NAPI_REQ = BIT(1),
-	EF4_CHANNEL_STATE_POLL_BIT = 2,
-	EF4_CHANNEL_STATE_POLL = BIT(2),
-	EF4_CHANNEL_STATE_DISABLE_BIT = 3,
-};
-
-static inline void ef4_channel_busy_poll_init(struct ef4_channel *channel)
-{
-	WRITE_ONCE(channel->busy_poll_state, EF4_CHANNEL_STATE_IDLE);
-}
-
-/* Called from the device poll routine to get ownership of a channel. */
-static inline bool ef4_channel_lock_napi(struct ef4_channel *channel)
-{
-	unsigned long prev, old = READ_ONCE(channel->busy_poll_state);
-
-	while (1) {
-		switch (old) {
-		case EF4_CHANNEL_STATE_POLL:
-			/* Ensure ef4_channel_try_lock_poll() wont starve us */
-			set_bit(EF4_CHANNEL_STATE_NAPI_REQ_BIT,
-				&channel->busy_poll_state);
-			/* fallthrough */
-		case EF4_CHANNEL_STATE_POLL | EF4_CHANNEL_STATE_NAPI_REQ:
-			return false;
-		default:
-			break;
-		}
-		prev = cmpxchg(&channel->busy_poll_state, old,
-			       EF4_CHANNEL_STATE_NAPI);
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
-static inline void ef4_channel_unlock_napi(struct ef4_channel *channel)
-{
-	/* Make sure write has completed from ef4_channel_lock_napi() */
-	smp_wmb();
-	WRITE_ONCE(channel->busy_poll_state, EF4_CHANNEL_STATE_IDLE);
-}
-
-/* Called from ef4_busy_poll(). */
-static inline bool ef4_channel_try_lock_poll(struct ef4_channel *channel)
-{
-	return cmpxchg(&channel->busy_poll_state, EF4_CHANNEL_STATE_IDLE,
-			EF4_CHANNEL_STATE_POLL) == EF4_CHANNEL_STATE_IDLE;
-}
-
-static inline void ef4_channel_unlock_poll(struct ef4_channel *channel)
-{
-	clear_bit_unlock(EF4_CHANNEL_STATE_POLL_BIT, &channel->busy_poll_state);
-}
-
-static inline bool ef4_channel_busy_polling(struct ef4_channel *channel)
-{
-	return test_bit(EF4_CHANNEL_STATE_POLL_BIT, &channel->busy_poll_state);
-}
-
-static inline void ef4_channel_enable(struct ef4_channel *channel)
-{
-	clear_bit_unlock(EF4_CHANNEL_STATE_DISABLE_BIT,
-			 &channel->busy_poll_state);
-}
-
-/* Stop further polling or napi access.
- * Returns false if the channel is currently busy polling.
- */
-static inline bool ef4_channel_disable(struct ef4_channel *channel)
-{
-	set_bit(EF4_CHANNEL_STATE_DISABLE_BIT, &channel->busy_poll_state);
-	/* Implicit barrier in ef4_channel_busy_polling() */
-	return !ef4_channel_busy_polling(channel);
-}
-
-#else /* CONFIG_NET_RX_BUSY_POLL */
-
-static inline void ef4_channel_busy_poll_init(struct ef4_channel *channel)
-{
-}
-
-static inline bool ef4_channel_lock_napi(struct ef4_channel *channel)
-{
-	return true;
-}
-
-static inline void ef4_channel_unlock_napi(struct ef4_channel *channel)
-{
-}
-
-static inline bool ef4_channel_try_lock_poll(struct ef4_channel *channel)
-{
-	return false;
-}
-
-static inline void ef4_channel_unlock_poll(struct ef4_channel *channel)
-{
-}
-
-static inline bool ef4_channel_busy_polling(struct ef4_channel *channel)
-{
-	return false;
-}
-
-static inline void ef4_channel_enable(struct ef4_channel *channel)
-{
-}
-
-static inline bool ef4_channel_disable(struct ef4_channel *channel)
-{
-	return true;
-}
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 /**
  * struct ef4_msi_context - Context for each MSI
  * @efx: The associated NIC
diff --git a/drivers/net/ethernet/sfc/falcon/rx.c b/drivers/net/ethernet/sfc/falcon/rx.c
index 250458cbdb4dcdd3700bdf520cee8c9865c4abdb..6a8406dc0c2b47dbdb4c2466e028ff04fd35e1c9 100644
--- a/drivers/net/ethernet/sfc/falcon/rx.c
+++ b/drivers/net/ethernet/sfc/falcon/rx.c
@@ -674,8 +674,7 @@ void __ef4_rx_packet(struct ef4_channel *channel)
 	if (unlikely(!(efx->net_dev->features & NETIF_F_RXCSUM)))
 		rx_buf->flags &= ~EF4_RX_PKT_CSUMMED;
 
-	if ((rx_buf->flags & EF4_RX_PKT_TCP) && !channel->type->receive_skb &&
-	    !ef4_channel_busy_polling(channel))
+	if ((rx_buf->flags & EF4_RX_PKT_TCP) && !channel->type->receive_skb)
 		ef4_rx_packet_gro(channel, rx_buf, channel->rx_pkt_n_frags, eh);
 	else
 		ef4_rx_deliver(channel, eh, rx_buf, channel->rx_pkt_n_frags);
