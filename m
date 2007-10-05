From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: [PATCH][IPv6] Export userland ND options through netlink (RDNSS support)
Date: Fri, 5 Oct 2007 08:09:30 +0200
Message-ID: <20071005060930.GA15305@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from durga.via.ecp.fr ([138.195.130.75]:37315 "EHLO durga.via.ecp.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbXJEGJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 02:09:33 -0400
Received: from localhost (durga.via.ecp.fr [127.0.0.1])
	by durga.via.ecp.fr (Postfix) with ESMTP id 0C5A931F69
	for <netdev@vger.kernel.org>; Fri,  5 Oct 2007 08:09:31 +0200 (CEST)
Received: from durga.via.ecp.fr ([127.0.0.1])
	by localhost (durga.via.ecp.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IctMLuo33XVS for <netdev@vger.kernel.org>;
	Fri,  5 Oct 2007 08:09:30 +0200 (CEST)
Received: from zen.via.ecp.fr (zen.via.ecp.fr [138.195.130.72])
	by durga.via.ecp.fr (Postfix) with ESMTP id DAA7C31F1C
	for <netdev@vger.kernel.org>; Fri,  5 Oct 2007 08:09:30 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As discussed before, this patch provides userland with a way to access
relevant options in Router Advertisements, after they are processed and
validated by the kernel. Extra options are processed in a generic way;
this patch only exports RDNSS options described in RFC5006, but support
to control which options are exported could be easily added.

A new rtnetlink message type is defined, to transport Neighbor Discover=
y
options, along with optional context information. At the moment only
the address of the router sending an RDNSS option is included, but
additional attributes may be later defined, if needed by new use cases.

Signed-off-by: Pierre Ynard <linkfanel@yahoo.fr>

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index dff3192..124d451 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -97,6 +97,9 @@ enum {
 	RTM_SETNEIGHTBL,
 #define RTM_SETNEIGHTBL	RTM_SETNEIGHTBL
=20
+	RTM_NEWNDUSEROPT =3D 68,
+#define RTM_NEWNDUSEROPT RTM_NEWNDUSEROPT
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
@@ -479,6 +482,30 @@ enum
 #define TCA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeo=
f(struct tcmsg))))
 #define TCA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcmsg))
=20
+/********************************************************************
+ *		Neighbor Discovery userland options
+ ****/
+
+struct nduseroptmsg
+{
+	unsigned char	nduseropt_family;
+	unsigned char	nduseropt_pad1;
+	unsigned short	nduseropt_opts_len;	/* Total length of options */
+	__u8		nduseropt_icmp_type;
+	__u8		nduseropt_icmp_code;
+	unsigned short	nduseropt_pad2;
+	/* Followed by one or more ND options */
+};
+
+enum=20
+{
+	NDUSEROPT_UNSPEC,
+	NDUSEROPT_SRCADDR,
+	__NDUSEROPT_MAX
+};
+
+#define NDUSEROPT_MAX	(__NDUSEROPT_MAX - 1)
+
 #ifndef __KERNEL__
 /* RTnetlink multicast groups - backwards compatibility for userspace =
*/
 #define RTMGRP_LINK		1
@@ -542,6 +569,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_IPV6_PREFIX	RTNLGRP_IPV6_PREFIX
 	RTNLGRP_IPV6_RULE,
 #define RTNLGRP_IPV6_RULE	RTNLGRP_IPV6_RULE
+	RTNLGRP_ND_USEROPT,
+#define RTNLGRP_ND_USEROPT	RTNLGRP_ND_USEROPT
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 475b10c..6684f7e 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -24,6 +24,7 @@ enum {
 	ND_OPT_MTU =3D 5,			/* RFC2461 */
 	__ND_OPT_ARRAY_MAX,
 	ND_OPT_ROUTE_INFO =3D 24,		/* RFC4191 */
+	ND_OPT_RDNSS =3D 25,		/* RFC5006 */
 	__ND_OPT_MAX
 };
