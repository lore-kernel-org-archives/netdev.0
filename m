From: Patrick McHardy <kaber@trash.net>
Subject: Troubles with NFS & ip_conntrack: packets go to wrong mac
Date: Wed, 12 Feb 2003 18:05:15 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <3E4A7ECB.1020207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: netdev@oss.sgi.com
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

I've been experiencing strange problems with nfs and ip_conntrack for a 
while now,
unfortunately noone so far was able to help. The problem occurs when 
ip_conntrack
is loaded on the nfs server. nfs reads hang and the clients start logging

UDP: short packet: 192.168.0.1:0 0/120 to 192.168.0.23:0
UDP: short packet: 192.168.0.1:6439 28562/120 to 192.168.0.23:60558

There are two ways to make it work: 1. remove ip_conntrack or 2. set mtu 
to 1484 on
the nfs server. One suspicion was ip_conntrack breaking udp path mtu 
discovery
since it seems to defragment packets with DF|MF and refragment them 
(with possibly
different mtu) at POSTROUTING. This doesn't seem to be the problem, but 
i noted the
nfs server sends out fragments with wrong destination mac.

This is a packet captured on 192.168.0.23:
0:e0:7d:74:ab:cc 0:e0:7d:74:ab:cd 0800 1514: 192.168.0.1 > 
192.168.0.223: (frag 44777:1480@4440+) (ttl 64, len 1500, bad cksum 2294!)

This happens every 1-30 seconds. I never saw more than one misdirected 
fragment per packet.

Relevent parts from neighbour table:
192.168.0.223 dev eth0 lladdr 00:e0:29:3c:c1:c9 nud reachable
192.168.0.23 dev eth0 lladdr 00:e0:7d:74:ab:cd nud reachable

On 192.168.0.223 packets for 192.168.0.23 show up. Both clients time out 
during reassembly.
I placed some printks though the netfilter code and ip_output.c but 
couldn't find any further
pointers. I looked for broken checksums (something seems to alter the ip 
after checksumming)
in ip_finish_output2, but everything is ok there. I can't see anything 
netfilter related touching packets after that.
Any help and/or pointers where to look further would be appreciated.

Regards,
Patrick
