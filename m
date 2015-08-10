From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/5] netfilter: nf_conntrack: checking for IS_ERR() instead of NULL
Date: Mon, 10 Aug 2015 19:58:36 +0200
Message-ID: <1439229519-7640-3-git-send-email-pablo@netfilter.org>
References: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35703 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932423AbbHJRyU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Aug 2015 13:54:20 -0400
In-Reply-To: <1439229519-7640-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>

We recently changed this from nf_conntrack_alloc() to nf_ct_tmpl_alloc()
so the error handling needs to changed to check for NULL instead of
IS_ERR().

Fixes: 0838aa7fcfcd ('netfilter: fix netns dependencies with conntrack templates')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_synproxy_core.c |    4 +---
 net/netfilter/xt_CT.c            |    5 +++--
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 71f1e9f..d7f1685 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -353,10 +353,8 @@ static int __net_init synproxy_net_init(struct net *net)
 	int err = -ENOMEM;
 
 	ct = nf_ct_tmpl_alloc(net, 0, GFP_KERNEL);
-	if (IS_ERR(ct)) {
-		err = PTR_ERR(ct);
+	if (!ct)
 		goto err1;
-	}
 
 	if (!nfct_seqadj_ext_add(ct))
 		goto err2;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index c663003..43ddeee 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -202,9 +202,10 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 		goto err1;
 
 	ct = nf_ct_tmpl_alloc(par->net, info->zone, GFP_KERNEL);
-	ret = PTR_ERR(ct);
-	if (IS_ERR(ct))
+	if (!ct) {
+		ret = -ENOMEM;
 		goto err2;
+	}
 
 	ret = 0;
 	if ((info->ct_events || info->exp_events) &&
-- 
1.7.10.4
