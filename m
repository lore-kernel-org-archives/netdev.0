From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] netfilter: add more values to enum
 ip_conntrack_info
Date: Thu, 19 May 2011 15:44:27 +0200
Message-ID: <1305812667.3028.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ollowing error is raised (and other similar ones) :

net/ipv4/netfilter/nf_nat_standalone.c: In function =E2=80=98nf_nat_fn=E2=
=80=99:
net/ipv4/netfilter/nf_nat_standalone.c:119:2: warning: case value =E2=80=
=984=E2=80=99
not in enumerated type =E2=80=98enum ip_conntrack_info=E2=80=99

gcc barfs on adding two enum values and getting a not enumerated
result :

case IP_CT_RELATED+IP_CT_IS_REPLY:

Add missing enum values

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Miller <davem@davemloft.net>
---
 include/linux/netfilter/nf_conntrack_common.h  |    3 +++
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |    6 +++---
 net/ipv4/netfilter/ipt_MASQUERADE.c            |    2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/ipv4/netfilter/nf_nat_core.c               |    2 +-
 net/ipv4/netfilter/nf_nat_rule.c               |    2 +-
 net/ipv4/netfilter/nf_nat_standalone.c         |    4 ++--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    2 +-
 net/netfilter/nf_conntrack_core.c              |    4 ++--
 net/netfilter/nf_conntrack_ftp.c               |    2 +-
 net/netfilter/nf_conntrack_h323_main.c         |   10 ++++------
 net/netfilter/nf_conntrack_irc.c               |    3 +--
 net/netfilter/nf_conntrack_pptp.c              |    3 +--
 net/netfilter/nf_conntrack_sane.c              |    2 +-
 net/netfilter/nf_conntrack_sip.c               |    2 +-
 net/netfilter/xt_socket.c                      |    4 ++--
 16 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/li=
nux/netfilter/nf_conntrack_common.h
index 50cdc25..0d3dd66 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -18,6 +18,9 @@ enum ip_conntrack_info {
 	/* >=3D this indicates reply direction */
 	IP_CT_IS_REPLY,
=20
+	IP_CT_ESTABLISHED_REPLY =3D IP_CT_ESTABLISHED + IP_CT_IS_REPLY,
+	IP_CT_RELATED_REPLY =3D IP_CT_RELATED + IP_CT_IS_REPLY,
+	IP_CT_NEW_REPLY =3D IP_CT_NEW + IP_CT_IS_REPLY,=09
 	/* Number of distinct IP_CT types (no NEW in reply dirn). */
 	IP_CT_NUMBER =3D IP_CT_IS_REPLY * 2 - 1
 };
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ip=
t_CLUSTERIP.c
index d609ac3..5c9e97c 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -307,7 +307,7 @@ clusterip_tg(struct sk_buff *skb, const struct xt_a=
ction_param *par)
 	 * error messages (RELATED) and information requests (see below) */
 	if (ip_hdr(skb)->protocol =3D=3D IPPROTO_ICMP &&
 	    (ctinfo =3D=3D IP_CT_RELATED ||
-	     ctinfo =3D=3D IP_CT_RELATED + IP_CT_IS_REPLY))
+	     ctinfo =3D=3D IP_CT_RELATED_REPLY))
 		return XT_CONTINUE;
=20
 	/* ip_conntrack_icmp guarantees us that we only have ICMP_ECHO,
@@ -321,12 +321,12 @@ clusterip_tg(struct sk_buff *skb, const struct xt=
_action_param *par)
 			ct->mark =3D hash;
 			break;
 		case IP_CT_RELATED:
-		case IP_CT_RELATED+IP_CT_IS_REPLY:
+		case IP_CT_RELATED_REPLY:
 			/* FIXME: we don't handle expectations at the
 			 * moment.  they can arrive on a different node than
 			 * the master connection (e.g. FTP passive mode) */
 		case IP_CT_ESTABLISHED:
