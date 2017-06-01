From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH] xfrm: fix xfrm_dev_event() missing when compile without CONFIG_XFRM_OFFLOAD
Date: Thu,  1 Jun 2017 08:38:22 +0800
Message-ID: <1496277502-10642-1-git-send-email-liuhangbin@gmail.com>
Cc: Guy Shapiro <guysh@mellanox.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        David Miller <davem@davemloft.net>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35434 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdFAAi4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 20:38:56 -0400
Received: by mail-pf0-f195.google.com with SMTP id u26so5119309pfd.2
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 17:38:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API") we
make xfrm_device.o only compiled when enable option CONFIG_XFRM_OFFLOAD.
But this will make xfrm_dev_event() missing if we only enable default XFRM
options.

So when we set down and unregister an interface with IPsec on it. there
will no xfrm_garbage_collect(), which will cause dev usage count hold and
get error like:

unregister_netdevice: waiting for <dev> to become free. Usage count = 4

Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 net/xfrm/Makefile      | 3 +--
 net/xfrm/xfrm_device.c | 2 ++
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index abf81b3..55b2ac3 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -4,8 +4,7 @@
 
 obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
 		      xfrm_input.o xfrm_output.o \
-		      xfrm_sysctl.o xfrm_replay.o
-obj-$(CONFIG_XFRM_OFFLOAD) += xfrm_device.o
+		      xfrm_sysctl.o xfrm_replay.o xfrm_device.o
 obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
 obj-$(CONFIG_XFRM_ALGO) += xfrm_algo.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 574e6f3..5aba036 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -22,6 +22,7 @@
 #include <net/xfrm.h>
 #include <linux/notifier.h>
 
+#ifdef CONFIG_XFRM_OFFLOAD
 int validate_xmit_xfrm(struct sk_buff *skb, netdev_features_t features)
 {
 	int err;
@@ -137,6 +138,7 @@ bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
 	return true;
 }
 EXPORT_SYMBOL_GPL(xfrm_dev_offload_ok);
+#endif
 
 int xfrm_dev_register(struct net_device *dev)
 {
-- 
2.5.5
