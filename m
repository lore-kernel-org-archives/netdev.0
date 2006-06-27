From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Added GSO header verification
Date: Wed, 28 Jun 2006 08:31:20 +1000
Message-ID: <20060627223120.GA19026@gondor.apana.org.au>
References: <20060627120714.GA15270@gondor.apana.org.au> <1151441195.3543.3.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55301 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422679AbWF0WcD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 18:32:03 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1151441195.3543.3.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2006 at 01:46:35PM -0700, Michael Chan wrote:
> On Tue, 2006-06-27 at 22:07 +1000, Herbert Xu wrote:
> 
> > [NET]: Added GSO header verification
> >
> > @@ -2166,10 +2166,14 @@ struct sk_buff *tcp_tso_segment(struct s
> >         if (!pskb_may_pull(skb, thlen))
> >                 goto out;
> >  
> > +       segs = NULL;
> > +       if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST))
> > +               goto out;
> > +
> 
> This logic doesn't look right to me.  Perhaps it's backwards and should
> be:
> 
> if (!skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST))

Oops, you're absolutely right.  Here is the fix.

[NET]: Fix logical error in skb_gso_ok

The test in skb_gso_ok is backwards.  Noticed by Michael Chan
<mchan@broadcom.com>.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 84b0f0d..efd1e2a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -994,12 +994,12 @@ static inline int skb_gso_ok(struct sk_b
 {
 	int feature = skb_shinfo(skb)->gso_size ?
 		      skb_shinfo(skb)->gso_type << NETIF_F_GSO_SHIFT : 0;
-	return (features & feature) != feature;
+	return (features & feature) == feature;
 }
 
 static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
 {
-	return skb_gso_ok(skb, dev->features);
+	return !skb_gso_ok(skb, dev->features);
 }
 
 #endif /* __KERNEL__ */
