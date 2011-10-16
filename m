From: Dan Siemon <dan@coverfire.com>
Subject: [PATCH] cls_flow: Add tunnel support to the flow classifier
Date: Sun, 16 Oct 2011 19:06:12 -0400
Message-ID: <1318806373.7169.35.camel@ganymede>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-+TrWPHoibEreUowuqhDW"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.coverfire.com ([69.41.199.58]:47451 "EHLO
	alpha.coverfire.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945Ab1JPXGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2011 19:06:15 -0400
Received: from [192.168.88.98] (ganymede [192.168.88.98])
	(authenticated bits=0)
	by alpha.coverfire.com (8.14.4/8.14.4) with ESMTP id p9GN6DI6016906
	(version=TLSv1/SSLv3 cipher=DHE-RSA-CAMELLIA256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 16 Oct 2011 19:06:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+TrWPHoibEreUowuqhDW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

When used on an interface carrying tunneled traffic the flow classifier
can't look into the tunnels so all of the traffic within the tunnel is
treated as a single flow. This does not allow any type of intelligent
queuing to occur. This patch adds new keys to the flow classifier which
look inside the tunnel. Presently IP-IP, IP-IPv6, IPv6-IPv6 and IPv6-IP
tunnels are supported.

If you are interested I have posted some background and experimental
results at:
http://www.coverfire.com/archives/2011/10/16/making-the-linux-flow-classifi=
er-tunnel-aware/

The related iproute2 patch can be found at the above URL as well.

Signed-off-by: Dan Siemon <dan@coverfire.com>

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index defbde2..2f80fa0 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -333,6 +333,11 @@ enum {
 	FLOW_KEY_SKGID,
 	FLOW_KEY_VLAN_TAG,
 	FLOW_KEY_RXHASH,
+	FLOW_KEY_TUNNEL_SRC,
+	FLOW_KEY_TUNNEL_DST,
+	FLOW_KEY_TUNNEL_PROTO,
+	FLOW_KEY_TUNNEL_PROTO_SRC,
+	FLOW_KEY_TUNNEL_PROTO_DST,
 	__FLOW_KEY_MAX,
 };
=20
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 6994214..f0bd3ad 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -311,6 +311,301 @@ static u32 flow_get_rxhash(struct sk_buff *skb)
 	return skb_get_rxhash(skb);
 }
