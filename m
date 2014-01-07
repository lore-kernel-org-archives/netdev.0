From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP
 encapsulating protocols
Date: Tue, 07 Jan 2014 12:32:15 -0800
Message-ID: <1389126735.26646.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	 <1389108594-665-2-git-send-email-ogerlitz@mellanox.com>
	 <1389112433.26646.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+q=uc4Svia+dFHrQfYyfJfsSVmqH1avJ99f4O0ES3QoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f175.google.com ([209.85.161.175]:33292 "EHLO
	mail-gg0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbaAGUcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:32:18 -0500
Received: by mail-gg0-f175.google.com with SMTP id g10so119241gga.6
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 12:32:18 -0800 (PST)
In-Reply-To: <CAJZOPZ+q=uc4Svia+dFHrQfYyfJfsSVmqH1avJ99f4O0ES3QoQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 22:19 +0200, Or Gerlitz wrote:
> On Tue, Jan 7, 2014 at 6:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2014-01-07 at 17:29 +0200, Or Gerlitz wrote:
> >>
> >> +
> >> +#define MAX_UDP_PORT (1 << 16)
> >> +extern const struct net_offload __rcu *udp_offloads[MAX_UDP_PORT];
> >
> > Thats 512 KB of memory.
> > This will greatly impact forwarding performance of UDP packets with
> > random ports, and will increase kernel memory size for embedded devices.
> 
> Re forwarding, are you referring to the case where the forwarded
> packets are encapsulated? packets which are not encapusalted will be
> flushed in the gro receive handler (this went out by mistake in V2 but
> exists in V1)  if skb->encapsulation isn't set.
> 

How do you know encapsulation must be tried for a given incoming
packet ? NIC do not magically sets skb->encapsulation I think...

You access udp_offloads[XXX], with XXX being in 0..65535 range, right ?


> As for encapsulated packets, when you say random ports, are you
> referring to a router which has multiple udp encapsulating protocols
> where each uses different udp port? for this case and also to reduce
> the memory footprint, we can use lookup in a list as done for the L2
> protocols gro handlers in the list_for_each loop of dev_gro_receive(),
> makes sense?

I am speaking of a normal router, running linux kernel, and having
GRO/TSO enabled.

If each incoming UDP packet has to access one extra cache line in a
512KB array, its likely to be an extra cache line miss, if UDP dest
port is mostly random (compared to ports used by very recent UDP
packets)
