From: Patrick McHardy <kaber@trash.net>
Subject: Re: net 00/05: routing based send-to-self implementation
Date: Fri, 14 Jan 2011 13:22:16 +0100
Message-ID: <4D303FF8.5000809@trash.net>
References: <20091203112550.15100.86217.sendpatchset@x2.localnet> <20110114101832.GA3170@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jonathan Corbet <corbet@lwn.net>,
	Boris Kocherov <bkocherov@gmail.com>
To: Kirill Smelkov <kirr@mns.spb.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34174 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab1ANMWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 07:22:13 -0500
In-Reply-To: <20110114101832.GA3170@tugrik.mns.mnsspb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.01.2011 11:18, Kirill Smelkov wrote:
>  [ Cc'ing Jonathan Corbet and a friend of mine ]
> 
> On Thu, Dec 03, 2009 at 12:25:52PM +0100, Patrick McHardy wrote:
>> These patches are yet another attempt at adding "send-to-self" functionality,
>> allowing to send packets between two local interfaces over the wire. Unlike
>> the approaches I've seen so far, this one is purely routing based.
>> Especially the oif classification should also be useful for different setups.
>>
>> The patchset consists of three parts:
>>
>> - the first three patches add oif classification to fib_rules. This can be
>>   used create special routing tables for sockets bound to an interface.
>>
>> - the fourth patch changes IPv4 and IPv6 to allow to delete the local rule
>>   with priority 0. This allows to re-create it using a lower priority and
>>   insert new rules below it to force packets with a local destination out
>>   on the wire.
>>
>> - the fifth patch adds a devinet sysctl to accept packets with local source
>>   addresses in fib_validate_source(). This one unfortunately seems to be
>>   necessary, I couldn't come up with a method based purely on adding more
>>   routes to fool fib_validate_source() into accepting those packets.
>>
>> Usage example:
>>
>> # move local routing rule to lower priority
>> ip rule add pref 1000 lookup local
>> ip rule del pref 0
>>
>> # only reply to ARP requests for addresses configured on the device
>> echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
>>
>> # configure device and force packets of bound sockets out on eth1
>> ip address add dev eth1 10.0.0.1/24
>> echo 1 > /proc/sys/net/ipv4/conf/eth1/accept_local
>> ip link set eth1 up
>> ip rule add pref 500 oif eth1 lookup 500
>> ip route add default dev eth1 table 500
>>
>> # configure device and force packets of bound sockets out on eth2
>> ip address add dev eth2 10.0.0.2/24
>> echo 1 > /proc/sys/net/ipv4/conf/eth2/accept_local
>> ip link set eth2 up
>> ip rule add pref 501 oif eth2 lookup 501
>> ip route add default dev eth2 table 501
>>
>> At this point packets between sockets bound to eth1/eth2 will go over the wire.
> 
> Patrick, thanks a lot for doing this!
> 
> Just a small follow-up: it is possible to setup such loops without
> requiring sockets to be bound to devices. The idea is to setup rules
> like
> 
>     $ ip rule add pref 100 to <ip-on-eth1> lookup 100
>     $ ip route add default dev eth0 table 100
> 
> so that on TX, packets go through appropriate interfaces.
> 
> And for RX, another rules like
> 
>     $ ip rule add pref 10 iif eth0 lookup local
> 
> so that packets can be received at all.
> 
> 
> I've spent several days to find this, debugging and tracing kernel and
> trying various variants on how to do it, so I though I'd better share
> the info for poor souls like me :)
> 
> For completeness, here is the script which will setup tap0/tap1 loop
> through virtual vde_switch.
> 
>  ( Jonathan, I though something like this could be useful for LDD4 in
>    revised snull not needing to play dirty tricks with IP addresses anymore )

Thanks for sharing this. Setups using this get pretty complicated,
I've done something similar recently to have packets loop through
the network stack twice using veth devices to perform double NAT
for remapping clashing networks. If I can get permission I'll post
that script as well.

> 
> 
> ---- 8< (mk-tap-loop.sh) ----
> #!/bin/sh -e
> 
> # reset interfaces
> ip link del tap0 2>/dev/null || :
> ip link del tap1 2>/dev/null || :
> 
> # create interfaces
> vde_tunctl -t tap0
> vde_tunctl -t tap1
> 
> # assign addresses
> ip addr add 192.168.23.10/24 dev tap0
> ip addr add 192.168.23.11/24 dev tap1
> 
> # put ifs up
> ip link set tap0 up
> ip link set tap1 up
> 
> # lower priority of kernel local table to 500
> ip rule del pref   0 lookup local 2>/dev/null || :
> ip rule del pref 500 lookup local 2>/dev/null || :
> ip rule add pref 500 lookup local
> 
> # on rx side handle packets by local table, so we can receive them
> echo 1 >/proc/sys/net/ipv4/conf/tap0/accept_local
> echo 1 >/proc/sys/net/ipv4/conf/tap1/accept_local
> ip rule del pref 10 2>/dev/null || :
> ip rule del pref 11 2>/dev/null || :
> ip rule add pref 10 iif tap0 lookup local
> ip rule add pref 11 iif tap1 lookup local
> 
> # tx
> ip rule del pref 100 2>/dev/null || :
> ip rule del pref 101 2>/dev/null || :
> ip rule add pref 100 to 192.168.23.10 lookup 100	# tap0 <- tap1
> ip rule add pref 101 to 192.168.23.11 lookup 101	# tap1 <- tap0
> 
> ip route flush table 100
> ip route flush table 101
> ip route add default dev tap1 table 100
> ip route add default dev tap0 table 101
> 
> 
> # ensure (visually) we've set up it ok
> 
> echo
> echo " >>> rules:"
> ip rule
> 
> echo
> echo " >>> tap(0|1) routing table:"
> #routel | grep '\<tap\(0\|1\)\>'
> ip route show table all | grep '\<tap\(0\|1\)\>'
> 
> # tx path
> echo
> echo " >>> checking routing for tx path:"
> ip route get 192.168.23.10 connected
> ip route get 192.168.23.11 connected
> 
> # rx path
> echo
> echo " >>> checking routing for rx path:"
> ip route get from 192.168.23.10 to 192.168.23.11 iif tap1
> ip route get from 192.168.23.11 to 192.168.23.10 iif tap0
> 
> 
> 
> # start switch and connect switch-tap0 and switch-tap1
> echo
> echo " >>> ready to start vde_switch and connect wires..."
> read
> screen sh -c 'screen sh -cx "sleep 4; vde_plug2tap tap0"; screen sh -cx "sleep 4; vde_plug2tap tap1"; sh -cx vde_switch'
> 
> 
> # now e.g. ping 192.168.23.11 sends packets to tap0 which are received
> # on tap1 and ICMP-ECHO'ed by kernel on tap1 and received on tap0.
> 

