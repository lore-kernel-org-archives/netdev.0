From: "Art Haas" <ahaas@airmail.net>
Subject: [PATCH] Add C99 initializers to net/ipv4/ipvs/ip_vs_lblc.c
Date: Tue, 16 Mar 2004 12:54:51 -0600
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040316185451.GB12996@artsapartment.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Wensong Zhang <wensong@gnuchina.org>,
	"David S. Miller" <davem@redhat.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi.

This is the second patch adding initializers. The patch splits a
structure up into several variables, making the code more like
other code in net/. The patch is against the current BK.

Art Haas

===== net/ipv4/ipvs/ip_vs_lblc.c 1.7 vs edited =====
--- 1.7/net/ipv4/ipvs/ip_vs_lblc.c	Wed Feb 18 15:03:53 2004
+++ edited/net/ipv4/ipvs/ip_vs_lblc.c	Tue Mar 16 11:49:24 2004
@@ -108,29 +108,50 @@
 /*
  *      IPVS LBLC sysctl table
  */
-struct ip_vs_lblc_sysctl_table {
-	struct ctl_table_header *sysctl_header;
-	ctl_table vs_vars[2];
-	ctl_table vs_dir[2];
-	ctl_table ipv4_dir[2];
-	ctl_table root_dir[2];
+
+static ctl_table vs_vars_table[] = {
+	{
+		.ctl_name	= NET_IPV4_VS_LBLC_EXPIRE,
+		.procname	= "lblc_expiration",
+		.data		= &sysctl_ip_vs_lblc_expiration,
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
 
-static struct ip_vs_lblc_sysctl_table lblc_sysctl_table = {
-	NULL,
-	{{NET_IPV4_VS_LBLC_EXPIRE, "lblc_expiration",
-	  &sysctl_ip_vs_lblc_expiration,
-	  sizeof(int), 0644, NULL, &proc_dointvec_jiffies},
-	 {0}},
-	{{NET_IPV4_VS, "vs", NULL, 0, 0555, lblc_sysctl_table.vs_vars},
-	 {0}},
-	{{NET_IPV4, "ipv4", NULL, 0, 0555, lblc_sysctl_table.vs_dir},
-	 {0}},
-	{{CTL_NET, "net", NULL, 0, 0555, lblc_sysctl_table.ipv4_dir},
-	 {0}}
+static ctl_table lblc_root_table[] = {
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
  *      new/free a ip_vs_lblc_entry, which is a mapping of a destionation
@@ -586,15 +607,14 @@
 static int __init ip_vs_lblc_init(void)
 {
 	INIT_LIST_HEAD(&ip_vs_lblc_scheduler.n_list);
-	lblc_sysctl_table.sysctl_header =
-		register_sysctl_table(lblc_sysctl_table.root_dir, 0);
+	sysctl_header = register_sysctl_table(lblc_root_table, 0);
 	return register_ip_vs_scheduler(&ip_vs_lblc_scheduler);
 }
 
 
 static void __exit ip_vs_lblc_cleanup(void)
 {
-	unregister_sysctl_table(lblc_sysctl_table.sysctl_header);
+	unregister_sysctl_table(sysctl_header);
 	unregister_ip_vs_scheduler(&ip_vs_lblc_scheduler);
 }
 
-- 
Man once surrendering his reason, has no remaining guard against absurdities
the most monstrous, and like a ship without rudder, is the sport of every wind.

-Thomas Jefferson to James Smith, 1822
