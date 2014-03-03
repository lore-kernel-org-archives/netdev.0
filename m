From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 3/3] Altera TSE: Add Altera Triple Speed Ethernet
 (TSE) Driver
Date: Mon, 3 Mar 2014 10:38:31 -0800
Message-ID: <CAGVrzcb1qwAG8ByaRdvaExcHxe3WtxF_MHO0_s0b99CAAcoiGw@mail.gmail.com>
References: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com>
 <1393792922-2381-4-git-send-email-vbridgers2013@gmail.com>
 <5313D3DE.3030907@gmail.com> <CAOwfj2OjxyCNwgxWLjv5asDQYKD2Mcd3N_3Wn+jankK-pa35Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAOwfj2OjxyCNwgxWLjv5asDQYKD2Mcd3N_3Wn+jankK-pa35Fw@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-03-03 10:21 GMT-08:00 Vince Bridgers <vbridgers2013@gmail.com>:
> Hello Florian, thank you for taking the time to comments. My responses inline.
>
> On Sun, Mar 2, 2014 at 6:59 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
>> Hello Vince,
>>
>> It might help reviewing the patches by breaking the patches into:
>>
>> - the SGDMA bits
>> - the MSGDMA bits
>> - the Ethernet MAC driver per-se
>
> I'll break down the next submission.
>
>>
>> BTW, it does look like the SGDMA code could/should be a dmaengine driver?
>
> I did consider this, but after studying the dmaengine api I found the
> API definitions and semantics were not a match to the way the SGDMA
> and MSGDMA behave collectively. Moreover, I could not find an example
> of an Ethernet driver that made use of the dmaengine API - only the
> Micrel driver seems to use it. When studying what components actually
> used the dmaengine API I concluded the dmaengine API was defined for
> use cases different than Ethernet.

To tell you the truth, I have myself been toying with the idea of
using a dmaengine driver for some Ethernet drivers out there (mainly
bcm63xx_enet), but so far have not had any chance to take a stab at
doing a real implementation. My concern was more about the fact that
maybe the SGDMA/MSGDMA code could be reusable for other peripherals in
your system, such as USB device, PCM etc... This is fine anyway.

[snip]

>>
>> Is this the software number of descriptors or hardware number of
>> descriptors?
>
> This number applies to the number of descriptors as limited by the
> MSGDMA capabilities. The SGDMA has different limitations and issues,
> but the maximum number of descriptors for either DMA engine that can
> be used is represented as shown above. This is important since an
> unusual hardware configuration could support both SGDMA and MSGDMA
> simultaneously for more than one TSE instance. I used a design that
> supported a single SGDMA with TSE and a single MSGDMA with TSE for
> testing purposes (among other designs). So this a hardware defined
> number of descriptors and is fixed.

Ok, so this describes a hardware configuration, and as such should be
part of some Device Tree properties, something that could easily be
changed by someone wanting to slightly modify the RTL parameters.

