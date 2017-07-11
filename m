From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: fix BUG() on interrupt deallocating path of
 ULD
Date: Tue, 11 Jul 2017 13:40:57 -0700 (PDT)
Message-ID: <20170711.134057.496510914490251148.davem@davemloft.net>
References: <20170710135546.350-1-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, atul.gupta@chelsio.com,
        ganeshgr@chelsio.com, swise@chelsio.com
To: gpiccoli@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41706 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933210AbdGKUk6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 16:40:58 -0400
In-Reply-To: <20170710135546.350-1-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Date: Mon, 10 Jul 2017 10:55:46 -0300

> Since the introduction of ULD (Upper-Layer Drivers), the MSI-X
> deallocating path changed in cxgb4: the driver frees the interrupts
> of ULD when unregistering it or on shutdown PCI handler.
> 
> Problem is that if a MSI-X is not freed before deallocated in the PCI
> layer, it will trigger a BUG() due to still "alive" interrupt being
> tentatively quiesced.
> 
> The below trace was observed when doing a simple unbind of Chelsio's
> adapter PCI function, like:
>   "echo 001e:80:00.4 > /sys/bus/pci/drivers/cxgb4/unbind"
> 
> Trace:
> 
>   kernel BUG at drivers/pci/msi.c:352!
>   Oops: Exception in kernel mode, sig: 5 [#1]
>   ...
>   NIP [c0000000005a5e60] free_msi_irqs+0xa0/0x250
>   LR [c0000000005a5e50] free_msi_irqs+0x90/0x250
>   Call Trace:
>   [c0000000005a5e50] free_msi_irqs+0x90/0x250 (unreliable)
>   [c0000000005a72c4] pci_disable_msix+0x124/0x180
>   [d000000011e06708] disable_msi+0x88/0xb0 [cxgb4]
>   [d000000011e06948] free_some_resources+0xa8/0x160 [cxgb4]
>   [d000000011e06d60] remove_one+0x170/0x3c0 [cxgb4]
>   [c00000000058a910] pci_device_remove+0x70/0x110
>   [c00000000064ef04] device_release_driver_internal+0x1f4/0x2c0
>   ...
> 
> This patch fixes the issue by refactoring the shutdown path of ULD on
> cxgb4 driver, by properly freeing and disabling interrupts on PCI
> remove handler too.
> 
> Fixes: 0fbc81b3ad51 ("Allocate resources dynamically for all cxgb4 ULD's")
> Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>

Applied and queued up for -stable, thanks.
