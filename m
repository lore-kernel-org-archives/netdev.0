From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: TSO on veth device slows transmission to a crawl
Date: Tue, 7 Apr 2015 11:54:00 +0200 (CEST)
Message-ID: <alpine.LSU.2.20.1504071149280.31930@nerf40.vanv.qr>
References: <alpine.LSU.2.20.1504070014250.21650@nerf40.vanv.qr> <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares41.inai.de ([46.4.122.207]:53843 "EHLO ares41.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068AbbDGJyC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 05:54:02 -0400
In-Reply-To: <1428374918.25985.206.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2015-04-07 04:48, Eric Dumazet wrote:
>On Tue, 2015-04-07 at 00:45 +0200, Jan Engelhardt wrote:
>> I have here a Linux 3.19(.0) system where activated TSO on a veth slave 
>> device makes IPv4-TCP transfers going into that veth-connected container 
>> progress slowly.
>
>Nothing comes to mind. It would help if you could provide a script to
>reproduce the issue.

It seems IPsec is *also* a requirement in the mix.
Anyhow, script time!

<<<<< lpaa23-run.sh
#!/bin/sh -x
#lpaa23 has 10.10.40.129/24 on enp0s3
#remember to sysctl -w net.ipv4.conf.enp0s3.forwarding=1 etc.

ip x s a \
	src 10.10.40.129 dst 10.10.40.1 \
	proto esp spi 0xc3184540 reqid 4 mode tunnel \
	replay-window 32 flag af-unspec \
	auth-trunc "hmac(sha1)" 0x30ce4aa84fcc0e11f2d1567b4bdd5ba619b2dd77 96 \
	enc "cbc(aes)" 0x4e2acb3899f8d6b7b472de59535c2fd7
ip x s a \
	src 10.10.40.1 dst 10.10.40.129 \
	proto esp spi 0xc8141c39 reqid 4 mode tunnel \
	replay-window 32 flag af-unspec \
	auth-trunc "hmac(sha1)" 0xbf06bfd2e30a0f043f6c426acd5758112133ffc8 96 \
	enc "cbc(aes)" 0x2d6da3e595d04d2ed9aa89676ad3dabd
ip x p a \
	src 10.10.40.1/32 dst 10.10.23.0/24 \
	dir fwd priority 2851 ptype main \
	tmpl src 10.10.40.1 dst 10.10.40.129 \
		proto esp reqid 4 mode tunnel
ip x p a \
	src 10.10.40.1/32 dst 10.10.23.0/24 \
	dir in priority 2851 ptype main \
	tmpl src 10.10.40.1 dst 10.10.40.129 \
		proto esp reqid 4 mode tunnel
ip x p a \
	src 10.10.23.0/24 dst 10.10.40.1/32 \
	dir out priority 2851 ptype main \
	tmpl src 10.10.40.129 dst 10.10.40.1 \
		proto esp reqid 4 mode tunnel


ip link add name ext0 type veth peer name int0
ip addr add 10.10.40.129/32 dev ext0
ip link set ext0 up
ip route add 10.10.23.23/32 dev ext0
ip netns add vnode0
ip link set dev int0 netns vnode0
ip netns exec vnode0 ip addr add 10.10.23.23/32 dev int0
ip netns exec vnode0 ip link set dev lo up
ip netns exec vnode0 ip link set dev int0 up
ip netns exec vnode0 ip route add 10.10.40.129/32 dev int0
ip netns exec vnode0 ip route replace default via 10.10.40.129

xexit ()
{
	trap "" EXIT INT
	ip x p d src 10.10.40.1/32 dst 10.10.23.0/24 dir fwd
	ip x p d src 10.10.40.1/32 dst 10.10.23.0/24 dir in
	ip x p d src 10.10.23.0/24 dst 10.10.40.1/32 dir out
	ip x s d src 10.10.40.129 dst 10.10.40.1 proto esp spi 0xc3184540
	ip x s d src 10.10.40.1 dst 10.10.40.129 proto esp spi 0xc8141c39
	ip link del ext0
	ip netns delete vnode0
}

trap xexit EXIT INT
ip netns exec vnode0 netserver -D
>>>

<<< lpaa24-run.sh
#!/bin/sh -x
#lpaa24 has 10.10.40.1/24 on eth0

ip x s a \
	src 10.10.40.1 dst 10.10.40.129 \
        proto esp spi 0xc8141c39 reqid 4 mode tunnel \
        replay-window 32 flag af-unspec \
        auth-trunc "hmac(sha1)" 0xbf06bfd2e30a0f043f6c426acd5758112133ffc8 96 \
        enc "cbc(aes)" 0x2d6da3e595d04d2ed9aa89676ad3dabd
ip x s a \
	src 10.10.40.129 dst 10.10.40.1 \
        proto esp spi 0xc3184540 reqid 4 mode tunnel \
        replay-window 32 flag af-unspec \
        auth-trunc "hmac(sha1)" 0x30ce4aa84fcc0e11f2d1567b4bdd5ba619b2dd77 96 \
        enc "cbc(aes)" 0x4e2acb3899f8d6b7b472de59535c2fd7
ip x p a \
	src 10.10.23.0/24 dst 10.10.40.1/32 \
        dir fwd priority 1827 ptype main \
        tmpl src 10.10.40.129 dst 10.10.40.1 \
                proto esp reqid 4 mode tunnel
ip x p a \
	src 10.10.23.0/24 dst 10.10.40.1/32 \
        dir in priority 1827 ptype main \
        tmpl src 10.10.40.129 dst 10.10.40.1 \
                proto esp reqid 4 mode tunnel
ip x p a \
	src 10.10.40.1/32 dst 10.10.23.0/24 \
        dir out priority 1827 ptype main \
        tmpl src 10.10.40.1 dst 10.10.40.129 \
                proto esp reqid 4 mode tunnel
ip r a \
	10.10.23.0/24 via 10.10.40.129 dev eth0  proto static  src 10.10.40.1 


xexit ()
{
	trap "" EXIT INT
	ip x p d src 10.10.23.0/24 dst 10.10.40.1/32 dir fwd
	ip x p d src 10.10.23.0/24 dst 10.10.40.1/32 dir in
	ip x p d src 10.10.40.1/32 dst 10.10.23.0/24 dir out
	ip x s d src 10.10.40.1 dst 10.10.40.129 proto esp spi 0xc8141c39
	ip x s d src 10.10.40.129 dst 10.10.40.1 proto esp spi 0xc3184540
}

trap xexit EXIT INT
netperf -H 10.10.23.23 -l 10
>>>
