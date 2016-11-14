From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac: GMAC_RGSMIIIS reports bogus values
Date: Mon, 14 Nov 2016 09:14:46 +0100
Message-ID: <a1f114cc-6120-154c-a3f7-3e0389d38e36@st.com>
References: <1478189833.4072.65.camel@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "fabrice.gasnier@st.com" <fabrice.gasnier@st.com>,
 "manabian@gmail.com" <manabian@gmail.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "preid@electromag.com.au" <preid@electromag.com.au>,
 "alexandre.torgue@gmail.com" <alexandre.torgue@gmail.com>,
 "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Alexey Brodkin <Alexey.Brodkin@synopsys.com>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
In-Reply-To: <1478189833.4072.65.camel@synopsys.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello Alexey

Sorry for my late reply. In that case, I think that the stmmac
is using own RGMII/SGMII support (PCS) to dialog with the
transceiver. I think, from the HW capability register
this feature is present and the driver is using it as default.

I kindly ask you to verify if this is your setup or if you
do not want to use it. In that case, it is likely we need to
add some code in the driver.

Also I wonder if, other version of the stmmac worked on this platform
before.

Regards
Peppe

On 11/3/2016 5:17 PM, Alexey Brodkin wrote:
> Hello,
>
> I'm seeing pretty strange issue with GMAC reporting a lot of link state changes
> based on bits in GMAC_RGSMIIIS. It looks like that:
> -------------------------->8-----------------------
> Link is Down
> Link is Up - 10/Full
> Link is Down
> Link is Up - 10/Half
> Link is Down
> Link is Down
> Link is Up - 10/Half
> Link is Up -
> 1000/Half
> Link is Down
> Link is Down
> Link is Down
> Link is Down
> Link is Up - 10/Half
> Link is Down
> Link is Down
> Link is Up -
> 1000/Half
> Link is Up - 1000/Full
> -------------------------->8-----------------------
>
> What's especially interesting my board with GMAC is connected to 100Mbit device
> which means there's no chance for 1Gb mode to be set.
>
> Also this has nothing to do with link state detected and reported by PHY via MDIO.
> So obviously GMAC_RGSMIIIS bits are wrong. But given the fact that GMAC_RGSMIIIS bits
> are set based on state of RXD[3:0] lines of RGMII I may only thing that it's
> PHY (in my case DP83865) who's sending random data on the RXD during inter-frame gap.
>
> Note data transferred through that networking connection is perfectly correct and
> actually I haven't see those link state prints before kernel v4.8 basically
> because the prints in question were implemented with pr_debug() and then with [1]
> we got pr_info() that made prints visible by default.
>
> Since I don't have any means to capture all required GMII signals to do better
> analysis and my data is not corrupted in the end I'm thinking about way how to
> mute these pretty senseless messages.
>
> One thing I may think of we may disable checking of GMAC_RGSMIIIS if a particular
> board uses MDIO for PHY setup. Something like that:
> -------------------------->8-----------------------
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> @@ -337,7 +337,7 @@ static int dwmac1000_irq_status(struct mac_device_info *hw,
>
>         dwmac_pcs_isr(ioaddr, GMAC_PCS_BASE, intr_status, x);
>
> -       if (intr_status & PCS_RGSMIIIS_IRQ)
> +       if (!priv->use_mdio && (intr_status & PCS_RGSMIIIS_IRQ))
>                 dwmac1000_rgsmii(ioaddr, x);
>
>         return ret;
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 6c85b61aaa0b..34e9de0450ba 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3356,11 +3356,13 @@ int stmmac_dvr_probe(struct device *device,
>
>         stmmac_check_pcs_mode(priv);
>
> +       priv->use_mdio = 0;
>         if (priv->hw->pcs != STMMAC_PCS_RGMII  &&
>             priv->hw->pcs != STMMAC_PCS_TBI &&
>             priv->hw->pcs != STMMAC_PCS_RTBI) {
>                 /* MDIO bus Registration */
>                 ret = stmmac_mdio_register(ndev);
> +               priv->use_mdio = 1;
>                 if (ret < 0) {
>                         pr_debug("%s: MDIO bus (id: %d) registration failed",
>                                  __func__, priv->plat->bus_id);
> -------------------------->8-----------------------
>
> Any thoughts on that are much appreciated!
>
> Regards,
> Alexey
>
> [1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=70523e639bf8ca09b3357371c3546cee55c06351
>
