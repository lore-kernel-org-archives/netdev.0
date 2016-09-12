From: kan.liang@intel.com
Subject: [RFC V3 PATCH 24/26] net/netpolicy: optimize for queue pair
Date: Mon, 12 Sep 2016 07:55:57 -0700
Message-ID: <1473692159-4017-25-git-send-email-kan.liang@intel.com>
References: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
        peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net,
        akpm@linux-foundation.org, keescook@chromium.org,
        viro@zeniv.linux.org.uk, gorcunov@openvz.org,
        john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
        decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
        daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
        xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
        stephen@networkplumber.org, alexei.starovoitov@gmail.com,
        jesse.brandeburg@intel.com, andi@firstfloor.org,
        Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37125 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759457AbcILO4v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 10:56:51 -0400
In-Reply-To: <1473692159-4017-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>

Some drivers like i40e driver does not support separate Tx and Rx queues
as channels. Using Rx queue to stand for the channels, if queue_pair is
set by driver.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h | 1 +
 net/core/netpolicy.c      | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index 88f4f60..9b03b4d 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -83,6 +83,7 @@ struct netpolicy_info {
 	unsigned long avail_policy[BITS_TO_LONGS(NET_POLICY_MAX)];
 	bool irq_affinity;
 	bool has_mix_policy;
+	bool queue_pair;
 	/* cpu and queue mapping information */
 	struct netpolicy_sys_info	sys_info;
 	/* List of policy objects 0 rx 1 tx */
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 2f55a14..84503a4 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -538,6 +538,9 @@ int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx)
 	if (!policy_validate(instance))
 		return -EINVAL;
 
+	if (dev->netpolicy->queue_pair)
+		is_rx = true;
+
 	/* fast path */
 	rcu_read_lock();
 	version = rcu_dereference(dev->netpolicy->sys_info.version)->major;
-- 
2.5.5
