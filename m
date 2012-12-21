From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH 1/3] net: stmmac: change GMAC control register for SGMII
Date: Fri, 21 Dec 2012 13:17:26 -0600
Message-ID: <001301cddfaf$d18900a0$749b01e0$@samsung.com>
References: <004b01cdc959$80af8030$820e8090$%an@samsung.com>
 <50B344FC.4070405@st.com> <009401cdcd57$18b275d0$4a176170$%an@samsung.com>
 <50BDEDE8.4030105@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kgene.kim@samsung.com,
	linux-kernel@vger.kernel.org
To: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <50BDEDE8.4030105@st.com>
Content-language: en-us
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/04/2012 06:35 AM, Giuseppe CAVALLARO wrote:
>On 11/28/2012 11:57 AM, Byungho An wrote:
>> On 11/26/2012 07:31 PM, Giuseppe CABALLARO wrote:
>>> On 11/23/2012 10:04 AM, Byungho An wrote:
>>>>
>>>> This patch changes GMAC control register (TC(Transmit
>>>> Configuration) and PS(Port Selection) bit for SGMII.
>>>> In case of SGMII, TC bit is '1' and PS bit is 0.
>>>
>>> IMO this new support that should be released for net-next and further
>>> effort is actually needed.
>>>
>> OK, I see but if possible, I want to support the new features which is
>> included in this patch from v3.8
>
>ok I agree and I can support you.
>
>>
>>> The availability of the PCS registers is given by looking at the HW
>>> feature register. In fact, these are optional registers.
>>> I don't want to break the compatibility with old chips.
>>>
>> It means that old chip doesn't have this bit or this register? If that,
how
>> about using compatible in DT blob like snps,dwmac-3.70a and then in just
>> this case trying to read this bit and this register.
>
>The driver also works on mac 10/100 Databook 2.0 that has not these
>registers.
>
>>> I do not see why we have to use Kconfig macro to select ANE etc (as
>>> you do in your patches).
>> OK. I agree with you.
>
>we have to use the HW feature reg.
>
>>
>>> The driver could directly manage the phy device by itself if possible
>>> and the stmmac_init_phy should be reworked.
>>>
>> Could you explain more detail? As I understood, after set ANE bit in MAC
>> side then PHY auto-negotiation can be enabled. If I'm wrong let me know.
>> According to your mention, MAC and PHY auto-negotiation can be managed
>in
>> stmmac_init_phy?
>
>Currently the driver uses the Physical Abstraction Layer (PAL) to dialog
>with a PHY. On all the platforms supported (not only ST) we have always
>used it. Personally, I tested several phy devices with different MII
>interfaces (MII/RMII/GMII/RGMII ... ) but not TBI/RTBI/SGMII interfaces.
>
Currently I'm testing on SGMII interface and so far it's working fine.

>>> There are several things that need to be implemented. For example:
>>>
>>> The ISR (e.g. priv->hw->mac->host_irq_status) should be able to manage
>>> these new interrupts.
>> I think that there would be two additional interrupts."PCS
Auto-Negotiation
>> Complete" and "PCS Link Status Changed". These two interrupts are added
>to
>> "stmmac_interrupt". In my opinion, there are no specific processing for
>> these two irqs. What do you think about it?
>
>if the link changes this has to be logged in the driver.
>For example, depending on the link speed on some platforms we need to
>call dedicated call-back to set sysconfig registers or custom clocks.
>
>>> The code has to be able to maintain the user interface.
>>> For example if you want to enable ANE or manage Advertisement caps.
>>>
>> Does it mean that command line or other network command(e.g. ifconfig...)
>or
>> ioctol? Actually I don't understand exact user interface way. Could you
>> recommend the method for user interface?
>
>Using ethtool or mii-tool the user want to know the link status. So
>these kind of information have to be maintained.
>
As I know, user can set speed, duplex mode and auto-negotiation on/off using
ethtool.
If user wants to set auto-negotiation on, I think GMAC's ANE bit should be
ON as well.
For example, in stmmac_ethtool.c file, I try to add GMAC ANE bit enable
setting.
I think stmmac_set_pauseparam function is suitable for it.

	if (phy->autoneg) {
		if (netif_running(netdev)) {
 			ret = phy_start_aneg(phy);
+			value = readl(priv->ioaddr + GMAC_AN_CTRL);
+			value |= 0x1000;
+			writel(value, priv->ioaddr + GMAC_AN_CTRL);
+		}

What's your opinion?

>Take a look at the stmmac_adjust_link that is called by the PAL.
>
And for speed setting, if user changes speed to 1Gb using ethtool, link
status will be changed and then interrupt is occurred.
In the ISR, If interface is SGMII, I want to add SGMRAL setting and PS(port
selection)for guarantee 1Gb speed.
In the dwmac1000_core.c file.

+	if (unlikely(intr_status & pcs_link_irq)) {
+		readl(ioaddr + GMAC_AN_STATUS);
+		status |= core_irq_pcs_link;

+		if (priv->phydev->interface == PHY_INTERFACE_MODE_SGMII) {
+			value = readl(priv->ioaddr);
+			/* GMAC_CONTROL_PS : Port Selection for GMII */
+			value &= ~GMAC_CONTROL_PS;
+			writel(value, priv->ioaddr);
+			value = readl(priv->ioaddr + GMAC_AN_CTRL);
+			value = |= 0x40000;
+			writel(value, priv->ioaddr + GMAC_AN_CTRL);
+		}		
+	}

Then stmmac_interrupt in stmmac_main.c file call stmmac_adjust_link when
status is core_irq_pcs_link.
 
For auto-negotiation complete interrupt, I try to make patch like below

drivers/net/ethernet/stmicro/stmmac/common.h
@@ -184,6 +184,7 @@ enum core_specific_irq_mask {
 	core_irq_tx_path_exit_lpi_mode = 32,
 	core_irq_rx_path_in_lpi_mode = 64,
 	core_irq_rx_path_exit_lpi_mode = 128,
+	core_irq_rx_pcs_an = 256,
 };
 
 /* DMA HW capabilities */

drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
@@ -231,6 +231,11 @@ static int dwmac1000_irq_status(void __iomem *ioaddr)
 		readl(ioaddr + GMAC_PMT);
 		status |= core_irq_receive_pmt_irq;
 	}
+	if (unlikely(intr_status & pcs_ane_irq)) {
+		CHIP_DBG(KERN_INFO "GMAC: PCS Auto-negotiation complete\n");
+		readl(ioaddr + GMAC_AN_STATUS);
+		status |= core_irq_pcs_an;
+	}
 	/* MAC trx/rx EEE LPI entry/exit interrupts */
 	if (intr_status & lpiis_irq) {
 		/* Clean LPI interrupt by reading the Reg 12 */

drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -93,6 +93,7 @@ struct stmmac_priv {
 	int eee_enabled;
 	int eee_active;
 	int tx_lpi_timer;
+	bool core_pcs_an;
 };
 
 extern int phyaddr;

drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1658,6 +1658,8 @@ static irqreturn_t stmmac_interrupt(int irq, void
*dev_id)
 				priv->xstats.mmc_rx_csum_offload_irq_n++;
 			if (status & core_irq_receive_pmt_irq)
 				priv->xstats.irq_receive_pmt_irq_n++;
+			if (status & core_irq_pcs_an)
+				priv->core_pcs_an = true;
 
 			/* For LPI we need to save the tx status */
 			if (status & core_irq_tx_path_in_lpi_mode) {

>>>> Signed-off-by: Byungho An <bh74.an@samsung.com>
>>>> ---
>>>
>>> [snip]
>>>
>>>> +	if (priv->phydev->interface == PHY_INTERFACE_MODE_SGMII) {
>>>> +		value = readl(priv->ioaddr);
>>>> +		/* GMAC_CONTROL_TC : transmit config in RGMII/SGMII */
>>>> +		value |= 0x1000000;
>>>> +		/* GMAC_CONTROL_PS : Port Selection for GMII */
>>>> +		value &= ~(0x8000);
>>>> +		writel(value, priv->ioaddr);
>>>> +	}
>>>> +
>>>
>>>
>>> This parts of code have to be moved in
>>> drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
>>>
>> OK.
>>
I moved this code todwmac1000_core.c using hw feature register like below

+#include "dwmac_dma.h"
 
 static void dwmac1000_core_init(void __iomem *ioaddr)
 {
 	u32 value = readl(ioaddr + GMAC_CONTROL);
+	u32 hw_feature = readl(ioaddr + DMA_HW_FEATURE);
 	value |= GMAC_CORE_INIT;
 	writel(value, ioaddr + GMAC_CONTROL);
+	hw_feature &= DMA_HW_FEAT_ACTPHYIF;
+
+	if ((hw_feature >> 28 < 2) && (hw_feature != 0) {
+		/* transmit config in RGMII/SGMII */
+		value |= GMAC_CONTROL_TC;
+	}
+	writel(value, ioaddr + GMAC_CONTROL);

>>> Pls, do not use value |= 0x1000000 but provide the appropriate defines.
>>>
>> OK.
>>
>>>>    	/* Request the IRQ lines */
>>>>    	ret = request_irq(dev->irq, stmmac_interrupt,
>>>>    			 IRQF_SHARED, dev->name, dev);
>>>>
>> Thank you.
>
>you are welcome
>Peppe
>
>> Byungho An.
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>
Thank you.
Byungho An.

 --
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org More majordomo
info at  http://vger.kernel.org/majordomo-info.html
