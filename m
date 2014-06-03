From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] rtnetlink: fix a memory leak when ->newlink fails
Date: Tue,  3 Jun 2014 16:40:47 -0700
Message-ID: <1401838847-5982-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:51263 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932164AbaFCXlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 19:41:04 -0400
Received: by mail-pd0-f180.google.com with SMTP id y13so5281319pdi.11
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 16:41:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

It is possible that ->newlink() fails before registering
the device, in this case we should just free it, it's
safe to call free_netdev().

Fixes: commit 0e0eee2465df77bcec2 (net: correct error path in rtnl_newlink())
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/rtnetlink.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2d8d8fc..f4e9037 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2019,11 +2019,15 @@ replay:
 		if (ops->newlink) {
 			err = ops->newlink(net, dev, tb, data);
 			/* Drivers should call free_netdev() in ->destructor
-			 * and unregister it on failure so that device could be
-			 * finally freed in rtnl_unlock.
+			 * and unregister it on failure after registration
+			 * so that device could be finally freed in rtnl_unlock.
 			 */
-			if (err < 0)
+			if (err < 0) {
+				/* If device is not registered at all, free it now */
+				if (dev->reg_state == NETREG_UNINITIALIZED)
+					free_netdev(dev);
 				goto out;
+			}
 		} else {
 			err = register_netdevice(dev);
 			if (err < 0) {
-- 
1.8.3.1
