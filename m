From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2] net: sched: convert qdisc linked list to hashtable
Date: Fri, 12 Aug 2016 14:52:58 +0200
Message-ID: <57ADC6AA.5070506@iogearbox.net>
References: <alpine.LNX.2.00.1608101049260.22028@cbobk.fhfr.pm> <alpine.LNX.2.00.1608101054320.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1608101054320.22028@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

On 08/10/2016 11:05 AM, Jiri Kosina wrote:
> From: Jiri Kosina <jkosina@suse.cz>
>
> Convert the per-device linked list into a hashtable. The primary
> motivation for this change is that currently, we're not tracking all the
> qdiscs in hierarchy (e.g. excluding default qdiscs), as the lookup
> performed over the linked list by qdisc_match_from_root() is rather
> expensive.
>
> The ultimate goal is to get rid of hidden qdiscs completely, which will
> bring much more determinism in user experience.
>
> Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

This results in below panic. Tested reverting this patch and it fixes
the panic.

Did you test this also with ingress or clsact qdisc (just try adding
it to lo dev for example) ?

What happens is the following in qdisc_match_from_root():

[  995.422187] XXX qdisc:ffff88025e4fc800 queue:ffff880262759000 dev:ffff880261cc2000 handle:ffff0000
[  995.422200] XXX qdisc:ffffffff81cf8100 queue:ffffffff81cf8240 dev:          (null) handle:ffff0000

I believe this is due to dev_ingress_queue_create() assigning the
global noop_qdisc instance as qdisc_sleeping, which later qdisc_lookup()
uses for qdisc_match_from_root().

But everything that uses things like noop_qdisc cannot work with the
new qdisc_match_from_root(), because qdisc_dev(root) will always trigger
NULL pointer dereference there. Reason is because the dev is always
NULL for noop, it's a singleton, see noop_qdisc and noop_netdev_queue
in sch_generic.c.

Now how to fix it? Creating separate noop instances each time it's set
would be quite a waste of memory. Even fuglier would be to hack a static
net device struct into sch_generic.c and let noop_netdev_queue point there
to get to the hash table. Or we just not use qdisc_dev().

I've tried the below to hand in dev pointer instead of qdisc_dev(), but
I think this is not sound yet. Despite fixing the panic, I get something
weird like:

# tc qdisc show dev wlp2s0b1
qdisc mq 0: root
qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc clsact ffff: parent ffff:fff1
qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1

Not yet sure whether this below, really quickly hacked patch is just buggy
(I guess so) or it's another side effect of the original patch.

If you have some cycles to take a look into fixing the panic, would be great.

Thanks

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 25aada7..c2c9799 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -256,7 +256,8 @@ int qdisc_set_default(const char *name)
   * Note: caller either uses rtnl or rcu_read_lock()
   */

-static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
+static struct Qdisc *qdisc_match_from_root(struct net_device *dev,
+					   struct Qdisc *root, u32 handle)
  {
  	struct Qdisc *q;

@@ -264,7 +265,7 @@ static struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
  	    root->handle == handle)
  		return root;

