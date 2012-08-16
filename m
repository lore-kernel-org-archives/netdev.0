From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/9] tipc: fix lockdep warning during bearer initialization
Date: Thu, 16 Aug 2012 18:09:07 -0400
Message-ID: <1345154954-12526-3-git-send-email-paul.gortmaker@windriver.com>
References: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57481 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752661Ab2HPWOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 18:14:49 -0400
In-Reply-To: <1345154954-12526-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

When the lockdep validator is enabled, it will report the below
warning when we enable a TIPC bearer:

[ INFO: possible irq lock inversion dependency detected ]
---------------------------------------------------------
Possible interrupt unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(ptype_lock);
                                local_irq_disable();
                                lock(tipc_net_lock);
                                lock(ptype_lock);
   <Interrupt>
   lock(tipc_net_lock);

  *** DEADLOCK ***

the shortest dependencies between 2nd lock and 1st lock:
  -> (ptype_lock){+.+...} ops: 10 {
[...]
SOFTIRQ-ON-W at:
                      [<c1089418>] __lock_acquire+0x528/0x13e0
                      [<c108a360>] lock_acquire+0x90/0x100
                      [<c1553c38>] _raw_spin_lock+0x38/0x50
                      [<c14651ca>] dev_add_pack+0x3a/0x60
                      [<c182da75>] arp_init+0x1a/0x48
                      [<c182dce5>] inet_init+0x181/0x27e
                      [<c1001114>] do_one_initcall+0x34/0x170
                      [<c17f7329>] kernel_init+0x110/0x1b2
                      [<c155b6a2>] kernel_thread_helper+0x6/0x10
[...]
   ... key      at: [<c17e4b10>] ptype_lock+0x10/0x20
   ... acquired at:
    [<c108a360>] lock_acquire+0x90/0x100
    [<c1553c38>] _raw_spin_lock+0x38/0x50
    [<c14651ca>] dev_add_pack+0x3a/0x60
    [<c8bc18d2>] enable_bearer+0xf2/0x140 [tipc]
    [<c8bb283a>] tipc_enable_bearer+0x1ba/0x450 [tipc]
    [<c8bb3a04>] tipc_cfg_do_cmd+0x5c4/0x830 [tipc]
    [<c8bbc032>] handle_cmd+0x42/0xd0 [tipc]
    [<c148e802>] genl_rcv_msg+0x232/0x280
    [<c148d3f6>] netlink_rcv_skb+0x86/0xb0
    [<c148e5bc>] genl_rcv+0x1c/0x30
    [<c148d144>] netlink_unicast+0x174/0x1f0
    [<c148ddab>] netlink_sendmsg+0x1eb/0x2d0
    [<c1456bc1>] sock_aio_write+0x161/0x170
    [<c1135a7c>] do_sync_write+0xac/0xf0
    [<c11360f6>] vfs_write+0x156/0x170
    [<c11361e2>] sys_write+0x42/0x70
    [<c155b0df>] sysenter_do_call+0x12/0x38
[...]
}
  -> (tipc_net_lock){+..-..} ops: 4 {
[...]
    IN-SOFTIRQ-R at:
                     [<c108953a>] __lock_acquire+0x64a/0x13e0
                     [<c108a360>] lock_acquire+0x90/0x100
                     [<c15541cd>] _raw_read_lock_bh+0x3d/0x50
                     [<c8bb874d>] tipc_recv_msg+0x1d/0x830 [tipc]
                     [<c8bc195f>] recv_msg+0x3f/0x50 [tipc]
                     [<c146a5fa>] __netif_receive_skb+0x22a/0x590
                     [<c146ab0b>] netif_receive_skb+0x2b/0xf0
                     [<c13c43d2>] pcnet32_poll+0x292/0x780
                     [<c146b00a>] net_rx_action+0xfa/0x1e0
                     [<c103a4be>] __do_softirq+0xae/0x1e0
[...]
}

>From the log, we can see three different call chains between
CPU0 and CPU1:

Time 0 on CPU0:

  kernel_init()->inet_init()->dev_add_pack()

At time 0, the ptype_lock is held by CPU0 in dev_add_pack();

Time 1 on CPU1:

  tipc_enable_bearer()->enable_bearer()->dev_add_pack()

At time 1, tipc_enable_bearer() first holds tipc_net_lock, and then
wants to take ptype_lock to register TIPC protocol handler into the
networking stack.  But the ptype_lock has been taken by dev_add_pack()
on CPU0, so at this time the dev_add_pack() running on CPU1 has to be
busy looping.

Time 2 on CPU0:

  netif_receive_skb()->recv_msg()->tipc_recv_msg()

At time 2, an incoming TIPC packet arrives at CPU0, hence
tipc_recv_msg() will be invoked. In tipc_recv_msg(), it first wants
to hold tipc_net_lock.  At the moment, below scenario happens:

On CPU0, below is our sequence of taking locks:

  lock(ptype_lock)->lock(tipc_net_lock)

On CPU1, our sequence of taking locks looks like:

  lock(tipc_net_lock)->lock(ptype_lock)

Obviously deadlock may happen in this case.

But please note the deadlock possibly doesn't occur at all when the
first TIPC bearer is enabled.  Before enable_bearer() -- running on
CPU1 does not hold ptype_lock, so the TIPC receive handler (i.e.
recv_msg()) is not registered successfully via dev_add_pack(), so
the tipc_recv_msg() cannot be called by recv_msg() even if a TIPC
message comes to CPU0. But when the second TIPC bearer is
registered, the deadlock can perhaps really happen.

To fix it, we will push the work of registering TIPC protocol
handler into workqueue context. After the change, both paths taking
ptype_lock are always in process contexts, thus, the deadlock should
never occur.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/eth_media.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 0f312c2..2132c1e 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -46,12 +46,14 @@
  * @bearer: ptr to associated "generic" bearer structure
  * @dev: ptr to associated Ethernet network device
  * @tipc_packet_type: used in binding TIPC to Ethernet driver
+ * @setup: work item used when enabling bearer
  * @cleanup: work item used when disabling bearer
  */
 struct eth_bearer {
 	struct tipc_bearer *bearer;
 	struct net_device *dev;
 	struct packet_type tipc_packet_type;
+	struct work_struct setup;
 	struct work_struct cleanup;
 };
 
@@ -143,6 +145,17 @@ static int recv_msg(struct sk_buff *buf, struct net_device *dev,
 }
 
 /**
+ * setup_bearer - setup association between Ethernet bearer and interface
+ */
+static void setup_bearer(struct work_struct *work)
+{
+	struct eth_bearer *eb_ptr =
+		container_of(work, struct eth_bearer, setup);
+
+	dev_add_pack(&eb_ptr->tipc_packet_type);
+}
+
+/**
  * enable_bearer - attach TIPC bearer to an Ethernet interface
  */
 static int enable_bearer(struct tipc_bearer *tb_ptr)
@@ -182,7 +195,8 @@ static int enable_bearer(struct tipc_bearer *tb_ptr)
 	eb_ptr->tipc_packet_type.func = recv_msg;
 	eb_ptr->tipc_packet_type.af_packet_priv = eb_ptr;
 	INIT_LIST_HEAD(&(eb_ptr->tipc_packet_type.list));
-	dev_add_pack(&eb_ptr->tipc_packet_type);
+	INIT_WORK(&eb_ptr->setup, setup_bearer);
+	schedule_work(&eb_ptr->setup);
 
 	/* Associate TIPC bearer with Ethernet bearer */
 	eb_ptr->bearer = tb_ptr;
-- 
1.7.11.1
