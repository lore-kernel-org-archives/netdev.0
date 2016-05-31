From: Loh Tien Hock <thloh@altera.com>
Subject: Re: [PATCH 1/1] net: ethernet: Add SGMII support to dwmac-socfpga
Date: Tue, 31 May 2016 17:10:52 +0800
Message-ID: <CAJKo0K7hm-L-C=6ieW_o0uuP6M23wHUoxKKEOsQTj6JhtAos6g@mail.gmail.com>
References: <1463122872-31309-1-git-send-email-thloh@altera.com>
 <5735867A.1090405@st.com> <CAJKo0K6-Ak4DOnODgXs2Gx6PVfZUHysdCxpxJifLYv8pa4AQBA@mail.gmail.com>
 <D2D3854A0FC5BC47B9A35FE9D8E8F86006C019B0@SJ-ITEXCH02.altera.priv.altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dinguyen@altera.com, cnphoon@altera.com,
	Loh Tien Hock <thloh85@gmail.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <D2D3854A0FC5BC47B9A35FE9D8E8F86006C019B0@SJ-ITEXCH02.altera.priv.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peppe,

Sorry for the late reply.

I believe my patch's title is a little confusing. The patch is to
enable Altera TSE PCS SGMII support, not to add SGMII support to
stmmac (well that in a way tests SGMII for stmmac though)

I went through the code and it seems like if we were to refactor PCS
defines (and codes) into common code it would bloat up the common
codes.
Would it be better if we create new PCS source files (eg.
altr_tse_pcs.c/.h)? This means the rest of the PCS supports should
also be refactored out as well for consistency purposes.

Thanks

