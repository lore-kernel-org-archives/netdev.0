From: "Art Haas" <ahaas@airmail.net>
Subject: [PATCH] C99 initializers for net/ipv4/ipvs/ip_vs_lblcr.c
Date: Tue, 16 Mar 2004 12:56:28 -0600
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040316185628.GC12996@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Wensong Zhang <wensong@gnuchina.org>,
	"David S. Miller" <davem@redhat.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi.

Here's the last of the three patches adding C99 initializers. This patch
splits a structure up, and is against the current BK.

Art Haas

===== net/ipv4/ipvs/ip_vs_lblcr.c 1.8 vs edited =====
--- 1.8/net/ipv4/ipvs/ip_vs_lblcr.c	Wed Feb 18 15:03:53 2004
+++ edited/net/ipv4/ipvs/ip_vs_lblcr.c	Tue Mar 16 11:49:49 2004
@@ -297,29 +297,50 @@
 /*
  *      IPVS LBLCR sysctl table
  */
-struct ip_vs_lblcr_sysctl_table {
-	struct ctl_table_header *sysctl_header;
-	ctl_table vs_vars[2];
-	ctl_table vs_dir[2];
-	ctl_table ipv4_dir[2];
-	ctl_table root_dir[2];
+
+static ctl_table vs_vars_table[] = {
+	{
+		.ctl_name	= NET_IPV4_VS_LBLCR_EXPIRE,
+		.procname	= "lblcr_expiration",
+		.data		= &sysctl_ip_vs_lblcr_expiration,
+		.maxlen		= sizeof(int),
+		.mode		= 0644, 
+		.proc_handler	= &proc_dointvec_jiffies,
+	},
+	{ .ctl_name = 0 }
+};
+
+static ctl_table vs_table[] = {
+	{
+		.ctl_name	= NET_IPV4_VS,
+		.procname	= "vs",
+		.mode		= 0555,
+		.child		= vs_vars_table
+	},
+	{ .ctl_name = 0 }
 };
 
+static ctl_table ipv4_table[] = {
+	{
+		.ctl_name	= NET_IPV4,
+		.procname	= "ipv4", 
+		.mode		= 0555,
+		.child		= vs_table
+	},
+	{ .ctl_name = 0 }
+};
 
-static struct ip_vs_lblcr_sysctl_table lblcr_sysctl_table = {
-	NULL,
-	{{NET_IPV4_VS_LBLCR_EXPIRE, "lblcr_expiration",
-	  &sysctl_ip_vs_lblcr_expiration,
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {0}},
-	{{NET_IPV4_VS, "vs", NULL, 0, 0555, lblcr_sysctl_table.vs_vars},
-	 {0}},
-	{{NET_IPV4, "ipv4", NULL, 0, 0555, lblcr_sysctl_table.vs_dir},
-	 {0}},
-	{{CTL_NET, "net", NULL, 0, 0555, lblcr_sysctl_table.ipv4_dir},
-	 {0}}
+static ctl_table lblcr_root_table[] = {
+	{
+		.ctl_name	= CTL_NET,
+		.procname	= "net", 
+		.mode		= 0555, 
+		.child		= ipv4_table
+	},
+	{ .ctl_name = 0 }
 };
 
+static struct ctl_table_header * sysctl_header;
 
 /*
  *      new/free a ip_vs_lblcr_entry, which is a mapping of a destination
@@ -844,8 +865,7 @@
 static int __init ip_vs_lblcr_init(void)
 {
 	INIT_LIST_HEAD(&ip_vs_lblcr_scheduler.n_list);
-	lblcr_sysctl_table.sysctl_header =
-		register_sysctl_table(lblcr_sysctl_table.root_dir, 0);
+	sysctl_header = register_sysctl_table(lblcr_root_table, 0);
 #ifdef CONFIG_IP_VS_LBLCR_DEBUG
 	proc_net_create("ip_vs_lblcr", 0, ip_vs_lblcr_getinfo);
 #endif
@@ -858,7 +878,7 @@
 #ifdef CONFIG_IP_VS_LBLCR_DEBUG
 	proc_net_remove("ip_vs_lblcr");
 #endif
-	unregister_sysctl_table(lblcr_sysctl_table.sysctl_header);
+	unregister_sysctl_table(sysctl_header);
 	unregister_ip_vs_scheduler(&ip_vs_lblcr_scheduler);
 }
 
-- 
Man once surrendering his reason, has no remaining guard against absurdities
the most monstrous, and like a ship without rudder, is the sport of every wind.

-Thomas Jefferson to James Smith, 1822
