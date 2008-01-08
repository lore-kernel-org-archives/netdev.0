From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 3/6][DECNET] Switch to using ctl_paths.
Date: Tue, 08 Jan 2008 19:02:16 +0300
Message-ID: <47839E88.2040604@openvz.org>
References: <47839C30.2040402@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52545 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752810AbYAHQCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 11:02:07 -0500
In-Reply-To: <47839C30.2040402@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The decnet includes two places to patch. The first one is 
the net/decnet table itself, and it is patched just like 
other subsystems in the first patch in this series.

The second place is a bit more complex - it is the 
net/decnet/conf/xxx entries,. similar to those in 
ipv4/devinet.c and ipv6/addrconf.c. This code is made similar 
to those in ipv[46].

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

 net/decnet/dn_dev.c            |   52 +++++++++++------------------------------
 net/decnet/sysctl_net_decnet.c |   23 +++---------------
 2 files changed, 20 insertions(+), 55 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 39c89c6..fb884e5 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -173,10 +173,6 @@ static int dn_forwarding_sysctl(ctl_table *table, int __user *name, int nlen,
 static struct dn_dev_sysctl_table {
 	struct ctl_table_header *sysctl_header;
 	ctl_table dn_dev_vars[5];
-	ctl_table dn_dev_dev[2];
-	ctl_table dn_dev_conf_dir[2];
-	ctl_table dn_dev_proto_dir[2];
-	ctl_table dn_dev_root_dir[2];
 } dn_dev_sysctl = {
 	NULL,
 	{
@@ -224,30 +220,6 @@ static struct dn_dev_sysctl_table {
 	},
 	{0}
 	},
-	{{
-		.ctl_name = 0,
-		.procname = "",
-		.mode = 0555,
-		.child = dn_dev_sysctl.dn_dev_vars
-	}, {0}},
-	{{
-		.ctl_name = NET_DECNET_CONF,
-		.procname = "conf",
-		.mode = 0555,
-		.child = dn_dev_sysctl.dn_dev_dev
-	}, {0}},
-	{{
-		.ctl_name = NET_DECNET,
-		.procname = "decnet",
-		.mode = 0555,
-		.child = dn_dev_sysctl.dn_dev_conf_dir
-	}, {0}},
-	{{
-		.ctl_name = CTL_NET,
-		.procname = "net",
-		.mode = 0555,
-		.child = dn_dev_sysctl.dn_dev_proto_dir
-	}, {0}}
 };
 
 static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *parms)
@@ -255,6 +227,16 @@ static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *
 	struct dn_dev_sysctl_table *t;
 	int i;
 
+#define DN_CTL_PATH_DEV	3
+	
+	struct ctl_path dn_ctl_path[] = {
+		{ .procname = "net", .ctl_name = CTL_NET, },
+		{ .procname = "decnet", .ctl_name = NET_DECNET, },
+		{ .procname = "conf", .ctl_name = NET_DECNET_CONF, },
+		{ /* to be set */ },
+		{ },
+	};
+
 	t = kmemdup(&dn_dev_sysctl, sizeof(*t), GFP_KERNEL);
 	if (t == NULL)
 		return;
@@ -265,20 +247,16 @@ static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *
 	}
 
 	if (dev) {
-		t->dn_dev_dev[0].procname = dev->name;
-		t->dn_dev_dev[0].ctl_name = dev->ifindex;
+		dn_ctl_path[DN_CTL_PATH_DEV].procname = dev->name;
+		dn_ctl_path[DN_CTL_PATH_DEV].ctl_name = dev->ifindex;
 	} else {
-		t->dn_dev_dev[0].procname = parms->name;
-		t->dn_dev_dev[0].ctl_name = parms->ctl_name;
+		dn_ctl_path[DN_CTL_PATH_DEV].procname = parms->name;
+		dn_ctl_path[DN_CTL_PATH_DEV].ctl_name = parms->ctl_name;
 	}
 
-	t->dn_dev_dev[0].child = t->dn_dev_vars;
-	t->dn_dev_conf_dir[0].child = t->dn_dev_dev;
-	t->dn_dev_proto_dir[0].child = t->dn_dev_conf_dir;
-	t->dn_dev_root_dir[0].child = t->dn_dev_proto_dir;
 	t->dn_dev_vars[0].extra1 = (void *)dev;
 
-	t->sysctl_header = register_sysctl_table(t->dn_dev_root_dir);
+	t->sysctl_header = register_sysctl_paths(dn_ctl_path, t->dn_dev_vars);
 	if (t->sysctl_header == NULL)
 		kfree(t);
 	else
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index ae354a4..228067c 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -470,28 +470,15 @@ static ctl_table dn_table[] = {
 	{0}
 };
 
-static ctl_table dn_dir_table[] = {
-	{
-		.ctl_name = NET_DECNET,
-		.procname = "decnet",
-		.mode = 0555,
-		.child = dn_table},
-	{0}
-};
-
-static ctl_table dn_root_table[] = {
-	{
-		.ctl_name = CTL_NET,
-		.procname = "net",
-		.mode = 0555,
-		.child = dn_dir_table
-	},
-	{0}
+static struct ctl_path dn_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "decnet", .ctl_name = NET_DECNET, },
+	{ }
 };
 
 void dn_register_sysctl(void)
 {
-	dn_table_header = register_sysctl_table(dn_root_table);
+	dn_table_header = register_sysctl_paths(dn_path, dn_table);
 }
 
 void dn_unregister_sysctl(void)

