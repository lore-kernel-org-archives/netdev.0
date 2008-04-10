From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 12/14][VLAN]: Make vlan_name_type per-net.
Date: Thu, 10 Apr 2008 19:20:25 +0400
Message-ID: <47FE3039.8020601@openvz.org>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40360 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756618AbYDJO4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 10:56:31 -0400
In-Reply-To: <47FE2AD4.9080609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/8021q/vlan.c     |   14 +++++++++-----
 net/8021q/vlan.h     |    4 ++--
 net/8021q/vlanproc.c |    7 +++++--
 3 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 541542e..5cacad0 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -52,9 +52,6 @@ static char vlan_version[] = DRV_VERSION;
 static char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
 static char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
-/* Determines interface naming scheme. */
-unsigned short vlan_name_type = VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD;
-
 static struct packet_type vlan_packet_type = {
 	.type = __constant_htons(ETH_P_8021Q),
 	.func = vlan_skb_recv, /* VLAN receive method */
@@ -299,6 +296,8 @@ static int register_vlan_device(struct net_device *real_dev,
 				unsigned short VLAN_ID)
 {
 	struct net_device *new_dev;
+	struct net *net = dev_net(real_dev);
+	struct vlan_net *vn = net_generic(net, vlan_net_id);
 	char name[IFNAMSIZ];
 	int err;
 
@@ -310,7 +309,7 @@ static int register_vlan_device(struct net_device *real_dev,
 		return err;
 
 	/* Gotta set up the fields for the device. */
-	switch (vlan_name_type) {
+	switch (vn->name_type) {
 	case VLAN_NAME_TYPE_RAW_PLUS_VID:
 		/* name will look like:	 eth1.0005 */
 		snprintf(name, IFNAMSIZ, "%s.%.4i", real_dev->name, VLAN_ID);
@@ -580,7 +579,10 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 			break;
 		if ((args.u.name_type >= 0) &&
 		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
-			vlan_name_type = args.u.name_type;
+			struct vlan_net *vn;
+
+			vn = net_generic(net, vlan_net_id);
+			vn->name_type = args.u.name_type;
 			err = 0;
 		} else {
 			err = -EINVAL;
@@ -642,6 +644,8 @@ static int vlan_init_net(struct net *net)
 	if (err < 0)
 		goto err_assign;
 
+	vn->name_type = VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD;
+
 	err = vlan_proc_init(net);
 	if (err < 0)
 		goto err_proc;
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 7258357..5229a72 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -3,8 +3,6 @@
 
 #include <linux/if_vlan.h>
 
-extern unsigned short vlan_name_type;
-
 #define VLAN_GRP_HASH_SHIFT	5
 #define VLAN_GRP_HASH_SIZE	(1 << VLAN_GRP_HASH_SHIFT)
 #define VLAN_GRP_HASH_MASK	(VLAN_GRP_HASH_SIZE - 1)
@@ -59,6 +57,8 @@ struct vlan_net {
 	struct proc_dir_entry *proc_vlan_dir;
 	/* /proc/net/vlan/config */
 	struct proc_dir_entry *proc_vlan_conf;
+	/* Determines interface naming scheme. */
+	unsigned short name_type;
 };
 
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index cc17b72..daad006 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -260,13 +260,16 @@ static void vlan_seq_stop(struct seq_file *seq, void *v)
 
 static int vlan_seq_show(struct seq_file *seq, void *v)
 {
+	struct net *net = seq_file_net(seq);
+	struct vlan_net *vn = net_generic(net, vlan_net_id);
+
 	if (v == SEQ_START_TOKEN) {
 		const char *nmtype = NULL;
 
 		seq_puts(seq, "VLAN Dev name	 | VLAN ID\n");
 
-		if (vlan_name_type < ARRAY_SIZE(vlan_name_type_str))
-		    nmtype =  vlan_name_type_str[vlan_name_type];
+		if (vn->name_type < ARRAY_SIZE(vlan_name_type_str))
+		    nmtype =  vlan_name_type_str[vn->name_type];
 
 		seq_printf(seq, "Name-Type: %s\n",
 			   nmtype ? nmtype :  "UNKNOWN");
-- 
1.5.3.4

