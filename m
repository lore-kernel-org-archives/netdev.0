From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv6: fix incorrect ipsec transport mode fragment
Date: Mon, 14 May 2012 15:05:28 +0200
Message-ID: <20120514130528.GA24733@secunet.com>
References: <20120215104021.GC31660@secunet.com>
 <1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, lw@cn.fujitsu.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38002 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756514Ab2ENNFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 09:05:31 -0400
Content-Disposition: inline
In-Reply-To: <1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 14, 2012 at 11:21:00AM +0800, Gao feng wrote:
> Since commit 299b0767(ipv6: Fix IPsec slowpath fragmentation problem)
> the fragment of ipsec transport mode packets is incorrect.
> because tunnel mode needs IPsec headers and trailer for all fragments,
> while on transport mode it is sufficient to add the headers to the
> first fragment and the trailer to the last.

I mentioned this in an other thread some time ago,
this is due to commit ad0081e43a
"ipv6: Fragment locally generated tunnel-mode IPSec6 packets as needed"
changed tunnel mode to do fragmentation before the transformation
while transport mode still does fragmentation after transformation.
Now, tunnel mode needs IPsec headers and trailer for all fragments,
while on transport mode it is sufficient to add the headers to the
first fragment and the trailer to the last.

> 
> so modify mtu and maxfraglen base on ipsec mode and if fragment is first
> or last.

There might be other opinions, but I don't like to see this IPsec mode
dependent stuff hacked into the generic ipv6 output path.

Basically we have two cases. One where we have to add rt->dst.header_len
to the first fragment and rt->dst.trailer_len to the last fragment,
and the other where we have to add both to all fragments. So perhaps we
could isolate this code and create two functions, one for each case.


> 
> with my test,it work well and does not trigger slow fragment path.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/ipv6/ip6_output.c |   80 +++++++++++++++++++++++++++++++++++++-----------
>  1 files changed, 61 insertions(+), 19 deletions(-)
> 
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index b7ca461..9416887 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1191,19 +1191,23 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
>  	struct ipv6_pinfo *np = inet6_sk(sk);
>  	struct inet_cork *cork;
>  	struct sk_buff *skb;
> -	unsigned int maxfraglen, fragheaderlen;
> +	unsigned int maxfraglen, maxfraglen_prev, fragheaderlen;
>  	int exthdrlen;
>  	int dst_exthdrlen;
>  	int hh_len;
> -	int mtu;
> +	int mtu, mtu_prev;
>  	int copy;
>  	int err;
>  	int offset = 0;
>  	int csummode = CHECKSUM_NONE;
>  	__u8 tx_flags = 0;
> -
> +	bool transport_mode = false;
> +	struct xfrm_state *x = rt->dst.xfrm;
>  	if (flags&MSG_PROBE)
>  		return 0;
> +	if (x && x->props.mode == XFRM_MODE_TRANSPORT)
> +		transport_mode = true;
> +

Btw. beet mode should behave like transport mode here, just tunnel
mode was changed to do fragmentation before the transformation.
