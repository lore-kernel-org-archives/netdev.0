From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCHv3] netem: Segment GSO packets on enqueue
Date: Fri, 29 Apr 2016 13:35:48 -0400
Message-ID: <1461951348-3920-1-git-send-email-nhorman@tuxdriver.com>
References: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	netem@lists.linux-foundation.org, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58496 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbcD2RgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 13:36:04 -0400
In-Reply-To: <1461692618-21333-1-git-send-email-nhorman@tuxdriver.com>
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
way we do in __dev_queue_xmit (via validate_xmit_skb), with some minor changes.
When we decide to corrupt an skb, if the frame is GSO, we segment it, corrupt
the first segment, and enqueue the remaining ones.

tested successfully by myself on the latest net kernel, to whcih this applies

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Jamal Hadi Salim <jhs@mojatatu.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: netem@lists.linux-foundation.org
CC: eric.dumazet@gmail.com

----
Change Notes:
V2) As per request from Eric Dumazet, I rewrote this to limit the need to
segment the skb. Instead of doing so unilaterally, we only do so now when
the netem qdisc requires determines that a packet must be corrupted, thus
avoidign the failure in skb_checksum_help.  This still leaves open concerns
wth statistical measurements made on GSO packets being dropped or reordered
(i.e. they are counted as a single packet rather than multiple packets), but
i'd rather fix the immediate problem before we go rewriting everything to fix
that larger issue

V3) Added back missing call to qdisc_tree_reduce_backlog that I misplaced in
the V2 change.
---
 net/sched/sch_netem.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 57 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 9640bb3..c4d8133 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -395,6 +395,25 @@ static void tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 	sch->q.qlen++;
 }
 
+/* netem can't properly corrupt a megapacket (like we get from GSO), so instead
+ * when we statistically choose to corrupt one, we instead segment it, returning
+ * the first packet to be corrupted, and re-enqueue the remaining frames
+ */
+static struct sk_buff* netem_segment(struct sk_buff *skb, struct Qdisc *sch)
+{
+	struct sk_buff *segs;
+	netdev_features_t features = netif_skb_features(skb);
+
+	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
+
+	if (IS_ERR_OR_NULL(segs)) {
+		qdisc_reshape_fail(skb, sch);
+		return NULL;
+	}
+	consume_skb(skb);
+	return segs;
+}
+
 /*
  * Insert one skb into qdisc.
  * Note: parent depends on return value to account for queue length.
@@ -407,7 +426,11 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	/* We don't fill cb now as skb_unshare() may invalidate it */
 	struct netem_skb_cb *cb;
 	struct sk_buff *skb2;
+	struct sk_buff *segs = NULL;
+	unsigned int len = 0, prev_len = qdisc_pkt_len(skb);
+	int nb = 0;
 	int count = 1;
+	int rc = NET_XMIT_SUCCESS;
 
 	/* Random duplication */
 	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
@@ -453,10 +476,22 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	 * do it now in software before we mangle it.
 	 */
 	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
+		if (skb_is_gso(skb)) {
+			segs = netem_segment(skb, sch);
+			if (!segs)
+				return NET_XMIT_DROP;
+		} else
+			segs = skb;
+
+		skb = segs;
+		segs = segs->next;
+
 		if (!(skb = skb_unshare(skb, GFP_ATOMIC)) ||
 		    (skb->ip_summed == CHECKSUM_PARTIAL &&
-		     skb_checksum_help(skb)))
-			return qdisc_drop(skb, sch);
+		     skb_checksum_help(skb))) {
+			rc = qdisc_drop(skb, sch);
+			goto finish_segs;
+		}
 
 		skb->data[prandom_u32() % skb_headlen(skb)] ^=
 			1<<(prandom_u32() % 8);
@@ -516,7 +551,26 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		sch->qstats.requeues++;
 	}
 
-	return NET_XMIT_SUCCESS;
+finish_segs:
+	if (segs) {
+		while (segs) {
+			skb2 = segs->next;
+			segs->next = NULL;
+			qdisc_skb_cb(segs)->pkt_len = segs->len;
+			len += segs->len;
+			rc = qdisc_enqueue(segs, sch);
+			if (rc != NET_XMIT_SUCCESS) {
+				if (net_xmit_drop_count(rc))
+					qdisc_qstats_drop(sch);
+			} else
+				nb++;
+			segs = skb2;
+		}
+		sch->q.qlen += nb;
+		if (nb > 1)
+			qdisc_tree_reduce_backlog(sch, 1 - nb, prev_len - len);
+	}
+	return rc;
 }
 
 static unsigned int netem_drop(struct Qdisc *sch)
-- 
2.5.5
