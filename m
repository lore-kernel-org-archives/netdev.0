From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 9/14][VLAN]: Add net argument to proc init/cleanup calls.
Date: Thu, 10 Apr 2008 19:16:54 +0400
Message-ID: <47FE2F66.60001@openvz.org>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39684 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758142AbYDJOxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 10:53:13 -0400
In-Reply-To: <47FE2AD4.9080609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Proc files will be created in each net, so prepare them for this
change just to make patches smaller.

The net != &init_net checks in them are for git-bisect sanity, but
I'll drop them soon.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/8021q/vlan.c     |   15 +++++++--------
 net/8021q/vlanproc.c |   12 +++++++++---
 net/8021q/vlanproc.h |   10 ++++++----
 3 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 9296601..541542e 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -642,8 +642,14 @@ static int vlan_init_net(struct net *net)
 	if (err < 0)
 		goto err_assign;
 
+	err = vlan_proc_init(net);
+	if (err < 0)
+		goto err_proc;
+
 	return 0;
 
+err_proc:
+	/* nothing */
 err_assign:
 	kfree(vn);
 err_alloc:
@@ -655,6 +661,7 @@ static void vlan_exit_net(struct net *net)
 	struct vlan_net *vn;
 
 	vn = net_generic(net, vlan_net_id);
+	vlan_proc_cleanup(net);
 	kfree(vn);
 }
 
@@ -674,10 +681,6 @@ static int __init vlan_proto_init(void)
 	if (err < 0)
 		goto err0;
 
-	err = vlan_proc_init();
-	if (err < 0)
-		goto err1;
-
 	err = register_netdevice_notifier(&vlan_notifier_block);
 	if (err < 0)
 		goto err2;
@@ -693,8 +696,6 @@ static int __init vlan_proto_init(void)
 err3:
 	unregister_netdevice_notifier(&vlan_notifier_block);
 err2:
-	vlan_proc_cleanup();
-err1:
 	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
 err0:
 	return err;
@@ -715,8 +716,6 @@ static void __exit vlan_cleanup_module(void)
 	for (i = 0; i < VLAN_GRP_HASH_SIZE; i++)
 		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
 
-	vlan_proc_cleanup();
-
 	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
 
 	synchronize_net();
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 24cd96e..4d13aeb 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -138,8 +138,11 @@ static const char *vlan_name_type_str[VLAN_NAME_TYPE_HIGHEST] = {
  *	Clean up /proc/net/vlan entries
  */
 
-void vlan_proc_cleanup(void)
+void vlan_proc_cleanup(struct net *net)
 {
+	if (net != &init_net)
+		return;
+
 	if (proc_vlan_conf)
 		remove_proc_entry(name_conf, proc_vlan_dir);
 
@@ -155,8 +158,11 @@ void vlan_proc_cleanup(void)
  *	Create /proc/net/vlan entries
  */
 
-int __init vlan_proc_init(void)
+int vlan_proc_init(struct net *net)
 {
+	if (net != &init_net)
+		return 0;
+
 	proc_vlan_dir = proc_mkdir(name_root, init_net.proc_net);
 	if (!proc_vlan_dir)
 		goto err;
@@ -169,7 +175,7 @@ int __init vlan_proc_init(void)
 
 err:
 	pr_err("%s: can't create entry in proc filesystem!\n", __func__);
-	vlan_proc_cleanup();
+	vlan_proc_cleanup(net);
 	return -ENOBUFS;
 }
 
diff --git a/net/8021q/vlanproc.h b/net/8021q/vlanproc.h
index da542ca..063f60a 100644
--- a/net/8021q/vlanproc.h
+++ b/net/8021q/vlanproc.h
@@ -2,15 +2,17 @@
 #define __BEN_VLAN_PROC_INC__
 
 #ifdef CONFIG_PROC_FS
-int vlan_proc_init(void);
+struct net;
+
+int vlan_proc_init(struct net *net);
 int vlan_proc_rem_dev(struct net_device *vlandev);
 int vlan_proc_add_dev(struct net_device *vlandev);
-void vlan_proc_cleanup(void);
+void vlan_proc_cleanup(struct net *net);
 
 #else /* No CONFIG_PROC_FS */
 
-#define vlan_proc_init()	(0)
-#define vlan_proc_cleanup()	do {} while (0)
+#define vlan_proc_init(net)	(0)
+#define vlan_proc_cleanup(net)	do {} while (0)
 #define vlan_proc_add_dev(dev)	({(void)(dev), 0; })
 #define vlan_proc_rem_dev(dev)	({(void)(dev), 0; })
 #endif
-- 
1.5.3.4

