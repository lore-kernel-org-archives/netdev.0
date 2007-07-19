From: Glen Gray <glen@lincor.com>
Subject: Re: Status of RTL8110SC in vanilla r8169.c
Date: Thu, 19 Jul 2007 18:49:11 +0100
Message-ID: <469FA417.8010207@lincor.com>
References: <F5A04EB7-0726-4CF5-A4B8-F32F00D9BC52@lincor.com> <20070718221107.GE9755@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="------------010902090903080502080205"
Cc: edward_hsu@realtek.com.tw, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.station1.mxsweep.com ([212.147.136.149]:3462 "EHLO
	2out.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S937848AbXGSSAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 14:00:38 -0400
In-Reply-To: <20070718221107.GE9755@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--------------010902090903080502080205
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit

Hey Francois,
I've CC'd the netdev list as requested, however, I'm not signed up to 
this list so please include my email address directly in any replies. Thanks

Francois Romieu wrote:
>> I'm in a particularly sticky situation in relation to the latest  
>> kernels and multicast. And I need some help to get out of it. I'm  
>> hoping with your combined experiences we might be able to solve my  
>> problems.
> 
> Multicast ? It could be worth to try 2.6.22 +
> http://www.fr.zoreil.com/people/francois/misc/20070628-2.6.22-rc6-r8169-test.patch
> 
> (same thing as a serie of patches at:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628)
> 
> The patches are available in the current git kernel tree (and will thus
> appear in 2.6.23-rc1).
> 

I've applied that patch to the 2.6.22.1 kernel. I found a fedora source 
rpm in the testing dir and modified it to apply your patch.

Unfortunately, this hasn't solved my problems. The tests mentioned below 
where also carried out under this kernel with the same effect.

>> that for some reason dhcp wasn't working. After investigations back  
>> in our lab we realised that the hardware suppliers had changed the  
>> eth chip from the RTL8169S/8110S used in the initial run of units  
>> that we developed against to the RTL8169SC/8110SC without telling us.
> 
> Can you send a detailled output of mii-tool for both ? Just curious.
> 

Sure, but not sure what kind of info you'd like to see though, I'm new 
to this side of things. Could you give me some examples of what would be 
helpful ?
Here's some data from ethtool
[root@webnote root]# uname -r
2.6.22.1-20.fc7

[root@webnote root]# dmesg | grep eth
eth0: RTL8169sc/8110sc at 0xdc876000, 00:05:6b:40:2c:be, XID 18000000 IRQ 18
r8169: eth0: link up
r8169: eth0: link up

[root@webnote root]# ethtool -i eth0
driver: r8169
version: 2.2LK-NAPI
firmware-version:
bus-info: 0000:00:0b.0

[root@webnote root]# ethtool eth0
Settings for eth0:
         Supported ports: [ TP ]
         Supported link modes:   10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Supports auto-negotiation: Yes
         Advertised link modes:  10baseT/Half 10baseT/Full
                                 100baseT/Half 100baseT/Full
                                 1000baseT/Full
         Advertised auto-negotiation: Yes
         Speed: 100Mb/s
         Duplex: Full
         Port: Twisted Pair
         PHYAD: 0
         Transceiver: internal
         Auto-negotiation: on
         Supports Wake-on: pumbg
         Wake-on: g
         Current message level: 0x00000033 (51)
         Link detected: yes

[root@webnote root]# ethtool -S eth0
NIC statistics:
      tx_packets: 2666
      rx_packets: 21498
      tx_errors: 0
      rx_errors: 0
      rx_missed: 0
      align_errors: 0
      tx_single_collisions: 0
      tx_multi_collisions: 0
      unicast: 20392
      broadcast: 579
      multicast: 536
      tx_aborted: 0
      tx_underrun: 0

>> I've frantically managed to upgrade the base distro to Fedora 7 with  
>> the stock 2.6.21 kernel in the hopes it would resolve our problems.  
>> DHCP now works correctly but I'm still having issues. Specifically  
>> with multicast.
> 
> FC7 with latest FC6 kernel may behave better. There are some issues
> with the last FC7 kernel and the r8169 driver.
> 
> However, you should really try the suggestion above first.
> 

I've managed to localise the problem a bit better. It looks like its 
ethernet multicast that's the problem. We've setup some fixed playlist 
items that use IP multicast addresses (what the SAP announcements are 
providing) and they play fine. However, the ethernet multicast packets 
are either being ignored or something else is wrong as the SAP messages 
aren't getting back to the unit.

My colleague in our other office with an exterity iptv gateway captured 
some data that I'm including here. I've replicated these tests also 
using vlc as a simulated iptv gateway.

Attached are two files. One is a tcpdump from a machine on the same hub 
showing the IGMPv2 messages getting sent to the multicast address and 
then the subsequent data packets being routed from the iptv gateway 
(192.168.3.4) to the unit. There's also a tcpdump from the unit where 
you can see the IGMPv2 requests going out, but none of the data coming 
back. The first file shows that the multicast session was setup 
correctly, but for some reason the unit can't see it.

As mentioned in my original message, we have to force the igmp version 
to 2 via the /proc/sys/net/ipv4/conf/eth0/force_igmp_version as it 
defaults to V3 (as seen from /proc/net/igmp). The RTL8110S defaulted to V2.

Here is a dump of what the missing data packets look like

Frame 64 (324 bytes on wire, 324 bytes captured)
     Arrival Time: Jul 19, 2007 18:16:18.820712000
     [Time delta from previous captured frame: 1.020403000 seconds]
     [Time delta from previous displayed frame: 1.020403000 seconds]
     [Time since reference or first frame: 1184865378.820712000 seconds]
     Frame Number: 64
     Frame Length: 324 bytes
     Capture Length: 324 bytes
     [Frame is marked: False]
     [Protocols in frame: eth:ip:udp:sap:sdp]
Ethernet II, Src: AsustekC_51:f9:19 (00:0e:a6:51:f9:19), Dst:
01:00:5e:7f:ff:ff (01:00:5e:7f:ff:ff)
     Destination: 01:00:5e:7f:ff:ff (01:00:5e:7f:ff:ff)
         Address: 01:00:5e:7f:ff:ff (01:00:5e:7f:ff:ff)
         .... ...1 .... .... .... .... = IG bit: Group address
(multicast/broadcast)
         .... ..0. .... .... .... .... = LG bit: Globally unique address
(factory default)
     Source: AsustekC_51:f9:19 (00:0e:a6:51:f9:19)
         Address: AsustekC_51:f9:19 (00:0e:a6:51:f9:19)
         .... ...0 .... .... .... .... = IG bit: Individual address
(unicast)
         .... ..0. .... .... .... .... = LG bit: Globally unique address
(factory default)
     Type: IP (0x0800)
     Trailer: 8C0DFBE0
Internet Protocol, Src: 192.168.3.4 (192.168.3.4), Dst: 239.255.255.255
(239.255.255.255)
     Version: 4
     Header length: 20 bytes
     Differentiated Services Field: 0x00 (DSCP 0x00: Default; ECN: 0x00)
         0000 00.. = Differentiated Services Codepoint: Default (0x00)
         .... ..0. = ECN-Capable Transport (ECT): 0
         .... ...0 = ECN-CE: 0
     Total Length: 306
     Identification: 0x0000 (0)
     Flags: 0x04 (Don't Fragment)
         0... = Reserved bit: Not set
         .1.. = Don't fragment: Set
         ..0. = More fragments: Not set
     Fragment offset: 0
     Time to live: 255
     Protocol: UDP (0x11)
     Header checksum: 0xc70e [correct]
         [Good: True]
         [Bad : False]
     Source: 192.168.3.4 (192.168.3.4)
     Destination: 239.255.255.255 (239.255.255.255)

Kind Regards
-- 
Glen Gray <glen@lincor.com>              Digital Depot, Thomas Street
Senior Software Engineer                            Dublin 8, Ireland
Lincor Solutions Ltd.                          Ph: +353 (0) 1 4893682

--------------010902090903080502080205
Content-Type: text/plain; name="newonwire.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="newonwire.txt"

[daveharley@dave-ws ~]$ sudo tcpdump -s 0 ether multicast or ip multicast
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
16:36:53.793604 IP dave-ws.cork.lincor.com > 224.0.0.251: igmp v2 report 224.0.0.251
16:37:06.139586 arp who-has colorprinter.cork.lincor.com tell netscreen.cork.lincor.com
16:37:07.144003 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:37:07.293409 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:37:07.293421 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:07.293658 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:08.273844 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:14.501961 arp who-has homer.cork.lincor.com tell 192.168.3.244
16:37:14.721084 IP colorprinter.cork.lincor.com.netbios-dgm > 192.168.3.255.netbios-dgm: NBT UDP PACKET(138)
16:37:22.821357 IP exterity.cork.lincor.com.hbci > 255.255.255.255.snmptrap:  V2Trap(98)  system.sysUpTime.0=1 S:1.1.4.1.0=E:38072.1.1000.1 E:38072.1.5=00_0e_a6_51_f9_19_00_00 E:38072.1.10=3
16:37:23.282835 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:37:23.432243 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:37:23.432253 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:23.432494 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:24.412678 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:39.421676 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:37:39.571090 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:37:39.571108 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:39.571112 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:40.551519 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:49.255189 IP6 fe80::205:6bff:fe40:2cca > ff02::16: HBH ICMP6, multicast listener report v2, 11 group record(s), length 228
16:37:50.085210 IP 192.168.3.243 > SAP.MCAST.NET: igmp v2 report SAP.MCAST.NET
16:37:50.086200 IP 192.168.3.243 > 239.195.255.255: igmp v2 report 239.195.255.255
16:37:50.090198 IP 192.168.3.243 > 239.255.255.255: igmp v2 report 239.255.255.255
16:37:50.092197 IP 192.168.3.243 > 224.0.0.255: igmp v2 report 224.0.0.255
16:37:50.096444 IP6 fe80::205:6bff:fe40:2cca > ff02::16: HBH ICMP6, multicast listener report v2, 11 group record(s), length 228
16:37:53.417015 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 278
16:37:53.417260 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 289
16:37:53.417758 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 277
16:37:53.418008 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 286
16:37:53.418258 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 288
16:37:53.418508 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 289
16:37:53.418758 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 280
16:37:53.419009 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 287
16:37:53.419260 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 275
16:37:53.419510 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 282
16:37:53.420008 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 285
16:37:53.420256 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 286
16:37:53.420507 IP exterity.cork.lincor.com.sapv1 > 239.255.255.255.sapv1: UDP, length 291
16:37:53.427254 IP exterity.cork.lincor.com.hbci > 255.255.255.255.snmptrap:  V2Trap(98)  system.sysUpTime.0=1 S:1.1.4.1.0=E:38072.1.1000.1 E:38072.1.5=00_0e_a6_51_f9_19_00_00 E:38072.1.10=3
16:37:54.445666 IP6 fe80::205:6bff:fe40:2cca > ff02::16: HBH ICMP6, multicast listener report v2, 11 group record(s), length 228
16:37:54.583587 IP 192.168.3.243 > 239.255.255.255: igmp v2 report 239.255.255.255
16:37:55.550522 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:37:55.699937 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:37:55.699958 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:55.700180 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:56.680361 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:56.855763 IP 192.168.3.243 > SAP.MCAST.NET: igmp v2 report SAP.MCAST.NET
16:37:58.218718 IP 192.168.3.243 > 224.0.0.255: igmp v2 report 224.0.0.255
16:37:59.014754 IP 192.168.3.243 > SAP.MCAST.NET: igmp v2 report SAP.MCAST.NET
16:37:59.286846 IP 192.168.3.243 > 239.195.255.255: igmp v2 report 239.195.255.255
16:38:03.050145 IP 192.168.3.243 > 239.255.255.255: igmp v2 report 239.255.255.255
16:38:07.515541 IP 192.168.3.243 > 239.195.255.255: igmp v2 report 239.195.255.255
16:38:08.102457 IP 192.168.3.243 > 224.0.0.255: igmp v2 report 224.0.0.255

54 packets captured
108 packets received by filter
0 packets dropped by kernel

--------------010902090903080502080205
Content-Type: text/plain; name="newonstb.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="newonstb.txt"

tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes



16:36:32.671661 arp who-has colorprinter.cork.lincor.com tell 192.168.3.227
16:36:34.830268 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:36:34.979677 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:36:34.979735 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:36:34.979803 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:36:35.960127 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:36:46.238616 IP 0.0.0.0.bootpc > 255.255.255.255.bootps: BOOTP/DHCP, Request from 00:04:96:05:48:c1 (oui Unknown), length 300
16:36:50.957792 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:36:51.107200 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:36:51.107258 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:36:51.107326 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:36:52.087659 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:36:52.157997 IP exterity.cork.lincor.com.hbci > 255.255.255.255.snmptrap:  V2Trap(98)  system.sysUpTime.0=1 S:1.1.4.1.0=E:38072.1.1000.1 E:38072.1.5=00_0e_a6_51_f9_19_00_00 E:38072.1.10=3
16:37:06.081091 arp who-has colorprinter.cork.lincor.com tell netscreen.cork.lincor.com
16:37:07.085342 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:37:07.234749 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:37:07.234809 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:07.234875 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:08.215186 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:14.442591 arp who-has homer.cork.lincor.com tell 192.168.3.244
16:37:14.661762 IP colorprinter.cork.lincor.com.netbios-dgm > 192.168.3.255.netbios-dgm: NBT UDP PACKET(138)
16:37:22.761320 IP exterity.cork.lincor.com.hbci > 255.255.255.255.snmptrap:  V2Trap(98)  system.sysUpTime.0=1 S:1.1.4.1.0=E:38072.1.1000.1 E:38072.1.5=00_0e_a6_51_f9_19_00_00 E:38072.1.10=3
16:37:23.222849 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:37:23.372249 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:37:23.372317 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:23.372382 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:24.352685 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:39.360368 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:37:39.509781 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:37:39.509839 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:39.509906 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:40.490229 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:49.192973 IP6 fe80::205:6bff:fe40:2cca > ff02::16: HBH ICMP6, multicast listener report v2, 11 group record(s), length 228
16:37:50.022991 IP 192.168.3.243 > SAP.MCAST.NET: igmp v2 report SAP.MCAST.NET
16:37:50.023981 IP 192.168.3.243 > 239.195.255.255: igmp v2 report 239.195.255.255
16:37:50.027995 IP 192.168.3.243 > 239.255.255.255: igmp v2 report 239.255.255.255
16:37:50.029991 IP 192.168.3.243 > 224.0.0.255: igmp v2 report 224.0.0.255
16:37:50.034003 IP6 fe80::205:6bff:fe40:2cca > ff02::16: HBH ICMP6, multicast listener report v2, 11 group record(s), length 228
16:37:53.364877 IP exterity.cork.lincor.com.hbci > 255.255.255.255.snmptrap:  V2Trap(98)  system.sysUpTime.0=1 S:1.1.4.1.0=E:38072.1.1000.1 E:38072.1.5=00_0e_a6_51_f9_19_00_00 E:38072.1.10=3
16:37:54.382979 IP6 fe80::205:6bff:fe40:2cca > ff02::16: HBH ICMP6, multicast listener report v2, 11 group record(s), length 228
16:37:54.521003 IP 192.168.3.243 > 239.255.255.255: igmp v2 report 239.255.255.255
16:37:55.488015 arp who-has jumpgate3.cork.lincor.com tell 192.168.3.107
16:37:55.637426 arp who-has homer.cork.lincor.com tell 192.168.3.107
16:37:55.637483 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:55.637764 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:56.617871 arp who-has wellgate.cork.lincor.com tell 192.168.3.107
16:37:56.792998 IP 192.168.3.243 > SAP.MCAST.NET: igmp v2 report SAP.MCAST.NET
16:37:58.155977 IP 192.168.3.243 > 224.0.0.255: igmp v2 report 224.0.0.255
16:37:58.951975 IP 192.168.3.243 > SAP.MCAST.NET: igmp v2 report SAP.MCAST.NET
16:37:59.223986 IP 192.168.3.243 > 239.195.255.255: igmp v2 report 239.195.255.255
16:38:02.986975 IP 192.168.3.243 > 239.255.255.255: igmp v2 report 239.255.255.255

--------------010902090903080502080205--
