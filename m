From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Fix corrupt TCP packets when options space overflows
 with MD5SIG enabled
Date: Fri, 30 May 2008 13:32:36 -0700
Message-ID: <20080530133236.24675c23@extreme>
References: <396556a20805301140x586093e5o92d44e38f7c2869a@mail.gmail.com>
	<20080530190218.GD1743@solarflare.com>
	<396556a20805301211g7dd98ae7m185a356e611e81aa@mail.gmail.com>
	<396556a20805301217k293e5718h6bbf02bfe0683142@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:43099 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753399AbYE3Uct (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 16:32:49 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe0683142@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 May 2008 12:17:12 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> When MD5 signatures are turned on we can end up with syntactically invalid
> packets with a header length < 20 bytes. This is because tcp_header_size
> overflows with 12 bytes of timestamp, 20 bytes of signature and > 8 bytes of
> SACK option.
> 
> Since we can't fit any SACK blocks in the final 8 bytes of options space, and
> the MD5 signature is more important, we disable including SACK, or even
> advertising it, when MD5 is enabled.
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>
> 
> ---
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index e399bde..c98a4c9 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -477,6 +477,8 @@ static int tcp_transmit_skb(struct sock *sk,
> struct sk_buff *skb, int clone_it,

Your mailer is wrapping lines so patch is munged.

>  #ifdef CONFIG_TCP_MD5SIG
>         struct tcp_md5sig_key *md5;
>         __u8 *md5_hash_location;
> +#else
> +       void *const md5 = NULL;
>  #endif

You can just do:

+	struct tcp_md5sig_key *md5 = NULL;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *md5;
 	__u8 *md5_hash_location;
 #endif

GCC does the right thing.

>         struct tcphdr *th;
>         int sysctl_flags;
> @@ -504,6 +506,16 @@ static int tcp_transmit_skb(struct sock *sk,
> struct sk_buff *skb, int clone_it,
>         tcb = TCP_SKB_CB(skb);
>         tcp_header_size = tp->tcp_header_len;
> 
> +#ifdef CONFIG_TCP_MD5SIG
> +       /*
> +        * Are we doing MD5 on this segment? If so - make
> +        * room for it.
> +        */
> +       md5 = tp->af_specific->md5_lookup(sk, sk);
> +       if (md5)
> +               tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
> +#endif
> +
>  #define SYSCTL_FLAG_TSTAMPS    0x1
>  #define SYSCTL_FLAG_WSCALE     0x2
>  #define SYSCTL_FLAG_SACK       0x4
> @@ -519,12 +531,15 @@ static int tcp_transmit_skb(struct sock *sk,
> struct sk_buff *skb, int clone_it,
>                         tcp_header_size += TCPOLEN_WSCALE_ALIGNED;
>                         sysctl_flags |= SYSCTL_FLAG_WSCALE;
>                 }
> -               if (sysctl_tcp_sack) {
> +               /* We don't include SACK options if we are going to
> +                * include an MD5 signature because they can't fit
> +                * in the options space */
> +               if (sysctl_tcp_sack && !md5) {
>                         sysctl_flags |= SYSCTL_FLAG_SACK;
>                         if (!(sysctl_flags & SYSCTL_FLAG_TSTAMPS))
>                                 tcp_header_size += TCPOLEN_SACKPERM_ALIGNED;
>                 }
> -       } else if (unlikely(tp->rx_opt.eff_sacks)) {
> +       } else if (unlikely(tp->rx_opt.eff_sacks && !md5)) {
>                 /* A SACK is 2 pad bytes, a 2 byte header, plus
>                  * 2 32-bit sequence numbers for each SACK block.
>                  */
> @@ -536,16 +551,6 @@ static int tcp_transmit_skb(struct sock *sk,
> struct sk_buff *skb, int clone_it,
>         if (tcp_packets_in_flight(tp) == 0)
>                 tcp_ca_event(sk, CA_EVENT_TX_START);
> 
> -#ifdef CONFIG_TCP_MD5SIG
> -       /*
> -        * Are we doing MD5 on this segment? If so - make
> -        * room for it.
> -        */
> -       md5 = tp->af_specific->md5_lookup(sk, sk);
> -       if (md5)
> -               tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
> -#endif
> -
>         skb_push(skb, tcp_header_size);
>         skb_reset_transport_header(skb);
>         skb_set_owner_w(skb, sk);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
