From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [2.6.25-rc2] e100: Trying to free already-free
 IRQ 11 during suspend ...
Date: Thu, 21 Feb 2008 10:33:11 -0800
Message-ID: <47BDC3E7.8040807@intel.com>
References: <200802171536.51695.arvidjaar@mail.ru>
	<20080218050113.1b4b0897.akpm@linux-foundation.org>
	<47BB0F76.1040808@intel.com> <47BC725C.3060400@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010908010909040402090807"
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Andrey Borzenkov <arvidjaar@mail.ru>, linux-kernel@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <47BC725C.3060400@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010908010909040402090807
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Kok, Auke wrote:
> Kok, Auke wrote:
>> Andrew Morton wrote:
>>> On Sun, 17 Feb 2008 15:36:50 +0300 Andrey Borzenkov <arvidjaar@mail.ru> wrote:
>>>
>>>> ... and possibly reboot/poweroff (it flows by too fast to be legible).
>>>>
>>>> [ 8803.850634] ACPI: Preparing to enter system sleep state S3
>>>> [ 8803.853141] Suspending console(s)
>>>> [ 8805.287505] serial 00:09: disabled
>>>> [ 8805.291564] Trying to free already-free IRQ 11
>>>> [ 8805.291579] Pid: 6920, comm: pm-suspend Not tainted 2.6.25-rc2-1avb #2
>>>> [ 8805.291628]  [<c0152127>] free_irq+0xb7/0x130
>>>> [ 8805.291675]  [<c024bd80>] e100_suspend+0xc0/0x100
>>>> [ 8805.291724]  [<c01eaa36>] pci_device_suspend+0x26/0x70
>>>> [ 8805.291747]  [<c0243674>] suspend_device+0x94/0xd0
>>>> [ 8805.291763]  [<c02439a3>] device_suspend+0x153/0x240
>>>> [ 8805.291784]  [<c014314f>] suspend_devices_and_enter+0x4f/0xf0
>>>> [ 8805.291808]  [<c0143a5f>] ? freeze_processes+0x3f/0x80
>>>> [ 8805.291825]  [<c01432fa>] enter_state+0xaa/0x140
>>>> [ 8805.291840]  [<c014341f>] state_store+0x8f/0xd0
>>>> [ 8805.291852]  [<c0143390>] ? state_store+0x0/0xd0
>>>> [ 8805.291866]  [<c01d3404>] kobj_attr_store+0x24/0x30
>>>> [ 8805.291901]  [<c01b547b>] sysfs_write_file+0xbb/0x110
>>>> [ 8805.291936]  [<c0177d79>] vfs_write+0x99/0x130
>>>> [ 8805.291963]  [<c01b53c0>] ? sysfs_write_file+0x0/0x110
>>>> [ 8805.291979]  [<c01782fd>] sys_write+0x3d/0x70
>>>> [ 8805.291998]  [<c010409a>] sysenter_past_esp+0x5f/0xa5
>>>> [ 8805.292038]  =======================
>>>> [ 8805.347640] ACPI: PCI interrupt for device 0000:00:06.0 disabled
>>>> [ 8805.361128] ACPI: PCI interrupt for device 0000:00:02.0 disabled
>>>> [ 8805.376670]  hwsleep-0322 [00] enter_sleep_state     : Entering sleep state [S3]
>>>> [ 8805.376670] Back to C!
>>>>
>>>> Interface is unused normally (only for netconsole sometimes). dmesg and config
>>>> attached.
>>> Does reverting this:
>>>
>>> commit 8543da6672b0994921f014f2250e27ae81645580
>>> Author: Auke Kok <auke-jan.h.kok@intel.com>
>>> Date:   Wed Dec 12 16:30:42 2007 -0800
>>>
>>>     e100: free IRQ to remove warningwhenrebooting
>>>     
>>> with this patch:
>>>
>>> --- a/drivers/net/e100.c~revert-1
>>> +++ a/drivers/net/e100.c
>>> @@ -2804,9 +2804,8 @@ static int e100_suspend(struct pci_dev *
>>>  		pci_enable_wake(pdev, PCI_D3cold, 0);
>>>  	}
>>>  
>>> -	free_irq(pdev->irq, netdev);
>>> -
>>>  	pci_disable_device(pdev);
>>> +	free_irq(pdev->irq, netdev);
>>>  	pci_set_power_state(pdev, PCI_D3hot);
>>>  
>>>  	return 0;
>>> @@ -2848,8 +2847,6 @@ static void e100_shutdown(struct pci_dev
>>>  		pci_enable_wake(pdev, PCI_D3cold, 0);
>>>  	}
>>>  
>>> -	free_irq(pdev->irq, netdev);
>>> -
>>>  	pci_disable_device(pdev);
>>>  	pci_set_power_state(pdev, PCI_D3hot);
>>>  }
>>> _
>>>
>>> fix it?
>>>
>>>> Hmm ... after resume device has disappeared at all ...
>>>>
>>>> {pts/1}% cat /proc/interrupts
>>>>            CPU0
>>>>   0:    1290492    XT-PIC-XT        timer
>>>>   1:       6675    XT-PIC-XT        i8042
>>>>   2:          0    XT-PIC-XT        cascade
>>>>   3:          2    XT-PIC-XT
>>>>   4:          2    XT-PIC-XT
>>>>   5:          3    XT-PIC-XT
>>>>   7:          4    XT-PIC-XT        irda0
>>>>   8:          0    XT-PIC-XT        rtc0
>>>>   9:        583    XT-PIC-XT        acpi
>>>>  10:          2    XT-PIC-XT
>>>>  11:      31483    XT-PIC-XT        yenta, yenta, yenta, ohci_hcd:usb1, ALI 5451, pcmcia0.0
>>>>  12:      28070    XT-PIC-XT        i8042
>>>>  14:      21705    XT-PIC-XT        ide0
>>>>  15:      82123    XT-PIC-XT        ide1
>>>> NMI:          0   Non-maskable interrupts
>>>> TRM:          0   Thermal event interrupts
>>>> SPU:          0   Spurious interrupts
>>>> ERR:          0
>>> I hope that's not a separate bug...
>> I'll take a look at this as well. thanks for reporting.
> 
> ok, I just had a repro - on a regular shutdown even.
> 
> this always worked before - I'm not blaming anything yet but something in the pci
> shutdown code must now be freeing our irq for us (I'm not using anything fancy to
> autoconfigure my network here).
> 
> I definately do not see this with 2.6.24 either.

can you try this patch please? It rewrites e100 to do suspend/shutdown just like
e1000e does, which is much more tested than anything else. I don't get the IRQ
message anymore - but I haven't gotten to testing suspend/resume just yet.


Auke

--------------010908010909040402090807
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------010908010909040402090807
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--------------010908010909040402090807--
