From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v2 4/5] selinux: bpf: Add selinux check for eBPF syscall operations
Date: Mon,  9 Oct 2017 15:20:27 -0700
Message-ID: <20171009222028.13096-5-chenbofeng.kernel@gmail.com>
References: <20171009222028.13096-1-chenbofeng.kernel@gmail.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Daniel Borkmann <daniel@iogearbox.net>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Chenbo Feng <fengc@google.com>
To: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35048 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754908AbdJIWVD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 18:21:03 -0400
In-Reply-To: <20171009222028.13096-1-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Implement the actual checks introduced to eBPF related syscalls. This
implementation use the security field inside bpf object to store a sid that
identify the bpf object. And when processes try to access the object,
selinux will check if processes have the right privileges. The creation
of eBPF object are also checked at the general bpf check hook and new
cmd introduced to eBPF domain can also be checked there.

Signed-off-by: Chenbo Feng <fengc@google.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 security/selinux/hooks.c            | 111 ++++++++++++++++++++++++++++++++++++
 security/selinux/include/classmap.h |   2 +
 security/selinux/include/objsec.h   |   4 ++
 3 files changed, 117 insertions(+)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index f5d304736852..41aba4e3d57c 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -85,6 +85,7 @@
 #include <linux/export.h>
 #include <linux/msg.h>
 #include <linux/shm.h>
+#include <linux/bpf.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -6252,6 +6253,106 @@ static void selinux_ib_free_security(void *ib_sec)
 }
 #endif
 
+#ifdef CONFIG_BPF_SYSCALL
+static int selinux_bpf(int cmd, union bpf_attr *attr,
+				     unsigned int size)
+{
+	u32 sid = current_sid();
+	int ret;
+
+	switch (cmd) {
+	case BPF_MAP_CREATE:
+		ret = avc_has_perm(sid, sid, SECCLASS_BPF_MAP, BPF_MAP__CREATE,
+				   NULL);
+		break;
+	case BPF_PROG_LOAD:
+		ret = avc_has_perm(sid, sid, SECCLASS_BPF_PROG, BPF_PROG__LOAD,
+				   NULL);
+		break;
+	default:
+		ret = 0;
+		break;
+	}
+
+	return ret;
+}
+
+static u32 bpf_map_fmode_to_av(fmode_t fmode)
+{
+	u32 av = 0;
+
+	if (f_mode & FMODE_READ)
+		av |= BPF_MAP__READ;
+	if (f_mode & FMODE_WRITE)
+		av |= BPF_MAP__WRITE;
+	return av;
+}
+
+static int selinux_bpf_map(struct bpf_map *map, fmode_t fmode)
+{
+	u32 sid = current_sid();
+	struct bpf_security_struct *bpfsec;
+
+	bpfsec = map->security;
+	return avc_has_perm(sid, bpfsec->sid, SECCLASS_BPF_MAP,
+			    bpf_map_fmode_to_av(fmode), NULL);
+}
+
+static int selinux_bpf_prog(struct bpf_prog *prog)
+{
+	u32 sid = current_sid();
+	struct bpf_security_struct *bpfsec;
+
+	bpfsec = prog->aux->security;
+	return avc_has_perm(sid, bpfsec->sid, SECCLASS_BPF_PROG,
+			    BPF_PROG__USE, NULL);
+}
+
+static int selinux_bpf_map_alloc(struct bpf_map *map)
+{
+	struct bpf_security_struct *bpfsec;
+
+	bpfsec = kzalloc(sizeof(*bpfsec), GFP_KERNEL);
+	if (!bpfsec)
+		return -ENOMEM;
+
+	bpfsec->sid = current_sid();
+	map->security = bpfsec;
+
+	return 0;
+}
+
+static void selinux_bpf_map_free(struct bpf_map *map)
+{
+	struct bpf_security_struct *bpfsec = map->security;
+
+	map->security = NULL;
+	kfree(bpfsec);
+}
+
+static int selinux_bpf_prog_alloc(struct bpf_prog_aux *aux)
+{
+	struct bpf_security_struct *bpfsec;
+
+	bpfsec = kzalloc(sizeof(*bpfsec), GFP_KERNEL);
+	if (!bpfsec)
+		return -ENOMEM;
+
+	bpfsec->sid = current_sid();
+	aux->security = bpfsec;
+
+	return 0;
+}
+
+static void selinux_bpf_prog_free(struct bpf_prog_aux *aux)
+{
+	struct bpf_security_struct *bpfsec = aux->security;
+
+	aux->security = NULL;
+	kfree(bpfsec);
+}
+#endif
+
 static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(binder_set_context_mgr, selinux_binder_set_context_mgr),
 	LSM_HOOK_INIT(binder_transaction, selinux_binder_transaction),
@@ -6471,6 +6572,16 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(audit_rule_match, selinux_audit_rule_match),
 	LSM_HOOK_INIT(audit_rule_free, selinux_audit_rule_free),
 #endif
+
+#ifdef CONFIG_BPF_SYSCALL
+	LSM_HOOK_INIT(bpf, selinux_bpf),
+	LSM_HOOK_INIT(bpf_map, selinux_bpf_map),
+	LSM_HOOK_INIT(bpf_prog, selinux_bpf_prog),
+	LSM_HOOK_INIT(bpf_map_alloc_security, selinux_bpf_map_alloc),
+	LSM_HOOK_INIT(bpf_prog_alloc_security, selinux_bpf_prog_alloc),
+	LSM_HOOK_INIT(bpf_map_free_security, selinux_bpf_map_free),
+	LSM_HOOK_INIT(bpf_prog_free_security, selinux_bpf_prog_free),
+#endif
 };
 
 static __init int selinux_init(void)
diff --git a/security/selinux/include/classmap.h b/security/selinux/include/classmap.h
index 35ffb29a69cb..7253c5eea59c 100644
--- a/security/selinux/include/classmap.h
+++ b/security/selinux/include/classmap.h
@@ -237,6 +237,8 @@ struct security_class_mapping secclass_map[] = {
 	  { "access", NULL } },
 	{ "infiniband_endport",
 	  { "manage_subnet", NULL } },
+	{ "bpf_map", {"create", "read", "write"} },
+	{ "bpf_prog", {"load", "use"} },
 	{ NULL }
   };
 
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index 1649cd18eb0b..3d54468ce334 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -150,6 +150,10 @@ struct pkey_security_struct {
 	u32	sid;	/* SID of pkey */
 };
 
+struct bpf_security_struct {
+	u32 sid;  /*SID of bpf obj creater*/
+};
+
 extern unsigned int selinux_checkreqprot;
 
 #endif /* _SELINUX_OBJSEC_H_ */
-- 
2.14.2.920.gcf0c67979c-goog
