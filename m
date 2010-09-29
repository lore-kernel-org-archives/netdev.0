From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 06:24:55 +0200
Message-ID: <1285734295.22570.25.camel@edumazet-laptop>
References: <20100928084139.GA26793@gondor.apana.org.au>
	 <1285663738.2607.30.camel@edumazet-laptop>
	 <1285733911.22570.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61466 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896Ab0I2EZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 00:25:03 -0400
Received: by fxm14 with SMTP id 14so241460fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 21:24:59 -0700 (PDT)
In-Reply-To: <1285733911.22570.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 29 septembre 2010 =C3=A0 06:18 +0200, Eric Dumazet a =C3=A9=
crit :

> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 03e62f9..25e9ad6 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -862,6 +862,7 @@ int __init icmpv6_init(void)
>  	err =3D -EAGAIN;
>  	if (inet6_add_protocol(&icmpv6_protocol, IPPROTO_ICMPV6) < 0)
>  		goto fail;
> +	register_icmpv6_send(icmpv6_send);
>  	return 0;
> =20
>  fail:
> @@ -874,6 +875,7 @@ void icmpv6_cleanup(void)
>  {
>  	unregister_pernet_subsys(&icmpv6_sk_ops);
>  	inet6_del_protocol(&icmpv6_protocol, IPPROTO_ICMPV6);
> +	unregister_icmpv6_send();
>  }

Well, we all know icmpv6_cleanup() is not really called (or can we
really unload ipv6 ?).

But unregister_icmpv6_send() should be the first call in it.

Updated patch :

[PATCH v2] ipv6: introduce call_icmpv6_send()

ip_gre module has a dependency against IPv6:

It needs to call icmpv6_send(), while this symbol is available only if
IPv6 module is loaded (or static)

Introduce call_icmpv6_send(), provided in core network, to indirectly
call icmpv6_send() function if available.

Reported-by: Patrick McHardy <kaber@trash.net>
Reported-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/icmp.h |    6 ++++++
 net/ipv4/icmp.c    |   33 +++++++++++++++++++++++++++++++++
 net/ipv4/ip_gre.c  |    2 +-
 net/ipv6/icmp.c    |    2 ++
 4 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 6e991e0..ec45a4f 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -48,4 +48,10 @@ extern void	icmp_out_count(struct net *net, unsigned=
 char type);
 /* Move into dst.h ? */
 extern int 	xrlim_allow(struct dst_entry *dst, int timeout);
=20
+extern int register_icmpv6_send(void (*func)(struct sk_buff *skb, u8 t=
ype,
+					     u8 code, __u32 info));
+extern int unregister_icmpv6_send(void);
+extern void call_icmpv6_send(struct sk_buff *skb, u8 type,
+			     u8 code, __u32 info);
+
 #endif	/* _ICMP_H */
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index a0d847c..4c5b817 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1217,3 +1217,36 @@ int __init icmp_init(void)
 {
 	return register_pernet_subsys(&icmp_sk_ops);
 }
+
+
+/* wrappers to call icmpv6_send() if ipv6 module is loaded */
+
+static void __rcu (*icmpv6_send_ptr)(struct sk_buff *skb, u8 type, u8 =
code,
+				     __u32 info);
+
+int register_icmpv6_send(void (*func)(struct sk_buff *skb, u8 type, u8=
 code,
+				      __u32 info))
+{
+	rcu_assign_pointer(icmpv6_send_ptr, func);
+	return 0;
+}
+EXPORT_SYMBOL(register_icmpv6_send);
+
+int unregister_icmpv6_send(void)
+{
+	rcu_assign_pointer(icmpv6_send_ptr, NULL);
+	synchronize_rcu();
+	return 0;
+}
+EXPORT_SYMBOL(unregister_icmpv6_send);
+
+/* called with rcu_read_lock */
+void call_icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 inf=
o)
+{
+	void (*func)(struct sk_buff *skb, u8 type, u8 code, __u32 info);
+
+	func =3D rcu_dereference(icmpv6_send_ptr);
+	if (func)
+		(*func)(skb, type, code, info);
+}
+EXPORT_SYMBOL(call_icmpv6_send);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 35c93e8..6cbd37c 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -788,7 +788,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 		}
=20
 		if (mtu >=3D IPV6_MIN_MTU && mtu < skb->len - tunnel->hlen + gre_hle=
n) {
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+			call_icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			ip_rt_put(rt);
 			goto tx_error;
 		}
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 03e62f9..2d0f56b 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -862,6 +862,7 @@ int __init icmpv6_init(void)
 	err =3D -EAGAIN;
 	if (inet6_add_protocol(&icmpv6_protocol, IPPROTO_ICMPV6) < 0)
 		goto fail;
+	register_icmpv6_send(icmpv6_send);
 	return 0;
=20
 fail:
@@ -872,6 +873,7 @@ fail:
=20
 void icmpv6_cleanup(void)
 {
+	unregister_icmpv6_send();
 	unregister_pernet_subsys(&icmpv6_sk_ops);
 	inet6_del_protocol(&icmpv6_protocol, IPPROTO_ICMPV6);
 }


