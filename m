From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 8/14][VLAN]: Introduce the vlan_net structure.
Date: Thu, 10 Apr 2008 19:14:58 +0400
Message-ID: <47FE2EF2.2020401@openvz.org>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
        Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
To: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47FE2AD4.9080609-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

It is empty now, but it will be populated later.
And it uses net generic pointers like TUN does.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

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
