From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 7/8] net: ipv4: RTM_GETROUTE: return matched fib result when requested
Date: Wed, 24 May 2017 11:19:10 -0700
Message-ID: <1495649951-30417-8-git-send-email-roopa@cumulusnetworks.com>
References: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33572 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933865AbdEXST1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 14:19:27 -0400
Received: by mail-pf0-f178.google.com with SMTP id e193so143309227pfh.0
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:19:27 -0700 (PDT)
In-Reply-To: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support to return matched fib result when RTM_F_FIB_MATCH
flag is specified in RTM_GETROUTE request. This is useful for user-space
applications/controllers wanting to query a matching route.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv4/route.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6e0bd40..419bdba 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -114,6 +114,8 @@
 #include <net/ip_tunnels.h>
 #include <net/l3mdev.h>
 
+#include "fib_lookup.h"
+
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
 
@@ -2746,8 +2748,15 @@ static int inet_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
 	if (rtm->rtm_flags & RTM_F_LOOKUP_TABLE)
 		table_id = rt->rt_table_id;
 
-	err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
-			   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq, rt);
+	if (rtm->rtm_flags & RTM_F_FIB_MATCH)
+		err = fib_dump_info(skb, NETLINK_CB(in_skb).portid,
+				    nlh->nlmsg_seq, RTM_NEWROUTE, table_id,
+				    rt->rt_type, res.prefix, res.prefixlen,
+				    fl4.flowi4_tos, res.fi, 0);
+	else
+		err = rt_fill_info(net, dst, src, table_id, &fl4, skb,
+				   NETLINK_CB(in_skb).portid, nlh->nlmsg_seq,
+				   rt);
 	if (err < 0)
 		goto errout_free;
 
-- 
1.9.1
