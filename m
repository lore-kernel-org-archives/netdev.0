From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v5 10/10] net: stmmac: dwmac-sun8i: Handle
 integrated/external MDIOs
Date: Mon, 11 Sep 2017 21:08:50 +0200
Message-ID: <20170911190850.GA2291@Red>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-11-clabbe.montjoie@gmail.com>
 <20170908130520.GA11248@lunn.ch>
 <20170908132632.GA3037@Red>
 <20170908140020.GC25219@lunn.ch>
 <20170908140832.GB3037@Red>
 <20170908141736.GF25219@lunn.ch>
 <20170908142825.GC3037@Red>
 <20170911161124.GD27599@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170911161124.GD27599@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 11, 2017 at 06:11:24PM +0200, Andrew Lunn wrote:
> On Fri, Sep 08, 2017 at 04:28:25PM +0200, Corentin Labbe wrote:
> > On Fri, Sep 08, 2017 at 04:17:36PM +0200, Andrew Lunn wrote:
> > > > > Do you know why the reset times out/fails?
> > > > > 
> > > > 
> > > > Because there are nothing connected to it.
> > > 
> > > That should not be an issue. A read should just return 0xffff.  And it
> > > should return 0xffff fast. The timing of the MDIO protocol is fixed. A
> > > read or a write takes a fixed number of cycles, independent of if
> > > there is a device there or not. The bus data line has a pullup, so if
> > > you try to access a missing device, you automatically read 0xffff.
> > > 
> > 
> > Perhaps, but the reality is that with nothing connected to it, the reset of the MAC timeout.
> > Certainly, the MAC does not support finding no PHY.
> 
> Are you sure this is not because of the clock and reset?
> 
> +                               #address-cells = <1>;
> +                               #size-cells = <0>;
> +                               int_mii_phy: ethernet-phy@1 {
> +                                       compatible = "ethernet-phy-ieee802.3-c22";
> +                                       reg = <1>;
> +                                       clocks = <&ccu CLK_BUS_EPHY>;
> +                                       resets = <&ccu RST_BUS_EPHY>;
> 
> The way you describe it here, the clock and reset are for the PHY. But
> maybe it is actually for the bus? I can understand a bus timing out if
> it has no clock, or it is held in reset. Try enabling the clock and
> reset when the internal bus is selected, not when the PHY on the bus
> is selected.
> 

Even with CLK_BUS_EPHY/RST_BUS_EPHY enabled, the MAC reset timeout.
So no the CLK/RST are really for the PHY.

Regards

PS: patch and result with "integrated CLK/RST always on"
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c
@@ -659,7 +659,7 @@ static int mdio_mux_syscon_switch_fn(int current_child, int desired_child,
        struct sunxi_priv_data *gmac = priv->plat->bsp_priv;
        u32 reg, val;
        int ret = 0;
-       bool need_reset = false;
+       bool need_reset = true;
 
        if (current_child ^ desired_child) {
                regmap_read(gmac->regmap, SYSCON_EMAC_REG, &reg);
@@ -824,7 +824,7 @@ static int sun8i_dwmac_power_internal_phy(struct stmmac_priv *priv)
        int ret;
 
        if (!gmac->use_internal_phy)
-               return 0;
+               dev_info(priv->device, "IPHY BYPASS\n");
 
        ret = clk_prepare_enable(gmac->ephy_clk);
        if (ret) {

[   18.057162] dwmac-sun8i 1c30000.ethernet: Will use external PHY
[   18.183789] dwmac-sun8i 1c30000.ethernet: IPHY BYPASS
[   18.184136] dwmac-sun8i 1c30000.ethernet: Chain mode enabled
[   18.184158] dwmac-sun8i 1c30000.ethernet: No HW DMA feature register supported
[   18.184175] dwmac-sun8i 1c30000.ethernet: Normal descriptors
[   18.184192] dwmac-sun8i 1c30000.ethernet: RX Checksum Offload Engine supported
[   18.184214] dwmac-sun8i 1c30000.ethernet: COE Type 2
[   18.184231] dwmac-sun8i 1c30000.ethernet: TX Checksum insertion supported
[   18.185491] libphy: stmmac: probed
[   18.188481] libphy: mdio_mux: probed
[   18.188831] dwmac-sun8i 1c30000.ethernet: Switch mux to internal PHY
[   18.288981] dwmac-sun8i 1c30000.ethernet: EMAC reset timeout
[   18.289559] libphy: mdio_mux: probed
[   18.289629] dwmac-sun8i 1c30000.ethernet: Switch mux to external PHY
[   20.578316] EXT4-fs (mmcblk0p1): re-mounted. Opts: (null)
[   31.240650] RTL8211E Gigabit Ethernet 0.1:00: attached PHY driver [RTL8211E Gigabit Ethernet] (mii_bus:phy_addr=0.1:00, irq=POLL)
