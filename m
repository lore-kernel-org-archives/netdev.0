From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] tcp: md5: add fields to the tcp_md5sig struct to
 set a key address prefix
Date: Tue, 06 Jun 2017 21:08:22 -0700
Message-ID: <1496808502.736.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170607005414.25361-1-colona@arista.com>
         <20170607005414.25361-2-colona@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607005414.25361-2-colona@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-06-06 at 17:54 -0700, Ivan Delalande wrote:
> Replace padding in the socket option structure tcp_md5sig with a new
> flag field and address prefix length so it can be specified when
> configuring a new key with the TCP_MD5SIG socket option.
> 
> Signed-off-by: Bob Gilligan <gilligan@arista.com>
> Signed-off-by: Eric Mowat <mowat@arista.com>
> Signed-off-by: Ivan Delalande <colona@arista.com>
> ---
>  include/uapi/linux/tcp.h |  6 +++++-
>  net/ipv4/tcp_ipv4.c      | 13 +++++++++++--
>  net/ipv6/tcp_ipv6.c      | 20 +++++++++++++++-----
>  3 files changed, 31 insertions(+), 8 deletions(-)
> 
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index 38a2b07afdff..52ac30aa0652 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -234,9 +234,13 @@ enum {
>  /* for TCP_MD5SIG socket option */
>  #define TCP_MD5SIG_MAXKEYLEN	80
>  
> +/* tcp_md5sig flags */
> +#define TCP_MD5SIG_FLAG_PREFIX		1	/* address prefix length */
> +
>  struct tcp_md5sig {
>  	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
> -	__u16	__tcpm_pad1;				/* zero */
> +	__u8	tcpm_flags;				/* flags */
> +	__u8	tcpm_prefixlen;				/* address prefix */
>  	__u16	tcpm_keylen;				/* key length */
>  	__u32	__tcpm_pad2;				/* zero */
>  	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 51ca3bd5a8a3..2b1bb67b3388 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1069,6 +1069,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
>  {
>  	struct tcp_md5sig cmd;
>  	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
> +	u8 prefixlen;
>  
>  	if (optlen < sizeof(cmd))
>  		return -EINVAL;
> @@ -1079,15 +1080,23 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
>  	if (sin->sin_family != AF_INET)
>  		return -EINVAL;
>  
> +	if (cmd.tcpm_flags & TCP_MD5SIG_FLAG_PREFIX) {
> +		prefixlen = cmd.tcpm_prefixlen;
> +		if (prefixlen > 32)
> +			return -EINVAL;
> +	} else {
> +		prefixlen = 32;
> +	}

This will break some applications that maybe did not clear the
__tcpm_pad1 field ?


You need to find another way to maintain compatibility with old
applications.
