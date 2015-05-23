From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] ipv4: Avoid crashing in ip_error
Date: Sat, 23 May 2015 09:40:10 -0500
Message-ID: <87oalb2w8l.fsf@x220.int.ebiederm.org>
References: <2b6d6ab2d8c35af3be55c82e507f5376@vittgam.net>
	<20150520025428.GA23304@kroah.com>
	<b5abf7328b22373e4ec18bd6da479431@vittgam.net>
	<06f5f10e9ee831f5a839c6ea24b94f64@vittgam.net>
	<d146b8b8a69462ced89a384e6be85b28@vittgam.net>
	<4cb068397127c2b2baee1f021b014b11@vittgam.net>
	<da006bc9072931406270f0fdda06045d@vittgam.net>
	<6056363be65a2c129551518da94bff20@vittgam.net>
	<87a8wx97er.fsf@x220.int.ebiederm.org>
	<ff82713d6862786de9784bd3c9c06bfa@vittgam.net>
	<20150522040453.GC8530@1wt.eu>
	<87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
	<alpine.LFD.2.11.1505231158240.1796@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Vittorio G \(VittGam\)" <linuxbugs@vittgam.net>,
	security@kernel.org, Greg KH <greg@kroah.com>, luto@amacapital.net,
	Willy Tarreau <w@1wt.eu>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34292 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757900AbbEWOpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2015 10:45:12 -0400
In-Reply-To: <alpine.LFD.2.11.1505231158240.1796@ja.home.ssi.bg> (Julian
	Anastasov's message of "Sat, 23 May 2015 12:20:05 +0300 (EEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> writes:

> 	Hello,
>
> On Fri, 22 May 2015, Eric W. Biederman wrote:
>
>> ip_error does not check if in_dev is NULL before dereferencing it.
>> 
>> IThe following sequence of calls is possible:
>> CPU A                          CPU B
>> ip_rcv_finish
>>     ip_route_input_noref()
>>         ip_route_input_slow()
>>                                inetdev_destroy()
>>     dst_input()
>> 
>> With the result that a network device can be destroyed while processing
>> an input packet.
>
> 	How can that happen in practice? May be network
> driver is missing a napi_disable() call in ndo_stop()?
> napi_disable is supposed to wait backlog before NETDEV_DOWN
> and NETDEV_UNREGISTER (where inetdev_destroy is called) handlers
> are notified. Any link to original crash report, info for used
> driver, etc?
>
> 	After commit 8030f54499925d ("[IPV4] devinet: Register inetdev 
> earlier.") dev->ip_ptr is always present while packets are
> processed, only in_dev->ifa_list can be NULL.

Interesting I see the dev_close in unregister_netdevice that should have
prevented this scenario.

The reproducer was apparently:
ip netns add ns0
ip netns add ns1
ip link add test0 type veth peer name test1
ip link set test0 netns ns0
ip link set test1 netns ns1
ip netns exec ns0 sysctl net.ipv4.ip_forward=1
ip netns exec ns1 sysctl net.ipv4.ip_forward=1
ip netns exec ns0 sysctl net.ipv4.conf.all.accept_local=1
ip netns exec ns1 sysctl net.ipv4.conf.all.accept_local=1
ip netns exec ns0 sysctl net.ipv4.conf.test0.accept_local=1
ip netns exec ns1 sysctl net.ipv4.conf.test1.accept_local=1
ip netns exec ns0 sysctl net.ipv4.conf.all.send_redirects=0
ip netns exec ns1 sysctl net.ipv4.conf.all.send_redirects=0
ip netns exec ns0 sysctl net.ipv4.conf.test0.send_redirects=0
ip netns exec ns1 sysctl net.ipv4.conf.test1.send_redirects=0
ip netns exec ns0 ip addr add 10.10.10.1/24 dev test0
ip netns exec ns1 ip addr add 10.10.10.2/24 dev test1
ip netns exec ns0 ip link set up dev test0
ip netns exec ns1 ip link set up dev test1
ip netns exec ns0 ip route add 10.20.30.40 via 10.10.10.2 dev test0
ip netns exec ns1 ip route add 10.20.30.40 via 10.10.10.1 dev test1
ip netns exec ns0 iptables -t mangle -A PREROUTING -i test0 -j TTL --ttl-inc 1
ip netns exec ns1 iptables -t mangle -A PREROUTING -i test1 -j TTL --ttl-inc 1
ip netns exec ns0 ping -s 1400 -f -w 5 10.20.30.40
ip netns delete ns0
ip netns delete ns1

With a NULL pointer dereference in ip_error at offset 0x108 which
appeared to correspond with the line:

	if (!IN_DEV_FORWARD(in_dev)) {

As did the debug information.

Plus there is not much other than in_dev that could be NULL in that
function.

Perhaps it is possible to transmit into a veth pair even when the
carrier is down?  Which could be a bug in the veth driver.

Eric
