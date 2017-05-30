From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH 3/5] net: introduce XDP driver features
 interface
Date: Tue, 30 May 2017 11:58:06 +0200
Message-ID: <20170530115806.3086a009@redhat.com>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
        <149512210317.14733.15039298820296846614.stgit@firesoul>
        <591F27B9.9070003@iogearbox.net>
        <20170520095331.18c6be36@redhat.com>
        <5920E62B.3040201@iogearbox.net>
        <20170522164958.52fb3b3d@redhat.com>
        <59231AE0.8080409@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54266 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750904AbdE3J6O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 05:58:14 -0400
In-Reply-To: <59231AE0.8080409@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 22 May 2017 19:07:44 +0200 Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 05/22/2017 04:49 PM, Jesper Dangaard Brouer wrote:
> >
> > How do we move forward from here?  
> 
> If we introduce such feature bits one day, one possibility I see
> that more or less could work is to propagate this into tail call
> maps in a similar way like we do today with bpf_prog_array_compatible().
> Latter checks the prog type and whether a prog was jited, as both
> really cannot be mixed among each other.

I went down this path, of extending bpf_prog_array_compatible() and
traversing the tail call maps when the bpf_prog gets attached in the
XDP driver.  It is first at the XDP driver attachment point-in-time, the
features can be checked and locked down.

See patch below (on top of this RFC patchset).
Tested with:
 https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/samples/bpf
 bpf_tail_calls01_{kern,user}.c

> So, once you load the program, either we somehow need to tell the
> verifier upfront about our requirements, or the verifier detects
> them based on the programs that are loaded (not sure about this
> one though), 

IMHO "optional" features are *detected* by bpf verifier and filter.c
rewriter.  And "required" features are defined/detect/verified at NIC
driver level.  The user (XDP bpf programmer) do NOT supply "features".

> and besides prog, it needs to mark the tail call map
> with the same mask, such that any programs added later on to this
> tail call map are guaranteed to use the same set of features or
> just a subset of them. This also means that later updates cannot
> use features outside of this set anymore (even if the driver could
> support it). Then, the 'root' program which is to be attached to
> the device can check against the driver's capabilities eventually,
> since any program reachable from the root program would be guaranteed
> to not use features outside of this set.

I've also solved this one by storing the max supported features by the
driver, after validating that the "used" features passed the driver
check.  Thus, later runtime progs can still use all features supported
by the driver, even-though they were not "used" at XDO init/attach time.
 
> Still big question-mark wrt exposing these feature bits, and how
> the set would be determined eventually, e.g. the loader would somehow
> need to transparently calc the superset of features based on all
> progs residing in the object file, and then pass them into the kernel
> on prog load, where verifier checks them against the prog and if the
> prog makes use of the same set or a subset, then we mark it and related
> maps with the superset.

I've managed to keep the bpf side of the feature bits completely
flexible and not-exposed.  It is only the NIC drivers XDP_DRV_F_*
defines that gets exposed, which is what we want to easily "see" and
enforce what drivers (must) support.  For the bpf side, the bits can be
removed and recycled once a XDP_DRV_F_XXX feature moved to the required
set XDP_DRV_FEATURES_REQUIRED.

I've also managed to keep feature validation to "setup-time", thus no
additional runtime overhead is added for tail calls.


[PATCH RFC] bpf: handle XDP features for bpf tail calls

From: Jesper Dangaard Brouer <brouer@redhat.com>

XDP is challenging the bpf infrastructure assumption, that a
bpf_helper imply that a features is available to the bpf program.
This is no-longer true for XDP NIC drivers as the feature behind the
bpf_helper need to be implemented on a per driver basis.

Disregarding handling bpf tail calls, it is fairly easily to implement
and detect feature mismatch, via leveraging the bpf verifier and
ins-rewriter, who knows what helpers and direct access a given
bpf_prog are activating, as demonstrated in previous patches.

This patch handle tail calls (BPF_MAP_TYPE_PROG_ARRAY) by traversing
the tail call prog array, and collecting the features.

When attaching the XDP bpf_prog to a given XDP driver, the prog arrays
are traversed, and used features are verified against what the XDP
driver supports.  On success the supported NIC XDP features are locked
down (for the traversed bpf prog_array maps).  Later when runtime
adding bpf_prog's to the map, then features are checked.

