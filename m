From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] rtnetlink: fix rtnl_calcit() and rtnl_dump_ifinfo()
Date: Sun, 04 Mar 2012 14:32:10 -0800
Message-ID: <1330900330.17266.10.camel@edumazet-laptop>
References: <20120221215127.30280.30853.stgit@gitlad.jf.intel.com>
	 <20120221.165750.2246668899195223381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:62666 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755567Ab2CDWcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 17:32:13 -0500
Received: by dadp12 with SMTP id p12so4205506dad.11
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 14:32:13 -0800 (PST)
In-Reply-To: <20120221.165750.2246668899195223381.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nlmsg_parse() might return an error, so test its return value before
potential random memory accesses.

Errors introduced in commit 115c9b81928 (rtnetlink: Fix problem with
buffer allocation)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
---
 net/core/rtnetlink.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 606a6e8..f965dce 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1060,11 +1060,12 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	rcu_read_lock();
 	cb->seq = net->dev_base_seq;
 
-	nlmsg_parse(cb->nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
-		    ifla_policy);
+	if (nlmsg_parse(cb->nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
+			ifla_policy) >= 0) {
 
-	if (tb[IFLA_EXT_MASK])
-		ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+		if (tb[IFLA_EXT_MASK])
+			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+	}
 
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
@@ -1900,10 +1901,11 @@ static u16 rtnl_calcit(struct sk_buff *skb, struct nlmsghdr *nlh)
 	u32 ext_filter_mask = 0;
 	u16 min_ifinfo_dump_size = 0;
 
-	nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX, ifla_policy);
-
-	if (tb[IFLA_EXT_MASK])
-		ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+	if (nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
+			ifla_policy) >= 0) {
+		if (tb[IFLA_EXT_MASK])
+			ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
+	}
 
 	if (!ext_filter_mask)
 		return NLMSG_GOODSIZE;
