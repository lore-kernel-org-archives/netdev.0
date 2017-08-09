From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next] rtnelink: Move link dump consistency check out of the loop
Date: Wed,  9 Aug 2017 17:39:12 +0200
Message-ID: <20170809153912.19733-1-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:34268 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752467AbdHIPjP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 11:39:15 -0400
Received: by mail-wr0-f171.google.com with SMTP id c24so19818552wra.1
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 08:39:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calls to rtnl_dump_ifinfo() are protected by RTNL lock. So are the
{list,unlist}_netdevice() calls where we bump the net->dev_base_seq
number.

For this reason net->dev_base_seq can't change under out feet while
we're looping over links in rtnl_dump_ifinfo(). So move the check for
net->dev_base_seq change (since the last time we were called) out of the
loop.

This way we avoid giving a wrong impression that there are concurrent
updates to the link list going on while we're iterating over them.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 net/core/rtnetlink.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9201e36..6b7888e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1644,8 +1644,6 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
 
-	cb->seq = net->dev_base_seq;
-
 	/* A hack to preserve kernel<->userspace interface.
 	 * The correct header is ifinfomsg. It is consistent with rtnl_getlink.
 	 * However, before Linux v3.9 the code here assumed rtgenmsg and that's
@@ -1691,8 +1689,6 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 
 				goto out_err;
 			}
-
-			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 cont:
 			idx++;
 		}
@@ -1702,6 +1698,8 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 out_err:
 	cb->args[1] = idx;
 	cb->args[0] = h;
+	cb->seq = net->dev_base_seq;
+	nl_dump_check_consistent(cb, nlmsg_hdr(skb));
 
 	return err;
 }
-- 
2.9.4