-		case IP_CT_ESTABLISHED+IP_CT_IS_REPLY:
+		case IP_CT_ESTABLISHED_REPLY:
 			break;
 		default:
 			break;
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/i=
pt_MASQUERADE.c
index d2ed9dc..9931152 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -60,7 +60,7 @@ masquerade_tg(struct sk_buff *skb, const struct xt_ac=
tion_param *par)
 	nat =3D nfct_nat(ct);
=20
 	NF_CT_ASSERT(ct && (ctinfo =3D=3D IP_CT_NEW || ctinfo =3D=3D IP_CT_RE=
LATED ||
-			    ctinfo =3D=3D IP_CT_RELATED + IP_CT_IS_REPLY));
+			    ctinfo =3D=3D IP_CT_RELATED_REPLY));
=20
 	/* Source address is 0.0.0.0 - locally generated packet that is
 	 * probably not supposed to be masqueraded.
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/=
netfilter/nf_conntrack_l3proto_ipv4.c
index 5a03c02..db10075 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -101,7 +101,7 @@ static unsigned int ipv4_confirm(unsigned int hookn=
um,
=20
 	/* This is where we call the helper: as the packet goes out. */
 	ct =3D nf_ct_get(skb, &ctinfo);
-	if (!ct || ctinfo =3D=3D IP_CT_RELATED + IP_CT_IS_REPLY)
+	if (!ct || ctinfo =3D=3D IP_CT_RELATED_REPLY)
 		goto out;
=20
 	help =3D nfct_help(ct);
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_n=
at_core.c
index 9c71b27..3346de5 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -433,7 +433,7 @@ int nf_nat_icmp_reply_translation(struct nf_conn *c=
t,
=20
 	/* Must be RELATED */
 	NF_CT_ASSERT(skb->nfctinfo =3D=3D IP_CT_RELATED ||
-		     skb->nfctinfo =3D=3D IP_CT_RELATED+IP_CT_IS_REPLY);
+		     skb->nfctinfo =3D=3D IP_CT_RELATED_REPLY);
=20
 	/* Redirects on non-null nats must be dropped, else they'll
 	   start talking to each other without our translation, and be
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_n=
at_rule.c
index 21c3042..733c9ab 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -53,7 +53,7 @@ ipt_snat_target(struct sk_buff *skb, const struct xt_=
action_param *par)
=20
 	/* Connection must be valid and new. */
 	NF_CT_ASSERT(ct && (ctinfo =3D=3D IP_CT_NEW || ctinfo =3D=3D IP_CT_RE=
LATED ||
-			    ctinfo =3D=3D IP_CT_RELATED + IP_CT_IS_REPLY));
+			    ctinfo =3D=3D IP_CT_RELATED_REPLY));
 	NF_CT_ASSERT(par->out !=3D NULL);
