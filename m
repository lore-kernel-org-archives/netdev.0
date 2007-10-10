From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible 2.6.22 -> 2.6.23 HTB regression?
Date: Wed, 10 Oct 2007 15:18:37 +0200
Message-ID: <470CD12D.2060105@trash.net>
References: <20071010130653.M55961@visp.net.lb>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070406060606020802080606"
Cc: netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61228 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752467AbXJJNV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 09:21:56 -0400
In-Reply-To: <20071010130653.M55961@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070406060606020802080606
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Denys wrote:
> Seems i am lost a bit. Now 2.6.22, i am not sure that working well. Possible 
> it is related, that i booted kernel over kexec.


Possibly.

> I will try to do full power cycle reboot if required, but it will cause for 
> me serious downtime. Please tell me, which kernel prefferable to boot?
> 
> If it is interesting 
> 2.6.22 (but also non-functional now).
> 
> visp-1 ~ # cat /proc/net/psched
> 000003e8 00000400 000f4240 3b9aca00
> 
> maybe it is related to 
> visp-1 ~ # dmesg|grep hpet
> hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
> hpet0: 3 64-bit timers, 14318180 Hz
> Time: hpet clocksource has been installed.
> hpet_resources: 0xfed00000 is busy <<< - this?


Thats appears on both 2.6.22 and 2.6.23.

> --- log.2.6.22  2007-10-10 16:08:04.000000000 +0300
> +++ log.2.6.23  2007-10-10 16:06:19.000000000 +0300

> @@ -314,12 +235,20 @@
>  usbcore: registered new device driver usb
>  PCI: Using ACPI for IRQ routing
>  PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a 
> report
> +Time: hpet clocksource has been installed.
> +Clockevents: could not switch to one-shot mode: lapic is not functional.
> +Could not switch to high resolution mode on CPU 0
> +Clockevents: could not switch to one-shot mode:<6>Clockevents: could not 
> switch to one-shot mode: lapic is not functional.
> + lapic is not functional.
> +Could not switch to high resolution mode on CPU 2
> +Could not switch to high resolution mode on CPU 3
> +Clockevents: could not switch to one-shot mode: lapic is not functional.
> +Could not switch to high resolution mode on CPU 1
>  pnp: 00:08: ioport range 0x800-0x87f has been reserved
>  pnp: 00:08: ioport range 0x880-0x8bf has been reserved
>  pnp: 00:08: ioport range 0x8c0-0x8df has been reserved
>  pnp: 00:08: ioport range 0x8e0-0x8e3 has been reserved
>  pnp: 00:08: ioport range 0xc00-0xc7f has been reserved
> -Time: hpet clocksource has been installed.
>  pnp: 00:08: ioport range 0xca0-0xca7 has been reserved
>  pnp: 00:08: ioport range 0xca9-0xcab has been reserved
>  pnp: 00:08: ioport range 0xcad-0xcaf has been reserved


>  Real Time Clock Driver v1.12ac
> -[ACPI Debug]  String: [0x09] "HPET _CRS"
> -[ACPI Debug]  Buffer: [0x1C]
>  hpet_resources: 0xfed00000 is busy
> -ACPI Error (utglobal-0126): Unknown exception code: 0xFFFFFFF0 [20070126]
>  intel_rng: FWH not detected
>  Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin is 60 
> seconds).
>  Hangcheck: Using get_cycles().
> -input: Power Button (FF) as /class/input/input0
> -ACPI: Power Button (FF) [PWRF]
>  Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
> +serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> +serial8250: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
>  00:06: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
>  00:07: ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
> +Clockevents: could not switch to one-shot mode:<6>Clockevents: could not 
> switch to one-shot mode:<6>Clockevents: could not switch to one-shot mode: 
> lapic is not functional.
> + lapic is not functional.
> +Could not switch to high resolution mode on CPU 3
> +Could not switch to high resolution mode on CPU 2
> +Clockevents: could not switch to one-shot mode: lapic is not functional.
> +Could not switch to high resolution mode on CPU 0
> + lapic is not functional.
> +Could not switch to high resolution mode on CPU 1


hrtimers seem to have worked on your system in 2.6.22 and not in
2.6.23 anymore. This patch should fix the incorrectly announced
/proc/net/psched timer resolution I mentioned earlier, causing HTB
to use larger burst rates by default, but that still won't be as
precise as with hrtimers.

Looking at the code, the reason for not using the lapic seems to
be nmi_watchdog=1:

+APIC timer registered as dummy, due to nmi_watchdog=1!

--------------070406060606020802080606
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index dee0d5f..8f1bcf6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1225,10 +1225,13 @@ EXPORT_SYMBOL(tcf_destroy_chain);
 #ifdef CONFIG_PROC_FS
 static int psched_show(struct seq_file *seq, void *v)
 {
+	struct timespec ts;
+
+	hrtimer_get_res(CLOCK_MONOTONIC, &ts);
 	seq_printf(seq, "%08x %08x %08x %08x\n",
 		   (u32)NSEC_PER_USEC, (u32)PSCHED_US2NS(1),
 		   1000000,
-		   (u32)NSEC_PER_SEC/(u32)ktime_to_ns(KTIME_MONOTONIC_RES));
+		   (u32)NSEC_PER_SEC/(u32)ktime_to_ns(timespec_to_ktime(ts)));
 
 	return 0;
 }

--------------070406060606020802080606--
