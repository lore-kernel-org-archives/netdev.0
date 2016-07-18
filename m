From: kan.liang@intel.com
Subject: [RFC PATCH 28/30] net/netpolicy: optimize for queue pair
Date: Sun, 17 Jul 2016 23:56:22 -0700
Message-ID: <1468824984-65318-29-git-send-email-kan.liang@intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:18996 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752082AbcGROXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 10:23:36 -0400
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Some drivers like i40e driver does not support separate tx and rx queues
as channels. Using rx queue to stand for the channels, if queue_pair is
set by driver.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 +++
 include/linux/netpolicy.h                   | 1 +
 net/core/netpolicy.c                        | 3 +++
 3 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d3f087d..f03d9f6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9009,6 +9009,9 @@ static int i40e_ndo_netpolicy_init(struct net_device *dev,
 	/* support MIX policy */
 	info->has_mix_policy = true;
 
+	/* support queue pair */
+	info->queue_pair = true;
+
 	return 0;
 }
 
diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index fa740b5..2de59a6 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -75,6 +75,7 @@ struct netpolicy_info {
 	enum netpolicy_name	cur_policy;
 	unsigned long avail_policy[BITS_TO_LONGS(NET_POLICY_MAX)];
 	bool	has_mix_policy;
+	bool	queue_pair;
 	/* cpu and queue mapping information */
 	struct netpolicy_sys_info	sys_info;
 	/* List of policy objects 0 rx 1 tx */
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index a63ccd4..83242d3 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -398,6 +398,9 @@ int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
 	    (current->task_netpolicy.policy != reg->policy))
 		return -EINVAL;
 
+	if (dev->netpolicy->queue_pair)
+		is_rx = true;
+
 	/* fast path */
 	read_lock(&np_sys_map_lock);
 	if (netpolicy_sys_map_version == reg->sys_map_version) {
-- 
2.5.5
