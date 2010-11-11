From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-2.6 PATCH] nete zero kobject in rx_queue_release
Date: Thu, 11 Nov 2010 12:13:41 -0800
Message-ID: <20101111201341.4418.16400.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, therbert@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34765 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756071Ab0KKUQZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Nov 2010 15:16:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_set_real_num_rx_queues() can decrement and increment
the number of rx queues. For example ixgbe does this as
features and offloads are toggled. Presumably this could
also happen across down/up on most devices if the available
resources changed (cpu offlined).

The kobject needs to be zero'd in this case so that the
state is not preserved across kobject_put()/kobject_init_and_add().

This resolves the following error report.

ixgbe 0000:03:00.0: eth2: NIC Link is Up 10 Gbps, Flow Control: RX/TX
kobject (ffff880324b83210): tried to init an initialized object, something is seriously wrong.
Pid: 1972, comm: lldpad Not tainted 2.6.37-rc18021qaz+ #169
Call Trace:
 [<ffffffff8121c940>] kobject_init+0x3a/0x83
 [<ffffffff8121cf77>] kobject_init_and_add+0x23/0x57
 [<ffffffff8107b800>] ? mark_lock+0x21/0x267
 [<ffffffff813c6d11>] net_rx_queue_update_kobjects+0x63/0xc6
 [<ffffffff813b5e0e>] netif_set_real_num_rx_queues+0x5f/0x78
 [<ffffffffa0261d49>] ixgbe_set_num_queues+0x1c6/0x1ca [ixgbe]
 [<ffffffffa0262509>] ixgbe_init_interrupt_scheme+0x1e/0x79c [ixgbe]
 [<ffffffffa0274596>] ixgbe_dcbnl_set_state+0x167/0x189 [ixgbe]

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/net-sysfs.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index a5ff5a8..3315033 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -721,6 +721,11 @@ static void rx_queue_release(struct kobject *kobj)
 
 	if (atomic_dec_and_test(&first->count))
 		kfree(first);
+
+	/* cleanup kobject because we may need to reuse it if the
+	 * number of rx queues is increased again in the future
+	 */
+	memset(kobj, 0, sizeof(*kobj));
 }
 
 static struct kobj_type rx_queue_ktype = {

