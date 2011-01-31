From: kaber@trash.net
Subject: [PATCH 5/7] netfilter: xt_connlimit: pick right dstaddr in NAT scenario
Date: Mon, 31 Jan 2011 21:10:18 +0100
Message-ID: <1296504620-820-6-git-send-email-kaber@trash.net>
References: <1296504620-820-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59945 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755973Ab1AaUKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 15:10:35 -0500
In-Reply-To: <1296504620-820-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jan Engelhardt <jengelh@medozas.de>

xt_connlimit normally records the "original" tuples in a hashlist
(such as "1.2.3.4 -> 5.6.7.8"), and looks in this list for iph->daddr
when counting.

When the user however uses DNAT in PREROUTING, looking for
iph->daddr=C2=A0-- which is now 192.168.9.10 -- will not match. Thus in
daddr mode, we need to record the reverse direction tuple
("192.168.9.10 -> 1.2.3.4") instead. In the reverse tuple, the dst
addr is on the src side, which is convenient, as count_them still uses
&conn->tuple.src.u3.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_connlimit.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.=
c
index 7fd3fd5..e029c48 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -185,11 +185,15 @@ connlimit_mt(const struct sk_buff *skb, struct xt=
_action_param *par)
 	int connections;
=20
 	ct =3D nf_ct_get(skb, &ctinfo);
-	if (ct !=3D NULL)
-		tuple_ptr =3D &ct->tuplehash[0].tuple;
-	else if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
-				    par->family, &tuple))
+	if (ct !=3D NULL) {
+		if (info->flags & XT_CONNLIMIT_DADDR)
+			tuple_ptr =3D &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
+		else
+			tuple_ptr =3D &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+	} else if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
+				    par->family, &tuple)) {
 		goto hotdrop;
+	}
=20
 	if (par->family =3D=3D NFPROTO_IPV6) {
 		const struct ipv6hdr *iph =3D ipv6_hdr(skb);
--=20
1.7.2.3

