From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/8] [TCP]: Uninline tcp_set_state
Date: Mon, 14 Jan 2008 09:20:26 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801140858040.31652@kivilampi-30.cs.helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20080112130355.74c39ae7@deepthought>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1134523905-1200294420=:31652"
Cc: Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46012 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbYANHU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 02:20:29 -0500
In-Reply-To: <20080112130355.74c39ae7@deepthought>
Content-ID: <Pine.LNX.4.64.0801140909200.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1134523905-1200294420=:31652
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0801140908311.31652@kivilampi-30.cs.helsinki.fi>

On Sat, 12 Jan 2008, Stephen Hemminger wrote:

> On Sat, 12 Jan 2008 11:40:10 +0200
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:

...snip...

> > built-in.o:
> >  12 functions changed, 250 bytes added, 1695 bytes removed, diff: -1445

...snip...

> >  include/net/tcp.h |   35 +----------------------------------
> >  net/ipv4/tcp.c    |   35 +++++++++++++++++++++++++++++++++++
> >  2 files changed, 36 insertions(+), 34 deletions(-)
> > 
> > diff --git a/include/net/tcp.h b/include/net/tcp.h
> > index 48081ad..306580c 100644
> > --- a/include/net/tcp.h
> > +++ b/include/net/tcp.h
> > @@ -926,40 +926,7 @@ static const char *statename[]={
> >  	"Close Wait","Last ACK","Listen","Closing"
> >  };
> >  #endif
> > -
> > -static inline void tcp_set_state(struct sock *sk, int state)
> > -{
> > -	int oldstate = sk->sk_state;
> > -
> > -	switch (state) {
> > -	case TCP_ESTABLISHED:
> > -		if (oldstate != TCP_ESTABLISHED)
> > -			TCP_INC_STATS(TCP_MIB_CURRESTAB);
> > -		break;
> > -
> > -	case TCP_CLOSE:
> > -		if (oldstate == TCP_CLOSE_WAIT || oldstate == TCP_ESTABLISHED)
> > -			TCP_INC_STATS(TCP_MIB_ESTABRESETS);
> > -
> > -		sk->sk_prot->unhash(sk);
> > -		if (inet_csk(sk)->icsk_bind_hash &&
> > -		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
> > -			inet_put_port(&tcp_hashinfo, sk);
> > -		/* fall through */
> > -	default:
> > -		if (oldstate==TCP_ESTABLISHED)
> > -			TCP_DEC_STATS(TCP_MIB_CURRESTAB);
> > -	}
> > -
> > -	/* Change state AFTER socket is unhashed to avoid closed
> > -	 * socket sitting in hash tables.
> > -	 */
> > -	sk->sk_state = state;
> > -
> > -#ifdef STATE_TRACE
> > -	SOCK_DEBUG(sk, "TCP sk=%p, State %s -> %s\n",sk, statename[oldstate],statename[state]);
> > -#endif	
> > -}
> >
> 
> 
> Since the function is called with a constant state, I guess the assumption
> was that gcc would be smart enough to only include the code needed, it looks like
> either code was bigger or the compiler was dumber than expected

I'd guess that compiler was just dumber... :-) It might be an interesting 
experiment to convert it to if's and see if it would make a difference, 
maybe it just gets confused by the switch or something.

Besides, it not always that obvious that gcc is able to determine "the
constant state", considering e.g., the complexity in the cases with
tcp_rcv_synsent_state_process, tcp_close_state, tcp_done. In such cases
uninlining should be done and gcc is probably not able to mix both cases
nicely for a single function?

However, after looking a bit, I'm partially leaning towards the other 
option too:

> >   tcp_done        | -145
> >   tcp_disconnect  | -141

...These called for tcp_set_state just _once_, while this calls for it 
twice:

> >   tcp_fin               |  -86

...Obviously the compiler was able to perform some reductions but 43 bytes 
per inlining seems still a bit high number.


-- 
 i.
---696243703-1134523905-1200294420=:31652--
