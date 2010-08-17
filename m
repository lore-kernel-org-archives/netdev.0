From: Thomas Habets <thomas@habets.pp.se>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 13:08:41 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>  <1281953960.2524.23.camel@edumazet-laptop>  <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>  <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
 <1282024802.2487.687.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Thomas Habets <thomas@habets.pp.se>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282024802.2487.687.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Aha! New development:

The Cisco router can't discover the address of the Linux box because Linux 
doesn't seem to be listening to ff02::1 (all-nodes).

-----------
cisco#ping ff02::1
Output Interface: GigabitEthernet1/2
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to FF02::1, timeout is 2 seconds:
Packet sent with a source address of 
FE80::222:55FF:FE17:4B80%GigabitEthernet1/2

Request 0 timed out
Request 1 timed out
Request 2 timed out
Request 3 timed out
Request 4 timed out
Success rate is 0 percent (0/5)
0 multicast replies and 0 errors.
------------

If i set promisc mode on the interface (tcpdump without -p or "ip link set 
promisc on eth0") it starts working (both normal ping and the above ping 
from the Cisco to ff02::1). It continues working until I guess the 
neighbor table on the cisco times out (leaving it overnight seems to 
be enough idle time) or I manually do a "clear ipv6 neig".

So great news! I can reproduce it at will with no waiting time! Right 
after rebooting the Linux box I run "clear ipv6 neighbors" and Linux can 
no longer ping the router. Tested reproducing it immediately after reboot.

The Linux box itself can ping ff02::1%eth0 with no problem, and gets 
replies from the fe80:: link-local of itself and the Cisco router.

So could this be that for some reason the NIC isn't listening 
multicast MAC address 33:33:ff:5c:00:02 ?

Is there a way to see the list of addresses that get past the NIC? Or can 
this perhaps be filtered after the NIC, but before tcpdump -p?

Since this now looks like a NIC thing, here's some info about eth0:

$ dmesg | grep eth0
[...]
tg3 0000:03:04.0: eth0: Tigon3 [partno(N/A) rev 9003] (PCIX:133MHz:64-bit) 
MAC address 00:24:81:a3:44:24
tg3 0000:03:04.0: eth0: attached PHY is 5714 (10/100/1000Base-T Ethernet) 
(WireSpeed[1])
tg3 0000:03:04.0: eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] TSOcap[1]
tg3 0000:03:04.0: eth0: dma_rwctrl[76148000] dma_mask[40-bit]
[...]

$ sudo lspci -v -s 03:04.0
03:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5715 
Gigabit Ethernet (rev a3)
Subsystem: Hewlett-Packard Company NC326i PCIe Dual Port Gigabit Server 
Adapter
Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 47
Memory at fdff0000 (64-bit, non-prefetchable) [size=64K]
Memory at fdfe0000 (64-bit, non-prefetchable) [size=64K]
Expansion ROM at <ignored> [disabled]
Capabilities: [40] PCI-X non-bridge device
Capabilities: [48] Power Management version 2
Capabilities: [50] Vital Product Data <?>
Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 
Enable+
Kernel driver in use: tg3
Kernel modules: tg3

$ sudo ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:24:81:a3:44:24
           inet addr:x.x.x.x  Bcast:x.x.x.x 
Mask:255.255.255.252
           inet6 addr: 2a00:800:752:1::5c:2/112 Scope:Global
           inet6 addr: fe80::224:81ff:fea3:4424/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:928 errors:0 dropped:0 overruns:0 frame:0
           TX packets:834 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:142281 (138.9 KiB)  TX bytes:154616 (150.9 KiB)
           Interrupt:16

I have doublechecked iptables, ip6tables and arptables, and they are 
either not compiled in the kernel or they are empty ACCEPT lists.

I have answered your questions below even if they may no longer be 
applicable.


On Tue, 17 Aug 2010, Eric Dumazet wrote:
>> $ ip -6 ne sh
>> 2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router STALE
>>
>> [try ping6 again, no reply]
>>
>> $ ip -6 ne sh
>> 2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router DELAY
>>
>> [try ping6 again, no reply]
>>
>> $ ip -6 ne sh
>> 2a00:800:752:1::5c:1 dev eth0 lladdr 00:22:55:17:4b:80 router REACHABLE
>>
> This seems a bit different than previous mail. Apparently discovery now
> works ?

I didn't post the "ip -6 ne sh" immediately after ping attempt last time. 
I'm not sure this changed since last time.

But the tcpdump output from last time seems to indicate that ND did work 
then, at least in one direction, even if solicitation came from link-local 
address and not the global address. The solicitation was answered, after 
all (as seen in the tcpdump in in the original mail).

> Could you have a tcpdump on both sides ?

Not easily. The other end is a Cisco and a bit inconvenient to get to. I'm 
going there tomorrow night, so I can hook up a cable and do a monitor 
port then if needed.

---------
typedef struct me_s {
   char name[]      = { "Thomas Habets" };
   char email[]     = { "thomas@habets.pp.se" };
   char kernel[]    = { "Linux" };
   char *pgpKey[]   = { "http://www.habets.pp.se/pubkey.txt" };
   char pgp[] = { "A8A3 D1DD 4AE0 8467 7FDE  0945 286A E90A AD48 E854" };
   char coolcmd[]   = { "echo '. ./_&. ./_'>_;. ./_" };
} me_t;
