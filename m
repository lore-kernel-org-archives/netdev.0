From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/34] netfilter: fix compilation of masquerading without IP_NF_TARGET_MASQUERADE
Date: Mon, 29 Sep 2014 14:38:50 +0200
Message-ID: <1411994363-8451-2-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33996 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752856AbaI2MiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 08:38:19 -0400
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 CONFIG_NF_NAT_MASQUERADE_IPV6=3Dm
 # CONFIG_IP6_NF_TARGET_MASQUERADE is not set

results in:

net/ipv6/netfilter/nf_nat_masquerade_ipv6.c: In function =E2=80=98nf_na=
t_masquerade_ipv6=E2=80=99:
net/ipv6/netfilter/nf_nat_masquerade_ipv6.c:41:14: error: =E2=80=98stru=
ct nf_conn_nat=E2=80=99 has no member named =E2=80=98masq_index=E2=80=99
  nfct_nat(ct)->masq_index =3D out->ifindex;
              ^
net/ipv6/netfilter/nf_nat_masquerade_ipv6.c: In function =E2=80=98devic=
e_cmp=E2=80=99:
net/ipv6/netfilter/nf_nat_masquerade_ipv6.c:61:12: error: =E2=80=98cons=
t struct nf_conn_nat=E2=80=99 has no member named =E2=80=98masq_index=E2=
=80=99
  return nat->masq_index =3D=3D (int)(long)ifindex;
            ^
net/ipv6/netfilter/nf_nat_masquerade_ipv6.c:62:1: warning: control
reaches end of non-void function [-Wreturn-type]
 }
 ^
make[3]: *** [net/ipv6/netfilter/nf_nat_masquerade_ipv6.o] Error 1

=46ix this by using the new NF_NAT_MASQUERADE_IPV4 and _IPV6 symbols
in include/net/netfilter/nf_nat.h.

Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat.h |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_=
nat.h
index a71dd33..344b1ab 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -32,10 +32,8 @@ struct nf_conn_nat {
 	struct hlist_node bysource;
 	struct nf_conn *ct;
 	union nf_conntrack_nat_help help;
-#if defined(CONFIG_IP_NF_TARGET_MASQUERADE) || \
-    defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE) || \
-    defined(CONFIG_IP6_NF_TARGET_MASQUERADE) || \
-    defined(CONFIG_IP6_NF_TARGET_MASQUERADE_MODULE)
+#if IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV4) || \
+    IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV6)
 	int masq_index;
 #endif
 };
@@ -68,8 +66,8 @@ static inline bool nf_nat_oif_changed(unsigned int ho=
oknum,
 				      struct nf_conn_nat *nat,
 				      const struct net_device *out)
 {
-#if IS_ENABLED(CONFIG_IP_NF_TARGET_MASQUERADE) || \
-    IS_ENABLED(CONFIG_IP6_NF_TARGET_MASQUERADE)
+#if IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV4) || \
+    IS_ENABLED(CONFIG_NF_NAT_MASQUERADE_IPV6)
 	return nat->masq_index && hooknum =3D=3D NF_INET_POST_ROUTING &&
 	       CTINFO2DIR(ctinfo) =3D=3D IP_CT_DIR_ORIGINAL &&
 	       nat->masq_index !=3D out->ifindex;
--=20
1.7.10.4
