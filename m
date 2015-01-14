From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: non-OVS based vxlan config broken on 3.19-rc ?!
Date: Wed, 14 Jan 2015 17:18:49 +0200
Message-ID: <54B688D9.8030101@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: tom Herbert <therbert@google.com>, thomas Graf <tgraf@suug.ch>,
	"Marcelo Leitner" <mleitner@redhat.com>,
	Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0058.outbound.protection.outlook.com ([157.55.234.58]:62719
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753156AbbANPf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 10:35:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Guys, just realized that non-OVS based vxlan config is broken with 
3.19-rc... I see that it works for me on 3.18.2 and breaks on 3.19-rc3 
(Linus tree). Tested over mlx4 (both offloaded and non offloaded modes) 
and igb, see below the simplest form I can see it breaks on 3.19-rcand 
works on 3.18

Looking on tcpdump and stats, the arp reply arrives to the 3.19-rc host 
NIC driver but is dropped along the stack beforehanded to the vxlan 
driver, not sure where and why...

Or.

> $ tcpdump -nni vxlan42 -e
> 16:48:40.961852 8e:c2:13:4f:97:6e > ff:ff:ff:ff:ff:ff, ethertype ARP 
> (0x0806), length 42: Request who-has 192.168.92.18 tell 192.168.92.17, 
> length 28
> 16:48:41.961864 8e:c2:13:4f:97:6e > ff:ff:ff:ff:ff:ff, ethertype ARP 
> (0x0806), length 42: Request who-has 192.168.92.18 tell 192.168.92.17, 
> length 28
> 16:48:42.979948 8e:c2:13:4f:97:6e > ff:ff:ff:ff:ff:ff, ethertype ARP 
> (0x0806), length 42: Request who-has 192.168.92.18 tell 192.168.92.17, 
> length 28
>
> $ tcpdump -nni eth3 -e
> 16:48:46.993870 00:02:c9:e9:bf:32 > 01:00:5e:00:00:2a, ethertype IPv4 
> (0x0800), length 92: 192.168.31.17.33434 > 239.0.0.42.4789: UDP, length 50
> 16:48:46.993905 f4:52:14:01:da:82 > 00:02:c9:e9:bf:32, ethertype IPv4 
> (0x0800), length 92: 192.168.31.18.39155 > 192.168.31.17.4789: UDP, 
> length 50
> 16:48:47.993855 00:02:c9:e9:bf:32 > 01:00:5e:00:00:2a, ethertype IPv4 
> (0x0800), length 92: 192.168.31.17.33434 > 239.0.0.42.4789: UDP, length 50
> 16:48:47.993881 f4:52:14:01:da:82 > 00:02:c9:e9:bf:32, ethertype IPv4 
> (0x0800), length 92: 192.168.31.18.39155 > 192.168.31.17.4789: UDP, 
> length 50
>
> $ nstat
> Wed Jan 14 16:54:04 2015
>
> #kernel
> IpInReceives                    2                  0.0
> IpInDelivers                    2                  0.0
> IpOutRequests                   4                  0.0
> IcmpOutErrors                   2                  0.0
> IcmpOutEchoReps                 2                  0.0
> IcmpMsgOutType8                 2                  0.0
> TcpInSegs                       1                  0.0
> TcpOutSegs                      1                  0.0
> UdpInDatagrams                  1                  0.0
> TcpExtTCPPureAcks               1                  0.0
> TcpExtTCPOrigDataSent           1                  0.0
> IpExtOutMcastPkts               1                  0.0
> IpExtInOctets                   124                0.0
> IpExtOutOctets                  670                0.0
> IpExtOutMcastOctets             78                 0.0
> IpExtInNoECTPkts                2                  0.0
>
> Every 1.0s: netstat -s -w
> Wed Jan 14 16:54:56 2015
>
> Ip:
>     1077125083 total packets received
>     182 with invalid addresses
>     0 forwarded
>     0 incoming packets discarded
>     1077124621 incoming packets delivered
>     545614475 requests sent out
> Icmp:
>     67936 ICMP messages received
>     60 input ICMP message failed.
>     ICMP input histogram:
>         destination unreachable: 3319
>         echo requests: 528
>         echo replies: 64089
>     71890 ICMP messages sent
>     0 ICMP messages failed
>     ICMP output histogram:
>         destination unreachable: 3542
>         echo request: 67821
>         echo replies: 527
> IcmpMsg:
>         InType0: 64089
>         InType3: 3319
>         InType8: 528
>         OutType0: 527
>         OutType3: 3542
>         OutType8: 67821
> UdpLite:
> IpExt:
>     InMcastPkts: 827
>     OutMcastPkts: 2993
>     InBcastPkts: 1424
>     InOctets: 2102729994314
>     OutOctets: 35397269627
>     InMcastOctets: 31854
>     OutMcastOctets: 237154
>     InBcastOctets: 453473
>     InNoECTPkts: 1440876685



# host A with IP address 192.168.31.17

IP=ip

# mlx4
ETH=eth0

$IP link del vxlan42
$IP link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dstport 
4789 dev $ETH
$IP link set vxlan42 up
ifconfig vxlan42 192.168.92.17/24
ifconfig vxlan42 mtu 1450

# plain ping
ping 192.168.31.18 -c 2
# encaped  ping <-- BREAKS
ping 192.168.92.18 -c 2

# host B with IP address 192.168.31.18

IP=ip

# mlx4
ETH=eth0

$IP link del vxlan42
$IP link add vxlan42 type vxlan id 42 group 239.0.0.42 ttl 10 dstport 
4789 dev $ETH
$IP link set vxlan42 up
ifconfig vxlan42 192.168.92.18/24
ifconfig vxlan42 mtu 1450

ping 192.168.31.17 -c 2
ping 192.168.92.17 -c 2
