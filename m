From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] ip: Add support for IP_CHECKSUM cmsg
Date: Wed, 03 Dec 2014 16:56:32 -0800
Message-ID: <1417654592.5303.148.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417653868-14922-1-git-send-email-therbert@google.com>
	 <1417653868-14922-4-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37001 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbaLDA4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 19:56:35 -0500
Received: by mail-ig0-f169.google.com with SMTP id hl2so19006268igb.4
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 16:56:34 -0800 (PST)
In-Reply-To: <1417653868-14922-4-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC Michael Kerrisk <mtk.manpages@gmail.com> for man pages...

On Wed, 2014-12-03 at 16:44 -0800, Tom Herbert wrote:
> New cmsg type is IP_CHECKSUM under SOL_IP. Enabled by standard
> setsockopt.
> 
> The value returned is the unfolded 32 bit checksum of the packet
> being received starting from the first byte returned in recvmsg
> through the end of the packet (truncation is disregarded).
> 
> Modified UDP to postpull checksum beyond UDP header before returning
> checksum for UDP data to userspace.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/net/inet_sock.h |  1 +
>  include/uapi/linux/in.h |  1 +
>  net/ipv4/ip_sockglue.c  | 34 +++++++++++++++++++++++++++++++++-
>  net/ipv4/udp.c          | 10 +++++++++-
>  4 files changed, 44 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
> index 4091fab..2823fc0 100644
> --- a/include/net/inet_sock.h
> +++ b/include/net/inet_sock.h
> @@ -203,6 +203,7 @@ struct inet_sock {
>  #define IP_CMSG_RETOPTS		(1 << 4)
>  #define IP_CMSG_PASSSEC		(1 << 5)
>  #define IP_CMSG_ORIGDSTADDR	(1 << 6)
> +#define IP_CMSG_CHECKSUM	(1 << 7)
>  
>  static inline struct inet_sock *inet_sk(const struct sock *sk)
>  {
> diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
> index c33a65e..589ced0 100644
> --- a/include/uapi/linux/in.h
> +++ b/include/uapi/linux/in.h
> @@ -109,6 +109,7 @@ struct in_addr {
>  
>  #define IP_MINTTL       21
>  #define IP_NODEFRAG     22
> +#define IP_CHECKSUM	23
>  
>  /* IP_MTU_DISCOVER values */
>  #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index d4406aa..054280f 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -96,6 +96,14 @@ static void ip_cmsg_recv_retopts(struct msghdr *msg, struct sk_buff *skb)
>  	put_cmsg(msg, SOL_IP, IP_RETOPTS, opt->optlen, opt->__data);
>  }
>  
> +static void ip_cmsg_recv_checksum(struct msghdr *msg, struct sk_buff *skb)
> +{
> +	if (skb->ip_summed != CHECKSUM_COMPLETE)
> +		return;
> +
> +	put_cmsg(msg, SOL_IP, IP_CHECKSUM, sizeof(__wsum), &skb->csum);
> +}
> +
>  static void ip_cmsg_recv_security(struct msghdr *msg, struct sk_buff *skb)
>  {
>  	char *secdata;
> @@ -190,9 +198,16 @@ void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
>  			return;
>  	}
>  
> -	if (flags & IP_CMSG_ORIGDSTADDR)
> +	if (flags & IP_CMSG_ORIGDSTADDR) {
>  		ip_cmsg_recv_dstaddr(msg, skb);
>  
> +		flags &= ~IP_CMSG_ORIGDSTADDR;
> +		if (!flags)
> +			return;
> +	}
> +
> +	if (flags & IP_CMSG_CHECKSUM)
> +		ip_cmsg_recv_checksum(msg, skb);
>  }
>  EXPORT_SYMBOL(ip_cmsg_recv);
>  
> @@ -512,6 +527,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
>  	case IP_MULTICAST_ALL:
>  	case IP_MULTICAST_LOOP:
>  	case IP_RECVORIGDSTADDR:
> +	case IP_CHECKSUM:
>  		if (optlen >= sizeof(int)) {
>  			if (get_user(val, (int __user *) optval))
>  				return -EFAULT;
> @@ -609,6 +625,19 @@ static int do_ip_setsockopt(struct sock *sk, int level,
>  		else
>  			inet->cmsg_flags &= ~IP_CMSG_ORIGDSTADDR;
>  		break;
> +	case IP_CHECKSUM:
> +		if (val) {
> +			if (!(inet->cmsg_flags & IP_CMSG_CHECKSUM)) {
> +				inet_inc_convert_csum(sk);
> +				inet->cmsg_flags |= IP_CMSG_CHECKSUM;
> +			}
> +		} else {
> +			if (inet->cmsg_flags & IP_CMSG_CHECKSUM) {
> +				inet_dec_convert_csum(sk);
> +				inet->cmsg_flags &= ~IP_CMSG_CHECKSUM;
> +			}
> +		}
> +		break;
>  	case IP_TOS:	/* This sets both TOS and Precedence */
>  		if (sk->sk_type == SOCK_STREAM) {
>  			val &= ~INET_ECN_MASK;
> @@ -1212,6 +1241,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
>  	case IP_RECVORIGDSTADDR:
>  		val = (inet->cmsg_flags & IP_CMSG_ORIGDSTADDR) != 0;
>  		break;
> +	case IP_CHECKSUM:
> +		val = (inet->cmsg_flags & IP_CMSG_CHECKSUM) != 0;
> +		break;
>  	case IP_TOS:
>  		val = inet->tos;
>  		break;
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 221b53f..bba2e06 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1315,8 +1315,16 @@ try_again:
>  		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
>  		*addr_len = sizeof(*sin);
>  	}
> -	if (inet->cmsg_flags)
> +	if (inet->cmsg_flags) {
> +		/* Pull checksum past UDP header in case we are providing
> +		 * checksum in cmsg.
> +		 */
> +		if (inet->cmsg_flags & IP_CMSG_CHECKSUM)
> +			skb_postpull_rcsum(skb, skb->data,
> +					   sizeof(struct udphdr));
> +
>  		ip_cmsg_recv(msg, skb);
> +	}
>  
>  	err = copied;
>  	if (flags & MSG_TRUNC)
