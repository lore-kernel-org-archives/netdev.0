From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp: Export TCP Delayed ACK parameters to user
Date: Fri, 28 Oct 2011 02:01:37 +0200
Message-ID: <1319760097.19125.55.camel@edumazet-laptop>
References: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63398 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab1J1ABt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 20:01:49 -0400
Received: by wwe6 with SMTP id 6so4996355wwe.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 17:01:48 -0700 (PDT)
In-Reply-To: <1319756841-2051-1-git-send-email-dbaluta@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 28 octobre 2011 =C3=A0 02:07 +0300, Daniel Baluta a =C3=A9c=
rit :
> RFC2581 ($4.2) specifies when an ACK should be generated as follows:
>=20
> " .. an ACK SHOULD be generated for at least every second
>   full-sized segment, and MUST be generated within 500 ms
>   of the arrival of the first unacknowledged packet.
> "
>=20
> We export the number of segments and the timeout limits
> specified above, so that a user can tune them according
> to its needs.
>=20

Well, this requires user has a machine exclusive use :)

> Specifically:
> 	* /proc/sys/net/ipv4/tcp_delack_segs, represents
> 	the threshold for the number of segments.
> 	* /proc/sys/net/ipv4/tcp_delack_min, specifies
> 	the minimum timeout value
> 	* /proc/sys/net/ipv4/tcp_delack_max, specifies
> 	the maximum timeout value.
>=20


> Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
> ---
>  include/net/tcp.h          |   20 +++++++++++++++++---
>  net/ipv4/sysctl_net_ipv4.c |   21 +++++++++++++++++++++
>  net/ipv4/tcp.c             |    5 +++--
>  net/ipv4/tcp_input.c       |    7 +++++--
>  net/ipv4/tcp_output.c      |    4 +++-
>  5 files changed, 49 insertions(+), 8 deletions(-)
>=20

Missing Documentation changes

> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index e147f42..f3b0c17 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -111,14 +111,21 @@ extern void tcp_time_wait(struct sock *sk, int =
state, int timeo);
>  				  * TIME-WAIT timer.
>  				  */
> =20
> -#define TCP_DELACK_MAX	((unsigned)(HZ/5))	/* maximal time to delay b=
efore sending an ACK */
> +/* default maximum time to delay before sending an ACK */
> +#define TCP_DELACK_MAX_DEFAULT	((unsigned)(HZ/5))
> +
>  #if HZ >=3D 100
> -#define TCP_DELACK_MIN	((unsigned)(HZ/25))	/* minimal time to delay =
before sending an ACK */
> +/* default minimum time to delay before sending an ACK */
> +#define TCP_DELACK_MIN_DEFAULT	((unsigned)(HZ/25))
>  #define TCP_ATO_MIN	((unsigned)(HZ/25))
>  #else
> -#define TCP_DELACK_MIN	4U
> +#define TCP_DELACK_MIN_DEFAULT	4U
>  #define TCP_ATO_MIN	4U
>  #endif
> +
> +#define TCP_DELACK_MIN sysctl_tcp_delack_min
> +#define TCP_DELACK_MAX sysctl_tcp_delack_max

Hmm, please try to compile dccp as a module :)

You need some EXPORT_SYMBOL() definitions.

=46rankly, I suggest removing TCP_DELACK_{MIN|MAX} to avoid unecessary
layer, and use sysctl_tcp_delack_{min|max} instead


> +
>  #define TCP_RTO_MAX	((unsigned)(120*HZ))
>  #define TCP_RTO_MIN	((unsigned)(HZ/5))
>  #define TCP_TIMEOUT_INIT ((unsigned)(1*HZ))	/* RFC2988bis initial RT=
O value	*/
> @@ -251,6 +258,9 @@ extern int sysctl_tcp_max_ssthresh;
>  extern int sysctl_tcp_cookie_size;
>  extern int sysctl_tcp_thin_linear_timeouts;
>  extern int sysctl_tcp_thin_dupack;
> +extern int sysctl_tcp_delack_segs;
> +extern int sysctl_tcp_delack_min;
> +extern int sysctl_tcp_delack_max;
> =20
>  extern atomic_long_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> @@ -1557,6 +1567,10 @@ static inline struct tcp_extend_values *tcp_xv=
(struct request_values *rvp)
>  {
>  	return (struct tcp_extend_values *)rvp;
>  }


> +static inline int tcp_snd_thresh(struct sock *sk)

I am not sure name is properly chosen, its about delack or not ?

const struct *sk

> +{
> +	return inet_csk(sk)->icsk_ack.rcv_mss * sysctl_tcp_delack_segs;
> +}
> =20

Thanks !
