From: Harout Hedeshian <harouth@codeaurora.org>
Subject: [PATCH net-next] net: ipv6: Add sysctl entry to disable MTU updates from RA
Date: Fri, 16 Jan 2015 18:02:38 -0700
Message-ID: <1421456558-27144-1-git-send-email-harouth@codeaurora.org>
Cc: Harout Hedeshian <harouth@codeaurora.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:33527 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466AbbAQBD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 20:03:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel forcefully applies MTU values received in router
advertisements provided the new MTU is less than the current. This
behavior is undesirable when the user space is managing the MTU. Instead
a sysctl flag 'accept_ra_mtu' is introduced such that the user space
can control whether or not RA provided MTU updates should be applied. The
default behavior is unchanged; user space must explicitly set this flag
to 0 for RA MTUs to be ignored.

Signed-off-by: Harout Hedeshian <harouth@codeaurora.org>
---
 Documentation/networking/ip-sysctl.txt | 7 +++++++
 include/linux/ipv6.h                   | 1 +
 include/uapi/linux/ipv6.h              | 1 +
 kernel/sysctl_binary.c                 | 1 +
 net/ipv6/addrconf.c                    | 9 +++++++++
 net/ipv6/ndisc.c                       | 2 +-
 6 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 85b0221..da50faa 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1287,6 +1287,13 @@ accept_ra_rtr_pref - BOOLEAN
 	Functional default: enabled if accept_ra is enabled.
 			    disabled if accept_ra is disabled.
 
+accept_ra_mtu - BOOLEAN
+	Apply the MTU value specified in RA option 5 (RFC4861). If
+	disabled, the MTU specified in the RA will be ignored.
+
+	Functional default: enabled if accept_ra is enabled.
+                            disabled if accept_ra is disabled.
+
 accept_redirects - BOOLEAN
 	Accept Redirects.
 
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index c694e7b..2805062 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -52,6 +52,7 @@ struct ipv6_devconf {
 	__s32		force_tllao;
 	__s32           ndisc_notify;
 	__s32		suppress_frag_ndisc;
+	__s32		accept_ra_mtu;
 	void		*sysctl;
 };
 
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 73cb02d..437a6a4 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -169,6 +169,7 @@ enum {
 	DEVCONF_SUPPRESS_FRAG_NDISC,
 	DEVCONF_ACCEPT_RA_FROM_LOCAL,
 	DEVCONF_USE_OPTIMISTIC,
+	DEVCONF_ACCEPT_RA_MTU,
 	DEVCONF_MAX
 };
 
diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
index 7e7746a..16091e5 100644
--- a/kernel/sysctl_binary.c
+++ b/kernel/sysctl_binary.c
@@ -523,6 +523,7 @@ static const struct bin_table bin_net_ipv6_conf_var_table[] = {
 	{ CTL_INT,	NET_IPV6_PROXY_NDP,			"proxy_ndp" },
 	{ CTL_INT,	NET_IPV6_ACCEPT_SOURCE_ROUTE,		"accept_source_route" },
 	{ CTL_INT,	NET_IPV6_ACCEPT_RA_FROM_LOCAL,		"accept_ra_from_local" },
+	{ CTL_INT,	NET_IPV6_ACCEPT_RA_MTU,			"accept_ra_mtu" },
 	{}
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f7c8bbe..cdd70ed 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -201,6 +201,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
+	.accept_ra_mtu		= 1,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -238,6 +239,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.disable_ipv6		= 0,
 	.accept_dad		= 1,
 	.suppress_frag_ndisc	= 1,
+	.accept_ra_mtu		= 1,
 };
 
 /* Check if a valid qdisc is available */
@@ -5253,6 +5255,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	= proc_dointvec,
 		},
 		{
+			.procname	= "accept_ra_mtu",
+			.data		= &ipv6_devconf.accept_ra_mtu,
+			.maxlen		= sizeof(int),
+			.mode		= 0644,
+			.proc_handler	= proc_dointvec,
+		},
+		{
 			/* sentinel */
 		}
 	},
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 6828667..83332cd 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1348,7 +1348,7 @@ skip_routeinfo:
 		}
 	}
 
-	if (ndopts.nd_opts_mtu) {
+	if (ndopts.nd_opts_mtu  && in6_dev->cnf.accept_ra_mtu) {
 		__be32 n;
 		u32 mtu;
 
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project
