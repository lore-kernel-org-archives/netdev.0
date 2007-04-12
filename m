From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection stops after high load.
Date: Thu, 12 Apr 2007 12:12:22 -0700
Message-ID: <461E8496.2050003@candelatech.com>
References: <461D2DEA.4010806@candelatech.com>	<461D447C.4070408@candelatech.com>	<20070411.134804.50594117.davem@davemloft.net>	<461D4DD7.7020207@candelatech.com>	<p73y7kx7iol.fsf@bingen.suse.de>	<461E7377.3020708@candelatech.com> <20070412201940.7f570b6d.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57229 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751600AbXDLTNo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 15:13:44 -0400
In-Reply-To: <20070412201940.7f570b6d.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:

> What 
> "tc -s -d qdisc"
> "ifconfig -a"
> "cat /proc/interrupts" 
> "cat /proc/net/sockstat" and
> "cat /proc/net/softnet_stat" are telling ?


In this test, eth2 is talking to eth3, using something similar to this
send-to-self patch:
http://www.candelatech.com/oss/sts.patch


[root@lf1001-240 ipv4]# ifconfig -a
eth0      Link encap:Ethernet  HWaddr 00:30:48:89:74:60
           inet addr:192.168.100.187  Bcast:192.168.100.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:1672220 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1560305 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:151896589 (144.8 MiB)  TX bytes:1375280163 (1.2 GiB)
           Interrupt:17

eth1      Link encap:Ethernet  HWaddr 00:30:48:89:74:61
           UP BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
           Interrupt:18

eth2      Link encap:Ethernet  HWaddr 00:07:E9:1F:CE:02
           inet addr:20.20.20.20  Bcast:20.20.20.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:2175144684 errors:0 dropped:2 overruns:0 frame:0
           TX packets:2196560123 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:1321380186 (1.2 GiB)  TX bytes:2274982574 (2.1 GiB)
           Base address:0xd000 Memory:d0000000-d0020000

eth3      Link encap:Ethernet  HWaddr 00:07:E9:1F:CE:03
           inet addr:20.20.20.30  Bcast:20.20.20.255  Mask:255.255.255.0
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:2196315966 errors:0 dropped:0 overruns:0 frame:0
           TX packets:2174900538 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:2257901986 (2.1 GiB)  TX bytes:1304493504 (1.2 GiB)
           Base address:0xd100 Memory:d0020000-d0040000

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:1159378 errors:0 dropped:0 overruns:0 frame:0
           TX packets:1159378 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:1133646590 (1.0 GiB)  TX bytes:1133646590 (1.0 GiB)

[root@lf1001-240 ipv4]# tc -s -d qdisc
qdisc pfifo_fast 0: dev eth0 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
  Sent 1367521025 bytes 1324808 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
  Sent 1815657070136 bytes 1536674488 pkt (dropped 0, overlimits 0 requeues 1448094)
  rate 0bit 0pps backlog 0b 0p requeues 1448094
qdisc pfifo_fast 0: dev eth3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
  Sent 1752033393324 bytes 1536906566 pkt (dropped 0, overlimits 0 requeues 1063672)
  rate 0bit 0pps backlog 0b 0p requeues 1063672

[root@lf1001-240 ipv4]# cat /proc/interrupts
            CPU0       CPU1
   0:   46020594   44501954    IO-APIC-edge  timer
   1:          9          0    IO-APIC-edge  i8042
   7:          0          0    IO-APIC-edge  parport0
   8:          1          0    IO-APIC-edge  rtc
   9:          0          0   IO-APIC-level  acpi
  12:         96          0    IO-APIC-edge  i8042
  14:     394023     407282    IO-APIC-edge  ide0
  16:          0          0   IO-APIC-level  uhci_hcd:usb4
  17:    1134346    1034006   IO-APIC-level  uhci_hcd:usb3, eth0
  18:      81605      83739   IO-APIC-level  libata, uhci_hcd:usb2, eth1
  19:          0          0   IO-APIC-level  uhci_hcd:usb1, ehci_hcd:usb5
  20:   53056128   46598235   IO-APIC-level  eth2
  21:   47534577   52189674   IO-APIC-level  eth3
NMI:          0          0
LOC:   90485383   90485382
ERR:          0
MIS:          0

[root@lf1001-240 ipv4]# cat /proc/net/sockstat
sockets: used 334
TCP: inuse 27 orphan 0 tw 0 alloc 27 mem 360
UDP: inuse 12
RAW: inuse 0
FRAG: inuse 0 memory 0

[root@lf1001-240 ipv4]# cat /proc/net/softnet_stat
d58236f1 00000000 023badc3 00000000 00000000 00000000 00000000 00000000 0004ef01
3a4354a1 00000000 01b57b4b 00000000 00000000 00000000 00000000 00000000 0005445f


Thanks,
Ben

> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

