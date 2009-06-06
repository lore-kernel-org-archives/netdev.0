From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next 2/4] udp: Handle large UFO packets from untrusted
 sources
Date: Fri, 05 Jun 2009 17:16:31 -0700
Message-ID: <1244247391.1526.171.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, kvm@vger.kernel.org,
	herbert.xu@redhat.com, rusty@rustcorp.com.au
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Setup partial checksum and add gso checks to handle large UFO packets from
untrusted sources.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---


 include/net/udp.h  |    3 +++
 net/ipv4/af_inet.c |    2 ++
 net/ipv4/udp.c     |   60 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/udp.c     |   22 +++++++++++++++++++
 4 files changed, 87 insertions(+), 0 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 90e6ce5..274b764 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -207,4 +207,7 @@ extern void udp4_proc_exit(void);
 #endif
 
 extern void udp_init(void);
+
+extern int udp_v4_gso_send_check(struct sk_buff *skb);
+extern struct sk_buff *udp_ufo_fragment(struct sk_buff *skb, int features);
 #endif	/* _UDP_H */
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d873621..1c1ac7d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1426,6 +1426,8 @@ static struct net_protocol tcp_protocol = {
 static struct net_protocol udp_protocol = {
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
+	.gso_send_check = udp_v4_gso_send_check,
+	.gso_segment = udp_ufo_fragment,
 	.no_policy =	1,
 	.netns_ok =	1,
 };
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8f4158d..678bdf9 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1815,6 +1815,66 @@ void __init udp_init(void)
 	sysctl_udp_wmem_min = SK_MEM_QUANTUM;
 }
 
+int udp_v4_gso_send_check(struct sk_buff *skb)
+{
+	const struct iphdr *iph;
+	struct udphdr *uh;
+
+	if (!pskb_may_pull(skb, sizeof(*uh)))
+		return -EINVAL;
+
+	iph = ip_hdr(skb);
+	uh = udp_hdr(skb);
+
+	uh->check = 0;
+	uh->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len, IPPROTO_UDP, 0);
+	skb->csum_start = skb_transport_header(skb) - skb->head;
+	skb->csum_offset = offsetof(struct udphdr, check);
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	return 0;
+}
+
+struct sk_buff *udp_ufo_fragment(struct sk_buff *skb, int features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct udphdr *uh;
+	unsigned uhlen;
+	unsigned int mss;
+
+	if (!pskb_may_pull(skb, sizeof(*uh)))
+		goto out;
+
+	uh = udp_hdr(skb);
+	uhlen = sizeof(*uh);
+
+	__skb_pull(skb, uhlen);
+
+	mss = skb_shinfo(skb)->gso_size;
+	if (unlikely(skb->len <= mss))
+		goto out;
+
+	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
+		int type = skb_shinfo(skb)->gso_type;
+
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
+			     !(type & (SKB_GSO_UDP))))
+			goto out;
+
+		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
+
+		segs = NULL;
+		goto out;
+	}
+
+	/* Software UFO is not yet supported */
+	segs = ERR_PTR(-EPROTONOSUPPORT);
+
+out:
+	return segs;
+}
+EXPORT_SYMBOL(udp_ufo_fragment);
+
+
 EXPORT_SYMBOL(udp_disconnect);
 EXPORT_SYMBOL(udp_ioctl);
 EXPORT_SYMBOL(udp_prot);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index fad0f5f..ccd42d5 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1081,9 +1081,31 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 }
 #endif
 
+
+static int udpv6_gso_send_check(struct sk_buff *skb)
+{
+	struct ipv6hdr *ipv6h;
+	struct udphdr *uh;
+
+	if (!pskb_may_pull(skb, sizeof(*uh)))
+		return -EINVAL;
+
+	ipv6h = ipv6_hdr(skb);
+	uh = udp_hdr(skb);
+
+	uh->check = 0;
+	uh->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len, IPPROTO_UDP, 0);
+	skb->csum_start = skb_transport_header(skb) - skb->head;
+	skb->csum_offset = offsetof(struct udphdr, check);
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	return 0;
+}
+
 static struct inet6_protocol udpv6_protocol = {
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
+	.gso_send_check =	udpv6_gso_send_check,
+	.gso_segment	=	udp_ufo_fragment,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 


