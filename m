From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK 02/04]: Hold rtnl_mutex during netlink dump callbacks
Date: Mon, 16 Apr 2007 09:51:54 +0200 (MEST)
Message-ID: <20070416074951.19262.57226.sendpatchset@localhost.localdomain>
References: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34165 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932451AbXDPHvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 03:51:55 -0400
In-Reply-To: <20070416074949.19262.73702.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[RTNETLINK]: Hold rtnl_mutex during netlink dump callbacks

Hold rtnl_mutex during the entire netlink dump operation. This allows
to simplify locking in the dump callbacks, since they can now rely on
that no concurrent changes happen.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8d28b6a3d70b6c98bba6d1e60e2ecf8eb9fbbb2b
tree e363ea54f7b22a3cbd47e032c5fed1b1edb7d53c
parent 8373a426e9d692f74d10867c2dc3ea332e09154c
author Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:24 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 16 Apr 2007 09:05:24 +0200

 net/core/rtnetlink.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 648a7b6..62f5c7f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -859,6 +859,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int min_len;
 	int family;
 	int type;
+	int err;
 
 	type = nlh->nlmsg_type;
 	if (type > RTM_MAX)
@@ -887,7 +888,10 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (dumpit == NULL)
 			return -EOPNOTSUPP;
 
-		return netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
+		__rtnl_unlock();
+		err = netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
+		rtnl_lock();
+		return err;
 	}
 
 	memset(rta_buf, 0, (rtattr_max * sizeof(struct rtattr *)));
@@ -972,7 +976,7 @@ void __init rtnetlink_init(void)
 		panic("rtnetlink_init: cannot allocate rta_buf\n");
 
 	rtnl = netlink_kernel_create(NETLINK_ROUTE, RTNLGRP_MAX, rtnetlink_rcv,
-				     NULL, THIS_MODULE);
+				     &rtnl_mutex, THIS_MODULE);
 	if (rtnl == NULL)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
