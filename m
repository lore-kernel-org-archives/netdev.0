From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/18] netfilter: Factor out the hook list selection from nf_register_hook
Date: Tue,  4 Aug 2015 12:02:33 +0200
Message-ID: <1438682568-8346-4-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55960 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932995AbbHDJ5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:14 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

- Add a new function find_nf_hook_list to select the nf_hook_list

- Fail nf_register_hook when asked for a per netdevice hook list when
  support for per netdevice hook lists is not built into the kernel.

- Move the hook list head selection outside of nf_hook_mutex as
  nothing in the selection requires the hook list, and error handling
  is simpler if a mutex is not held.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/core.c |   32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index c4c3b85..fa4d3c1 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -62,27 +62,31 @@ EXPORT_SYMBOL(nf_hooks_needed);
 
 static DEFINE_MUTEX(nf_hook_mutex);
 
-int nf_register_hook(struct nf_hook_ops *reg)
+static struct list_head *find_nf_hook_list(const struct nf_hook_ops *reg)
 {
-	struct list_head *nf_hook_list;
-	struct nf_hook_ops *elem;
+	struct list_head *nf_hook_list = NULL;
 
-	mutex_lock(&nf_hook_mutex);
-	switch (reg->pf) {
-	case NFPROTO_NETDEV:
+	if (reg->pf != NFPROTO_NETDEV)
+		nf_hook_list = &nf_hooks[reg->pf][reg->hooknum];
+	else if (reg->hooknum == NF_NETDEV_INGRESS) {
 #ifdef CONFIG_NETFILTER_INGRESS
-		if (reg->hooknum == NF_NETDEV_INGRESS) {
-			BUG_ON(reg->dev == NULL);
+		if (reg->dev)
 			nf_hook_list = &reg->dev->nf_hooks_ingress;
-			break;
-		}
 #endif
-		/* Fall through. */
-	default:
-		nf_hook_list = &nf_hooks[reg->pf][reg->hooknum];
-		break;
 	}
+	return nf_hook_list;
+}
+
+int nf_register_hook(struct nf_hook_ops *reg)
+{
+	struct list_head *nf_hook_list;
+	struct nf_hook_ops *elem;
 
+	nf_hook_list = find_nf_hook_list(reg);
+	if (!nf_hook_list)
+		return -ENOENT;
+
+	mutex_lock(&nf_hook_mutex);
 	list_for_each_entry(elem, nf_hook_list, list) {
 		if (reg->priority < elem->priority)
 			break;
-- 
1.7.10.4
