From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Sat, 4 Feb 2012 19:39:29 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1202041912430.1496@ja.ssi.bg>
References: <4F2B7DF1.5050303@oktetlabs.ru>   <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1328358402.2731.11.camel@edumazet-laptop>  <alpine.LFD.2.00.1202041537370.1496@ja.ssi.bg>
 <1328374715.2731.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1238273273-1328377170=:1496"
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:57009 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058Ab2BDRix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Feb 2012 12:38:53 -0500
In-Reply-To: <1328374715.2731.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1238273273-1328377170=:1496
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Sat, 4 Feb 2012, Eric Dumazet wrote:

> Le samedi 04 février 2012 à 17:48 +0200, Julian Anastasov a écrit :
> 
> > 	flowi4_tos is missing from this list but anyways,
> > it looks wrong because __ip_route_output_key returns data
> > in saddr and daddr, such change will break source address
> > autoselection and destination address autoselection. That is
> > what ip_route_connect is trying to do. May be
> > ip_route_connect should be fixed instead?
> > 
> 
> Thanks Julian, this is indeed tricky.
> 
> I tested successfully the following patch, maybe we also need
> to restore tos bits ?

	Yes, but reset must happen before every lookup,
not after it.

> diff --git a/include/net/route.h b/include/net/route.h
> index 91855d1..f27a82d 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -272,7 +272,9 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
>  		ip_rt_put(rt);
>  	}
>  	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
> -	return ip_route_output_flow(net, fl4, sk);
> +	rt = ip_route_output_flow(net, fl4, sk);
> +	fl4->flowi4_oif = oif;
> +	return rt;
>  }
>  
>  static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable *rt,

	May be it will need also fix for ip_route_newports:

	fl4->flowi4_oif = sk->sk_bound_dev_if;
	fl4->flowi4_tos = RT_CONN_FLAGS(sk);

	Here is what I have in mind but may be saddr/daddr
do not need to be updated at all?

[PATCH] ipv4: reset flowi parameters on route connect

	ip_route_connect and ip_route_newports need to reset
some flowi fields that are input parameters because we do not
want unnecessary binding to oif. Fixes problem with lost
RST packets when connecting to local port that has no
listener.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 include/net/flow.h  |   10 ++++++++++
 include/net/route.h |    4 ++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 9b58243..6c469db 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -93,6 +93,16 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 	fl4->fl4_dport = dport;
 	fl4->fl4_sport = sport;
 }
+
+/* Reset some input parameters after previous lookup */
+static inline void flowi4_update_output(struct flowi4 *fl4, int oif, __u8 tos,
+					__be32 daddr, __be32 saddr)
+{
+	fl4->flowi4_oif = oif;
+	fl4->flowi4_tos = tos;
+	fl4->daddr = daddr;
+	fl4->saddr = saddr;
+}
 				      
 
 struct flowi6 {
diff --git a/include/net/route.h b/include/net/route.h
index 91855d1..b1c0d5b 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -270,6 +270,7 @@ static inline struct rtable *ip_route_connect(struct flowi4 *fl4,
 		if (IS_ERR(rt))
 			return rt;
 		ip_rt_put(rt);
+		flowi4_update_output(fl4, oif, tos, fl4->daddr, fl4->saddr);
 	}
 	security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 	return ip_route_output_flow(net, fl4, sk);
@@ -284,6 +285,9 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 		fl4->fl4_dport = dport;
 		fl4->fl4_sport = sport;
 		ip_rt_put(rt);
+		flowi4_update_output(fl4, sk->sk_bound_dev_if,
+				     RT_CONN_FLAGS(sk), fl4->daddr,
+				     fl4->saddr);
 		security_sk_classify_flow(sk, flowi4_to_flowi(fl4));
 		return ip_route_output_flow(sock_net(sk), fl4, sk);
 	}
-- 
1.7.3.4

---1463811672-1238273273-1328377170=:1496--
