From: Pavel Machek <pavel@ucw.cz>
Subject: Re: e1000e on thinkpad x60: interrupt problem
Date: Tue, 9 Jul 2013 19:02:42 +0200
Message-ID: <20130709170242.GA14112@amd.pavel.ucw.cz>
References: <20130709010500.GA21248@amd.pavel.ucw.cz>
	<D38E8E86660E514AB505863C19C9287C73E60E70@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ronciak, John" <john.ronciak@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <D38E8E86660E514AB505863C19C9287C73E60E70@ORSMSX102.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi!

> Nothing appears to be wrong.  If the system is seeing ping packets
>at all means that device is generating interrupts and that they are
>being processed.  If you are looking at performance then sharing

No, that's not true. There is other interrupt load, and e1000e has big
enough buffers; that means that packets eventually get processed. I
strongly suspect e1000e generates little or no interrupts and packets
only get processed when other devices on shared interrupt line
generate interrupt. 

>interrupts is probably not a good idea.  Since you are on a laptop it
>may not be easy to separate the networking device onto its own
>interrupt.  The interrupt is shared with a lot of other devices and
>not just ahci.

Yes, it is wrong. 100msec latency on unloaded core duo is not
right... and notice how ping latency goes _down_ when I load the other
devices.

[100msec latency is so big that it makes interactive work over
ssh hard.]

IOW if the interrupt was not shared, I'd be getting latencies in one
second range. It happened before on this machine, and other x60 users
are seing that, too.

It may have something to do with ASPM, because hack below makes
latencies lower than 2msec. (And btw shared interrupt load does not
make them worse in a way that can be measured; it stays <2msec with
AHCI load.)

Any ideas for acceptable solution?

								Pavel

diff --git a/.config b/.config
index 149f713..d7f5a11 100644
--- a/.config
+++ b/.config
@@ -559,9 +559,9 @@ CONFIG_PCIEAER=y
 # CONFIG_PCIEAER_INJECT is not set
 CONFIG_PCIEASPM=y
 CONFIG_PCIEASPM_DEBUG=y
-CONFIG_PCIEASPM_DEFAULT=y
+# CONFIG_PCIEASPM_DEFAULT is not set
 # CONFIG_PCIEASPM_POWERSAVE is not set
-# CONFIG_PCIEASPM_PERFORMANCE is not set
+CONFIG_PCIEASPM_PERFORMANCE=y
 CONFIG_PCIE_PME=y
 CONFIG_ARCH_SUPPORTS_MSI=y
 # CONFIG_PCI_MSI is not set
index e4b1fb2..9a1b63e 100644
--- a/drivers/pci/pci-acpi.c
+++ b/drivers/pci/pci-acpi.c
@@ -382,7 +382,7 @@ static int __init acpi_pci_init(void)
 
 	if (acpi_gbl_FADT.boot_flags & ACPI_FADT_NO_ASPM) {
 		printk(KERN_INFO"ACPI FADT declares the system doesn't support PCIe ASPM, so disable it\n");
-		pcie_no_aspm();
+//		pcie_no_aspm();
 	}
 
 	ret = register_acpi_bus_type(&acpi_pci_bus);


> > Interrupts are like this:
> > 
> > pavel@amd:/data/l/linux-good$ cat /proc/interrupts
> >            CPU0       CPU1
> >   0:   95454037       5192   IO-APIC-edge      timer
> >   1:      16292         20   IO-APIC-edge      i8042
> >   3:          9          0   IO-APIC-edge
> >   4:          9          0   IO-APIC-edge
> >   7:          0          0   IO-APIC-edge      parport0
> >   8:          1          0   IO-APIC-edge      rtc0
> >   9:   19471974       1207   IO-APIC-fasteoi   acpi
> >  12:     168092         15   IO-APIC-edge      i8042
> >  14:    3568551        165   IO-APIC-edge      ata_piix
> >  15:          0          0   IO-APIC-edge      ata_piix
> >  16:   14033945        877   IO-APIC-fasteoi   i915, ahci, yenta,
> > uhci_hcd:usb2, eth0
> > 
> > but it seems that eth0 is not generating interrupts at all:
> > 
> > ...
> > 64 bytes from 10.0.0.251: icmp_req=32 ttl=64 time=26.2 ms
> > 64 bytes from 10.0.0.251: icmp_req=33 ttl=64 time=16.6 ms
> > 64 bytes from 10.0.0.251: icmp_req=34 ttl=64 time=1.14 ms
> > 64 bytes from 10.0.0.251: icmp_req=35 ttl=64 time=56.4 ms ^C
> > --- 10.0.0.251 ping statistics ---
> > 35 packets transmitted, 35 received, 0% packet loss, time 34140ms rtt
> > min/avg/max/mdev = 1.024/20.173/88.285/25.281 ms
> > pavel@amd:/data/l/linux-good$ ping 10.0.0.251
> > 
> > Note huge latencies. But as interrupt is shared with ahci, I can help
> > with:
> > 
> > pavel@amd:~$ sudo cat /dev/sda > /dev/null [sudo] password for pavel:
> > 
> > Then latencies get to high but reasonable range:
> > 
> > pavel@amd:/data/l/linux-good$ ping 10.0.0.251 PING 10.0.0.251
> > (10.0.0.251) 56(84) bytes of data.
> > 64 bytes from 10.0.0.251: icmp_req=1 ttl=64 time=1.14 ms
> > 64 bytes from 10.0.0.251: icmp_req=2 ttl=64 time=3.79 ms
> > 64 bytes from 10.0.0.251: icmp_req=3 ttl=64 time=1.24 ms
> > 64 bytes from 10.0.0.251: icmp_req=4 ttl=64 time=1.54 ms
> > 64 bytes from 10.0.0.251: icmp_req=5 ttl=64 time=2.04 ms
> > 64 bytes from 10.0.0.251: icmp_req=6 ttl=64 time=2.48 ms
> > 64 bytes from 10.0.0.251: icmp_req=7 ttl=64 time=1.90 ms
> > 64 bytes from 10.0.0.251: icmp_req=8 ttl=64 time=2.30 ms (other
> > attempt)
> > --- 10.0.0.251 ping statistics ---
> > 22 packets transmitted, 22 received, 0% packet loss, time 21128ms rtt
> > min/avg/max/mdev = 0.940/1.733/3.604/0.685 ms

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

------------------------------------------------------------------------------
See everything from the browser to the database with AppDynamics
Get end-to-end visibility with application monitoring from AppDynamics
Isolate bottlenecks and diagnose root cause in seconds.
Start your free trial of AppDynamics Pro today!
http://pubads.g.doubleclick.net/gampad/clk?id=48808831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
