From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] act_mirred: do not drop packets when fails to mirror it
Date: Wed, 15 Aug 2012 17:37:56 +0800
Message-ID: <20120815093756.22238.80872.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, jhs@mojatatu.com,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We drop packet unconditionally when we fail to mirror it. This is not intended
in some cases. Consdier for kvm guest, we may mirror the traffic of the bridge
to a tap device used by a VM. When kernel fails to mirror the packet in
conditions such as when qemu crashes or stop polling the tap, it's hard for the
management software to detect such condition and clean the the mirroring
before. This would lead all packets to the bridge to be dropped and break the
netowrk of other virtual machines.

To solve the issue, the patch does not drop packets when kernel fails to mirror
it, and only drop the redirected packets.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net/sched/act_mirred.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index fe81cc1..3682951 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -198,15 +198,12 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	err = dev_queue_xmit(skb2);
 
 out:
-	if (err) {
+	if (err)
 		m->tcf_qstats.overlimits++;
-		/* should we be asking for packet to be dropped?
-		 * may make sense for redirect case only
-		 */
+	if (err && m->tcf_action == TC_ACT_STOLEN)
 		retval = TC_ACT_SHOT;
-	} else {
+	else
 		retval = m->tcf_action;
-	}
 	spin_unlock(&m->tcf_lock);
 
 	return retval;
