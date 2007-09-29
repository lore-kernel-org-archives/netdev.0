From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: [RFC][IPv6] Export userland ND options through netlink (RDNSS support)
Date: Sat, 29 Sep 2007 19:47:20 +0200
Message-ID: <20070929174720.GA21678@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from durga.via.ecp.fr ([138.195.130.75]:50359 "EHLO durga.via.ecp.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755081AbXI2SRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 14:17:41 -0400
Received: from localhost (durga.via.ecp.fr [127.0.0.1])
	by durga.via.ecp.fr (Postfix) with ESMTP id A853D327B3
	for <netdev@vger.kernel.org>; Sat, 29 Sep 2007 19:47:20 +0200 (CEST)
Received: from durga.via.ecp.fr ([127.0.0.1])
	by localhost (durga.via.ecp.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id baXfemX3vI+L for <netdev@vger.kernel.org>;
	Sat, 29 Sep 2007 19:47:20 +0200 (CEST)
Received: from zen.via.ecp.fr (zen.via.ecp.fr [138.195.130.72])
	by durga.via.ecp.fr (Postfix) with ESMTP id 8053732776
	for <netdev@vger.kernel.org>; Sat, 29 Sep 2007 19:47:20 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As discussed before, this patch provides userland with a way to access
relevant options in Router Advertisements, after they are processed and
validated by the kernel. Extra options are processed in a generic way;
this patch only exports RDNSS options described in RFC5006, but support
to control which options are exported could be easily added.

Options are exported using a new message type of rtnetlink. I am totall=
y
new to netlink, so help would be greatly appreciated to design a right
interface. For now each message only contains a single ND option, in it=
s
raw format. Should they contains several options when possible?

Also, depending on the option, userland might need context information
contained in the rest of the RA packet. For example, RFC5006 states:

"Note:  An RDNSS address MUST be used only as long as both the RA
router lifetime and the RDNSS option lifetime have not expired."

which implies that a userland daemon processing RDNSS options needs a
way to associate the option to the router that sent it, and fetch its
lifetime. This kind of information could be included in a header in the
rtnetlink message (in this version of the patch there is none).

Regards,

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index dff3192..f69d415 100644
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
@@ -542,6 +545,8 @@ enum rtnetlink_groups {
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
index 74c4d8d..646cd4a 100644
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
@@ -984,6 +1013,33 @@ out:
 	in6_dev_put(idev);
 }
=20
+static void ndisc_useropt_notify(struct nd_opt_hdr *opt)
+{
+	struct sk_buff *skb;
+	struct nlmsghdr *nlh;
+	int err =3D -ENOBUFS;
+
+	skb =3D nlmsg_new(opt->nd_opt_len << 3, GFP_ATOMIC);
+	if (skb =3D=3D NULL)
+		goto errout;
+
+	nlh =3D nlmsg_put(skb, 0, 0, RTM_NEWNDUSEROPT, opt->nd_opt_len << 3, =
0);
+	if (nlh =3D=3D NULL) {
+		nlmsg_free(skb);
+		goto errout;
+	}
+
+	memcpy(nlmsg_data(nlh), opt, opt->nd_opt_len << 3);
+	nlmsg_end(skb, nlh);
+
+	err =3D rtnl_notify(skb, 0, RTNLGRP_ND_USEROPT, NULL, GFP_ATOMIC);
+
+	if (err < 0) {
+errout:
+		rtnl_set_sk_err(RTNLGRP_ND_USEROPT, err);
+	}
+}
+
 static void ndisc_router_discovery(struct sk_buff *skb)
 {
 	struct ra_msg *ra_msg =3D (struct ra_msg *)skb_transport_header(skb);
@@ -1216,6 +1272,15 @@ skip_defrtr:
 		}
 	}
=20
+	if (ndopts.nd_useropts) {
+		struct nd_opt_hdr *opt;
+		for (opt =3D ndopts.nd_useropts;
+		     opt;
+		     opt =3D ndisc_next_useropt(opt, ndopts.nd_useropts_end)) {
+				ndisc_useropt_notify(opt);
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
