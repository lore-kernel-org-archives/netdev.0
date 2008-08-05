From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] AX.25: Fix sysctl registration if !CONFIG_AX25_DAMA_SLAVE
Date: Tue, 5 Aug 2008 23:37:36 +0100
Message-ID: <20080805223736.GA16608@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Thomas Osterried <thomas@osterried.de>, jann@linux-mips.org,
	Hans-Juergen Barthen <dl5di@gmx.de>
To: "David S. Miller" <davem@davemloft.net>, stable@kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 49ffcf8f99e8d33ec8afb450956804af518fd788
setting struct ctl_table.procname = NULL does no longer work as it used to
the way the AX.25 code is expecting it to resulting in the AX.25 sysctl
registration code to break if CONFIG_AX25_DAMA_SLAVE was not set as in some
distribution kernels.  Kernel releases from 2.6.24 are affected.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index f597987..f288fc4 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -36,6 +36,7 @@ static struct ctl_path ax25_path[] = {
 	{ .procname = "ax25", .ctl_name = NET_AX25, },
 	{ }
 };
+
 static const ctl_table ax25_param_table[] = {
 	{
 		.ctl_name	= NET_AX25_IP_DEFAULT_MODE,
@@ -167,6 +168,7 @@ static const ctl_table ax25_param_table[] = {
 		.extra1		= &min_proto,
 		.extra2		= &max_proto
 	},
+#ifdef CONFIG_AX25_DAMA_SLAVE
 	{
 		.ctl_name	= NET_AX25_DAMA_SLAVE_TIMEOUT,
 		.procname	= "dama_slave_timeout",
@@ -177,6 +179,8 @@ static const ctl_table ax25_param_table[] = {
 		.extra1		= &min_ds_timeout,
 		.extra2		= &max_ds_timeout
 	},
+#endif
+
 	{ .ctl_name = 0 }	/* that's all, folks! */
 };
 
@@ -210,16 +214,6 @@ void ax25_register_sysctl(void)
 		ax25_table[n].procname     = ax25_dev->dev->name;
 		ax25_table[n].mode         = 0555;
 
-#ifndef CONFIG_AX25_DAMA_SLAVE
-		/*
-		 * We do not wish to have a representation of this parameter
-		 * in /proc/sys/ when configured *not* to include the
-		 * AX.25 DAMA slave code, do we?
-		 */
-
-		child[AX25_VALUES_DS_TIMEOUT].procname = NULL;
-#endif
-
 		child[AX25_MAX_VALUES].ctl_name = 0;	/* just in case... */
 
 		for (k = 0; k < AX25_MAX_VALUES; k++)