=20
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 74c4d8d..04b2453 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -15,9 +15,10 @@
 /*
  *	Changes:
  *
+ *	Pierre Ynard			:	export userland ND options
+ *						through netlink (RDNSS support)
  *	Lars Fenneberg			:	fixed MTU setting on receipt
  *						of an RA.
- *
  *	Janos Farkas			:	kmalloc failure checks
  *	Alexey Kuznetsov		:	state machine reworked
  *						and moved to net/core.
@@ -78,6 +79,9 @@
 #include <net/addrconf.h>
 #include <net/icmp.h>
=20
+#include <net/netlink.h>
+#include <linux/rtnetlink.h>
+
 #include <net/flow.h>
 #include <net/ip6_checksum.h>
 #include <linux/proc_fs.h>
@@ -161,6 +165,8 @@ struct ndisc_options {
 	struct nd_opt_hdr *nd_opts_ri;
 	struct nd_opt_hdr *nd_opts_ri_end;
 #endif
+	struct nd_opt_hdr *nd_useropts;
+	struct nd_opt_hdr *nd_useropts_end;
 };
=20
 #define nd_opts_src_lladdr	nd_opt_array[ND_OPT_SOURCE_LL_ADDR]
@@ -225,6 +231,22 @@ static struct nd_opt_hdr *ndisc_next_option(struct=
 nd_opt_hdr *cur,
 	return (cur <=3D end && cur->nd_opt_type =3D=3D type ? cur : NULL);
 }
=20
+static inline int ndisc_is_useropt(struct nd_opt_hdr *opt)
+{
+	return (opt->nd_opt_type =3D=3D ND_OPT_RDNSS);
+}
+
+static struct nd_opt_hdr *ndisc_next_useropt(struct nd_opt_hdr *cur,
+					     struct nd_opt_hdr *end)
+{
+	if (!cur || !end || cur >=3D end)
+		return NULL;
+	do {
+		cur =3D ((void *)cur) + (cur->nd_opt_len << 3);
+	} while(cur < end && !ndisc_is_useropt(cur));
+	return (cur <=3D end && ndisc_is_useropt(cur) ? cur : NULL);
+}
+
 static struct ndisc_options *ndisc_parse_options(u8 *opt, int opt_len,
 						 struct ndisc_options *ndopts)
 {
@@ -267,14 +289,21 @@ static struct ndisc_options *ndisc_parse_options(=
u8 *opt, int opt_len,
 			break;
 #endif
 		default:
-			/*
-			 * Unknown options must be silently ignored,
-			 * to accommodate future extension to the protocol.
-			 */
-			ND_PRINTK2(KERN_NOTICE
-				   "%s(): ignored unsupported option; type=3D%d, len=3D%d\n",
-				   __FUNCTION__,
-				   nd_opt->nd_opt_type, nd_opt->nd_opt_len);
+			if (ndisc_is_useropt(nd_opt)) {
+				ndopts->nd_useropts_end =3D nd_opt;
+				if (!ndopts->nd_useropts)
+					ndopts->nd_useropts =3D nd_opt;
+			} else {
+				/*
+				 * Unknown options must be silently ignored,
+				 * to accommodate future extension to the
+				 * protocol.
+				 */
+				ND_PRINTK2(KERN_NOTICE
+					   "%s(): ignored unsupported option; type=3D%d, len=3D%d\n",
+					   __FUNCTION__,
+					   nd_opt->nd_opt_type, nd_opt->nd_opt_len);
+			}
 		}
 		opt_len -=3D l;
 		nd_opt =3D ((void *)nd_opt) + l;
@@ -984,6 +1013,53 @@ out:
 	in6_dev_put(idev);
 }
=20
+static void ndisc_ra_useropt(struct sk_buff *ra, struct nd_opt_hdr *op=
t)
+{
+	struct icmp6hdr *icmp6h =3D (struct icmp6hdr *)skb_transport_header(r=
a);
+	struct sk_buff *skb;
+	struct nlmsghdr *nlh;
+	struct nduseroptmsg *ndmsg;
+	int err;
+	int base_size =3D NLMSG_ALIGN(sizeof(struct nduseroptmsg)
+				    + (opt->nd_opt_len << 3));
+	size_t msg_size =3D base_size + nla_total_size(sizeof(struct in6_addr=
));
+
+	skb =3D nlmsg_new(msg_size, GFP_ATOMIC);
+	if (skb =3D=3D NULL) {
+		err =3D -ENOBUFS;
+		goto errout;
+	}
+
+	nlh =3D nlmsg_put(skb, 0, 0, RTM_NEWNDUSEROPT, base_size, 0);
+	if (nlh =3D=3D NULL) {
+		goto nla_put_failure;
+	}
+
+	ndmsg =3D nlmsg_data(nlh);
+	ndmsg->nduseropt_family =3D AF_INET6;
+	ndmsg->nduseropt_icmp_type =3D icmp6h->icmp6_type;
+	ndmsg->nduseropt_icmp_code =3D icmp6h->icmp6_code;
+	ndmsg->nduseropt_opts_len =3D opt->nd_opt_len << 3;
+
+	memcpy(ndmsg + 1, opt, opt->nd_opt_len << 3);
+
+	NLA_PUT(skb, NDUSEROPT_SRCADDR, sizeof(struct in6_addr),
+		&ipv6_hdr(ra)->saddr);
+	nlmsg_end(skb, nlh);
+
+	err =3D rtnl_notify(skb, 0, RTNLGRP_ND_USEROPT, NULL, GFP_ATOMIC);
+	if (err < 0)
+		goto errout;
+
+	return;
+
+nla_put_failure:
+	nlmsg_free(skb);
+	err =3D -EMSGSIZE;
+errout:
+	rtnl_set_sk_err(RTNLGRP_ND_USEROPT, err);
+}
+
 static void ndisc_router_discovery(struct sk_buff *skb)
 {
 	struct ra_msg *ra_msg =3D (struct ra_msg *)skb_transport_header(skb);
@@ -1216,6 +1292,15 @@ skip_defrtr:
 		}
 	}
=20
+	if (ndopts.nd_useropts) {
+		struct nd_opt_hdr *opt;
+		for (opt =3D ndopts.nd_useropts;
+		     opt;
+		     opt =3D ndisc_next_useropt(opt, ndopts.nd_useropts_end)) {
+				ndisc_ra_useropt(skb, opt);
+		}
+	}
+
 	if (ndopts.nd_opts_tgt_lladdr || ndopts.nd_opts_rh) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 RA: invalid RA options");


--=20
Pierre Ynard
=46or hire in Quebec City, Canada, during Fall 2007
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
