From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 4/10][VLAN]: Introduce the vlan_net structure and
 init/exit net ops.
Date: Tue, 15 Apr 2008 16:07:13 +0400
Message-ID: <48049A71.1030900@openvz.org>
References: <4804989F.1060503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60448 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755225AbYDOLcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 07:32:55 -0400
In-Reply-To: <4804989F.1060503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike TUN, it is empty from the very beginning, and will 
be eventually populated later.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/8021q/vlan.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 net/8021q/vlan.h |    5 +++++
 2 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index cf8d810..9296601 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -32,6 +32,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/notifier.h>
 #include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 #include <linux/if_vlan.h>
 #include "vlan.h"
@@ -41,6 +42,8 @@
 
 /* Global VLAN variables */
 
+int vlan_net_id;
+
 /* Our listing of VLAN group(s) */
 static struct hlist_head vlan_group_hash[VLAN_GRP_HASH_SIZE];
 
@@ -625,6 +628,41 @@ out:
 	return err;
 }
 
+static int vlan_init_net(struct net *net)
+{
+	int err;
+	struct vlan_net *vn;
+
+	err = -ENOMEM;
+	vn = kzalloc(sizeof(struct vlan_net), GFP_KERNEL);
+	if (vn == NULL)
+		goto err_alloc;
+
+	err = net_assign_generic(net, vlan_net_id, vn);
+	if (err < 0)
+		goto err_assign;
+
+	return 0;
+
+err_assign:
+	kfree(vn);
+err_alloc:
+	return err;
+}
+
+static void vlan_exit_net(struct net *net)
+{
+	struct vlan_net *vn;
+
+	vn = net_generic(net, vlan_net_id);
+	kfree(vn);
+}
+
+static struct pernet_operations vlan_net_ops = {
+	.init = vlan_init_net,
+	.exit = vlan_exit_net,
+};
+
 static int __init vlan_proto_init(void)
 {
 	int err;
@@ -632,6 +670,10 @@ static int __init vlan_proto_init(void)
 	pr_info("%s v%s %s\n", vlan_fullname, vlan_version, vlan_copyright);
 	pr_info("All bugs added by %s\n", vlan_buggyright);
 
+	err = register_pernet_gen_device(&vlan_net_id, &vlan_net_ops);
+	if (err < 0)
+		goto err0;
+
 	err = vlan_proc_init();
 	if (err < 0)
 		goto err1;
@@ -653,6 +695,8 @@ err3:
 err2:
 	vlan_proc_cleanup();
 err1:
+	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
+err0:
 	return err;
 }
 
@@ -673,6 +717,8 @@ static void __exit vlan_cleanup_module(void)
 
 	vlan_proc_cleanup();
 
+	unregister_pernet_gen_device(vlan_net_id, &vlan_net_ops);
+
 	synchronize_net();
 }
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 51271ae..f27d8d6 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -50,4 +50,9 @@ static inline int is_vlan_dev(struct net_device *dev)
 	return dev->priv_flags & IFF_802_1Q_VLAN;
 }
 
+extern int vlan_net_id;
+
+struct vlan_net {
+};
+
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
-- 
1.5.3.4

