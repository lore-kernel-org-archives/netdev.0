From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/4] modules: proper cleanup of kobject without CONFIG_SYSFS
Date: Tue, 20 May 2008 13:59:48 +0400
Message-ID: <1211277589-8565-3-git-send-email-den@openvz.org>
References: <1211277589-8565-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Denis V. Lunev" <den@openvz.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Kay Sievers <kay.sievers@vrfy.org>
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:41940 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764697AbYETKAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 06:00:24 -0400
In-Reply-To: <1211277589-8565-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kobject: '<NULL>' (ffffffffa0104050): is not initialized, yet kobject_put() is being called.
------------[ cut here ]------------
WARNING: at /home/den/src/linux-netns26/lib/kobject.c:583 kobject_put+0x53/0x55()
Modules linked in: ipv6 nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs ide_cd_mod cdrom button [last unloaded: pktgen]
comm: rmmod Tainted: G        W 2.6.26-rc3 #585
Call Trace:
  [<ffffffff802359ab>] warn_on_slowpath+0x58/0x7a
  [<ffffffff80236aca>] ? printk+0x67/0x69
  [<ffffffff80236aca>] ? printk+0x67/0x69
  [<ffffffff80324289>] kobject_put+0x53/0x55
  [<ffffffff8025e2ee>] free_module+0x87/0xfa
  [<ffffffff8025fee5>] sys_delete_module+0x178/0x1e1
  [<ffffffff804b1e70>] ? lockdep_sys_exit_thunk+0x35/0x67
  [<ffffffff804b1dff>] ? trace_hardirqs_on_thunk+0x35/0x3a
  [<ffffffff8020c0bb>] system_call_after_swapgs+0x7b/0x80
---[ end trace 8f5aafa7f6406cf8 ]---

mod->mkobj.kobj is not initialized without CONFIG_SYSFS. Do not call
kobject_put in this case.

Signed-off-by: Denis V. Lunev <den@openvz.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Kay Sievers <kay.sievers@vrfy.org>
---
 kernel/module.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/kernel/module.c b/kernel/module.c
index e6daf9a..5f80478 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -1337,7 +1337,19 @@ out_unreg:
 	kobject_put(&mod->mkobj.kobj);
 	return err;
 }
-#endif
+
+static void mod_sysfs_fini(struct module *mod)
+{
+	kobject_put(&mod->mkobj.kobj);
+}
+
+#else /* CONFIG_SYSFS */
+
+static void mod_sysfs_fini(struct module *mod)
+{
+}
+
+#endif /* CONFIG_SYSFS */
 
 static void mod_kobject_remove(struct module *mod)
 {
@@ -1345,7 +1357,7 @@ static void mod_kobject_remove(struct module *mod)
 	module_param_sysfs_remove(mod);
 	kobject_put(mod->mkobj.drivers_dir);
 	kobject_put(mod->holders_dir);
-	kobject_put(&mod->mkobj.kobj);
+	mod_sysfs_fini(mod);
 }
 
 /*
-- 
1.5.3.rc5

