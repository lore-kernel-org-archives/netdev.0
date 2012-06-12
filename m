From: Michel Machado <michel@digirati.com.br>
Subject: [PATCH 1/1] net-next: add dev_loopback_xmit() to avoid duplicate
 code
Date: Tue, 12 Jun 2012 16:16:35 -0400
Message-ID: <1339532195.2701.8.camel@Thor>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jpirko@redhat.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add dev_loopback_xmit() in order to deduplicate functions
ip_dev_loopback_xmit() (in net/ipv4/ip_output.c) and
ip6_dev_loopback_xmit() (in net/ipv6/ip6_output.c).

I was about to reinvent the wheel when I noticed that
ip_dev_loopback_xmit() and ip6_dev_loopback_xmit() do exactly what I
need and are not IP-only functions, but they were not available to reus=
e
elsewhere.

ip6_dev_loopback_xmit() does not have line "skb_dst_force(skb);", but I
understand that this is harmless, and should be in dev_loopback_xmit().

Signed-off-by: Michel Machado <michel@digirati.com.br>
CC: "David S. Miller" <davem@davemloft.net>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
CC: Eric Dumazet <edumazet@google.com>
CC: Jiri Pirko <jpirko@redhat.com>
CC: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
CC: Ben Hutchings <bhutchings@solarflare.com>
---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e7fd468..1c49c21 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1626,6 +1626,7 @@ extern int		dev_alloc_name(struct net_device *dev=
, const char *name);
 extern int		dev_open(struct net_device *dev);
 extern int		dev_close(struct net_device *dev);
 extern void		dev_disable_lro(struct net_device *dev);
+extern int		dev_loopback_xmit(struct sk_buff *newskb);
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
 extern void		unregister_netdevice_queue(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index cd09819..c6e29ea6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2476,6 +2476,23 @@ static DEFINE_PER_CPU(int, xmit_recursion);
 #define RECURSION_LIMIT 10
=20
 /**
+ *	dev_loopback_xmit - loop back @skb
+ *	@skb: buffer to transmit
+ */
+int dev_loopback_xmit(struct sk_buff *skb)
+{
+	skb_reset_mac_header(skb);
+	__skb_pull(skb, skb_network_offset(skb));
+	skb->pkt_type =3D PACKET_LOOPBACK;
+	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+	WARN_ON(!skb_dst(skb));
+	skb_dst_force(skb);
+	netif_rx_ni(skb);
+	return 0;
+}
+EXPORT_SYMBOL(dev_loopback_xmit);
+
+/**
  *	dev_queue_xmit - transmit a buffer
  *	@skb: buffer to transmit
  *
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 451f97c..d34ddde 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -113,19 +113,6 @@ int ip_local_out(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(ip_local_out);
=20
-/* dev_loopback_xmit for use with netfilter. */
-static int ip_dev_loopback_xmit(struct sk_buff *newskb)
-{
-	skb_reset_mac_header(newskb);
-	__skb_pull(newskb, skb_network_offset(newskb));
-	newskb->pkt_type =3D PACKET_LOOPBACK;
-	newskb->ip_summed =3D CHECKSUM_UNNECESSARY;
-	WARN_ON(!skb_dst(newskb));
-	skb_dst_force(newskb);
-	netif_rx_ni(newskb);
-	return 0;
-}
-
 static inline int ip_select_ttl(struct inet_sock *inet, struct dst_ent=
ry *dst)
 {
 	int ttl =3D inet->uc_ttl;
@@ -281,7 +268,7 @@ int ip_mc_output(struct sk_buff *skb)
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING,
 					newskb, NULL, newskb->dev,
-					ip_dev_loopback_xmit);
+					dev_loopback_xmit);
 		}
=20
 		/* Multicasts with ttl 0 must not go beyond the host */
@@ -296,7 +283,7 @@ int ip_mc_output(struct sk_buff *skb)
 		struct sk_buff *newskb =3D skb_clone(skb, GFP_ATOMIC);
 		if (newskb)
 			NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING, newskb,
-				NULL, newskb->dev, ip_dev_loopback_xmit);
+				NULL, newskb->dev, dev_loopback_xmit);
 	}
=20
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb, NULL,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d99fdc6..8443c00 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -83,19 +83,6 @@ int ip6_local_out(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(ip6_local_out);
=20
-/* dev_loopback_xmit for use with netfilter. */
-static int ip6_dev_loopback_xmit(struct sk_buff *newskb)
-{
-	skb_reset_mac_header(newskb);
-	__skb_pull(newskb, skb_network_offset(newskb));
-	newskb->pkt_type =3D PACKET_LOOPBACK;
-	newskb->ip_summed =3D CHECKSUM_UNNECESSARY;
-	WARN_ON(!skb_dst(newskb));
-
-	netif_rx_ni(newskb);
-	return 0;
-}
-
 static int ip6_finish_output2(struct sk_buff *skb)
 {
 	struct dst_entry *dst =3D skb_dst(skb);
@@ -121,7 +108,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING,
 					newskb, NULL, newskb->dev,
-					ip6_dev_loopback_xmit);
+					dev_loopback_xmit);
=20
 			if (ipv6_hdr(skb)->hop_limit =3D=3D 0) {
 				IP6_INC_STATS(dev_net(dev), idev,
