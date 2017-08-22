From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH net-next 2/4] bpf/verifier: remove
 varlen_map_value_access flag
Date: Tue, 22 Aug 2017 14:26:40 +0100
Message-ID: <6174b732-0bf9-19a3-09c4-f6a62be24a0c@solarflare.com>
References: <f25f46bd-27cb-2182-2551-2887757c1e0f@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <f25f46bd-27cb-2182-2551-2887757c1e0f-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

The optimisation it does is broken when the 'new' register value has a
 variable offset and the 'old' was constant.  I broke it with my pointer
 types unification (see Fixes tag below), before which the 'new' value
 would have type PTR_TO_MAP_VALUE_ADJ and would thus not compare equal;
 other changes in that patch mean that its original behaviour (ignore
 min/max values) cannot be restored.
Tests on a sample set of cilium programs show no change in count of
 processed instructions.

Fixes: f1174f77b50c ("bpf/verifier: rework value tracking")
Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 include/linux/bpf_verifier.h |  1 -
 kernel/bpf/verifier.c        | 41 ++++++++++++-----------------------------
 2 files changed, 12 insertions(+), 30 deletions(-)

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 91d07ef..d8f131a 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -125,7 +125,6 @@ struct bpf_verifier_env {
 	u32 id_gen;			/* used to generate unique reg IDs */
 	bool allow_ptr_leaks;
 	bool seen_direct_write;
-	bool varlen_map_value_access;
 	struct bpf_insn_aux_data *insn_aux_data; /* array of per-insn state */
 };
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index e42c096..1e3f56c 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -832,11 +832,6 @@ static int check_map_access(struct bpf_verifier_env *env, u32 regno,
 	 */
 	if (log_level)
 		print_verifier_state(state);
-	/* If the offset is variable, we will need to be stricter in state
-	 * pruning from now on.
-	 */
-	if (!tnum_is_const(reg->var_off))
-		env->varlen_map_value_access = true;
 	/* The minimum value is only important with signed
 	 * comparisons where we can't assume the floor of a
 	 * value is 0.  If we are using signed variables for our
@@ -3247,9 +3242,8 @@ static bool check_ids(u32 old_id, u32 cur_id, struct idpair *idmap)
 }
 
 /* Returns true if (rold safe implies rcur safe) */
-static bool regsafe(struct bpf_reg_state *rold,
-		    struct bpf_reg_state *rcur,
-		    bool varlen_map_access, struct idpair *idmap)
+static bool regsafe(struct bpf_reg_state *rold, struct bpf_reg_state *rcur,
+		    struct idpair *idmap)
 {
 	if (!(rold->live & REG_LIVE_READ))
 		/* explored state didn't use this */
@@ -3281,22 +3275,14 @@ static bool regsafe(struct bpf_reg_state *rold,
 			       tnum_is_unknown(rold->var_off);
 		}
 	case PTR_TO_MAP_VALUE:
-		if (varlen_map_access) {
-			/* If the new min/max/var_off satisfy the old ones and
-			 * everything else matches, we are OK.
-			 * We don't care about the 'id' value, because nothing
-			 * uses it for PTR_TO_MAP_VALUE (only for ..._OR_NULL)
-			 */
-			return memcmp(rold, rcur, offsetof(struct bpf_reg_state, id)) == 0 &&
-			       range_within(rold, rcur) &&
-			       tnum_in(rold->var_off, rcur->var_off);
-		} else {
-			/* If the ranges/var_off were not the same, but
-			 * everything else was and we didn't do a variable
-			 * access into a map then we are a-ok.
-			 */
-			return memcmp(rold, rcur, offsetof(struct bpf_reg_state, id)) == 0;
-		}
+		/* If the new min/max/var_off satisfy the old ones and
+		 * everything else matches, we are OK.
+		 * We don't care about the 'id' value, because nothing
+		 * uses it for PTR_TO_MAP_VALUE (only for ..._OR_NULL)
+		 */
+		return memcmp(rold, rcur, offsetof(struct bpf_reg_state, id)) == 0 &&
+		       range_within(rold, rcur) &&
+		       tnum_in(rold->var_off, rcur->var_off);
 	case PTR_TO_MAP_VALUE_OR_NULL:
 		/* a PTR_TO_MAP_VALUE could be safe to use as a
 		 * PTR_TO_MAP_VALUE_OR_NULL into the same map.
@@ -3380,7 +3366,6 @@ static bool states_equal(struct bpf_verifier_env *env,
 			 struct bpf_verifier_state *old,
 			 struct bpf_verifier_state *cur)
 {
-	bool varlen_map_access = env->varlen_map_value_access;
 	struct idpair *idmap;
 	bool ret = false;
 	int i;
@@ -3391,8 +3376,7 @@ static bool states_equal(struct bpf_verifier_env *env,
 		return false;
 
 	for (i = 0; i < MAX_BPF_REG; i++) {
-		if (!regsafe(&old->regs[i], &cur->regs[i], varlen_map_access,
-			     idmap))
+		if (!regsafe(&old->regs[i], &cur->regs[i], idmap))
 			goto out_free;
 	}
 
@@ -3412,7 +3396,7 @@ static bool states_equal(struct bpf_verifier_env *env,
 			continue;
 		if (!regsafe(&old->spilled_regs[i / BPF_REG_SIZE],
 			     &cur->spilled_regs[i / BPF_REG_SIZE],
-			     varlen_map_access, idmap))
+			     idmap))
 			/* when explored and current stack slot are both storing
 			 * spilled registers, check that stored pointers types
 			 * are the same as well.
@@ -3550,7 +3534,6 @@ static int do_check(struct bpf_verifier_env *env)
 	init_reg_state(regs);
 	state->parent = NULL;
 	insn_idx = 0;
-	env->varlen_map_value_access = false;
 	for (;;) {
 		struct bpf_insn *insn;
 		u8 class;
