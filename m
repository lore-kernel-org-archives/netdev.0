From: Patrick McHardy <kaber@trash.net>
Subject: Re: [3/4] [IPSEC] Add route element to xfrm_dst
Date: Mon, 14 Mar 2005 12:52:16 +0100
Message-ID: <42357AF0.4080205@trash.net>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050214221433.GB18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> This patch adds a pointer to the route corresponding to the specific
> flow over the SA of an xfrm_dst that's being used.
> 
> It also sets the next pointer of each xfrm_dst to the one above it.
> This allows to traverse the list upwards from the bottom.

Looking at this again, I noticed a problem:

> +		if (remote != fl_tunnel.fl4_dst) {
> +			fl_tunnel.fl4_src = local;
> +			fl_tunnel.fl4_dst = remote;
> +			err = xfrm_dst_lookup((struct xfrm_dst **)&rt,
> +					      &fl_tunnel, AF_INET);
> +			if (err)
> +				goto error;
> +		} else
> +			dst_hold(&rt->u.dst);
>  	}
> +
>  	dst_prev->child = &rt->u.dst;
> +	dst->path = &rt->u.dst;
> +
> +	*dst_p = dst;
> +	dst = dst_prev;
> +
> +	dst_prev = *dst_p;
>  	i = 0;
> -	for (dst_prev = dst; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
> +	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {

Since the tunnel dst is not necessarily the last in the bundle anymore,
we might miss to initialize some dsts, for example with ipcomp/tunnel +
esp/transport. If we have nested tunnels we'll fiddle with entries in
the routing cache.

Regards
Patrick
