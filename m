From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 2/2] tcp_diag: report TCP MD5 signing keys
 and addresses
Date: Tue, 29 Aug 2017 16:01:17 -0700
Message-ID: <1504047677.11498.107.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170829222954.24863-1-colona@arista.com>
         <20170829222954.24863-3-colona@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:38425 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751746AbdH2XBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:01:20 -0400
Received: by mail-pf0-f196.google.com with SMTP id r187so3173217pfr.5
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 16:01:20 -0700 (PDT)
In-Reply-To: <20170829222954.24863-3-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-29 at 15:29 -0700, Ivan Delalande wrote:
> Report TCP MD5 (RFC2385) signing keys, addresses and address prefixes to
> processes with CAP_NET_ADMIN requesting INET_DIAG_INFO. Currently it is
> not possible to retrieve these from the kernel once they have been
> configured on sockets.
> 
> Signed-off-by: Ivan Delalande <colona@arista.com>
> ---
>  include/uapi/linux/inet_diag.h |   1 +
>  net/ipv4/tcp_diag.c            | 115 ++++++++++++++++++++++++++++++++++++++---
>  2 files changed, 110 insertions(+), 6 deletions(-)
> 
> diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
> index 678496897a68..f52ff62bfabe 100644
> --- a/include/uapi/linux/inet_diag.h
> +++ b/include/uapi/linux/inet_diag.h
> @@ -143,6 +143,7 @@ enum {
>  	INET_DIAG_MARK,
>  	INET_DIAG_BBRINFO,
>  	INET_DIAG_CLASS_ID,
> +	INET_DIAG_MD5SIG,
>  	__INET_DIAG_MAX,
>  };
>  
> diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
> index a748c74aa8b7..f972f9f7eae4 100644
> --- a/net/ipv4/tcp_diag.c
> +++ b/net/ipv4/tcp_diag.c
> @@ -16,6 +16,7 @@
>  
>  #include <linux/tcp.h>
>  
> +#include <net/netlink.h>
>  #include <net/tcp.h>
>  
>  static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
> @@ -36,6 +37,106 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
>  		tcp_get_info(sk, info);
>  }
>  
> +#ifdef CONFIG_TCP_MD5SIG
> +static void inet_diag_md5sig_fill(struct tcp_md5sig *info,
> +				  const struct tcp_md5sig_key *key)
> +{
> +	#if IS_ENABLED(CONFIG_IPV6)
> +	if (key->family == AF_INET6) {
> +		struct sockaddr_in6 *sin6 =
> +			(struct sockaddr_in6 *)&info->tcpm_addr;
> +
> +		memcpy(&sin6->sin6_addr, &key->addr.a6,
> +		       sizeof(struct in6_addr));
> +	} else
> +	#endif
> +	{
> +		struct sockaddr_in *sin =
> +			(struct sockaddr_in *)&info->tcpm_addr;
> +
> +		memcpy(&sin->sin_addr, &key->addr.a4, sizeof(struct in_addr));

You probably need a memset(... 0  ...) to clear the XX bytes that are
not used by IPv4 address.

Otherwise your patch is going to 'leak'  124 bytes of kernel memory to
user space and offer yet another way for attackers to build exploits.

AFAIK, struct tcp_md5sig has a huge hole, since it uses

"struct __kernel_sockaddr_storage tcpm_addr "

So a similar problem exists for IPv6.

Maybe it is time to define a much smaller structure, using only 16 bytes
instead of 128 for the address.
