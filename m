From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 05/13]: [IPV4/6]: Netfilter IPsec output hooks
Date: Tue, 22 Nov 2005 15:40:46 +1100
Message-ID: <20051122044046.GA29166@gondor.apana.org.au>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163134.16666.9265.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20051120163134.16666.9265.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 20, 2005 at 04:31:34PM +0000, Patrick McHardy wrote:
>
> diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
> index ae0779d..b93e7cd 100644
> --- a/net/ipv4/netfilter.c
> +++ b/net/ipv4/netfilter.c
> @@ -78,6 +79,34 @@ int ip_route_me_harder(struct sk_buff **
>  }
>  EXPORT_SYMBOL(ip_route_me_harder);
>  
> +#ifdef CONFIG_XFRM
> +static inline int __ip_dst_output(struct sk_buff *skb)

I'd like to suggest an alternative way of doing this that

1) Keeps this XFRM stuff in xfrm*.c.
2) Removes the need for ip_dst_output.

Please see the attached patch.

> +	do {
> +		err = skb->dst->output(skb);
> +
> +		if (likely(err == 0))
> +			return err;
> +		if (unlikely(err != NET_XMIT_BYPASS))
> +			return err;
> +	} while (skb->dst->xfrm && !skb->dst->xfrm->props.mode);
> +
> +	return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dst->dev,
> +	               ip_dst_output);

The idea is simply to put this stuff in xfrm[46]_output directly.
So for your patch you would simply need to add the two NF_HOOK
calls at the beginning and end of xfrm[46]_output once they've
been modified in the way I outline below.

> diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
> index 66620a9..c135746 100644
> --- a/net/ipv4/xfrm4_output.c
> +++ b/net/ipv4/xfrm4_output.c
> @@ -133,6 +133,7 @@ int xfrm4_output(struct sk_buff *skb)
>  		err = -EHOSTUNREACH;
>  		goto error_nolock;
>  	}
> +	nf_reset(skb);
>  	err = NET_XMIT_BYPASS;

Shouldn't this sit after POST_ROUTING, i.e., once the connection
has been confirmed?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/ip.h b/include/net/ip.h
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -113,26 +113,31 @@ int xfrm4_output(struct sk_buff *skb)
 			goto error_nolock;
 	}
 
-	spin_lock_bh(&x->lock);
-	err = xfrm_state_check(x, skb);
-	if (err)
-		goto error;
-
-	xfrm4_encap(skb);
-
-	err = x->type->output(x, skb);
-	if (err)
-		goto error;
+	do {
+		spin_lock_bh(&x->lock);
+		err = xfrm_state_check(x, skb);
+		if (err)
+			goto error;
+
+		xfrm4_encap(skb);
+
+		err = x->type->output(x, skb);
+		if (err)
+			goto error;
 
-	x->curlft.bytes += skb->len;
-	x->curlft.packets++;
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
 
-	spin_unlock_bh(&x->lock);
+		spin_unlock_bh(&x->lock);
 	
-	if (!(skb->dst = dst_pop(dst))) {
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
+		if (!(skb->dst = dst_pop(dst))) {
+			err = -EHOSTUNREACH;
+			goto error_nolock;
+		}
+		dst = skb->dst;
+		x = dst->xfrm;
+	} while (x && !x->props.mode);
+
 	err = NET_XMIT_BYPASS;
 
 out_exit:
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -110,28 +110,33 @@ int xfrm6_output(struct sk_buff *skb)
 			goto error_nolock;
 	}
 
-	spin_lock_bh(&x->lock);
-	err = xfrm_state_check(x, skb);
-	if (err)
-		goto error;
-
-	xfrm6_encap(skb);
-
-	err = x->type->output(x, skb);
-	if (err)
-		goto error;
-
-	x->curlft.bytes += skb->len;
-	x->curlft.packets++;
-
-	spin_unlock_bh(&x->lock);
+	do {
+		spin_lock_bh(&x->lock);
+		err = xfrm_state_check(x, skb);
+		if (err)
+			goto error;
+
+		xfrm6_encap(skb);
+
+		err = x->type->output(x, skb);
+		if (err)
+			goto error;
+
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
+
+		spin_unlock_bh(&x->lock);
+
+		skb->nh.raw = skb->data;
+		
+		if (!(skb->dst = dst_pop(dst))) {
+			err = -EHOSTUNREACH;
+			goto error_nolock;
+		}
+		dst = skb->dst;
+		x = dst->xfrm;
+	} while (x && !x->props.mode);
 
-	skb->nh.raw = skb->data;
-	
-	if (!(skb->dst = dst_pop(dst))) {
-		err = -EHOSTUNREACH;
-		goto error_nolock;
-	}
 	err = NET_XMIT_BYPASS;
 
 out_exit:
