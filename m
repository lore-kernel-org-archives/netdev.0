From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/16] sfc: Add TX merged completion counter
Date: Wed, 28 Aug 2013 16:21:27 +0100
Message-ID: <1377703287.2264.35.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17303 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852Ab3H1PVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:21:31 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a counter for TX merged completion events.

This is implemented in the common TX path, because the NIC event
handlers only know how many descriptors were completed, not how many
packets.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c    | 1 +
 drivers/net/ethernet/sfc/net_driver.h | 2 ++
 drivers/net/ethernet/sfc/tx.c         | 3 +++
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 0b8ffdf..6354693 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -65,6 +65,7 @@ static u64 efx_get_atomic_stat(void *field)
 			 unsigned int, efx_get_uint_stat)
 
 static const struct efx_sw_stat_desc efx_sw_stat_desc[] = {
+	EFX_ETHTOOL_UINT_TXQ_STAT(merge_events),
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_bursts),
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_long_headers),
 	EFX_ETHTOOL_UINT_TXQ_STAT(tso_packets),
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 481e412..f52b38c 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -186,6 +186,7 @@ struct efx_tx_buffer {
  *	variable indicates that the queue is empty.  This is to
  *	avoid cache-line ping-pong between the xmit path and the
  *	completion path.
+ * @merge_events: Number of TX merged completion events
  * @insert_count: Current insert pointer
  *	This is the number of buffers that have been added to the
  *	software ring.
@@ -222,6 +223,7 @@ struct efx_tx_queue {
 	/* Members used mainly on the completion path */
 	unsigned int read_count ____cacheline_aligned_in_smp;
 	unsigned int old_write_count;
+	unsigned int merge_events;
 
 	/* Members used only on the xmit path */
 	unsigned int insert_count ____cacheline_aligned_in_smp;
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 4903c4f..85ee647 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -437,6 +437,9 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	efx_dequeue_buffers(tx_queue, index, &pkts_compl, &bytes_compl);
 	netdev_tx_completed_queue(tx_queue->core_txq, pkts_compl, bytes_compl);
 
+	if (pkts_compl > 1)
+		++tx_queue->merge_events;
+
 	/* See if we need to restart the netif queue.  This memory
 	 * barrier ensures that we write read_count (inside
 	 * efx_dequeue_buffers()) before reading the queue status.


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
