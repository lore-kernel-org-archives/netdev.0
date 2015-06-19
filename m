From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: inet_diag: export IPV6_V6ONLY sockopt
Date: Fri, 19 Jun 2015 06:52:00 -0700
Message-ID: <1434721920.31511.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150615205421.GA22616@orbit.nwl.cc>
	 <1434716132-25103-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:32810 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbbFSNwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 09:52:04 -0400
Received: by wibee9 with SMTP id ee9so10353884wib.0
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 06:52:03 -0700 (PDT)
In-Reply-To: <1434716132-25103-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-06-19 at 14:15 +0200, Phil Sutter wrote:
> For AF_INET6 sockets, the value of struct ipv6_pinfo.ipv6only is
> exported to userspace. It indicates whether an unbound socket listens on
> IPv4 as well as IPv6.

What is an 'unbound socket' ??? This makes no sense to me here.

>  Since the socket is natively IPv6, it is not
> listed by e.g. 'netstat -l -4'.

netstat does not use this interface. iproute2/ss does.

> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
> This patch is accompanied by an appropriate one for iproute2 to enable
> the additional information in 'ss -e'.
> ---
>  include/uapi/linux/inet_diag.h | 3 ++-
>  net/ipv4/inet_diag.c           | 4 ++++
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
> index c7093c7..9ca4834 100644
> --- a/include/uapi/linux/inet_diag.h
> +++ b/include/uapi/linux/inet_diag.h
> @@ -111,9 +111,10 @@ enum {
>  	INET_DIAG_SKMEMINFO,
>  	INET_DIAG_SHUTDOWN,
>  	INET_DIAG_DCTCPINFO,
> +	INET_DIAG_SKV6ONLY,
>  };
>  
> -#define INET_DIAG_MAX INET_DIAG_DCTCPINFO
> +#define INET_DIAG_MAX INET_DIAG_SKV6ONLY
>  
>  /* INET_DIAG_MEM */
>  
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 4d32262..4bf6d03 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -151,6 +151,10 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
>  			if (nla_put_u8(skb, INET_DIAG_TCLASS,
>  				       inet6_sk(sk)->tclass) < 0)
>  				goto errout;
> +
> +		if (nla_put_u8(skb, INET_DIAG_SKV6ONLY,
> +				inet6_sk(sk)->ipv6only) < 0)
> +			goto errout;
>  	}
>  #endif
>  

1) This certainly should not compile on current linux trees.
   Always submit such patches on net-next.

2) It is not clear why we would add this attribute if it is 0.
    This looks a waste of data.

So I would rather use :

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index b629fc53b1090e73047b263a9231e34ebf64b2af..46d72e45f8701526abb06f4a8187262dbc635784 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -112,6 +112,7 @@ enum {
 	INET_DIAG_SHUTDOWN,
 	INET_DIAG_DCTCPINFO,
 	INET_DIAG_PROTOCOL,  /* response attribute only */
+	INET_DIAG_SKV6ONLY,
 };
 
 #define INET_DIAG_MAX INET_DIAG_PROTOCOL
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 21985d8d41e709908021769be36380f7a5dfac23..381a26e932691075a73ae63569fd3a4366ce277f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -151,6 +151,9 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			if (nla_put_u8(skb, INET_DIAG_TCLASS,
 				       inet6_sk(sk)->tclass) < 0)
 				goto errout;
+		if (ipv6_only_sock(sk) &&
+		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, 1))
+			goto errout;
 	}
 #endif
 
