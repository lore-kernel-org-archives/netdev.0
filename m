From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 15/31: nfnetlink: cleanup for nfnetlink_rcv_msg() function
Date: Wed, 10 Jun 2009 21:46:40 +0200 (MEST)
Message-ID: <20090610194638.11112.42060.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33163 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761120AbZFJTqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:38 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f49c857ff20a660850bf8014716d0df6175e1883
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Jun 2 20:03:33 2009 +0200

    netfilter: nfnetlink: cleanup for nfnetlink_rcv_msg() function
    
    This patch cleans up the message handling path in two aspects:
    
     * it uses NLMSG_LENGTH() instead of NLMSG_SPACE() like rtnetlink
    does in this case to check if there is enough room for the
    Netlink/nfnetlink headers. No need to check for the padding room.
    
     * it removes a redundant header size checking that has been
     already do at the beginning of the function.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index b8ab37a..9dbd570 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -136,7 +136,7 @@ static int nfnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EPERM;
 
 	/* All the messages must at least contain nfgenmsg */
-	if (nlh->nlmsg_len < NLMSG_SPACE(sizeof(struct nfgenmsg)))
+	if (nlh->nlmsg_len < NLMSG_LENGTH(sizeof(struct nfgenmsg)))
 		return 0;
 
 	type = nlh->nlmsg_type;
@@ -160,19 +160,14 @@ replay:
 	{
 		int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
 		u_int8_t cb_id = NFNL_MSG_TYPE(nlh->nlmsg_type);
-		u_int16_t attr_count = ss->cb[cb_id].attr_count;
-		struct nlattr *cda[attr_count+1];
-
-		if (likely(nlh->nlmsg_len >= min_len)) {
-			struct nlattr *attr = (void *)nlh + NLMSG_ALIGN(min_len);
-			int attrlen = nlh->nlmsg_len - NLMSG_ALIGN(min_len);
-
-			err = nla_parse(cda, attr_count, attr, attrlen,
-					ss->cb[cb_id].policy);
-			if (err < 0)
-				return err;
-		} else
-			return -EINVAL;
+		struct nlattr *cda[ss->cb[cb_id].attr_count + 1];
+		struct nlattr *attr = (void *)nlh + min_len;
+		int attrlen = nlh->nlmsg_len - min_len;
+
+		err = nla_parse(cda, ss->cb[cb_id].attr_count,
+				attr, attrlen, ss->cb[cb_id].policy);
+		if (err < 0)
+			return err;
 
 		err = nc->call(nfnl, skb, nlh, cda);
 		if (err == -EAGAIN)
