From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 4/7] net: ipv4: refactor fib_dump_info
Date: Mon,  9 Jan 2017 13:32:48 -0800
Message-ID: <1483997571-3964-5-git-send-email-dsa@cumulusnetworks.com>
References: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34221 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941378AbdAIVdA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:33:00 -0500
Received: by mail-pf0-f173.google.com with SMTP id 127so34073334pfg.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 13:33:00 -0800 (PST)
In-Reply-To: <1483997571-3964-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pull code that adds attributes to the response from fib_dump_info into
a separate, stand-alone function. That function is used by a later patch
to add the matching route to a get route request.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_lookup.h    |  2 ++
 net/ipv4/fib_semantics.c | 17 +++++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 9c02920725db..7d2c019c5257 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -33,6 +33,8 @@ int fib_nh_match(struct fib_config *cfg, struct fib_info *fi);
 int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event, u32 tb_id,
 		  u8 type, __be32 dst, int dst_len, u8 tos, struct fib_info *fi,
 		  unsigned int);
+int fib_dump_add_attrs_rcu(struct sk_buff *skb, __be32 dst, struct rtmsg *rtm,
+			   struct fib_info *fi);
 void rtmsg_fib(int event, __be32 key, struct fib_alias *fa, int dst_len,
 	       u32 tb_id, const struct nl_info *info, unsigned int nlm_flags);
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 05c911d21782..c6f7223fcd08 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1247,6 +1247,21 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 	rtm->rtm_scope = fi->fib_scope;
 	rtm->rtm_protocol = fi->fib_protocol;
 
+	if (fib_dump_add_attrs_rcu(skb, dst, rtm, fi))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+/* called with rcu_read_lock held */
+int fib_dump_add_attrs_rcu(struct sk_buff *skb, __be32 dst, struct rtmsg *rtm,
+			   struct fib_info *fi)
+{
 	if (rtm->rtm_dst_len &&
 	    nla_put_in_addr(skb, RTA_DST, dst))
 		goto nla_put_failure;
@@ -1325,11 +1340,9 @@ int fib_dump_info(struct sk_buff *skb, u32 portid, u32 seq, int event,
 		nla_nest_end(skb, mp);
 	}
 #endif
-	nlmsg_end(skb, nlh);
 	return 0;
 
 nla_put_failure:
-	nlmsg_cancel(skb, nlh);
 	return -EMSGSIZE;
 }
 
-- 
2.1.4
