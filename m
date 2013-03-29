From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] net: rtnetlink: fdb dflt dump must set idx used
 for cb->arg[0]
Date: Fri, 29 Mar 2013 11:18:37 -0700
Message-ID: <20130329181831.9902.70451.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f173.google.com ([209.85.160.173]:62956 "EHLO
	mail-gh0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756016Ab3C2TTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:19:45 -0400
Received: by mail-gh0-f173.google.com with SMTP id g16so65353ghb.4
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 12:19:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rtnl_fdb_dump() when the fdb_dump ndo op is not populated
we never set the idx value so that cb->arg[0] is always 0.
Resulting in a endless loop of messages.

Introduced with this commit,

commit 090096bf3db1c281ddd034573260045888a68fea
Author: Vlad Yasevich <vyasevic@redhat.com>
Date:   Wed Mar 6 15:39:42 2013 +0000

    net: generic fdb support for drivers without ndo_fdb_<op>

CC: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/core/rtnetlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 6fdfac8..d2322d7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2262,7 +2262,7 @@ skip:
  * @dev: netdevice
  *
  * Default netdevice operation to dump the existing unicast address list.
- * Returns zero on success.
+ * Returns number of addresses from list put in skb.
  */
 int ndo_dflt_fdb_dump(struct sk_buff *skb,
 		      struct netlink_callback *cb,
@@ -2303,7 +2303,7 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		if (dev->netdev_ops->ndo_fdb_dump)
 			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, idx);
 		else
-			ndo_dflt_fdb_dump(skb, cb, dev, idx);
+			idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
 	}
 	rcu_read_unlock();
 
