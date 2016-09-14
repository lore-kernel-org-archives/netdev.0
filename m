From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 14/22] bpf/cgroup: Make cgroup_bpf_update() return an error code
Date: Wed, 14 Sep 2016 09:24:07 +0200
Message-ID: <20160914072415.26021-15-mic@digikod.net>
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
Return-path: <kernel-hardening-return-4596-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
List-Id: netdev.vger.kernel.org

This will be useful to support Landlock for the next commits.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Mack <daniel@zonque.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/bpf-cgroup.h |  4 ++--
 kernel/bpf/cgroup.c        |  3 ++-
 kernel/bpf/syscall.c       | 10 ++++++----
 kernel/cgroup.c            |  6 ++++--
 4 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 2234042d7f61..6cca7924ee17 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -31,13 +31,13 @@ struct cgroup_bpf {
 void cgroup_bpf_put(struct cgroup *cgrp);
 void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent);
 
-void __cgroup_bpf_update(struct cgroup *cgrp,
+int __cgroup_bpf_update(struct cgroup *cgrp,
 			 struct cgroup *parent,
 			 struct bpf_prog *prog,
 			 enum bpf_attach_type type);
 
 /* Wrapper for __cgroup_bpf_update() protected by cgroup_mutex */
-void cgroup_bpf_update(struct cgroup *cgrp,
+int cgroup_bpf_update(struct cgroup *cgrp,
 		       struct bpf_prog *prog,
 		       enum bpf_attach_type type);
 
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index 782878ec4f2d..7b75fa692617 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -83,7 +83,7 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
  *
  * Must be called with cgroup_mutex held.
  */
-void __cgroup_bpf_update(struct cgroup *cgrp,
+int __cgroup_bpf_update(struct cgroup *cgrp,
 			 struct cgroup *parent,
 			 struct bpf_prog *prog,
 			 enum bpf_attach_type type)
@@ -117,6 +117,7 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
 		bpf_prog_put(old_pinned.prog);
 		static_branch_dec(&cgroup_bpf_enabled_key);
 	}
+	return 0;
 }
 
 /**
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 45a91d511119..c978f2d9a1b3 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -831,6 +831,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 {
 	struct bpf_prog *prog;
 	struct cgroup *cgrp;
+	int result;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -858,10 +859,10 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 		return PTR_ERR(cgrp);
 	}
 
-	cgroup_bpf_update(cgrp, prog, attr->attach_type);
+	result = cgroup_bpf_update(cgrp, prog, attr->attach_type);
 	cgroup_put(cgrp);
 
-	return 0;
+	return result;
 }
 
 #define BPF_PROG_DETACH_LAST_FIELD attach_type
@@ -869,6 +870,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 static int bpf_prog_detach(const union bpf_attr *attr)
 {
 	struct cgroup *cgrp;
+	int result = 0;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -883,7 +885,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 		if (IS_ERR(cgrp))
 			return PTR_ERR(cgrp);
 
-		cgroup_bpf_update(cgrp, NULL, attr->attach_type);
+		result = cgroup_bpf_update(cgrp, NULL, attr->attach_type);
 		cgroup_put(cgrp);
 		break;
 
@@ -891,7 +893,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 		return -EINVAL;
 	}
 
-	return 0;
+	return result;
 }
 #endif /* CONFIG_CGROUP_BPF */
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 87324ce481b1..48b650a640a9 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -6450,15 +6450,17 @@ static __init int cgroup_namespaces_init(void)
 subsys_initcall(cgroup_namespaces_init);
 
 #ifdef CONFIG_CGROUP_BPF
-void cgroup_bpf_update(struct cgroup *cgrp,
+int cgroup_bpf_update(struct cgroup *cgrp,
 		       struct bpf_prog *prog,
 		       enum bpf_attach_type type)
 {
 	struct cgroup *parent = cgroup_parent(cgrp);
+	int result;
 
 	mutex_lock(&cgroup_mutex);
-	__cgroup_bpf_update(cgrp, parent, prog, type);
+	result = __cgroup_bpf_update(cgrp, parent, prog, type);
 	mutex_unlock(&cgroup_mutex);
+	return result;
 }
 #endif /* CONFIG_CGROUP_BPF */
 
-- 
2.9.3
