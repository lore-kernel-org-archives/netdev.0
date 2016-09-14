From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 13/22] bpf/cgroup: Replace struct bpf_prog with union bpf_object
Date: Wed, 14 Sep 2016 09:24:06 +0200
Message-ID: <20160914072415.26021-14-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>, kernel-hardening@lists.openwall.com,
        linux-api@vger.kernel.org, linux-security-module@vger.
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4599-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This allows CONFIG_CGROUP_BPF to manage different type of pointers
instead of only eBPF programs. This will be useful for the next commits
to support Landlock with cgroups.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Mack <daniel@zonque.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/bpf-cgroup.h |  8 ++++++--
 kernel/bpf/cgroup.c        | 44 +++++++++++++++++++++++---------------------
 2 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index fc076de74ab9..2234042d7f61 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -14,14 +14,18 @@ struct sk_buff;
 extern struct static_key_false cgroup_bpf_enabled_key;
 #define cgroup_bpf_enabled static_branch_unlikely(&cgroup_bpf_enabled_key)
 
+union bpf_object {
+	struct bpf_prog *prog;
+};
+
 struct cgroup_bpf {
 	/*
 	 * Store two sets of bpf_prog pointers, one for programs that are
 	 * pinned directly to this cgroup, and one for those that are effective
 	 * when this cgroup is accessed.
 	 */
-	struct bpf_prog *prog[MAX_BPF_ATTACH_TYPE];
-	struct bpf_prog *effective[MAX_BPF_ATTACH_TYPE];
+	union bpf_object pinned[MAX_BPF_ATTACH_TYPE];
+	union bpf_object effective[MAX_BPF_ATTACH_TYPE];
 };
 
 void cgroup_bpf_put(struct cgroup *cgrp);
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index 21d168c3ad35..782878ec4f2d 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -20,18 +20,18 @@ DEFINE_STATIC_KEY_FALSE(cgroup_bpf_enabled_key);
 EXPORT_SYMBOL(cgroup_bpf_enabled_key);
 
 /**
- * cgroup_bpf_put() - put references of all bpf programs
+ * cgroup_bpf_put() - put references of all bpf objects
  * @cgrp: the cgroup to modify
  */
 void cgroup_bpf_put(struct cgroup *cgrp)
 {
 	unsigned int type;
 
-	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.prog); type++) {
-		struct bpf_prog *prog = cgrp->bpf.prog[type];
+	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.pinned); type++) {
+		union bpf_object pinned = cgrp->bpf.pinned[type];
 
-		if (prog) {
-			bpf_prog_put(prog);
+		if (pinned.prog) {
+			bpf_prog_put(pinned.prog);
 			static_branch_dec(&cgroup_bpf_enabled_key);
 		}
 	}
@@ -47,11 +47,12 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
 	unsigned int type;
 
 	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.effective); type++) {
-		struct bpf_prog *e;
+		union bpf_object e;
 
-		e = rcu_dereference_protected(parent->bpf.effective[type],
-					      lockdep_is_held(&cgroup_mutex));
-		rcu_assign_pointer(cgrp->bpf.effective[type], e);
+		e.prog = rcu_dereference_protected(
+				parent->bpf.effective[type].prog,
+				lockdep_is_held(&cgroup_mutex));
+		rcu_assign_pointer(cgrp->bpf.effective[type].prog, e.prog);
 	}
 }
 
@@ -87,32 +88,33 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
 			 struct bpf_prog *prog,
 			 enum bpf_attach_type type)
 {
-	struct bpf_prog *old_prog, *effective;
+	union bpf_object obj, old_pinned, effective;
 	struct cgroup_subsys_state *pos;
 
-	old_prog = xchg(cgrp->bpf.prog + type, prog);
+	obj.prog = prog;
+	old_pinned = xchg(cgrp->bpf.pinned + type, obj);
 
-	effective = (!prog && parent) ?
-		rcu_dereference_protected(parent->bpf.effective[type],
+	effective.prog = (!obj.prog && parent) ?
+		rcu_dereference_protected(parent->bpf.effective[type].prog,
 					  lockdep_is_held(&cgroup_mutex)) :
-		prog;
+		obj.prog;
 
 	css_for_each_descendant_pre(pos, &cgrp->self) {
 		struct cgroup *desc = container_of(pos, struct cgroup, self);
 
 		/* skip the subtree if the descendant has its own program */
-		if (desc->bpf.prog[type] && desc != cgrp)
+		if (desc->bpf.pinned[type].prog && desc != cgrp)
 			pos = css_rightmost_descendant(pos);
 		else
-			rcu_assign_pointer(desc->bpf.effective[type],
-					   effective);
+			rcu_assign_pointer(desc->bpf.effective[type].prog,
+					   effective.prog);
 	}
 
-	if (prog)
+	if (obj.prog)
 		static_branch_inc(&cgroup_bpf_enabled_key);
 
-	if (old_prog) {
-		bpf_prog_put(old_prog);
+	if (old_pinned.prog) {
+		bpf_prog_put(old_pinned.prog);
 		static_branch_dec(&cgroup_bpf_enabled_key);
 	}
 }
@@ -151,7 +153,7 @@ int __cgroup_bpf_run_filter(struct sock *sk,
 
 	rcu_read_lock();
 
-	prog = rcu_dereference(cgrp->bpf.effective[type]);
+	prog = rcu_dereference(cgrp->bpf.effective[type].prog);
 	if (prog) {
 		unsigned int offset = skb->data - skb_mac_header(skb);
 
-- 
2.9.3
