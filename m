From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH] net: correct error path in rtnl_newlink()
Date: Tue, 11 Feb 2014 15:51:30 -0800
Message-ID: <1392162690-6647-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:59630 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbaBKXvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 18:51:45 -0500
Received: by mail-pb0-f54.google.com with SMTP id uo5so8433337pbc.13
        for <netdev@vger.kernel.org>; Tue, 11 Feb 2014 15:51:44 -0800 (PST)
In-Reply-To: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

I saw the following BUG when ->newlink() fails in rtnl_newlink():

[   40.240058] kernel BUG at net/core/dev.c:6438!

this is due to free_netdev() is not supposed to be called before
netdev is completely unregistered, therefore it is not correct
to call free_netdev() here, at least for ops->newlink!=NULL case,
many drivers call it in ->destructor so that rtnl_unlock() will
take care of it, we probably don't need to do anything here.

Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 net/core/rtnetlink.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 048dc8d..1a0dac2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1963,16 +1963,21 @@ replay:
 
 		dev->ifindex = ifm->ifi_index;
 
-		if (ops->newlink)
+		if (ops->newlink) {
 			err = ops->newlink(net, dev, tb, data);
-		else
+			/* Drivers should call free_netdev() in ->destructor
+			 * and unregister it on failure so that device could be
+			 * finally freed in rtnl_unlock.
+			 */
+			if (err < 0)
+				goto out;
+		} else {
 			err = register_netdevice(dev);
-
-		if (err < 0) {
-			free_netdev(dev);
-			goto out;
+			if (err < 0) {
+				free_netdev(dev);
+				goto out;
+			}
 		}
-
 		err = rtnl_configure_link(dev, ifm);
 		if (err < 0)
 			unregister_netdevice(dev);
-- 
1.8.3.1
