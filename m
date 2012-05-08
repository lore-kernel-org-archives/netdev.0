From: pablo@netfilter.org
Subject: [PATCH 24/25] netfilter: nf_conntrack: fix explicit helper attachment and NAT
Date: Tue,  8 May 2012 20:38:22 +0200
Message-ID: <1336502303-1722-25-git-send-email-pablo@netfilter.org>
References: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, openbsc@lists.osmocom.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39318 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756629Ab2EHSkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 14:40:13 -0400
In-Reply-To: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Explicit helper attachment via the CT target is broken with NAT
if non-standard ports are used. This problem was hidden behind
the automatic helper assignment routine. Thus, it becomes more
noticeable now that we can disable the automatic helper assignment
with Eric Leblond's:

9e8ac5a netfilter: nf_ct_helper: allow to disable automatic helper assignment

Basically, nf_conntrack_alter_reply asks for looking up the helper
up if NAT is enabled. Unfortunately, we don't have the conntrack
template at that point anymore.

Since we don't want to rely on the automatic helper assignment,
we can skip the second look-up and stick to the helper that was
attached by iptables. With the CT target, the user is in full
control of helper attachment, thus, the policy is to trust what
the user explicitly configures via iptables (no automatic magic
anymore).

Interestingly, this bug was hidden by the automatic helper look-up
code. But it can be easily trigger if you attach the helper in
a non-standard port, eg.

iptables -I PREROUTING -t raw -p tcp --dport 8888 \
	-j CT --helper ftp

And you disabled the automatic helper assignment.

I added the IPS_HELPER_BIT that allows us to differenciate between
a helper that has been explicitly attached and those that have been
automatically assigned. I didn't come up with a better solution
(having backward compatibility in mind).

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_common.h |    4 ++++
 net/netfilter/nf_conntrack_helper.c           |   13 ++++++++++++-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/linux/netfilter/nf_conntrack_common.h b/include/linux/netfilter/nf_conntrack_common.h
index 0d3dd66..d146872 100644
--- a/include/linux/netfilter/nf_conntrack_common.h
+++ b/include/linux/netfilter/nf_conntrack_common.h
@@ -83,6 +83,10 @@ enum ip_conntrack_status {
 	/* Conntrack is a fake untracked entry */
 	IPS_UNTRACKED_BIT = 12,
 	IPS_UNTRACKED = (1 << IPS_UNTRACKED_BIT),
+
+	/* Conntrack got a helper explicitly attached via CT target. */
+	IPS_HELPER_BIT = 13,
+	IPS_HELPER = (1 << IPS_HELPER_BIT),
 };
 
 /* Connection tracking event types */
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 317f6e4..4fa2ff9 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -182,10 +182,21 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 	struct net *net = nf_ct_net(ct);
 	int ret = 0;
 
+	/* We already got a helper explicitly attached. The function
+	 * nf_conntrack_alter_reply - in case NAT is in use - asks for looking
+	 * the helper up again. Since now the user is in full control of
+	 * making consistent helper configurations, skip this automatic
+	 * re-lookup, otherwise we'll lose the helper.
+	 */
+	if (test_bit(IPS_HELPER_BIT, &ct->status))
+		return 0;
+
 	if (tmpl != NULL) {
 		help = nfct_help(tmpl);
-		if (help != NULL)
+		if (help != NULL) {
 			helper = help->helper;
+			set_bit(IPS_HELPER_BIT, &ct->status);
+		}
 	}
 
 	help = nfct_help(ct);
-- 
1.7.9.5
