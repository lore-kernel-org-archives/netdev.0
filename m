From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 09/11] xfrm: pass xfrm_user module to netlink_dump_start
Date: Wed, 26 Sep 2012 12:52:18 +0800
Message-ID: <1348635140-20225-9-git-send-email-gaofeng@cn.fujitsu.com>
References: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	pablo@netfilter.org, steffen.klassert@secunet.com,
	linux-crypto@vger.kernel.org, jengelh@inai.de,
	stephen.hemminger@vyatta.com, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:27694 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751853Ab2IZEwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 00:52:55 -0400
In-Reply-To: <1348635140-20225-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use proper netlink_dump_control.done and .module to avoid panic.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/xfrm/xfrm_user.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 289f4bf..fb6b06b 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -867,6 +867,7 @@ static int xfrm_dump_sa_done(struct netlink_callback *cb)
 {
 	struct xfrm_state_walk *walk = (struct xfrm_state_walk *) &cb->args[1];
 	xfrm_state_walk_done(walk);
+	netlink_dump_done(cb);
 	return 0;
 }
 
@@ -1538,6 +1539,7 @@ static int xfrm_dump_policy_done(struct netlink_callback *cb)
 	struct xfrm_policy_walk *walk = (struct xfrm_policy_walk *) &cb->args[1];
 
 	xfrm_policy_walk_done(walk);
+	netlink_dump_done(cb);
 	return 0;
 }
 
@@ -2308,17 +2310,20 @@ static struct xfrm_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct nlattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 	int (*done)(struct netlink_callback *);
+	struct module *module;
 } xfrm_dispatch[XFRM_NR_MSGTYPES] = {
 	[XFRM_MSG_NEWSA       - XFRM_MSG_BASE] = { .doit = xfrm_add_sa        },
 	[XFRM_MSG_DELSA       - XFRM_MSG_BASE] = { .doit = xfrm_del_sa        },
 	[XFRM_MSG_GETSA       - XFRM_MSG_BASE] = { .doit = xfrm_get_sa,
 						   .dump = xfrm_dump_sa,
-						   .done = xfrm_dump_sa_done  },
+						   .done = xfrm_dump_sa_done,
+						   .module = THIS_MODULE      },
 	[XFRM_MSG_NEWPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_add_policy    },
 	[XFRM_MSG_DELPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy    },
 	[XFRM_MSG_GETPOLICY   - XFRM_MSG_BASE] = { .doit = xfrm_get_policy,
 						   .dump = xfrm_dump_policy,
-						   .done = xfrm_dump_policy_done },
+						   .done = xfrm_dump_policy_done,
+						   .module = THIS_MODULE      },
 	[XFRM_MSG_ALLOCSPI    - XFRM_MSG_BASE] = { .doit = xfrm_alloc_userspi },
 	[XFRM_MSG_ACQUIRE     - XFRM_MSG_BASE] = { .doit = xfrm_add_acquire   },
 	[XFRM_MSG_EXPIRE      - XFRM_MSG_BASE] = { .doit = xfrm_add_sa_expire },
@@ -2362,6 +2367,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 			struct netlink_dump_control c = {
 				.dump = link->dump,
 				.done = link->done,
+				.module = link->module,
 			};
 			return netlink_dump_start(net->xfrm.nlsk, skb, nlh, &c);
 		}
-- 
1.7.7.6
