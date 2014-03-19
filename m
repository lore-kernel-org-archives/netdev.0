From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 1/3] rtnetlink: fix fdb notification flags
Date: Wed, 19 Mar 2014 17:47:49 +0100
Message-ID: <1395247671-9356-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56154 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965238AbaCSQs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 12:48:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3ff661c38c84 ("net: rtnetlink notify events for FDB NTF_SELF adds and
deletes") reuses the function nlmsg_populate_fdb_fill() to notify fdb events.
But this function was used only for dump and thus was always setting the
flag NLM_F_MULTI, which is wrong in case of a single notification.

Libraries like libnl will wait forever for NLMSG_DONE.

CC: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1a0dac2ef9ad..120eecc0f5a4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2121,12 +2121,13 @@ EXPORT_SYMBOL(rtmsg_ifinfo);
 static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
 				   struct net_device *dev,
 				   u8 *addr, u32 pid, u32 seq,
-				   int type, unsigned int flags)
+				   int type, unsigned int flags,
+				   int nlflags)
 {
 	struct nlmsghdr *nlh;
 	struct ndmsg *ndm;
 
-	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndm), NLM_F_MULTI);
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ndm), nlflags);
 	if (!nlh)
 		return -EMSGSIZE;
 
@@ -2164,7 +2165,7 @@ static void rtnl_fdb_notify(struct net_device *dev, u8 *addr, int type)
 	if (!skb)
 		goto errout;
 
-	err = nlmsg_populate_fdb_fill(skb, dev, addr, 0, 0, type, NTF_SELF);
+	err = nlmsg_populate_fdb_fill(skb, dev, addr, 0, 0, type, NTF_SELF, 0);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
@@ -2389,7 +2390,8 @@ static int nlmsg_populate_fdb(struct sk_buff *skb,
 
 		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr,
 					      portid, seq,
-					      RTM_NEWNEIGH, NTF_SELF);
+					      RTM_NEWNEIGH, NTF_SELF,
+					      NLM_F_MULTI);
 		if (err < 0)
 			return err;
 skip:
-- 
1.8.5.4
