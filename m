From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH v2 net 2/2] drivers/net,ipv6: Select IPv6 fragment idents
 for virtio UFO packets
Date: Thu, 30 Oct 2014 18:27:17 +0000
Message-ID: <1414693637.16849.63.camel@decadent.org.uk>
References: <1414693592.16849.61.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RGXZN8kn9ZFjZyyhFx2w"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47698 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758954AbaJ3S1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 14:27:24 -0400
In-Reply-To: <1414693592.16849.61.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RGXZN8kn9ZFjZyyhFx2w
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
index 280d3d2..7302398 100644
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
@@ -1159,6 +1162,8 @@ static ssize_t tun_get_user(struct tun_struct *tun, s=
truct tun_file *tfile,
 					    current->comm);
 			}
 			skb_shinfo(skb)->gso_type =3D SKB_GSO_UDP;
+			if (skb->protocol =3D=3D htons(ETH_P_IPV6))
+				ipv6_proxy_select_ident(skb);
 			break;
 		}
 		default:
@@ -1189,7 +1194,6 @@ static ssize_t tun_get_user(struct tun_struct *tun, s=
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
The program is absolutely right; therefore, the computer must be wrong.

--=-RGXZN8kn9ZFjZyyhFx2w
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVFKDBee/yOyVhhEJAQpJsw/9EiBB8plfodpbgDBrB3AmI0s3W2IoO5MP
nvaXMA+ORoKNDHcP3dRWGgr1maIFwM5XaDv2m5ShHzPGuYRuEo0MwZBxddDRRwYn
JH4yI6A+ZgXULiLRf82EmOdBSxN6P7KhNoliEXnyJNKvPSSUI/La3kbeo+3fZ3DC
wxwmkbgW+nqCC5WuktikJoEsiLMwJr8A7i0v7IRl/asChSsbWdjjEvl/3mz5IpOs
6GxdIKaJhhlyAGLlDgHBnsYmFkE1v4DJIArP70lQosArNoQ+T5U7tLlKsmEG8LX/
VJ1rsDk4wQ791h44gkk2YCgjy00Q7arSSvV5zW/u5tWEuC+teJDl4NgJFWALw1aj
B6uNTAK8uadqa7o0YXjoJVjJ+U7aCFfjSfJbmGvXXBYVHIrEMdk4Cifm9BNOnz/4
PO3nWrBWpoAlYIc9iafAjRiy12ucZYiVSGSVDcOt0PYgik5nA/ZBjvHmEt8m2QJl
LIw9lcRbf24vAT5eO7ygyLUnmiTxKEWw71+W/OrITEmcqp0vfVGFlrKe/zHX1gbs
uKpazzIryeE3nOqIvjG/cmtV0rSgKLLjMMd2nh+AArlAlK7wBZU0V56HFuAYwNUW
/O3cIlzsG9Ix3mipXtXTtToUkOg9TiWfy/3yf7qnFlnZlGUGpqaR3I2//59uSlZr
vGKJKxBycOc=
=G2Np
-----END PGP SIGNATURE-----

--=-RGXZN8kn9ZFjZyyhFx2w--
