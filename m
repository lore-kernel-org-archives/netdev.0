From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH] igb: fix kexec with igb
Date: Sun, 08 Mar 2009 11:10:11 -0700
Message-ID: <49B40A03.7060703@kernel.org>
References: <49B1F934.5050006@kernel.org> <4807377b0903062318q15ba52a7n82d4c9399b8a7fa8@mail.gmail.com> <86802c440903062331j22aa57c7r93c84da880a8e572@mail.gmail.com> <200903081157.37139.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:56414 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751647AbZCHSLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Mar 2009 14:11:10 -0400
In-Reply-To: <200903081157.37139.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki wrote:
> On Saturday 07 March 2009, Yinghai Lu wrote:
>> On Fri, Mar 6, 2009 at 11:18 PM, Jesse Brandeburg
>> <jesse.brandeburg@gmail.com> wrote:
>>> On Fri, Mar 6, 2009 at 8:33 PM, Yinghai Lu <yinghai@kernel.org> wrote:
>>>> Impact: could probe igb
>>>>
>>>> Found one system with 82575EB, in the kernel that is kexeced, probe igb
>>>> failed with -2.
>>>>
>>>> it looks like the same behavior happened on forcedeth.
>>>>
>>>> try to check system_state to make sure if put it on D3
>>>>
>>>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>>>>
>>>> ---
>>>>  drivers/net/igb/igb_main.c |   19 ++++++++++++++-----
>>>>  1 file changed, 14 insertions(+), 5 deletions(-)
>>> I see the point of the patch, but I know for a fact that ixgbe when
>>> enabled for MSI-X also doesn't work with kexec.
>>>
>>> so my questions are:
>>> are you going to change every driver?
>> i tend to only change driver that i have related HW.
>>
>>> why can't this be fixed in core kernel code instead?
>> will check it.
>>
>>> Shouldn't pci_enable_device take it out of D3?
>>> Or maybe it should be taken out of D3 immediately if someone tries to
>>> ioremap any of the BARx registers?
>>
>> looks like second kernel can not detect the state any more.
> 
> In fact pci_enable_device() calls pci_set_power_state(dev, PCI_D0) as the first
> thing.  The question is why it doesn't work as expected.

not sure... please check the version for forcedeth that you made.

commit 3cb5599a84c557c0dd9a19feb63a3788268cf249
Author: Rafael J. Wysocki <rjw@sisk.pl>
Date:   Fri Sep 5 14:00:19 2008 -0700

    forcedeth: fix kexec regression
    
    Fix regression tracked as http://bugzilla.kernel.org/show_bug.cgi?id=11361
    and caused by commit f735a2a1a4f2a0f5cd823ce323e82675990469e2 ("[netdrvr]
    forcedeth: setup wake-on-lan before shutting down") that makes network
    adapters integrated into the NVidia MCP55 chipsets fail to work in kexeced
    kernels.  The problem appears to be that if the adapter is put into D3_hot
    during ->shutdown(), it cannot be brought back into D0 after kexec (ref.
    http://marc.info/?l=linux-kernel&m=121900062814967&w=4).  Therefore, only
    put forcedeth into D3 during ->shutdown() if the system is to be powered
    off.
    
    Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
    Tested-by: Yinghai Lu <yhlu.kernel@gmail.com>
    Cc: Ayaz Abdulla <aabdulla@nvidia.com>
    Acked-by: Jeff Garzik <jeff@garzik.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 331b86b..0b6ecef 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5975,10 +5975,12 @@ static void nv_shutdown(struct pci_dev *pdev)
        if (netif_running(dev))
                nv_close(dev);
 
-       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
-       pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
        pci_disable_device(pdev);
-       pci_set_power_state(pdev, PCI_D3hot);
+       if (system_state == SYSTEM_POWER_OFF) {
+               if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
+                       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
+               pci_set_power_state(pdev, PCI_D3hot);
+       }
 }
 #else
 #define nv_suspend NULL

