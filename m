From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-2.6 PATCH] e1000e: enable/disable ASPM L0s and L1 and ERT
 according to hardware errata
Date: Thu, 29 Apr 2010 10:19:56 -0700
Message-ID: <8DD2590731AB5D4C9DBF71A877482A9062274501@orsmsx509.amr.corp.intel.com>
References: <20100427133232.25490.92973.stgit@localhost.localdomain>
 <20100429074606.GA12437@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	Matthew Garret <mjg@redhat.com>
To: Anton Blanchard <anton@samba.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3401 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932530Ab0D3Q7a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 12:59:30 -0400
In-Reply-To: <20100429074606.GA12437@kryten>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, April 29, 2010 12:46 AM, Anton Blanchard wrote:
> This oopses on one of my ppc64 boxes with a NULL pointer (0x4a):
> 
> Unable to handle kernel paging request for data at address 0x0000004a
> Faulting instruction address: 0xc0000000004d2f1c
> cpu 0xe: Vector: 300 (Data Access) at [c000000bec1833a0]
>     pc: c0000000004d2f1c: .e1000e_disable_aspm+0xe0/0x150
>     lr: c0000000004d2f0c: .e1000e_disable_aspm+0xd0/0x150
>    dar: 4a
> 
> [c000000bec1836d0] c00000000069b9d8 .e1000_probe+0x84/0xe8c
> [c000000bec1837b0] c000000000386d90 .local_pci_probe+0x4c/0x68
> [c000000bec183840] c0000000003872ac .pci_device_probe+0xfc/0x148
> [c000000bec183900] c000000000409e8c .driver_probe_device+0xe4/0x1d0
> [c000000bec1839a0] c00000000040a024 .__driver_attach+0xac/0xf4
> [c000000bec183a40] c000000000409124 .bus_for_each_dev+0x9c/0x10c
> [c000000bec183b00] c000000000409c1c .driver_attach+0x40/0x60
> [c000000bec183b90] c0000000004085dc .bus_add_driver+0x150/0x328
> [c000000bec183c40] c00000000040a58c .driver_register+0x100/0x1c4
> [c000000bec183cf0] c00000000038764c .__pci_register_driver+0x78/0x128
> 
> Seems like pdev->bus->self == NULL. I haven't touched pci in a long
> time 
> so I'm trying to remember what this means (no pcie bridge perhaps?)
> 
> The patch below fixes the oops for me.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
> 
> Index: linux-2.6.34-rc5/drivers/net/e1000e/netdev.c
> ===================================================================
> --- linux-2.6.34-rc5.orig/drivers/net/e1000e/netdev.c	2010-04-29
> 00:10:58.000000000 -0500 +++
> linux-2.6.34-rc5/drivers/net/e1000e/netdev.c	2010-04-29
>  	02:20:50.000000000 -0500 @@ -4633,6 +4633,9 @@ reg16 &= ~state;
>  	pci_write_config_word(pdev, pos + PCI_EXP_LNKCTL, reg16);
> 
> +	if (!pdev->bus->self)
> +		return;
> +
>  	pos = pci_pcie_cap(pdev->bus->self);
>  	pci_read_config_word(pdev->bus->self, pos + PCI_EXP_LNKCTL, &reg16);
>  	reg16 &= ~state;

Your patch is probably the correct thing to do but I'm not all that familiar with the ppc64 architecture.  Would you please provide the output of 'lspci -t' and 'lspci -vvv -xxx'.

Thanks,
Bruce.