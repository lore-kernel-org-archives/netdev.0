From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] sfc: fix addr_list_lock spinlock use before init
Date: Mon, 15 Sep 2014 14:55:27 +0200
Message-ID: <1410785727-659-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17736 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036AbaIOM4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 08:56:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the module is initializing the ports it may call a function that
uses addr_list_lock before register_netdevice() has been called for that
port i.e. addr_list_lock is still uninitialized. The function in
question is efx_farch_filter_sync_rx_mode(), now it looks pointless to call
it before the port has been registered so alter the reconfigure_mac
callbacks to check if the port has been registered using the existing
efx_dev_registered() macro.

An example calltrace is (taken from net-next, but it's the same in net):
[   79.454689] BUG: spinlock bad magic on CPU#1, insmod/9650
[   79.455046]  lock: 0xffff88005a61a250, .magic: 00000000, .owner:
<none>/-1, .owner_cpu: 0
[   79.455488] CPU: 1 PID: 9650 Comm: insmod Tainted: G           O
3.17.0-rc4+ #30
[   79.455937] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[   79.456243]  0000000000000000 00000000a604ae4a ffff8800048239f8
ffffffff81731149
[   79.457476]  0000000000000000 ffff880004823a18 ffffffff8172d242
ffff88005a61a250
[   79.458126]  ffffffff81a39357 ffff880004823a38 ffffffff8172d26d
ffff88005a61a250
[   79.458761] Call Trace:
[   79.458987]  [<ffffffff81731149>] dump_stack+0x4d/0x66
[   79.459259]  [<ffffffff8172d242>] spin_dump+0x91/0x96
[   79.459526]  [<ffffffff8172d26d>] spin_bug+0x26/0x2b
[   79.459788]  [<ffffffff810d7e67>] do_raw_spin_lock+0x127/0x140
[   79.460069]  [<ffffffff8173812a>] _raw_spin_lock_bh+0x1a/0x20
[   79.460348]  [<ffffffffa0203872>]
efx_farch_filter_sync_rx_mode+0x32/0x100 [sfc]
[   79.460790]  [<ffffffffa0209735>] siena_mac_reconfigure+0x25/0xc0
[sfc]
[   79.461087]  [<ffffffffa020a1c2>] ? siena_init_nic+0x2b2/0x2c0 [sfc]
[   79.461374]  [<ffffffffa01fb7c5>] efx_pci_probe+0xb45/0x13c0 [sfc]
[   79.461659]  [<ffffffff813b8425>] local_pci_probe+0x45/0xa0
[   79.461928]  [<ffffffff813b9615>] ? pci_match_device+0xe5/0x110
[   79.462211]  [<ffffffff813b9779>] pci_device_probe+0xf9/0x150
[   79.462486]  [<ffffffff8148b93d>] driver_probe_device+0x12d/0x3d0
[   79.462767]  [<ffffffff8148bcb3>] __driver_attach+0x93/0xa0
[   79.463043]  [<ffffffff8148bc20>] ? __device_attach+0x40/0x40
[   79.463316]  [<ffffffff814897b3>] bus_for_each_dev+0x73/0xc0
[   79.463590]  [<ffffffff8148b33e>] driver_attach+0x1e/0x20
[   79.463857]  [<ffffffff8148af20>] bus_add_driver+0x180/0x250
[   79.464137]  [<ffffffffa023f000>] ? 0xffffffffa023f000
[   79.464401]  [<ffffffff8148c4c4>] driver_register+0x64/0xf0
[   79.464674]  [<ffffffff813b7db0>] __pci_register_driver+0x60/0x70
[   79.464954]  [<ffffffffa023f081>] efx_init_module+0x81/0x1000 [sfc]
[   79.465244]  [<ffffffff81002144>] do_one_initcall+0xd4/0x210
[   79.465521]  [<ffffffff811c7e24>] ? __vunmap+0x94/0x100
[   79.466652]  [<ffffffff811107cc>] load_module+0x1f3c/0x2570
[   79.466978]  [<ffffffff8110c460>] ? store_uevent+0x70/0x70
[   79.467277]  [<ffffffff81208d50>] ? kernel_read+0x50/0x80
[   79.467554]  [<ffffffff81110fd6>] SyS_finit_module+0xa6/0xd0
[   79.467829]  [<ffffffff81738929>] system_call_fastpath+0x16/0x1b

CC: Ben Hutchings <ben@decadent.org.uk>
CC: Shradha Shah <sshah@solarflare.com>
CC: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
Fixes: 964e61355e94 ("sfc: Cleanup Falcon-arch simple MAC filter state")
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/ethernet/sfc/falcon.c | 3 ++-
 drivers/net/ethernet/sfc/siena.c  | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 157037546d30..f8cff9ce3bc1 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -1210,7 +1210,8 @@ static int falcon_reconfigure_xmac(struct efx_nic *efx)
 {
 	struct falcon_nic_data *nic_data = efx->nic_data;
 
-	efx_farch_filter_sync_rx_mode(efx);
+	if (efx_dev_registered(efx))
+		efx_farch_filter_sync_rx_mode(efx);
 
 	falcon_reconfigure_xgxs_core(efx);
 	falcon_reconfigure_xmac_core(efx);
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index ae696855f21a..7d77590d09c9 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -593,7 +593,8 @@ static int siena_mac_reconfigure(struct efx_nic *efx)
 		     MC_CMD_SET_MCAST_HASH_IN_HASH0_OFST +
 		     sizeof(efx->multicast_hash));
 
-	efx_farch_filter_sync_rx_mode(efx);
+	if (efx_dev_registered(efx))
+		efx_farch_filter_sync_rx_mode(efx);
 
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
 
-- 
1.9.3
