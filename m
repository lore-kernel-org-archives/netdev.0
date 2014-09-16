From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] sfc: fix addr_list_lock spinlock use before init
Date: Tue, 16 Sep 2014 16:57:59 +0100
Message-ID: <alpine.LFD.2.03.1409161654370.25290@solarflare.com>
References: <1410785727-659-1-git-send-email-nikolay@redhat.com> <alpine.LFD.2.03.1409161540490.25290@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Nikolay Aleksandrov <nikolay@redhat.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Ben Hutchings <ben@decadent.org.uk>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:59604 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754264AbaIPP6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 11:58:30 -0400
In-Reply-To: <alpine.LFD.2.03.1409161540490.25290@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by Nikolay Aleksandrov.  In efx_init_port() we call
 efx_mac_reconfigure() to work around a Falcon/A1 limitation, and this calls
 efx_{arch}_filter_sync_rx_mode(), which takes the addr_list_lock; but this
 lock is uninitialised, because we haven't called register_netdevice() yet.
So, in efx_farch_filter_sync_rx_mode(), check efx_dev_registered() before
 doing anything else.
The EF10 equivalent, efx_ef10_filter_sync_rx_mode(), already has the
 corresponding check.
---
 drivers/net/ethernet/sfc/farch.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 0537381..6859437 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -2933,6 +2933,9 @@ void efx_farch_filter_sync_rx_mode(struct efx_nic *efx)
 	u32 crc;
 	int bit;
 
+	if (!efx_dev_registered(efx))
+		return;
+
 	netif_addr_lock_bh(net_dev);
 
 	efx->unicast_filter = !(net_dev->flags & IFF_PROMISC);
-- 
1.7.11.7
