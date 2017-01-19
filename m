From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: Re: [PATCH] stmmac: adding EEE to GMAC4
Date: Thu, 19 Jan 2017 11:31:52 +0530
Message-ID: <CAJ3bTp7XHNd+oc9QsX25iX_umARFjSveehPY_a+quJBnj-okkA@mail.gmail.com>
References: <f89aaac8024e2a92834088545ad72fbe682b32ed.1483030665.git.jpinto@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f89aaac8024e2a92834088545ad72fbe682b32ed.1483030665.git.jpinto@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 29, 2016 at 10:40 PM, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
> This patch adds Energy Efficiency Ethernet to GMAC4.
>
> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
> ---
>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      | 12 +++++
>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 59 +++++++++++++++++++++++
>  2 files changed, 71 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> index b524598..73d1dab 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
> @@ -90,6 +90,18 @@ enum power_event {
>         power_down = 0x00000001,
>  };
>
> +/* Energy Efficient Ethernet (EEE) for GMAC4
> + *
> + * LPI status, timer and control register offset
> + */
> +#define GMAC4_LPI_CTRL_STATUS  0xd0
> +#define GMAC4_LPI_TIMER_CTRL   0xd4
> +
> +/* LPI control and status defines */
> +#define GMAC4_LPI_CTRL_STATUS_LPITXA   BIT(19) /* Enable LPI TX Automate */
> +#define GMAC4_LPI_CTRL_STATUS_PLS      BIT(17) /* PHY Link Status */
> +#define GMAC4_LPI_CTRL_STATUS_LPIEN    BIT(16) /* LPI Enable */
> +
>  /* MAC Debug bitmap */
>  #define GMAC_DEBUG_TFCSTS_MASK         GENMASK(18, 17)
>  #define GMAC_DEBUG_TFCSTS_SHIFT                17
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> index ecfbf57..02eab79 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
> @@ -137,6 +137,61 @@ static void dwmac4_get_umac_addr(struct mac_device_info *hw,
>                                    GMAC_ADDR_LOW(reg_n));
>  }
>
> +static void dwmac4_set_eee_mode(struct mac_device_info *hw)
> +{
> +       void __iomem *ioaddr = hw->pcsr;
> +       u32 value;
> +
> +       /* Enable the link status receive on RGMII, SGMII ore SMII
> +        * receive path and instruct the transmit to enter in LPI
> +        * state.
> +        */
> +       value = readl(ioaddr + GMAC4_LPI_CTRL_STATUS);
> +       value |= GMAC4_LPI_CTRL_STATUS_LPIEN | GMAC4_LPI_CTRL_STATUS_LPITXA;
> +
> +       writel(value, ioaddr + GMAC4_LPI_CTRL_STATUS);
> +}
> +
> +static void dwmac4_reset_eee_mode(struct mac_device_info *hw)
> +{
> +       void __iomem *ioaddr = hw->pcsr;
> +       u32 value;
> +
> +       value = readl(ioaddr + GMAC4_LPI_CTRL_STATUS);
> +       value &= ~(GMAC4_LPI_CTRL_STATUS_LPIEN | GMAC4_LPI_CTRL_STATUS_LPITXA);
> +       writel(value, ioaddr + GMAC4_LPI_CTRL_STATUS);
> +}
> +
> +static void dwmac4_set_eee_pls(struct mac_device_info *hw, int link)
> +{
> +       void __iomem *ioaddr = hw->pcsr;
> +       u32 value;
> +
> +       value = readl(ioaddr + GMAC4_LPI_CTRL_STATUS);
> +
> +       if (link)
> +               value |= GMAC4_LPI_CTRL_STATUS_PLS;
> +       else
> +               value &= ~GMAC4_LPI_CTRL_STATUS_PLS;
> +
> +       writel(value, ioaddr + GMAC4_LPI_CTRL_STATUS);
> +}
> +
> +static void dwmac4_set_eee_timer(struct mac_device_info *hw, int ls, int tw)
> +{
> +       void __iomem *ioaddr = hw->pcsr;
> +       int value = ((tw & 0xffff)) | ((ls & 0x7ff) << 16);

If I am not wrong, LS field is 10 bits wide not 11 bits, hence we
should AND 0x3ff.

int value = ((tw & 0xffff)) | ((ls & 0x3ff) << 16);

> +
> +       /* Program the timers in the LPI timer control register:
> +        * LS: minimum time (ms) for which the link
> +        *  status from PHY should be ok before transmitting
> +        *  the LPI pattern.
> +        * TW: minimum time (us) for which the core waits
> +        *  after it has stopped transmitting the LPI pattern.
> +        */
> +       writel(value, ioaddr + GMAC4_LPI_TIMER_CTRL);
> +}
> +
>  static void dwmac4_set_filter(struct mac_device_info *hw,
>                               struct net_device *dev)
>  {
> @@ -410,6 +465,10 @@ static const struct stmmac_ops dwmac4_ops = {
>         .pmt = dwmac4_pmt,
>         .set_umac_addr = dwmac4_set_umac_addr,
>         .get_umac_addr = dwmac4_get_umac_addr,
> +       .set_eee_mode = dwmac4_set_eee_mode,
> +       .reset_eee_mode = dwmac4_reset_eee_mode,
> +       .set_eee_timer = dwmac4_set_eee_timer,
> +       .set_eee_pls = dwmac4_set_eee_pls,
>         .pcs_ctrl_ane = dwmac4_ctrl_ane,
>         .pcs_rane = dwmac4_rane,
>         .pcs_get_adv_lp = dwmac4_get_adv_lp,
> --
> 2.9.3
>



-- 
wwr
Rayagond
