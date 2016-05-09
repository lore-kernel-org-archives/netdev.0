From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: rtk8168 driver help needed
Date: Mon, 9 May 2016 13:25:07 -0400
Message-ID: <5730C7F3.6030905@ti.com>
References: <572D147C.8020203@ti.com>
 <20160507083511.GA18421@electric-eye.fr.zoreil.com> <5730A4B0.7000606@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42384 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835AbcEIRZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 13:25:04 -0400
In-Reply-To: <5730A4B0.7000606@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2016 10:54 AM, Murali Karicheri wrote:
> Francois,
> 
> Thanks for responding.
> 
> On 05/07/2016 04:35 AM, Francois Romieu wrote:
>> Murali Karicheri <m-karicheri2@ti.com> :
>> [...]
>>> I am trying to integrate the rtl8168 PCIe card to have Ethernet functional
>>> on my Keystone EVM.
>>
>> Which (EVM) one ?
> K2G EVM. This is a new EVM for which work has been started to add it to upstream
> kernel. But it not there yet. The PCIe h/w in the K2G SoC is a re-use from
> existing SoC such as K2E. The PCIe controller (Root complex a.k.a RC) driver
> based on this PCIe h/w works fine on K2E EVM with a Marvel SATA controller
> connected to the PCIe port. On K2G EVM, I have a PCIe slot to which I have
> plugged the rtl8168 PCIe card and power on with the log I had sent you. The
> serdes driver is responsible for link setup seems to work fine, link is up and
> could detect the rtl8168 below.
>>
>>> I purchased the rtl8111c Gib card from Amazon. The Card is detected
>>> by the RC and I can see it is enumerated and show up when doing lspci command.
>>
>> What does "the RC" mean ? A different PC ?
> 
> RC - Root Complex (PCIe controller - drivers/pci/host/pci-keystone.c, a designware
> based PCIe controller driver)
> 
> The the PCIe controller driver bindings...
> 
>                 pcie0_phy: phy@2320000 {
>                         #phy-cells = <0>;
>                         compatible = "ti,keystone-serdes-pcie";
>                         reg = <0x02320000 0x4000>;
>                         link-rate-kbps = <5000000>;
>                         num-lanes = <1>;
>                         status = "disabled";
>                 };
> 
>                 pcie0: pcie@21800000 {
>                         compatible = "ti,keystone-pcie", "snps,dw-pcie";
>                         power-domains = <&k2g_pds K2G_DEV_PCIE0>;
>                         clocks = <&k2g_clks K2G_DEV_PCIE0 K2G_DEV_PCIE_VBUS_CLK>;
>                         clock-names = "pcie";
>                         #address-cells = <3>;
>                         #size-cells = <2>;
>                         reg =  <0x21801000 0x2000>, <0x21800000 0x1000>, <0x02620128 4>;
>                         ranges = <0x81000000 0 0 0x23250000 0 0x4000
>                                 0x82000000 0 0x50000000 0x50000000 0 0x10000000>;
> 
>                         status = "disabled";
>                         device_type = "pci";
>                         num-lanes = <1>;
>                         phys = <&pcie0_phy>;
> 
>                         #interrupt-cells = <1>;
>                         interrupt-map-mask = <0 0 0 7>;
>                         interrupt-map = <0 0 0 1 &pcie_intc0 0>, /* INT A */
>                                         <0 0 0 2 &pcie_intc0 1>, /* INT B */
>                                         <0 0 0 3 &pcie_intc0 2>, /* INT C */
>                                         <0 0 0 4 &pcie_intc0 3>; /* INT D */
>                         pcie_msi_intc0: msi-interrupt-controller {
>                                 interrupt-controller;
>                                 #interrupt-cells = <1>;
>                                 interrupt-parent = <&gic>;
>                                 interrupts = <GIC_SPI 30 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 31 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 32 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 33 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 34 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 35 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 36 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 37 IRQ_TYPE_EDGE_RISING>;
>                         };
> 
>                         pcie_intc0: legacy-interrupt-controller {
>                                 interrupt-controller;
>                                 #interrupt-cells = <1>;
>                                 interrupt-parent = <&gic>;
>                                 interrupts = <GIC_SPI 26 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 27 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 28 IRQ_TYPE_EDGE_RISING>,
>                                         <GIC_SPI 29 IRQ_TYPE_EDGE_RISING>;
>                         };
>                 };
> 
> 
>>
>>> However I can't get the Ethernet port functional.
>>
>>> Does this need MSI interrupt ?
>>
>> No.
> 
> Does it also work with MSI?? Is there anything to be set in the driver
> to request MSI interrupt?
> 
>>
>>> I can't see it has requested any.
>>
>> Yes, something went really, really wrong. See below.
>>
>> [...]
>>> [    2.303965] PCI host bridge /soc/pcie@21800000 ranges:
>>> [    2.309108]   No bus range found for /soc/pcie@21800000, using [bus 00-ff]
>>> [    2.316269]    IO 0x23250000..0x23253fff -> 0x00000000
>>> [    2.321499]   MEM 0x50000000..0x5fffffff -> 0x50000000
>>> [    2.331666] keystone-pcie 21801000.pcie: PCI host bridge to bus 0000:00
>>> [    2.338283] pci_bus 0000:00: root bus resource [bus 00-ff]
>>> [    2.343937] pci_bus 0000:00: root bus resource [io  0x0000-0x3fff]
>>> [    2.350114] pci_bus 0000:00: root bus resource [mem 0x50000000-0x5fffffff]
>>> [    2.357095] pci 0000:00:00.0: [104c:b00b] type 01 class 0x060400
>>> [    2.357665] PCI: bus0: Fast back to back transfers disabled
>>> [    2.363717] pci 0000:01:00.0: [10ec:8168] type 00 class 0x020000
>>> [    2.363809] pci 0000:01:00.0: reg 0x10: [io  0x0000-0x00ff]
>>> [    2.363867] pci 0000:01:00.0: reg 0x18: [mem 0x00000000-0x00000fff 64bit]
>>> [    2.363909] pci 0000:01:00.0: reg 0x20: [mem 0x00000000-0x0000ffff 64bit pref]
>>> [    2.363939] pci 0000:01:00.0: reg 0x30: [mem 0x00000000-0x0001ffff pref]
>>> [    2.364099] pci 0000:01:00.0: supports D1 D2
>>> [    2.364116] pci 0000:01:00.0: PME# supported from D0 D1 D2 D3hot D3cold
>>> [    2.381251] PCI: bus1: Fast back to back transfers disabled
>>> [    2.386989] pci 0000:00:00.0: BAR 8: assigned [mem 0x50000000-0x500fffff]
>>> [    2.393937] pci 0000:00:00.0: BAR 9: assigned [mem 0x50100000-0x501fffff pref]
>>> [    2.401221] pci 0000:00:00.0: BAR 7: assigned [io  0x1000-0x1fff]
>>> [    2.407320] pci 0000:01:00.0: BAR 6: assigned [mem 0x50100000-0x5011ffff pref]
>>> [    2.414597] pci 0000:01:00.0: BAR 4: assigned [mem 0x50120000-0x5012ffff 64bit pref]
>>> [    2.422380] pci 0000:01:00.0: BAR 2: assigned [mem 0x50000000-0x50000fff 64bit]
>>> [    2.429702] pci 0000:01:00.0: BAR 0: assigned [io  0x1000-0x10ff]
>>> [    2.435821] pci 0000:00:00.0: PCI bridge to [bus 01]
>>> [    2.440783] pci 0000:00:00.0:   bridge window [io  0x1000-0x1fff]
>>> [    2.446896] pci 0000:00:00.0:   bridge window [mem 0x50000000-0x500fffff]
>>> [    2.453699] pci 0000:00:00.0:   bridge window [mem 0x50100000-0x501fffff pref]
>>> [    2.461453] pcieport 0000:00:00.0: Signaling PME through PCIe PME interrupt
>>> [    2.468411] pci 0000:01:00.0: Signaling PME through PCIe PME interrupt
>>> [    2.475075] pcie_pme 0000:00:00.0:pcie01: service driver pcie_pme loaded
>>> [    2.475392] aer 0000:00:00.0:pcie02: service driver aer loaded
>>> [    2.475652] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>>> [    2.481419] r8169 0000:01:00.0: enabling device (0140 -> 0143)
>>> [    2.488865] r8169 0000:01:00.0 eth0: RTL8169 at 0xf0d6a000, 00:00:00:00:00:00, XID 00000000 IRQ 286
>>
>> No need to go further, there is a serious problem here.
>>
>> Most of the XID bits are read from a mapped register. They're definitely not
>> expected to be null as the driver requires it to identify a proper chipset
>> (the common PCI configuration registers only tell that you aren't dealing
>> with a coffee machine).
> 
> Looks like during enumeration, the PCIe controller has correctly read the
> Device ID a and Vendor ID over the PCIe bus. So the bus access is happening
> at least to read the common PCI configuration space. But then what you are
> confirming is the mapped XID register is not accessed correctly and is reading
> zeors. Right? I will try to debug this first before proceeding any further.
> 

