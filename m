From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: ICMPv6 too big Packet will makes the network unreachable
Date: Wed, 14 Oct 2015 17:53:37 +0800
Message-ID: <CAJFZqHz=PjafQNmifksDPigfiUki1AF00Zj0Q6W-6t-o6gL1dA@mail.gmail.com>
References: <CAJFZqHz93RmSp369W508i8zbDmxhohG9n4UfxG1TnSxDPD4B=g@mail.gmail.com>
	<561E1DE8.6070400@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>
To: Sheng Yong <shengyong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:35796 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbbJNJxi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 05:53:38 -0400
Received: by qgt47 with SMTP id 47so37575478qgt.2
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 02:53:38 -0700 (PDT)
In-Reply-To: <561E1DE8.6070400@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 5:18 PM, Sheng Yong <shengyong1@huawei.com> wrote:
> Hi, Rongqing,
>
> Cced Martin KaFai Lau <kafai@fb.com>
>
> It seems you trigger the problem that I met before, here is the link of disucssion:
> http://www.spinics.net/lists/netdev/msg314717.html
>
> You can try these patches to check if they resolve your problem:
> 7035870d1219 | 2015-05-03 | ipv6: Check RTF_LOCAL on rt->rt6i_flags instead of rt->dst.flags
> 653437d02f1f | 2015-04-28 | ipv6: Stop /128 route from disappearing after pmtu update
>
> thanks,
> Sheng
>
> On 10/13/2015 3:09 PM, Li RongQing wrote:
>> 1. Machine with 2001:1b70:82a8:18:650:65:0:2 address, and receive wrong
>> icmp packets
>>     root@du1:~# ifconfig
>>     eth10.650 Link encap:Ethernet  HWaddr 74:c9:9a:a7:e5:88
>>               inet6 addr: fe80::76c9:9aff:fea7:e588/64 Scope:Link
>>               inet6 addr: 2001:1b70:82a8:18:650:65:0:2/80 Scope:Global
>>               UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>               RX packets:1 errors:0 dropped:0 overruns:0 frame:0
>>               TX packets:9 errors:0 dropped:0 overruns:0 carrier:0
>>               collisions:0 txqueuelen:0
>>               RX bytes:104 (104.0 B)  TX bytes:934 (934.0 B)
>>
>> 2. ICMPv6 packet is as below.
>>
>>    ###[ Ethernet ]###
>>      dst       = 74:C9:9A:A7:E5:88
>>      src       = ae:4f:44:f2:10:cc
>>      type      = 0x86dd
>>    ###[ IPv6 ]###
>>         version   = 6
>>         tc        = 0
>>         fl        = 0
>>         plen      = None
>>         nh        = ICMPv6
>>         hlim      = 64
>>         src       = 2001:1b70:82a8:18:650:65:0:4
>>         dst       = 2001:1b70:82a8:18:650:65:0:2
>>
>>    ###[ ICMPv6 Packet Too Big ]###
>>            type      = Packet too big
>>            code      = 0
>>            cksum     = None
>>            mtu       = 1280
>>
>>    ###[ IPv6 ]###
>>               version   = 6
>>               tc        = 0
>>               fl        = 0
>>               plen      = None
>>               nh        = ICMPv6
>>               hlim      = 255
>>               src       = 2001:1b70:82a8:18:650:65:0:2
>>               dst       = 2001:1b70:82a8:18:650:65:0:2
>>    ###[ ICMPv6 Neighbor Discovery - Neighbor Advertisement ]###
>>                  type      = Neighbor Advertisement
>>                  code      = 0
>>                  cksum     = None
>>                  R         = 1
>>                  S         = 0
>>                  O         = 1
>>                  res       = 0x0
>>                  tgt       = 2001:1b70:82a8:18:650:65:0:2
>>
>>    ##### Test #####
>>
>> 3. Send ICMPv6  with Scapy to trigger fault.
>>
>>    conf.iface='eth1'
>>    eth = Ether(src='ae:4f:44:f2:10:cc', dst='74:C9:9A:A7:E5:88')
>>    base = IPv6(src='2001:1b70:82a8:18:650:65:0:4',
>> dst='2001:1b70:82a8:18:650:65:0:2')
>>    ptb = ICMPv6PacketTooBig(type=2)
>>    packet = eth/base/ptb
>>    ptb_payload_na_base = IPv6(src='2001:1b70:82a8:18:650:65:0:2',
>> dst='2001:1b70:82a8:18:650:65:0:2')
>>    ptb_payload_na = ICMPv6ND_NA(type=136, tgt='2001:1b70:82a8:18:650:65:0:2')
>>    ptb_payload = ptb_payload_na_base/ptb_payload_na
>>    packet = packet/ptb_payload
>>    sendp(packet, iface="eth1.650", count=1)
>>
>> 4.  route information  will enter the faulty state after Wait 600 seconds,
>>
>>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>>    local 2001:1b70:82a8:18:650:65:0:2 dev lo  proto none  src
>> 2001:1b70:82a8:18:650:65:0:2  metric 0  expires 7sec mtu 1280
>>
>>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>>    local 2001:1b70:82a8:18:650:65:0:2 dev lo  proto none  src
>> 2001:1b70:82a8:18:650:65:0:2  metric 0  expires 3sec mtu 1280
>>
>>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>>    2001:1b70:82a8:18:650:65:0:2 dev eth10.650  src
>> 2001:1b70:82a8:18:650:65:0:2  metric 0
>>        cache
>>    root@du1:~#
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> .
>>
>
