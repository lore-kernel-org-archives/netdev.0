From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] udp: Neaten and reduce size of compute_score
 functions
Date: Mon, 01 Dec 2014 19:09:20 -0800
Message-ID: <1417489760.4894.8.camel@perches.com>
References: <1417484341.4894.6.camel@perches.com>
	 <1417489141.4442.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417489141.4442.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-12-01 at 18:59 -0800, Eric Dumazet wrote:
> On Mon, 2014-12-01 at 17:39 -0800, Joe Perches wrote:
> > The compute_score functions are a bit difficult to read.
> > 
> > Neaten them a bit to reduce object sizes and make them a
> > bit more intelligible.
> > 
> > Return early to avoid indentation and avoid unnecessary
> > initializations.
[]
> > +	if (!(net_eq(sock_net(sk), net) &&
> > +	      udp_sk(sk)->udp_port_hash == hnum &&
> > +	      !ipv6_only_sock(sk)))
> > +		return -1
> 
> Or even better :
> 
> 
> 	if (!net_eq(sock_net(sk), net) ||
> 	    udp_sk(sk)->udp_port_hash != hnum ||
> 	    ipv6_only_sock(sk))
> 		return -1;

Hi Eric.

Yeah, I thought about it but thought it
simpler to not change the logic.

Either way is fine with me.

David?

btw: the same thing can be done for the v6 block too:

+       if (!(net_eq(sock_net(sk), net) && !ipv6_only_sock(sk)))
+               return -1;
 
-               if (inet->inet_rcv_saddr != daddr)
+       inet = inet_sk(sk);
+
+       if (inet->inet_rcv_saddr != daddr)
+               return -1;
+       if (inet->inet_num != hnum)
+               return -1;

to:

	if (!net_eq(sock_net(sk, net) ||
	    ipv6_only_sock(sk))
		return -1;

	inet = inet_sk(sk);

	if (inet->inet_rcv_saddr != daddr ||
	    inet->inet_num != hnum)
		return -1;
