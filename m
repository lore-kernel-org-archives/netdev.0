From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v2 net] bonding: Fix stacked device detection in arp monitoring
Date: Thu, 8 May 2014 12:25:12 +0800
Message-ID: <536B0728.3090608@huawei.com>
References: <20140507185937.GV6295@redhat.com> <20140507201019.GW6295@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>,
	<netdev@vger.kernel.org>, Andy Gospodarek <andy@greyhouse.net>,
	Patric McHardy <kaber@trash.net>
To: Veaceslav Falico <vfalico@redhat.com>,
	Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:43933 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaEHE0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 00:26:38 -0400
In-Reply-To: <20140507201019.GW6295@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/8 4:10, Veaceslav Falico wrote:
> On Wed, May 07, 2014 at 08:59:37PM +0200, Veaceslav Falico wrote:
>> Anyway, so the only concern is:
>>
>> bond0 -> whatever1 -> vlan1 -> whatever2 -> vlan2 -> whatever3_IP
>>                     \-> vlan3
>> bond_check_path start==bond0 idx=0
>> finds vlan1, tag[0] set, recursion start==vlan1 idx=1
>> \->
>>     bond_check_path start==vlan1 idx=1
>>     finds vlan2, tag[1] set, recursion start==vlan2 idx=2
>>     \->    returns right away with false as idx >= 2.
>>
>>     finds vlan3 (!!!) that isn't related with whatever_IP, tag[1] set with the
>>     wrong vlan, recursion start==vlan3 idx=2
>>     \->    return right away with false as idx >= 2.
>>
>>     finds whatever3_IP, returns true.
>> returns true
> 
> Here's a proof of concept (btw, if somebody wants this script - I can put
> it somewhere), with your patch applied:
> 
> bond0 is configured in mode 1 with eth2 being the primary slave, and (one of)
> the arp_ip_targets is 192.168.10.254 (bond2's subnet /24).
> 
> Initially everything works:
> 
> darkmag:~#/home/vfalico/tmp/asciinet/netstruct.pl
> +---------------+              +-------------+           +--------------+
> |     bond1     |  neighbour   |  bond1.11   |  master   |    bond2     |
> |  192.168.2.1  | ------------ |             | <-------- | 192.168.10.1 |
> +---------------+              +-------------+           +--------------+
>   |
>   | master
>   v
> +---------------+              +-------------+           +--------------+           +------+
> |  bridge0.15   |  neighbour   |   bridge0   |  master   |    bond0     |  master   | eth2 |
> |               | ------------ | 192.168.3.1 | --------> |              | --------> |      |
> +---------------+              +-------------+           +--------------+           +------+
>                                                            |
>                                                            | master
>                                                            v
> +---------------+                                        +--------------+
> |    dummy0     |                                        |     eth0     |
> +---------------+                                        +--------------+
> ...
> 
> tcpdump from eth2:
> 21:57:54.990521 00:22:64:b9:87:05 > Broadcast, ethertype 802.1Q (0x8100), length 50: vlan 15, p 0, ethertype 802.1Q, vlan 11, p 0, ethertype ARP, Request who-has 192.168.10.254 tell 192.168.10.1, length 28
> 
> so, tag 11 (via bond1.11) and tag 15 (via bridge0.15), all fine.
> 
> Now:
> 
> darkmag:~#echo -bond2 > /sys/class/net/bonding_masters darkmag:~#vconfig add bond1 12
> Added VLAN with VID == 12 to IF -:bond1:-
> darkmag:~#ifup bond2
> Determining if ip address 192.168.10.1 is already in use for device bond2...
> darkmag:~#/home/vfalico/tmp/asciinet/netstruct.pl
> +-------------+           +---------------+              +----------+           +--------------+
> | bridge0.15  |  master   |     bond1     |  neighbour   | bond1.11 |  master   |    bond2     |
> |             | <-------- |  192.168.2.1  | ------------ |          | <-------- | 192.168.10.1 |
> +-------------+           +---------------+              +----------+           +--------------+
>   |                         |
>   | neighbour               | neighbour
>   |                         |
> +-------------+           +---------------+
> |   bridge0   |           |   bond1.12    |
> | 192.168.3.1 |           |               |
> +-------------+           +---------------+
>   |
>   | master
>   v
> +-------------+  master   +---------------+
> |    bond0    | --------> |     eth2      |
> +-------------+           +---------------+
>   |
>   | master
>   v
> +-------------+           +---------------+
> |    eth0     |           |    dummy0     |
> +-------------+           +---------------+
> ...
> 
> and tcpdump shows:
> 
> 21:58:44.136522 00:22:64:b9:87:05 > Broadcast, ethertype 802.1Q (0x8100), length 50: vlan 15, p 0, ethertype 802.1Q, vlan 12, p 0, ethertype ARP, Request who-has 192.168.10.254 tell 192.168.10.1, length 28
> 
> Notice vlan 12 instead of vlan 11.
> 
> So I guess that, till the end, we indeed can't guarantee the ordering and should,
> actually, go via "the longest" route...
> 
> Hope that helps.
> 
> .

Great analysis, But it is really hard to read, I think I reproduce this situation more simple.

ip link add link eth10 eth10.10 type vlan proto 802.1ad id 10
ip link add link eth10.10 eth10.10.100 type vlan proto 802.1q id 100

ifconfig eth10.10.100 192.168.10.37
ping 192.168.10.32

then show the tcpdump:
tcpdump: listening on eth10, link-type EN10MB (Ethernet), capture size 96 bytes
00:47:48.940194 54:89:98:f3:f1:b7 (oui Unknown) > Broadcast, ethertype Unknown (0x88a8), length 50:
        0x0000:  ffff ffff ffff 5489 98f3 f1b7 88a8 000a  ......T.........
        0x0010:  8100 0064 0806 0001 0800 0604 0001 5489  ...d..........T.
        0x0020:  98f3 f1b7 c0a8 0a25 0000 0000 0000 c0a8  .......%........
        0x0030:  0a20

obviously the first tag is 88a8 and the second tag is 8100,

then I add more vlan dev:

ip link add link eth10.10.100 eth10.10.100.200 type vlan proto 802.1q id 100.200

then show the tcpdump:

00:43:50.541466 54:89:98:f3:f1:b7 (oui Unknown) > Broadcast, ethertype Unknown (0x88a8), length 54:
        0x0000:  ffff ffff ffff 5489 98f3 f1b7 88a8 000a  ......T.........
        0x0010:  8100 0064 8100 00c8 0806 0001 0800 0604  ...d............
        0x0020:  0001 5489 98f3 f1b7 c0a8 1e25 0000 0000  ..T........%....
        0x0030:  0000 c0a8 1e20   

obviously the first tag is 88a8, the second is 8100, id is 100, and the third tag is 8100, id is 200.

So I think in this patch, the idx should not only limit to 2.

Ding




> 
