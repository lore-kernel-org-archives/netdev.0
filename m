From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] 1/1 net: packet: Keep 802.1Q VLAN tag in packet on SOCK_DGRAM
 socket - resend
Date: Tue, 05 Jan 2010 06:17:00 +0100
Message-ID: <4B42CB4C.9010508@trash.net>
References: <001801ca8d1d$90c68de0$b253a9a0$@name> <4B41F292.8080908@trash.net> <001b01ca8d52$817d07d0$84771770$@name> <4B421785.6090403@trash.net> <001c01ca8d60$eda21640$c8e642c0$@name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: uaca@alumni.uv.es, johann.baudy@gnu-log.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Milan Dadok <milan@dadok.name>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751779Ab0AEFRH@vger.kernel.org>
In-Reply-To: <001c01ca8d60$eda21640$c8e642c0$@name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milan Dadok wrote:
>> Patrick McHardy wrote:
>>> Currently pseudo-header contains for OUTGOING packet on physical card (vlan10@eth1)
>>> a) HW accelarated network card  
>>> protocol = ethertype IPv4 (0x0800)
>>> tci = vlan number = 10
>>> and data starts with 4500 0028
>>>
>>> b) non HW accelerated network card 
>>> protocol = ethertype 802.1Q (0x8100)
>>> tci = 0
>>> and data starts with 4500 0028
>>> vlan tci and real protocol number (ARP,IPV4,IPV6) of data is lost 
>>>
>> As mentioned in the text I quoted, this is apparently what is
>> intended for SOCK_DGRAM packet sockets. The accelerated case is
>> inconsistent and vlan_tci should be cleared I guess.
>>
>> I agree that sll_protocol should reflect the network protocol
>> in this case however.
> 
> There are probablly two solution SOCK_DGRAM
> A. sll_protocol will have outer network protokol and packet data will have all data after that network protokol field
> 	(sll tci will be <>0 only with VLAN acceleration)
> 
> B. ssl_protocol will have the most inner network protokol (Ipv4, ARP, Ipv6)
> 	and cooked sll will have fields for restore all encapsulation protocols
> 	(on eth1 I need to know, if packet is send with vlan 1010 in vlan 10 or as vlan 10 in vlan 1010)

I think it should indicate the outer network protocol, IOW the
protocol of the header at offset 0. But as the data doesn't contain
any link layer headers, vlan_tci should always be zero for SOCK_DGRAM
sockets for consistency.

If you want the link layer data, you simply shouldn't be using
SOCK_DGRAM sockets. I don't know why libpcap uses them when no
device is specified, I guess it simply can't build proper BPF
filters without knowing the link layer type. Which actually
should be possible, this seems like a limitation in libpcap's
BPF compiler.

>>> I have no problems with received packets, only outgoing packet have problem.
>>> I think that out packet on SOCK_DGRAM sockets MUST BE in same format as in (received) packet on same interface.
>>> Can we agree on this?
>> Yes, agreed.
> 
> Now receive path is working as in solution A (if I remember correctly from my tests)
> - packet data with all 802.1Q tags are send throu SOCK_DGRAM in same format as in SOCK_RAW (expect MAC header)
>   (on HW vlan accel first VLAN tag is in tci field of TPACKET_V2)
> 
> Outgoing packet in SOCK_RAW is same as in receive.
> Outgoing packet in SOCK_DGRAM - solution B with invalid sll_protokol
> 
> My patch is trying to change behaviour of outgoing packet in SOCK_DGRAM to same format as in received SOCK_DGRAM or SOCK_RAW

So basically what seems to be missing is a) not including vlan_tci
and b) figuring out the higher layer protocol for inclusion in
sll_protocol. The second part should be easy to fix for nested
VLANs. It gets quite complicated however if you consider setups
using nested VLANs with non-VLAN devices in between, like
vlan10@gretap0@vlan100.

> PS. There is one BIG question - how can I write kernel filter for filter explicit vlan number,
> which can be used at the same time on HW vlan accelerated card (outer VLAN is in tci) and
> non HW vlan accelerated card (outer VLAN is at the beggining of packet data)
> 
> Only solution I found, is to use user level filter and recreate vlan tag from sll tci in userspace before running filter.

To do this in the kernel, you'd have to add a new ancillary data
filter type to net/core/filter.c using vlan_get_tag().
