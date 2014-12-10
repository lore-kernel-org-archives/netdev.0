From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected] xfrm: TCP connection initiating PMTU discovery
 stalls on v3.
Date: Wed, 10 Dec 2014 11:10:03 -0800
Message-ID: <1418238603.27198.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
	 <2625472.GutY3xCvKT@h2o.as.studentenwerk.mhn.de>
	 <1418161219.27198.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <6700748.kZ07xrNvHX@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Jarosch <thomas.jarosch@intra2net.com>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:59589 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933042AbaLJTKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 14:10:06 -0500
Received: by mail-ie0-f178.google.com with SMTP id tp5so3314654ieb.37
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 11:10:05 -0800 (PST)
In-Reply-To: <6700748.kZ07xrNvHX@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-12-10 at 19:34 +0100, Wolfgang Walter wrote:

> So gso is on. When the hang happens sk_setup_caps is called from		
> inet_sk_rebuild_header(). Now the path
> 
> 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
> 
> is taken as dst->header_len is now non zero.
> 
> This is the reason why later calls of sk_can_gso() return false.
> 
> I'll try to change the above patch to
> 
> @@ -1585,6 +1585,8 @@ void sk_setup_caps(struct sock *sk, struct dst_entry
> *dst) sk->sk_gso_max_size = dst->dev->gso_max_size;
>  			sk->sk_gso_max_segs = dst->dev->gso_max_segs;
>  		}
> 	}
> +   if (sk_can_gso(sk)) {
> +		sk->sk_gso_max_segs = 1;
>  	}
>  }
>  EXPORT_SYMBOL_GPL(sk_setup_caps);
> 
> so that the case that GSO is disabled because of dst->header_len != 0 sets 
> sk_gso_max_segs, too.

Sounds good, or maybe simply :

diff --git a/net/core/sock.c b/net/core/sock.c
index 9a56b2000c3f374fb95aedada3327447816a9512..edca31319dfee57cabe5b376505324bea07f767a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1577,6 +1577,7 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 	if (sk->sk_route_caps & NETIF_F_GSO)
 		sk->sk_route_caps |= NETIF_F_GSO_SOFTWARE;
 	sk->sk_route_caps &= ~sk->sk_route_nocaps;
+	sk->sk_gso_max_segs = 1;
 	if (sk_can_gso(sk)) {
 		if (dst->header_len) {
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
