From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/20] netfilter: x_tables: fix cgroup matching on non-full sks
Date: Thu,  9 Apr 2015 13:34:50 +0200
Message-ID: <1428579304-5520-7-git-send-email-pablo@netfilter.org>
References: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33159 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933044AbbDILbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 07:31:21 -0400
In-Reply-To: <1428579304-5520-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>

While originally only being intended for outgoing traffic, commit
a00e76349f35 ("netfilter: x_tables: allow to use cgroup match for
LOCAL_IN nf hooks") enabled xt_cgroups for the NF_INET_LOCAL_IN hook
as well, in order to allow for nfacct accounting.

Besides being currently limited to early demuxes only, commit
a00e76349f35 forgot to add a check if we deal with full sockets,
i.e. in this case not with time wait sockets. TCP time wait sockets
do not have the same memory layout as full sockets, a lower memory
footprint and consequently also don't have a sk_classid member;
probing for sk_classid member there could potentially lead to a
crash.

Fixes: a00e76349f35 ("netfilter: x_tables: allow to use cgroup match for LOCAL_IN nf hooks")
Cc: Alexey Perevalov <a.perevalov@samsung.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_cgroup.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_cgroup.c b/net/netfilter/xt_cgroup.c
index 7198d66..a1d126f 100644
--- a/net/netfilter/xt_cgroup.c
+++ b/net/netfilter/xt_cgroup.c
@@ -39,7 +39,7 @@ cgroup_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_cgroup_info *info = par->matchinfo;
 
-	if (skb->sk == NULL)
+	if (skb->sk == NULL || !sk_fullsock(skb->sk))
 		return false;
 
 	return (info->id == skb->sk->sk_classid) ^ info->invert;
-- 
1.7.10.4
