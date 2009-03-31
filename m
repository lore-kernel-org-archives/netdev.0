From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] PCI: Fix oops in pci_vpd_truncate
Date: Tue, 31 Mar 2009 15:53:09 -0700
Message-ID: <20090331155309.5d39e6a8@nehalam>
References: <20090331222341.GA16479@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35987 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763987AbZCaWxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2009 18:53:12 -0400
In-Reply-To: <20090331222341.GA16479@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Apr 2009 02:23:41 +0400
Anton Vorontsov <avorontsov@ru.mvista.com> wrote:

> pci_vpd_truncate() should check for dev->vpd->attr, otherwise
> this might happen:
> 
> sky2 driver version 1.22
> Unable to handle kernel paging request for data at address 0x0000000c
> Faulting instruction address: 0xc01836fc
> Oops: Kernel access of bad area, sig: 11 [#1]
> [...]
> NIP [c01836fc] pci_vpd_truncate+0x38/0x40
> LR [c029be18] sky2_probe+0x14c/0x518
> Call Trace:
> [ef82bde0] [c029bda4] sky2_probe+0xd8/0x518 (unreliable)
> [ef82be20] [c018a11c] local_pci_probe+0x24/0x34
> [ef82be30] [c018a14c] pci_call_probe+0x20/0x30
> [ef82be50] [c018a330] __pci_device_probe+0x64/0x78
> [ef82be60] [c018a44c] pci_device_probe+0x30/0x58
> [ef82be80] [c01aa270] really_probe+0x78/0x1a0
> [ef82bea0] [c01aa460] __driver_attach+0xa4/0xa8
> [ef82bec0] [c01a96ac] bus_for_each_dev+0x60/0x9c
> [ef82bef0] [c01aa0b4] driver_attach+0x24/0x34
> [ef82bf00] [c01a9e08] bus_add_driver+0x12c/0x1cc
> [ef82bf20] [c01aa87c] driver_register+0x6c/0x110
> [ef82bf30] [c018a770] __pci_register_driver+0x4c/0x9c
> [ef82bf50] [c03782c8] sky2_init_module+0x30/0x40
> [ef82bf60] [c0001dbc] do_one_initcall+0x34/0x1a0
> [ef82bfd0] [c0362240] do_initcalls+0x38/0x58
> 
> This happens with CONFIG_SKY2=y, and "ip=on" kernel command line, so
> pci_vpd_truncate() is called before late_initcall(pci_sysfs_init),
> therefore ->attr isn't yet initialized.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

If you are doing this you will never get sky2 vpd pci access,
but that is not a big loss. I worry that other thing could break if
devices are getting initialized before sysfs. Drivers that create sysfs
entries (like the 10G drivers) could also break?

But this is okay as a provisional step, the sysfs startup order
needs to be fixed.
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