-	hash_for_each_possible_rcu(qdisc_dev(root)->qdisc_hash, q, hash, handle) {
+	hash_for_each_possible_rcu(dev->qdisc_hash, q, hash, handle) {
  		if (q->handle == handle)
  			return q;
  	}
@@ -296,12 +297,12 @@ struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
  {
  	struct Qdisc *q;

-	q = qdisc_match_from_root(dev->qdisc, handle);
+	q = qdisc_match_from_root(dev, dev->qdisc, handle);
  	if (q)
  		goto out;

  	if (dev_ingress_queue(dev))
-		q = qdisc_match_from_root(
+		q = qdisc_match_from_root(dev,
  			dev_ingress_queue(dev)->qdisc_sleeping,
  			handle);
  out:
@@ -1430,8 +1431,8 @@ err_out:
  	return -EINVAL;
  }

-static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
-			      struct netlink_callback *cb,
+static int tc_dump_qdisc_root(struct net_device *dev, struct Qdisc *root,
+			      struct sk_buff *skb, struct netlink_callback *cb,
  			      int *q_idx_p, int s_q_idx)
  {
  	int ret = 0, q_idx = *q_idx_p;
@@ -1451,7 +1452,7 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
  			goto done;
  		q_idx++;
  	}
-	hash_for_each(qdisc_dev(root)->qdisc_hash, b, q, hash) {
+	hash_for_each(dev->qdisc_hash, b, q, hash) {
  		if (q_idx < s_q_idx) {
  			q_idx++;
  			continue;
@@ -1492,12 +1493,12 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
  			s_q_idx = 0;
  		q_idx = 0;

-		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx) < 0)
+		if (tc_dump_qdisc_root(dev, dev->qdisc, skb, cb, &q_idx, s_q_idx) < 0)
  			goto done;

  		dev_queue = dev_ingress_queue(dev);
  		if (dev_queue &&
-		    tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb,
+		    tc_dump_qdisc_root(dev, dev_queue->qdisc_sleeping, skb, cb,
  				       &q_idx, s_q_idx) < 0)
  			goto done;

@@ -1762,9 +1763,9 @@ static int tc_dump_tclass_qdisc(struct Qdisc *q, struct sk_buff *skb,
  	return 0;
  }

-static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
-			       struct tcmsg *tcm, struct netlink_callback *cb,
-			       int *t_p, int s_t)
+static int tc_dump_tclass_root(struct net_device *dev, struct Qdisc *root,
+			       struct sk_buff *skb, struct tcmsg *tcm,
+			       struct netlink_callback *cb, int *t_p, int s_t)
  {
  	struct Qdisc *q;
  	int b;
@@ -1775,7 +1776,7 @@ static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb,
  	if (tc_dump_tclass_qdisc(root, skb, tcm, cb, t_p, s_t) < 0)
  		return -1;

-	hash_for_each(qdisc_dev(root)->qdisc_hash, b, q, hash) {
+	hash_for_each(dev->qdisc_hash, b, q, hash) {
  		if (tc_dump_tclass_qdisc(q, skb, tcm, cb, t_p, s_t) < 0)
  			return -1;
  	}
@@ -1800,12 +1801,12 @@ static int tc_dump_tclass(struct sk_buff *skb, struct netlink_callback *cb)
  	s_t = cb->args[0];
  	t = 0;

-	if (tc_dump_tclass_root(dev->qdisc, skb, tcm, cb, &t, s_t) < 0)
+	if (tc_dump_tclass_root(dev, dev->qdisc, skb, tcm, cb, &t, s_t) < 0)
  		goto done;

  	dev_queue = dev_ingress_queue(dev);
  	if (dev_queue &&
-	    tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb,
+	    tc_dump_tclass_root(dev, dev_queue->qdisc_sleeping, skb, tcm, cb,
  				&t, s_t) < 0)
  		goto done;

Panic output:

[ 1243.459280] BUG: unable to handle kernel NULL pointer dereference at 0000000000000410
[ 1243.459430] IP: [<ffffffff8167efac>] qdisc_match_from_root+0x2c/0x70
[ 1243.459528] PGD 1aceba067 PUD 1aceb7067 PMD 0
[ 1243.459604] Oops: 0000 [#1] PREEMPT SMP
[ 1243.459659] Modules linked in: ccm br_netfilter bridge stp llc dm_thin_pool dm_persistent_data dm_bio_prison libcrc32c loop xt_tcpudp ip6t_rpfilter ip6t_REJECT nf_reject_ipv6 ipt_REJECT nf_reject_ipv4 xt_conntrack ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 arc4 brcmsmac nf_nat nf_conntrack cordic brcmutil iptable_mangle b43 iptable_security iptable_raw iptable_filter ip_tables x_tables mac80211 bnep cfg80211 snd_hda_codec_hdmi snd_hda_codec_cirrus snd_hda_codec_generic ssb snd_hda_intel snd_hda_codec x86_pkg_temp_thermal coretemp kvm_intel btusb mmc_core kvm btrtl btbcm snd_hda_core btintel uvcvideo bluetooth nls_utf8 snd_hwdep hfsplus snd_seq
  videobuf2_vmalloc
[ 1243.476357]  videobuf2_memops iTCO_wdt videobuf2_v4l2 iTCO_vendor_support videobuf2_core videodev snd_seq_device bcma irqbypass snd_pcm crc32_pclmul crc32c_intel applesmc input_polldev ghash_clmulni_intel pcspkr nfsd i2c_i801 lpc_ich rfkill bcm5974 media mfd_core i2c_smbus joydev snd_timer snd mei_me auth_rpcgss sbs mei tpm_tis sbshc nfs_acl tpm_tis_core lockd tpm apple_bl soundcore grace sunrpc i915 i2c_algo_bit drm_kms_helper drm i2c_core video
[ 1243.494439] CPU: 2 PID: 2223 Comm: tc Not tainted 4.7.0+ #1181
[ 1243.499015] Hardware name: Apple Inc. MacBookAir5,1/Mac-66F35F19FE2A0D05, BIOS MBA51.88Z.00EF.B02.1211271028 11/27/2012
[ 1243.503630] task: ffff8801ec996e00 task.stack: ffff8801ec934000
[ 1243.508311] RIP: 0010:[<ffffffff8167efac>]  [<ffffffff8167efac>] qdisc_match_from_root+0x2c/0x70
[ 1243.513207] RSP: 0018:ffff8801ec937ab0  EFLAGS: 00010203
[ 1243.518053] RAX: 0000000000000408 RBX: ffff88025e612000 RCX: ffffffffffffffd8
[ 1243.522893] RDX: 0000000000000000 RSI: 00000000ffff0000 RDI: ffffffff81cf8100
[ 1243.527598] RBP: ffff8801ec937ab0 R08: 000000000001c160 R09: ffff8802668032c0
[ 1243.532378] R10: ffffffff81cf8100 R11: 0000000000000030 R12: 00000000ffff0000
[ 1243.537221] R13: ffff88025e612000 R14: ffffffff81cf3140 R15: 0000000000000000
[ 1243.542051] FS:  00007f24b9af6740(0000) GS:ffff88026f280000(0000) knlGS:0000000000000000
[ 1243.542059] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1243.542062] CR2: 0000000000000410 CR3: 00000001aceec000 CR4: 00000000001406e0
[ 1243.542064] Stack:
[ 1243.542075]  ffff8801ec937ad0 ffffffff81681210 ffff88025dd51a00 00000000fffffff1
[ 1243.542082]  ffff8801ec937b88 ffffffff81681e4e ffffffff81c42bc0 ffff880262431500
[ 1243.542090]  ffffffff81cf3140 ffff88025dd51a10 ffff88025dd51a24 00000000ec937b38
[ 1243.542092] Call Trace:
[ 1243.542104]  [<ffffffff81681210>] qdisc_lookup+0x40/0x50
[ 1243.542113]  [<ffffffff81681e4e>] tc_modify_qdisc+0x21e/0x550
[ 1243.542125]  [<ffffffff8166ae25>] rtnetlink_rcv_msg+0x95/0x220
[ 1243.542136]  [<ffffffff81209602>] ? __kmalloc_track_caller+0x172/0x230
[ 1243.542144]  [<ffffffff8166ad90>] ? rtnl_newlink+0x870/0x870
[ 1243.542151]  [<ffffffff816897b7>] netlink_rcv_skb+0xa7/0xc0
[ 1243.542158]  [<ffffffff816657c8>] rtnetlink_rcv+0x28/0x30
[ 1243.542164]  [<ffffffff8168919b>] netlink_unicast+0x15b/0x210
[ 1243.542170]  [<ffffffff81689569>] netlink_sendmsg+0x319/0x390
[ 1243.542180]  [<ffffffff816379f8>] sock_sendmsg+0x38/0x50
[ 1243.542187]  [<ffffffff81638296>] ___sys_sendmsg+0x256/0x260
[ 1243.542197]  [<ffffffff811b1275>] ? __pagevec_lru_add_fn+0x135/0x280
[ 1243.542206]  [<ffffffff811b1a90>] ? pagevec_lru_move_fn+0xd0/0xf0
[ 1243.542214]  [<ffffffff811b1140>] ? trace_event_raw_event_mm_lru_insertion+0x180/0x180
[ 1243.542222]  [<ffffffff811b1b85>] ? __lru_cache_add+0x75/0xb0
[ 1243.542230]  [<ffffffff817708a6>] ? _raw_spin_unlock+0x16/0x40
[ 1243.542237]  [<ffffffff811d8dff>] ? handle_mm_fault+0x39f/0x1160
[ 1243.542245]  [<ffffffff81638b15>] __sys_sendmsg+0x45/0x80
[ 1243.542254]  [<ffffffff81638b62>] SyS_sendmsg+0x12/0x20
[ 1243.542261]  [<ffffffff810038e7>] do_syscall_64+0x57/0xb0
[ 1243.542268]  [<ffffffff81770fa1>] entry_SYSCALL64_slow_path+0x25/0x25
[ 1243.542357] Code: 1f 44 00 00 f6 47 10 01 55 48 89 e5 75 05 39 77 38 74 48 48 8b 57 48 69 c6 47 86 c8 61 48 8b 12 c1 e8 1c 48 8d 84 c2 d0 03 00 00 <48> 8b 50 08 31 c0 48 8d 4a d8 48 85 d2 48 0f 45 c1 eb 04 48 83
[ 1243.542366] RIP  [<ffffffff8167efac>] qdisc_match_from_root+0x2c/0x70
[ 1243.542368]  RSP <ffff8801ec937ab0>
[ 1243.542370] CR2: 0000000000000410
[ 1243.565166] ---[ end trace aee041a86366c4d4 ]---
