From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH / RFC] net: fix locking in ibm_newemac
Date: Thu, 14 Aug 2008 13:45:54 +1000
Message-ID: <1218685554.8041.172.camel@pasglop>
References: <20080813182957.GA12612@www.tglx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20080813182957.GA12612@www.tglx.de>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, 2008-08-13 at 20:29 +0200, Sebastian Siewior wrote:
> |PPC 4xx OCP EMAC driver, version 3.54
> |MAL v2 /plb/mcmal, 2 TX channels, 2 RX channels
> |RGMII /plb/opb/emac-rgmii@ef600b00 initialized with MDIO support
> |/plb/opb/emac-rgmii@ef600b00: input 0 in RGMII mode
> |BUG: spinlock bad magic on CPU#0, swapper/1
> | lock: cf81632c, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
> |Call Trace:
> |[cf82bc70] [c00071c4] show_stack+0x34/0x194 (unreliable)
> |[cf82bca0] [c0136d5c] spin_bug+0x8c/0xd0
> |[cf82bcc0] [c0136f64] _raw_spin_lock+0x94/0x16c
> |[cf82bcf0] [c023b528] _spin_lock_bh+0x20/0x34
> |[cf82bd10] [c01d04a8] dev_mc_add+0x2c/0x84
> |[cf82bd30] [c0166f80] emac_configure+0x2a8/0x55c
> |[cf82bd60] [c02418bc] emac_probe+0xc24/0x105c
> |[cf82be40] [c01bb504] of_platform_device_probe+0x58/0x80
> |[cf82be60] [c016057c] driver_probe_device+0xb8/0x1ec
> |[cf82be80] [c0160734] __driver_attach+0x84/0x88
> |[cf82bea0] [c015fa4c] bus_for_each_dev+0x5c/0x98
> |[cf82bed0] [c0160384] driver_attach+0x24/0x34
> |[cf82bee0] [c01600b4] bus_add_driver+0x1d8/0x24c
> |[cf82bf00] [c0160944] driver_register+0x5c/0x158
> |[cf82bf20] [c01bb3dc] of_register_driver+0x54/0x70
> |[cf82bf30] [c030ba8c] emac_init+0x1c8/0x208
> |[cf82bf60] [c02f4184] kernel_init+0x84/0x27c
> |[cf82bff0] [c000e594] kernel_thread+0x44/0x60
> 
> The fix is to defer phy init until netdevice is registered / initialized.

I think it's better instead to take the dev_mc_add() statement
out of emac_configure().

What about this patch instead, does it fix it for you ?

ibm_newemac: Fix uninitialized spinlock at probe time

We must not call dev_mc_add() from within our HW configure which happens
before we initialize and register the netdev. Do it in open() instead.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Index: linux-work/drivers/net/ibm_newemac/core.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.c	2008-08-14 13:36:10.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/core.c	2008-08-14 13:42:10.000000000 +1000
@@ -663,9 +663,6 @@ static int emac_configure(struct emac_in
 	if (emac_phy_gpcs(dev->phy.mode))
 		emac_mii_reset_phy(&dev->phy);
 
-	/* Required for Pause packet support in EMAC */
-	dev_mc_add(ndev, default_mcast_addr, sizeof(default_mcast_addr), 1);
-
 	return 0;
 }
 
@@ -1150,6 +1147,9 @@ static int emac_open(struct net_device *
 	} else
 		netif_carrier_on(dev->ndev);
 
+	/* Required for Pause packet support in EMAC */
+	dev_mc_add(ndev, default_mcast_addr, sizeof(default_mcast_addr), 1);
+
 	emac_configure(dev);
 	mal_poll_add(dev->mal, &dev->commac);
 	mal_enable_tx_channel(dev->mal, dev->mal_tx_chan);
