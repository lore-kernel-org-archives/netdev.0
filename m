From: Pavel Machek <pavel@ucw.cz>
Subject: e1000e on thinkpad x60: interrupt problem
Date: Tue, 9 Jul 2013 03:05:00 +0200
Message-ID: <20130709010500.GA21248@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:50035 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026Ab3GIBFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 21:05:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm using

02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller

on thinkpad x60. Kernel is 3.10. 

# CONFIG_E100 is not set
# CONFIG_E1000 is not set
CONFIG_E1000E=y

Interrupts are like this:

pavel@amd:/data/l/linux-good$ cat /proc/interrupts 
           CPU0       CPU1       
  0:   95454037       5192   IO-APIC-edge      timer
  1:      16292         20   IO-APIC-edge      i8042
  3:          9          0   IO-APIC-edge    
  4:          9          0   IO-APIC-edge    
  7:          0          0   IO-APIC-edge      parport0
  8:          1          0   IO-APIC-edge      rtc0
  9:   19471974       1207   IO-APIC-fasteoi   acpi
 12:     168092         15   IO-APIC-edge      i8042
 14:    3568551        165   IO-APIC-edge      ata_piix
 15:          0          0   IO-APIC-edge      ata_piix
 16:   14033945        877   IO-APIC-fasteoi   i915, ahci, yenta, uhci_hcd:usb2, eth0

but it seems that eth0 is not generating interrupts at all:

...
64 bytes from 10.0.0.251: icmp_req=32 ttl=64 time=26.2 ms
64 bytes from 10.0.0.251: icmp_req=33 ttl=64 time=16.6 ms
64 bytes from 10.0.0.251: icmp_req=34 ttl=64 time=1.14 ms
64 bytes from 10.0.0.251: icmp_req=35 ttl=64 time=56.4 ms
^C
--- 10.0.0.251 ping statistics ---
35 packets transmitted, 35 received, 0% packet loss, time 34140ms
rtt min/avg/max/mdev = 1.024/20.173/88.285/25.281 ms
pavel@amd:/data/l/linux-good$ ping 10.0.0.251

Note huge latencies. But as interrupt is shared with ahci, I can help
with:

pavel@amd:~$ sudo cat /dev/sda > /dev/null
[sudo] password for pavel: 

Then latencies get to high but reasonable range:

pavel@amd:/data/l/linux-good$ ping 10.0.0.251
PING 10.0.0.251 (10.0.0.251) 56(84) bytes of data.
64 bytes from 10.0.0.251: icmp_req=1 ttl=64 time=1.14 ms
64 bytes from 10.0.0.251: icmp_req=2 ttl=64 time=3.79 ms
64 bytes from 10.0.0.251: icmp_req=3 ttl=64 time=1.24 ms
64 bytes from 10.0.0.251: icmp_req=4 ttl=64 time=1.54 ms
64 bytes from 10.0.0.251: icmp_req=5 ttl=64 time=2.04 ms
64 bytes from 10.0.0.251: icmp_req=6 ttl=64 time=2.48 ms
64 bytes from 10.0.0.251: icmp_req=7 ttl=64 time=1.90 ms
64 bytes from 10.0.0.251: icmp_req=8 ttl=64 time=2.30 ms
(other attempt)
--- 10.0.0.251 ping statistics ---
22 packets transmitted, 22 received, 0% packet loss, time 21128ms
rtt min/avg/max/mdev = 0.940/1.733/3.604/0.685 ms

root@amd:/data/l/linux-good# ethtool -e eth0
Offset Values
------ ------
0x0000 00 16 d3 25 19 04 30 0b b2 ff 51 00 ff ff ff ff 
0x0010 53 00 03 02 6b 02 7e 20 aa 17 9a 10 86 80 df 80 
0x0020 00 00 00 20 54 7e 00 00 14 00 da 00 04 00 00 27 
0x0030 c9 6c 50 31 3e 07 0b 04 8b 29 00 00 00 f0 02 0f 
0x0040 08 10 00 00 04 0f ff 7f 01 4d ff ff ff ff ff ff 
0x0050 14 00 1d 00 14 00 1d 00 af aa 1e 00 00 00 1d 00 
0x0060 00 01 00 40 32 12 07 40 ff ff ff ff ff ff ff ff 
0x0070 ff ff ff ff ff ff ff ff ff ff ff ff ff ff fd 5d 

02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
        Subsystem: Lenovo ThinkPad X60s
        Flags: bus master, fast devsel, latency 0, IRQ 16
        Memory at ee000000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at 2000 [size=32]
        Capabilities: [c8] Power Management version 2
        Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
        Capabilities: [e0] Express Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [140] Device Serial Number 00-16-d3-ff-ff-25-19-04
        Kernel driver in use: e1000e

Any ideas how to debug/fix this?

[Maybe related: https://bugzilla.kernel.org/show_bug.cgi?id=6929 but
that was fixed in 2007. And yes, it _is_ better with bigger packets.]?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
