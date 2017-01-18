From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net 1/2] lwtunnel: Fix oops on state free after encap module unload
Date: Wed, 18 Jan 2017 15:32:02 +0000
Message-ID: <1484753523-26230-2-git-send-email-rshearma@brocade.com>
References: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Tom Herbert <tom@herbertland.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:38099 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751642AbdARPdx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 10:33:53 -0500
In-Reply-To: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
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

The problem is that we don't check for NULL ops in
lwtstate_free. Adding the check fixes the immediate problem but will
then won't properly clean up for ops that implement the
->destroy_state function if the implementing module has been unloaded,
resulting in memory leaks or other problems. So in addition, refcount
the module when the ops implements ->destroy_state so it can't be
unloaded while there is still state around.

Fixes: 1104d9ba443a ("lwtunnel: Add destroy state operation")
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 include/net/lwtunnel.h |  2 ++
 net/core/lwtunnel.c    | 11 +++++++++--
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index d4c1c75b8862..2b9993f33198 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -44,6 +44,8 @@ struct lwtunnel_encap_ops {
 	int (*get_encap_size)(struct lwtunnel_state *lwtstate);
 	int (*cmp_encap)(struct lwtunnel_state *a, struct lwtunnel_state *b);
 	int (*xmit)(struct sk_buff *skb);
+
+	struct module *owner;
 };
 
 #ifdef CONFIG_LWTUNNEL
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index a5d4e866ce88..3dc3cc3b38ec 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -126,8 +126,14 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 		}
 	}
 #endif
-	if (likely(ops && ops->build_state))
+	/* take module reference if destroy_state is in use */
+	if (unlikely(ops && ops->destroy_state && !try_module_get(ops->owner)))
+		ops = NULL;
+	if (likely(ops && ops->build_state)) {
 		ret = ops->build_state(dev, encap, family, cfg, lws);
+		if (ret && ops->destroy_state)
+			module_put(ops->owner);
+	}
 	rcu_read_unlock();
 
 	return ret;
@@ -138,9 +144,10 @@ void lwtstate_free(struct lwtunnel_state *lws)
 {
 	const struct lwtunnel_encap_ops *ops = lwtun_encaps[lws->type];
 
-	if (ops->destroy_state) {
+	if (ops && ops->destroy_state) {
 		ops->destroy_state(lws);
 		kfree_rcu(lws, rcu);
+		module_put(ops->owner);
 	} else {
 		kfree(lws);
 	}
-- 
2.1.4
