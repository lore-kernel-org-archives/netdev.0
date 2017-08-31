From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 2/2] tcp_diag: report TCP MD5 signing keys
 and addresses
Date: Wed, 30 Aug 2017 21:10:43 -0700
Message-ID: <1504152643.15310.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170831013312.29142-1-colona@arista.com>
         <20170831013312.29142-3-colona@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35685 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdHaEKp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 00:10:45 -0400
Received: by mail-pg0-f67.google.com with SMTP id r133so6476952pgr.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 21:10:45 -0700 (PDT)
In-Reply-To: <20170831013312.29142-3-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-30 at 18:33 -0700, Ivan Delalande wrote:
> Report TCP MD5 (RFC2385) signing keys, addresses and address prefixes to
> processes with CAP_NET_ADMIN requesting INET_DIAG_INFO. Currently it is
> not possible to retrieve these from the kernel once they have been
> configured on sockets.
> 
> Signed-off-by: Ivan Delalande <colona@arista.com>
> ---
>  include/uapi/linux/inet_diag.h |   1 +
>  include/uapi/linux/tcp.h       |   9 ++++
>  net/ipv4/tcp_diag.c            | 110 ++++++++++++++++++++++++++++++++++++++---
>  3 files changed, 114 insertions(+), 6 deletions(-)
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
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index 030e594bab45..15c25eccab2b 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -256,4 +256,13 @@ struct tcp_md5sig {
>  	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
>  };
>  
> +/* INET_DIAG_MD5SIG */
> +struct tcp_diag_md5sig {
> +	__u8	tcpm_family;
> +	__u8	tcpm_prefixlen;
> +	__u16	tcpm_keylen;
> +	__be32	tcpm_addr[4];
> +	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];
> +};
> +
>  #endif /* _UAPI_LINUX_TCP_H */
> diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
> index a748c74aa8b7..65d0c34a76ee 100644
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
> @@ -36,6 +37,101 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
>  		tcp_get_info(sk, info);
>  }
>  
> +#ifdef CONFIG_TCP_MD5SIG
> +static void tcp_diag_md5sig_fill(struct tcp_diag_md5sig *info,
> +				 const struct tcp_md5sig_key *key)
> +{
> +	info->tcpm_family = key->family;
> +	info->tcpm_prefixlen = key->prefixlen;
> +	info->tcpm_keylen = key->keylen;
> +	memcpy(info->tcpm_key, key->key, key->keylen);


if (key->keylen < TCP_MD5SIG_MAXKEYLEN), 
then you'll leak sensitive kernel data to user space.

Since I doubt many sockets are using MD5SIG, you could simply do at the
beginning of this function :

memset(info, 0, sizeof(*info));

> +
> +	if (key->family == AF_INET) {
> +		memset(info->tcpm_addr, 0, sizeof(info->tcpm_addr));

then also remove this memset() since the prior memset would do this
already.

> +		info->tcpm_addr[0] = key->addr.a4.s_addr;
> +	}
> +	#if IS_ENABLED(CONFIG_IPV6)
> +	else if (key->family == AF_INET6) {
> +		memcpy(&info->tcpm_addr, &key->addr.a6,
> +		       sizeof(info->tcpm_addr));
> +	}
> +	#endif
> +}
> +