=20
+static u32 tunnel_inner_ip_src(struct sk_buff *skb)
+{
+	if (pskb_network_may_pull(skb, skb_network_header_len(skb) +
+							sizeof(struct iphdr))) {
+		return ntohl(ipip_hdr(skb)->saddr);
+	}
+
+	return 0;
+}
+
+static u32 tunnel_inner_ipv6_src(struct sk_buff *skb)
+{
+	if (pskb_network_may_pull(skb, skb_network_header_len(skb) +
+						sizeof(struct ipv6hdr))) {
+		struct ipv6hdr *iph =3D (struct ipv6hdr *)
+					skb_transport_header(skb);
+		return ntohl(iph->saddr.s6_addr32[3]);
+	}
+
+	return 0;
+}
+
+static u32 flow_get_tunnel_src(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		if (pskb_network_may_pull(skb, sizeof(struct iphdr))) {
+			if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_src(skb);
+			} else if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_src(skb);
+			}
+		}
+		break;
+	case htons(ETH_P_IPV6):
+		if (pskb_network_may_pull(skb, sizeof(struct ipv6hdr))) {
+			if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_src(skb);
+			} else if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_src(skb);
+			}
+		}
+		break;
+	}
+
+	return 0;
+}
+
+static u32 tunnel_inner_ip_dst(struct sk_buff *skb)
+{
+	if (pskb_network_may_pull(skb, skb_network_header_len(skb) +
+							sizeof(struct iphdr))) {
+		return ntohl(ipip_hdr(skb)->daddr);
+	}
+
+	return 0;
+}
+
+static u32 tunnel_inner_ipv6_dst(struct sk_buff *skb)
+{
+	if (pskb_network_may_pull(skb, skb_network_header_len(skb) +
+						sizeof(struct ipv6hdr))) {
+		struct ipv6hdr *iph =3D (struct ipv6hdr *)
+					skb_transport_header(skb);
+		return ntohl(iph->daddr.s6_addr32[3]);
+	}
+
+	return 0;
+}
+
+static u32 flow_get_tunnel_dst(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		if (pskb_network_may_pull(skb, sizeof(struct iphdr))) {
+			if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_dst(skb);
+			} else if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_dst(skb);
+			}
+		}
+		break;
+	case htons(ETH_P_IPV6):
+		if (pskb_network_may_pull(skb, sizeof(struct ipv6hdr))) {
+			if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_dst(skb);
+			} else if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_dst(skb);
+			}
+		}
+		break;
+	}
+
+	return 0;
+}
+
+static u32 tunnel_inner_ip_proto(struct sk_buff *skb)
+{
+	struct iphdr *iph;
+
+	if (!pskb_network_may_pull(skb, skb_network_header_len(skb) +
+							sizeof(struct iphdr))) {
+		return 0;
+	}
+
+	iph =3D ipip_hdr(skb);
+
+	return iph->protocol;
+}
+
+static u32 tunnel_inner_ipv6_proto(struct sk_buff *skb)
+{
+	struct ipv6hdr *ipv6h;
+
+	if (!pskb_network_may_pull(skb, skb_network_header_len(skb) +
+						sizeof(struct ipv6hdr))) {
+		return 0;
+	}
+
+	ipv6h =3D (struct ipv6hdr *)skb_transport_header(skb);
+
+	return ipv6h->nexthdr;
+}
+
+static u32 flow_get_tunnel_proto(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		if (pskb_network_may_pull(skb, sizeof(struct iphdr))) {
+			if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_proto(skb);
+			} else if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_proto(skb);
+			}
+		}
+		break;
+	case htons(ETH_P_IPV6):
+		if (pskb_network_may_pull(skb, sizeof(struct ipv6hdr))) {
+			if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_proto(skb);
+			} else if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_proto(skb);
+			}
+		}
+		break;
+	}
+
+	return 0;
+}
+
+static u32 tunnel_inner_ip_proto_src(struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	int poff;
+
+	if (!pskb_network_may_pull(skb, skb_network_header_len(skb) +
+							sizeof(struct iphdr))) {
+		return 0;
+	}
+
+	iph =3D ipip_hdr(skb);
+
+	if (ip_is_fragment(iph))
+		return 0;
+
+	poff =3D proto_ports_offset(iph->protocol);
+	if (poff >=3D 0 && pskb_network_may_pull(skb, skb_network_header_len(skb)
+						+ iph->ihl * 4 + 2 + poff)) {
+		return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 + poff));
+	}
+
+	return 0;
+}
+
+static u32 tunnel_inner_ipv6_proto_src(struct sk_buff *skb)
+{
+	struct ipv6hdr *ipv6h;
+	int poff;
+
+	if (!pskb_network_may_pull(skb, skb_network_header_len(skb) +
+						sizeof(struct ipv6hdr))) {
+		return 0;
+	}
+
+	ipv6h =3D (struct ipv6hdr *)skb_transport_header(skb);
+
+	poff =3D proto_ports_offset(ipv6h->nexthdr);
+	if (poff >=3D 0 &&
+		    pskb_network_may_pull(skb, sizeof(*ipv6h) + poff + 2)) {
+		return ntohs(*(__be16 *)((void *)ipv6h + sizeof(*ipv6h) +
+						 			poff));
+	}
+
+	return 0;
+}
+
+static u32 flow_get_tunnel_proto_src(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		if (pskb_network_may_pull(skb, sizeof(struct iphdr))) {
+			if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_proto_src(skb);
+			} else if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_proto_src(skb);
+			}
+			return 0;
+		}
+		break;
+	case htons(ETH_P_IPV6):
+		if (pskb_network_may_pull(skb, sizeof(struct ipv6hdr))) {
+			if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_proto_src(skb);
+			} else if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_proto_src(skb);
+			}
+		}
+		break;
+	}
+
+	return 0;
+}
+
+static u32 tunnel_inner_ip_proto_dst(struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	int poff;
+
+	if (!pskb_network_may_pull(skb, skb_network_header_len(skb) +
+							sizeof(struct iphdr))) {
+		return 0;
+	}
+
+	iph =3D ipip_hdr(skb);
+
+	if (ip_is_fragment(iph))
+		return 0;
+
+	poff =3D proto_ports_offset(iph->protocol);
+	if (poff >=3D 0 && pskb_network_may_pull(skb, skb_network_header_len(skb)
+						+ iph->ihl * 4 + 4 + poff)) {
+		return ntohs(*(__be16 *)((void *)iph + iph->ihl * 4 + 2 + poff));
+	}
+
+	return 0;
+}
+
+static u32 tunnel_inner_ipv6_proto_dst(struct sk_buff *skb)
+{
+	struct ipv6hdr *ipv6h;
+	int poff;
+
+	if (!pskb_network_may_pull(skb, skb_network_header_len(skb) +
+						sizeof(struct ipv6hdr))) {
+		return 0;
+	}
+
+	ipv6h =3D (struct ipv6hdr *)skb_transport_header(skb);
+
+	poff =3D proto_ports_offset(ipv6h->nexthdr);
+	if (poff >=3D 0 &&
+		    pskb_network_may_pull(skb, sizeof(*ipv6h) + poff + 4)) {
+		return ntohs(*(__be16 *)((void *)ipv6h + sizeof(*ipv6h) +
+						 		poff + 2));
+	}
+
+	return 0;
+}
+
+static u32 flow_get_tunnel_proto_dst(struct sk_buff *skb)
+{
+	switch (skb->protocol) {
+	case htons(ETH_P_IP):
+		if (pskb_network_may_pull(skb, sizeof(struct iphdr))) {
+			if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_proto_dst(skb);
+			} else if (ip_hdr(skb)->protocol =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_proto_dst(skb);
+			}
+		}
+		break;
+	case htons(ETH_P_IPV6):
+		if (pskb_network_may_pull(skb, sizeof(struct ipv6hdr))) {
+			if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPIP) {
+				return tunnel_inner_ip_proto_dst(skb);
+			} else if (ipv6_hdr(skb)->nexthdr =3D=3D IPPROTO_IPV6) {
+				return tunnel_inner_ipv6_proto_dst(skb);
+			}
+		}
+		break;
+	}
+
+	return 0;
+}
+
 static u32 flow_key_get(struct sk_buff *skb, int key)
 {
 	switch (key) {
@@ -350,6 +645,16 @@ static u32 flow_key_get(struct sk_buff *skb, int key)
 		return flow_get_vlan_tag(skb);
 	case FLOW_KEY_RXHASH:
 		return flow_get_rxhash(skb);
+	case FLOW_KEY_TUNNEL_SRC:
+		return flow_get_tunnel_src(skb);
+	case FLOW_KEY_TUNNEL_DST:
+		return flow_get_tunnel_dst(skb);
+	case FLOW_KEY_TUNNEL_PROTO:
+		return flow_get_tunnel_proto(skb);
+	case FLOW_KEY_TUNNEL_PROTO_SRC:
+		return flow_get_tunnel_proto_src(skb);
+	case FLOW_KEY_TUNNEL_PROTO_DST:
+		return flow_get_tunnel_proto_dst(skb);
 	default:
 		WARN_ON(1);
 		return 0;


--=-+TrWPHoibEreUowuqhDW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCAAGBQJOm2NkAAoJEJKXGLoTP2w+SHAP/jXxFjE93cUMsAfMCfFObXCC
f+fiW8QSNgBkdywgA7m5L6OL2MTx9OdcORDCCxvt4EZAYpj2h3ME6PV66BT/Hgtq
n5/bSBiPp8bMSkeY9zu7mPeVmSNRUnw9O3l9inDdCJWrrfFbsmpi90hl49iGTl+P
9uvb3RIc1g28iSud0LV1uUuloF4JByga8FWcWCaDkC9RWg2u7pgDftWiFtIB7sW5
PyaWxv4mQ2OmrNub2AjwFtMKxcmncvSzkjwh5ZDhyUCh8DpDzhGraL8YDOXDdL3L
jyFBo5oXanVF7zdAOQNjn/TFdg/JMdBJbTlGqwdPjY7pW7+/QSTqMVSGPdDP99tv
u6TqxyCxR/UjcrxcdpK90NcSI9FWp+NVpJVh6aB5iNLW9kANudqGUF67AU+QMqra
Bbqb5yjEYVllc6FlkLamBkC0XlwGm8IqcU/ox29cldKC1RKvE5kO29C1JnyIlXCm
2FKa0q1nT1dnoHaVxVzsz6X9sSuWsbeZuCUK0yBm/ujCuEP4fCr9N1979U0U90Go
wsiAgE2ZGWLbDTiSBoTT7T//JFBHSI7sUjXSNyy7c3/ovQF2rdS13cMaATAwKQ7/
xNKW2LSUH5huUkHsgnnS2SApVrfgSs0Q02I4uSl3+/tJe24xKNO8LB/q74k7s7EH
L6bgEr6es5pESCb/7UdI
=g6MG
-----END PGP SIGNATURE-----

--=-+TrWPHoibEreUowuqhDW--
