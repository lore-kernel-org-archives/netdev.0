From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: Re: ESP interfamily tunnel bug?
Date: Thu, 19 Apr 2007 16:51:44 +0900
Message-ID: <46271F90.6020207@miyazawa.org>
References: <1176891019.4625ee8b2ab66@webmail.hiit.fi> <4626F8C9.3030904@miyazawa.org> <1176960061.4626fc3db4759@webmail.hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org, miika@iki.fi
To: Diego Beltrami <Diego.Beltrami@hiit.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:36310 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1031178AbXDSHw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2007 03:52:28 -0400
In-Reply-To: <1176960061.4626fc3db4759@webmail.hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm using a machine and a dummy device.
So I'm using loopback communication.
Yes, the backtrace is correct.

I thought you used loopback communication to test the modes
because your configuration showed that the dummy device has
some addresses and you did ping from the address to the other
address.

Is not right? Did you use two or more hosts?

I do not have enough environment to test today.
I'll test it with a couple of machines tomorrow.

Diego Beltrami wrote:
> Hi Kazunori,
> thanks for reply.
> 
> In your backtrace I see that there are both input and output functions calls. Is
> it the right way?
> 
> One more thing, were your two hosts you used located on the same network?
> In fact it seems that if the machines are on the same network, this bug doesn't
> manifest.
> 
> Thanks,
> 
> Diego
> 
> 
>> Hello Diego,
>>
>> I tried to reproduce the bug. But I got a panic of the kernel :-<
>> I'm using current net-2.6.
>>
>> I suspect that some special routing for loopback is related
>> because I checked with kdb and got the backtrace like
>>
>> 	fib_sync_down
>> 	ipv6_rcv
>> 	netif_receive_skb
>> 	__mod_timer
>> 	net_rx_action
>> 	__do_softirq
>> 	do_softirq
>> 	local_bh_enable
>> 	dev_queue_xmit
>> 	neigh_resolve_output
>> 	ip_output
>> 	xfrm4_output_finish
>> 	xfrm4_output
>> 	ip_generic_getfrag
>> 	ip6_push_pending_frames
>>
>> I think ip_rcv or some IPv4 function should be called between
>> netif_receive_skb
>> and ipv6_rcv.
>>
>> Anyway I could not classify the way to make a panic.
>> I'll trace it.
>>
>> Thank you,
>>
>> Diego Beltrami wrote:
>>> Hi,
>>>
>>> we have discovered a routing related problem in ESP tunnel and beet mode.
>>> We don't know whether it is a bug in the XFRM, or just in the way the
>>> virtual addresses and the corresponding routes are set-up. We set up a
>>> dummy0 device for the virtual addresses:
>>>
>>> root@mekong:~# ip addr show dummy0
>>> 5: dummy0: <BROADCAST,NOARP,UP,10000> mtu 1500 qdisc noqueue
>>>      link/ether 92:09:fe:11:81:1b brd ff:ff:ff:ff:ff:ff
>>>      inet6 2001:72:e6d3:1cf3:e11d:5bb0:b99:e85e/28 scope global
>>>         valid_lft forever preferred_lft forever
>>>      inet6 2001:74:32e0:df36:e862:3963:523e:dd7d/28 scope global
>>>         valid_lft forever preferred_lft forever
>>>      inet6 2001:73:d3a8:8723:d572:7549:7f2c:e590/28 scope global
>>>         valid_lft forever preferred_lft forever
>>>      inet6 2001:75:a2e6:aad6:e901:dd1c:ba95:e300/28 scope global
>>>         valid_lft forever preferred_lft forever
>>>      inet6 fe80::9009:feff:fe11:811b/64 scope link
>>>         valid_lft forever preferred_lft forever
>>>
>>> And then we have routes for the virtual addresses:
>>>
>>> root@mekong:~# ip -6 route
>>> 2001:72:e6d3:1cf3:e11d:5bb0:b99:e85e dev dummy0  metric 1024  expires
>>> 21334305sec mtu 1500 advmss 1440 metric 10 4294967295
>>> 2001:73:d3a8:8723:d572:7549:7f2c:e590 dev dummy0  metric 1024  expires
>>> 21334305sec mtu 1500 advmss 1440 metric 10 4294967295
>>> 2001:74:32e0:df36:e862:3963:523e:dd7d dev dummy0  metric 1024  expires
>>> 21334305sec mtu 1500 advmss 1440 metric 10 4294967295
>>> 2001:75:a2e6:aad6:e901:dd1c:ba95:e300 dev dummy0  metric 1024  expires
>>> 21334305sec mtu 1500 advmss 1440 metric 10 4294967295
>>> 2001:70::/28 dev dummy0  metric 256  expires 21334305sec mtu 1500 advmss
>>> 1440 metric 10 4294967295
>>> fe80::/64 dev dummy0  metric 256  expires 21334305sec mtu 1500 advmss 1440
>>> metric 10 4294967295
>>> ff00::/8 dev eth0  metric 256  expires 21325454sec mtu 1500 advmss 1440
>>> metric 10 4294967295
>>> ff00::/8 dev dummy0  metric 256  expires 21334305sec mtu 1500 advmss 1440
>>> metric 10 4294967295
>>> unreachable default dev lo  proto none  metric -1  error -101 metric 10
>>> 255
>>>
>>> ...and set-up policies and associations. The virtual IPv6 addresses
>>> are inner and IPv4 addresses are outer addresses:
>>>
>>> root@mekong:~/projects/hipl--userspace--2.6# ip xfrm policy show
>>> src 2001:76:7d5a:88d7:51af:cdd1:6bf5:3d15/128 dst
>>> 2001:74:32e0:df36:e862:3963:523e:dd7d/128
>>>          dir in priority 0
>>>          tmpl src c1a7:bb82:: dst c0a8:65::
>>>                  proto esp reqid 0 mode beet
>>> src 2001:74:32e0:df36:e862:3963:523e:dd7d/128 dst
>>> 2001:76:7d5a:88d7:51af:cdd1:6bf5:3d15/128
>>>          dir out priority 0
>>>          tmpl src c0a8:65:: dst c1a7:bb82::
>>>                  proto esp reqid 0 mode beet
>>>
>>> root@mekong:~/projects/hipl--userspace--2.6# ip xfrm state show
>>> src 193.167.187.130 dst 192.168.0.101
>>>          proto esp spi 0xf556c7c7 reqid 0 mode beet
>>>          replay-window 0
>>>          auth sha1 0xab327b944011c94a0c54a097b4752e23f377ff34
>>>          enc aes 0x882a334830b1cd14b9e411ec37a4242f
>>>          encap type espinudp-nonike sport 50500 dport 50500
>>>                addr 193.167.187.130
>>>          sel src 2001:76:7d5a:88d7:51af:cdd1:6bf5:3d15/0
>>>              dst 2001:74:32e0:df36:e862:3963:523e:dd7d/0
>>>              src 192.168.0.101 dst 193.167.187.130
>>>          proto esp spi 0x1663f3a4 reqid 0 mode beet
>>>          replay-window 0
>>>          auth sha1 0x9f07dabce4abf2ebfe45e247ede2cf15f9156a13
>>>          enc aes 0xfc50593b9af6d296b042a16ca00bad20
>>>          encap type espinudp-nonike
>>>              sport 50500 dport 50500 addr 192.168.0.101
>>>          sel src 2001:74:32e0:df36:e862:3963:523e:dd7d/0
>>>              dst 2001:76:7d5a:88d7:51af:cdd1:6bf5:3d15/0
>>>
>>> And then we try to ping6 the virtual address:
>>>
>>> root@mekong:~/projects/hipl--userspace--2.6# ping6 -I
>>> 2001:0074:32e0:df36:e862:3963:523e:dd7d
>>> 2001:76:7d5a:88d7:51af:cdd1:6bf5:3d15
>>> PING
>>>
>> 2001:76:7d5a:88d7:51af:cdd1:6bf5:3d15(2001:76:7d5a:88d7:51af:cdd1:6bf5:3d15)
>>> from 2001:74:32e0:df36:e862:3963:523e:dd7d : 56 data bytes
>>> ping: sendmsg: Network is unreachable
>>> ping: sendmsg: Network is unreachable
>>>
>>> Tcpdump shows no traffic at the host. We can repeat the problem both with
>>> tunnel and beet modes in 2.6.21-rc6 (and also in 2.6.17.14).
>>>
>>> I have tried also "ip rule stuff" but it seems that it does not rule with
>>> IPv6 :) It does help either to reduce the number of virtual addresses to a
>>> single one. It is weird that the ESP actually works some combinations of
>>> virtual addresses (4 of 16) in both directions, or works unidirectionally
>>> on some and does not work at all on the rest. I verified the
>>> unidirectional property using a simple UDP based application: sender xmits
>>> UDP packet, receiver gets it ok, but cannot respond. So, the problem is in
>>> the transmission of packets.
>>>
>>> I traced the ENETUNREACH in the kernel side to here:
>>>
>>> net/ipv4/route.c:ip_route_output_slow:
>>>          if (fib_lookup(&fl, &res)) {
>>>          ....
>>>                 if (dev_out)
>>>                          dev_put(dev_out);
>>>                  err = -ENETUNREACH;
>>>
>>> FIB lookup up is returning an error net/ipv4/fib_rules:
>>>
>>> int fib_lookup(const struct flowi *flp, struct fib_result *res)
>>> {
>>> ...
>>>          hlist_for_each_entry_rcu(r, node, &fib_rules, hlist) {
>>> ...
>>>                  case RTN_UNREACHABLE:
>>>                          rcu_read_unlock();
>>>                          return -ENETUNREACH;
>>>
>>> I wonder if the problem is related to one that Yoshifugi has filed:
>>>
>>> http://bugzilla.kernel.org/show_bug.cgi?id=8349
>>>
>>> The bug does not usually occur with machines that in the same
>>> physical network, so I guess it is a routing problem. Any ideas or hints?
>>>
>>> Miika & Diego
>>>
>>>
>>>
>>>
>>>
>> -
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Kazunori Miyazawa