On Fri, May 13, 2016 at 3:47 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> Hello Tien
>
> On 5/13/2016 9:01 AM, thloh@altera.com wrote:
>>
>> From: Tien Hock Loh <thloh@altera.com>
>>
>> Adds SGMII support for dwmac-socfpga to enable the SGMII PHY when phy-mode
>> of the dwmac is set to sgmii.
>
>
> I wonder if part of this patch can be unified to the common code
> reusing (or improving) existent PCS support (see, for example the
> defines inside the common.h and dwmac1000.h header files).
> I had added some code for RGMII but never tested the SGMII indeed.
>
> what is your feeling about that?
>
> Peppe
>
>
>>
>> Signed-off-by: Tien Hock Loh <thloh@altera.com>
>> ---
>>   .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 339
>> ++++++++++++++++++++-
>>   1 file changed, 329 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> index 41f4c58..a59d590 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
>> @@ -40,6 +40,43 @@
>>   #define EMAC_SPLITTER_CTRL_SPEED_100          0x3
>>   #define EMAC_SPLITTER_CTRL_SPEED_1000         0x0
>>
>> +#define TSE_PCS_CONTROL_AN_EN_MASK                     0x1000
>> +#define TSE_PCS_CONTROL_REG                            0x00
>> +#define TSE_PCS_CONTROL_RESTART_AN_MASK                0x0200
>> +#define TSE_PCS_IF_MODE_REG                            0x28
>> +#define TSE_PCS_LINK_TIMER_0_REG                       0x24
>> +#define TSE_PCS_LINK_TIMER_1_REG                       0x26
>> +#define TSE_PCS_SIZE                                   0x40
>> +#define TSE_PCS_STATUS_AN_COMPLETED_MASK               0x0020
>> +#define TSE_PCS_STATUS_LINK_MASK                       0x0004
>> +#define TSE_PCS_STATUS_REG                             0x02
>> +#define TSE_PCS_SGMII_SPEED_1000                       0x8
>> +#define TSE_PCS_SGMII_SPEED_100                        0x4
>> +#define TSE_PCS_SGMII_SPEED_10                         0x0
>> +#define TSE_PCS_SW_RST_MASK                            0x8000
>> +#define TSE_PCS_PARTNER_ABILITY_REG                    0x0A
>> +#define TSE_PCS_PARTNER_DUPLEX_FULL                    0x1000
>> +#define TSE_PCS_PARTNER_DUPLEX_HALF                    0x0000
>> +#define TSE_PCS_PARTNER_DUPLEX_MASK                    0x1000
>> +#define TSE_PCS_PARTNER_SPEED_MASK                     0x0c00
>> +#define TSE_PCS_PARTNER_SPEED_1000                     0x0800
>> +#define TSE_PCS_PARTNER_SPEED_100                      0x0400
>> +#define TSE_PCS_PARTNER_SPEED_10                       0x0000
>> +#define TSE_PCS_PARTNER_SPEED_1000                     0x0800
>> +#define TSE_PCS_PARTNER_SPEED_100                      0x0400
>> +#define TSE_PCS_PARTNER_SPEED_10                       0x0000
>> +#define TSE_PCS_SGMII_SPEED_MASK                       0x000C
>> +#define TSE_PCS_SGMII_LINK_TIMER_0                     0x0D40
>> +#define TSE_PCS_SGMII_LINK_TIMER_1                     0x0003
>> +#define TSE_PCS_SW_RESET_TIMEOUT                       100
>> +#define TSE_PCS_USE_SGMII_AN_MASK                      0x0002
>> +
>> +#define SGMII_ADAPTER_CTRL_REG                         0x00
>> +#define SGMII_ADAPTER_DISABLE                          0x0001
>> +#define SGMII_ADAPTER_ENABLE                           0x0000
>> +#define LINK_TIMER                                     20
>> +#define AUTONEGO_TIMER                                 20
>> +
>>   struct socfpga_dwmac {
>>         int     interface;
>>         u32     reg_offset;
>> @@ -49,18 +86,17 @@ struct socfpga_dwmac {
>>         struct reset_control *stmmac_rst;
>>         void __iomem *splitter_base;
>>         bool f2h_ptp_ref_clk;
>> +       void __iomem *tse_pcs_base;
>> +       void __iomem *sgmii_adapter_base;
>> +       struct timer_list an_timer;
>> +       struct timer_list link_timer;
>>   };
>>
>> -static void socfpga_dwmac_fix_mac_speed(void *priv, unsigned int speed)
>> +static void config_emac_splitter_speed(void __iomem *base, unsigned int
>> speed)
>>   {
>> -       struct socfpga_dwmac *dwmac = (struct socfpga_dwmac *)priv;
>> -       void __iomem *splitter_base = dwmac->splitter_base;
>>         u32 val;
>>
>> -       if (!splitter_base)
>> -               return;
>> -
>> -       val = readl(splitter_base + EMAC_SPLITTER_CTRL_REG);
>> +       val = readl(base + EMAC_SPLITTER_CTRL_REG);
>>         val &= ~EMAC_SPLITTER_CTRL_SPEED_MASK;
>>
>>         switch (speed) {
>> @@ -76,8 +112,214 @@ static void socfpga_dwmac_fix_mac_speed(void *priv,
>> unsigned int speed)
>>         default:
>>                 return;
>>         }
>> +       writel(val, base + EMAC_SPLITTER_CTRL_REG);
>> +}
>> +
>> +static void config_tx_buffer(u16 data, void __iomem *base)
>> +{
>> +       writew(data, base + SGMII_ADAPTER_CTRL_REG);
>> +}
>> +
>> +static void tse_pcs_reset(void __iomem *base, struct socfpga_dwmac
>> *dwmac)
>> +{
>> +       int counter = 0;
>> +       u16 val;
>> +
>> +       val = readw(base + TSE_PCS_CONTROL_REG);
>> +       val |= TSE_PCS_SW_RST_MASK;
>> +       writew(val, base + TSE_PCS_CONTROL_REG);
>> +
>> +       while (counter < TSE_PCS_SW_RESET_TIMEOUT) {
>> +               val = readw(base + TSE_PCS_CONTROL_REG);
>> +               val &= TSE_PCS_SW_RST_MASK;
>> +               if (val == 0)
>> +                       break;
>> +               counter++;
>> +               udelay(1);
>> +       }
>> +       if (counter >= TSE_PCS_SW_RESET_TIMEOUT)
>> +               dev_err(dwmac->dev, "PCS could not get out of sw
>> reset\n");
>> +}
>> +
>> +static void tse_pcs_init(void __iomem *base, struct socfpga_dwmac *dwmac)
>> +{
>> +       writew(0x0001, base + TSE_PCS_IF_MODE_REG);
>> +
>> +       writew(TSE_PCS_SGMII_LINK_TIMER_0, base +
>> TSE_PCS_LINK_TIMER_0_REG);
>> +       writew(TSE_PCS_SGMII_LINK_TIMER_1, base +
>> TSE_PCS_LINK_TIMER_1_REG);
>> +
>> +       tse_pcs_reset(base, dwmac);
>> +}
>> +
>> +static void pcs_link_timer_callback(unsigned long data)
>> +{
>> +       u16 val = 0;
>> +
>> +       struct socfpga_dwmac *dwmac = (struct socfpga_dwmac *)data;
>> +       void __iomem *tse_pcs_base = dwmac->tse_pcs_base;
>> +       void __iomem *sgmii_adapter_base = dwmac->sgmii_adapter_base;
>> +
>> +       val = readw(tse_pcs_base + TSE_PCS_STATUS_REG);
>> +       val &=  TSE_PCS_STATUS_LINK_MASK;
>> +
>> +       if (val != 0) {
>> +               dev_dbg(dwmac->dev, "Adapter: Link is established\n");
>> +               config_tx_buffer(SGMII_ADAPTER_ENABLE,
>> sgmii_adapter_base);
>> +       } else {
>> +               mod_timer(&dwmac->link_timer, jiffies +
>> +                               msecs_to_jiffies(LINK_TIMER));
>> +       }
>> +}
>> +
>> +static void auto_nego_timer_callback(unsigned long data)
>> +{
>> +       u16 val = 0;
>> +       u16 speed = 0;
>> +       u16 duplex = 0;
>> +
>> +       struct socfpga_dwmac *dwmac = (struct socfpga_dwmac *)data;
>> +       void __iomem *tse_pcs_base = dwmac->tse_pcs_base;
>> +       void __iomem *sgmii_adapter_base = dwmac->sgmii_adapter_base;
>> +
>> +       val = readw(tse_pcs_base + TSE_PCS_STATUS_REG);
>> +       val &=  TSE_PCS_STATUS_AN_COMPLETED_MASK;
>> +
>> +       if (val != 0) {
>> +               dev_dbg(dwmac->dev, "Adapter: Auto Negotiation is
>> completed\n");
>> +               val = readw(tse_pcs_base + TSE_PCS_PARTNER_ABILITY_REG);
>> +               speed = val & TSE_PCS_PARTNER_SPEED_MASK;
>> +               duplex = val & TSE_PCS_PARTNER_DUPLEX_MASK;
>> +
>> +               if (speed == TSE_PCS_PARTNER_SPEED_10 &&
>> +                   duplex == TSE_PCS_PARTNER_DUPLEX_FULL)
>> +                       dev_dbg(dwmac->dev,
>> +                               "Adapter: Link Partner is Up -
>> 10/Full\n");
>> +               else if (speed == TSE_PCS_PARTNER_SPEED_100 &&
>> +                        duplex == TSE_PCS_PARTNER_DUPLEX_FULL)
>> +                       dev_dbg(dwmac->dev,
>> +                               "Adapter: Link Partner is Up -
>> 100/Full\n");
>> +               else if (speed == TSE_PCS_PARTNER_SPEED_1000 &&
>> +                        duplex == TSE_PCS_PARTNER_DUPLEX_FULL)
>> +                       dev_dbg(dwmac->dev,
>> +                               "Adapter: Link Partner is Up -
>> 1000/Full\n");
>> +               else if (speed == TSE_PCS_PARTNER_SPEED_10 &&
>> +                        duplex == TSE_PCS_PARTNER_DUPLEX_HALF)
>> +                       dev_err(dwmac->dev,
>> +                               "Adapter does not support Half Duplex\n");
>> +               else if (speed == TSE_PCS_PARTNER_SPEED_100 &&
>> +                        duplex == TSE_PCS_PARTNER_DUPLEX_HALF)
>> +                       dev_err(dwmac->dev,
>> +                               "Adapter does not support Half Duplex\n");
>> +               else if (speed == TSE_PCS_PARTNER_SPEED_1000 &&
>> +                        duplex == TSE_PCS_PARTNER_DUPLEX_HALF)
>> +                       dev_err(dwmac->dev,
>> +                               "Adapter does not support Half Duplex\n");
>> +               else
>> +                       dev_err(dwmac->dev,
>> +                               "Adapter: Invalid Partner Speed and
>> Duplex\n");
>> +
>> +               config_tx_buffer(SGMII_ADAPTER_ENABLE,
>> sgmii_adapter_base);
>> +       } else {
>> +               val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
>> +               val |= TSE_PCS_CONTROL_RESTART_AN_MASK;
>> +               writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
>> +
>> +               tse_pcs_reset(tse_pcs_base, dwmac);
>> +               mod_timer(&dwmac->an_timer, jiffies +
>> +                         msecs_to_jiffies(AUTONEGO_TIMER));
>> +       }
>> +}
>> +
>> +static void socfpga_dwmac_fix_mac_speed(void *priv, unsigned int speed)
>> +{
>> +       struct socfpga_dwmac *dwmac = (struct socfpga_dwmac *)priv;
>> +       void __iomem *splitter_base = dwmac->splitter_base;
>> +       void __iomem *tse_pcs_base = dwmac->tse_pcs_base;
>> +       void __iomem *sgmii_adapter_base = dwmac->sgmii_adapter_base;
>> +       struct device *dev = dwmac->dev;
>> +       struct net_device *ndev = dev_get_drvdata(dev);
>> +       struct phy_device *phy_dev = ndev->phydev;
>> +       u32 val;
>>
>> -       writel(val, splitter_base + EMAC_SPLITTER_CTRL_REG);
>> +       if ((tse_pcs_base) && (sgmii_adapter_base)) {
>> +               config_tx_buffer(SGMII_ADAPTER_DISABLE,
>> sgmii_adapter_base);
>> +               if (splitter_base)
>> +                       config_emac_splitter_speed(splitter_base, speed);
>> +
>> +               if (phy_dev->autoneg == AUTONEG_ENABLE) {
>> +                       val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
>> +                       val |= TSE_PCS_CONTROL_AN_EN_MASK;
>> +                       writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
>> +
>> +                       val = readw(tse_pcs_base + TSE_PCS_IF_MODE_REG);
>> +                       val |= TSE_PCS_USE_SGMII_AN_MASK;
>> +                       writew(val, tse_pcs_base + TSE_PCS_IF_MODE_REG);
>> +
>> +                       val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
>> +                       val |= TSE_PCS_CONTROL_RESTART_AN_MASK;
>> +                       writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
>> +
>> +                       tse_pcs_reset(tse_pcs_base, dwmac);
>> +
>> +                       setup_timer(&dwmac->an_timer,
>> +                                   auto_nego_timer_callback,
>> +                                   (unsigned long)dwmac);
>> +                       mod_timer(&dwmac->an_timer, jiffies +
>> +                                 msecs_to_jiffies(AUTONEGO_TIMER));
>> +               } else if (phy_dev->autoneg == AUTONEG_DISABLE) {
>> +                       val = readw(tse_pcs_base + TSE_PCS_CONTROL_REG);
>> +                       val &= ~TSE_PCS_CONTROL_AN_EN_MASK;
>> +                       writew(val, tse_pcs_base + TSE_PCS_CONTROL_REG);
>> +
>> +                       val = readw(tse_pcs_base + TSE_PCS_IF_MODE_REG);
>> +                       val &= ~TSE_PCS_USE_SGMII_AN_MASK;
>> +                       writew(val, tse_pcs_base + TSE_PCS_IF_MODE_REG);
>> +
>> +                       val = readw(tse_pcs_base + TSE_PCS_IF_MODE_REG);
>> +                       val &= ~TSE_PCS_SGMII_SPEED_MASK;
>> +
>> +                       switch (speed) {
>> +                       case 1000:
>> +                               val |= TSE_PCS_SGMII_SPEED_1000;
>> +                               break;
>> +                       case 100:
>> +                               val |= TSE_PCS_SGMII_SPEED_100;
>> +                               break;
>> +                       case 10:
>> +                               val |= TSE_PCS_SGMII_SPEED_10;
>> +                               break;
>> +                       default:
>> +                               return;
>> +                       }
>> +                       writew(val, tse_pcs_base + TSE_PCS_IF_MODE_REG);
>> +
>> +                       tse_pcs_reset(tse_pcs_base, dwmac);
>> +
>> +                       setup_timer(&dwmac->link_timer,
>> +                                   pcs_link_timer_callback,
>> +                                               (unsigned long)dwmac);
>> +                       mod_timer(&dwmac->link_timer, jiffies +
>> +                                 msecs_to_jiffies(LINK_TIMER));
>> +               }
>> +       } else if (splitter_base) {
>> +               val = readl(splitter_base + EMAC_SPLITTER_CTRL_REG);
>> +               val &= ~EMAC_SPLITTER_CTRL_SPEED_MASK;
>> +
>> +               switch (speed) {
>> +               case 1000:
>> +                       val |= EMAC_SPLITTER_CTRL_SPEED_1000;
>> +                       break;
>> +               case 100:
>> +                       val |= EMAC_SPLITTER_CTRL_SPEED_100;
>> +                       break;
>> +               case 10:
>> +                       val |= EMAC_SPLITTER_CTRL_SPEED_10;
>> +                       break;
>> +               default:
>> +                       return;
>> +               }
>> +               writel(val, splitter_base + EMAC_SPLITTER_CTRL_REG);
>> +       }
>>   }
>>
>>   static int socfpga_dwmac_parse_data(struct socfpga_dwmac *dwmac, struct
>> device *dev)
>> @@ -85,9 +327,13 @@ static int socfpga_dwmac_parse_data(struct
>> socfpga_dwmac *dwmac, struct device *
>>         struct device_node *np = dev->of_node;
>>         struct regmap *sys_mgr_base_addr;
>>         u32 reg_offset, reg_shift;
>> -       int ret;
>> -       struct device_node *np_splitter;
>> +       int ret, index;
>> +       struct device_node *np_splitter = NULL;
>> +       struct device_node *np_sgmii_adapter = NULL;
>> +
>>         struct resource res_splitter;
>> +       struct resource res_tse_pcs;
>> +       struct resource res_sgmii_adapter;
>>
>>         dwmac->stmmac_rst = devm_reset_control_get(dev,
>>                                                   STMMAC_RESOURCE_NAME);
>> @@ -134,6 +380,72 @@ static int socfpga_dwmac_parse_data(struct
>> socfpga_dwmac *dwmac, struct device *
>>                 }
>>         }
>>
>> +       np_sgmii_adapter = of_parse_phandle(np,
>> +
>> "altr,gmii_to_sgmii_converter", 0);
>> +       if (np_sgmii_adapter) {
>> +               index = of_property_match_string(np_sgmii_adapter,
>> "reg-names",
>> +
>> "hps_emac_interface_splitter_avalon_slave");
>> +
>> +               if (index >= 0) {
>> +                       if (of_address_to_resource(np_sgmii_adapter,
>> index,
>> +                                                  &res_splitter)) {
>> +                               dev_err(dev, "%s: ERROR: missing emac
>> splitter "
>> +                                       "address\n", __func__);
>> +                               return -EINVAL;
>> +                       }
>> +
>> +                       dwmac->splitter_base = devm_ioremap_resource(
>> +                               dev, &res_splitter);
>> +
>> +                       if (IS_ERR(dwmac->splitter_base)) {
>> +                               dev_err(dev, "%s: ERROR: failed to mapping
>> emac"
>> +                                       " splitter\n", __func__);
>> +                               return PTR_ERR(dwmac->splitter_base);
>> +                       }
>> +               }
>> +
>> +               index = of_property_match_string(np_sgmii_adapter,
>> "reg-names",
>> +
>> "gmii_to_sgmii_adapter_avalon_slave");
>> +
>> +               if (index >= 0) {
>> +                       if (of_address_to_resource(np_sgmii_adapter,
>> index,
>> +                                                  &res_sgmii_adapter)) {
>> +                               dev_err(dev, "%s: ERROR: failed to mapping
>> adapter\n",
>> +                                       __func__);
>> +                               return -EINVAL;
>> +                       }
>> +
>> +                       dwmac->sgmii_adapter_base = devm_ioremap_resource(
>> +                               dev, &res_sgmii_adapter);
>> +
>> +                       if (IS_ERR(dwmac->sgmii_adapter_base)) {
>> +                               dev_err(dev, "%s: failed to mapping
>> adapter\n",
>> +                                       __func__);
>> +                               return PTR_ERR(dwmac->sgmii_adapter_base);
>> +                       }
>> +               }
>> +
>> +               index = of_property_match_string(np_sgmii_adapter,
>> "reg-names",
>> +                                                "eth_tse_control_port");
>> +
>> +               if (index >= 0) {
>> +                       if (of_address_to_resource(np_sgmii_adapter,
>> index,
>> +                                                  &res_tse_pcs)) {
>> +                               dev_err(dev, "%s: ERROR: failed mapping
>> tse control port\n",
>> +                                       __func__);
>> +                               return -EINVAL;
>> +                       }
>> +
>> +                       dwmac->tse_pcs_base = devm_ioremap_resource(
>> +                       dev, &res_tse_pcs);
>> +
>> +                       if (IS_ERR(dwmac->tse_pcs_base)) {
>> +                               dev_err(dev, "%s: failed to mapping tse
>> control port\n",
>> +                                       __func__);
>> +                               return PTR_ERR(dwmac->sgmii_adapter_base);
>> +                       }
>> +               }
>> +       }
>>         dwmac->reg_offset = reg_offset;
>>         dwmac->reg_shift = reg_shift;
>>         dwmac->sys_mgr_base_addr = sys_mgr_base_addr;
>> @@ -157,6 +469,7 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac
>> *dwmac)
>>                 break;
>>         case PHY_INTERFACE_MODE_MII:
>>         case PHY_INTERFACE_MODE_GMII:
>> +       case PHY_INTERFACE_MODE_SGMII:
>>                 val = SYSMGR_EMACGRP_CTRL_PHYSEL_ENUM_GMII_MII;
>>                 break;
>>         default:
>> @@ -181,6 +494,12 @@ static int socfpga_dwmac_setup(struct socfpga_dwmac
>> *dwmac)
>>                 ctrl &= ~(SYSMGR_EMACGRP_CTRL_PTP_REF_CLK_MASK <<
>> (reg_shift / 2));
>>
>>         regmap_write(sys_mgr_base_addr, reg_offset, ctrl);
>> +
>> +       if (phymode == PHY_INTERFACE_MODE_SGMII) {
>> +               tse_pcs_init(dwmac->tse_pcs_base, dwmac);
>> +               config_tx_buffer(SGMII_ADAPTER_ENABLE,
>> +                                dwmac->sgmii_adapter_base);
>> +       }
>>         return 0;
>>   }
>>
>>
>
