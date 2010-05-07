From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 07 May 2010 17:18:06 +0200
Message-ID: <1273245486.2261.76.camel@edumazet-laptop>
References: <i2h571fb4001005031027y4a58c4dtfd28ddcdc08d8401@mail.gmail.com>
	 <l2k571fb4001005041008k9b129a06vf5e40db2d119434c@mail.gmail.com>
	 <20100504101301.5f4dd9c2@nehalam>
	 <g2p571fb4001005051103w67e1b9ddn3e8f7feb84d0559@mail.gmail.com>
	 <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273210774.2222.45.camel@edumazet-laptop>
	 <1273219222.2261.11.camel@edumazet-laptop>
	 <n2u571fb4001005070159y91d8b13crb20d2f14ea26dd1a@mail.gmail.com>
	 <1273225039.2261.32.camel@edumazet-laptop>
	 <w2n571fb4001005070350m7af2a494s7e7b66b68b26e5c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Bhaskar Dutta <bhaskie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:63851 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755160Ab0EGPSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 11:18:11 -0400
Received: by bwz19 with SMTP id 19so644528bwz.21
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 08:18:10 -0700 (PDT)
In-Reply-To: <w2n571fb4001005070350m7af2a494s7e7b66b68b26e5c8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, I found the second problem.

if/when IP route cache is invalidated, ip_queue_xmit() has to refetch a
route and calls sk_setup_caps(sk, &rt->u.dst), destroying the 

sk->sk_route_caps &= ~NETIF_F_GSO_MASK

that MD5 desesperatly try to make all over its way (from
tcp_transmit_skb() for example)

So we send few bad packets, and everything is fine when
tcp_transmit_skb() is called again.

You get many errors on remote peer if you do

ip route flush cache



