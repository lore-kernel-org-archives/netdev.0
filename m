From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 7 Sep 2010 15:15:25 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1009071443510.26447@wel-95.cs.helsinki.fi>
References: <AANLkTikMPENe011GxK15TNTXwdckZSSYfb=3pdDwfUeG@mail.gmail.com>  <20100906.221644.123986391.davem@davemloft.net>  <AANLkTik75BGz=csDKVRk+Ni9__MqXMpHeqi_sHniu09A@mail.gmail.com>  <20100906.223010.173858342.davem@davemloft.net>
 <1283859552.2338.402.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1673754904-1283861726=:26447"
Cc: David Miller <davem@davemloft.net>, leandroal@gmail.com,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50421 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755476Ab0IGMP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 08:15:27 -0400
In-Reply-To: <1283859552.2338.402.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1673754904-1283861726=:26447
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Tue, 7 Sep 2010, Eric Dumazet wrote:

> Le lundi 06 septembre 2010 à 22:30 -0700, David Miller a écrit :
> 
> 
> > The small 78 byte window is why the sending system is splitting up the
> > writes into smaller pieces.
> > 
> > I presume that the system advertises exactly a 78 byte window because
> > this is how large the commands are.  But this is an extremely foolish
> > and baroque thing to do, and it's why you are having problems.
> 
> I am not sure why TSO added a "Bound mss with half of window"
> requirement for tcp_sync_mss()

I've thought it is more related on window behavior in general and 
much much older than TSO (it certainly seems to be old one).

I guess we might run to some SWS issue if MSS < rwin < 2*MSS with your 
patch that are avoided by the current approach?

> I tried with MSS=1000 and WIN=1000, and segment size chosen is 500

Perhaps worth to try with MSS=999 WIN=1000 pair too and see what happens?

> With WIN=78, 78/2->39 is then capped to 48 (68U - tp->tcp_header_len)
> 
> Is there a hard requirement about segment size being at most half the
> window ?
>
> Following patch solves the problem for me :
> 
> [PATCH] tcp: bound mss to window in tcp_sync_mss()
> 
> Leandro Melo de Sales noticed that if a peer announces a very small
> initial tcp window (78 in his case), first sent frames have unnecessary
> small lengths (48 in his case)
> 
> CLNT->SRV    [SYN] Seq=0 Win=5840 Len=0 MSS=1460
> SRV->CLNT    [SYN, ACK] Seq=0 Ack=1 Win=78 Len=0 MSS=78
> CLNT->SRV    [ACK] Seq=1 Ack=1 Win=5840 Len=0
> CLNT->SRV    [PSH, ACK] Seq=1 Ack=1 Win=5840 Len=48
> CLNT->SRV    [PSH, ACK] Seq=49 Ack=1 Win=5840 Len=30
> SRV->CLNT    [ACK] Seq=1 Ack=49 Win=78 Len=0
> SRV->CLNT    [RST, ACK] Seq=1 Ack=79 Win=78 Len=0
> 
> tcp_sync_mss() bounds mss to half the window, while it could use full
> window:
> 
> CLNT->SRV    [SYN] Seq=0 Win=5840 Len=0 MSS=1460
> SRV->CLNT    [SYN, ACK] Seq=0 Ack=1 Win=78 Len=0 MSS=78
> CLNT->SRV    [ACK] Seq=1 Ack=1 Win=5840 Len=0
> CLNT->SRV    [PSH, ACK] Seq=1 Ack=1 Win=5840 Len=78
> SRV->CLNT    [ACK] Seq=1 Ack=79 Win=78 Len=0
> 
> Reported-by: ツ Leandro Melo de Sales <leandroal@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  include/net/tcp.h     |    9 +++++++++
>  net/ipv4/tcp_output.c |    2 +-
>  2 files changed, 10 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index eaa9582..c262676 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -481,6 +481,15 @@ static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
>  		return pktsize;
>  }
>  
> +/* Bound MSS / TSO packet size with the window */
> +static inline int tcp_bound_to_wnd(struct tcp_sock *tp, int pktsize)
> +{
> +	if (tp->max_window && pktsize > tp->max_window)
> +		return max(tp->max_window, 68U - tp->tcp_header_len);
> +	else
> +		return pktsize;
> +}
> +
>
>  /* tcp.c */
>  extern void tcp_get_info(struct sock *, struct tcp_info *);
>  
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index de3bd84..49cdbe4 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1224,7 +1224,7 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu)
>  		icsk->icsk_mtup.search_high = pmtu;
>  
>  	mss_now = tcp_mtu_to_mss(sk, pmtu);
> -	mss_now = tcp_bound_to_half_wnd(tp, mss_now);
> +	mss_now = tcp_bound_to_wnd(tp, mss_now);
>  
>  	/* And store cached results */
>  	icsk->icsk_pmtu_cookie = pmtu;

I don't quite follow why tcp.c caller should then be left as is? Though it 
seems to me that it is more complex than tcp_sync_mss case.

-- 
 i.
--8323329-1673754904-1283861726=:26447--
