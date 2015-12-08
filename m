From: kan.liang@intel.com
Subject: [RFC 1/2] net/ethtool: Add new coalescing parameter for queue
Date: Tue,  8 Dec 2015 04:42:29 +0000
Message-ID: <1449549750-12448-1-git-send-email-kan.liang@intel.com>
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, Kan Liang <kan.liang@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net, bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46536 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933530AbbLHQYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 11:24:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Intrdouce "queue" option for coalesce getting and setting.
For coalesce getting, only the coalescing parameters from specific
queue will be passed to user space.
For coalesce setting, the coalescing parameters will only be applied to
specific queue.
If the queue is set to -1, the coalescing parameters will apply to all
queues.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/uapi/linux/ethtool.h | 2 ++
 net/core/ethtool.c           | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index cd16291..f4fc18b 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -384,6 +384,7 @@ struct ethtool_modinfo {
  *	a TX interrupt, when the packet rate is above @pkt_rate_high.
  * @rate_sample_interval: How often to do adaptive coalescing packet rate
  *	sampling, measured in seconds.  Must not be zero.
+ * @queue: The specific queue which coalescing parameters apply to.
  *
  * Each pair of (usecs, max_frames) fields specifies that interrupts
  * should be coalesced until
@@ -434,6 +435,7 @@ struct ethtool_coalesce {
 	__u32	tx_coalesce_usecs_high;
 	__u32	tx_max_coalesced_frames_high;
 	__u32	rate_sample_interval;
+	__s32	queue;
 };
 
 /**
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 29edf74..fa8ab7a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1123,10 +1123,16 @@ static noinline_for_stack int ethtool_get_coalesce(struct net_device *dev,
 						   void __user *useraddr)
 {
 	struct ethtool_coalesce coalesce = { .cmd = ETHTOOL_GCOALESCE };
+	struct ethtool_coalesce tmp = { .queue = -1 };
 
 	if (!dev->ethtool_ops->get_coalesce)
 		return -EOPNOTSUPP;
 
+	if (copy_from_user(&tmp, useraddr, sizeof(coalesce)))
+		return -EFAULT;
+
+	coalesce.queue = tmp.queue;
+
 	dev->ethtool_ops->get_coalesce(dev, &coalesce);
 
 	if (copy_to_user(useraddr, &coalesce, sizeof(coalesce)))
-- 
1.7.11.7
