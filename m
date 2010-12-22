From: "juice" <juice@swagman.org>
Subject: Re: Using ethernet device as efficient small packet generator
Date: Wed, 22 Dec 2010 13:11:00 +0200
Message-ID: <46a49c1abf06991c1154acc21ac6834d.squirrel@www.liukuma.net>
References: <e66c1ff20e095bcc3a9a678a9935dc7e.squirrel@www.liukuma.net>
    <1293005302.4317.19.camel@edumazet-laptop>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: juice@swagman.org, "Stephen Hemminger" <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:13119 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473Ab0LVLLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Dec 2010 06:11:12 -0500
In-Reply-To: <1293005302.4317.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> Could you share some information on the required interrupt tuning? It
>> would certainly be easiest if the full line rate can be achieved without
>> any patching of drivers or hindering normal eth/ip interface operation.
>>
>
> Thats pretty easy.
>
> Say your card has 8 queues, do :
>
> echo 01 >/proc/irq/*/eth1-fp-0/../smp_affinity
> echo 02 >/proc/irq/*/eth1-fp-1/../smp_affinity
> echo 04 >/proc/irq/*/eth1-fp-2/../smp_affinity
> echo 08 >/proc/irq/*/eth1-fp-3/../smp_affinity
> echo 10 >/proc/irq/*/eth1-fp-4/../smp_affinity
> echo 20 >/proc/irq/*/eth1-fp-5/../smp_affinity
> echo 40 >/proc/irq/*/eth1-fp-6/../smp_affinity
> echo 80 >/proc/irq/*/eth1-fp-7/../smp_affinity
>
> Then, start your pktgen threads on each queue, so that TX completion IRQ
> are run on same CPU.
>
> I confirm getting 6Mpps (or more) out of the box is OK.
>
> I did it one year ago on ixgbe, no patches needed.
>
> With recent kernels, it should even be faster.
>

I guess the irq structures are different on 2.6.31, as there are no such
files there. However, this is what it looks like:

root@a2labralinux:/home/juice#
root@a2labralinux:/home/juice# cat /proc/interrupts
           CPU0       CPU1
  0:         46          0   IO-APIC-edge      timer
  1:       1917          0   IO-APIC-edge      i8042
  3:          2          0   IO-APIC-edge
  4:          2          0   IO-APIC-edge
  6:          5          0   IO-APIC-edge      floppy
  7:          0          0   IO-APIC-edge      parport0
  8:          0          0   IO-APIC-edge      rtc0
  9:          0          0   IO-APIC-fasteoi   acpi
 12:      41310          0   IO-APIC-edge      i8042
 14:     132126          0   IO-APIC-edge      ata_piix
 15:    3747771          0   IO-APIC-edge      ata_piix
 16:          0          0   IO-APIC-fasteoi   uhci_hcd:usb1
 18:          0          0   IO-APIC-fasteoi   uhci_hcd:usb3
 19:          0          0   IO-APIC-fasteoi   uhci_hcd:usb2
 28:   11678379          0   IO-APIC-fasteoi   eth0
 29:    1659580     305890   IO-APIC-fasteoi   eth1
 72:    1667572          0   IO-APIC-fasteoi   eth2
NMI:          0          0   Non-maskable interrupts
LOC:   42109031   78473986   Local timer interrupts
SPU:          0          0   Spurious interrupts
CNT:          0          0   Performance counter interrupts
PND:          0          0   Performance pending work
RES:     654819     680053   Rescheduling interrupts
CAL:        137       1534   Function call interrupts
TLB:     102720     606381   TLB shootdowns
TRM:          0          0   Thermal event interrupts
THR:          0          0   Threshold APIC interrupts
MCE:          0          0   Machine check exceptions
MCP:       1724       1724   Machine check polls
ERR:          0
MIS:          0
root@a2labralinux:/home/juice# ls -la /proc/irq/28/
total 0
dr-xr-xr-x  3 root root 0 2010-12-22 15:23 .
dr-xr-xr-x 24 root root 0 2010-12-22 15:23 ..
dr-xr-xr-x  2 root root 0 2010-12-22 15:23 eth0
-rw-------  1 root root 0 2010-12-22 15:23 smp_affinity
-r--r--r--  1 root root 0 2010-12-22 15:23 spurious
root@a2labralinux:/home/juice#
root@a2labralinux:/home/juice# cat /proc/irq/28/smp_affinity
1
root@a2labralinux:/home/juice#

The smp_affinity was previously 3, so I guess both CPU's handled the
interrupts.

Now, with affinity set to CPU0, I get a bit better results but still
nothing near full GE saturation:

root@a2labralinux:/home/juice# cat /proc/net/pktgen/eth1
Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 10000000  ifname: eth1
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 10.10.11.2  dst_max:
     src_min:   src_max:
     src_mac: 00:30:48:2a:2a:61 dst_mac: 00:04:23:08:91:dc
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 10000000  errors: 0
     started: 1293021547122748us  stopped: 1293021562952096us idle: 2118707us
     seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0xb090914  cur_daddr: 0x20b0a0a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 15829348(c13710641+d2118707) usec, 10000000 (60byte,0frags)
  631737pps 303Mb/sec (303233760bps) errors: 0
root@a2labralinux:/home/juice#

This result is from the Pomi micro using e1000 network interface.
Previously the small packet throghput was about 180Mb/s, now 303Mb/s.

>From the Dell machine using tg3 interface, there was really no difference
when I set the interrupt affinity to single CPU, the results are about
same as before:

root@d8labralinux:/home/juice# cat /proc/net/pktgen/eth2
Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 10000000  ifname: eth2
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 10.10.11.2  dst_max:
        src_min:   src_max:
     src_mac: b8:ac:6f:95:d5:f7 dst_mac: 00:04:23:08:91:dc
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 10000000  errors: 0
     started: 169829200145us  stopped: 169856889850us idle: 1296us
     seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x4030201  cur_daddr: 0x20b0a0a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 27689705(c27688408+d1296) nsec, 10000000 (60byte,0frags)
  361145pps 173Mb/sec (173349600bps) errors: 0
root@d8labralinux:/home/juice#


>
> Hmm, might be better with 10.10 ubuntu, with 2.6.35 kernels
>

So, is the interrupt handling different in newer kernels?
Should I try to update the linux version before doing any more optimizing?

As the boxes are also running other software I would like to keep
them in Ubuntu-LTS.

Yours, Jussi Ohenoja


