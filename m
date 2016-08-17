From: Riku Voipio <riku.voipio-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: regression in xgene-enet in 4.8-rc series, oops from xgene_enet_probe
Date: Wed, 17 Aug 2016 11:27:57 +0300
Message-ID: <CAAqcGHmwjZS8_NjZnXDcgw+x5YAGt+mCdwbgN++ipVqXLMuTaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 26 July 2016 at 03:12, Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org> wrote:
> When the driver is configured as kernel module and when it gets
> unloaded and reloaded, kernel crash was observed.  This patch
> addresses the software cleanup by doing the following,
>
> - Moved register_netdev call after hardware is ready
> - Since ndev is not ready, added set_irq_name to set irq name
> - Since ndev is not ready, changed mdio_bus->parent to pdev->dev
> - Replaced netif_start(stop)_queue by netif_tx_start(stop)_queues
> - Removed napi_del call since it's called by free_netdev
> - Added dev_close call, within remove
> - Added shutdown callback
> - Changed to use dmam_ APIs

Bisecting points this patch, commited as
cb0366b7c16427a25923350b69f53a5b1345a34b the cause of oops when
booting apm mustang:

[    1.670201] ------------[ cut here ]------------
[    1.674804] WARNING: CPU: 2 PID: 1 at ../net/core/dev.c:6696
rollback_registered_many+0x60/0x300
[    1.683543] Modules linked in: realtek
[    1.687291]
[    1.688774] CPU: 2 PID: 1 Comm: swapper/0 Not tainted
4.8.0-rc2-00037-g3ec60b92d3ba #1
[    1.696648] Hardware name: APM X-Gene Mustang board (DT)
[    1.701930] task: ffff8003ee078000 task.stack: ffff8003ee054000
[    1.707819] PC is at rollback_registered_many+0x60/0x300
[    1.713102] LR is at rollback_registered_many+0x30/0x300
[    1.718384] pc : [] lr : [] pstate: 20000045
[    1.725739] sp : ffff8003ee057b00
[    1.729034] x29: ffff8003ee057b00 x28: ffff8003eda1a000
[    1.734338] x27: 0000000000000002 x26: ffff8003ebcba970
[    1.739641] x25: ffff8003eda1a208 x24: ffff8003eda1a010
[    1.744945] x23: ffff8003ee057c58 x22: ffff8003ebcba000
[    1.750247] x21: 00000000ffffffed x20: ffff8003ee057b70
[    1.755549] x19: ffff8003ee057b50 x18: ffff000008dfafff
[    1.760852] x17: 0000000000000007 x16: 0000000000000001
[    1.766154] x15: ffff000008ce2000 x14: ffffffffffffffff
[    1.771458] x13: 0000000000000008 x12: 0000000000000030
[    1.776760] x11: 0000000000000030 x10: 0101010101010101
[    1.782062] x9 : 0000000000000000 x8 : ffff8003df80c700
[    1.787365] x7 : 0000000000000000 x6 : 0000000000000001
[    1.792668] x5 : dead000000000100 x4 : dead000000000200
[    1.797971] x3 : ffff8003ebcba070 x2 : 0000000000000000
[    1.803273] x1 : ffff8003ee057b00 x0 : ffff8003ebcba000
[    1.808575]
[    1.810057] ---[ end trace 93f1dda704e63533 ]---
[    1.814648] Call trace:
[    1.816207] ata2: SATA link down (SStatus 0 SControl 4300)
[    1.822535] Exception stack(0xffff8003ee057930 to 0xffff8003ee057a60)
[    1.828941] 7920:
ffff8003ee057b50 0001000000000000
[    1.836729] 7940: ffff8003ee057b00 ffff000008773c18
ffff8003ee057980 ffff000008849a1c
[    1.844517] 7960: 0000000000000009 ffff000008e50000
ffff8003ee0579a0 ffff0000086eb03c
[    1.852305] 7980: ffff000008dbcde8 ffff8003fffe1ca0
0000000000000040 ffff8003ee057998
[    1.860094] 79a0: ffff8003ee0579e0 ffff0000086eb1b0
0000000000000004 ffff8003ee057a4c
f8003ebcba000 ffff8003ee057b00
[    1.875669] 79e0: 0000000000000000 ffff8003ebcba070
dead000000000200 dead000000000100
[    1.883457] 7a00: 0000000000000001 0000000000000000
ffff8003df80c700 0000000000000000
[    1.884198] ata4: SATA link down (SStatus 0 SControl 4300)
[    1.884211] ata3: SATA link down (SStatus 0 SControl 4300)
[    1.902153] 7a20: 0101010101010101 0000000000000030
0000000000000030 0000000000000008
[    1.909941] 7a40: ffffffffffffffff ffff000008ce2000
0000000000000001 0000000000000007
[    1.917730] [] rollback_registered_many+0x60/0x300
[    1.924050] [] rollback_registered+0x28/0x40
[    1.929852] [] unregister_netdevice_queue+0x78/0xb8
[    1.936259] [] unregister_netdev+0x20/0x30
[    1.941889] [] xgene_enet_probe+0x638/0xf98
[    1.947605] [] platform_drv_probe+0x50/0xb8
[    1.953320] [] driver_probe_device+0x204/0x2b0
[    1.959294] [] __driver_attach+0xac/0xb0
[    1.964751] [] bus_for_each_dev+0x60/0xa0
[    1.970293] [] driver_attach+0x20/0x28
[    1.975576] [] bus_add_driver+0x1d0/0x238
[    1.981118] [] driver_register+0x60/0xf8
[    1.986574] [] __platform_driver_register+0x40/0x48
[    1.992982] [] xgene_enet_driver_init+0x18/0x20
[    1.999044] [] do_one_initcall+0x38/0x128
[    2.004588] [] kernel_init_freeable+0x1ac/0x250
[    2.010651] [] kernel_init+0x10/0x100
[    2.015847] [] ret_from_fork+0x10/0x40
[    2.021152] network todo 'eth%d' but state 0

