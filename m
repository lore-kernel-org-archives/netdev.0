From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/18] selinux: netlink: Move away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:35 -0700 (PDT)
Message-ID: <20120626.220235.1852400934147605470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab2F0FCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:36 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id A5EC4584191
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 security/selinux/netlink.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/security/selinux/netlink.c b/security/selinux/netlink.c
index 161e01a..8a23a35 100644
--- a/security/selinux/netlink.c
+++ b/security/selinux/netlink.c
@@ -19,6 +19,7 @@
 #include <linux/netlink.h>
 #include <linux/selinux_netlink.h>
 #include <net/net_namespace.h>
+#include <net/netlink.h>
 
 #include "security.h"
 
@@ -47,7 +48,7 @@ static void selnl_add_payload(struct nlmsghdr *nlh, int len, int msgtype, void *
 {
 	switch (msgtype) {
 	case SELNL_MSG_SETENFORCE: {
-		struct selnl_msg_setenforce *msg = NLMSG_DATA(nlh);
+		struct selnl_msg_setenforce *msg = nlmsg_data(nlh);
 
 		memset(msg, 0, len);
 		msg->val = *((int *)data);
@@ -55,7 +56,7 @@ static void selnl_add_payload(struct nlmsghdr *nlh, int len, int msgtype, void *
 	}
 
 	case SELNL_MSG_POLICYLOAD: {
-		struct selnl_msg_policyload *msg = NLMSG_DATA(nlh);
+		struct selnl_msg_policyload *msg = nlmsg_data(nlh);
 
 		memset(msg, 0, len);
 		msg->seqno = *((u32 *)data);
@@ -81,7 +82,9 @@ static void selnl_notify(int msgtype, void *data)
 		goto oom;
 
 	tmp = skb->tail;
-	nlh = NLMSG_PUT(skb, 0, 0, msgtype, len);
+	nlh = nlmsg_put(skb, 0, 0, msgtype, len, 0);
+	if (!nlh)
+		goto out_kfree_skb;
 	selnl_add_payload(nlh, len, msgtype, data);
 	nlh->nlmsg_len = skb->tail - tmp;
 	NETLINK_CB(skb).dst_group = SELNLGRP_AVC;
@@ -89,7 +92,7 @@ static void selnl_notify(int msgtype, void *data)
 out:
 	return;
 
-nlmsg_failure:
+out_kfree_skb:
 	kfree_skb(skb);
 oom:
 	printk(KERN_ERR "SELinux:  OOM in %s\n", __func__);
-- 
1.7.10.2
