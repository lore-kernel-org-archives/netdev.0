From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v9 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Thu, 7 Aug 2014 15:11:01 -0700
Message-ID: <CAKh23FkOsGLAOP5ypjh++V5PDeFOBLKOFTnnfmzyBu8stD=biQ@mail.gmail.com>
References: <1405376285-23008-1-git-send-email-isubramanian@apm.com>
	<1405376285-23008-5-git-send-email-isubramanian@apm.com>
	<20140715074829.GC7668@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"jcm@redhat.com" <jcm@redhat.com>, patches <patches@apm.com>,
	Ravi Patel <rapatel@apm.com>, Keyur Chudgar <kchudgar@apm.com>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og121.obsmtp.com ([64.18.0.139]:56961 "HELO
	exprod5og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751780AbaHGWLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 18:11:04 -0400
Received: by mail-lb0-f170.google.com with SMTP id l4so1298006lbv.1
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2014 15:11:01 -0700 (PDT)
In-Reply-To: <20140715074829.GC7668@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 15, 2014 at 12:48 AM, Tobias Klauser <tklauser@distanz.ch> wrote:
> On 2014-07-15 at 00:18:05 +0200, Iyappan Subramanian <isubramanian@apm.com> wrote:
>> This patch adds network driver for APM X-Gene SoC ethernet.
>>
>> Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
>> Signed-off-by: Ravi Patel <rapatel@apm.com>
>> Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
>> ---
>>  drivers/net/ethernet/Kconfig                       |   1 +
>>  drivers/net/ethernet/Makefile                      |   1 +
>>  drivers/net/ethernet/apm/Kconfig                   |   1 +
>>  drivers/net/ethernet/apm/Makefile                  |   5 +
>>  drivers/net/ethernet/apm/xgene/Kconfig             |   9 +
>>  drivers/net/ethernet/apm/xgene/Makefile            |   6 +
>>  .../net/ethernet/apm/xgene/xgene_enet_ethtool.c    | 125 +++
>>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     | 747 ++++++++++++++++
>>  drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     | 375 ++++++++
>>  drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 962 +++++++++++++++++++++
>>  drivers/net/ethernet/apm/xgene/xgene_enet_main.h   | 107 +++
>>  11 files changed, 2339 insertions(+)
>>  create mode 100644 drivers/net/ethernet/apm/Kconfig
>>  create mode 100644 drivers/net/ethernet/apm/Makefile
>>  create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
>>  create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
>>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_ethtool.c
>>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
>>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
>>  create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h
>
> [...]
>
>> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>> new file mode 100644
>> index 0000000..e52af60
>> --- /dev/null
>> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
>> @@ -0,0 +1,747 @@
>
> [...]
>
>> +int xgene_enet_mdio_config(struct xgene_enet_pdata *pdata)
>> +{
>> +     struct net_device *ndev = pdata->ndev;
>> +     struct device *dev = &pdata->pdev->dev;
>> +     struct device_node *child_np;
>> +     struct device_node *mdio_np = NULL;
>> +     struct mii_bus *mdio_bus;
>> +     int ret;
>> +
>> +     for_each_child_of_node(dev->of_node, child_np) {
>> +             if (of_device_is_compatible(child_np, "apm,xgene-mdio")) {
>> +                     mdio_np = child_np;
>> +                     break;
>> +             }
>> +     }
>> +
>> +     if (!mdio_np) {
>> +             netdev_dbg(ndev, "No mdio node in the dts\n");
>> +             return -1;
>> +     }
>> +
>> +     mdio_bus = mdiobus_alloc();
>> +     if (!mdio_bus)
>> +             return -ENOMEM;
>> +
>> +     mdio_bus->name = "APM X-Gene MDIO bus";
>> +     mdio_bus->read = xgene_enet_mdio_read;
>> +     mdio_bus->write = xgene_enet_mdio_write;
>> +     snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-%s", "xgene-mii",
>> +              ndev->name);
>> +
>> +     mdio_bus->priv = pdata;
>> +     mdio_bus->parent = &ndev->dev;
>> +
>> +     ret = of_mdiobus_register(mdio_bus, mdio_np);
>> +     if (ret) {
>> +             netdev_err(ndev, "Failed to register MDIO bus\n");
>> +             goto err;
>> +     }
>> +     pdata->mdio_bus = mdio_bus;
>> +
>> +     ret = xgene_enet_phy_connect(ndev);
>> +     if (ret)
>
> mdiobus_unregister() should be called on this error path.

Thanks.  I will fix this.

>
>> +             goto err;
>> +
>> +     return ret;
>> +
>> +err:
>> +     mdiobus_free(mdio_bus);
>> +
>> +     return ret;
>> +}
>
> [...]
>
>> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
>> new file mode 100644
>> index 0000000..756523a
>> --- /dev/null
>> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
>
> [...]
>
>> +static struct rtnl_link_stats64 *xgene_enet_get_stats64(
>> +                     struct net_device *ndev,
>> +                     struct rtnl_link_stats64 *storage)
>> +{
>> +     struct xgene_enet_pdata *pdata = netdev_priv(ndev);
>> +     struct rtnl_link_stats64 *stats = &pdata->stats;
>> +
>> +     spin_lock(&pdata->stats_lock);
>
> What is the purpose of this spinlock? It doesn't seem to protect any
> hardware-specific stats readout. Is it really necessary?

I agree and will remove the spin lock.

>
>> +     stats->rx_errors += stats->rx_length_errors +
>> +                         stats->rx_crc_errors +
>> +                         stats->rx_frame_errors +
>> +                         stats->rx_fifo_errors;
>> +     memcpy(storage, &pdata->stats, sizeof(struct rtnl_link_stats64));
>> +     spin_unlock(&pdata->stats_lock);
>> +
>> +     return storage;
>> +}
>
> [...]
>
>> +static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
>> +{
>> +     struct net_device *ndev = pdata->ndev;
>> +     struct xgene_enet_desc_ring *buf_pool;
>> +     u16 dst_ring_num;
>> +     int ret;
>> +
>> +     xgene_gmac_tx_disable(pdata);
>> +     xgene_gmac_rx_disable(pdata);
>> +
>> +     ret = xgene_enet_create_desc_rings(ndev);
>> +     if (ret) {
>> +             netdev_err(ndev, "Error in ring configuration\n");
>> +             return ret;
>> +     }
>> +
>> +     /* setup buffer pool */
>> +     buf_pool = pdata->rx_ring->buf_pool;
>> +     xgene_enet_init_bufpool(buf_pool);
>> +     ret = xgene_enet_refill_bufpool(buf_pool, pdata->rx_buff_cnt);
>> +     if (ret)
>
> Shouldn't xgene_enet_delete_desc_rings() be called here?

I will fix this.

>
>> +             return ret;
>> +
>> +     dst_ring_num = xgene_enet_dst_ring_num(pdata->rx_ring);
>> +     xgene_enet_cle_bypass(pdata, dst_ring_num, buf_pool->id);
>> +
>> +     return ret;
>> +}
>> +
>> +static int xgene_enet_probe(struct platform_device *pdev)
>> +{
>> +     struct net_device *ndev;
>> +     struct xgene_enet_pdata *pdata;
>> +     struct device *dev = &pdev->dev;
>> +     struct napi_struct *napi;
>> +     int ret;
>> +
>> +     ndev = alloc_etherdev(sizeof(struct xgene_enet_pdata));
>> +     if (!ndev)
>> +             return -ENOMEM;
>> +
>> +     pdata = netdev_priv(ndev);
>> +
>> +     pdata->pdev = pdev;
>> +     pdata->ndev = ndev;
>> +     SET_NETDEV_DEV(ndev, dev);
>> +     platform_set_drvdata(pdev, pdata);
>> +     ndev->netdev_ops = &xgene_ndev_ops;
>> +     xgene_enet_set_ethtool_ops(ndev);
>> +     ndev->features |= NETIF_F_IP_CSUM |
>> +                       NETIF_F_GSO |
>> +                       NETIF_F_GRO;
>> +
>> +     ret = xgene_enet_get_resources(pdata);
>> +     if (ret)
>> +             goto err;
>> +
>> +     xgene_enet_reset(pdata);
>> +     xgene_gmac_init(pdata, SPEED_1000);
>> +
>> +     spin_lock_init(&pdata->stats_lock);
>> +     ret = register_netdev(ndev);
>> +     if (ret) {
>> +             netdev_err(ndev, "Failed to register netdev\n");
>> +             goto err;
>> +     }
>> +
>> +     ret = dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64));
>> +     if (ret) {
>> +             netdev_err(ndev, "No usable DMA configuration\n");
>> +             goto err;
>> +     }
>> +
>> +     ret = xgene_enet_init_hw(pdata);
>> +     if (ret)
>> +             goto err;
>> +
>> +     napi = &pdata->rx_ring->napi;
>> +     netif_napi_add(ndev, napi, xgene_enet_napi, NAPI_POLL_WEIGHT);
>> +     ret = xgene_enet_mdio_config(pdata);
>> +
>> +     return ret;
>> +err:
>> +     free_netdev(ndev);
>> +     return ret;
>> +}
>> +
>> +static int xgene_enet_remove(struct platform_device *pdev)
>> +{
>> +     struct xgene_enet_pdata *pdata;
>> +     struct net_device *ndev;
>> +
>> +     pdata = platform_get_drvdata(pdev);
>> +     ndev = pdata->ndev;
>> +
>> +     xgene_gmac_rx_disable(pdata);
>> +     xgene_gmac_tx_disable(pdata);
>> +
>> +     netif_napi_del(&pdata->rx_ring->napi);
>> +     xgene_enet_mdio_remove(pdata);
>> +     xgene_enet_delete_desc_rings(pdata);
>> +     unregister_netdev(ndev);
>> +     xgene_gport_shutdown(pdata);
>> +     free_netdev(ndev);
>> +
>> +     return 0;
>> +}
>> +
>> +static struct of_device_id xgene_enet_match[] = {
>> +     {.compatible = "apm,xgene-enet",},
>> +     {},
>> +};
>> +
>> +MODULE_DEVICE_TABLE(of, xgene_enet_match);
>> +
>> +static struct platform_driver xgene_enet_driver = {
>> +     .driver = {
>> +                .name = "xgene-enet",
>> +                .owner = THIS_MODULE,
>> +                .of_match_table = xgene_enet_match,
>> +                },
>> +     .probe = xgene_enet_probe,
>> +     .remove = xgene_enet_remove,
>> +};
>> +
>> +module_platform_driver(xgene_enet_driver);
>> +
>> +MODULE_DESCRIPTION("APM X-Gene SoC Ethernet driver");
>> +MODULE_VERSION(XGENE_DRV_VERSION);
>> +MODULE_AUTHOR("Keyur Chudgar <kchudgar@apm.com>");
>> +MODULE_LICENSE("GPL");