Picked up from:

https://storage.kernelci.org/mainline/v4.8-rc2-37-g3ec60b92d3ba/arm64-defconfig/lab-cambridge/boot-apm-mustang.html

Visible on all mainline/apt-mustang boot reports. net-next seems to
have a fix for this.

Riku

> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> Tested-by: Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
> Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
> ---
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.c   |   2 +-
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 120 ++++++++++++++---------
>  2 files changed, 73 insertions(+), 49 deletions(-)
>
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> index 009fb8e..4f98749 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> @@ -901,7 +901,7 @@ int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
>                  ndev->name);
>
>         mdio_bus->priv = pdata;
> -       mdio_bus->parent = &ndev->dev;
> +       mdio_bus->parent = &pdata->pdev->dev;
>
>         ret = xgene_mdiobus_register(pdata, mdio_bus);
>         if (ret) {
> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index f79950a..87e5929 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -608,6 +608,30 @@ static void xgene_enet_timeout(struct net_device *ndev)
>         }
>  }
>
> +static void xgene_enet_set_irq_name(struct net_device *ndev)
> +{
> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +       struct xgene_enet_desc_ring *ring;
> +       int i;
> +
> +       for (i = 0; i < pdata->rxq_cnt; i++) {
> +               ring = pdata->rx_ring[i];
> +               if (!pdata->cq_cnt) {
> +                       snprintf(ring->irq_name, IRQ_ID_SIZE, "%s-rx-txc",
> +                                ndev->name);
> +               } else {
> +                       snprintf(ring->irq_name, IRQ_ID_SIZE, "%s-rx-%d",
> +                                ndev->name, i);
> +               }
> +       }
> +
> +       for (i = 0; i < pdata->cq_cnt; i++) {
> +               ring = pdata->tx_ring[i]->cp_ring;
> +               snprintf(ring->irq_name, IRQ_ID_SIZE, "%s-txc-%d",
> +                        ndev->name, i);
> +       }
> +}
> +
>  static int xgene_enet_register_irq(struct net_device *ndev)
>  {
>         struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> @@ -615,6 +639,7 @@ static int xgene_enet_register_irq(struct net_device *ndev)
>         struct xgene_enet_desc_ring *ring;
>         int ret = 0, i;
>
> +       xgene_enet_set_irq_name(ndev);
>         for (i = 0; i < pdata->rxq_cnt; i++) {
>                 ring = pdata->rx_ring[i];
>                 irq_set_status_flags(ring->irq, IRQ_DISABLE_UNLAZY);
> @@ -723,7 +748,7 @@ static int xgene_enet_open(struct net_device *ndev)
>
>         mac_ops->tx_enable(pdata);
>         mac_ops->rx_enable(pdata);
> -       netif_start_queue(ndev);
> +       netif_tx_start_all_queues(ndev);
>
>         return ret;
>  }
> @@ -734,7 +759,7 @@ static int xgene_enet_close(struct net_device *ndev)
>         const struct xgene_mac_ops *mac_ops = pdata->mac_ops;
>         int i;
>
> -       netif_stop_queue(ndev);
> +       netif_tx_stop_all_queues(ndev);
>         mac_ops->tx_disable(pdata);
>         mac_ops->rx_disable(pdata);
>
> @@ -759,7 +784,7 @@ static void xgene_enet_delete_ring(struct xgene_enet_desc_ring *ring)
>         dev = ndev_to_dev(ring->ndev);
>
>         pdata->ring_ops->clear(ring);
> -       dma_free_coherent(dev, ring->size, ring->desc_addr, ring->dma);
> +       dmam_free_coherent(dev, ring->size, ring->desc_addr, ring->dma);
>  }
>
>  static void xgene_enet_delete_desc_rings(struct xgene_enet_pdata *pdata)
> @@ -834,7 +859,7 @@ static void xgene_enet_free_desc_ring(struct xgene_enet_desc_ring *ring)
>
>         if (ring->desc_addr) {
>                 pdata->ring_ops->clear(ring);
> -               dma_free_coherent(dev, ring->size, ring->desc_addr, ring->dma);
> +               dmam_free_coherent(dev, ring->size, ring->desc_addr, ring->dma);
>         }
>         devm_kfree(dev, ring);
>  }
> @@ -892,9 +917,10 @@ static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
>                         struct net_device *ndev, u32 ring_num,
>                         enum xgene_enet_ring_cfgsize cfgsize, u32 ring_id)
>  {
> -       struct xgene_enet_desc_ring *ring;
>         struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>         struct device *dev = ndev_to_dev(ndev);
> +       struct xgene_enet_desc_ring *ring;
> +       void *irq_mbox_addr;
>         int size;
>
>         size = xgene_enet_get_ring_size(dev, cfgsize);
> @@ -911,8 +937,8 @@ static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
>         ring->cfgsize = cfgsize;
>         ring->id = ring_id;
>
> -       ring->desc_addr = dma_zalloc_coherent(dev, size, &ring->dma,
> -                                             GFP_KERNEL);
> +       ring->desc_addr = dmam_alloc_coherent(dev, size, &ring->dma,
> +                                             GFP_KERNEL | __GFP_ZERO);
>         if (!ring->desc_addr) {
>                 devm_kfree(dev, ring);
>                 return NULL;
> @@ -920,14 +946,16 @@ static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
>         ring->size = size;
>
>         if (is_irq_mbox_required(pdata, ring)) {
> -               ring->irq_mbox_addr = dma_zalloc_coherent(dev, INTR_MBOX_SIZE,
> -                               &ring->irq_mbox_dma, GFP_KERNEL);
> -               if (!ring->irq_mbox_addr) {
> -                       dma_free_coherent(dev, size, ring->desc_addr,
> -                                         ring->dma);
> +               irq_mbox_addr = dmam_alloc_coherent(dev, INTR_MBOX_SIZE,
> +                                                   &ring->irq_mbox_dma,
> +                                                   GFP_KERNEL | __GFP_ZERO);
> +               if (!irq_mbox_addr) {
> +                       dmam_free_coherent(dev, size, ring->desc_addr,
> +                                          ring->dma);
>                         devm_kfree(dev, ring);
>                         return NULL;
>                 }
> +               ring->irq_mbox_addr = irq_mbox_addr;
>         }
>
>         ring->cmd_base = xgene_enet_ring_cmd_base(pdata, ring);
> @@ -988,6 +1016,7 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
>         u8 eth_bufnum = pdata->eth_bufnum;
>         u8 bp_bufnum = pdata->bp_bufnum;
>         u16 ring_num = pdata->ring_num;
> +       __le64 *exp_bufs;
>         u16 ring_id;
>         int i, ret, size;
>
> @@ -1019,13 +1048,6 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
>                 rx_ring->nbufpool = NUM_BUFPOOL;
>                 rx_ring->buf_pool = buf_pool;
>                 rx_ring->irq = pdata->irqs[i];
> -               if (!pdata->cq_cnt) {
> -                       snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx-txc",
> -                                ndev->name);
> -               } else {
> -                       snprintf(rx_ring->irq_name, IRQ_ID_SIZE, "%s-rx%d",
> -                                ndev->name, i);
> -               }
>                 buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
>                                                 sizeof(struct sk_buff *),
>                                                 GFP_KERNEL);
> @@ -1052,13 +1074,13 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
>                 }
>
>                 size = (tx_ring->slots / 2) * sizeof(__le64) * MAX_EXP_BUFFS;
> -               tx_ring->exp_bufs = dma_zalloc_coherent(dev, size,
> -                                                       &dma_exp_bufs,
> -                                                       GFP_KERNEL);
> -               if (!tx_ring->exp_bufs) {
> +               exp_bufs = dmam_alloc_coherent(dev, size, &dma_exp_bufs,
> +                                              GFP_KERNEL | __GFP_ZERO);
> +               if (!exp_bufs) {
>                         ret = -ENOMEM;
>                         goto err;
>                 }
> +               tx_ring->exp_bufs = exp_bufs;
>
>                 pdata->tx_ring[i] = tx_ring;
>
> @@ -1078,8 +1100,6 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
>
>                         cp_ring->irq = pdata->irqs[pdata->rxq_cnt + i];
>                         cp_ring->index = i;
> -                       snprintf(cp_ring->irq_name, IRQ_ID_SIZE, "%s-txc%d",
> -                                ndev->name, i);
>                 }
>
>                 cp_ring->cp_skb = devm_kcalloc(dev, tx_ring->slots,
> @@ -1549,22 +1569,6 @@ static void xgene_enet_napi_add(struct xgene_enet_pdata *pdata)
>         }
>  }
>
> -static void xgene_enet_napi_del(struct xgene_enet_pdata *pdata)
> -{
> -       struct napi_struct *napi;
> -       int i;
> -
> -       for (i = 0; i < pdata->rxq_cnt; i++) {
> -               napi = &pdata->rx_ring[i]->napi;
> -               netif_napi_del(napi);
> -       }
> -
> -       for (i = 0; i < pdata->cq_cnt; i++) {
> -               napi = &pdata->tx_ring[i]->cp_ring->napi;
> -               netif_napi_del(napi);
> -       }
> -}
> -
>  static int xgene_enet_probe(struct platform_device *pdev)
>  {
>         struct net_device *ndev;
> @@ -1628,12 +1632,6 @@ static int xgene_enet_probe(struct platform_device *pdev)
>                 goto err;
>         }
>
> -       ret = register_netdev(ndev);
> -       if (ret) {
> -               netdev_err(ndev, "Failed to register netdev\n");
> -               goto err;
> -       }
> -
>         ret = xgene_enet_init_hw(pdata);
>         if (ret)
>                 goto err_netdev;
> @@ -1648,7 +1646,14 @@ static int xgene_enet_probe(struct platform_device *pdev)
>         }
>
>         xgene_enet_napi_add(pdata);
> +       ret = register_netdev(ndev);
> +       if (ret) {
> +               netdev_err(ndev, "Failed to register netdev\n");
> +               goto err;
> +       }
> +
>         return 0;
> +
>  err_netdev:
>         unregister_netdev(ndev);
>  err:
> @@ -1666,10 +1671,14 @@ static int xgene_enet_remove(struct platform_device *pdev)
>         mac_ops = pdata->mac_ops;
>         ndev = pdata->ndev;
>
> +       rtnl_lock();
> +       if (netif_running(ndev))
> +               dev_close(ndev);
> +       rtnl_unlock();
> +
>         mac_ops->rx_disable(pdata);
>         mac_ops->tx_disable(pdata);
>
> -       xgene_enet_napi_del(pdata);
>         if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
>                 xgene_enet_mdio_remove(pdata);
>         unregister_netdev(ndev);
> @@ -1680,6 +1689,20 @@ static int xgene_enet_remove(struct platform_device *pdev)
>         return 0;
>  }
>
> +static void xgene_enet_shutdown(struct platform_device *pdev)
> +{
> +       struct xgene_enet_pdata *pdata;
> +
> +       pdata = platform_get_drvdata(pdev);
> +       if (!pdata)
> +               return;
> +
> +       if (!pdata->ndev)
> +               return;
> +
> +       xgene_enet_remove(pdev);
> +}
> +
>  #ifdef CONFIG_ACPI
>  static const struct acpi_device_id xgene_enet_acpi_match[] = {
>         { "APMC0D05", XGENE_ENET1},
> @@ -1714,6 +1737,7 @@ static struct platform_driver xgene_enet_driver = {
>         },
>         .probe = xgene_enet_probe,
>         .remove = xgene_enet_remove,
> +       .shutdown = xgene_enet_shutdown,
>  };
>
>  module_platform_driver(xgene_enet_driver);
> --
> 1.9.1
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
