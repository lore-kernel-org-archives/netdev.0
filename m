From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH] igb: fix kexec with igb
Date: Wed, 11 Mar 2009 16:37:18 -0700
Message-ID: <49B84B2E.6080701@kernel.org>
References: <49B1F934.5050006@kernel.org> <49B40A03.7060703@kernel.org> <200903082208.42957.rjw@sisk.pl> <200903082232.36660.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754092AbZCKXjg@vger.kernel.org>
In-Reply-To: <200903082232.36660.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> On Sunday 08 March 2009, Rafael J. Wysocki wrote:
>> On Sunday 08 March 2009, Yinghai Lu wrote:
>>> Rafael J. Wysocki wrote:
>>>> On Saturday 07 March 2009, Yinghai Lu wrote:
>>>>> On Fri, Mar 6, 2009 at 11:18 PM, Jesse Brandeburg
>>>>> <jesse.brandeburg@gmail.com> wrote:
>>>>>> On Fri, Mar 6, 2009 at 8:33 PM, Yinghai Lu <yinghai@kernel.org> wrote:
>>>>>>> Impact: could probe igb
>>>>>>>
>>>>>>> Found one system with 82575EB, in the kernel that is kexeced, probe igb
>>>>>>> failed with -2.
>>>>>>>
>>>>>>> it looks like the same behavior happened on forcedeth.
>>>>>>>
>>>>>>> try to check system_state to make sure if put it on D3
>>>>>>>
>>>>>>> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>>>>>>>
>>>>>>> ---
>>>>>>>  drivers/net/igb/igb_main.c |   19 ++++++++++++++-----
>>>>>>>  1 file changed, 14 insertions(+), 5 deletions(-)
>>>>>> I see the point of the patch, but I know for a fact that ixgbe when
>>>>>> enabled for MSI-X also doesn't work with kexec.
>>>>>>
>>>>>> so my questions are:
>>>>>> are you going to change every driver?
>>>>> i tend to only change driver that i have related HW.
>>>>>
>>>>>> why can't this be fixed in core kernel code instead?
>>>>> will check it.
>>>>>
>>>>>> Shouldn't pci_enable_device take it out of D3?
>>>>>> Or maybe it should be taken out of D3 immediately if someone tries to
>>>>>> ioremap any of the BARx registers?
>>>>> looks like second kernel can not detect the state any more.
>>>> In fact pci_enable_device() calls pci_set_power_state(dev, PCI_D0) as the first
>>>> thing.  The question is why it doesn't work as expected.
>>> not sure... please check the version for forcedeth that you made.
>>>
>>> commit 3cb5599a84c557c0dd9a19feb63a3788268cf249
>>> Author: Rafael J. Wysocki <rjw@sisk.pl>
>>> Date:   Fri Sep 5 14:00:19 2008 -0700
>>>
>>>     forcedeth: fix kexec regression
>>>     
>>>     Fix regression tracked as http://bugzilla.kernel.org/show_bug.cgi?id=11361
>>>     and caused by commit f735a2a1a4f2a0f5cd823ce323e82675990469e2 ("[netdrvr]
>>>     forcedeth: setup wake-on-lan before shutting down") that makes network
>>>     adapters integrated into the NVidia MCP55 chipsets fail to work in kexeced
>>>     kernels.  The problem appears to be that if the adapter is put into D3_hot
>>>     during ->shutdown(), it cannot be brought back into D0 after kexec (ref.
>>>     http://marc.info/?l=linux-kernel&m=121900062814967&w=4).  Therefore, only
>>>     put forcedeth into D3 during ->shutdown() if the system is to be powered
>>>     off.
>> Thanks, I remember now.
> 
> In which case you need to rework igb_shutdown() rather than igb_suspend().
> 
> Something like the patch below, perhaps (totally untested).

it works, David, can you picked it up

---

From: Rafael J. Wysocki <rjw@sisk.pl>

[PATCH] igb: fix kexec with igb -v2

Impact: could probe igb

Found one system with 82575EB, in the kernel that is kexeced, probe igb
failed with -2.

it looks like the same behavior happened on forcedeth.

try to check system_state to make sure if put it on D3

v2: Rafael J. Wysocki seperate igb_shutdown and igb_suspend code

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
drivers/net/igb/igb_main.c |   24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

Index: linux-2.6/drivers/net/igb/igb_main.c
===================================================================
--- linux-2.6.orig/drivers/net/igb/igb_main.c
+++ linux-2.6/drivers/net/igb/igb_main.c
@@ -4299,7 +4299,7 @@ int igb_set_spd_dplx(struct igb_adapter
 }
 
 
-static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
+static int __igb_shutdown(struct pci_dev *pdev, bool enable_wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
@@ -4359,7 +4359,7 @@ static int igb_suspend(struct pci_dev *p
 	}
 
 	/* make sure adapter isn't asleep if manageability/wol is enabled */
-	if (wufc || adapter->en_mng_pt) {
+	if ((wufc || adapter->en_mng_pt) && enable_wake) {
 		pci_enable_wake(pdev, PCI_D3hot, 1);
 		pci_enable_wake(pdev, PCI_D3cold, 1);
 	} else {
@@ -4374,12 +4374,21 @@ static int igb_suspend(struct pci_dev *p
 
 	pci_disable_device(pdev);
 
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-
 	return 0;
 }
 
 #ifdef CONFIG_PM
+static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	int retval;
+
+	retval = __igb_shutdown(pdev, true);
+	if (!retval)
+		pci_set_power_state(pdev, PCI_D3hot);
+
+	return retval;
+}
+
 static int igb_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -4434,7 +4443,12 @@ static int igb_resume(struct pci_dev *pd
 
 static void igb_shutdown(struct pci_dev *pdev)
 {
-	igb_suspend(pdev, PMSG_SUSPEND);
+	if (system_state == SYSTEM_POWER_OFF) {
+		__igb_shutdown(pdev, true);
+		pci_set_power_state(pdev, PCI_D3hot);
+	} else {
+		__igb_shutdown(pdev, false);
+	}
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
