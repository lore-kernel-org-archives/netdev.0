From: pablo@netfilter.org
Subject: [PATCH 14/16] netfilter: nf_ct_ftp: add sequence tracking pickup facility for injected entries
Date: Mon, 24 Sep 2012 21:19:26 +0200
Message-ID: <1348514369-3272-15-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58137 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932102Ab2IXTVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:21:09 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch allows the FTP helper to pickup the sequence tracking from
the first packet seen. This is useful to fix the breakage of the first
FTP command after the failover while using conntrackd to synchronize
states.

The seq_aft_nl_num field in struct nf_ct_ftp_info has been shrinked to
16-bits (enough for what it does), so we can use the remaining 16-bits
to store the flags while using the same size for the private FTP helper
data.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_ftp.h |    6 +++++-
 net/netfilter/nf_conntrack_ftp.c           |   21 +++++++++++++++++++++
 net/netfilter/nf_conntrack_netlink.c       |    4 ++--
 net/netfilter/nfnetlink_cthelper.c         |    3 +++
 4 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_ftp.h b/include/linux/netfilter/nf_conntrack_ftp.h
index 28f18df..8faf3f7 100644
--- a/include/linux/netfilter/nf_conntrack_ftp.h
+++ b/include/linux/netfilter/nf_conntrack_ftp.h
@@ -18,13 +18,17 @@ enum nf_ct_ftp_type {
 
 #define FTP_PORT	21
 
+#define NF_CT_FTP_SEQ_PICKUP	(1 << 0)
+
 #define NUM_SEQ_TO_REMEMBER 2
 /* This structure exists only once per master */
 struct nf_ct_ftp_master {
 	/* Valid seq positions for cmd matching after newline */
 	u_int32_t seq_aft_nl[IP_CT_DIR_MAX][NUM_SEQ_TO_REMEMBER];
 	/* 0 means seq_match_aft_nl not set */
-	int seq_aft_nl_num[IP_CT_DIR_MAX];
+	u_int16_t seq_aft_nl_num[IP_CT_DIR_MAX];
+	/* pickup sequence tracking, useful for conntrackd */
+	u_int16_t flags[IP_CT_DIR_MAX];
 };
 
 struct nf_conntrack_expect;
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index f8cc26a..1ce3bef 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -396,6 +396,12 @@ static int help(struct sk_buff *skb,
 
 	/* Look up to see if we're just after a \n. */
 	if (!find_nl_seq(ntohl(th->seq), ct_ftp_info, dir)) {
+		/* We're picking up this, clear flags and let it continue */
+		if (unlikely(ct_ftp_info->flags[dir] & NF_CT_FTP_SEQ_PICKUP)) {
+			ct_ftp_info->flags[dir] ^= NF_CT_FTP_SEQ_PICKUP;
+			goto skip_nl_seq;
+		}
+
 		/* Now if this ends in \n, update ftp info. */
 		pr_debug("nf_conntrack_ftp: wrong seq pos %s(%u) or %s(%u)\n",
 			 ct_ftp_info->seq_aft_nl_num[dir] > 0 ? "" : "(UNSET)",
@@ -406,6 +412,7 @@ static int help(struct sk_buff *skb,
 		goto out_update_nl;
 	}
 
+skip_nl_seq:
 	/* Initialize IP/IPv6 addr to expected address (it's not mentioned
 	   in EPSV responses) */
 	cmd.l3num = nf_ct_l3num(ct);
@@ -512,6 +519,19 @@ out_update_nl:
 	return ret;
 }
 
+static int nf_ct_ftp_from_nlattr(struct nlattr *attr, struct nf_conn *ct)
+{
+	struct nf_ct_ftp_master *ftp = nfct_help_data(ct);
+
+	/* This conntrack has been injected from user-space, always pick up
+	 * sequence tracking. Otherwise, the first FTP command after the
+	 * failover breaks.
+	 */
+	ftp->flags[IP_CT_DIR_ORIGINAL] |= NF_CT_FTP_SEQ_PICKUP;
+	ftp->flags[IP_CT_DIR_REPLY] |= NF_CT_FTP_SEQ_PICKUP;
+	return 0;
+}
+
 static struct nf_conntrack_helper ftp[MAX_PORTS][2] __read_mostly;
 
 static const struct nf_conntrack_expect_policy ftp_exp_policy = {
@@ -561,6 +581,7 @@ static int __init nf_conntrack_ftp_init(void)
 			ftp[i][j].expect_policy = &ftp_exp_policy;
 			ftp[i][j].me = THIS_MODULE;
 			ftp[i][j].help = help;
+			ftp[i][j].from_nlattr = nf_ct_ftp_from_nlattr;
 			if (ports[i] == FTP_PORT)
 				sprintf(ftp[i][j].name, "ftp");
 			else
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 2dcd080..7bbfb3d 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1238,7 +1238,7 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 	if (help) {
 		if (help->helper == helper) {
 			/* update private helper data if allowed. */
-			if (helper->from_nlattr && helpinfo)
+			if (helper->from_nlattr)
 				helper->from_nlattr(helpinfo, ct);
 			return 0;
 		} else
@@ -1467,7 +1467,7 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 				goto err2;
 			}
 			/* set private helper data if allowed. */
-			if (helper->from_nlattr && helpinfo)
+			if (helper->from_nlattr)
 				helper->from_nlattr(helpinfo, ct);
 
 			/* not in hash table yet so not strictly necessary */
diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index 3678073..945950a 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -85,6 +85,9 @@ nfnl_cthelper_from_nlattr(struct nlattr *attr, struct nf_conn *ct)
 {
 	const struct nf_conn_help *help = nfct_help(ct);
 
+	if (attr == NULL)
+		return -EINVAL;
+
 	if (help->helper->data_len == 0)
 		return -EINVAL;
 
-- 
1.7.10.4
