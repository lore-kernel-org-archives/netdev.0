From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Subject: Re: [PATCH 4/4] net: stmmac: add MSI support for Intel Quark X1000
Date: Wed, 01 Oct 2014 13:05:49 +0100
Message-ID: <542BEE1D.30400@nexus-software.ie>
References: <F54AEECA5E2B9541821D670476DAE19C2B7F65A6@PGSMSX102.gar.corp.intel.com> <542BE580.2000807@nexus-software.ie> <F54AEECA5E2B9541821D670476DAE19C2B7F6612@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'peppe.cavallaro@st.com'" <peppe.cavallaro@st.com>,
	"'rayagond@vayavyalabs.com'" <rayagond@vayavyalabs.com>,
	"'vbridgers2013@gmail.com'" <vbridgers2013@gmail.com>,
	"'srinivas.kandagatla@st.com'" <srinivas.kandagatla@st.com>,
	"'wens@csie.org'" <wens@csie.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
	'David Miller' <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C2B7F6612@PGSMSX102.gar.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/10/14 12:55, Kweh, Hock Leong wrote:
>> -----Original Message-----
>> From: Bryan O'Donoghue [mailto:pure.logic@nexus-software.ie]
>> Sent: Wednesday, October 01, 2014 7:29 PM
>> Hi Wilson.
>>
>> Seeing you post now on the PCI emumeration suggestion from Dave Miller I
>> see
>>
>> I wasn't copied on this https://lkml.org/lkml/2014/8/27/190 thread so can
>> only respond now....
>>
>> What's missing from your MSI enabling code is the PVM mask/unmask
>> required on the Quark X1000 bridge - for *all* downstream devices using MSI.
>>
>> I realise it's not an upstreaming friendly piece of code - however - without
>> the PVM mask operation all MSIs on Quark should be considered unreliable.
>>
>> Maybe you guys have submitted patches to the PCI layer on this already ?
>> If so feel free to ignore.
>>
>> If not then please re-evaluate all MSI enabling code.
>>
>>   From the original
>>
>> http://downloadmirror.intel.com/23171/eng/Board_Support_Package_Sour
>> ces_for_Intel_Quark_v1.0.0.7z
>>
>> +#if defined(CONFIG_INTEL_QUARK_X1000_SOC)
>> +	#define mask_pvm(x) qrk_pci_pvm_mask(x)
>> +	#define unmask_pvm(x) qrk_pci_pvm_unmask(x) #else
>> +	#define mask_pvm(x)
>> +	#define unmask_pvm(x)
>> +#endif
>> +
>>    static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
>>    {
>>    	struct net_device *dev = (struct net_device *)dev_id; @@ -1601,10
>> +1686,12 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
>>    		return IRQ_NONE;
>>    	}
>>
>> +	mask_pvm(priv->pdev);
>> +
>>    	/* To handle GMAC own interrupts */
>>    	if (priv->plat->has_gmac) {
>> -		int status = priv->hw->mac->host_irq_status((void __iomem
>> *)
>> -							    dev->base_addr);
>> +		int status = priv->hw->mac->host_irq_status(priv);
>> +
>>    		if (unlikely(status)) {
>>    			if (status & core_mmc_tx_irq)
>>    				priv->xstats.mmc_tx_irq_n++;
>> @@ -1634,6 +1721,8 @@ static irqreturn_t stmmac_interrupt(int irq, void
>> *dev_id)
>>    	/* To handle DMA interrupts */
>>    	stmmac_dma_interrupt(priv);
>>
>> +	unmask_pvm(priv->pdev);

> Hi Bryan,
>
> The MSI masking is already implemented in the MSI framework: http://lxr.free-electrons.com/source/drivers/pci/msi.c#L181.
> I don't see a reason to upstream a local set implementation to Ethernet subsystem.
> Thanks.

Hi Wilson.

Understand where you are getting your MSI enabling code from.

What I'm saying to you is that on Quark SoC X1000 there's an 
*additional* requirement with respect to MSIs

That's why the reference code for the Quark BSP does PVM masking for 
*all* MSI enabled code - not just ethernet.....

I'll have a review of the patches for the SoC thus far with a view to 
ensuring the MSI pvm issue is adequately addressed - but just to be 
clear it's emphatically *not* ethernet specific.

In essence the following additional requirement is place on the Quark 
SoC when using MSIs

pvm_mask();

/* handle your interrupt */

pvm_unmask();

It's the same behaviour in the USB gadget driver...

@@ -2779,55 +2788,70 @@ static irqreturn_t pch_udc_isr(int irq, void *pdev)
  {
  	struct pch_udc_dev *dev = (struct pch_udc_dev *) pdev;
  	u32 dev_intr, ep_intr;
-	int i;
-
-	dev_intr = pch_udc_read_device_interrupts(dev);
-	ep_intr = pch_udc_read_ep_interrupts(dev);
-
-	/* For a hot plug, this find that the controller is hung up. */
-	if (dev_intr == ep_intr)
-		if (dev_intr == pch_udc_readl(dev, UDC_DEVCFG_ADDR)) {
-			dev_dbg(&dev->pdev->dev, "UDC: Hung up\n");
-			/* The controller is reset */
-			pch_udc_writel(dev, UDC_SRST, UDC_SRST_ADDR);
-			return IRQ_HANDLED;
+	int i, events = 0;
+
+	mask_pvm(dev->pdev);
	// do stuff

+	unmask_pvm(dev->pdev);
+
  	return IRQ_HANDLED;
  }

And again in the GIP block

+static irqreturn_t intel_qrk_gip_handler(int irq, void *dev_id)
+{
+	irqreturn_t ret_i2c = IRQ_NONE;
+	irqreturn_t ret_gpio = IRQ_NONE;
+	struct intel_qrk_gip_data *data = (struct intel_qrk_gip_data *)dev_id;
+
+	mask_pvm(data->pci_device);
+
+	if (likely(i2c)) {
+		/* Only I2C gets platform data */
+		ret_i2c = i2c_dw_isr(irq, data->i2c_drvdata);
+	}
+
+	if (likely(gpio)) {
+		ret_gpio = intel_qrk_gpio_isr(irq, NULL);
+	}
+
+	unmask_pvm(data->pci_device);
+
+	if (likely(IRQ_HANDLED == ret_i2c || IRQ_HANDLED == ret_gpio))
+		return IRQ_HANDLED;
+
+	/* Each sub-ISR routine returns either IRQ_HANDLED or IRQ_NONE. */
+	return IRQ_NONE;
+}

Best,
	BOD
