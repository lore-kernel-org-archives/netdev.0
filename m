From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [netfilter-core] [NETFILTER] Apply IPsec to ipt_REJECT packets
Date: Wed, 24 Nov 2004 17:27:47 +1100
Message-ID: <20041124062747.GA13522@gondor.apana.org.au>
References: <20041123084225.GA3514@gondor.apana.org.au> <41A37EC0.8010901@trash.net> <20041123211630.GA9805@gondor.apana.org.au> <41A3AF41.4010700@trash.net> <20041123221900.GA10099@gondor.apana.org.au> <41A3E9D6.9060904@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="+HP7ph2BbKc20aGI"
Cc: netdev@oss.sgi.com, coreteam@netfilter.org,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41A3E9D6.9060904@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Nov 24, 2004 at 02:54:30AM +0100, Patrick McHardy wrote:
>
> >	if (rt->u.dst.error) {
> >@@ -82,6 +88,15 @@
> >		rt = NULL;
> >
> ^ you should return here so xfrm_lookup isn't called without a dst_entry 
> below.

Good point.  Fixed in the following patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for all your help, Patrick.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--+HP7ph2BbKc20aGI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=q

===== net/ipv4/netfilter/ipt_REJECT.c 1.32 vs edited =====
--- 1.32/net/ipv4/netfilter/ipt_REJECT.c	2004-11-14 00:41:07 +11:00
+++ edited/net/ipv4/netfilter/ipt_REJECT.c	2004-11-24 17:26:04 +11:00
@@ -22,6 +22,7 @@
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/route.h>
+#include <net/dst.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv4/ipt_REJECT.h>
 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -38,7 +39,8 @@
 #define DEBUGP(format, args...)
 #endif
 
-static inline struct rtable *route_reverse(struct sk_buff *skb, int hook)
+static inline struct rtable *route_reverse(struct sk_buff *skb, 
+					   struct tcphdr *tcph, int hook)
 {
 	struct iphdr *iph = skb->nh.iph;
 	struct dst_entry *odst;
@@ -75,10 +77,23 @@
 		dst_release(&rt->u.dst);
 		rt = (struct rtable *)skb->dst;
 		skb->dst = odst;
+
+		fl.nl_u.ip4_u.daddr = iph->saddr;
+		fl.nl_u.ip4_u.saddr = iph->daddr;
+		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
 	}
 
 	if (rt->u.dst.error) {
 		dst_release(&rt->u.dst);
+		return NULL;
+	}
+
+	fl.proto = IPPROTO_TCP;
+	fl.fl_ip_sport = tcph->dest;
+	fl.fl_ip_dport = tcph->source;
+
+	if (xfrm_lookup((struct dst_entry **)&rt, &fl, NULL, 0)) {
+		dst_release(&rt->u.dst);
 		rt = NULL;
 	}
 
@@ -110,7 +125,7 @@
 		return;
 
 	/* FIXME: Check checksum --RR */
-	if ((rt = route_reverse(oldskb, hook)) == NULL)
+	if ((rt = route_reverse(oldskb, oth, hook)) == NULL)
 		return;
 
 	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
@@ -282,10 +297,23 @@
 	tos = (iph->tos & IPTOS_TOS_MASK) | IPTOS_PREC_INTERNETCONTROL;
 
 	{
-		struct flowi fl = { .nl_u = { .ip4_u =
-					      { .daddr = skb_in->nh.iph->saddr,
-						.saddr = saddr,
-						.tos = RT_TOS(tos) } } };
+		struct flowi fl = {
+			.nl_u = {
+				.ip4_u = {
+					.daddr = skb_in->nh.iph->saddr,
+					.saddr = saddr,
+					.tos = RT_TOS(tos)
+				}
+			},
+			.proto = IPPROTO_ICMP,
+			.uli_u = {
+				.icmpt = {
+					.type = ICMP_DEST_UNREACH,
+					.code = code
+				}
+			}
+		};
+
 		if (ip_route_output_key(&rt, &fl))
 			return;
 	}

--+HP7ph2BbKc20aGI--
