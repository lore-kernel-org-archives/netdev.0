From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [v5,net-next,2/9] net: stmmac: configure mtl rx and tx algorithms
Date: Tue, 21 Mar 2017 13:58:36 +0000
Message-ID: <b869becd-899b-1366-cdca-a32820fb8610@synopsys.com>
References: <aa027812f1ab084c3d1e578369cd35c3be3b7f96.1489169213.git.jpinto@synopsys.com>
 <20170321115804.GA5377@ulmo.ba.sec>
 <1020202a-5b96-0c11-a5de-fbd93ff02323@synopsys.com>
 <20170321122426.GE30407@ulmo.ba.sec>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <peppe.cavallaro@st.com>,
        <alexandre.torgue@st.com>, <niklas.cassel@axis.com>,
        <netdev@vger.kernel.org>
To: Thierry Reding <thierry.reding@gmail.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay.synopsys.com ([198.182.60.111]:49848 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757547AbdCUN7a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:30 -0400
In-Reply-To: <20170321122426.GE30407@ulmo.ba.sec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 12:24 PM de 3/21/2017, Thierry Reding escreveu:
> On Tue, Mar 21, 2017 at 12:02:03PM +0000, Joao Pinto wrote:
>> Às 11:58 AM de 3/21/2017, Thierry Reding escreveu:
>>> On Fri, Mar 10, 2017 at 06:24:52PM +0000, Joao Pinto wrote:
>>>> This patch adds the RX and TX scheduling algorithms programming.
>>>> It introduces the multiple queues configuration function
>>>> (stmmac_mtl_configuration) in stmmac_main.
>>>>
>>>> Signed-off-by: Joao Pinto <jpinto@synopsys.com>
>>>> ---
>>>> Changes v4->v5:
>>>> - patch title update (stmicro replaced by stmmac)
>>>> Changes v3->v4:
>>>> - Just to keep up with patch-set version
>>>> Changes v2->v3:
>>>> - Switch statements with a tab
>>>> Changes v1->v2:
>>>> - Just to keep up with patch-set version
>>>>
>>>>  drivers/net/ethernet/stmicro/stmmac/common.h      |  4 ++
>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4.h      | 10 +++++
>>>>  drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 48 +++++++++++++++++++++++
>>>>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 31 +++++++++++++--
>>>>  4 files changed, 90 insertions(+), 3 deletions(-)
>>>
>>> This patch breaks backwards-compatibility with DTBs that don't have an
>>> of the multiple queue properties.
>>>
>>> See below...
>>>
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
>>>> index 04d9245..5a0a781 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/common.h
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/common.h
>>>> @@ -455,6 +455,10 @@ struct stmmac_ops {
>>>>  	int (*rx_ipc)(struct mac_device_info *hw);
>>>>  	/* Enable RX Queues */
>>>>  	void (*rx_queue_enable)(struct mac_device_info *hw, u32 queue);
>>>> +	/* Program RX Algorithms */
>>>> +	void (*prog_mtl_rx_algorithms)(struct mac_device_info *hw, u32 rx_alg);
>>>> +	/* Program TX Algorithms */
>>>> +	void (*prog_mtl_tx_algorithms)(struct mac_device_info *hw, u32 tx_alg);
>>>>  	/* Dump MAC registers */
>>>>  	void (*dump_regs)(struct mac_device_info *hw, u32 *reg_space);
>>>>  	/* Handle extra events on specific interrupts hw dependent */
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>>>> index db45134..748ab6f 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4.h
>>>> @@ -161,6 +161,16 @@ enum power_event {
>>>>  #define GMAC_HI_REG_AE			BIT(31)
>>>>  
>>>>  /*  MTL registers */
>>>> +#define MTL_OPERATION_MODE		0x00000c00
>>>> +#define MTL_OPERATION_SCHALG_MASK	GENMASK(6, 5)
>>>> +#define MTL_OPERATION_SCHALG_WRR	(0x0 << 5)
>>>> +#define MTL_OPERATION_SCHALG_WFQ	(0x1 << 5)
>>>> +#define MTL_OPERATION_SCHALG_DWRR	(0x2 << 5)
>>>> +#define MTL_OPERATION_SCHALG_SP		(0x3 << 5)
>>>> +#define MTL_OPERATION_RAA		BIT(2)
>>>> +#define MTL_OPERATION_RAA_SP		(0x0 << 2)
>>>> +#define MTL_OPERATION_RAA_WSP		(0x1 << 2)
>>>> +
>>>>  #define MTL_INT_STATUS			0x00000c20
>>>>  #define MTL_INT_Q0			BIT(0)
>>>>  
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>>>> index 1e79e65..f966755 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
>>>> @@ -70,6 +70,52 @@ static void dwmac4_rx_queue_enable(struct mac_device_info *hw, u32 queue)
>>>>  	writel(value, ioaddr + GMAC_RXQ_CTRL0);
>>>>  }
>>>>  
>>>> +static void dwmac4_prog_mtl_rx_algorithms(struct mac_device_info *hw,
>>>> +					  u32 rx_alg)
>>>> +{
>>>> +	void __iomem *ioaddr = hw->pcsr;
>>>> +	u32 value = readl(ioaddr + MTL_OPERATION_MODE);
>>>> +
>>>> +	value &= ~MTL_OPERATION_RAA;
>>>> +	switch (rx_alg) {
>>>> +	case MTL_RX_ALGORITHM_SP:
>>>> +		value |= MTL_OPERATION_RAA_SP;
>>>> +		break;
>>>> +	case MTL_RX_ALGORITHM_WSP:
>>>> +		value |= MTL_OPERATION_RAA_WSP;
>>>> +		break;
>>>> +	default:
>>>> +		break;
>>>> +	}
>>>> +
>>>> +	writel(value, ioaddr + MTL_OPERATION_MODE);
>>>> +}
>>>> +
>>>> +static void dwmac4_prog_mtl_tx_algorithms(struct mac_device_info *hw,
>>>> +					  u32 tx_alg)
>>>> +{
>>>> +	void __iomem *ioaddr = hw->pcsr;
>>>> +	u32 value = readl(ioaddr + MTL_OPERATION_MODE);
>>>> +
>>>> +	value &= ~MTL_OPERATION_SCHALG_MASK;
>>>> +	switch (tx_alg) {
>>>> +	case MTL_TX_ALGORITHM_WRR:
>>>> +		value |= MTL_OPERATION_SCHALG_WRR;
>>>> +		break;
>>>> +	case MTL_TX_ALGORITHM_WFQ:
>>>> +		value |= MTL_OPERATION_SCHALG_WFQ;
>>>> +		break;
>>>> +	case MTL_TX_ALGORITHM_DWRR:
>>>> +		value |= MTL_OPERATION_SCHALG_DWRR;
>>>> +		break;
>>>> +	case MTL_TX_ALGORITHM_SP:
>>>> +		value |= MTL_OPERATION_SCHALG_SP;
>>>> +		break;
>>>> +	default:
>>>> +		break;
>>>> +	}
>>>> +}
>>>> +
>>>>  static void dwmac4_dump_regs(struct mac_device_info *hw, u32 *reg_space)
>>>>  {
>>>>  	void __iomem *ioaddr = hw->pcsr;
>>>> @@ -457,6 +503,8 @@ static const struct stmmac_ops dwmac4_ops = {
>>>>  	.core_init = dwmac4_core_init,
>>>>  	.rx_ipc = dwmac4_rx_ipc_enable,
>>>>  	.rx_queue_enable = dwmac4_rx_queue_enable,
>>>> +	.prog_mtl_rx_algorithms = dwmac4_prog_mtl_rx_algorithms,
>>>> +	.prog_mtl_tx_algorithms = dwmac4_prog_mtl_tx_algorithms,
>>>>  	.dump_regs = dwmac4_dump_regs,
>>>>  	.host_irq_status = dwmac4_irq_status,
>>>>  	.flow_ctrl = dwmac4_flow_ctrl,
>>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>> index 4498a38..af57f8d 100644
>>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>>> @@ -1645,6 +1645,31 @@ static void stmmac_init_tx_coalesce(struct stmmac_priv *priv)
>>>>  }
>>>>  
>>>>  /**
>>>> + *  stmmac_mtl_configuration - Configure MTL
>>>> + *  @priv: driver private structure
>>>> + *  Description: It is used for configurring MTL
>>>> + */
>>>> +static void stmmac_mtl_configuration(struct stmmac_priv *priv)
>>>> +{
>>>> +	u32 rx_queues_count = priv->plat->rx_queues_to_use;
>>>> +	u32 tx_queues_count = priv->plat->tx_queues_to_use;
>>>> +
>>>> +	/* Configure MTL RX algorithms */
>>>> +	if (rx_queues_count > 1 && priv->hw->mac->prog_mtl_rx_algorithms)
>>>> +		priv->hw->mac->prog_mtl_rx_algorithms(priv->hw,
>>>> +						priv->plat->rx_sched_algorithm);
>>>> +
>>>> +	/* Configure MTL TX algorithms */
>>>> +	if (tx_queues_count > 1 && priv->hw->mac->prog_mtl_tx_algorithms)
>>>> +		priv->hw->mac->prog_mtl_tx_algorithms(priv->hw,
>>>> +						priv->plat->tx_sched_algorithm);
>>>> +
>>>> +	/* Enable MAC RX Queues */
>>>> +	if (rx_queues_count > 1 && priv->hw->mac->rx_queue_enable)
>>>> +		stmmac_mac_enable_rx_queues(priv);
>>>
>>> This is almost equivalent to the code removed from stmmac_hw_setup()
>>> which happens to be the key for this driver to work for me. However, the
>>> code above adds an additional check for rx_queues_count > 1 which is
>>> going to be false for any existing DTB, because it is derived from the
>>> values retrieved from new device tree properties.
>>>
>>> So I think for backwards compatibility we'd need something like this:
>>>
>>> 	if ((rx_queue_count == 0 || rx_queue_count > 1) &&
>>> 	    priv->hw->mac->rx_queue_enable)
>>>
>>> But then I'm beginning to think maybe we don't need a check here at all
>>> because it would only prevent RX queue setup for rx_queue_count == 1 and
>>> I think it would still be legitimate to set it up even then.
>>>
>>> stmmac_mac_enable_rx_queues() already checks for rx_count == 1, but that
>>> is derived from the number of RX queues derived from the feature
>>> registers and therefore refers to the number of queues that the hardware
>>> supports as opposed to the number of queues configured in device tree.
>>>
>>> I can follow up with a patch to restore backwards-compatibility.
>>
>> Forhw configured as single queue you don't need to enable the rx queue, since
>> they are enable by default. if you check in stmmac_platform.c I assure backward
>> compatibility by setting the number of rx and tx queues = 1 if nothing is
>> declared. Please check here:
>>
>> https://urldefense.proofpoint.com/v2/url?u=https-3A__git.kernel.org_pub_scm_linux_kernel_git_davem_net-2Dnext.git_tree_drivers_net_ethernet_stmicro_stmmac_stmmac-5Fplatform.c-23n156&d=DwIFaQ&c=DPL6_X_6JkXFx7AXWqB0tg&r=s2fO0hii0OGNOv9qQy_HRXy-xAJUD1NNoEcc3io_kx0&m=tvYpf8cZr-Y6Zl-d7NlT2FEW7Gv5Bzs86GMIhZs4OSI&s=jA0P7-MXCVOtu262fF75EhUq5dfcDutzsYg8CAE6XQc&e= 
> 
> Ah yes, I just ran across that trying to debug why a subsequent patch
> broke things again. I think the rx_queue_count > 1 condition is still
> wrong in the above because it will still fail for the backwards-
> compatibility case.

Enabling RX Queue is needed only if the hw is configured as having more than 1
RX queue. If your hardware is configured as being multiple-queue,
rx_queue_to_use should be > 1. True single queue hardware will work fine.

> 
> I still think any check other than priv->hw->mac->rx_queue_enable should
> be dropped when calling stmmac_mac_enable_rx_queues(). A later patch is
> going to move the check into that function anyway (via the for loop). I
> need to step through the series some more since there are a couple of
> other things I noticed that make the driver fail for Tegra186 now. Let
> me report back once I'm through all of it.
> 
> Thierry
> 
