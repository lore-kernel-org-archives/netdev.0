From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tbench wrt. loopback TSO
Date: Tue, 28 Oct 2008 00:17:00 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810272113280.13973@wrl-59.cs.helsinki.fi>
References: <20081015.171408.193701292.davem@davemloft.net>
 <20081026123442.GA31506@ioremap.net> <20081026.185911.193696873.davem@davemloft.net>
 <Pine.LNX.4.64.0810270942430.1290@wrl-59.cs.helsinki.fi>
 <20081027141332.GA4691@ioremap.net> <Pine.LNX.4.64.0810271704530.7072@wrl-59.cs.helsinki.fi>
 <20081027170314.GA25148@ioremap.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-62795404-1225135141=:13973"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, Herbert Xu <herbert@gondor.apana.org.au>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34798 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbYJ0WRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 18:17:02 -0400
In-Reply-To: <20081027170314.GA25148@ioremap.net>
Content-ID: <Pine.LNX.4.64.0810280010410.13973@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-62795404-1225135141=:13973
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810280010411.13973@wrl-59.cs.helsinki.fi>

On Mon, 27 Oct 2008, Evgeniy Polyakov wrote:

> On Mon, Oct 27, 2008 at 05:19:17PM +0200, Ilpo Järvinen (ilpo.jarvinen@helsinki.fi) wrote:
> > On Mon, 27 Oct 2008, Evgeniy Polyakov wrote:
> > 
> > > On Mon, Oct 27, 2008 at 09:49:21AM +0200, Ilpo Järvinen (ilpo.jarvinen@helsinki.fi) wrote:
> > > > > > That's what I got with the current tree for 8 threads on a 4-way 32-bit
> > > > > > Xeons (2 physical CPUs) and 8gb of ram:
> > > > > > gso/tso off: 361.367
> > > > > > tso/gso on:  354.635
> > > > > 
> > > > > Yes, it might do this, in which case tcp_tso_should_defer() simply needs
> > > > > some tweaking.
> > > > 
> > > > Good point, could you Evgeniy verify first if simple goto send_now; in 
> > > > beginning there recovers it all...
> > > 
> > > With direct goto at the begining of the tcp_tso_should_defer()
> > > and 4403b406 commit git tree (was current yesterday night)
> > > I got following numbers: 
> > > 
> > > with goto:
> > > tso/gso  on: 358.976, 357.699
> > > tso/gso off: 368.016, 367.079
> > > 
> > > no goto
> > > tso/gso  on: 353.656, 354.791
> > > tso/gso off: 364.8, 365.85
> > > 
> > > So tcp_tso_should_defer() adds additional problems not counted in
> > > tso/gso changes.
> > 
> > Noticed that tcp_current_mss does modulo with tso and that it is 
> > being called from a non-trivial number of places, though ovbiously only 
> > part of them should be relevant here. ...I'm not sure if that can show 
> > up though.
> 
> That's why when I see modulo something screams inside me...
> I used following patch (without goto in the tcp_tso_should_defer():
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index e4c5ac9..8ee7597 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1075,7 +1075,6 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
>  				  tp->tcp_header_len);
>  
>  		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
> -		xmit_size_goal -= (xmit_size_goal % mss_now);
>  	}
>  	tp->xmit_size_goal = xmit_size_goal;
>  
> 
> tso/gso  on: 361.866 362.662
> tso/gso off: 370.038 368.768
> 
> So this is another improvement hidden and not accounted in the tso/gso stuff.
> Another modulo sits in tcp_mss_split_point().

I know it's there but it should occur not that often. If you have pcount 
== 1 (len <= mss implies that) that won't even execute and rest of the 
cases involve handling rwin limited & nagle. I suppose we could make nagle 
to work without splitting the skb to sub-mss (needs some auditting to find 
out if something else than snd_sml setting assumes skb->len < mss, nagle 
check probably as well but I don't remember w/o looking).


-- 
 i.
---696208474-62795404-1225135141=:13973--
