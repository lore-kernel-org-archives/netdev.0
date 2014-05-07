From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v2 net] bonding: Fix stacked device detection in arp
 monitoring
Date: Wed, 7 May 2014 22:10:20 +0200
Message-ID: <20140507201019.GW6295@redhat.com>
References: <20140507185937.GV6295@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Ding Tianhong <dingtianhong@huawei.com>,
	Patric McHardy <kaber@trash.net>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793AbaEGUKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 16:10:46 -0400
Content-Disposition: inline
In-Reply-To: <20140507185937.GV6295@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 07, 2014 at 08:59:37PM +0200, Veaceslav Falico wrote:
>Anyway, so the only concern is:
>
>bond0 -> whatever1 -> vlan1 -> whatever2 -> vlan2 -> whatever3_IP
>					\-> vlan3
>bond_check_path start==bond0 idx=0
>finds vlan1, tag[0] set, recursion start==vlan1 idx=1
>\->
>	bond_check_path start==vlan1 idx=1
>	finds vlan2, tag[1] set, recursion start==vlan2 idx=2
>	\->	returns right away with false as idx >= 2.
>
>	finds vlan3 (!!!) that isn't related with whatever_IP, tag[1] set with the
>	wrong vlan, recursion start==vlan3 idx=2
>	\->	return right away with false as idx >= 2.
>
>	finds whatever3_IP, returns true.
>returns true

Here's a proof of concept (btw, if somebody wants this script - I can put
it somewhere), with your patch applied:

bond0 is configured in mode 1 with eth2 being the primary slave, and (one of)
the arp_ip_targets is 192.168.10.254 (bond2's subnet /24).

Initially everything works:

darkmag:~#/home/vfalico/tmp/asciinet/netstruct.pl
+---------------+              +-------------+           +--------------+
|     bond1     |  neighbour   |  bond1.11   |  master   |    bond2     |
|  192.168.2.1  | ------------ |             | <-------- | 192.168.10.1 |
+---------------+              +-------------+           +--------------+
   |
   | master
   v
+---------------+              +-------------+           +--------------+           +------+
|  bridge0.15   |  neighbour   |   bridge0   |  master   |    bond0     |  master   | eth2 |
|               | ------------ | 192.168.3.1 | --------> |              | --------> |      |
+---------------+              +-------------+           +--------------+           +------+
                                                            |
                                                            | master
                                                            v
+---------------+                                        +--------------+
|    dummy0     |                                        |     eth0     |
+---------------+                                        +--------------+
...

tcpdump from eth2:
21:57:54.990521 00:22:64:b9:87:05 > Broadcast, ethertype 802.1Q (0x8100), length 50: vlan 15, p 0, ethertype 802.1Q, vlan 11, p 0, ethertype ARP, Request who-has 192.168.10.254 tell 192.168.10.1, length 28

so, tag 11 (via bond1.11) and tag 15 (via bridge0.15), all fine.

Now:

darkmag:~#echo -bond2 > /sys/class/net/bonding_masters 
darkmag:~#vconfig add bond1 12
Added VLAN with VID == 12 to IF -:bond1:-
darkmag:~#ifup bond2
Determining if ip address 192.168.10.1 is already in use for device bond2...
darkmag:~#/home/vfalico/tmp/asciinet/netstruct.pl
+-------------+           +---------------+              +----------+           +--------------+
| bridge0.15  |  master   |     bond1     |  neighbour   | bond1.11 |  master   |    bond2     |
|             | <-------- |  192.168.2.1  | ------------ |          | <-------- | 192.168.10.1 |
+-------------+           +---------------+              +----------+           +--------------+
   |                         |
   | neighbour               | neighbour
   |                         |
+-------------+           +---------------+
|   bridge0   |           |   bond1.12    |
| 192.168.3.1 |           |               |
+-------------+           +---------------+
   |
   | master
   v
+-------------+  master   +---------------+
|    bond0    | --------> |     eth2      |
+-------------+           +---------------+
   |
   | master
   v
+-------------+           +---------------+
|    eth0     |           |    dummy0     |
+-------------+           +---------------+
...

and tcpdump shows:

21:58:44.136522 00:22:64:b9:87:05 > Broadcast, ethertype 802.1Q (0x8100), length 50: vlan 15, p 0, ethertype 802.1Q, vlan 12, p 0, ethertype ARP, Request who-has 192.168.10.254 tell 192.168.10.1, length 28

Notice vlan 12 instead of vlan 11.

So I guess that, till the end, we indeed can't guarantee the ordering and should,
actually, go via "the longest" route...

Hope that helps.
