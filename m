From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/29] netfilter: use_nf_conn_expires helper in more places
Date: Mon,  5 Sep 2016 12:58:19 +0200
Message-ID: <1473073124-5015-5-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35106 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932635AbcIEK66 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:58:58 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AC0252EFEBF
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:56 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9D9D8114D77
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:56 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 214251150D0
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:54 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

... so we don't need to touch all of these places when we get rid of the
timer in nf_conn.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c | 3 +--
 net/netfilter/nf_conntrack_netlink.c                  | 5 +----
 net/netfilter/nf_conntrack_standalone.c               | 3 +--
 net/netfilter/xt_conntrack.c                          | 4 +---
 4 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 6392371..67bfc69 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -163,8 +163,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	ret = -ENOSPC;
 	seq_printf(s, "%-8s %u %ld ",
 		   l4proto->name, nf_ct_protonum(ct),
-		   timer_pending(&ct->timeout)
-		   ? (long)(ct->timeout.expires - jiffies)/HZ : 0);
+		   nf_ct_expires(ct) / HZ);
 
 	if (l4proto->print_conntrack)
 		l4proto->print_conntrack(s, ct);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 050bb34..68800c1 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -149,10 +149,7 @@ nla_put_failure:
 
 static int ctnetlink_dump_timeout(struct sk_buff *skb, const struct nf_conn *ct)
 {
-	long timeout = ((long)ct->timeout.expires - (long)jiffies) / HZ;
-
-	if (timeout < 0)
-		timeout = 0;
+	long timeout = nf_ct_expires(ct) / HZ;
 
 	if (nla_put_be32(skb, CTA_TIMEOUT, htonl(timeout)))
 		goto nla_put_failure;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 958a145..4e7becd 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -224,8 +224,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 	seq_printf(s, "%-8s %u %-8s %u %ld ",
 		   l3proto->name, nf_ct_l3num(ct),
 		   l4proto->name, nf_ct_protonum(ct),
-		   timer_pending(&ct->timeout)
-		   ? (long)(ct->timeout.expires - jiffies)/HZ : 0);
+		   nf_ct_expires(ct)  / HZ);
 
 	if (l4proto->print_conntrack)
 		l4proto->print_conntrack(s, ct);
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 188404b9..a3b8f69 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -233,10 +233,8 @@ conntrack_mt(const struct sk_buff *skb, struct xt_action_param *par,
 		return false;
 
 	if (info->match_flags & XT_CONNTRACK_EXPIRES) {
-		unsigned long expires = 0;
+		unsigned long expires = nf_ct_expires(ct) / HZ;
 
-		if (timer_pending(&ct->timeout))
-			expires = (ct->timeout.expires - jiffies) / HZ;
 		if ((expires >= info->expires_min &&
 		    expires <= info->expires_max) ^
 		    !(info->invert_flags & XT_CONNTRACK_EXPIRES))
-- 
2.1.4
