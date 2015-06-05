From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net] mpls: fix possible use after free of device
Date: Fri, 5 Jun 2015 18:54:45 +0100
Message-ID: <1433526885-18861-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>, <ebiederm@xmission.com>,
	<roopa@cumulusnetworks.com>, Robert Shearman <rshearma@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:9494 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751055AbbFER5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 13:57:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mpls device is used in an RCU read context without a lock being
held. As the memory is freed without waiting for the RCU grace period
to elapse, the freed memory could still be in use.

Address this by using kfree_rcu to free the memory for the mpls device
after the RCU grace period has elapsed.

Fixes: 03c57747a702 ("mpls: Per-device MPLS state")
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c  | 2 +-
 net/mpls/internal.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 7b3f732269e4..bff427f31924 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -541,7 +541,7 @@ static void mpls_ifdown(struct net_device *dev)
 
 	RCU_INIT_POINTER(dev->mpls_ptr, NULL);
 
-	kfree(mdev);
+	kfree_rcu(mdev, rcu);
 }
 
 static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index b064c345042c..8cabeb5a1cb9 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -16,6 +16,7 @@ struct mpls_dev {
 	int			input_enabled;
 
 	struct ctl_table_header *sysctl;
+	struct rcu_head		rcu;
 };
 
 struct sk_buff;
-- 
2.1.4
