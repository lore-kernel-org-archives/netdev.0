From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: r8169 and tg3
Date: Tue, 18 Nov 2003 11:00:01 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118100001.GA23615@wsx.ksp.sk>
References: <47973.68.105.173.45.1069042089.squirrel@mail.mainstreetsoftworks.com> <3FB9A277.70309@pobox.com>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brad House <brad_mssw@gentoo.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FB9A277.70309@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,

> 1) If you have problems with the tg3 driver, we need to get those bug 
> reports and fix them.  bcm5700 is not going to be merged into the 
> kernel.  Further, there was at least one serious x86-64 issue that was 
> fixed in tg3, and we need to make sure users are testing that driver, 
> not a non-standard driver with bugs of its own.


So here is the bug report:

I have a 4-port card with two Broadcom 5704 chips plugged into PCI-X 1 of
Tyan S2880 motherboard (the onboard 5704's are disabled) with single Opteron
240 processor. When loading tg3 driver, this appears in dmesg:

eth0: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet <MAC0>
eth1: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet <MAC1>
eth2: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet <MAC2>
eth3: Tigon3 [partno(BCM95704A6) rev 2003 PHY(5704)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet <MAC3>

The IRQs of the ports are:

eth0: IRQ 28
eth1: IRQ 28
eth2: IRQ 28
eth3: IRQ 30


When we try configure eth0 only or eth3 only, it works fine. When only eth1
or eth2 are configured, the 'RUNNING' flag of the interface is missing even
if the cable is plugged thus card does not work. When we turn eth0 up, eth1
and eth2 starts working, but the latency of transfers is horrible.

After some debugging I realized this:

When inserting printk() into tg3_interrupt():

When one of eth0, eth3 are up, I get 10 interrups per second for them (I
heard that it's some workaround for HW bug).

When one of eth1, eth2 are up, I get no interrupt.

When one of eth1, eth2 are up and eth0 is up, I get 10 interrupts per second
for each of them, but I get no interrupts when data are received on eth1 or
eth2. That explains the horrible latency like:

64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=10.0 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=9.00 ms
64 bytes from 10.0.0.1: icmp_seq=3 ttl=64 time=8.00 ms
64 bytes from 10.0.0.1: icmp_seq=4 ttl=64 time=7.00 ms
64 bytes from 10.0.0.1: icmp_seq=5 ttl=64 time=6.00 ms
64 bytes from 10.0.0.1: icmp_seq=6 ttl=64 time=5.00 ms
64 bytes from 10.0.0.1: icmp_seq=7 ttl=64 time=4.00 ms
64 bytes from 10.0.0.1: icmp_seq=8 ttl=64 time=3.00 ms
64 bytes from 10.0.0.1: icmp_seq=9 ttl=64 time=2.00 ms
64 bytes from 10.0.0.1: icmp_seq=10 ttl=64 time=1.00 ms
64 bytes from 10.0.0.1: icmp_seq=11 ttl=64 time=99.9 ms
64 bytes from 10.0.0.1: icmp_seq=12 ttl=64 time=98.9 ms
64 bytes from 10.0.0.1: icmp_seq=13 ttl=64 time=97.9 ms
64 bytes from 10.0.0.1: icmp_seq=14 ttl=64 time=96.9 ms


Also, I cannot see any interrupts in /proc/interrupts when I receive packets
thru eth1/eth2.

The problem is repeatable on other exactly same system. The NICs works fine
on 32-bit architecture with 64-bit PCI-X. There are some reports that it
works under 32-bit kernel on Opteron, but I have not tried this yet.

The same problem appears with bcm5700 driver (except 10 ints/sec so the only
way to make it partially work is to make traffic on eth0).

If you need any details or have some suggestions what should I try, let me
know.

Thanks,


Jan