One difference between the BAR logs w.r.t Marvel controller on K2E EVM is that
the BARs are showing up as 64bit instead of 32bit.

Marvell controller
==================
[    0.236353] pci 0000:00:00.0: BAR 8: assigned [mem 0x60000000-0x600fffff]
[    0.236364] pci 0000:00:00.0: BAR 9: assigned [mem 0x60100000-0x601fffff pref]
[    0.236373] pci 0000:00:00.0: BAR 7: assigned [io  0x1000-0x1fff]
[    0.236385] pci 0000:01:00.0: BAR 6: assigned [mem 0x60100000-0x6010ffff pref]
[    0.236394] pci 0000:01:00.0: BAR 5: assigned [mem 0x60000000-0x600001ff]
[    0.236406] pci 0000:01:00.0: BAR 4: assigned [io  0x1000-0x100f]
[    0.236418] pci 0000:01:00.0: BAR 0: assigned [io  0x1010-0x1017]
[    0.236429] pci 0000:01:00.0: BAR 2: assigned [io  0x1018-0x101f]
[    0.236441] pci 0000:01:00.0: BAR 1: assigned [io  0x1020-0x1023]
[    0.236452] pci 0000:01:00.0: BAR 3: assigned [io  0x1024-0x1027]
[    0.236464] pci 0000:00:00.0: PCI bridge to [bus 01]
[    0.236472] pci 0000:00:00.0:   bridge window [io  0x1000-0x1fff]
[    0.236481] pci 0000:00:00.0:   bridge window [mem 0x60000000-0x600fffff]
[    0.236490] pci 0000:00:00.0:   bridge window [mem 0x60100000-0x601fffff pref]

