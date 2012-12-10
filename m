From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH] net: Allow DCBnl to use other namespaces besides init_net
Date: Sun, 09 Dec 2012 22:48:13 -0800
Message-ID: <20121210064813.10883.88194.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:36123 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751950Ab2LJGso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 01:48:44 -0500
Received: by mail-gg0-f174.google.com with SMTP id k2so436488ggd.19
        for <netdev@vger.kernel.org>; Sun, 09 Dec 2012 22:48:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow DCB and net namespace to work together. This is useful if you
have containers that are bound to 'phys' interfaces that want to
also manage their DCB attributes.

The net namespace is taken from sock_net(skb->sk) of the netlink skb.

CC: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/dcb/dcbnl.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index b07c75d..1b588e2 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -1665,9 +1665,6 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if ((nlh->nlmsg_type == RTM_SETDCB) && !capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (!net_eq(net, &init_net))
-		return -EINVAL;
-
 	ret = nlmsg_parse(nlh, sizeof(*dcb), tb, DCB_ATTR_MAX,
 			  dcbnl_rtnl_policy);
 	if (ret < 0)
@@ -1684,7 +1681,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	if (!tb[DCB_ATTR_IFNAME])
 		return -EINVAL;
 
-	netdev = dev_get_by_name(&init_net, nla_data(tb[DCB_ATTR_IFNAME]));
+	netdev = dev_get_by_name(net, nla_data(tb[DCB_ATTR_IFNAME]));
 	if (!netdev)
 		return -ENODEV;
 
@@ -1708,7 +1705,7 @@ static int dcb_doit(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 
 	nlmsg_end(reply_skb, reply_nlh);
 
-	ret = rtnl_unicast(reply_skb, &init_net, portid);
+	ret = rtnl_unicast(reply_skb, net, portid);
 out:
 	dev_put(netdev);
 	return ret;
