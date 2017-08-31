From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH 3/3] selinux: bpf: Implement the selinux checks for eBPF object
Date: Thu, 31 Aug 2017 13:56:35 -0700
Message-ID: <20170831205635.80256-4-chenbofeng.kernel@gmail.com>
References: <20170831205635.80256-1-chenbofeng.kernel@gmail.com>
Cc: Jeffrey Vander Stoep <jeffv@google.com>, netdev@vger.kernel.org,
        SELinux <Selinux@tycho.nsa.gov>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        lorenzo@google.com, Chenbo Feng <fengc@google.com>
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36708 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751443AbdHaU5L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 16:57:11 -0400
In-Reply-To: <20170831205635.80256-1-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Introduce 5 new selinux checks for eBPF object related operations. The
check is based on the ownership information of eBPF maps and the
capability of creating eBPF object.

Signed-off-by: Chenbo Feng <fengc@google.com>
---
 security/selinux/hooks.c            | 54 +++++++++++++++++++++++++++++++++++++
 security/selinux/include/classmap.h |  2 ++
 security/selinux/include/objsec.h   |  4 +++
 3 files changed, 60 insertions(+)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 33fd061305c4..39ad7d9f335d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -85,6 +85,7 @@
 #include <linux/export.h>
 #include <linux/msg.h>
 #include <linux/shm.h>
+#include <linux/bpf.h>
 
 #include "avc.h"
 #include "objsec.h"
@@ -6245,6 +6246,52 @@ static void selinux_ib_free_security(void *ib_sec)
 }
 #endif
 
+#ifdef CONFIG_BPF_SYSCALL
+static int selinux_bpf_map_create(void)
+{
+	u32 sid = current_sid();
+
+	return avc_has_perm(sid, sid, SECCLASS_BPF, BPF__MAP_CREATE, NULL);
+}
+
+static int selinux_bpf_map_modify(struct bpf_map *map)
+{
+	struct bpf_security_struct *bpfsec = map->security;
+
+	return avc_has_perm(current_sid(), bpfsec->sid, SECCLASS_BPF,
+			    BPF__MAP_MODIFY, NULL);
+}
+
+static int selinux_bpf_map_read(struct bpf_map *map)
+{
+	struct bpf_security_struct *bpfsec = map->security;
+
+	return avc_has_perm(current_sid(), bpfsec->sid, SECCLASS_BPF,
+			    BPF__MAP_READ, NULL);
+}
+
+static int selinux_bpf_prog_load(void)
+{
+	u32 sid = current_sid();
+
+	return avc_has_perm(sid, sid, SECCLASS_BPF, BPF__PROG_LOAD, NULL);
+}
+
+static int selinux_bpf_post_create(struct bpf_map *map)
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
+#endif
+
 static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(binder_set_context_mgr, selinux_binder_set_context_mgr),
 	LSM_HOOK_INIT(binder_transaction, selinux_binder_transaction),
@@ -6465,6 +6512,13 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(audit_rule_match, selinux_audit_rule_match),
 	LSM_HOOK_INIT(audit_rule_free, selinux_audit_rule_free),
 #endif
+#ifdef CONFIG_BPF_SYSCALL
+	LSM_HOOK_INIT(bpf_map_create, selinux_bpf_map_create),
+	LSM_HOOK_INIT(bpf_map_modify, selinux_bpf_map_modify),
+	LSM_HOOK_INIT(bpf_map_read, selinux_bpf_map_read),
+	LSM_HOOK_INIT(bpf_prog_load, selinux_bpf_prog_load),
+	LSM_HOOK_INIT(bpf_post_create, selinux_bpf_post_create),
+#endif
 };
 
 static __init int selinux_init(void)
diff --git a/security/selinux/include/classmap.h b/security/selinux/include/classmap.h
index b9fe3434b036..83c880fb17b4 100644
--- a/security/selinux/include/classmap.h
+++ b/security/selinux/include/classmap.h
@@ -235,6 +235,8 @@ struct security_class_mapping secclass_map[] = {
 	  { "access", NULL } },
 	{ "infiniband_endport",
 	  { "manage_subnet", NULL } },
+	{ "bpf",
+	  {"map_create", "map_modify", "map_read", "prog_load" } },
 	{ NULL }
   };
 
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index 6ebc61e370ff..ba564f662b0d 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -150,6 +150,10 @@ struct pkey_security_struct {
 	u32	sid;	/* SID of pkey */
 };
 
+struct bpf_security_struct {
+	u32 sid;	/*SID of bpf obj creater*/
+};
+
 extern unsigned int selinux_checkreqprot;
 
 #endif /* _SELINUX_OBJSEC_H_ */
-- 
2.14.1.581.gf28d330327-goog