Realtek
=========
[    2.311572] keystone-pcie 21801000.pcie: PCI host bridge to bus 0000:00
[    2.318188] pci_bus 0000:00: root bus resource [bus 00-ff]
[    2.323844] pci_bus 0000:00: root bus resource [io  0x0000-0x3fff]
[    2.330023] pci_bus 0000:00: root bus resource [mem 0x50000000-0x5fffffff]
[    2.337567] PCI: bus0: Fast back to back transfers disabled
[    2.361159] PCI: bus1: Fast back to back transfers disabled
[    2.366889] pci 0000:00:00.0: BAR 8: assigned [mem 0x50000000-0x500fffff]
[    2.373841] pci 0000:00:00.0: BAR 9: assigned [mem 0x50100000-0x501fffff pref]
[    2.381061] pci 0000:00:00.0: BAR 7: assigned [io  0x1000-0x1fff]
[    2.387225] pci 0000:01:00.0: BAR 6: assigned [mem 0x50100000-0x5011ffff pref]
[    2.394505] pci 0000:01:00.0: BAR 4: assigned [mem 0x50120000-0x5012ffff 64bit pref]
[    2.402288] pci 0000:01:00.0: BAR 2: assigned [mem 0x50000000-0x50000fff 64bit]
[    2.409610] pci 0000:01:00.0: BAR 0: assigned [io  0x1000-0x10ff]
[    2.415729] pci 0000:00:00.0: PCI bridge to [bus 01]
[    2.420693] pci 0000:00:00.0:   bridge window [io  0x1000-0x1fff]
[    2.426806] pci 0000:00:00.0:   bridge window [mem 0x50000000-0x500fffff]
[    2.433610] pci 0000:00:00.0:   bridge window [mem 0x50100000-0x501fffff pref]

Probably access to config space is happening in 64bit and it just get zeros?
Trying to see how does PCI core determine if the access is 64bit. If you have a
clue please let me know.

Murali
> Thanks.
> 
> Murali
>  
>> Any read returning zeroes would not surprize me.
>>
>> [...]
>>> Can someone help me figure out what is missing ?
>>
>> Hardly at this point. I can only suggest to switch power off, plug
>> the 8168 device in a x86 (32 or 64 bits) system and check how it behaves.
>>
> I need to continue work with my EVM as I have to make it functional.
> 
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