>
>>
>> [snip]
>>
>>
>>> +
>>> +static int altera_tse_mdio_create(struct net_device *dev, unsigned int
>>> id)
>>> +{
>>> +       struct altera_tse_private *priv = netdev_priv(dev);
>>> +       int ret;
>>> +       int i;
>>> +       struct device_node *mdio_node;
>>> +       struct mii_bus *mdio;
>>> +
>>> +       mdio_node = of_find_compatible_node(priv->device->of_node, NULL,
>>> +               "altr,tse-mdio");
>>> +
>>> +       if (mdio_node) {
>>> +               dev_warn(priv->device, "FOUND MDIO subnode\n");
>>> +       } else {
>>> +               dev_warn(priv->device, "NO MDIO subnode\n");
>>> +               return 0;
>>> +       }
>>> +
>>> +       mdio = mdiobus_alloc();
>>> +       if (mdio == NULL) {
>>> +               dev_err(priv->device, "Error allocating MDIO bus\n");
>>> +               return -ENOMEM;
>>> +       }
>>> +
>>> +       mdio->name = ALTERA_TSE_RESOURCE_NAME;
>>> +       mdio->read = &altera_tse_mdio_read;
>>> +       mdio->write = &altera_tse_mdio_write;
>>> +       snprintf(mdio->id, MII_BUS_ID_SIZE, "%s-%u", mdio->name, id);
>>
>>
>> You could use something more user-friendly such as mdio_node->full_name.
>
> The full name will exceed the characters available in that particular
> structure data member. MII_BUS_ID_SIZE is defined as (20-3) in
> include/linux/phy.h. The full name would exceed the allocated space in
> that structure. That's why this method was chosen.

Ok, that works too.

>
>>
>>
>>> +
>>> +       mdio->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
>>> +       if (mdio->irq == NULL) {
>>> +               dev_err(priv->device, "%s: Cannot allocate memory\n",
>>> __func__);
>>> +               ret = -ENOMEM;
>>> +               goto out_free_mdio;
>>> +       }
>>> +       for (i = 0; i < PHY_MAX_ADDR; i++)
>>> +               mdio->irq[i] = PHY_POLL;
>>> +
>>> +       mdio->priv = (void *)priv->mac_dev;
>>
>>
>> No need for the cast here, this is already a void *.
>
> Noted.
>
>>
>>
>>> +       mdio->parent = priv->device;
>>
>>
>> [snip]
>>
>>
>>> +               /* make cache consistent with receive packet buffer */
>>> +               dma_sync_single_for_cpu(priv->device,
>>> +                                       priv->rx_ring[entry].dma_addr,
>>> +                                       priv->rx_ring[entry].len,
>>> +                                       DMA_FROM_DEVICE);
>>> +
>>> +               dma_unmap_single(priv->device,
>>> priv->rx_ring[entry].dma_addr,
>>> +                                priv->rx_ring[entry].len,
>>> DMA_FROM_DEVICE);
>>> +
>>> +               /* make sure all pending memory updates are complete */
>>> +               rmb();
>>
>>
>> Are you sure this does something in your case? I am fairly sure that the
>> dma_unmap_single() call would have done that implicitely for you here.
>
> I wrote the code this way intentionally to be explicit. I'll check the
> API for behavior as you describe for both ARM and NIOS and if not
> handled this barrier should probably remain.
>

[snip]

>>
>> I am not sure this will even be triggered if you want do not advertise
>> NETIF_F_SG, so you might want to drop that entirely.
>
> The intent was to add Scatter Gather capabilities at some point in the
> future, so this was a form of documenting. I'll just drop the code and
> add a comment instead if you agree.

Since you are not advertising the NETIF_F_SG capability bit, you
should probably just drop this code and add it back again under a
different form when SG support is added.

[snip]

>>
>> You might rather do this during your driver probe function rather than in
>> the ndo_open() callback.
>
> This seems to be the normal place to probe and initialize the phy from
> examination of existing code. Perhaps I missed something, could you
> provide an example of where this is done differently?

Most drivers I can think about: tg3, bcmgenet, bcm63xx_enet, r6040 do
probe for the PHY in their driver's probe routine.

>
>>
>> [snip]
>>
>>
>>> +       /* Stop and disconnect the PHY */
>>> +       if (priv->phydev) {
>>> +               phy_stop(priv->phydev);
>>> +               phy_disconnect(priv->phydev);
>>> +               priv->phydev = NULL;
>>> +       }
>>> +
>>> +       netif_stop_queue(dev);
>>> +       napi_disable(&priv->napi);
>>> +
>>> +       /* Disable DMA interrupts */
>>> +       spin_lock_irqsave(&priv->rxdma_irq_lock, flags);
>>> +       priv->disable_rxirq(priv);
>>> +       priv->disable_txirq(priv);
>>> +       spin_unlock_irqrestore(&priv->rxdma_irq_lock, flags);
>>> +
>>> +       /* Free the IRQ lines */
>>> +       free_irq(priv->rx_irq, dev);
>>> +       free_irq(priv->tx_irq, dev);
>>> +
>>> +       /* disable and reset the MAC, empties fifo */
>>> +       spin_lock(&priv->mac_cfg_lock);
>>> +       spin_lock(&priv->tx_lock);
>>> +
>>> +       ret = reset_mac(priv);
>>> +       if (ret)
>>> +               netdev_err(dev, "Cannot reset MAC core (error: %d)\n",
>>> ret);
>>> +       priv->reset_dma(priv);
>>> +       free_skbufs(dev);
>>> +
>>> +       spin_unlock(&priv->tx_lock);
>>> +       spin_unlock(&priv->mac_cfg_lock);
>>> +
>>> +       priv->uninit_dma(priv);
>>> +
>>> +       netif_carrier_off(dev);
>>
>>
>> phy_stop() does that already.
>
> If you mean phy_stop calls netif_carrier_off, I don't see it in that
> function (phy/phy.c). Common usage in the intree drivers seems to be
> calling netif_carrier_off in this context, but perhaps the drivers I
> examined have not been updated. Is there some more specific feedback
> or comments that you could provide here? Do you mean that
> netif_carrier_off is unnecessary here?

by calling phy_stop() the PHY state machine will move to the state
PHY_HALTED, if the link state was valid at this point, it will call
netif_carrier_off(). If the link was not valid before, the PHY state
machine would have already called netif_carrier_off().

>
>>
>>
>>> +
>>> +       return 0;
>>> +}
>>> +
>>> +static struct net_device_ops altera_tse_netdev_ops = {
>>> +       .ndo_open               = tse_open,
>>> +       .ndo_stop               = tse_shutdown,
>>> +       .ndo_start_xmit         = tse_start_xmit,
>>> +       .ndo_set_mac_address    = eth_mac_addr,
>>> +       .ndo_set_rx_mode        = tse_set_rx_mode,
>>> +       .ndo_change_mtu         = tse_change_mtu,
>>> +       .ndo_validate_addr      = eth_validate_addr,
>>> +};
>>> +
>>> +static int altera_tse_get_of_prop(struct platform_device *pdev,
>>> +                                 const char *name, unsigned int *val)
>>> +{
>>> +       const __be32 *tmp;
>>> +       int len;
>>> +       char buf[strlen(name)+1];
>>> +
>>> +       tmp = of_get_property(pdev->dev.of_node, name, &len);
>>> +       if (!tmp && !strncmp(name, "altr,", 5)) {
>>> +               strcpy(buf, name);
>>> +               strncpy(buf, "ALTR,", 5);
>>> +               tmp = of_get_property(pdev->dev.of_node, buf, &len);
>>> +       }
>>> +       if (!tmp || (len < sizeof(__be32)))
>>> +               return -ENODEV;
>>> +
>>> +       *val = be32_to_cpup(tmp);
>>> +       return 0;
>>> +}
>>
>>
>> Do we really need that abstration?
>
> The intent here is to support legacy device trees that were created
> with upper case "ALTR".

