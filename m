From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK]: Remove remains of wireless extensions over rtnetlink
Date: Mon, 21 May 2007 23:39:09 +0200
Message-ID: <4652117D.7060000@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080000090005050403080206"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64621 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756857AbXEUVjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 17:39:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080000090005050403080206
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit


--------------080000090005050403080206
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[RTNETLINK]: Remove remains of wireless extensions over rtnetlink

Remove some unused variables and function arguments related to the recently
removed wireless extensions over rtnetlink.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 192ecca1d62ada577a664410ed90b9a83315a65a
tree 0c14773793fadfd1d1267a0a361718181e2b8f6e
parent 58bac614f9ea12b45970011ba53b8c2c33d1db3f
author Patrick McHardy <kaber@trash.net> Thu, 17 May 2007 05:31:10 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 17 May 2007 22:06:27 +0200

 net/core/rtnetlink.c |   27 ++++++++++-----------------
 1 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 20935f2..e2996bb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -437,7 +437,7 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 	a->tx_compressed = b->tx_compressed;
 };
 
-static inline size_t if_nlmsg_size(int iwbuflen)
+static inline size_t if_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
 	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
@@ -452,13 +452,12 @@ static inline size_t if_nlmsg_size(int iwbuflen)
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
-	       + nla_total_size(1) /* IFLA_LINKMODE */
-	       + nla_total_size(iwbuflen);
+	       + nla_total_size(1); /* IFLA_LINKMODE */
 }
 
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
-			    void *iwbuf, int iwbuflen, int type, u32 pid,
-			    u32 seq, u32 change, unsigned int flags)
+			    int type, u32 pid, u32 seq, u32 change,
+			    unsigned int flags)
 {
 	struct ifinfomsg *ifm;
 	struct nlmsghdr *nlh;
@@ -523,9 +522,6 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	if (iwbuf)
-		NLA_PUT(skb, IFLA_WIRELESS, iwbuflen, iwbuf);
-
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -543,7 +539,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	for_each_netdev(dev) {
 		if (idx < s_idx)
 			goto cont;
-		if (rtnl_fill_ifinfo(skb, dev, NULL, 0, RTM_NEWLINK,
+		if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
 				     NETLINK_CB(cb->skb).pid,
 				     cb->nlh->nlmsg_seq, 0, NLM_F_MULTI) <= 0)
 			break;
@@ -730,8 +726,6 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	struct nlattr *tb[IFLA_MAX+1];
 	struct net_device *dev = NULL;
 	struct sk_buff *nskb;
-	char *iw_buf = NULL, *iw = NULL;
-	int iw_buf_len = 0;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
@@ -746,14 +740,14 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	} else
 		return -EINVAL;
 
-	nskb = nlmsg_new(if_nlmsg_size(iw_buf_len), GFP_KERNEL);
+	nskb = nlmsg_new(if_nlmsg_size(), GFP_KERNEL);
 	if (nskb == NULL) {
 		err = -ENOBUFS;
 		goto errout;
 	}
 
-	err = rtnl_fill_ifinfo(nskb, dev, iw, iw_buf_len, RTM_NEWLINK,
-			       NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0, 0);
+	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).pid,
+			       nlh->nlmsg_seq, 0, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size */
 		WARN_ON(err == -EMSGSIZE);
@@ -762,7 +756,6 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 	}
 	err = rtnl_unicast(nskb, NETLINK_CB(skb).pid);
 errout:
-	kfree(iw_buf);
 	dev_put(dev);
 
 	return err;
@@ -797,11 +790,11 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change)
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(if_nlmsg_size(0), GFP_KERNEL);
+	skb = nlmsg_new(if_nlmsg_size(), GFP_KERNEL);
 	if (skb == NULL)
 		goto errout;
 
-	err = rtnl_fill_ifinfo(skb, dev, NULL, 0, type, 0, 0, change, 0);
+	err = rtnl_fill_ifinfo(skb, dev, type, 0, 0, change, 0);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in if_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);

--------------080000090005050403080206--
