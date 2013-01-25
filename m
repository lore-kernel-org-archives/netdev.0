From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH net-next 1/3] net: stmmac: add gmac autoneg set for SGMII,
 TBI, and RTBI
Date: Fri, 25 Jan 2013 14:01:40 -0800
Message-ID: <013e01cdfb47$8f5d2b30$ae178190$@samsung.com>
References: <00c001cdf369$9b25bdf0$d17139d0$@samsung.com>
 <50F6568D.3060703@st.com> <01e201cdf5a3$1f3e1890$5dba49b0$@samsung.com>
 <50FFB094.5000100@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	kgene.kim@samsung.com, cpgs@samsung.com
To: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:48474 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753108Ab3AYWBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 17:01:46 -0500
In-reply-to: <50FFB094.5000100@st.com>
Content-language: en-zw
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 1/23/2013 1:43 PM, Giuseppe CAVALLARO write:
> On 1/18/2013 6:41 PM, Byungho An wrote:
> > On 1/15/2013 11:28 PM, Giuseppe CAVALLARO write:
> >> On 1/15/2013 10:45 PM, Byungho An wrote:
> >>>
> >>> This patch adds gmac autoneg set function for SGMII, TBI, or RTBI
> >>> interface. In case of PHY's autoneg is set, gmac's autoneg enable
> >>> bit should set. After checking phy's autoneg if phydev's autoneg is
'1'
> >>> gmac's ANE bit set for those interface.
> >>
> >> Sorry I've some doubts about these patches.
> >>
> >> Firstly if the MAC is able to manage RGMII/SGMII etc this should be
> > verified
> >> by looking at the HW cap register: i.e. PCS bit.
> >>
> >>     (I have no HW that support this so I cannot do any tests).
> >>
> > I agree with you and actually I tried to use a PCS bit previously.
> > (PCS bit indicates TBI, SGMII, or RTBI PHY interface) But I was
> > confused which one I should use among PSC, ACTPHYIF or phydev to
> > recognize the interface.
> > At this time, I want to add auto-negotiation enable because sgmii
> > interface is not working without ANE using PCS bit(in H/W feature
register).
> >
> 
> really strange, from the synopsys databook we should only look at the RO
bit
> in the HW cap reg just to understand if the feature is supported.
> 
I modified this part like below

@@ -1044,12 +1046,8 @@ static int stmmac_open(struct net_device *dev)
        priv->hw->mac->core_init(priv->ioaddr);

        /* Enable auto-negotiation for SGMII, TBI or RTBI */
-       if (interface == PHY_INTERFACE_MODE_SGMII ||
-           interface == PHY_INTERFACE_MODE_TBI ||
-           interface == PHY_INTERFACE_MODE_RTBI) {
-               if (priv->phydev->autoneg)
-                       priv->hw->mac->set_autoneg(priv->ioaddr);
-       }
+       if (priv->dma_cap.pcs)
+               priv->hw->mac->ctrl_ane(priv->ioaddr, 0);

        /* Request the IRQ lines */
        ret = request_irq(dev->irq, stmmac_interrupt,

As you may know, auto-negotiation is essential for SGMII, TBI, or RTBI
interface.

And ctrl_ane funciont is like that

@@ -311,6 +317,18 @@ static void dwmac1000_set_autoneg(void __iomem *ioaddr)
        writel(value, ioaddr + GMAC_AN_CTRL);
 }