=20
 	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_SRC);
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilte=
r/nf_nat_standalone.c
index 7317bdf..483b76d 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/nf_nat_standalone.c
@@ -116,7 +116,7 @@ nf_nat_fn(unsigned int hooknum,
=20
 	switch (ctinfo) {
 	case IP_CT_RELATED:
-	case IP_CT_RELATED+IP_CT_IS_REPLY:
+	case IP_CT_RELATED_REPLY:
 		if (ip_hdr(skb)->protocol =3D=3D IPPROTO_ICMP) {
 			if (!nf_nat_icmp_reply_translation(ct, ctinfo,
 							   hooknum, skb))
@@ -144,7 +144,7 @@ nf_nat_fn(unsigned int hooknum,
 	default:
 		/* ESTABLISHED */
 		NF_CT_ASSERT(ctinfo =3D=3D IP_CT_ESTABLISHED ||
-			     ctinfo =3D=3D (IP_CT_ESTABLISHED+IP_CT_IS_REPLY));
+			     ctinfo =3D=3D IP_CT_ESTABLISHED_REPLY);
 	}
=20
 	return nf_nat_packet(ct, ctinfo, hooknum, skb);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/=
netfilter/nf_conntrack_l3proto_ipv6.c
index c8af58b..4111050 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -160,7 +160,7 @@ static unsigned int ipv6_confirm(unsigned int hookn=
um,
=20
 	/* This is where we call the helper: as the packet goes out. */
 	ct =3D nf_ct_get(skb, &ctinfo);
-	if (!ct || ctinfo =3D=3D IP_CT_RELATED + IP_CT_IS_REPLY)
+	if (!ct || ctinfo =3D=3D IP_CT_RELATED_REPLY)
 		goto out;
=20
 	help =3D nfct_help(ct);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 2e1c11f..0bd5689 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -850,7 +850,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *=
tmpl,
=20
 	/* It exists; we have (non-exclusive) reference. */
 	if (NF_CT_DIRECTION(h) =3D=3D IP_CT_DIR_REPLY) {
-		*ctinfo =3D IP_CT_ESTABLISHED + IP_CT_IS_REPLY;
+		*ctinfo =3D IP_CT_ESTABLISHED_REPLY;
 		/* Please set reply bit if this packet OK */
 		*set_reply =3D 1;
 	} else {
@@ -1143,7 +1143,7 @@ static void nf_conntrack_attach(struct sk_buff *n=
skb, struct sk_buff *skb)
 	/* This ICMP is in reverse direction to the packet which caused it */
 	ct =3D nf_ct_get(skb, &ctinfo);
 	if (CTINFO2DIR(ctinfo) =3D=3D IP_CT_DIR_ORIGINAL)
-		ctinfo =3D IP_CT_RELATED + IP_CT_IS_REPLY;
+		ctinfo =3D IP_CT_RELATED_REPLY;
 	else
 		ctinfo =3D IP_CT_RELATED;
=20
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntr=
ack_ftp.c
index e17cb7c..6f5801e 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -368,7 +368,7 @@ static int help(struct sk_buff *skb,
=20
 	/* Until there's been traffic both ways, don't look in packets. */
 	if (ctinfo !=3D IP_CT_ESTABLISHED &&
-	    ctinfo !=3D IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
+	    ctinfo !=3D IP_CT_ESTABLISHED_REPLY) {
 		pr_debug("ftp: Conntrackinfo =3D %u\n", ctinfo);
 		return NF_ACCEPT;
 	}
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_=
conntrack_h323_main.c
index 18b2ce5..f03c2d4 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -571,10 +571,9 @@ static int h245_help(struct sk_buff *skb, unsigned=
 int protoff,
 	int ret;
=20
 	/* Until there's been traffic both ways, don't look in packets. */
-	if (ctinfo !=3D IP_CT_ESTABLISHED &&
-	    ctinfo !=3D IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
+	if (ctinfo !=3D IP_CT_ESTABLISHED && ctinfo !=3D IP_CT_ESTABLISHED_RE=
PLY)
 		return NF_ACCEPT;
-	}
+
 	pr_debug("nf_ct_h245: skblen =3D %u\n", skb->len);
=20
 	spin_lock_bh(&nf_h323_lock);
@@ -1125,10 +1124,9 @@ static int q931_help(struct sk_buff *skb, unsign=
ed int protoff,
 	int ret;
=20
 	/* Until there's been traffic both ways, don't look in packets. */
-	if (ctinfo !=3D IP_CT_ESTABLISHED &&
-	    ctinfo !=3D IP_CT_ESTABLISHED + IP_CT_IS_REPLY) {
+	if (ctinfo !=3D IP_CT_ESTABLISHED && ctinfo !=3D IP_CT_ESTABLISHED_RE=
PLY)
 		return NF_ACCEPT;
-	}
+
 	pr_debug("nf_ct_q931: skblen =3D %u\n", skb->len);
=20
 	spin_lock_bh(&nf_h323_lock);
diff --git a/net/netfilter/nf_conntrack_irc.c b/net/netfilter/nf_conntr=
ack_irc.c
index b394aa3..4f9390b 100644
--- a/net/netfilter/nf_conntrack_irc.c
+++ b/net/netfilter/nf_conntrack_irc.c
@@ -125,8 +125,7 @@ static int help(struct sk_buff *skb, unsigned int p=
rotoff,
 		return NF_ACCEPT;
=20
 	/* Until there's been traffic both ways, don't look in packets. */
-	if (ctinfo !=3D IP_CT_ESTABLISHED &&
-	    ctinfo !=3D IP_CT_ESTABLISHED + IP_CT_IS_REPLY)
+	if (ctinfo !=3D IP_CT_ESTABLISHED && ctinfo !=3D IP_CT_ESTABLISHED_RE=
PLY)
 		return NF_ACCEPT;
=20
 	/* Not a full tcp header? */
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_connt=
rack_pptp.c
index 0889448..2fd4565 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -519,8 +519,7 @@ conntrack_pptp_help(struct sk_buff *skb, unsigned i=
nt protoff,
 	u_int16_t msg;
=20
 	/* don't do any tracking before tcp handshake complete */
-	if (ctinfo !=3D IP_CT_ESTABLISHED &&
-	    ctinfo !=3D IP_CT_ESTABLISHED + IP_CT_IS_REPLY)
+	if (ctinfo !=3D IP_CT_ESTABLISHED && ctinfo !=3D IP_CT_ESTABLISHED_RE=
PLY)
 		return NF_ACCEPT;
=20
 	nexthdr_off =3D protoff;
diff --git a/net/netfilter/nf_conntrack_sane.c b/net/netfilter/nf_connt=
rack_sane.c
index d9e2773..8501823 100644
--- a/net/netfilter/nf_conntrack_sane.c
+++ b/net/netfilter/nf_conntrack_sane.c
@@ -78,7 +78,7 @@ static int help(struct sk_buff *skb,
 	ct_sane_info =3D &nfct_help(ct)->help.ct_sane_info;
 	/* Until there's been traffic both ways, don't look in packets. */
 	if (ctinfo !=3D IP_CT_ESTABLISHED &&
-	    ctinfo !=3D IP_CT_ESTABLISHED+IP_CT_IS_REPLY)
+	    ctinfo !=3D IP_CT_ESTABLISHED_REPLY)
 		return NF_ACCEPT;
=20
 	/* Not a full tcp header? */
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntr=
ack_sip.c
index cb5a285..93faf6a 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -1423,7 +1423,7 @@ static int sip_help_tcp(struct sk_buff *skb, unsi=
gned int protoff,
 	typeof(nf_nat_sip_seq_adjust_hook) nf_nat_sip_seq_adjust;
=20
 	if (ctinfo !=3D IP_CT_ESTABLISHED &&
-	    ctinfo !=3D IP_CT_ESTABLISHED + IP_CT_IS_REPLY)
+	    ctinfo !=3D IP_CT_ESTABLISHED_REPLY)
 		return NF_ACCEPT;
=20
 	/* No Data ? */
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 9cc4635..fe39f7e 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -143,9 +143,9 @@ socket_match(const struct sk_buff *skb, struct xt_a=
ction_param *par,
 	ct =3D nf_ct_get(skb, &ctinfo);
 	if (ct && !nf_ct_is_untracked(ct) &&
 	    ((iph->protocol !=3D IPPROTO_ICMP &&
-	      ctinfo =3D=3D IP_CT_IS_REPLY + IP_CT_ESTABLISHED) ||
+	      ctinfo =3D=3D IP_CT_ESTABLISHED_REPLY) ||
 	     (iph->protocol =3D=3D IPPROTO_ICMP &&
-	      ctinfo =3D=3D IP_CT_IS_REPLY + IP_CT_RELATED)) &&
+	      ctinfo =3D=3D IP_CT_RELATED_REPLY)) &&
 	    (ct->status & IPS_SRC_NAT_DONE)) {
=20
 		daddr =3D ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
