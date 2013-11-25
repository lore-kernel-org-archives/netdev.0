From: fx.lebail@yahoo.com
Subject: [PATCH] ipv6 addrconf: source address selection, Rule 7: Prefer temporary addresses (RFC 6724)
Date: Mon, 25 Nov 2013 17:16:45 +0100
Message-ID: <1385396205-6105-1-git-send-email-fx.lebail@yahoo.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.smtpout.orange.fr ([80.12.242.125]:38309 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757092Ab3KYQ33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 11:29:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RFC 6724 change the default recommendation for source address selection
Rule 7 to prefer temporary addresses rather than public addresses,
while providing an administrative override.

The administrative override is based on the prefer_src_public sysctl.

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 3c12d9a..0f7ecaa 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1256,13 +1256,15 @@ router_solicitations - INTEGER
 use_tempaddr - INTEGER
 	Preference for Privacy Extensions (RFC3041).
 	  <= 0 : disable Privacy Extensions
-	  == 1 : enable Privacy Extensions, but prefer public
-	         addresses over temporary addresses.
-	  >  1 : enable Privacy Extensions and prefer temporary
-	         addresses over public addresses.
+	  >= 1 : enable Privacy Extensions and prefer temporary
+	         addresses over public addresses (RFC 6724).
 	Default:  0 (for most devices)
 		 -1 (for point-to-point devices and loopback devices)
 
+prefer_src_public - BOOLEAN
+	Prefer public addresses over temporary addresses.
+	Default: FALSE
+
 temp_valid_lft - INTEGER
 	valid lifetime (in seconds) for temporary addresses.
 	Default: 604800 (7 days)
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 5d89d1b..c90a1e6 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -49,6 +49,7 @@ struct ipv6_devconf {
 	__s32		force_tllao;
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
+	__s32		prefer_src_public;
 	void		*sysctl;
 };
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 593b0e3..37dabcc 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -163,6 +163,7 @@ enum {
 	DEVCONF_MLDV1_UNSOLICITED_REPORT_INTERVAL,
 	DEVCONF_MLDV2_UNSOLICITED_REPORT_INTERVAL,
 	DEVCONF_SUPPRESS_FRAG_NDISC,
+	DEVCONF_PREFER_SRC_PUBLIC,
 	DEVCONF_MAX
 };
 
diff --git a/include/uapi/linux/sysctl.h b/include/uapi/linux/sysctl.h
index 6d67213..0034b48 100644
--- a/include/uapi/linux/sysctl.h
+++ b/include/uapi/linux/sysctl.h
@@ -568,6 +568,7 @@ enum {
 	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN=22,
 	NET_IPV6_PROXY_NDP=23,
 	NET_IPV6_ACCEPT_SOURCE_ROUTE=25,
+	NET_IPV6_PREFER_SRC_PUBLIC = 26,
 	__NET_IPV6_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 12c97d8..b0127cd 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -197,6 +197,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
+	.prefer_src_public	= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -233,6 +234,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
+	.prefer_src_public	= 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -1245,12 +1247,14 @@ static int ipv6_get_saddr_eval(struct net *net,
 		break;
 	case IPV6_SADDR_RULE_PRIVACY:
 	    {
-		/* Rule 7: Prefer public address
-		 * Note: prefer temporary address if use_tempaddr >= 2
+		/* Rule 7: Prefer temporary addresses (updated in RFC 6724)
+		 * Note: test on use_tempaddr >= 1 to avoid changing previous
+		 * behaviour using > 1 value for the same purpose
 		 */
 		int preftmp = dst->prefs & (IPV6_PREFER_SRC_PUBLIC|IPV6_PREFER_SRC_TMP) ?
 				!!(dst->prefs & IPV6_PREFER_SRC_TMP) :
-				score->ifa->idev->cnf.use_tempaddr >= 2;
+				score->ifa->idev->cnf.use_tempaddr >= 1 &&
+				!score->ifa->idev->cnf.prefer_src_public;
 		ret = (!(score->ifa->flags & IFA_F_TEMPORARY)) ^ preftmp;
 		break;
 	    }
@@ -4120,6 +4124,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_FORCE_TLLAO] = cnf->force_tllao;
 	array[DEVCONF_NDISC_NOTIFY] = cnf->ndisc_notify;
 	array[DEVCONF_SUPPRESS_FRAG_NDISC] = cnf->suppress_frag_ndisc;
+	array[DEVCONF_PREFER_SRC_PUBLIC] = cnf->prefer_src_public;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -4939,6 +4944,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec
 		},
 		{
+			.procname	= "prefer_src_public",
+			.data		= &ipv6_devconf.prefer_src_public,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
 			/* sentinel */
 		}
 	},