+static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool restart)
+{
+       u32 value;
+
+       value = readl(ioaddr + GMAC_AN_CTRL);
+     /* auto negotiation enable and External Loopback enable */
+       value = GMAC_AN_CTRL__ANE | GMAC_AN_CTRL__ELE; 
+
+       if (restart)
+               value |= GMAC_AN_CTRL_RAN; 
+
+       writel(value, ioaddr + GMAC_AN_CTRL);
+}

 static const struct stmmac_ops dwmac1000_ops = {
        .core_init = dwmac1000_core_init,

> >> In case of this feature is actually supported then the driver could
> >> manage everything bypassing the MDIO.
> >> IMO, we could not need to call the stmmac_phy_init and we should not
> >> use the PHYLIB.
> >> I mean if we have the PCS module we could have a minimal support to
> >> get link status, restart ANE etc w/o using at all the PHYLIB (so w/o
> >> touching
> > the
> >> PHY regs via the MDIO/MDC).
> >>
> > Yes. For example SGMII/RGMII/SMII Status Register is useful to know
> > status so we can use this register to manage status of
> > SGMII/RGMII/SMII
> >
> >
> >>     It could also be useful to complete the support with the RGMII...
no
> >>     extra effort should be needed while adding SGMII if you look at the
> >>     core registers.
> >>     If you add the RGMII on some platforms we could guarantee to manage
> >>     the fix_mac_speed (see stmmac doc).
> >>
> > Unfortunately I have only the SGMII.
> 
> no problem, I'll complete it by my hand later.
> 
> >
> >> Looking at the other your patches, the ethtool support is not
> >> completed. I expected to restart ANE, get/set link property etc.
> >>
> > What is link property? It means link up, speed and duplex mode.
> > Are there anything else?
> > I think get link property is already working using ethtool.
> > In case of SGMII/RGMII/SMII, I think we can use SGMII/RGMII/SMII
> > Status Register for link status.
> >
> > I have a question regarding it.
> > In the mainline code, there is hardcode interrupt mask in
> > dwmac1000_core_init function.
> > When I try to get interrupt for link change, interrupt is not occurred
> > because of this mask.
> > Can we modify that?
> 
> yes you can. I had wrote an initial patch that started doing something.
> I have tested it on my boards and I can send it to the mailing list to be
> reviewed. Maybe you can build your patch on top of it.
> 
I've  changed restart AN like below.

@@ -610,6 +607,27 @@ static int stmmac_set_coalesce(struct net_device *dev,
        return 0;
 }

+static int
+stmmac_nway_reset(struct net_device *netdev)
+{
+       struct stmmac_priv *priv = netdev_priv(netdev);
+       struct phy_device *phy = priv->phydev;
+       int ret = 0;
+
+       spin_lock(&priv->lock);
+
+       if (netif_running(netdev)) {
+               phy_stop(phy);
+               phy_start(phy);
+               ret = phy_start_aneg(phy);
+               if (priv->dma_cap.pcs)
+                       priv->hw->mac->ctrl_ane(priv->ioaddr, true);
+       }
+
+       spin_unlock(&priv->lock);
+       return ret;
+}
+
 static const struct ethtool_ops stmmac_ethtool_ops = {
        .begin = stmmac_check_if_running,
        .get_drvinfo = stmmac_ethtool_getdrvinfo,



> >> Also pay attention to properly treat EEE. Maybe, as first stage we
> >> should disable the feature in this case. We will see it later.
> >> The question is that we could not be able to use some extra features
> >> that currently need to dialog more with the PHY device. I mean what
> >> we actually do by using PHYLIB.
> > OK. As I understood, using gmac register instead of phydev or phylib...
> > I agree. In my opinion gmac and phy communicate using mdio each other,
> > after that gmac can get updated status.
> 
> yep, this is the point :-)
> 
> >>
> >>>
> >>> Signed-off-by: Byungho An <bh74.an@samsung.com>
> >>> ---
> >>>    drivers/net/ethernet/stmicro/stmmac/common.h         |    1 +
> >>>    drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c |   11
> >> +++++++++++
> >>>    drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |    9
> +++++++++
> >>>    3 files changed, 21 insertions(+)
> >>>
> >>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h
> >>> b/drivers/net/ethernet/stmicro/stmmac/common.h
> >>> index 186d148..72ba769 100644
> >>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
> >>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
> >>> @@ -344,6 +344,7 @@ struct stmmac_ops {
> >>>    	void (*reset_eee_mode) (void __iomem *ioaddr);
> >>>    	void (*set_eee_timer) (void __iomem *ioaddr, int ls, int
tw);
> >>>    	void (*set_eee_pls) (void __iomem *ioaddr, int link);
> >>> +	void (*set_autoneg) (void __iomem *ioaddr);
> >>>    };
> >>>
> >>>    struct mac_link {
> >>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> >>> b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> >>> index bfe0226..a0737b39 100644
> >>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> >>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> >>> @@ -297,6 +297,16 @@ static void  dwmac1000_set_eee_timer(void
> >> __iomem
> >>> *ioaddr, int ls, int tw)
> >>>    	writel(value, ioaddr + LPI_TIMER_CTRL);
> >>>    }
> >>>
> >>> +static void dwmac1000_set_autoneg(void __iomem *ioaddr) {
> >>> +	u32 value;
> >>> +
> >>> +	value = readl(ioaddr + GMAC_AN_CTRL);
> >>> +	value |= 0x1000;
> >>
> >> pls use define instead of raw values ... see below.
> >>
> >>> +	writel(value, ioaddr + GMAC_AN_CTRL); }
> >>> +
> >>> +
> >>>    static const struct stmmac_ops dwmac1000_ops = {
> >>>    	.core_init = dwmac1000_core_init,
> >>>    	.rx_ipc = dwmac1000_rx_ipc_enable, @@ -311,6 +321,7 @@
static
> >>> const struct stmmac_ops dwmac1000_ops = {
> >>>    	.reset_eee_mode =  dwmac1000_reset_eee_mode,
> >>>    	.set_eee_timer =  dwmac1000_set_eee_timer,
> >>>    	.set_eee_pls =  dwmac1000_set_eee_pls,
> >>> +	.set_autoneg =  dwmac1000_set_autoneg,
> >>>    };
> >>>
> >>>    struct mac_device_info *dwmac1000_setup(void __iomem *ioaddr)
> >>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>> index f07c061..3e28934 100644
> >>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> >>> @@ -1007,6 +1007,7 @@ static int stmmac_open(struct net_device *dev)
> >>>    {
> >>>    	struct stmmac_priv *priv = netdev_priv(dev);
> >>>    	int ret;
> >>> +	int interface = priv->plat->interface;
> >>>
> >>>    	clk_prepare_enable(priv->stmmac_clk);
> >>>
> >>> @@ -1041,6 +1042,14 @@ static int stmmac_open(struct net_device
> *dev)
> >>>    	/* Initialize the MAC Core */
> >>>    	priv->hw->mac->core_init(priv->ioaddr);
> >>>
> >>> +	/* If phy autoneg is on, set gmac autoneg for SGMII, TBI and RTBI*/
> >>> +	if (interface == PHY_INTERFACE_MODE_SGMII ||
> >>> +	    interface == PHY_INTERFACE_MODE_TBI ||
> >>> +	    interface == PHY_INTERFACE_MODE_RTBI) {
> >>> +		if (priv->phydev->autoneg)
> >>> +			priv->hw->mac->set_autoneg(priv->ioaddr);
> >>> +	}
> >>
> >> we could use the following instead of priv->hw->mac->set_autoneg:
> >>
> >> static void dwmac1000_ctrl_ane(void __iomem *ioaddr, bool restart) {
> >>       int value = GMAC_CTRL_ANE_EN;
> >>
> >>       if (restart)
> >>           value |= GMAC_CTRL_ANE_RESTART;
> >>
> >>       writel(value, ioaddr +GMAC_AN_CTRL); }
> >>
> >> where we should defines all the missing macros for the registers 48,
> >> 49
> > ...
> > Actually I tested this code for restart autonegotiation, but even
> > though I changed link (1Gb -> 100Mb) phy's link is not changed.
> > For more detail, first time 1Gb I changed the link during system
> > working and then check speed using ethtool/mii-tool.
> > I think phy also should do autonegotiation (I'm not sure this is just
> > for the SGMII). Without phy auto negotiation  gmac is not working.
> >
> > OK, I'll try to check functionality and make macros.
> > Anyway as a first step, I want to complete to the code regarding ANE
> > (ctrl function, macros, ethtool support for link status etc..) I'll
> > send new code before making patch soon.
> 
> thanks you
> 
I think whenever link is changed, phy->state is changed and call
stmmac_adjust_link. It would update gmac's link.
I can get autonegotiation complete and link change irqs if we need something
we can add code in the handler but I'm not sure which one is need yet.
As of now I just added phy_state = PHY_CHANGELINK as a test code in the link
change irq handler.

@@ -1624,8 +1629,43 @@ static irqreturn_t stmmac_interrupt(int irq, void
*dev_id)
                                priv->xstats.mmc_rx_csum_offload_irq_n++;
                        if (status & core_irq_receive_pmt_irq)
                                priv->xstats.irq_receive_pmt_irq_n++;
+                       if (status & core_irq_pcs_autoneg_complete)
+                                priv->core_pcs_an = true;
+                       if (status & core_irq_pcs_link_status_change) {
+                               priv->core_pcs_link_change = true;
+                               status = readl(priv->ioaddr +
GMAC_AN_STATUS);
+                               if (status & GMAC_AN_STATUS_LS)
+                                       if ((priv->speed != phy->speed) ||
(priv->oldduplex != phy->duplex)) 
+                                       phy->state = PHY_CHANGELINK;  /* for
test */
+                       }

                        /* For LPI we need to save the tx status */
                        if (status & core_irq_tx_path_in_lpi_mode) {

I have a question, how to hand over phy's irq number, as I analyzed
phydev->irq is irqlist and irqlist is like below but I can not find a way to
set phy's irq number.
How to register or set priv->mii_irq or mdio_bus_data->irqs.

        if (mdio_bus_data->irqs)
                irqlist = mdio_bus_data->irqs;
        else
                irqlist = priv->mii_irq; 

I added some defines for AN like below
@@ -97,6 +97,20 @@ enum power_event {
 #define GMAC_TBI       0x000000d4      /* TBI extend status */
 #define GMAC_GMII_STATUS 0x000000d8    /* S/R-GMII status */

+/* AN Configuration defines */
+#define GMAC_AN_CTRL_RAN       0x00000200      /* Restart Auto-Negotiation
*/
+#define GMAC_AN_CTRL_ANE       0x00001000      /* Auto-Negotiation Enable
*/
+#define GMAC_AN_CTRL_ELE       0x00004000      /* External Loopback Enable
*/
+#define GMAC_AN_CTRL_ECD       0x00010000      /* Enable Comma Detect */
+#define GMAC_AN_CTRL_LR        0x00020000      /* Lock to Reference */
+#define GMAC_AN_CTRL_SGMRAL    0x00040000      /* SGMII RAL Control */
+
+/* AN Status defines */
+#define GMAC_AN_STATUS_LS      0x00000004      /* Link Status 0:down 1:up
*/
+#define GMAC_AN_STATUS_ANA     0x00000008      /* Auto-Negotiation Ability
*/
+#define GMAC_AN_STATUS_ANC     0x00000020      /* Auto-Negotiation Complete
*/
+#define GMAC_AN_STATUS_ES      0x00000100      /* Extended Status */
+
 /* GMAC Configuration defines */
 #define GMAC_CONTROL_TC        0x01000000      /* Transmit Conf. in
RGMII/SGMII */
 #define GMAC_CONTROL_WD        0x00800000      /* Disable Watchdog on
receive */


> >>
> >> /* RGMI/SGMII defines */
> >> #define GMAC_CTRL_ANE_SGMII_RAL (1 << 18)
> >> #define GMAC_CTRL_ANE_EN       (1 << 12)
> >> #define GMAC_CTRL_ANE_RESTART  (1 << 9)
> >>
> >> The handler should store the link status that will be used to pass
> >> the
> > info to
> >> the ethtool for example. We need to manage speed and duplex etc.
> >>
> >> What happens if you run "ethtool eth0" command?
> >> Or if you run mii-tool?
> >> I expect to get the right speed and duplex at least.
> > So far, I can get right data speed and duplex and autoneg.
> >
> >>
> >> Concerning the stmmac_set_pauseparam I'm also not sure you are doing
> >> the right thing. Note that you are not restarting the ANE at all ...
> >> (this is
> > what the
> >> phy_start_aneg does). If set the bit 12 then you are enabling the
> >> ane. To restart it, you need to set the bit 9 in the reg 48.
> >>
> >> I can support you on all the points above. Let me know.
> >>
> >> BR,
> >> peppe
> >>
> > OK, thank you and happy new year.
> 
> Also to you :-)
> 
> let me know for any progresses etc.
> 
> Peppe

BR, 
Byungho An

> 
> > Byungho An
> >
> >>> +
> >>>    	/* Request the IRQ lines */
> >>>    	ret = request_irq(dev->irq, stmmac_interrupt,
> >>>    			 IRQF_SHARED, dev->name, dev);
> >>>
> >
> >
> >
