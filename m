From: Patrick McHardy <kaber@trash.net>
Subject: Re: Troubles with NFS & ip_conntrack: packets go to wrong mac
Date: Thu, 13 Feb 2003 17:40:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E4BCA83.4060304@trash.net>
References: <3E4A7ECB.1020207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <3E4A7ECB.1020207@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Some of the information in my last mail was wrong, i'll cut-and-paste 
the information entered into the netfilter
bugtracking system, maybe someone has a suggestion. The important part 
is the packets checksum turns out to
be right if the destination ip is replaced by the ip the mac belongs to, 
so the mac is correct.

--cut-n-paste--

With ip_conntrack loaded on the nfs server, client reads time out.
Clients start logging:

UDP: short packet: 192.168.0.1:0 0/120 to 192.168.0.23:0
UDP: short packet: 192.168.0.1:6439 28562/120 to 192.168.0.23:60558

tcpdump shows corrupted packets:
0:e0:7d:74:ab:cc 0:e0:7d:74:ab:cd 0800 1514: 192.168.0.1 > 192.168.0.223: (frag
42878:1480@4440+) (ttl 64, len 1500, bad cksum 29ff!)
0:e0:7d:74:ab:cc 0:e0:7d:74:ab:cd 0800 1514: 192.168.0.1 > 192.168.0.223: (frag
42879:1480@4440+) (ttl 64, len 1500, bad cksum 29fe!)

0:e0:7d:74:ab:cd is not the mac of 192.168.0.223 but 192.168.0.23. Both are
nfs-clients. If more nfs-clients show up more incorrect destination ips appear.
The packets checksum is correct if the (incorrect) destination ip is replaced by
the correct destination ip. Only single fragments have incorrect destination,
the remaining fragments of a packet are fine. Packets verified (checksum) in
ip_finish_output2 show no corruption.

Neighbour table of nfs server:
192.168.0.223 dev eth0 lladdr 00:e0:29:3c:c1:c9 nud reachable
192.168.0.23 dev eth0 lladdr 00:e0:7d:74:ab:cd nud reachable

The problem goes away as soon as ip_conntrack is unloaded. Another possibility
is to set the interface mtu to 1486 on the nfs server.

CPU: AMD-K6(tm) 3D processor, 256MB RAM
Kernel: 2.4.21-pre3 with few netfilter patches applied, problem also exists in
vanilla kernel, first noticed around 2.4.17

lspci:
00:00.0 Host bridge: Acer Laboratories Inc. [ALi] M1541 (rev 04)
00:01.0 PCI bridge: Acer Laboratories Inc. [ALi] M5243 (rev 04)
00:07.0 ISA bridge: Acer Laboratories Inc. [ALi] M1533 PCI to ISA Bridge
[Aladdin IV] (rev c3)
00:08.0 VGA compatible unclassified device: S3 Inc. 86c864 [Vision 864 DRAM] vers 0
00:09.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139 (rev 10)
00:0a.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139 (rev 10)
00:0f.0 IDE interface: Acer Laboratories Inc. [ALi] M5229 IDE (rev c2)

--end-cut-n-paste--

Bye,
Patrick



Patrick McHardy wrote:

> I've been experiencing strange problems with nfs and ip_conntrack for 
> a while now,
> unfortunately noone so far was able to help. The problem occurs when 
> ip_conntrack
> is loaded on the nfs server. nfs reads hang and the clients start logging
>
> UDP: short packet: 192.168.0.1:0 0/120 to 192.168.0.23:0
> UDP: short packet: 192.168.0.1:6439 28562/120 to 192.168.0.23:60558
>
> There are two ways to make it work: 1. remove ip_conntrack or 2. set 
> mtu to 1484 on
> the nfs server. One suspicion was ip_conntrack breaking udp path mtu 
> discovery
> since it seems to defragment packets with DF|MF and refragment them 
> (with possibly
> different mtu) at POSTROUTING. This doesn't seem to be the problem, 
> but i noted the
> nfs server sends out fragments with wrong destination mac.
>
> This is a packet captured on 192.168.0.23:
> 0:e0:7d:74:ab:cc 0:e0:7d:74:ab:cd 0800 1514: 192.168.0.1 > 
> 192.168.0.223: (frag 44777:1480@4440+) (ttl 64, len 1500, bad cksum 
> 2294!)
>
> This happens every 1-30 seconds. I never saw more than one misdirected 
> fragment per packet.
>
> Relevent parts from neighbour table:
> 192.168.0.223 dev eth0 lladdr 00:e0:29:3c:c1:c9 nud reachable
> 192.168.0.23 dev eth0 lladdr 00:e0:7d:74:ab:cd nud reachable
>
> On 192.168.0.223 packets for 192.168.0.23 show up. Both clients time 
> out during reassembly.
> I placed some printks though the netfilter code and ip_output.c but 
> couldn't find any further
> pointers. I looked for broken checksums (something seems to alter the 
> ip after checksumming)
> in ip_finish_output2, but everything is ok there. I can't see anything 
> netfilter related touching packets after that.
> Any help and/or pointers where to look further would be appreciated.
>
> Regards,
> Patrick
>
