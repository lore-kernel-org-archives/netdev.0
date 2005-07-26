From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] rename skb_ip_make_writable() to skb_make_writable()
Date: Tue, 26 Jul 2005 17:20:53 +0200
Message-ID: <20050726152053.GA4279@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZfOjI3PrQbgiZnxM"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--ZfOjI3PrQbgiZnxM
Content-Type: multipart/mixed; boundary="EeQfGwPcQSOJBaQU"
Content-Disposition: inline


--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

please apply to your net-2.6.14 tree:

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--EeQfGwPcQSOJBaQU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="10-skb_make_writable.patch"
Content-Transfer-Encoding: quoted-printable

Rename skb_ip_make_writable() to skb_make_writable() since there is
nothing IPv4-specific in it.  In fact, it was already used by IPv6, too...
Upcoming nfnetlink_queue code will use it for any kind of packet.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit ebf2b990ed34e768fc009057091c94b52e8aa886
tree 8302388bb8eabea3fcd375ec0234bb958818cdf2
parent 9bb3d9ecf709bb46b7f69a59b070c8365094a9be
author laforge <laforge@netfilter.org> Di, 26 Jul 2005 17:18:56 +0200
committer laforge <laforge@netfilter.org> Di, 26 Jul 2005 17:18:56 +0200

 include/linux/netfilter.h              |    5 +++++
 include/linux/netfilter_ipv4.h         |    5 -----
 net/core/netfilter.c                   |    6 +++---
 net/ipv4/netfilter/ip_nat_core.c       |    4 ++--
 net/ipv4/netfilter/ip_nat_helper.c     |    8 ++++----
 net/ipv4/netfilter/ip_nat_proto_icmp.c |    2 +-
 net/ipv4/netfilter/ip_nat_proto_tcp.c  |    2 +-
 net/ipv4/netfilter/ip_nat_proto_udp.c  |    2 +-
 net/ipv4/netfilter/ip_nat_snmp_basic.c |    2 +-
 net/ipv4/netfilter/ip_queue.c          |    2 +-
 net/ipv4/netfilter/ipt_DSCP.c          |    2 +-
 net/ipv4/netfilter/ipt_ECN.c           |    4 ++--
 net/ipv4/netfilter/ipt_TCPMSS.c        |    2 +-
 net/ipv4/netfilter/ipt_TOS.c           |    2 +-
 net/ipv6/netfilter/ip6_queue.c         |    2 +-
 15 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -193,6 +193,11 @@ extern void nf_ct_attach(struct sk_buff=20
 /* FIXME: Before cache is ever used, this must be implemented for real. */
 extern void nf_invalidate_cache(int pf);
=20
+/* Call this before modifying an existing packet: ensures it is
+   modifiable and linear to the point you care about (writable_len).
+   Returns true or false. */
+extern int skb_make_writable(struct sk_buff **pskb, unsigned int writable_=
len);
+
 #else /* !CONFIG_NETFILTER */
 #define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) =
{}
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -80,11 +80,6 @@ enum nf_ip_hook_priorities {
 #ifdef __KERNEL__
 extern int ip_route_me_harder(struct sk_buff **pskb);
=20
-/* Call this before modifying an existing IP packet: ensures it is
-   modifiable and linear to the point you care about (writable_len).
-   Returns true or false. */
-extern int skb_ip_make_writable(struct sk_buff **pskb,
-				unsigned int writable_len);
 #endif /*__KERNEL__*/
=20
 #endif /*__LINUX_IP_NETFILTER_H*/
diff --git a/net/core/netfilter.c b/net/core/netfilter.c
--- a/net/core/netfilter.c
+++ b/net/core/netfilter.c
@@ -512,8 +512,9 @@ int ip_route_me_harder(struct sk_buff **
 	return 0;
 }
 EXPORT_SYMBOL(ip_route_me_harder);
+#endif /*CONFIG_INET*/
=20
-int skb_ip_make_writable(struct sk_buff **pskb, unsigned int writable_len)
+int skb_make_writable(struct sk_buff **pskb, unsigned int writable_len)
 {
 	struct sk_buff *nskb;
=20
@@ -540,8 +541,7 @@ copy_skb:
 	*pskb =3D nskb;
 	return 1;
 }
-EXPORT_SYMBOL(skb_ip_make_writable);
-#endif /*CONFIG_INET*/
+EXPORT_SYMBOL(skb_make_writable);
=20
 /* Internal logging interface, which relies on the real=20
    LOG target modules */
diff --git a/net/ipv4/netfilter/ip_nat_core.c b/net/ipv4/netfilter/ip_nat_c=
ore.c
--- a/net/ipv4/netfilter/ip_nat_core.c
+++ b/net/ipv4/netfilter/ip_nat_core.c
@@ -359,7 +359,7 @@ manip_pkt(u_int16_t proto,
 	struct iphdr *iph;
 	struct ip_nat_protocol *p;
=20
-	if (!skb_ip_make_writable(pskb, iphdroff + sizeof(*iph)))
+	if (!skb_make_writable(pskb, iphdroff + sizeof(*iph)))
 		return 0;
=20
 	iph =3D (void *)(*pskb)->data + iphdroff;
@@ -431,7 +431,7 @@ int icmp_reply_translation(struct sk_buf
 	struct ip_conntrack_tuple inner, target;
 	int hdrlen =3D (*pskb)->nh.iph->ihl * 4;
=20
-	if (!skb_ip_make_writable(pskb, hdrlen + sizeof(*inside)))
+	if (!skb_make_writable(pskb, hdrlen + sizeof(*inside)))
 		return 0;
=20
 	inside =3D (void *)(*pskb)->data + (*pskb)->nh.iph->ihl*4;
diff --git a/net/ipv4/netfilter/ip_nat_helper.c b/net/ipv4/netfilter/ip_nat=
_helper.c
--- a/net/ipv4/netfilter/ip_nat_helper.c
+++ b/net/ipv4/netfilter/ip_nat_helper.c
@@ -168,7 +168,7 @@ ip_nat_mangle_tcp_packet(struct sk_buff=20
 	struct tcphdr *tcph;
 	int datalen;
=20
-	if (!skb_ip_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(pskb, (*pskb)->len))
 		return 0;
=20
 	if (rep_len > match_len
@@ -228,7 +228,7 @@ ip_nat_mangle_udp_packet(struct sk_buff=20
 	                       match_offset + match_len)
 		return 0;
=20
-	if (!skb_ip_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(pskb, (*pskb)->len))
 		return 0;
=20
 	if (rep_len > match_len
@@ -315,7 +315,7 @@ ip_nat_sack_adjust(struct sk_buff **pskb
 	optoff =3D (*pskb)->nh.iph->ihl*4 + sizeof(struct tcphdr);
 	optend =3D (*pskb)->nh.iph->ihl*4 + tcph->doff*4;
=20
-	if (!skb_ip_make_writable(pskb, optend))
+	if (!skb_make_writable(pskb, optend))
 		return 0;
=20
 	dir =3D CTINFO2DIR(ctinfo);
@@ -363,7 +363,7 @@ ip_nat_seq_adjust(struct sk_buff **pskb,
 	this_way =3D &ct->nat.info.seq[dir];
 	other_way =3D &ct->nat.info.seq[!dir];
=20
-	if (!skb_ip_make_writable(pskb, (*pskb)->nh.iph->ihl*4+sizeof(*tcph)))
+	if (!skb_make_writable(pskb, (*pskb)->nh.iph->ihl*4+sizeof(*tcph)))
 		return 0;
=20
 	tcph =3D (void *)(*pskb)->data + (*pskb)->nh.iph->ihl*4;
diff --git a/net/ipv4/netfilter/ip_nat_proto_icmp.c b/net/ipv4/netfilter/ip=
_nat_proto_icmp.c
--- a/net/ipv4/netfilter/ip_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_icmp.c
@@ -62,7 +62,7 @@ icmp_manip_pkt(struct sk_buff **pskb,
 	struct icmphdr *hdr;
 	unsigned int hdroff =3D iphdroff + iph->ihl*4;
=20
-	if (!skb_ip_make_writable(pskb, hdroff + sizeof(*hdr)))
+	if (!skb_make_writable(pskb, hdroff + sizeof(*hdr)))
 		return 0;
=20
 	hdr =3D (struct icmphdr *)((*pskb)->data + hdroff);
diff --git a/net/ipv4/netfilter/ip_nat_proto_tcp.c b/net/ipv4/netfilter/ip_=
nat_proto_tcp.c
--- a/net/ipv4/netfilter/ip_nat_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_tcp.c
@@ -103,7 +103,7 @@ tcp_manip_pkt(struct sk_buff **pskb,
 	if ((*pskb)->len >=3D hdroff + sizeof(struct tcphdr))
 		hdrsize =3D sizeof(struct tcphdr);
=20
-	if (!skb_ip_make_writable(pskb, hdroff + hdrsize))
+	if (!skb_make_writable(pskb, hdroff + hdrsize))
 		return 0;
=20
 	iph =3D (struct iphdr *)((*pskb)->data + iphdroff);
diff --git a/net/ipv4/netfilter/ip_nat_proto_udp.c b/net/ipv4/netfilter/ip_=
nat_proto_udp.c
--- a/net/ipv4/netfilter/ip_nat_proto_udp.c
+++ b/net/ipv4/netfilter/ip_nat_proto_udp.c
@@ -94,7 +94,7 @@ udp_manip_pkt(struct sk_buff **pskb,
 	u32 oldip, newip;
 	u16 *portptr, newport;
=20
-	if (!skb_ip_make_writable(pskb, hdroff + sizeof(*hdr)))
+	if (!skb_make_writable(pskb, hdroff + sizeof(*hdr)))
 		return 0;
=20
 	iph =3D (struct iphdr *)((*pskb)->data + iphdroff);
diff --git a/net/ipv4/netfilter/ip_nat_snmp_basic.c b/net/ipv4/netfilter/ip=
_nat_snmp_basic.c
--- a/net/ipv4/netfilter/ip_nat_snmp_basic.c
+++ b/net/ipv4/netfilter/ip_nat_snmp_basic.c
@@ -1275,7 +1275,7 @@ static int help(struct sk_buff **pskb,
 		 return NF_DROP;
 	}
=20
-	if (!skb_ip_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(pskb, (*pskb)->len))
 		return NF_DROP;
=20
 	spin_lock_bh(&snmp_lock);
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -382,7 +382,7 @@ ipq_mangle_ipv4(ipq_verdict_msg_t *v, st
 		}
 		skb_put(e->skb, diff);
 	}
-	if (!skb_ip_make_writable(&e->skb, v->data_len))
+	if (!skb_make_writable(&e->skb, v->data_len))
 		return -ENOMEM;
 	memcpy(e->skb->data, v->payload, v->data_len);
=20
diff --git a/net/ipv4/netfilter/ipt_DSCP.c b/net/ipv4/netfilter/ipt_DSCP.c
--- a/net/ipv4/netfilter/ipt_DSCP.c
+++ b/net/ipv4/netfilter/ipt_DSCP.c
@@ -39,7 +39,7 @@ target(struct sk_buff **pskb,
 	if (((*pskb)->nh.iph->tos & IPT_DSCP_MASK) !=3D sh_dscp) {
 		u_int16_t diffs[2];
=20
-		if (!skb_ip_make_writable(pskb, sizeof(struct iphdr)))
+		if (!skb_make_writable(pskb, sizeof(struct iphdr)))
 			return NF_DROP;
=20
 		diffs[0] =3D htons((*pskb)->nh.iph->tos) ^ 0xFFFF;
diff --git a/net/ipv4/netfilter/ipt_ECN.c b/net/ipv4/netfilter/ipt_ECN.c
--- a/net/ipv4/netfilter/ipt_ECN.c
+++ b/net/ipv4/netfilter/ipt_ECN.c
@@ -31,7 +31,7 @@ set_ect_ip(struct sk_buff **pskb, const=20
 	    !=3D (einfo->ip_ect & IPT_ECN_IP_MASK)) {
 		u_int16_t diffs[2];
=20
-		if (!skb_ip_make_writable(pskb, sizeof(struct iphdr)))
+		if (!skb_make_writable(pskb, sizeof(struct iphdr)))
 			return 0;
=20
 		diffs[0] =3D htons((*pskb)->nh.iph->tos) ^ 0xFFFF;
@@ -66,7 +66,7 @@ set_ect_tcp(struct sk_buff **pskb, const
 		  || tcph->cwr =3D=3D einfo->proto.tcp.cwr)))
 		return 1;
=20
-	if (!skb_ip_make_writable(pskb, (*pskb)->nh.iph->ihl*4+sizeof(*tcph)))
+	if (!skb_make_writable(pskb, (*pskb)->nh.iph->ihl*4+sizeof(*tcph)))
 		return 0;
 	tcph =3D (void *)(*pskb)->nh.iph + (*pskb)->nh.iph->ihl*4;
=20
diff --git a/net/ipv4/netfilter/ipt_TCPMSS.c b/net/ipv4/netfilter/ipt_TCPMS=
S.c
--- a/net/ipv4/netfilter/ipt_TCPMSS.c
+++ b/net/ipv4/netfilter/ipt_TCPMSS.c
@@ -58,7 +58,7 @@ ipt_tcpmss_target(struct sk_buff **pskb,
 	unsigned int i;
 	u_int8_t *opt;
=20
-	if (!skb_ip_make_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(pskb, (*pskb)->len))
 		return NF_DROP;
=20
 	iph =3D (*pskb)->nh.iph;
diff --git a/net/ipv4/netfilter/ipt_TOS.c b/net/ipv4/netfilter/ipt_TOS.c
--- a/net/ipv4/netfilter/ipt_TOS.c
+++ b/net/ipv4/netfilter/ipt_TOS.c
@@ -33,7 +33,7 @@ target(struct sk_buff **pskb,
 	if (((*pskb)->nh.iph->tos & IPTOS_TOS_MASK) !=3D tosinfo->tos) {
 		u_int16_t diffs[2];
=20
-		if (!skb_ip_make_writable(pskb, sizeof(struct iphdr)))
+		if (!skb_make_writable(pskb, sizeof(struct iphdr)))
 			return NF_DROP;
=20
 		diffs[0] =3D htons((*pskb)->nh.iph->tos) ^ 0xFFFF;
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -378,7 +378,7 @@ ipq_mangle_ipv6(ipq_verdict_msg_t *v, st
 		}
 		skb_put(e->skb, diff);
 	}
-	if (!skb_ip_make_writable(&e->skb, v->data_len))
+	if (!skb_make_writable(&e->skb, v->data_len))
 		return -ENOMEM;
 	memcpy(e->skb->data, v->payload, v->data_len);
=20

--EeQfGwPcQSOJBaQU--

--ZfOjI3PrQbgiZnxM
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC5lSxXaXGVTD0i/8RAgdsAJ0fNDzfE4ylN0rJWrRfzSzNoDogcgCfVNlN
wSj1T9MIqaDIRbO3Sq3v9TM=
=iLgT
-----END PGP SIGNATURE-----

--ZfOjI3PrQbgiZnxM--
