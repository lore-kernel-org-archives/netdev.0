From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next v2 9/9] Altera TSE: Add main and header file for
 Altera Ethernet Driver
Date: Tue, 11 Mar 2014 10:38:37 -0500
Message-ID: <CAOwfj2PB7NCnrF4q1JgVRBpvmytTnoc037JjYWyDdQbnCnbpXA@mail.gmail.com>
References: <1394493277-2105-1-git-send-email-vbridgers2013@gmail.com>
	<1394493277-2105-10-git-send-email-vbridgers2013@gmail.com>
	<20140311094432.GB31679@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	Pawel Moll <Pawel.Moll@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"rob@landley.net" <rob@landley.net>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:39934 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbaCKPii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 11:38:38 -0400
In-Reply-To: <20140311094432.GB31679@e106331-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 4:44 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Mon, Mar 10, 2014 at 11:14:37PM +0000, Vince Bridgers wrote:
>> This patch adds the main driver and header file for the Altera Triple
>> Speed Ethernet driver.
>>
>> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
>> ---
>> V2: - Address all comments from initial RFC (thanks Florian!)
>>     - Moved asm/cacheflush.h to bottom of header includes
>>     - Remove barriers since DMA APIs ensure memory consistency
>>     - Add max-frame-size property
>>     - Use accessor function of_get_phy_mode instead of custom function
>>     - Remove custom function to access devicetree, use of APIs
>>     - Deprecate use of Altera devicetree properties where standard
>>       ones exist
>>     - Remove use of netif_carrier_off - not necessary where it was used
>>     - Move probing of phy to the probe routine instead of open
>>     - use ether_addr_copy instead of memcpy
>> ---
>>  drivers/net/ethernet/altera/altera_tse.h      |  486 ++++++++
>>  drivers/net/ethernet/altera/altera_tse_main.c | 1546 +++++++++++++++++++++++++
>>  2 files changed, 2032 insertions(+)
>>  create mode 100644 drivers/net/ethernet/altera/altera_tse.h
>>  create mode 100644 drivers/net/ethernet/altera/altera_tse_main.c
>
> [...]
>
>> +static int altera_tse_mdio_create(struct net_device *dev, unsigned int id)
>> +{
>> +       struct altera_tse_private *priv = netdev_priv(dev);
>> +       int ret;
>> +       int i;
>> +       struct device_node *mdio_node;
>> +       struct mii_bus *mdio;
>> +
>> +       mdio_node = of_find_compatible_node(priv->device->of_node, NULL,
>> +               "altr,tse-mdio");
>
> This doesn't find a subnode, as the binding requires. This finds _any_
> compatible node in the tree.
>
> There doesn't seem to be an of_find_compatible_child_node, but you can
> use for_each_child_of_node and of_device_is_compatible to achieve the
> same effect.

Double doh! Will address, thank you.

>
> [...]
>
>> +static struct phy_device *connect_local_phy(struct net_device *dev)
>> +{
>> +       struct altera_tse_private *priv = netdev_priv(dev);
>> +       struct phy_device *phydev = NULL;
>> +       char phy_id_fmt[MII_BUS_ID_SIZE + 3];
>> +       int ret;
>> +
>> +       if (priv->phy_addr != POLL_PHY) {
>> +               snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT,
>> +                        priv->mdio->id, priv->phy_addr);
>> +
>> +               dev_dbg(priv->device, "trying to attach to %s\n", phy_id_fmt);
>> +
>> +               phydev = phy_connect(dev, phy_id_fmt, &altera_tse_adjust_link,
>> +                                    priv->phy_iface);
>> +               if (IS_ERR(phydev))
>> +                       netdev_err(dev, "Could not attach to PHY\n");
>> +
>> +       } else {
>> +               phydev = phy_find_first(priv->mdio);
>> +               if (phydev == NULL) {
>> +                       netdev_err(dev, "No PHY found\n");
>> +                       return phydev;
>> +               }
>> +
>> +               ret = phy_connect_direct(dev, phydev, &altera_tse_adjust_link,
>> +                               priv->phy_iface);
>> +               if (ret != 0) {
>> +                       netdev_err(dev, "Could not attach to PHY\n");
>> +                       phydev = NULL;
>> +               }
>> +       }
>> +       return phydev;
>> +}
>> +
>> +/* Initialize driver's PHY state, and attach to the PHY
>> + */
>> +static int init_phy(struct net_device *dev)
>> +{
>> +       struct altera_tse_private *priv = netdev_priv(dev);
>> +       struct phy_device *phydev;
>> +       struct device_node *phynode;
>> +
>> +       priv->oldlink = 0;
>> +       priv->oldspeed = 0;
>> +       priv->oldduplex = -1;
>> +
>> +       phynode = of_parse_phandle(priv->device->of_node, "phy-handle", 0);
>> +
>> +       if (!phynode) {
>> +               netdev_dbg(dev, "no phy-handle found\n");
>> +               if (!priv->mdio) {
>> +                       netdev_err(dev,
>> +                                  "No phy-handle nor local mdio specified\n");
>> +                       return -ENODEV;
>> +               }
>> +               phydev = connect_local_phy(dev);
>> +       } else {
>> +               netdev_dbg(dev, "phy-handle found\n");
>> +               phydev = of_phy_connect(dev, phynode,
>> +                       &altera_tse_adjust_link, 0, priv->phy_iface);
>> +       }
>
> Be aware that of_phy_connect can return NULL (e.g. if the phy-handle
> phandle pointed to a node that wasn't a phy). You'll want to check it's
> not NULL before dereferencing it below.
>
> The same seems to be true of connect_local_phy, so the check can be
> shared.

Doh! Will address, thank you.

>
> [...]
>
>> +       /* get hash filter settings for this instance */
>> +       if (of_property_read_u32(pdev->dev.of_node, "altr,enable-hash",
>> +                                &priv->hash_filter)) {
>> +               dev_err(&pdev->dev, "cannot obtain altr,enable-hash\n");
>> +               priv->hash_filter = 0;
>> +       }
>> +
>> +       /* get supplemental address settings for this instance */
>> +       if (of_property_read_u32(pdev->dev.of_node, "altr,enable-sup-addr",
>> +                                &priv->added_unicast)) {
>> +               dev_err(&pdev->dev, "cannot obtain altr,enable-sup-addr\n");
>> +               priv->added_unicast = 0;
>> +       }
>
> Please change these to boolean/empty properties and use
> of_property_read_bool.

Will do, thank you.

>
>> +
>> +       /* Max MTU is 1500, ETH_DATA_LEN */
>> +       priv->max_mtu = ETH_DATA_LEN;
>> +
>> +       /* Get the max mtu from the device tree. Note that the
>> +        * "max-frame-size" parameter is actually max mtu. Definition
>> +        * in the ePAPR v1.1 spec and usage differ, so go with usage.
>> +        */
>> +       of_property_read_u32(pdev->dev.of_node, "max-frame-size",
>> +                            &priv->max_mtu);
>> +
>> +       /* The DMA buffer size already accounts for an alignment bias
>> +        * to avoid unaligned access exceptions for the NIOS processor,
>> +        */
>> +       priv->rx_dma_buf_sz = ALTERA_RXDMABUFFER_SIZE;
>> +
>> +       /* get default MAC address from device tree */
>> +       macaddr = of_get_property(pdev->dev.of_node, "local-mac-address", &len);
>> +       if (macaddr && len == ETH_ALEN)
>> +               ether_addr_copy(ndev->dev_addr, macaddr);
>
> Any reason we couldn't use of_get_mac_address here? It also checks that
> the address is valid.

No reason, an oversight. I'll address.

>
> Cheers,
> Mark.

Thank you for taking the time to review and comment. I'll address the
comments and respin the patch.

All the best,

Vince
