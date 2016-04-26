From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] netem: Segment GSO packets on enqueue.
Date: Tue, 26 Apr 2016 13:43:38 -0400
Message-ID: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60379 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890AbcDZRoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 13:44:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was recently reported to me, and reproduced on the latest net kernel, when
attempting to run netperf from a host that had a netem qdisc attached to the
egress interface:

[  788.073771] ------------[ cut here ]------------
[  788.096716] WARNING: at net/core/dev.c:2253 skb_warn_bad_offload+0xcd/0xda()
[  788.129521] bnx2: caps=(0x00000001801949b3, 0x0000000000000000) len=2962
data_len=0 gso_size=1448 gso_type=1 ip_summed=3
[  788.182150] Modules linked in: sch_netem kvm_amd kvm crc32_pclmul ipmi_ssif
ghash_clmulni_intel sp5100_tco amd64_edac_mod aesni_intel lrw gf128mul
glue_helper ablk_helper edac_mce_amd cryptd pcspkr sg edac_core hpilo ipmi_si
i2c_piix4 k10temp fam15h_power hpwdt ipmi_msghandler shpchp acpi_power_meter
pcc_cpufreq nfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_tables xfs libcrc32c
sd_mod crc_t10dif crct10dif_generic mgag200 syscopyarea sysfillrect sysimgblt
i2c_algo_bit drm_kms_helper ahci ata_generic pata_acpi ttm libahci
crct10dif_pclmul pata_atiixp tg3 libata crct10dif_common drm crc32c_intel ptp
serio_raw bnx2 r8169 hpsa pps_core i2c_core mii dm_mirror dm_region_hash dm_log
dm_mod
[  788.465294] CPU: 16 PID: 0 Comm: swapper/16 Tainted: G        W
------------   3.10.0-327.el7.x86_64 #1
[  788.511521] Hardware name: HP ProLiant DL385p Gen8, BIOS A28 12/17/2012
[  788.542260]  ffff880437c036b8 f7afc56532a53db9 ffff880437c03670
ffffffff816351f1
[  788.576332]  ffff880437c036a8 ffffffff8107b200 ffff880633e74200
ffff880231674000
[  788.611943]  0000000000000001 0000000000000003 0000000000000000
ffff880437c03710
[  788.647241] Call Trace:
[  788.658817]  <IRQ>  [<ffffffff816351f1>] dump_stack+0x19/0x1b
[  788.686193]  [<ffffffff8107b200>] warn_slowpath_common+0x70/0xb0
[  788.713803]  [<ffffffff8107b29c>] warn_slowpath_fmt+0x5c/0x80
[  788.741314]  [<ffffffff812f92f3>] ? ___ratelimit+0x93/0x100
[  788.767018]  [<ffffffff81637f49>] skb_warn_bad_offload+0xcd/0xda
[  788.796117]  [<ffffffff8152950c>] skb_checksum_help+0x17c/0x190
[  788.823392]  [<ffffffffa01463a1>] netem_enqueue+0x741/0x7c0 [sch_netem]
[  788.854487]  [<ffffffff8152cb58>] dev_queue_xmit+0x2a8/0x570
[  788.880870]  [<ffffffff8156ae1d>] ip_finish_output+0x53d/0x7d0
...

The problem occurs because netem is not prepared to handle GSO packets (as it
uses skb_checksum_help in its enqueue path, which cannot manipulate these
frames).

The solution I think is to simply segment the skb in a simmilar fashion to the
way we do in __dev_queue_xmit (via validate_xmit_skb), except here we always
segment, instead of only when the interface needs us to do it.  This allows
netem to properly drop/mangle/pass/etc the correct percentages of frames as per
its qdisc configuration, and avoid failing its checksum operations

tested successfully by myself on the latest net kernel, to whcih this applies

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Jamal Hadi Salim <jhs@mojatatu.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: netem@lists.linux-foundation.org
---
 net/sched/sch_netem.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 9640bb3..c9feecb 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -401,7 +401,7 @@ static void tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
  * 	NET_XMIT_DROP: queue length didn't change.
  *      NET_XMIT_SUCCESS: one skb was queued.
  */
-static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+static int __netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
 	/* We don't fill cb now as skb_unshare() may invalidate it */
@@ -519,6 +519,38 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_SUCCESS;
 }
 
+static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct sk_buff *segs;
+	struct sk_buff *next;
+	int rc = NET_XMIT_SUCCESS;
+
+	if (skb_is_gso(skb)) {
+		segs = skb_gso_segment(skb, 0);
+		kfree_skb(skb);
+		if (IS_ERR(segs)) {
+			qdisc_qstats_drop(sch);
+			return NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
+		}
+		skb = segs;
+	}
+
+	while (skb) {
+		next = skb->next;
+		skb->next = NULL;
+		if (rc == NET_XMIT_SUCCESS)
+			rc = __netem_enqueue(skb, sch);
+		else {
+			qdisc_qstats_drop(sch);
+			kfree_skb(skb);
+		}
+
+		skb = next;
+	}
+
+	return rc;
+}
+
 static unsigned int netem_drop(struct Qdisc *sch)
 {
 	struct netem_sched_data *q = qdisc_priv(sch);
-- 
2.5.5
