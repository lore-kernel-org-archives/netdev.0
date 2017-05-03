From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/16] netfilter: xt_CT: fix refcnt leak on error path
Date: Wed,  3 May 2017 11:31:56 +0200
Message-ID: <1493803931-2837-2-git-send-email-pablo@netfilter.org>
References: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45644 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752850AbdECJc3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 3 May 2017 05:32:29 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id E41481C4438
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 11:32:21 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CAF186E7AB
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 11:32:21 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B2FC9FF2D2
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 11:32:17 +0200 (CEST)
In-Reply-To: <1493803931-2837-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are two cases which causes refcnt leak.

1. When nf_ct_timeout_ext_add failed in xt_ct_set_timeout, it should
free the timeout refcnt.
Now goto the err_put_timeout error handler instead of going ahead.

2. When the time policy is not found, we should call module_put.
Otherwise, the related cthelper module cannot be removed anymore.
It is easy to reproduce by typing the following command:
  # iptables -t raw -A OUTPUT -p tcp -j CT --helper ftp --timeout xxx

Signed-off-by: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index b008db0184b8..81fdcdca7457 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -167,8 +167,10 @@ xt_ct_set_timeout(struct nf_conn *ct, const struct xt_tgchk_param *par,
 		goto err_put_timeout;
 	}
 	timeout_ext = nf_ct_timeout_ext_add(ct, timeout, GFP_ATOMIC);
-	if (timeout_ext == NULL)
+	if (!timeout_ext) {
 		ret = -ENOMEM;
+		goto err_put_timeout;
+	}
 
 	rcu_read_unlock();
 	return ret;
@@ -200,6 +202,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 			  struct xt_ct_target_info_v1 *info)
 {
 	struct nf_conntrack_zone zone;
+	struct nf_conn_help *help;
 	struct nf_conn *ct;
 	int ret = -EOPNOTSUPP;
 
@@ -248,7 +251,7 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 	if (info->timeout[0]) {
 		ret = xt_ct_set_timeout(ct, par, info->timeout);
 		if (ret < 0)
-			goto err3;
+			goto err4;
 	}
 	__set_bit(IPS_CONFIRMED_BIT, &ct->status);
 	nf_conntrack_get(&ct->ct_general);
@@ -256,6 +259,10 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 	info->ct = ct;
 	return 0;
 
+err4:
+	help = nfct_help(ct);
+	if (help)
+		module_put(help->helper->me);
 err3:
 	nf_ct_tmpl_free(ct);
 err2:
-- 
2.1.4
