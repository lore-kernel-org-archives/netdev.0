From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH v2 3/4] net: stmmac: add support for Intel Quark X1000
Date: Wed, 1 Oct 2014 11:06:25 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C2B7F65A6@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'peppe.cavallaro@st.com'" <peppe.cavallaro@st.com>,
	"'rayagond@vayavyalabs.com'" <rayagond@vayavyalabs.com>,
	"'vbridgers2013@gmail.com'" <vbridgers2013@gmail.com>,
	"'srinivas.kandagatla@st.com'" <srinivas.kandagatla@st.com>,
	"'wens@csie.org'" <wens@csie.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Kweh, Hock Leong
> Sent: Thursday, September 18, 2014 11:18 AM
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Wednesday, September 17, 2014 12:56 PM
> > Are you kidding me?  It's a perfect way to identify this device, it
> > properly uses PCI_CLASS_NETWORK_ETHERNET (0x0200) in both cases and
> > this will not match any other function on this PCI device at all.
> >
> > Please do as I suggested and use the PCI class for the differentiation
> > and matching during probing.
> 
> Hi David,
> 
> Thanks for your feedback so far. Appreciate it.
> 
> Sorry to my poorly written description that may have caused some confusion.
> My sincere apology here.
> Unfortunately, I don't really grasp your idea clearly based on your responses
> which I appreciate them a lot.
> Sorry for the long description below but I hope to clearly pen down my
> thinking process so that you can follow my thinking incrementally without
> being confused.
> 
> So, let's roll back a bit so that with my following description, you can help
> correct me if my understanding of using PCI function ID to differentiate PHY
> port that is associated with each Ethernet controller is wrong:
> 
> The high-level idea about the change that I made for STMMAC IP inside
> Quark is as follow:
> 
> (1) Based on Quark-specific PCI ID declared inside stmmac_id_table[],  the
> probe() function is
>        called to continue setting-up STMMAC for Quark.
> 
> @@ -228,11 +303,13 @@ static int stmmac_pci_resume(struct pci_dev *pdev)
> 
>  #define STMMAC_VENDOR_ID 0x700
>  #define STMMAC_DEVICE_ID 0x1108
> +#define STMMAC_QUARK_X1000_ID 0x0937
> 
>  static const struct pci_device_id stmmac_id_table[] = {
>  	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID),
> PCI_ANY_ID,
>  			PCI_ANY_ID, CHIP_STMICRO},
>  	{PCI_VDEVICE(STMICRO, PCI_DEVICE_ID_STMICRO_MAC),
> CHIP_STMICRO},
> +	{PCI_VDEVICE(INTEL, STMMAC_QUARK_X1000_ID),
> CHIP_QUARK_X1000},
>  	{}
>  };
> 
> (2) Back-ground on STMMAC hardware configuration on Intel Galileo Gen 1 &
> Gen 2 platforms:
> Intel Quark SoC has 2 MAC controller as described by lspci output below:
> 
> 00:14.6 Class 0200: 8086:0937    ====> 1st MAC controller
> 00:14.7 Class 0200: 8086:0937    ====> 2nd MAC controller
> 
> These Galileo boards use the same Intel Quark SoC and there is only one PHY
> connect to the 1st MAC [00:14.6 Class 0200: 8086:0937] The 2nd MAC [00:14.7
> Class 0200: 8086:0937] is NOT connected to any PHY at all.
> 
> So, it appears to me that the only way that I can differentiate between 1st &
> 2nd MAC are based on PCI function ID, i.e. 14.6 & 14.7. Therefore, within the
> probe() function, for Intel Quark SoC only, the function performs next-level
> discovery of 1st or 2nd MAC controller through quark_run_time_config()
> function.
> For other PCI ID (currently STMICRO_MAC) there is NO next-level discovery
> involved as rt_config is NULL.
> Changes shown below:
> 
> static struct platform_data platform_info[] = { @@ -59,15 +65,76 @@ static
> struct platform_data platform_info[] = {
>  		.phy_reset = NULL,
>  		.phy_mask = 0,
>  		.pbl = 32,
> +		.fixed_burst = 0,
>  		.burst_len = DMA_AXI_BLEN_256,
> +		.rt_config = NULL,  ===================> no 2nd-level
> discovery for other PCI ID
> +	},
> +	[CHIP_QUARK_X1000] = {
> +		.phy_addr = 1,
> +		.interface = PHY_INTERFACE_MODE_RMII,
> +		.clk_csr = 2,
> +		.has_gmac = 1,
> +		.force_sf_dma_mode = 1,
> +		.multicast_filter_bins = HASH_TABLE_SIZE,
> +		.unicast_filter_entries = 1,
> +		.phy_reset = NULL,
> +		.phy_mask = 0,
> +		.pbl = 16,
> +		.fixed_burst = 1,
> +		.burst_len = DMA_AXI_BLEN_256,
> +		.rt_config = &quark_run_time_config,       ==========>
> Quark specific 2nd-level discovery
> +	},
> +};
> 
> (3) Within quark_run_time_config(), due to the only way to differentiate 1st
> or 2nd MAC controller according to difference in function ID explained above,
> the following changes are made:
> 
> +static void quark_run_time_config(int chip_id, struct pci_dev *pdev) {
> +	const char *board_name =
> dmi_get_system_info(DMI_BOARD_NAME);
> +	int i;
> +	int func_num = PCI_FUNC(pdev->devfn);
> +
> +	if (!board_name)
> +		return;
> +
> +	for (i = 0; i < ARRAY_SIZE(quark_x1000_phy_info); i++) {
> +		if ((!strcmp(quark_x1000_phy_info[i].board_name,
> board_name)) &&
> +		    quark_x1000_phy_info[i].pci_func_num == func_num)
> +			platform_info[chip_id].phy_addr =
> +				quark_x1000_phy_info[i].phy_address;
> +	}
> +}
> 
> The reasons for the above proposed condition checks, i.e. "board name" &
> "pci function name" are below:
>   a) As described above, the only difference in both instance of STMMAC IP
> inside Intel Quark SoC is the function ID,
>        so I have proposed to use function ID to be the decision point here to
> differentiate 1st MAC from 2nd MAC.
>   b) Allow future expansion of any other Intel Quark platforms with specific
> need to fix PHY address
>   c) A PHY address set as "-1"  is to mark that the PHY (associated with
> function ID) is not connected to MAC, which
>       is being used here for the 2 Galileo boards -> 2nd MAC port not connected
> with PHY.
> 
> 
> Finally, based on the above description, it appears to me that using PCI
> function ID to decode seems viable for Intel Quark specific hardware
> configuration.
> 
> Appreciate your time and any feedback is very much appreciated.
> 
> Thanks.
> 
> 
> Regards,
> Wilson


Hi Guys,

Just gently ping for the discussion to carry on before forgetting the context.
Anyone have any better idea or comments or concern to this topic?
Hope the above explanation clear out your doubt.


Regards,
Wilson
