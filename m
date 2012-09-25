From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] inet_diag: fix panic when unload inet_diag
Date: Tue, 25 Sep 2012 10:48:30 +0800
Message-ID: <1348541310-31913-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: stephen.hemminger@vyatta.com, jengelh@inai.de,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:11493 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752407Ab2IYDAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 23:00:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when inet_diag being compiled as module, inet_diag_handler_dump
set netlink_dump_control.dump to inet_diag_dump,so if module
inet_diag is unloaded,netlink will still try to call this function
in netlink_dump. this will cause kernel panic.

fix this by adding a reference of inet_diag module before
setting netlink_callback, and release this reference in
netlink_callback.done.

Thanks for all help from Stephen,Jan and Eric.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/inet_diag.c |   46 ++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 570e61f..e573090 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -903,6 +903,12 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return __inet_diag_dump(skb, cb, nlmsg_data(cb->nlh), bc);
 }
 
+static int inet_diag_done(struct netlink_callback *cb)
+{
+	module_put(THIS_MODULE);
+	return 0;
+}
+
 static inline int inet_diag_type2proto(int type)
 {
 	switch (type) {
@@ -972,8 +978,26 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 		{
 			struct netlink_dump_control c = {
 				.dump = inet_diag_dump_compat,
+				.done = inet_diag_done,
 			};
-			return netlink_dump_start(net->diag_nlsk, skb, nlh, &c);
+			int err;
+			/*
+			 * netlink_dump will call inet_diag_dump_compat,
+			 * so we need a reference of THIS_MODULE.
+			 */
+			if (!try_module_get(THIS_MODULE))
+				return -EPROTONOSUPPORT;
+
+			err = netlink_dump_start(net->diag_nlsk, skb, nlh, &c);
+
+			if ((err != -EINTR) && (err != -ENOBUFS)) {
+				/*
+				 * netlink_callback set failed, release the
+				 * referenct of THIS_MODULE.
+				 */
+				module_put(THIS_MODULE);
+			}
+			return err;
 		}
 	}
 
@@ -1001,8 +1025,26 @@ static int inet_diag_handler_dump(struct sk_buff *skb, struct nlmsghdr *h)
 		{
 			struct netlink_dump_control c = {
 				.dump = inet_diag_dump,
+				.done = inet_diag_done,
 			};
-			return netlink_dump_start(net->diag_nlsk, skb, h, &c);
+			int err;
+			/*
+			 * netlink_dump will call inet_diag_dump,
+			 * so we need a reference of THIS_MODULE.
+			 */
+			if (!try_module_get(THIS_MODULE))
+				return -EPROTONOSUPPORT;
+
+			err = netlink_dump_start(net->diag_nlsk, skb, h, &c);
+
+			if ((err != -EINTR) && (err != -ENOBUFS)) {
+				/*
+				 * netlink_callback set failed, release the
+				 * referenct of THIS_MODULE.
+				 */
+				module_put(THIS_MODULE);
+			}
+			return err;
 		}
 	}
 
-- 
1.7.7
