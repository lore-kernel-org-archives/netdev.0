From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/8] netfilter: nf_ct_helper: warn when not applying default helper assignment
Date: Thu, 23 Feb 2017 12:14:02 +0100
Message-ID: <1487848449-2731-2-git-send-email-pablo@netfilter.org>
References: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54882 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751049AbdBWLOU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 06:14:20 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 7F118A4173
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:18 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 668CFDA84B
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:18 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C90ECDA860
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 12:14:15 +0100 (CET)
In-Reply-To: <1487848449-2731-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jkosina@suse.cz>

Commit 3bb398d925 ("netfilter: nf_ct_helper: disable automatic helper
assignment") is causing behavior regressions in firewalls, as traffic
handled by conntrack helpers is now by default not passed through even
though it was before due to missing CT targets (which were not necessary
before this commit).

The default had to be switched off due to security reasons [1] [2] and
therefore should stay the way it is, but let's be friendly to firewall
admins and issue a warning the first time we're in situation where packet
would be likely passed through with the old default but we're likely going
to drop it on the floor now.

Rewrite the code a little bit as suggested by Linus, so that we avoid
spaghettiing the code even more -- namely the whole decision making
process regarding helper selection (either automatic or not) is being
separated, so that the whole logic can be simplified and code (condition)
duplication reduced.

[1] https://cansecwest.com/csw12/conntrack-attack.pdf
[2] https://home.regit.org/netfilter-en/secure-use-of-helpers/

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c | 39 ++++++++++++++++++++++++-------------
 1 file changed, 26 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 7341adf7059d..6dc44d9b4190 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -188,6 +188,26 @@ nf_ct_helper_ext_add(struct nf_conn *ct,
 }
 EXPORT_SYMBOL_GPL(nf_ct_helper_ext_add);
 
+static struct nf_conntrack_helper *
+nf_ct_lookup_helper(struct nf_conn *ct, struct net *net)
+{
+	if (!net->ct.sysctl_auto_assign_helper) {
+		if (net->ct.auto_assign_helper_warned)
+			return NULL;
+		if (!__nf_ct_helper_find(&ct->tuplehash[IP_CT_DIR_REPLY].tuple))
+			return NULL;
+		pr_info("nf_conntrack: default automatic helper assignment "
+			"has been turned off for security reasons and CT-based "
+			" firewall rule not found. Use the iptables CT target "
+			"to attach helpers instead.\n");
+		net->ct.auto_assign_helper_warned = 1;
+		return NULL;
+	}
+
+	return __nf_ct_helper_find(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+}
+
+
 int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 			      gfp_t flags)
 {
@@ -213,21 +233,14 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 	}
 
 	help = nfct_help(ct);
-	if (net->ct.sysctl_auto_assign_helper && helper == NULL) {
-		helper = __nf_ct_helper_find(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
-		if (unlikely(!net->ct.auto_assign_helper_warned && helper)) {
-			pr_info("nf_conntrack: automatic helper "
-				"assignment is deprecated and it will "
-				"be removed soon. Use the iptables CT target "
-				"to attach helpers instead.\n");
-			net->ct.auto_assign_helper_warned = true;
-		}
-	}
 
 	if (helper == NULL) {
-		if (help)
-			RCU_INIT_POINTER(help->helper, NULL);
-		return 0;
+		helper = nf_ct_lookup_helper(ct, net);
+		if (helper == NULL) {
+			if (help)
+				RCU_INIT_POINTER(help->helper, NULL);
+			return 0;
+		}
 	}
 
 	if (help == NULL) {
-- 
2.1.4
