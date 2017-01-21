From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net v2 2/2] lwtunnel: Fix oops on state free after encap module unload
Date: Sat, 21 Jan 2017 00:21:26 +0000
Message-ID: <1484958086-6151-3-git-send-email-rshearma@brocade.com>
References: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
 <1484958086-6151-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Lebrun <david.lebrun@uclouvain.be>,
        "Thomas Graf" <tgraf@suug.ch>,
        David Ahern <dsa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:33156 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752244AbdAUAXR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:23:17 -0500
In-Reply-To: <1484958086-6151-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When attempting to free lwtunnel state after the module for the encap
has been unloaded an oops occurs:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: lwtstate_free+0x18/0x40
[..]
task: ffff88003e372380 task.stack: ffffc900001fc000
RIP: 0010:lwtstate_free+0x18/0x40
RSP: 0018:ffff88003fd83e88 EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffff88002bbb3380 RCX: ffff88000c91a300
[..]
Call Trace:
 <IRQ>
 free_fib_info_rcu+0x195/0x1a0
 ? rt_fibinfo_free+0x50/0x50
 rcu_process_callbacks+0x2d3/0x850
 ? rcu_process_callbacks+0x296/0x850
 __do_softirq+0xe4/0x4cb
 irq_exit+0xb0/0xc0
 smp_apic_timer_interrupt+0x3d/0x50
 apic_timer_interrupt+0x93/0xa0
[..]
Code: e8 6e c6 fc ff 89 d8 5b 5d c3 bb de ff ff ff eb f4 66 90 66 66 66 66 90 55 48 89 e5 53 0f b7 07 48 89 fb 48 8b 04 c5 00 81 d5 81 <48> 8b 40 08 48 85 c0 74 13 ff d0 48 8d 7b 20 be 20 00 00 00 e8

The problem is after the module for the encap is unloaded the
corresponding ops is removed and thus is NULL here.

Modules implementing lwtunnel ops should not be allowed to unload
while there is state alive using those ops, so grab the module
reference for the ops on creating lwtunnel state and of course release
the reference when freeing the state.

Fixes: 1104d9ba443a ("lwtunnel: Add destroy state operation")
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/core/lwtunnel.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 47b1dd65947b..ebfaffaa777b 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -115,8 +115,12 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 	ret = -EOPNOTSUPP;
 	rcu_read_lock();
 	ops = rcu_dereference(lwtun_encaps[encap_type]);
-	if (likely(ops && ops->build_state))
-		ret = ops->build_state(dev, encap, family, cfg, lws);
+	if (likely(ops)) {
+		if (likely(try_module_get(ops->owner) && ops->build_state))
+			ret = ops->build_state(dev, encap, family, cfg, lws);
+		if (ret)
+			module_put(ops->owner);
+	}
 	rcu_read_unlock();
 
 	return ret;
@@ -194,6 +198,7 @@ void lwtstate_free(struct lwtunnel_state *lws)
 	} else {
 		kfree(lws);
 	}
+	module_put(ops->owner);
 }
 EXPORT_SYMBOL(lwtstate_free);
 
-- 
2.1.4
