From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH] xfrm: don't segment UFO packets
Date: Thu, 17 Mar 2016 18:08:55 +0100
Message-ID: <20160317170855.GA21145@midget.suse.cz>
References: <20160129234424.GC7907@midget.suse.cz>
 <20160130042102.GA22809@gondor.apana.org.au>
 <20160316160026.GB19258@midget.suse.cz>
 <20160317050359.GA3840@gondor.apana.org.au>
 <20160317094115.GA11706@midget.suse.cz>
 <20160317102459.GG3347@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49562 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030300AbcCQRI6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 13:08:58 -0400
Content-Disposition: inline
In-Reply-To: <20160317102459.GG3347@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 11:24:59AM +0100, Steffen Klassert wrote:
> In IPv6 this check is missing, so this could be the
> problem if this is IPv6.

indeed, this patch also fixes my problem:

--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1353,6 +1353,7 @@ emsgsize:
 	     (skb && skb_is_gso(skb))) &&
 	    (sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->dst.dev->features & NETIF_F_UFO) &&
+	    !rt->dst.header_len &&
 	    (sk->sk_type == SOCK_DGRAM)) {
 		err = ip6_ufo_append_data(sk, queue, getfrag, from, length,
 					  hh_len, fragheaderlen,

I can't say which is better. Herbert originally seemed to like
the fix inside xfrm_output().

The IPv4 part is fixed by commit
c146066ab80267c3305de5dda6a4083f06df9265 (ipv4: Don't use ufo
handling on later transformed packets)

Thanks,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