The supported feature set is locked down to the maximum supported
features by the driver, to allow runtime adding tail calls that need
more features, but within drivers capabilities.

When adding a tail call, that itself have tail calls, the same
traversal verification is performed.  On success, these prog_array's
are also feature locked based on inheriting the supported features of
the array being inserted into.

At XDP driver attachment time, the bpf_prog have already been made
read-only.  Thus, the needed info are stored in struct bpf_array.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/bpf.h    |   26 ++++++
 include/linux/filter.h |    5 +
 kernel/bpf/core.c      |  226 +++++++++++++++++++++++++++++++++++++++++++++++-
 kernel/bpf/verifier.c  |    1 
 net/core/dev.c         |   18 ++--
 5 files changed, 262 insertions(+), 14 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 6bb38d76faf4..842409105925 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -167,6 +167,23 @@ struct bpf_verifier_ops {
 			union bpf_attr __user *uattr);
 };
 
+/* These bpf_feature bits are 100% internal to the bpf infrastructure
+ * They mirror some of the bpf_prog bits, related to features.  Over
+ * time these features bits will get removed when the subsystem using
+ * them, like XDP, will support the feature from all call points
+ * (e.g. XDP drivers).
+ */
+struct bpf_features {
+	union {
+		struct {
+			u32	cb_access:1,
+				xdp_rxhash_needed:1;
+		};
+		u32	flags;
+	};
+};
+typedef u32	bpf_features_t;
+
 struct bpf_prog_aux {
 	atomic_t refcnt;
 	u32 used_map_cnt;
@@ -193,6 +210,15 @@ struct bpf_array {
 	 */
 	enum bpf_prog_type owner_prog_type;
 	bool owner_jited;
+
+	/* Restrict features allowed */
+	bpf_features_t features_supported;
+	bool features_locked;
+
+	/* Members needed when traversing prog_array tail calls */
+	struct list_head traversed_node;
+	bool is_traversed;
+
 	union {
 		char value[0] __aligned(8);
 		void *ptrs[0] __aligned(8);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 33a254ccd47d..113914b7ac28 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -641,6 +641,11 @@ static inline int sk_filter(struct sock *sk, struct sk_buff *skb)
 	return sk_filter_trim_cap(sk, skb, 1);
 }
 
+netdev_features_t bpf_get_xdp_features(struct bpf_prog *xdp_prog);
+bool bpf_lock_xdp_features(struct bpf_prog *prog,
+			   netdev_features_t xdp_approved_f,
+			   netdev_features_t xdp_dev_support_f);
+
 struct bpf_prog *bpf_prog_select_runtime(struct bpf_prog *fp, int *err);
 void bpf_prog_free(struct bpf_prog *fp);
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 6f81e0f5a0fa..d3dbce365993 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1224,21 +1224,241 @@ static unsigned int __bpf_prog_run(void *ctx, const struct bpf_insn *insn)
 }
 STACK_FRAME_NON_STANDARD(__bpf_prog_run); /* jump table */
 
+/* convert bpf_prog bits into bpf_features bits */
+static bpf_features_t __bpf_prog_to_features(const struct bpf_prog *prog)
+{
+	struct bpf_features f = { 0 };
+
+	if (prog->cb_access)
+		f.cb_access = 1;
+
+	if (prog->xdp_rxhash_needed)
+		f.xdp_rxhash_needed = 1;
+
+	return f.flags;
+}
+
+/* convert bpf_features bits into net_device xdp_features */
+static netdev_features_t __bpf_features_to_xdp_features(bpf_features_t f)
+{
+	netdev_features_t features = XDP_DRV_FEATURES_REQUIRED;
+	struct bpf_features bf;
+
+	bf.flags = f;
+	if (bf.xdp_rxhash_needed)
+		features |= XDP_DRV_F_RXHASH;
+
+	return features;
+}
+
+/* Extend bpf_features with extra features based on xdp_features input */
+bpf_features_t __bpf_features_extend_from_xdp_features(bpf_features_t bpf_f,
+						       netdev_features_t xdp_f)
+{
+	struct bpf_features bf;
+
+	bf.flags = bpf_f;
+	if (xdp_f & XDP_DRV_F_RXHASH)
+		bf.xdp_rxhash_needed = 1;
+
+	return bf.flags;
+}
+
+static DEFINE_MUTEX(prog_array_traversal_mutex);
+static LIST_HEAD(prog_array_traversal_q);
+
+static bpf_features_t
+__bpf_features_via_prog_array(const struct bpf_prog *top_prog,
+			      bpf_features_t features)
+{
+	struct bpf_prog_aux *aux = top_prog->aux;
+	int i;
+
+	/* First extract features from bpf_prog's in known prog_array's */
+	for (i = 0; i < aux->used_map_cnt; i++) {
+		struct bpf_map *map = aux->used_maps[i];
+		struct bpf_array *array;
+		int j;
+
+		/* Walk all prog_array's */
+		if (map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
+			continue;
+		array = container_of(map, struct bpf_array, map);
+
+		/* Look at features in each active bpf_prog in prog_array */
+		for (j = 0; j < array->map.max_entries; j++) {
+			const struct bpf_prog *prog;
+
+			prog = array->ptrs[j];
+			if (!prog)
+				continue;
+
+			features |= __bpf_prog_to_features(prog);
+		}
+	}
+
+	/* Now recursive visit bpf_prog's for containing prog_array's */
+	for (i = 0; i < aux->used_map_cnt; i++) {
+		struct bpf_map *map = aux->used_maps[i];
+		struct bpf_array *array;
+		int j;
+
+		/* Walk all prog_array's again */
+		if (map->map_type != BPF_MAP_TYPE_PROG_ARRAY)
+			continue;
+		array = container_of(map, struct bpf_array, map);
+
+		/* Avoid traversal loops and record prog_array's */
+		if (array->is_traversed)
+			continue;
+		array->is_traversed = true;
+		list_add_tail(&array->traversed_node, &prog_array_traversal_q);
+
+		/* Recurse into bpf_prog in prog_array */
+		for (j = 0; j < array->map.max_entries; j++) {
+			const struct bpf_prog *p;
+
+			p = array->ptrs[j];
+			if (!p)
+				continue;
+
+			features |= __bpf_features_via_prog_array(p, features);
+		}
+	}
+
+	return features;
+}
+
+/* Find superset of features traversing tail call maps */
+static bpf_features_t bpf_features_via_prog_array(const struct bpf_prog *prog,
+						  bpf_features_t features)
+{
+	struct bpf_array *prog_array, *tmp;
+
+	features |= __bpf_features_via_prog_array(prog, features);
+	list_for_each_entry_safe(prog_array, tmp, &prog_array_traversal_q,
+				 traversed_node)
+	{
+		list_del(&prog_array->traversed_node);
+		prog_array->is_traversed = false;
+	}
+
+	return features;
+}
+
+netdev_features_t bpf_get_xdp_features(struct bpf_prog *prog)
+{
+	bpf_features_t bpf_features;
+
+	mutex_lock(&prog_array_traversal_mutex);
+	bpf_features = __bpf_prog_to_features(prog);
+	bpf_features = bpf_features_via_prog_array(prog, bpf_features);
+	mutex_unlock(&prog_array_traversal_mutex);
+
+	return __bpf_features_to_xdp_features(bpf_features);
+}
+
+/* Caller have checked xdp features are approved */
+bool bpf_lock_xdp_features(struct bpf_prog *prog,
+			   netdev_features_t xdp_approved_f,
+			   netdev_features_t xdp_dev_support_f)
+{
+	struct bpf_array *prog_array, *tmp;
+	netdev_features_t xdp_f_in_use;
+	bpf_features_t bpf_f_in_use;
+	bool lock_features = true;
+	bpf_features_t max;
+
+	mutex_lock(&prog_array_traversal_mutex);
+
+	/* Get and detect if bpf_features changed */
+	bpf_f_in_use  = __bpf_prog_to_features(prog);
+	bpf_f_in_use |= __bpf_features_via_prog_array(prog, bpf_f_in_use);
+	xdp_f_in_use  = __bpf_features_to_xdp_features(bpf_f_in_use);
+	if (xdp_f_in_use != xdp_approved_f)
+		lock_features = false;
+
+	/* XDP driver might support more features than in-use, allow
+	 * later added bpf_prog's to still use-these extra features
+	 */
+	max = __bpf_features_extend_from_xdp_features(bpf_f_in_use,
+						      xdp_dev_support_f);
+	list_for_each_entry_safe(prog_array, tmp, &prog_array_traversal_q,
+				 traversed_node)
+	{
+		list_del(&prog_array->traversed_node);
+		prog_array->is_traversed = false;
+		if (lock_features) {
+			/* Handle when already locked by another driver.
+			 * Find smallest common feature set (via simple AND)
+			 */
+			if (prog_array->features_locked)
+				prog_array->features_supported &= max;
+			else
+				prog_array->features_supported = max;
+			prog_array->features_locked = true;
+		}
+	}
+	mutex_unlock(&prog_array_traversal_mutex);
+	return lock_features;
+}
+
 bool bpf_prog_array_compatible(struct bpf_array *array,
 			       const struct bpf_prog *fp)
 {
+	bool compat = false;
+
+	mutex_lock(&prog_array_traversal_mutex);
+
 	if (!array->owner_prog_type) {
 		/* There's no owner yet where we could check for
 		 * compatibility.
 		 */
 		array->owner_prog_type = fp->type;
 		array->owner_jited = fp->jited;
+		array->features_locked = false;
+		array->is_traversed = false;
+		compat = true;
+		goto out;
+	}
+
+	/* Features can be locked, e.g. when XDP prog is attach to net_device */
+	if (array->features_locked)
+	{
+		bpf_features_t f = __bpf_prog_to_features(fp);
+		struct bpf_array *pa, *tmp;
+		bpf_features_t max;
 
-		return true;
+		f |= __bpf_features_via_prog_array(fp, f);
+
+		/* Detect any feature bit set, which is not supported */
+		if (f & ~(array->features_supported)) {
+			compat = false;
+			goto out;
+		}
+		/* If fp contained tail call's itself, they need to be
+		 * locked down, to this array->features_supported.
+		 */
+		max = array->features_supported;
+		list_for_each_entry_safe(pa, tmp, &prog_array_traversal_q,
+					 traversed_node)
+		{
+			list_del(&pa->traversed_node);
+			pa->is_traversed = false;
+			/* Handle when already locked by another driver */
+			if (pa->features_locked)
+				pa->features_supported &= max;
+			else
+				pa->features_supported = max;
+			pa->features_locked = true;
+		}
 	}
 
-	return array->owner_prog_type == fp->type &&
-	       array->owner_jited == fp->jited;
+	compat = (array->owner_prog_type == fp->type &&
+		  array->owner_jited == fp->jited);
+out:
+	mutex_unlock(&prog_array_traversal_mutex);
+	return compat;
 }
 
 static int bpf_check_tail_call(const struct bpf_prog *fp)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 248bc113ad18..df9d08a79ac6 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3355,7 +3355,6 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			 * the program array.
 			 */
 			prog->cb_access = 1;
-			prog->xdp_rxhash_needed = 1;
 
 			/* mark bpf_tail_call as different opcode to avoid
 			 * conditional branch in the interpeter for every normal
diff --git a/net/core/dev.c b/net/core/dev.c
index 28082067ac00..b45e8114b84c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6855,16 +6855,6 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
-netdev_features_t bpf_get_xdp_features(struct bpf_prog *prog)
-{
-	netdev_features_t features = XDP_DRV_FEATURES_REQUIRED;
-
-	if (prog->xdp_rxhash_needed)
-		features |= XDP_DRV_F_RXHASH;
-
-	return features;
-}
-
 bool xdp_features_check(struct net_device *dev, struct bpf_prog *xdp_prog,
 			struct netlink_ext_ack *extack, u32 flags)
 {
@@ -6881,6 +6871,14 @@ bool xdp_features_check(struct net_device *dev, struct bpf_prog *xdp_prog,
 			       "Required XDP feature not supported by device");
 		return false;
 	}
+	/* Ask BPF infra to limit runtime added bpf_prog's (tail calls)
+	 * to features supported by XDP driver.
+	 */
+	if (!bpf_lock_xdp_features(xdp_prog, req_features, dev_xdp_features)) {
+		NL_SET_ERR_MSG(extack,
+			"Couldn't lock XDP features supported by device");
+		return false;
+	}
 	return true;
 }
 


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
