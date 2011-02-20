From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] route_bench: Filter out all responses.
Date: Sun, 20 Feb 2011 23:28:15 +0100
Message-ID: <4D61957F.5060905@netfilter.org>
References: <20110220.140450.48516784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44935 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754719Ab1BTW2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Feb 2011 17:28:18 -0500
In-Reply-To: <20110220.140450.48516784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/02/11 23:04, David Miller wrote:
> 
> Install a socket filter to reduce the pure netlink overhead.
> 
> Unfortunately the libmnl library does not provide a way to
> set socket options that are of level other than SOL_NETLINK.
> 
> So we hack it by knowing some things about libmnl internals.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> 
> The knowledge of libmnl internals is unfortunate, but there
> is currently no other way to do this.
> 
>  route_bench.c |   33 +++++++++++++++++++++++++--------
>  1 files changed, 25 insertions(+), 8 deletions(-)
> 
> diff --git a/route_bench.c b/route_bench.c
> index c75ea45..6c6b525 100644
> --- a/route_bench.c
> +++ b/route_bench.c
> @@ -22,6 +22,17 @@
>  #include <linux/if.h>
>  #include <linux/if_link.h>
>  #include <linux/rtnetlink.h>
> +#include <linux/filter.h>
> +
> +/* XXX Ugly knowledge of internals, but there is currently no way
> + * XXX provided by the libmnl library to set socket options that are
> + * XXX of level other than SOL_NETLINK.   And we need to set one of
> + * XXX level SOL_SOCKET to install the socket filter.
> + */
> +struct mnl_socket {
> +	int 			fd;
> +	struct sockaddr_nl	addr;
> +};
>  
>  static int usage(void)
>  {
> @@ -139,8 +150,10 @@ static int do_bench(int count, in_addr_t src_addr, in_addr_t dst_addr,
>  		    unsigned int mark, unsigned int iif)
>  {
>  	char send_buf[MNL_SOCKET_BUFFER_SIZE];
> -	char recv_buf[MNL_SOCKET_BUFFER_SIZE];
>  	unsigned int min, sec, frac, tmp;
> +	struct sock_filter insns = { .code = BPF_RET | BPF_K,
> +				     .k = 0 };
> +	struct sock_fprog filter = { .len = 1, .filter = &insns, };
>  	struct bench_state *s = &state;
>  	struct timeval start_time;
>  	struct timeval end_time;
> @@ -148,7 +161,7 @@ static int do_bench(int count, in_addr_t src_addr, in_addr_t dst_addr,
>  	struct nlmsghdr *nlh;
>  	unsigned int portid;
>  	struct rtmsg *rtm;
> -	int i;
> +	int i, err;
>  
>  	init_bench_state(s);
>  
> @@ -165,10 +178,15 @@ static int do_bench(int count, in_addr_t src_addr, in_addr_t dst_addr,
>  
>  	portid = mnl_socket_get_portid(nl);
>  
> +	err = setsockopt(nl->fd, SOL_SOCKET, SO_ATTACH_FILTER, &filter, sizeof(filter));
> +	if (err) {
> +		perror("setsockopt");
> +		return -1;
> +	}
> +

You can use:

extern int mnl_socket_get_fd(const struct mnl_socket *nl);

Thus, you can invoke setsockopt directly ;-).
