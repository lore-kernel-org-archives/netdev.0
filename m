From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Tue, 27 May 2008 08:21:53 +0200
Message-ID: <20080527062153.GA3651@yamamaya.is-a-geek.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org> <20080518150908.GA4606@yamamaya.is-a-geek.org> <20080525150444.GA29739@yamamaya.is-a-geek.org> <20080525181329.GA5044@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Davi
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:40343 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753661AbYE0GW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 02:22:28 -0400
Content-Disposition: inline
In-Reply-To: <20080525181329.GA5044@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Diedrich wrote:
> Tobias Diedrich wrote:
> > So my BIOS is not as borked as I thought and it should be possible
> > to wake up the machine even with platform.  Further debugging will
> > have to wait until at least next weekend though (maybe longer)...
> 
> Or maybe it doesn't have to wait, I was just too curious:
> 
> Summary first: I got platform mode to work!
> 
> After grepping and reading through kernel/power/disk.c and
> (rather obfuscated) drivers/acpi/.* code, and reading up on
> ACPI _GPE (General Purpose Event?), and having a look at my DSDT I
> noticed two things:
> 
> 1) The network controllers are assigned to their own _GPE bits(pins?):
> |[...]
> |    Scope (\_GPE)
> |    {
> |[...]
> |        Method (_L0B, 0, NotSerialized)
> |        {
> |            Notify (\_SB.PCI0.MMAC, 0x02)
> |        }
> |
> |        Method (_L0A, 0, NotSerialized)
> |        {
> |            Notify (\_SB.PCI0.MAC1, 0x02)
> |        }
> |[...]
> 
> 2) drivers/acpi/sleep/proc.c registers a 'wakeup' file:
> |        proc_create("wakeup", S_IFREG | S_IRUGO | S_IWUSR,
> |                    acpi_root_dir, &acpi_system_wakeup_device_fops);
> 
> And I then remembered that someone said in
> http://bugzilla.kernel.org/show_bug.cgi?id=8381
> it works for him if he writes $MAGICVALUE into a proc file.
> 
> And yes, if I write 'MMAC' and 'MAC1' into /proc/acpi/wakeup, then
> wake-on-lan works even in platform mode.
> 
> So...
> AFAICS this bit of setup magic should not be required, because:
> 
> 1) /proc/acpi/wakeup knows which pci device is associated to each GPE bit
> |ranma@melchior:~$ cat /proc/acpi/wakeup 
> |Device	S-state	  Status   Sysfs node
> |HUB0	  S5	 disabled  pci:0000:00:06.0
> |XVR0	  S5	 disabled  
> |XVR1	  S5	 disabled  pci:0000:00:0e.0
> |XVR2	  S5	 disabled  
> |XVR3	  S5	 disabled  
> |XVR4	  S5	 disabled  
> |XVR5	  S5	 disabled  pci:0000:00:0a.0
> |UAR1	  S5	 disabled  pnp:00:09
> |PS2K	  S4	 disabled  pnp:00:0b
> |USB0	  S4	 disabled  pci:0000:00:02.0
> |USB2	  S4	 disabled  pci:0000:00:02.1
> |AZAD	  S5	 disabled  pci:0000:00:06.1
> |MMAC	  S5	 enabled   pci:0000:00:08.0
> |MAC1	  S5	 enabled   pci:0000:00:09.0
> (values after manually enabling MMAC and MAC1)
> 
> 2) kernel/power/disk.c calls hibernation_ops->enter(), which is
> acpi_suspend_enter, which calls acpi_enable_wakeup_device, which
> sets up GPE wakup bits.  This _should_ take care of enabling MMAC
> and MAC1 automatically, but apparently does not work correctly at
> some point.
> 
> I guess someone more knowledgable in ACPI stuff should have a look
> at this.

Any reason this patch hasn't made it into the kernel so far?
http://lists.laptop.org/pipermail/devel/2007-April/004691.html

(Ok, I tried getting it to apply to a current kernel, but it
a splodes (reboots instead of powering off, last message on the
serial console is "ACPI handle has no context!", see below))

The platform_enable_wakeup() hook is still there, but unused.
AFAICS this patch should solve the "'ethtool -s eth0 wol g' doesn't
suffice, I also have to write magic values into /proc/acpi/wakeup"
issue.

[14315431.627226] PM: Hibernation mode set to 'platform'
[14315431.639031] PM: Marking nosave pages: 000000000009f000 - 0000000000100000
[14315431.646879] PM: Basic memory bitmaps created
[14315431.651822] PM: Syncing filesystems ... done.
[14315431.660495] Freezing user space processes ... (elapsed 0.00 seconds) done.
[14315431.669364] Freezing remaining freezable tasks ... (elapsed 0.00 seconds) 
[14315431.677609] PM: Shrinking memory... done (0 pages freed)
[14315431.924310] PM: Freed 0 kbytes in 0.24 seconds (0.00 MB/s)
[14315431.932191] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[14315431.938679] ACPI handle has no context!
[14315432.534157] serial 00:09: activated
[14315432.539218] sd 0:0:0:0: [sda] Starting disk
[14315432.749996] PM: writing image.
[14315432.775321] PM: Free swap pages: 977947
[14315432.779662] PM: Saving image data pages (72491 pages) ... done
[14315436.437643] PM: Wrote 289964 kbytes in 3.65 seconds (79.44 MB/s)
[14315436.444385] PM: S|
[14315436.840487] ohci_hcd 0000:00:02.0: Unlink after no-IRQ?  Controller is probably using the wrong IRQ.
[14315436.854132] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[14315436.859325] sd 0:0:0:0: [sda] Stopping disk
[14315437.284158] ACPI handle has no context!
^@[    0.000000] Linux version 2.6.26-rc2 (ranma@melchior) (gcc version 4.2.3 (Debian 4.2.3-5)) #8 PREEMPT Tue May 27 00:03:20 CEST 2008
[    0.000000] Command line: root=/dev/sda5 resume=/dev/sda6 vga=6 apic=verbose console=ttyS0,115200 console=tty0 pci=nomsi no_console_suspend ro


-- 
Tobias						PGP: http://9ac7e0bc.uguu.de
このメールは十割再利用されたビットで作られています。
