From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [RFC PATCH] xfrm: Add option to reset oif in xfrm lookup
Date: Mon, 25 Jul 2016 18:34:32 -0600
Message-ID: <1469493272-14894-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: dsa@cumulusnetworks.com, steffen.klassert@secunet.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:45296 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbcGZAem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 20:34:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are seeing incorrect routing when tunneling packets over an
interface and sending it over another interface. This scenario
worked on 3.18 (and earlier) and failed on 4.4 kernel. The rules
/ routes / policies were the same across kernels.

Commit 42a7b32b73d6 ("xfrm: Add oif to dst lookups") allowed
preservation of the oif from a raw packet to a transformed packet.
This causes issues with forwarding scenarios where the
existing oif causes an incorrect route lookup.

Create a new sysctl which resets oif in xfrm policy. Default value
is 0 which means that oif is preserved on transform.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 include/net/netns/xfrm.h | 1 +
 net/ipv4/xfrm4_policy.c  | 3 ++-
 net/ipv6/xfrm6_policy.c  | 3 ++-
 net/xfrm/xfrm_sysctl.c   | 8 ++++++++
 4 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 24cd394..2e1beca 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -64,6 +64,7 @@ struct netns_xfrm {
 	u32			sysctl_aevent_rseqth;
 	int			sysctl_larval_drop;
 	u32			sysctl_acq_expires;
+	int 			sysctl_reset_oif;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_hdr;
 #endif
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 7b0edb3..4dc3733 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -29,7 +29,8 @@ static struct dst_entry *__xfrm4_dst_lookup(struct net *net, struct flowi4 *fl4,
 	memset(fl4, 0, sizeof(*fl4));
 	fl4->daddr = daddr->a4;
 	fl4->flowi4_tos = tos;
-	fl4->flowi4_oif = oif;
+	if (!net->xfrm.sysctl_reset_oif)
+		fl4->flowi4_oif = oif;
 	if (saddr)
 		fl4->saddr = saddr->a4;
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index c074771..13e72d7 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -36,7 +36,8 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
 	int err;
 
 	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_oif = oif;
+	if (!net->xfrm.sysctl_reset_oif)
+		fl6.flowi6_oif = oif;
 	fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
 	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
 	if (saddr)
diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
index 05a6e3d..c9d374b 100644
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -9,6 +9,7 @@ static void __net_init __xfrm_sysctl_init(struct net *net)
 	net->xfrm.sysctl_aevent_rseqth = XFRM_AE_SEQT_SIZE;
 	net->xfrm.sysctl_larval_drop = 1;
 	net->xfrm.sysctl_acq_expires = 30;
+	net->xfrm.sysctl_reset_oif = 0;
 }
 
 #ifdef CONFIG_SYSCTL
@@ -37,6 +38,12 @@ static struct ctl_table xfrm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "xfrm_reset_oif",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{}
 };
 
@@ -53,6 +60,7 @@ int __net_init xfrm_sysctl_init(struct net *net)
 	table[1].data = &net->xfrm.sysctl_aevent_rseqth;
 	table[2].data = &net->xfrm.sysctl_larval_drop;
 	table[3].data = &net->xfrm.sysctl_acq_expires;
+	table[4].data = &net->xfrm.sysctl_reset_oif;
 
 	/* Don't export sysctls to unprivileged users */
 	if (net->user_ns != &init_user_ns)
-- 
1.9.1
