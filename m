From: Jason Wang <jasowang@redhat.com>
Subject: [net V2] act_mirred: do not drop packets when fails to mirror it
Date: Thu, 16 Aug 2012 14:44:27 +0800
Message-ID: <1345099467-40922-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: jhs@mojatatu.com, netdev@vger.kernel.org,
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

Changes from v1:
- Check with TCA_EGRESS_MIRROR instead of TC_ACT_STOLEN per Jamal's comment

 net/sched/act_mirred.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index fe81cc1..9c0fd0c 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -200,13 +200,12 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 out:
 	if (err) {
 		m->tcf_qstats.overlimits++;
-		/* should we be asking for packet to be dropped?
-		 * may make sense for redirect case only
-		 */
-		retval = TC_ACT_SHOT;
-	} else {
+		if (m->tcfm_eaction != TCA_EGRESS_MIRROR)
+			retval = TC_ACT_SHOT;
+		else
+			retval = m->tcf_action;
+	} else
 		retval = m->tcf_action;
-	}
 	spin_unlock(&m->tcf_lock);
 
 	return retval;
-- 
1.7.1
