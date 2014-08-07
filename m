From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: Re: [PATCH v9 4/4] drivers: net: Add APM X-Gene SoC ethernet driver support.
Date: Thu, 7 Aug 2014 15:09:25 -0700
Message-ID: <CAKh23FmULrDLd0uvqh=wA_UC9uZxnmGjipodk2u5TP6h4e8Q1w@mail.gmail.com>
References: <1405376285-23008-1-git-send-email-isubramanian@apm.com>
	<1405376285-23008-5-git-send-email-isubramanian@apm.com>
	<53C4C584.1090109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, patches <patches-qTEPVZfXA3Y@public.gmane.org>,
	Ravi Patel <rapatel-qTEPVZfXA3Y@public.gmane.org>, Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53C4C584.1090109-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 14, 2014 at 11:09 PM, Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On 07/15/2014 03:48 AM, Iyappan Subramanian wrote:
>
> (...)
>
> +static void xgene_enet_rd_mcx_mac(struct xgene_enet_pdata *pdata,
> +  u32 rd_addr, u32 *rd_data)
> +{
> + void __iomem *addr, *rd, *cmd, *cmd_done;
> + bool ret;
> +
> + addr = pdata->mcx_mac_addr + MAC_ADDR_REG_OFFSET;
> + rd = pdata->mcx_mac_addr + MAC_READ_REG_OFFSET;
> + cmd = pdata->mcx_mac_addr + MAC_COMMAND_REG_OFFSET;
> + cmd_done = pdata->mcx_mac_addr + MAC_COMMAND_DONE_REG_OFFSET;
> +
> + ret = xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data);
> + if (!ret)
> + netdev_err(pdata->ndev, "MCX mac read failed, addr: %04x\n",
> +   rd_addr);
>
> if (!xgene_enet_rd_indirect(addr, rd, cmd, cmd_done, rd_addr, rd_data))
> netdev_err(pdata->ndev, "MCX mac read failed, addr: %04x\n",
>   rd_addr);
>
> +}
> +

I will apply the change here as well as at the wr_mcx_mac function.

>
> (...)
>
> +static int xgene_enet_mdio_write(struct mii_bus *bus, int mii_id, int
> regnum,
> + u16 val)
> +{
> + struct xgene_enet_pdata *pdata = bus->priv;
> + int ret;
> +
> + netdev_dbg(pdata->ndev, "mdio_wr: bus=%d reg=%d val=%x\n",
> +   mii_id, regnum, val);
> + ret = xgene_mii_phy_write(pdata, mii_id, regnum, val);
> +
> + return ret;
>
> return xgene_mii_phy_write(pdata, mii_id, regnum, val);
>
> No need of ret variable....

I will apply the change.

>
> +}
> +
> +
>
> (...)
>
> +
> + rx_ring->nbufpool = NUM_BUFPOOL;
> + rx_ring->buf_pool = buf_pool;
> + rx_ring->irq = pdata->rx_irq;
> + buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
> +     sizeof(struct sk_buff *), GFP_KERNEL);
>
> Should match open paranthesis:

I will fix these.

>
> buf_pool->rx_skb = devm_kcalloc(dev, buf_pool->slots,
> sizeof(struct sk_buff *),
> GFP_KERNEL);
>
> + if (!buf_pool->rx_skb) {
> + ret = -ENOMEM;
> + goto err;
> + }
> +
> + buf_pool->dst_ring_num = xgene_enet_dst_ring_num(buf_pool);
> + rx_ring->buf_pool = buf_pool;
> + pdata->rx_ring = rx_ring;
> +
> + /* allocate tx descriptor ring */
> + ring_id = xgene_enet_get_ring_id(RING_OWNER_ETH0, eth_bufnum++);
> + tx_ring = xgene_enet_create_desc_ring(ndev, ring_num++,
> +      RING_CFGSIZE_16KB, ring_id);
> + if (!tx_ring) {
> + ret = -ENOMEM;
> + goto err;
> + }
> + pdata->tx_ring = tx_ring;
> +
> + cp_ring = pdata->rx_ring;
> + cp_ring->cp_skb = devm_kcalloc(dev, tx_ring->slots,
> +     sizeof(struct sk_buff *), GFP_KERNEL);
>
> Ditto
>
> + if (!cp_ring->cp_skb) {
> + ret = -ENOMEM;
> + goto err;
> + }
> + pdata->tx_ring->cp_ring = cp_ring;
> + pdata->tx_ring->dst_ring_num = xgene_enet_dst_ring_num(cp_ring);
> +
> + pdata->tx_qcnt_hi = pdata->tx_ring->slots / 2;
> + pdata->cp_qcnt_hi = pdata->rx_ring->slots / 2;
> + pdata->cp_qcnt_low = pdata->cp_qcnt_hi / 2;
> +
> + return 0;
> +
> +err:
> + xgene_enet_free_desc_rings(pdata);
> + return ret;
> +}
> +
>
> (...)
>
> +
> +static struct of_device_id xgene_enet_match[] = {
> + {.compatible = "apm,xgene-enet",},
> + {},
> +};
> +
> +MODULE_DEVICE_TABLE(of, xgene_enet_match);
> +
> +static struct platform_driver xgene_enet_driver = {
> + .driver = {
> +   .name = "xgene-enet",
> +   .owner = THIS_MODULE,
>
> No need to update .owner. module_platform_driver() will do for you.
>
> see:
> http://lxr.free-electrons.com/source/include/linux/platform_device.h#L190

I will remove the owner field initialization.

>
> +   .of_match_table = xgene_enet_match,
> +   },
> + .probe = xgene_enet_probe,
> + .remove = xgene_enet_remove,
> +};
> +
> +module_platform_driver(xgene_enet_driver);
> +
> +MODULE_DESCRIPTION("APM X-Gene SoC Ethernet driver");
> +MODULE_VERSION(XGENE_DRV_VERSION);
> +MODULE_AUTHOR("Keyur Chudgar <kchudgar-qTEPVZfXA3Y@public.gmane.org>");
> +MODULE_LICENSE("GPL");
>
> This is lengthy patch... Its better if you split the patch...

This is the base driver and it will be difficult to split the patches
at this stage.

>
> --
> Regards,
> Varka Bhadram.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
