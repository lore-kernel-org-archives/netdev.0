From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 05/13]: [IPV4/6]: Netfilter IPsec output hooks
Date: Mon, 28 Nov 2005 15:56:11 +1100
Message-ID: <20051128045611.GA9571@gondor.apana.org.au>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163134.16666.9265.sendpatchset@localhost.localdomain>
	<20051122044046.GA29166@gondor.apana.org.au>
	<4382A44F.9000105@trash.net>
	<20051122103038.GA31532@gondor.apana.org.au>
	<20051122103139.GA4632@gondor.apana.org.au>
	<20051122121358.GA9057@gondor.apana.org.au>
	<438A5837.5040706@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <438A5837.5040706@trash.net>
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

On Mon, Nov 28, 2005 at 02:07:03AM +0100, Patrick McHardy wrote:
> 
> Thanks, this looks great. I've changed it to only call the hooks

Glad you liked it :)

> before tunnel mode transforms and added a missing dst_output call
> for the final packet.

This shouldn't be necessary if you apply it on top of my previous
patch which made xfrm[46]_output process the first SA and all subsequent
transport mode SAs.  I've included that patch here again.

I think it still makes sense to do that because this corresponds
with the usual representation of an IPsec connection and it
simplifies the handling of netfilter hooks.

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
