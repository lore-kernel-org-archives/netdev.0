From: Dann Frazier <dann.frazier-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v8 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Tue, 24 Jun 2014 22:29:48 -0600
Message-ID: <CALdTtnvHt5mYMC3619E4F3KK0jPOw7mCpKE6bTn0Um6fdZ4rbw@mail.gmail.com>
References: <1403306296-26198-1-git-send-email-isubramanian@apm.com>
	<1403306296-26198-5-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	patches-qTEPVZfXA3Y@public.gmane.org, Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>,
	Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403306296-26198-5-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 20, 2014 at 5:18 PM, Iyappan Subramanian
<isubramanian-qTEPVZfXA3Y@public.gmane.org> wrote:
> This patch adds network driver for APM X-Gene SoC ethernet.
>
> Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
> Signed-off-by: Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>
> Signed-off-by: Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
> ---
>  drivers/net/ethernet/Kconfig                       |   1 +
>  drivers/net/ethernet/Makefile                      |   1 +
>  drivers/net/ethernet/apm/Kconfig                   |   1 +
>  drivers/net/ethernet/apm/Makefile                  |   5 +
>  drivers/net/ethernet/apm/xgene/Kconfig             |   9 +
>  drivers/net/ethernet/apm/xgene/Makefile            |   6 +
>  .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 125 +++
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 848 +++++++++++++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     | 394 +++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 939 +++++++++++++++++++++
>  drivers/net/ethernet/apm/xgene/xgene_enet_main.h   | 109 +++
>  11 files changed, 2438 insertions(+)
>  create mode 100644 drivers/net/ethernet/apm/Kconfig
>  create mode 100644 drivers/net/ethernet/apm/Makefile
>  create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
>  create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h
[...]
> +static struct xgene_enet_desc_ring *xgene_enet_create_desc_ring(
> +                       struct net_device *ndev, u32 ring_num,
> +                       enum xgene_enet_ring_cfgsize cfgsize, u32 ring_id)
> +{
> +       struct xgene_enet_desc_ring *ring;
> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +       struct device *dev = &pdata->pdev->dev;
> +       u32 size;
> +
> +       ring = devm_kzalloc(dev, sizeof(struct xgene_enet_desc_ring),
> +                           GFP_KERNEL);
> +       if (!ring)
> +               return NULL;
> +
> +       ring->ndev = ndev;
> +       ring->num = ring_num;
> +       ring->cfgsize = cfgsize;
> +       ring->id = ring_id;
> +
> +       size = xgene_enet_get_ring_size(dev, cfgsize);
> +       ring->desc_addr = dma_zalloc_coherent(dev, size, &ring->dma,
> +                                             GFP_KERNEL);

Iyappan,
When testing this driver on a 3.16-rc2 base, I'm finding that
desc_addr gets assigned to NULL here, which results in an oops later
on (see below).

I wasn't seeing this before (3.15 base), so I'm guessing something
changed upstream, or in my config, to change this behavior. But it
does illuminate a place where we could maybe use some better error
handling (also see below).

> +       if (!ring->desc_addr)
> +               goto err;
> +       ring->size = size;
> +
> +       ring->cmd_base = pdata->ring_cmd_addr + (ring->num << 6);
> +       ring->cmd = ring->cmd_base + INC_DEC_CMD_ADDR;
> +       pdata->rm = RM3;
> +       ring = xgene_enet_setup_ring(ring);
> +       netdev_dbg(ndev, "ring info: num=%d  size=%d  id=%d  slots=%d\n",
> +                  ring->num, ring->size, ring->id, ring->slots);
> +
> +       return ring;
> +err:
> +       dma_free_coherent(dev, size, ring->desc_addr, ring->dma);
> +       devm_kfree(dev, ring);
> +
> +       return NULL;
> +}
> +
> +static u16 xgene_enet_get_ring_id(enum xgene_ring_owner owner, u8 bufnum)
> +{
> +       return (owner << 6) | (bufnum & GENMASK(5, 0));
> +}
> +
> +static int xgene_enet_create_desc_rings(struct net_device *ndev)
> +{
> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +       struct device *dev = &pdata->pdev->dev;
> +       struct xgene_enet_desc_ring *rx_ring, *tx_ring, *cp_ring;
> +       struct xgene_enet_desc_ring *buf_pool = NULL;
> +       u8 cpu_bufnum = 0, eth_bufnum = 0;
> +       u8 bp_bufnum = 0x20;
> +       u16 ring_id, ring_num = 0;
> +       int ret;
> +
> +       /* allocate rx descriptor ring */
> +       ring_id = xgene_enet_get_ring_id(RING_OWNER_CPU, cpu_bufnum++);
> +       rx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
> +                                             RING_CFGSIZE_16KB, ring_id);
> +       if (IS_ERR_OR_NULL(rx_ring)) {
> +               ret = PTR_ERR(rx_ring);
> +               goto err;
> +       }

Here we test for IS_ERR_OR_NULL. In the oops I'm hitting, rx_ring is
NULL here - but PTR_ERR() apparently returns 0 in that case. So this
function ends up returning no error.

> +       /* allocate buffer pool for receiving packets */
> +       ring_id = xgene_enet_get_ring_id(RING_OWNER_ETH0, bp_bufnum++);
> +       buf_pool = xgene_enet_create_desc_ring(ndev, ring_num++,
> +                                              RING_CFGSIZE_2KB, ring_id);
> +       if (IS_ERR_OR_NULL(buf_pool)) {
> +               ret = PTR_ERR(buf_pool);
> +               goto err;
> +       }
> +
> +       rx_ring->nbufpool = NUM_BUFPOOL;
> +       rx_ring->buf_pool = buf_pool;
> +       rx_ring->irq = pdata->rx_irq;
> +       buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
> +                                    sizeof(struct sk_buff *), GFP_KERNEL);
> +       if (!buf_pool->rx_skb) {
> +               ret = -ENOMEM;
> +               goto err;
> +       }
> +
> +       buf_pool->dst_ring_num = xgene_enet_dst_ring_num(buf_pool);
> +       rx_ring->buf_pool = buf_pool;
> +       pdata->rx_ring = rx_ring;
> +
> +       /* allocate tx descriptor ring */
> +       ring_id = xgene_enet_get_ring_id(RING_OWNER_ETH0, eth_bufnum++);
> +       tx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
> +                                             RING_CFGSIZE_16KB, ring_id);
> +       if (IS_ERR_OR_NULL(tx_ring)) {
> +               ret = PTR_ERR(tx_ring);
> +               goto err;
> +       }
> +       pdata->tx_ring = tx_ring;
> +
> +       cp_ring = pdata->rx_ring;
> +       cp_ring->cp_skb = devm_kcalloc(dev, tx_ring->slots,
> +                                    sizeof(struct sk_buff *), GFP_KERNEL);
> +       if (!cp_ring->cp_skb) {
> +               ret = -ENOMEM;
> +               goto err;
> +       }
> +       pdata->tx_ring->cp_ring = cp_ring;
> +       pdata->tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
> +
> +       pdata->tx_qcnt_hi = pdata->tx_ring->slots / 2;
> +       pdata->cp_qcnt_hi = pdata->rx_ring->slots / 2;
> +       pdata->cp_qcnt_low = pdata->cp_qcnt_hi / 2;
> +
> +       return 0;
> +
> +err:
> +       xgene_enet_delete_desc_rings(pdata);
> +       return ret;
> +}
> +
> +static struct rtnl_link_stats64 *xgene_enet_get_stats64(
> +                       struct net_device *ndev,
> +                       struct rtnl_link_stats64 *storage)
> +{
> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +       struct rtnl_link_stats64 *stats = &pdata->stats;
> +
> +       spin_lock(&pdata->stats_lock);
> +       stats->rx_errors += stats->rx_length_errors +
> +                           stats->rx_crc_errors +
> +                           stats->rx_frame_errors +
> +                           stats->rx_fifo_errors;
> +       memcpy(storage, &pdata->stats, sizeof(struct rtnl_link_stats64));
> +       spin_unlock(&pdata->stats_lock);
> +
> +       return storage;
> +}
> +
> +static int xgene_enet_set_mac_address(struct net_device *ndev, void *addr)
> +{
> +       struct xgene_enet_pdata *pdata = netdev_priv(ndev);
> +       int ret;
> +
> +       ret = eth_mac_addr(ndev, addr);
> +       if (ret)
> +               return ret;
> +       xgene_gmac_set_mac_addr(pdata);
> +
> +       return ret;
> +}
> +
> +static const struct net_device_ops xgene_ndev_ops = {
> +       .ndo_open = xgene_enet_open,
> +       .ndo_stop = xgene_enet_close,
> +       .ndo_start_xmit = xgene_enet_start_xmit,
> +       .ndo_tx_timeout = xgene_enet_timeout,
> +       .ndo_get_stats64 = xgene_enet_get_stats64,
> +       .ndo_change_mtu = eth_change_mtu,
> +       .ndo_set_mac_address = xgene_enet_set_mac_address,
> +};
> +
> +static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
> +{
> +       struct platform_device *pdev;
> +       struct net_device *ndev;
> +       struct device *dev;
> +       struct resource *res;
> +       void *base_addr;
> +       const char *mac;
> +       int ret;
> +
> +       pdev = pdata->pdev;
> +       dev = &pdev->dev;
> +       ndev = pdata->ndev;
> +
> +       res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "enet_csr");
> +       if (!res) {
> +               dev_err(dev, "Resource enet_csr not defined\n");
> +               return -ENODEV;
> +       }
> +       pdata->base_addr = devm_ioremap_resource(dev, res);
> +       if (IS_ERR(pdata->base_addr)) {
> +               dev_err(dev, "Unable to retrieve ENET Port CSR region\n");
> +               return PTR_ERR(pdata->base_addr);
> +       }
> +
> +       res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ring_csr");
> +       if (!res) {
> +               dev_err(dev, "Resource ring_csr not defined\n");
> +               return -ENODEV;
> +       }
> +       pdata->ring_csr_addr = devm_ioremap_resource(dev, res);
> +       if (IS_ERR(pdata->ring_csr_addr)) {
> +               dev_err(dev, "Unable to retrieve ENET Ring CSR region\n");
> +               return PTR_ERR(pdata->ring_csr_addr);
> +       }
> +
> +       res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "ring_cmd");
> +       if (!res) {
> +               dev_err(dev, "Resource ring_cmd not defined\n");
> +               return -ENODEV;
> +       }
> +       pdata->ring_cmd_addr = devm_ioremap_resource(dev, res);
> +       if (IS_ERR(pdata->ring_cmd_addr)) {
> +               dev_err(dev, "Unable to retrieve ENET Ring command region\n");
> +               return PTR_ERR(pdata->ring_cmd_addr);
> +       }
> +
> +       ret = platform_get_irq(pdev, 0);
> +       if (ret <= 0) {
> +               dev_err(dev, "Unable to get ENET Rx IRQ\n");
> +               ret = ret ? : -ENXIO;
> +               return ret;
> +       }
> +       pdata->rx_irq = ret;
> +
> +       mac = of_get_mac_address(dev->of_node);
> +       if (mac)
> +               memcpy(ndev->dev_addr, mac, ndev->addr_len);
> +       else
> +               eth_hw_addr_random(ndev);
> +       memcpy(ndev->perm_addr, ndev->dev_addr, ndev->addr_len);
> +
> +       pdata->phy_mode = of_get_phy_mode(pdev->dev.of_node);
> +       if (pdata->phy_mode < 0) {
> +               dev_err(dev, "Incorrect phy-connection-type in DTS\n");
> +               return -EINVAL;
> +       }
> +
> +       pdata->clk = devm_clk_get(&pdev->dev, NULL);
> +       ret = IS_ERR(pdata->clk);
> +       if (IS_ERR(pdata->clk)) {
> +               dev_err(&pdev->dev, "can't get clock\n");
> +               ret = PTR_ERR(pdata->clk);
> +               return ret;
> +       }
> +
> +       base_addr = pdata->base_addr;
> +       pdata->eth_csr_addr = base_addr + BLOCK_ETH_CSR_OFFSET;
> +       pdata->eth_ring_if_addr = base_addr + BLOCK_ETH_RING_IF_OFFSET;
> +       pdata->eth_diag_csr_addr = base_addr + BLOCK_ETH_DIAG_CSR_OFFSET;
> +       pdata->mcx_mac_addr = base_addr + BLOCK_ETH_MAC_OFFSET;
> +       pdata->mcx_stats_addr = base_addr + BLOCK_ETH_STATS_OFFSET;
> +       pdata->mcx_mac_csr_addr = base_addr + BLOCK_ETH_MAC_CSR_OFFSET;
> +       pdata->rx_buff_cnt = NUM_PKT_BUF;
> +
> +       return ret;
> +}
> +
> +static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
> +{
> +       struct net_device *ndev = pdata->ndev;
> +       struct xgene_enet_desc_ring *buf_pool;
> +       u16 dst_ring_num;
> +       int ret;
> +
> +       xgene_gmac_tx_disable(pdata);
> +       xgene_gmac_rx_disable(pdata);
> +
> +       ret = xgene_enet_create_desc_rings(ndev);
> +       if (ret) {
> +               netdev_err(ndev, "Error in ring configuration\n");
> +               return ret;
> +       }
> +
> +       /* setup buffer pool */
> +       buf_pool = pdata->rx_ring->buf_pool;

^ Here's where the oops ultimately surfaces, when we dereference the
NULL rx_ring.

 -dann

> +       xgene_enet_init_bufpool(buf_pool);
> +       ret = xgene_enet_refill_bufpool(buf_pool, pdata->rx_buff_cnt);
> +       if (ret)
> +               return ret;
> +
> +       dst_ring_num = xgene_enet_dst_ring_num(pdata->rx_ring);
> +       xgene_enet_cle_bypass(pdata, dst_ring_num, buf_pool->id);
> +
> +       return ret;
> +}
[...]
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
