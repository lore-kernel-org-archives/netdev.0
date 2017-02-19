From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH rfc 1/4] net/utils: generic inet_pton_with_scope helper
Date: Sun, 19 Feb 2017 09:15:23 -0800
Message-ID: <20170219171523.GC10310@infradead.org>
References: <1487267017-29904-1-git-send-email-sagi@grimberg.me>
 <1487267017-29904-2-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        target-devel@vger.kernel.org, netdev@vger.kernel.org
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1487267017-29904-2-git-send-email-sagi@grimberg.me>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2017 at 07:43:34PM +0200, Sagi Grimberg wrote:
> Several locations in the stack need to handle ipv4/ipv6
> (with scope) and port strings conversion to sockaddr.
> Add a helper that takes either AF_INET, AF_INET6 or
> AF_UNSPEC (for wildcard) to centralize this handling.
> 
> Suggested-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
> ---
>  include/linux/inet.h |  6 ++++
>  net/core/utils.c     | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 97 insertions(+)
> 
> diff --git a/include/linux/inet.h b/include/linux/inet.h
> index 4cca05c9678e..636ebe87e6f8 100644
> --- a/include/linux/inet.h
> +++ b/include/linux/inet.h
> @@ -43,6 +43,8 @@
>  #define _LINUX_INET_H
>  
>  #include <linux/types.h>
> +#include <net/net_namespace.h>
> +#include <linux/socket.h>
>  
>  /*
>   * These mimic similar macros defined in user-space for inet_ntop(3).
> @@ -54,4 +56,8 @@
>  extern __be32 in_aton(const char *str);
>  extern int in4_pton(const char *src, int srclen, u8 *dst, int delim, const char **end);
>  extern int in6_pton(const char *src, int srclen, u8 *dst, int delim, const char **end);
> +
> +extern int inet_pton_with_scope(struct net *net, unsigned short af,
> +		const char *src, const char *port, struct sockaddr_storage *addr);
> +
>  #endif	/* _LINUX_INET_H */
> diff --git a/net/core/utils.c b/net/core/utils.c
> index 6592d7bbed39..8f15d016c64a 100644
> --- a/net/core/utils.c
> +++ b/net/core/utils.c
> @@ -26,9 +26,11 @@
>  #include <linux/percpu.h>
>  #include <linux/init.h>
>  #include <linux/ratelimit.h>
> +#include <linux/socket.h>
>  
>  #include <net/sock.h>
>  #include <net/net_ratelimit.h>
> +#include <net/ipv6.h>
>  
>  #include <asm/byteorder.h>
>  #include <linux/uaccess.h>
> @@ -300,6 +302,95 @@ int in6_pton(const char *src, int srclen,
>  }
>  EXPORT_SYMBOL(in6_pton);
>  
> +/**
> + * inet_pton_with_scope - convert an IPv4/IPv6 and port to socket address
> + * @net: net namespace (used for scope handling)
> + * @af: address family, AF_INET, AF_INET6 or AF_UNSPEC for either
> + * @src: the start of the address string
> + * @port: the start of the port string (or NULL for none)
> + * @addr: output socket address
> + *
> + * Return zero on success, return errno when any error occurs.
> + */
> +int inet_pton_with_scope(struct net *net, __kernel_sa_family_t af,
> +		const char *src, const char *port, struct sockaddr_storage *addr)
> +{
> +	struct sockaddr_in *addr4;
> +	struct sockaddr_in6 *addr6;
> +	const char *scope_delim;
> +	bool unspec = false;
> +	int srclen = strlen(src);
> +	u16 port_num;
> +
> +	if (port) {
> +		if (kstrtou16(port, 0, &port_num)) {
> +			pr_err("failed port_num %s\n", port);
> +			return -EINVAL;
> +		}
> +	} else {
> +		port_num = 0;
> +	}
> +
> +	switch (af) {
> +	case AF_UNSPEC:
> +		unspec = true;
> +		/* FALLTHRU */
> +	case AF_INET:
> +		if (srclen <= INET_ADDRSTRLEN) {
> +			addr4 = (struct sockaddr_in *)addr;
> +			if (in4_pton(src, srclen, (u8 *) &addr4->sin_addr.s_addr,
> +				     '\n', NULL) > 0) {
> +				addr4->sin_family = AF_INET;
> +				addr4->sin_port = htons(port_num);
> +				return 0;
> +			}
> +			pr_err("failed in4_pton %s\n", src);
> +		}

I would probably factor this and the IPv6 equivalent below into helpers
to keep the code a little more self-contained so that we could avoid the
fallthrough magic.

Except for that and the semicolon warnings this looks fine to me.
