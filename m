From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.38 containers bug: Infinite loop in
 /proc/sys/net/ipv6/neigh/neigh/neigh...
Date: Wed, 30 Mar 2011 02:01:20 -0700 (PDT)
Message-ID: <20110330.020120.02272125.davem@davemloft.net>
References: <4D92E9DC.3070405@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org
To: rlandley@parallels.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D92E9DC.3070405@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Landley <rlandley@parallels.com>
Date: Wed, 30 Mar 2011 03:29:16 -0500

> In the host context a find on /proc completes, but inside an lxc
> container a find on /proc never completes, due to the endless loop in
> the title.  (It's not a symlink, it seems to be a cross linked directory.)
> 
> This is vanilla 2.6.38, I can attach my .config if you think it'd help.
>  (The container's the lxc debian sid template but that's probably not
> relevant.)

Please CC: netdev@vger.kernel.org when a bug might be related to
networking, as is obviously the case here.

This bug should be fixed by the following patch:

--------------------
commit 9d2a8fa96a44ba242de3a6f56acaef7a40a97b97
Author: Eric W. Biederman <ebiederm@aristanetworks.com>
Date:   Mon Mar 21 18:23:34 2011 -0700

    net ipv6: Fix duplicate /proc/sys/net/ipv6/neigh directory entries.
    
    When I was fixing issues with unregisgtering tables under /proc/sys/net/ipv6/neigh
    by adding a mount point it appears I missed a critical ordering issue, in the
    ipv6 initialization.  I had not realized that ipv6_sysctl_register is called
    at the very end of the ipv6 initialization and in particular after we call
    neigh_sysctl_register from ndisc_init.
    
    "neigh" needs to be initialized in ipv6_static_sysctl_register which is
    the first ipv6 table to initialized, and definitely before ndisc_init.
    This removes the weirdness of duplicate tables while still providing a
    "neigh" mount point which prevents races in sysctl unregistering.
    
    This was initially reported at https://bugzilla.kernel.org/show_bug.cgi?id=31232
    Reported-by: sunkan@zappa.cx
    Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 7cb65ef..6dcf5e7 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -17,6 +17,16 @@
 
 static struct ctl_table empty[1];
 
+static ctl_table ipv6_static_skeleton[] = {
+	{
+		.procname	= "neigh",
+		.maxlen		= 0,
+		.mode		= 0555,
+		.child		= empty,
+	},
+	{ }
+};
+
 static ctl_table ipv6_table_template[] = {
 	{
 		.procname	= "route",
@@ -37,12 +47,6 @@ static ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{
-		.procname	= "neigh",
-		.maxlen		= 0,
-		.mode		= 0555,
-		.child		= empty,
-	},
 	{ }
 };
 
@@ -160,7 +164,7 @@ static struct ctl_table_header *ip6_base;
 
 int ipv6_static_sysctl_register(void)
 {
-	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, empty);
+	ip6_base = register_sysctl_paths(net_ipv6_ctl_path, ipv6_static_skeleton);
 	if (ip6_base == NULL)
 		return -ENOMEM;
 	return 0;
