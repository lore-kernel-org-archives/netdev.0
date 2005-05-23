From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Super TSO v2
Date: Mon, 23 May 2005 19:54:17 +1000
Message-ID: <20050523095417.GA18770@gondor.apana.org.au>
References: <20050520.115154.48807299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050520.115154.48807299.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 20, 2005 at 06:51:54PM +0000, David S. Miller wrote:
> 
> Ok, new version of the patch.  Besides some cleanups,
> the main change is packet send deferral at ACK arrival
> time.

Thanks for the great work Dave.

> @@ -712,7 +713,7 @@ new_segment:
>  		if (!(psize -= copy))
>  			goto out;
>  
> -		if (skb->len != mss_now || (flags & MSG_OOB))
> +		if (skb->len != size_goal || (flags & MSG_OOB))
>  			continue;

> +unsigned int tcp_current_mss(struct sock *sk, int large_allowed)

> +
> +	if (tp->xmit_size_cache != xmit_cache) {
> +		u16 xmit_size_goal = mss_now;
> +
> +		if (doing_tso) {
> +			xmit_size_goal = 65535 -
> +				tp->af_specific->net_header_len -
> +				tp->ext_header_len - tp->tcp_header_len;
> +
> +			if (tp->rx_opt.eff_sacks)
> +				xmit_size_goal -= (TCPOLEN_SACK_BASE_ALIGNED +
> +						   (tp->rx_opt.eff_sacks *
> +						    TCPOLEN_SACK_PERBLOCK));
> +
> +			xmit_size_goal -= (xmit_size_goal % mss_now);
> +		}
> +		tp->xmit_size_goal = xmit_size_goal;
> +		tp->xmit_size_cache = xmit_cache;
> +	}
> +
>  	return mss_now;
>  }

Perhaps we should set the goal based on the cwnd as we do now?

As it is I believe we may be doing more work compared to the
status quo because it's always building 64K blocks and then
cutting them up as dictated by the cwnd.  On the other hand, the
current code simply builds the packets up to the size that cwnd
allows.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
