From: David Miller <davem@davemloft.net>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Mon, 05 Feb 2007 13:11:59 -0800 (PST)
Message-ID: <20070205.131159.88703371.davem@davemloft.net>
References: <20070204.205315.10325007.davem@davemloft.net>
	<000701c74967$1ad9a9c0$cc0a010a@tcssec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, latten@austin.ibm.com, netdev@vger.kernel.org,
	paul.moore@hp.com, vyekkirala@tcsfw4.tcs-sec.com,
	herbert@gondor.apana.org.au
To: vyekkirala@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933428AbXBEVMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 16:12:00 -0500
In-Reply-To: <000701c74967$1ad9a9c0$cc0a010a@tcssec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Date: Mon, 5 Feb 2007 14:49:17 -0600

> > Something like this (untested) on the ipv4 side, for example:
> > 
> > diff --git a/include/net/route.h b/include/net/route.h
> > index 486e37a..a8af632 100644
> > --- a/include/net/route.h
> > +++ b/include/net/route.h
> > @@ -146,7 +146,8 @@ static inline char rt_tos2priority(u8 tos)
> >  
> >  static inline int ip_route_connect(struct rtable **rp, __be32 dst,
> >  				   __be32 src, u32 tos, int 
> > oif, u8 protocol,
> > -				   __be16 sport, __be16 dport, 
> > struct sock *sk)
> > +				   __be16 sport, __be16 dport, 
> > struct sock *sk,
> > +				   int flags)
> >  {
> >  	struct flowi fl = { .oif = oif,
> >  			    .nl_u = { .ip4_u = { .daddr = dst,
> > @@ -168,7 +169,7 @@ static inline int ip_route_connect(struct 
> > rtable **rp, __be32 dst,
> >  		*rp = NULL;
> >  	}
> >  	security_sk_classify_flow(sk, &fl);
> > -	return ip_route_output_flow(rp, &fl, sk, 0);
> > +	return ip_route_output_flow(rp, &fl, sk, 1);
> 
> I guess you meant to pass the new flags param to ip_route_output_flow here?

Yes I did, thanks for catching that.

commit a6886040ae6b8c9bfc811bd0dbdb47cfa3f2db29
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Feb 5 13:11:42 2007 -0800

    [IPV4]: Fix thinko in ip_route_connect().
    
    The idea was the pass in the new "flags" parameter down
    to ip_route_output_flow().
    
    Noticed by Venkat Tekkirala.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/route.h b/include/net/route.h
index a8af632..1440bdb 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -169,7 +169,7 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 		*rp = NULL;
 	}
 	security_sk_classify_flow(sk, &fl);
-	return ip_route_output_flow(rp, &fl, sk, 1);
+	return ip_route_output_flow(rp, &fl, sk, flags);
 }
 
 static inline int ip_route_newports(struct rtable **rp, u8 protocol,
