From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/4] [NETFILTER]: Kill some supper dupper bloatry
Date: Sat,  5 Jan 2008 15:39:05 +0200
Message-ID: <11995403481730-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53608 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754264AbYAENjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 08:39:11 -0500
In-Reply-To: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

/me awards the bloatiest-of-all-net/-.c-code award to
nf_conntrack_netlink.c, congratulations to all the authors :-/!

Hall of (unquestionable) fame (measured per inline, top 10 under
net/):
  -4496 ctnetlink_parse_tuple        netfilter/nf_conntrack_netlink.c
  -2165 ctnetlink_dump_tuples        netfilter/nf_conntrack_netlink.c
  -2115 __ip_vs_get_out_rt           ipv4/ipvs/ip_vs_xmit.c
  -1924 xfrm_audit_helper_pktinfo    xfrm/xfrm_state.c
  -1799 ctnetlink_parse_tuple_proto  netfilter/nf_conntrack_netlink.c
  -1268 ctnetlink_parse_tuple_ip     netfilter/nf_conntrack_netlink.c
  -1093 ctnetlink_exp_dump_expect    netfilter/nf_conntrack_netlink.c
  -1060 void ccid3_update_send_interval  dccp/ccids/ccid3.c
  -983  ctnetlink_dump_tuples_proto  netfilter/nf_conntrack_netlink.c
  -827  ctnetlink_exp_dump_tuple     netfilter/nf_conntrack_netlink.c

  (i386 / gcc (GCC) 4.1.2 20070626 (Red Hat 4.1.2-13) /
   allyesconfig except CONFIG_FORCED_INLINING)

=2E..and I left < 200 byte gains as future work item.

After iterative inline removal, I finally have this:

net/netfilter/nf_conntrack_netlink.c:
  ctnetlink_exp_fill_info   | -1104
  ctnetlink_new_expect      | -1572
  ctnetlink_fill_info       | -1303
  ctnetlink_new_conntrack   | -2230
  ctnetlink_get_expect      | -341
  ctnetlink_del_expect      | -352
  ctnetlink_expect_event    | -1110
  ctnetlink_conntrack_event | -1548
  ctnetlink_del_conntrack   | -729
  ctnetlink_get_conntrack   | -728
 10 functions changed, 11017 bytes removed, diff: -11017

net/netfilter/nf_conntrack_netlink.c:
  ctnetlink_parse_tuple     | +419
  dump_nat_seq_adj          | +183
  ctnetlink_dump_counters   | +166
  ctnetlink_dump_tuples     | +261
  ctnetlink_exp_dump_expect | +633
  ctnetlink_change_status   | +460
 6 functions changed, 2122 bytes added, diff: +2122

net/netfilter/nf_conntrack_netlink.o:
 16 functions changed, 2122 bytes added, 11017 bytes removed, diff: -88=
95

Without a number of CONFIG.*DEBUGs, I got this:
net/netfilter/nf_conntrack_netlink.o:
 16 functions changed, 2122 bytes added, 11029 bytes removed, diff: -89=
07

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/netfilter/nf_conntrack_netlink.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_co=
nntrack_netlink.c
index d93d58d..38141f1 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -95,7 +95,7 @@ nla_put_failure:
 	return -1;
 }
=20
-static inline int
+static int
 ctnetlink_dump_tuples(struct sk_buff *skb,
 		      const struct nf_conntrack_tuple *tuple)
 {
@@ -205,7 +205,7 @@ nla_put_failure:
 }
=20
 #ifdef CONFIG_NF_CT_ACCT
-static inline int
+static int
 ctnetlink_dump_counters(struct sk_buff *skb, const struct nf_conn *ct,
 			enum ip_conntrack_dir dir)
 {
@@ -284,7 +284,7 @@ nla_put_failure:
 }
=20
 #ifdef CONFIG_NF_NAT_NEEDED
-static inline int
+static int
 dump_nat_seq_adj(struct sk_buff *skb, const struct nf_nat_seq *natseq,=
 int type)
 {
 	struct nlattr *nest_parms;
@@ -648,7 +648,7 @@ ctnetlink_parse_tuple_proto(struct nlattr *attr,
 	return ret;
 }
=20
-static inline int
+static int
 ctnetlink_parse_tuple(struct nlattr *cda[], struct nf_conntrack_tuple =
*tuple,
 		      enum ctattr_tuple type, u_int8_t l3num)
 {
@@ -888,7 +888,7 @@ out:
 	return err;
 }
=20
-static inline int
+static int
 ctnetlink_change_status(struct nf_conn *ct, struct nlattr *cda[])
 {
 	unsigned long d;
@@ -1349,7 +1349,7 @@ nla_put_failure:
 	return -1;
 }
=20
-static inline int
+static int
 ctnetlink_exp_dump_expect(struct sk_buff *skb,
 			  const struct nf_conntrack_expect *exp)
 {
--=20
1.5.0.6

