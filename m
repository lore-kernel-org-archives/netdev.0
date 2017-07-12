From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net] sfc: don't read beyond unicast address list
Date: Wed, 12 Jul 2017 17:19:41 +0100
Message-ID: <b8c7ef9e-6c6e-1b59-c911-728089682258@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:49672 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752854AbdGLQUE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 12:20:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we have more than 32 unicast MAC addresses assigned to an interface
we will read beyond the end of the address table in the driver when
adding filters. The next 256 entries store multicast addresses, so we
will end up attempting to insert duplicate filters, which is mostly
harmless. If we add more than 288 unicast addresses we will then read
past the multicast address table, which is likely to be more exciting.

Fixes: 12fb0da45c9a ("sfc: clean fallbacks between promisc/normal in efx_ef10_filter_sync_rx_mode")
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 761c518b2f92..13f72f5b18d2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -5034,12 +5034,9 @@ static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx)
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct net_device *net_dev = efx->net_dev;
 	struct netdev_hw_addr *uc;
-	int addr_count;
 	unsigned int i;
 
-	addr_count = netdev_uc_count(net_dev);
 	table->uc_promisc = !!(net_dev->flags & IFF_PROMISC);
-	table->dev_uc_count = 1 + addr_count;
 	ether_addr_copy(table->dev_uc_list[0].addr, net_dev->dev_addr);
 	i = 1;
 	netdev_for_each_uc_addr(uc, net_dev) {
@@ -5050,6 +5047,8 @@ static void efx_ef10_filter_uc_addr_list(struct efx_nic *efx)
 		ether_addr_copy(table->dev_uc_list[i].addr, uc->addr);
 		i++;
 	}
+
+	table->dev_uc_count = i;
 }
 
 static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx)
@@ -5057,12 +5056,11 @@ static void efx_ef10_filter_mc_addr_list(struct efx_nic *efx)
 	struct efx_ef10_filter_table *table = efx->filter_state;
 	struct net_device *net_dev = efx->net_dev;
 	struct netdev_hw_addr *mc;
-	unsigned int i, addr_count;
+	unsigned int i;
 
 	table->mc_overflow = false;
 	table->mc_promisc = !!(net_dev->flags & (IFF_PROMISC | IFF_ALLMULTI));
 
-	addr_count = netdev_mc_count(net_dev);
 	i = 0;
 	netdev_for_each_mc_addr(mc, net_dev) {
 		if (i >= EFX_EF10_FILTER_DEV_MC_MAX) {
-- 
2.7.5
