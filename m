From: pablo@netfilter.org
Subject: [PATCH 5/5] netfilter: ip6t_NPT: Ensure to check lower part of prefixes are zero
Date: Sat,  9 Feb 2013 13:04:00 +0100
Message-ID: <1360411440-6526-6-git-send-email-pablo@netfilter.org>
References: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1360411440-6526-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <yoshf=
uji@linux-ipv6.org>

RFC 6296 points that address bits that are not part of the prefix
has to be zeroed.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_NPT.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/ipv6/netfilter/ip6t_NPT.c b/net/ipv6/netfilter/ip6t_NP=
T.c
index 87b759c..83acc14 100644
--- a/net/ipv6/netfilter/ip6t_NPT.c
+++ b/net/ipv6/netfilter/ip6t_NPT.c
@@ -9,6 +9,7 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/ipv6.h>
+#include <net/ipv6.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter_ipv6/ip6t_NPT.h>
@@ -18,11 +19,20 @@ static int ip6t_npt_checkentry(const struct xt_tgch=
k_param *par)
 {
 	struct ip6t_npt_tginfo *npt =3D par->targinfo;
 	__wsum src_sum =3D 0, dst_sum =3D 0;
+	struct in6_addr pfx;
 	unsigned int i;
=20
 	if (npt->src_pfx_len > 64 || npt->dst_pfx_len > 64)
 		return -EINVAL;
=20
+	/* Ensure that LSB of prefix is zero */
+	ipv6_addr_prefix(&pfx, &npt->src_pfx.in6, npt->src_pfx_len);
+	if (!ipv6_addr_equal(&pfx, &npt->src_pfx.in6))
+		return -EINVAL;
+	ipv6_addr_prefix(&pfx, &npt->dst_pfx.in6, npt->dst_pfx_len);
+	if (!ipv6_addr_equal(&pfx, &npt->dst_pfx.in6))
+		return -EINVAL;
+
 	for (i =3D 0; i < ARRAY_SIZE(npt->src_pfx.in6.s6_addr16); i++) {
 		src_sum =3D csum_add(src_sum,
 				(__force __wsum)npt->src_pfx.in6.s6_addr16[i]);
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
