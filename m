From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/19] sfc: Disable flow control during flushes
Date: Thu, 16 Feb 2012 00:49:37 +0000
Message-ID: <1329353377.2565.39.camel@bwh-desktop>
References: <1329352938.2565.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:27673 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754733Ab2BPAtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 19:49:40 -0500
In-Reply-To: <1329352938.2565.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

The TX DMA engine issues upstream read requests when there is room in
the TX FIFO for the completion. However, the fetches for the rest of
the packet might be delayed by any back pressure.  Since a flush must
wait for an EOP, the entire flush may be delayed by back pressure.

Mitigate this by disabling flow control before the flushes are
started.  Since PF and VF flushes run in parallel introduce
fc_disable, a reference count of the number of flushes outstanding.

The same principle could be applied to Falcon, but that
would bring with it its own testing.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi_mac.c   |    2 ++
 drivers/net/ethernet/sfc/net_driver.h |    4 ++++
 drivers/net/ethernet/sfc/nic.c        |    3 +++
 3 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi_mac.c b/drivers/net/ethernet/sfc/mcdi_mac.c
index f67cf92..98afe1c 100644
--- a/drivers/net/ethernet/sfc/mcdi_mac.c
+++ b/drivers/net/ethernet/sfc/mcdi_mac.c
@@ -44,6 +44,8 @@ static int efx_mcdi_set_mac(struct efx_nic *efx)
 	}
 	if (efx->wanted_fc & EFX_FC_AUTO)
 		fcntl = MC_CMD_FCNTL_AUTO;
+	if (efx->fc_disable)
+		fcntl = MC_CMD_FCNTL_OFF;
 
 	MCDI_SET_DWORD(cmdbytes, SET_MAC_IN_FCNTL, fcntl);
 
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 18c4b3c..f526877 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -670,6 +670,9 @@ struct efx_filter_state;
  * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
  * @multicast_hash: Multicast hash table
  * @wanted_fc: Wanted flow control flags
+ * @fc_disable: When non-zero flow control is disabled. Typically used to
+ *	ensure that network back pressure doesn't delay dma queue flushes.
+ *	Serialised by the rtnl lock.
  * @mac_work: Work item for changing MAC promiscuity and multicast hash
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
@@ -769,6 +772,7 @@ struct efx_nic {
 	bool promiscuous;
 	union efx_multicast_hash multicast_hash;
 	u8 wanted_fc;
+	unsigned fc_disable;
 
 	atomic_t rx_reset;
 	enum efx_loopback_mode loopback_mode;
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 539b574..1bb41ff 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -677,6 +677,7 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 	struct efx_tx_queue *tx_queue;
 	int rc = 0;
 
+	efx->fc_disable++;
 	efx->type->prepare_flush(efx);
 
 	efx_for_each_channel(channel, efx) {
@@ -727,6 +728,8 @@ int efx_nic_flush_queues(struct efx_nic *efx)
 		atomic_set(&efx->rxq_flush_outstanding, 0);
 	}
 
+	efx->fc_disable--;
+
 	return rc;
 }
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
