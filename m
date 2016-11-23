From: Bjorn Helgaas <helgaas@kernel.org>
Subject: Re: [PATCH kernel v3] PCI: Enable access to custom VPD for Chelsio
 devices (cxgb3)
Date: Wed, 23 Nov 2016 16:35:58 -0600
Message-ID: <20161123223558.GH16033@bhelgaas-glaptop.roam.corp.google.com>
References: <1477292657-3021-1-git-send-email-aik@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Santosh Raspatur <santosh@chelsio.com>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477292657-3021-1-git-send-email-aik@ozlabs.ru>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2016 at 06:04:17PM +1100, Alexey Kardashevskiy wrote:
> There is at least one Chelsio 10Gb card which uses VPD area to store
> some custom blocks (example below). However pci_vpd_size() returns
> the length of the first block only assuming that there can be only
> one VPD "End Tag" and VFIO blocks access beyond that offset
> (since 4e1a63555) which leads to the situation when the guest "cxgb3"
> driver fails to probe the device. The host system does not have this
> problem as the drives accesses the config space directly without
> pci_read_vpd()/...
> 
> This adds a quirk to override the VPD size to a bigger value.
> The maximum size is taken from EEPROMSIZE in
> drivers/net/ethernet/chelsio/cxgb3/common.h. We do not read the tag
> as the cxgb3 driver does as the driver supports writing to EEPROM/VPD
> and when it writes, it only checks for 8192 bytes boundary. The quirk
> is registerted for all devices supported by the cxgb3 driver.
> 
> This adds a quirk to the PCI layer (not to the cxgb3 driver) as
> the cxgb3 driver itself accesses VPD directly and the problem only exists
> with the vfio-pci driver (when cxgb3 is not running on the host and
> may not be even loaded) which blocks accesses beyond the first block
> of VPD data. However vfio-pci itself does not have quirks mechanism so
> we add it to PCI.
> 
> This is the controller:
> Ethernet controller [0200]: Chelsio Communications Inc T310 10GbE Single Port Adapter [1425:0030]
> 
> This is what I parsed from its vpd:
> ===
> b'\x82*\x0010 Gigabit Ethernet-SR PCI Express Adapter\x90J\x00EC\x07D76809 FN\x0746K'
>  0000 Large item 42 bytes; name 0x2 Identifier String
> 	b'10 Gigabit Ethernet-SR PCI Express Adapter'
>  002d Large item 74 bytes; name 0x10
> 	#00 [EC] len=7: b'D76809 '
> 	#0a [FN] len=7: b'46K7897'
> 	#14 [PN] len=7: b'46K7897'
> 	#1e [MN] len=4: b'1037'
> 	#25 [FC] len=4: b'5769'
> 	#2c [SN] len=12: b'YL102035603V'
> 	#3b [NA] len=12: b'00145E992ED1'
>  007a Small item 1 bytes; name 0xf End Tag
> 
>  0c00 Large item 16 bytes; name 0x2 Identifier String
> 	b'S310E-SR-X      '
>  0c13 Large item 234 bytes; name 0x10
> 	#00 [PN] len=16: b'TBD             '
> 	#13 [EC] len=16: b'110107730D2     '
> 	#26 [SN] len=16: b'97YL102035603V  '
> 	#39 [NA] len=12: b'00145E992ED1'
> 	#48 [V0] len=6: b'175000'
> 	#51 [V1] len=6: b'266666'
> 	#5a [V2] len=6: b'266666'
> 	#63 [V3] len=6: b'2000  '
> 	#6c [V4] len=2: b'1 '
> 	#71 [V5] len=6: b'c2    '
> 	#7a [V6] len=6: b'0     '
> 	#83 [V7] len=2: b'1 '
> 	#88 [V8] len=2: b'0 '
> 	#8d [V9] len=2: b'0 '
> 	#92 [VA] len=2: b'0 '
> 	#97 [RV] len=80: b's\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'...
>  0d00 Large item 252 bytes; name 0x11
> 	#00 [VC] len=16: b'122310_1222 dp  '
> 	#13 [VD] len=16: b'610-0001-00 H1\x00\x00'
> 	#26 [VE] len=16: b'122310_1353 fp  '
> 	#39 [VF] len=16: b'610-0001-00 H1\x00\x00'
> 	#4c [RW] len=173: b'\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'...
>  0dff Small item 0 bytes; name 0xf End Tag
> 
> 10f3 Large item 13315 bytes; name 0x62
> !!! unknown item name 98: b'\xd0\x03\x00@`\x0c\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00'
> ===
> 
> Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>

Applied to pci/misc for v4.10, thanks, Alexey!

> ---
> Changes:
> v3:
> * unconditionally set VPD size to 8192
> 
> v2:
> * used pci_set_vpd_size() helper
> * added explicit list of IDs from cxgb3 driver
> * added a note in the commit log why the quirk is not in cxgb3
> ---
>  drivers/pci/quirks.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> index c232729..bc7c541 100644
> --- a/drivers/pci/quirks.c
> +++ b/drivers/pci/quirks.c
> @@ -3255,6 +3255,25 @@ DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_CACTUS_RIDGE_4C
>  DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_PORT_RIDGE,
>  			quirk_thunderbolt_hotplug_msi);
>  
> +static void quirk_chelsio_extend_vpd(struct pci_dev *dev)
> +{
> +	pci_set_vpd_size(dev, 8192);
> +}
> +
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x20, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x21, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x22, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x23, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x24, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x25, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x26, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x30, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x31, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x32, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x35, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x36, quirk_chelsio_extend_vpd);
> +DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_CHELSIO, 0x37, quirk_chelsio_extend_vpd);
> +
>  #ifdef CONFIG_ACPI
>  /*
>   * Apple: Shutdown Cactus Ridge Thunderbolt controller.
> -- 
> 2.5.0.rc3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-pci" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
