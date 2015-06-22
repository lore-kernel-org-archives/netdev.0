From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: [PATCH v6] NET: Add ezchip ethernet driver
Date: Tue, 23 Jun 2015 00:04:56 +0300
Message-ID: <CAKoUArmpRk4LJNCTkANtcB69qOOS8N0JuDS_VXhCpp2gTZCmPw@mail.gmail.com>
References: <1434465342-7412-1-git-send-email-noamc@ezchip.com>
	<1435006284-15445-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexey.Brodkin@synopsys.com, vgupta@synopsys.com,
	giladb@ezchip.com, cmetcalf@ezchip.com,
	Tal Zilcer <talz@ezchip.com>
To: Noam Camus <noamc@ezchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:34140 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751764AbbFVVE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 17:04:57 -0400
In-Reply-To: <1435006284-15445-1-git-send-email-noamc@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Noam,

Just a typo and a nitpick:

+/**
+ * nps_enet_open - Open the network device.
+ * @ndev:       Pointer to the network device.
+ *
+ * returns: 0, on success or non-zero error value on failure.
+ *

Maybe better:  This function enables IRQs

+ * This function enables an IRQs for the ENET device and starts the Tx queue.



+static s32 nps_enet_probe(struct platform_device *pdev)
+{
+       struct device *dev = &pdev->dev;
+       struct net_device *ndev;
+       struct nps_enet_priv *priv;
+       s32 err = 0;
+       const char *mac_addr;
+       struct resource *res_regs;
+
+       if (!dev->of_node)
+               return -ENODEV;
+
+       ndev = alloc_etherdev(sizeof(struct nps_enet_priv));
+       if (!ndev)
+               return -ENOMEM;
+
+       platform_set_drvdata(pdev, ndev);
+       SET_NETDEV_DEV(ndev, dev);
+       priv = netdev_priv(ndev);
+
+       /* The EZ NET specific entries in the device structure. */
+       ndev->netdev_ops = &nps_netdev_ops;
+       ndev->watchdog_timeo = (400 * HZ / 1000);
+       /* FIXME :: no multicast support yet */
+       ndev->flags &= ~IFF_MULTICAST;
+
+       res_regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+       priv->regs_base = devm_ioremap_resource(dev, res_regs);
+       if (IS_ERR(priv->regs_base)) {
+               err = PTR_ERR(priv->regs_base);
+               goto out_netdev;
+       }
+       dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs_base);
+
+       /* set kernel MAC address to dev */
+       mac_addr = of_get_mac_address(dev->of_node);
+       if (mac_addr)
+               ether_addr_copy(ndev->dev_addr, mac_addr);
+       else
+               eth_hw_addr_random(ndev);
+
+       /* Get IRQ number */
+       priv->irq = platform_get_irq(pdev, 0);
+       if (!priv->irq) {
+               dev_err(dev, "failed to retrieve <irq Rx-Tx> value
from device tree\n");
+               err = -ENODEV;
+               goto out_netdev;
+       }
+
+       netif_napi_add(ndev, &priv->napi, nps_enet_poll,
+                      NPS_ENET_NAPI_POLL_WEIGHT);

+
+       /* Register the driver. Should be the last thing in probe */
+       err = register_netdev(ndev);
+       if (err) {
+               dev_err(dev, "Failed to register ndev for %s, err = 0x%08x\n",
+                       ndev->name, (s32)err);

Wouldn't it be better not to assign any value at this point to err, so
that the returned err will reflect the true return value of
register_netdev(), which can have various error values ?

+               err = -ENODEV;
+               goto out_netif_api;
+       }
+
+       dev_info(dev, "(rx/tx=%d)\n", priv->irq);
+       return 0;
+
+out_netif_api:
+       netif_napi_del(&priv->napi);
+out_netdev:
+       if (err)
+               free_netdev(ndev);
+
+       return err;
+}


Regards,
Rami Rosen
