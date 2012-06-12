From: pablo@netfilter.org
Subject: [PATCH 6/7] netfilter: ctnetlink: add CTA_HELP_INFO attribute
Date: Tue, 12 Jun 2012 20:06:19 +0200
Message-ID: <1339524380-2707-7-git-send-email-pablo@netfilter.org>
References: <1339524380-2707-1-git-send-email-pablo@netfilter.org>
Cc: netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53634 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663Ab2FLSHM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2012 14:07:12 -0400
In-Reply-To: <1339524380-2707-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This attribute can be used to modify and to dump the internal
protocol information.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 include/net/netfilter/nf_conntrack_helper.h   |    1 +
 net/netfilter/nf_conntrack_netlink.c          |   23 ++++++++++++++++++-----
 3 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index e58e4b9..7688833 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -191,6 +191,7 @@ enum ctattr_expect_nat {
 enum ctattr_help {
 	CTA_HELP_UNSPEC,
 	CTA_HELP_NAME,
+	CTA_HELP_INFO,
 	__CTA_HELP_MAX
 };
 #define CTA_HELP_MAX (__CTA_HELP_MAX - 1)
diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 061352f..84b24c3 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -39,6 +39,7 @@ struct nf_conntrack_helper {
 
 	void (*destroy)(struct nf_conn *ct);
 
+	int (*from_nlattr)(struct nlattr *attr, struct nf_conn *ct);
 	int (*to_nlattr)(struct sk_buff *skb, const struct nf_conn *ct);
 	unsigned int expect_class_max;
 };
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 206d297..17bd96b 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -902,7 +902,8 @@ static const struct nla_policy help_nla_policy[CTA_HELP_MAX+1] = {
 };
 
 static inline int
-ctnetlink_parse_help(const struct nlattr *attr, char **helper_name)
+ctnetlink_parse_help(const struct nlattr *attr, char **helper_name,
+		     struct nlattr **helpinfo)
 {
 	struct nlattr *tb[CTA_HELP_MAX+1];
 
@@ -913,6 +914,9 @@ ctnetlink_parse_help(const struct nlattr *attr, char **helper_name)
 
 	*helper_name = nla_data(tb[CTA_HELP_NAME]);
 
+	if (tb[CTA_HELP_INFO])
+		*helpinfo = tb[CTA_HELP_INFO];
+
 	return 0;
 }
 
@@ -1173,13 +1177,14 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 	struct nf_conntrack_helper *helper;
 	struct nf_conn_help *help = nfct_help(ct);
 	char *helpname = NULL;
+	struct nlattr *helpinfo = NULL;
 	int err;
 
 	/* don't change helper of sibling connections */
 	if (ct->master)
 		return -EBUSY;
 
-	err = ctnetlink_parse_help(cda[CTA_HELP], &helpname);
+	err = ctnetlink_parse_help(cda[CTA_HELP], &helpname, &helpinfo);
 	if (err < 0)
 		return err;
 
@@ -1214,8 +1219,12 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 	}
 
 	if (help) {
-		if (help->helper == helper)
+		if (help->helper == helper) {
+			/* update private helper data if allowed. */
+			if (helper->from_nlattr && helpinfo)
+				helper->from_nlattr(helpinfo, ct);
 			return 0;
+		}
 		if (help->helper)
 			return -EBUSY;
 		/* need to zero data of old helper */
@@ -1411,8 +1420,9 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 	rcu_read_lock();
  	if (cda[CTA_HELP]) {
 		char *helpname = NULL;
- 
- 		err = ctnetlink_parse_help(cda[CTA_HELP], &helpname);
+		struct nlattr *helpinfo = NULL;
+
+		err = ctnetlink_parse_help(cda[CTA_HELP], &helpname, &helpinfo);
  		if (err < 0)
 			goto err2;
 
@@ -1446,6 +1456,9 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 				err = -ENOMEM;
 				goto err2;
 			}
+			/* set private helper data if allowed. */
+			if (helper->from_nlattr && helpinfo)
+				helper->from_nlattr(helpinfo, ct);
 
 			/* not in hash table yet so not strictly necessary */
 			RCU_INIT_POINTER(help->helper, helper);
-- 
1.7.10