Oh Device Tree fun, welcome to the club.

>
>>
>>
>>> +
>>> +static int altera_tse_get_phy_iface_prop(struct platform_device *pdev,
>>> +                                        phy_interface_t *iface)
>>> +{
>>> +       const void *prop;
>>> +       int len;
>>> +
>>> +       prop = of_get_property(pdev->dev.of_node, "phy-mode", &len);
>>> +       if (!prop)
>>> +               return -ENOENT;
>>> +       if (len < 4)
>>> +               return -EINVAL;
>>> +
>>> +       if (!strncmp((char *)prop, "mii", 3)) {
>>> +               *iface = PHY_INTERFACE_MODE_MII;
>>> +               return 0;
>>> +       } else if (!strncmp((char *)prop, "gmii", 4)) {
>>> +               *iface = PHY_INTERFACE_MODE_GMII;
>>> +               return 0;
>>> +       } else if (!strncmp((char *)prop, "rgmii-id", 8)) {
>>> +               *iface = PHY_INTERFACE_MODE_RGMII_ID;
>>> +               return 0;
>>> +       } else if (!strncmp((char *)prop, "rgmii", 5)) {
>>> +               *iface = PHY_INTERFACE_MODE_RGMII;
>>> +               return 0;
>>> +       } else if (!strncmp((char *)prop, "sgmii", 5)) {
>>> +               *iface = PHY_INTERFACE_MODE_SGMII;
>>> +               return 0;
>>> +       }
>>
>>
>> of_get_phy_mode() does that for you.
>
> Will address this. Thank you.
>
>>
>>
>>> +
>>> +       return -EINVAL;
>>> +}
>>> +
>>> +static int request_and_map(struct platform_device *pdev, const char
>>> *name,
>>> +                          struct resource **res, void __iomem **ptr)
>>> +{
>>> +       struct resource *region;
>>> +       struct device *device = &pdev->dev;
>>> +
>>> +       *res = platform_get_resource_byname(pdev, IORESOURCE_MEM, name);
>>> +       if (*res == NULL) {
>>> +               dev_err(device, "resource %s not defined\n", name);
>>> +               return -ENODEV;
>>> +       }
>>> +
>>> +       region = devm_request_mem_region(device, (*res)->start,
>>> +                                        resource_size(*res),
>>> dev_name(device));
>>> +       if (region == NULL) {
>>> +               dev_err(device, "unable to request %s\n", name);
>>> +               return -EBUSY;
>>> +       }
>>> +
>>> +       *ptr = devm_ioremap_nocache(device, region->start,
>>> +                                   resource_size(region));
>>> +       if (*ptr == NULL) {
>>> +               dev_err(device, "ioremap_nocache of %s failed!", name);
>>> +               return -ENOMEM;
>>> +       }
>>> +
>>> +       return 0;
>>> +}
>>> +
>>> +/* Probe Altera TSE MAC device
>>> + */
>>> +static int altera_tse_probe(struct platform_device *pdev)
>>> +{
>>> +       struct net_device *ndev;
>>> +       int ret = -ENODEV;
>>> +       struct resource *control_port;
>>> +       struct resource *dma_res;
>>> +       struct altera_tse_private *priv;
>>> +       int len;
>>> +       const unsigned char *macaddr;
>>> +       struct device_node *np = pdev->dev.of_node;
>>> +       unsigned int descmap;
>>> +
>>> +       ndev = alloc_etherdev(sizeof(struct altera_tse_private));
>>> +       if (!ndev) {
>>> +               dev_err(&pdev->dev, "Could not allocate network
>>> device\n");
>>> +               return -ENODEV;
>>> +       }
>>> +
>>> +       SET_NETDEV_DEV(ndev, &pdev->dev);
>>> +
>>> +       priv = netdev_priv(ndev);
>>> +       priv->device = &pdev->dev;
>>> +       priv->dev = ndev;
>>> +       priv->msg_enable = netif_msg_init(debug, default_msg_level);
>>> +
>>> +       if (of_device_is_compatible(np, "altr,tse-1.0") ||
>>> +           of_device_is_compatible(np, "ALTR,tse-1.0")) {
>>
>>
>> Use the .data pointer associated with the compatible string to help you do
>> that, see below.
>
> Noted. If we can agree that use of the dmaengine api is inappropriate
> in this case, I'll update the code to use a .data pointer as
> suggested. Thank you for the comment.

I think not using the dmaengine API is fine.

>
>>
>> [snip]
>>
>>
>>> +       /* get supplemental address settings for this instance */
>>> +       ret = altera_tse_get_of_prop(pdev, "altr,enable-sup-addr",
>>> +                                    &priv->added_unicast);
>>> +       if (ret)
>>> +               priv->added_unicast = 0;
>>> +
>>> +       /* Max MTU is 1500, ETH_DATA_LEN */
>>> +       priv->max_mtu = ETH_DATA_LEN;
>>
>>
>> How about VLANs? If this is always 1500, just let the core ethernet
>> functions configure the MTU for your interface.
>
> The TSE core handles frame size expansion for VLAN tagged frames, so
> it's ok (tested). At some point, frame sizes > 1518 may be supported
> (the core supports Jumbo frames, the driver is intentionally simple
> for initial submission). Your comment is noted, I accept the
> suggestion.

In case this needs to be matched against a newer version of the RTL,
or whatever HW configuration some RTL user is allowed to make, you
could probaly use the 'max-frame-size' ePAPR-defined property for
this?

>
>>
>>
>>> +
>>> +       /* The DMA buffer size already accounts for an alignment bias
>>> +        * to avoid unaligned access exceptions for the NIOS processor,
>>> +        */
>>> +       priv->rx_dma_buf_sz = ALTERA_RXDMABUFFER_SIZE;
>>> +
>>> +       /* get default MAC address from device tree */
>>> +       macaddr = of_get_property(pdev->dev.of_node, "local-mac-address",
>>> &len);
>>> +       if (macaddr && len == ETH_ALEN)
>>> +               memcpy(ndev->dev_addr, macaddr, ETH_ALEN);
>>> +
>>> +       /* If we didn't get a valid address, generate a random one */
>>> +       if (!is_valid_ether_addr(ndev->dev_addr))
>>> +               eth_hw_addr_random(ndev);
>>> +
>>> +       ret = altera_tse_get_phy_iface_prop(pdev, &priv->phy_iface);
>>> +       if (ret == -ENOENT) {
>>> +               /* backward compatability, assume RGMII */
>>> +               dev_warn(&pdev->dev,
>>> +                        "cannot obtain PHY interface mode, assuming
>>> RGMII\n");
>>> +               priv->phy_iface = PHY_INTERFACE_MODE_RGMII;
>>> +       } else if (ret) {
>>> +               dev_err(&pdev->dev, "unknown PHY interface mode\n");
>>> +               goto out_free;
>>> +       }
>>> +
>>> +       /* try to get PHY address from device tree, use PHY autodetection
>>> if
>>> +        * no valid address is given
>>> +        */
>>> +       ret = altera_tse_get_of_prop(pdev, "altr,phy-addr",
>>> &priv->phy_addr);
>>> +       if (ret)
>>> +               priv->phy_addr = POLL_PHY;
>>
>>
>> Please do not use such as custom property, either you use an Ethernet PHY
>> device tree node as described in ePAPR; or you do not and use a fixed-link
>> property instead.
>
> Agreed, the code tries phy handles as described in the ePAPR v1.1
> specification, then falls back to the method in question. The intent
> is to support legacy device trees as well. Is there a preferred way to
> handle legacy configurations that we may encounter in the wild?

Well, ideally a new driver should have no legacy at all, but I
understand that situation might not be the case, I believe it should
be duly noted in the Device Tree binding documentation (have not
reviewed that patch yet). Issuing a warning might be beneficial as
well to spot "old" DT bindings and help troubleshooting setups?
-- 
Florian
