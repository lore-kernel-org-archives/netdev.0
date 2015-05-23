From: "Vittorio G (VittGam)" <linuxbugs@vittgam.net>
Subject: Re: [PATCH net] ipv4: Avoid crashing in =?UTF-8?Q?ip=5Ferror?=
Date: Sat, 23 May 2015 18:59:45 +0200
Message-ID: <f68c1ee01934e4ce4e4379af7a72327a@vittgam.net>
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
 <20150522040453.GC8530@1wt.eu> <87zj4x6iiz.fsf_-_@x220.int.ebiederm.org>
 <alpine.LFD.2.11.1505231158240.1796@ja.home.ssi.bg>
 <87oalb2w8l.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<security@kernel.org>, Greg KH <greg@kroah.com>,
	<luto@amacapital.net>, Willy Tarreau <w@1wt.eu>
To: <ebiederm@xmission.com>, Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server1.vittgam.net ([213.239.197.142]:21169 "EHLO
	mail.vittgam.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758035AbbEWRAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2015 13:00:25 -0400
In-Reply-To: <87oalb2w8l.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 23.05.2015 16:40 ebiederm@xmission.com ha scritto:
> The reproducer was apparently:
> ip netns add ns0
> ip netns add ns1
> ip link add test0 type veth peer name test1
> ip link set test0 netns ns0
> ip link set test1 netns ns1
> ip netns exec ns0 sysctl net.ipv4.ip_forward=1
> ip netns exec ns1 sysctl net.ipv4.ip_forward=1
> ip netns exec ns0 sysctl net.ipv4.conf.all.accept_local=1
> ip netns exec ns1 sysctl net.ipv4.conf.all.accept_local=1
> ip netns exec ns0 sysctl net.ipv4.conf.test0.accept_local=1
> ip netns exec ns1 sysctl net.ipv4.conf.test1.accept_local=1
> ip netns exec ns0 sysctl net.ipv4.conf.all.send_redirects=0
> ip netns exec ns1 sysctl net.ipv4.conf.all.send_redirects=0
> ip netns exec ns0 sysctl net.ipv4.conf.test0.send_redirects=0
> ip netns exec ns1 sysctl net.ipv4.conf.test1.send_redirects=0
> ip netns exec ns0 ip addr add 10.10.10.1/24 dev test0
> ip netns exec ns1 ip addr add 10.10.10.2/24 dev test1
> ip netns exec ns0 ip link set up dev test0
> ip netns exec ns1 ip link set up dev test1
> ip netns exec ns0 ip route add 10.20.30.40 via 10.10.10.2 dev test0
> ip netns exec ns1 ip route add 10.20.30.40 via 10.10.10.1 dev test1
> ip netns exec ns0 iptables -t mangle -A PREROUTING -i test0 -j TTL --ttl-inc 1
> ip netns exec ns1 iptables -t mangle -A PREROUTING -i test1 -j TTL --ttl-inc 1
> ip netns exec ns0 ping -s 1400 -f -w 5 10.20.30.40
> ip netns delete ns0
> ip netns delete ns1

Yes, and the commands were ultimately wrapped in a "while true; do ... done" loop,
since the crash would not happen every time, but it eventually will, without the
patch.
