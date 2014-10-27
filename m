From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 2/2] drivers/net,ipv6: Select IPv6 fragment idents for
	virtio UFO packets
Date: Mon, 27 Oct 2014 04:23:18 +0000
Message-ID: <1414383798.16849.22.camel@decadent.org.uk>
References: <1414383425.16849.18.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3918207973093301389=="
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1414383425.16849.18.camel@decadent.org.uk>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============3918207973093301389==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/LOfkdmNHu/w5cSwi1mR"


--=-/LOfkdmNHu/w5cSwi1mR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

UFO is now disabled on all drivers that work with virtio net headers,
but userland may try to send UFO/IPv6 packets anyway.  Instead of
sending with ID=3D0, we should select identifiers on their behalf (as we
used to).

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
Fixes: 916e4cf46d02 ("ipv6: reuse ip6_frag_id from ip6_ufo_append_data")
---
 drivers/net/macvtap.c  |  3 +++
 drivers/net/tun.c      |  6 +++++-
 include/net/ipv6.h     |  2 ++
 net/ipv6/output_core.c | 34 ++++++++++++++++++++++++++++++++++
 4 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 2aeaa61..6f226de 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -16,6 +16,7 @@
 #include <linux/idr.h>
 #include <linux/fs.h>
=20
+#include <net/ipv6.h>
 #include <net/net_namespace.h>
 #include <net/rtnetlink.h>
 #include <net/sock.h>
@@ -572,6 +573,8 @@ static int macvtap_skb_from_vnet_hdr(struct sk_buff *sk=
b,
 			pr_warn_once("macvtap: %s: using disabled UFO feature; please fix this =
program\n",
 				     current->comm);
 			gso_type =3D SKB_GSO_UDP;
+			if (skb->protocol =3D=3D htons(ETH_P_IPV6))
+				ipv6_proxy_select_ident(skb);
 			break;
 		default:
 			return -EINVAL;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index e8b949a..f8356b0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -65,6 +65,7 @@
 #include <linux/nsproxy.h>
 #include <linux/virtio_net.h>
 #include <linux/rcupdate.h>
+#include <net/ipv6.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
@@ -1139,6 +1140,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, s=
truct tun_file *tfile,
 		break;
 	}
=20
+	skb_reset_network_header(skb);
+
 	if (gso.gso_type !=3D VIRTIO_NET_HDR_GSO_NONE) {
 		pr_debug("GSO!\n");
 		switch (gso.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
@@ -1158,6 +1161,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, s=
truct tun_file *tfile,
 					    current->comm);
 			}
 			skb_shinfo(skb)->gso_type =3D SKB_GSO_UDP;
+			if (skb->protocol =3D=3D htons(ETH_P_IPV6))
+				ipv6_proxy_select_ident(skb);
 			break;
 		}
 		default:
@@ -1188,7 +1193,6 @@ static ssize_t tun_get_user(struct tun_struct *tun, s=
truct tun_file *tfile,
 		skb_shinfo(skb)->tx_flags |=3D SKBTX_SHARED_FRAG;
 	}
=20
-	skb_reset_network_header(skb);
 	skb_probe_transport_header(skb, 0);
=20
 	rxhash =3D skb_get_hash(skb);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 97f4720..4292929 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -671,6 +671,8 @@ static inline int ipv6_addr_diff(const struct in6_addr =
*a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
=20
+void ipv6_proxy_select_ident(struct sk_buff *skb);
+
 int ip6_dst_hoplimit(struct dst_entry *dst);
=20
 static inline int ip6_sk_dst_hoplimit(struct ipv6_pinfo *np, struct flowi6=
 *fl6,
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index fc24c39..97f41a3 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -3,11 +3,45 @@
  * not configured or static.  These functions are needed by GSO/GRO implem=
entation.
  */
 #include <linux/export.h>
+#include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
 #include <net/addrconf.h>
 #include <net/secure_seq.h>
=20
+/* This function exists only for tap drivers that must support broken
+ * clients requesting UFO without specifying an IPv6 fragment ID.
+ *
+ * This is similar to ipv6_select_ident() but we use an independent hash
+ * seed to limit information leakage.
+ *
+ * The network header must be set before calling this.
+ */
+void ipv6_proxy_select_ident(struct sk_buff *skb)
+{
+	static u32 ip6_proxy_idents_hashrnd __read_mostly;
+	struct in6_addr buf[2];
+	struct in6_addr *addrs;
+	u32 hash, id;
+
+	addrs =3D skb_header_pointer(skb,
+				   skb_network_offset(skb) +
+				   offsetof(struct ipv6hdr, saddr),
+				   sizeof(buf), buf);
+	if (!addrs)
+		return;
+
+	net_get_random_once(&ip6_proxy_idents_hashrnd,
+			    sizeof(ip6_proxy_idents_hashrnd));
+
+	hash =3D __ipv6_addr_jhash(&addrs[1], ip6_proxy_idents_hashrnd);
+	hash =3D __ipv6_addr_jhash(&addrs[0], hash);
+
+	id =3D ip_idents_reserve(hash, 1);
+	skb_shinfo(skb)->ip6_frag_id =3D htonl(id);
+}
+EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
+
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 {
 	u16 offset =3D sizeof(struct ipv6hdr);

--=20
Ben Hutchings
Theory and practice are closer in theory than in practice.
                                - John Levine, moderator of comp.compilers

--=-/LOfkdmNHu/w5cSwi1mR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVE3It+e/yOyVhhEJAQre3w//XuSlEsJQ+ZUi3gE8+RjteXhbZobVF6nU
Jr+GxbIv411+y9iTNq5IIRmd3lxFnZ1/zHmsCJc7CnAA1eGIZVUounttt4dRBgIS
RTM8CNuppQbpjmKgpNlb5DKXyLHN8Rv2MhVorznlbOlUUb6kxTaIbmOZLbD/gZXk
A/W2OCy91jr6S+b6WyVbmjbdM4BjMt2eeqhtLGB13Fu9OYs/0zEIYtFSMh5X8Ppu
4K4452rgnvd26Qnc3MoC84LbCYMtdOWNjeDUnbtw8eb6DStjiPMvoET+lKaJAgq1
2RkcedOU+jxfnvm4aAmCNcDImeg9Y2XAD23FMuGzF2vvq/Fwx/pMLF3XNA9Hlsg2
R7w/1iu+XNrDqDcOCD7jgDEUOj8nBXh+S5CaEa+/R19K1IZR6zWI20NCOyvl04nq
USFo9JRefItTyleBf7ORR50Zr6JDtx5VzcJn0V24TPvY469+cCuWNTZLBKnNsHIe
Zd5JVL86lsTNrn0Sexm1qMTLUnXmSQcFKn3rLLd/Ek1gUfobmkKgGet6HxpA/L+f
Xt8n7/XuNRk7s0tzXw+TNucYJjRV74ylzDjcwGWbsxVOpe6eOa6Nvq2XhCgX7SxW
6QP+sYt39ruNhnkkXKqpWHoO4PuQ9CznBshZ5SYyQDOURbvbK2/2naaxPDUjuKvz
PLDQvl0jhKI=
=gk/B
-----END PGP SIGNATURE-----

--=-/LOfkdmNHu/w5cSwi1mR--

--===============3918207973093301389==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============3918207973093301389==--
