From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH] [NETFILTER] xt_TCPMSS: combine nearly identical
 reverse_mtu4/6
Date: Sat, 29 Mar 2008 16:24:18 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0803291621170.28605@fbirervta.pbzchgretzou.qr>
References: <Pine.LNX.4.64.0803291520210.8374@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick Hardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0803291520210.8374@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Saturday 2008-03-29 14:25, Ilpo J=E4rvinen wrote:
>
> Added tcpmss_reverse_mtu, only flowi setup and family differ
>
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
> net/netfilter/xt_TCPMSS.c |   34 ++++++++++++++--------------------
> 1 files changed, 14 insertions(+), 20 deletions(-)

How about this one instead?

commit 1143bd2cbcddb9fcdbffea6a2edfde42dca5bb46
Author: Jan Engelhardt <jengelh@computergmbh.de>
Date:   Sat Mar 29 16:20:13 2008 +0100

     [NETFILTER]: Collapse tcpmss_reverse_mtu{4,6} into one function

     Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
---
  net/netfilter/xt_TCPMSS.c |   44 ++++++++++++++----------------------=
--------
  1 files changed, 14 insertions(+), 30 deletions(-)

diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 217e2b6..2e3fe8e 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -147,15 +147,19 @@ tcpmss_mangle_packet(struct sk_buff *skb,
  	return TCPOLEN_MSS;
  }

-static u_int32_t tcpmss_reverse_mtu4(const struct iphdr *iph)
+static u_int32_t tcpmss_reverse_mtu(const struct sk_buff *skb,
+                                    unsigned int family)
  {
-	struct flowi fl =3D {
-		.fl4_dst =3D iph->saddr,
-	};
+	struct flowi fl =3D {};
  	const struct nf_afinfo *ai;
  	struct rtable *rt =3D NULL;
  	u_int32_t mtu     =3D ~0U;

+	if (family =3D=3D AF_INET)
+		fl.fl4_dst =3D ip_hdr(skb)->saddr;
+	else
+		fl.fl6_dst =3D ipv6_hdr(skb)->saddr;
+
  	rcu_read_lock();
  	ai =3D nf_get_afinfo(AF_INET);
  	if (ai !=3D NULL)
@@ -178,9 +182,10 @@ tcpmss_tg4(struct sk_buff *skb, const struct net_d=
evice *in,
  	__be16 newlen;
  	int ret;

-	ret =3D tcpmss_mangle_packet(skb, targinfo, tcpmss_reverse_mtu4(iph),
-				   iph->ihl * 4,
-				   sizeof(*iph) + sizeof(struct tcphdr));
+	ret =3D tcpmss_mangle_packet(skb, targinfo,
+	                           tcpmss_reverse_mtu(skb, AF_INET),
+	                           iph->ihl * 4,
+	                           sizeof(*iph) + sizeof(struct tcphdr));
  	if (ret < 0)
  		return NF_DROP;
  	if (ret > 0) {
@@ -193,28 +198,6 @@ tcpmss_tg4(struct sk_buff *skb, const struct net_d=
evice *in,
  }

  #if defined(CONFIG_IP6_NF_IPTABLES) || defined(CONFIG_IP6_NF_IPTABLES=
_MODULE)
-static u_int32_t tcpmss_reverse_mtu6(const struct ipv6hdr *iph)
-{
-	struct flowi fl =3D {
-		.fl6_dst =3D iph->saddr,
-	};
-	const struct nf_afinfo *ai;
-	struct rtable *rt =3D NULL;
-	u_int32_t mtu     =3D ~0U;
-
-	rcu_read_lock();
-	ai =3D nf_get_afinfo(AF_INET6);
-	if (ai !=3D NULL)
-		ai->route((struct dst_entry **)&rt, &fl);
-	rcu_read_unlock();
-
-	if (rt !=3D NULL) {
-		mtu =3D dst_mtu(&rt->u.dst);
-		dst_release(&rt->u.dst);
-	}
-	return mtu;
-}
-
  static unsigned int
  tcpmss_tg6(struct sk_buff *skb, const struct net_device *in,
             const struct net_device *out, unsigned int hooknum,
@@ -229,7 +212,8 @@ tcpmss_tg6(struct sk_buff *skb, const struct net_de=
vice *in,
  	tcphoff =3D ipv6_skip_exthdr(skb, sizeof(*ipv6h), &nexthdr);
  	if (tcphoff < 0)
  		return NF_DROP;
-	ret =3D tcpmss_mangle_packet(skb, targinfo, tcpmss_reverse_mtu6(ipv6h=
),
+	ret =3D tcpmss_mangle_packet(skb, targinfo,
+	                           tcpmss_reverse_mtu(skb, AF_INET6),
  				   tcphoff,
  				   sizeof(*ipv6h) + sizeof(struct tcphdr));
  	if (ret < 0)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
