From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH -next] sysctl: simplify ->strategy
Date: Thu, 28 Aug 2008 09:02:03 +0400
Message-ID: <20080828050203.GA7608@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:53213 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbYH1FAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 01:00:31 -0400
Received: by ey-out-2122.google.com with SMTP id 6so61121eyi.37
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 22:00:29 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

name and nlen parameters passed to ->strategy hook are unused, remove them.
In general ->strategy hook should know what it's doing, and don't do
something tricky for which, say, pointer to original userspace array may
be needed (name).

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 arch/frv/kernel/pm.c           |    6 +++---
 arch/mips/lasat/sysctl.c       |   17 ++++++++---------
 drivers/char/random.c          |    2 +-
 include/linux/sysctl.h         |    2 +-
 include/net/ip.h               |    2 +-
 include/net/ndisc.h            |    5 ++---
 ipc/ipc_sysctl.c               |    9 ++++-----
 kernel/sysctl.c                |   29 +++++++++++++----------------
 kernel/utsname_sysctl.c        |    5 ++---
 net/decnet/dn_dev.c            |    4 ++--
 net/decnet/sysctl_net_decnet.c |    4 ++--
 net/ipv4/devinet.c             |    7 +++----
 net/ipv4/route.c               |    7 +------
 net/ipv4/sysctl_net_ipv4.c     |   18 +++++++++---------
 net/ipv6/addrconf.c            |    1 -
 net/ipv6/ndisc.c               |   11 ++++-------
 16 files changed, 56 insertions(+), 73 deletions(-)

--- a/arch/frv/kernel/pm.c
+++ b/arch/frv/kernel/pm.c
@@ -211,7 +211,7 @@ static int cmode_procctl(ctl_table *ctl, int write, struct file *filp,
 	return try_set_cmode(new_cmode)?:*lenp;
 }
 
-static int cmode_sysctl(ctl_table *table, int __user *name, int nlen,
+static int cmode_sysctl(ctl_table *table,
 			void __user *oldval, size_t __user *oldlenp,
 			void __user *newval, size_t newlen)
 {
@@ -314,7 +314,7 @@ static int p0_procctl(ctl_table *ctl, int write, struct file *filp,
 	return try_set_p0(new_p0)?:*lenp;
 }
 
-static int p0_sysctl(ctl_table *table, int __user *name, int nlen,
+static int p0_sysctl(ctl_table *table,
 		     void __user *oldval, size_t __user *oldlenp,
 		     void __user *newval, size_t newlen)
 {
@@ -358,7 +358,7 @@ static int cm_procctl(ctl_table *ctl, int write, struct file *filp,
 	return try_set_cm(new_cm)?:*lenp;
 }
 
-static int cm_sysctl(ctl_table *table, int __user *name, int nlen,
+static int cm_sysctl(ctl_table *table,
 		     void __user *oldval, size_t __user *oldlenp,
 		     void __user *newval, size_t newlen)
 {
--- a/arch/mips/lasat/sysctl.c
+++ b/arch/mips/lasat/sysctl.c
@@ -38,14 +38,13 @@
 #endif
 
 /* Strategy function to write EEPROM after changing string entry */
-int sysctl_lasatstring(ctl_table *table, int *name, int nlen,
+int sysctl_lasatstring(ctl_table *table,
 		void *oldval, size_t *oldlenp,
 		void *newval, size_t newlen)
 {
 	int r;
 
-	r = sysctl_string(table, name,
-			  nlen, oldval, oldlenp, newval, newlen);
+	r = sysctl_string(table, oldval, oldlenp, newval, newlen);
 	if (r < 0)
 		return r;
 
@@ -113,13 +112,13 @@ int proc_dolasatrtc(ctl_table *table, int write, struct file *filp,
 #endif
 
 /* Sysctl for setting the IP addresses */
-int sysctl_lasat_intvec(ctl_table *table, int *name, int nlen,
+int sysctl_lasat_intvec(ctl_table *table,
 		    void *oldval, size_t *oldlenp,
 		    void *newval, size_t newlen)
 {
 	int r;
 
-	r = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+	r = sysctl_intvec(table, oldval, oldlenp, newval, newlen);
 	if (r < 0)
 		return r;
 
@@ -131,7 +130,7 @@ int sysctl_lasat_intvec(ctl_table *table, int *name, int nlen,
 
 #ifdef CONFIG_DS1603
 /* Same for RTC */
-int sysctl_lasat_rtc(ctl_table *table, int *name, int nlen,
+int sysctl_lasat_rtc(ctl_table *table,
 		    void *oldval, size_t *oldlenp,
 		    void *newval, size_t newlen)
 {
@@ -140,7 +139,7 @@ int sysctl_lasat_rtc(ctl_table *table, int *name, int nlen,
 	rtctmp = read_persistent_clock();
 	if (rtctmp < 0)
 		rtctmp = 0;
-	r = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+	r = sysctl_intvec(table, oldval, oldlenp, newval, newlen);
 	if (r < 0)
 		return r;
 	if (newval && newlen)
@@ -211,13 +210,13 @@ int proc_lasat_ip(ctl_table *table, int write, struct file *filp,
 }
 #endif
 
-static int sysctl_lasat_prid(ctl_table *table, int *name, int nlen,
+static int sysctl_lasat_prid(ctl_table *table,
 				     void *oldval, size_t *oldlenp,
 				     void *newval, size_t newlen)
 {
 	int r;
 
-	r = sysctl_intvec(table, name, nlen, oldval, oldlenp, newval, newlen);
+	r = sysctl_intvec(table, oldval, oldlenp, newval, newlen);
 	if (r < 0)
 		return r;
 	if (newval && newlen) {
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1266,7 +1266,7 @@ static int proc_do_uuid(ctl_table *table, int write, struct file *filp,
 	return proc_dostring(&fake_table, write, filp, buffer, lenp, ppos);
 }
 
-static int uuid_strategy(ctl_table *table, int __user *name, int nlen,
+static int uuid_strategy(ctl_table *table,
 			 void __user *oldval, size_t __user *oldlenp,
 			 void __user *newval, size_t newlen)
 {
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -972,7 +972,7 @@ extern int sysctl_perm(struct ctl_table_root *root,
 
 typedef struct ctl_table ctl_table;
 
-typedef int ctl_handler (struct ctl_table *table, int __user *name, int nlen,
+typedef int ctl_handler (struct ctl_table *table,
 			 void __user *oldval, size_t __user *oldlenp,
 			 void __user *newval, size_t newlen);
 
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -383,7 +383,7 @@ extern void	ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
 int ipv4_doint_and_flush(ctl_table *ctl, int write,
 			 struct file* filp, void __user *buffer,
 			 size_t *lenp, loff_t *ppos);
-int ipv4_doint_and_flush_strategy(ctl_table *table, int __user *name, int nlen,
+int ipv4_doint_and_flush_strategy(ctl_table *table,
 				  void __user *oldval, size_t __user *oldlenp,
 				  void __user *newval, size_t newlen);
 #ifdef CONFIG_PROC_FS
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -129,9 +129,8 @@ extern int 			ndisc_ifinfo_sysctl_change(struct ctl_table *ctl,
 							   void __user *buffer,
 							   size_t *lenp,
 							   loff_t *ppos);
-int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name,
-				 int nlen, void __user *oldval,
-				 size_t __user *oldlenp,
+int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl,
+				 void __user *oldval, size_t __user *oldlenp,
 				 void __user *newval, size_t newlen);
 #endif
 
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -131,7 +131,7 @@ static int proc_ipcauto_dointvec_minmax(ctl_table *table, int write,
 
 #ifdef CONFIG_SYSCTL_SYSCALL
 /* The generic sysctl ipc data routine. */
-static int sysctl_ipc_data(ctl_table *table, int __user *name, int nlen,
+static int sysctl_ipc_data(ctl_table *table,
 		void __user *oldval, size_t __user *oldlenp,
 		void __user *newval, size_t newlen)
 {
@@ -169,14 +169,13 @@ static int sysctl_ipc_data(ctl_table *table, int __user *name, int nlen,
 	return 1;
 }
 
-static int sysctl_ipc_registered_data(ctl_table *table, int __user *name,
-		int nlen, void __user *oldval, size_t __user *oldlenp,
+static int sysctl_ipc_registered_data(ctl_table *table,
+		void __user *oldval, size_t __user *oldlenp,
 		void __user *newval, size_t newlen)
 {
 	int rc;
 
-	rc = sysctl_ipc_data(table, name, nlen, oldval, oldlenp, newval,
-		newlen);
+	rc = sysctl_ipc_data(table, oldval, oldlenp, newval, newlen);
 
 	if (newval && newlen && rc > 0)
 		/*
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1545,7 +1545,6 @@ void register_sysctl_root(struct ctl_table_root *root)
 /* Perform the actual read/write of a sysctl table entry. */
 static int do_sysctl_strategy(struct ctl_table_root *root,
 			struct ctl_table *table,
-			int __user *name, int nlen,
 			void __user *oldval, size_t __user *oldlenp,
 			void __user *newval, size_t newlen)
 {
@@ -1559,8 +1558,7 @@ static int do_sysctl_strategy(struct ctl_table_root *root,
 		return -EPERM;
 
 	if (table->strategy) {
-		rc = table->strategy(table, name, nlen, oldval, oldlenp,
-				     newval, newlen);
+		rc = table->strategy(table, oldval, oldlenp, newval, newlen);
 		if (rc < 0)
 			return rc;
 		if (rc > 0)
@@ -1570,8 +1568,7 @@ static int do_sysctl_strategy(struct ctl_table_root *root,
 	/* If there is no strategy routine, or if the strategy returns
 	 * zero, proceed with automatic r/w */
 	if (table->data && table->maxlen) {
-		rc = sysctl_data(table, name, nlen, oldval, oldlenp,
-				 newval, newlen);
+		rc = sysctl_data(table, oldval, oldlenp, newval, newlen);
 		if (rc < 0)
 			return rc;
 	}
@@ -1603,7 +1600,7 @@ repeat:
 				table = table->child;
 				goto repeat;
 			}
-			error = do_sysctl_strategy(root, table, name, nlen,
+			error = do_sysctl_strategy(root, table,
 						   oldval, oldlenp,
 						   newval, newlen);
 			return error;
@@ -2762,7 +2759,7 @@ int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
  */
 
 /* The generic sysctl data routine (used if no strategy routine supplied) */
-int sysctl_data(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_data(struct ctl_table *table,
 		void __user *oldval, size_t __user *oldlenp,
 		void __user *newval, size_t newlen)
 {
@@ -2796,7 +2793,7 @@ int sysctl_data(struct ctl_table *table, int __user *name, int nlen,
 }
 
 /* The generic string strategy routine: */
-int sysctl_string(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_string(struct ctl_table *table,
 		  void __user *oldval, size_t __user *oldlenp,
 		  void __user *newval, size_t newlen)
 {
@@ -2842,7 +2839,7 @@ int sysctl_string(struct ctl_table *table, int __user *name, int nlen,
  * are between the minimum and maximum values given in the arrays
  * table->extra1 and table->extra2, respectively.
  */
-int sysctl_intvec(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_intvec(struct ctl_table *table,
 		void __user *oldval, size_t __user *oldlenp,
 		void __user *newval, size_t newlen)
 {
@@ -2878,7 +2875,7 @@ int sysctl_intvec(struct ctl_table *table, int __user *name, int nlen,
 }
 
 /* Strategy function to convert jiffies to seconds */ 
-int sysctl_jiffies(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_jiffies(struct ctl_table *table,
 		void __user *oldval, size_t __user *oldlenp,
 		void __user *newval, size_t newlen)
 {
@@ -2912,7 +2909,7 @@ int sysctl_jiffies(struct ctl_table *table, int __user *name, int nlen,
 }
 
 /* Strategy function to convert jiffies to seconds */ 
-int sysctl_ms_jiffies(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_ms_jiffies(struct ctl_table *table,
 		void __user *oldval, size_t __user *oldlenp,
 		void __user *newval, size_t newlen)
 {
@@ -2967,35 +2964,35 @@ asmlinkage long sys_sysctl(struct __sysctl_args __user *args)
 	return error;
 }
 
-int sysctl_data(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_data(struct ctl_table *table,
 		  void __user *oldval, size_t __user *oldlenp,
 		  void __user *newval, size_t newlen)
 {
 	return -ENOSYS;
 }
 
-int sysctl_string(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_string(struct ctl_table *table,
 		  void __user *oldval, size_t __user *oldlenp,
 		  void __user *newval, size_t newlen)
 {
 	return -ENOSYS;
 }
 
-int sysctl_intvec(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_intvec(struct ctl_table *table,
 		void __user *oldval, size_t __user *oldlenp,
 		void __user *newval, size_t newlen)
 {
 	return -ENOSYS;
 }
 
-int sysctl_jiffies(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_jiffies(struct ctl_table *table,
 		void __user *oldval, size_t __user *oldlenp,
 		void __user *newval, size_t newlen)
 {
 	return -ENOSYS;
 }
 
-int sysctl_ms_jiffies(struct ctl_table *table, int __user *name, int nlen,
+int sysctl_ms_jiffies(struct ctl_table *table,
 		void __user *oldval, size_t __user *oldlenp,
 		void __user *newval, size_t newlen)
 {
--- a/kernel/utsname_sysctl.c
+++ b/kernel/utsname_sysctl.c
@@ -60,7 +60,7 @@ static int proc_do_uts_string(ctl_table *table, int write, struct file *filp,
 
 #ifdef CONFIG_SYSCTL_SYSCALL
 /* The generic string strategy routine: */
-static int sysctl_uts_string(ctl_table *table, int __user *name, int nlen,
+static int sysctl_uts_string(ctl_table *table,
 		  void __user *oldval, size_t __user *oldlenp,
 		  void __user *newval, size_t newlen)
 {
@@ -69,8 +69,7 @@ static int sysctl_uts_string(ctl_table *table, int __user *name, int nlen,
 	write = newval && newlen;
 	memcpy(&uts_table, table, sizeof(uts_table));
 	uts_table.data = get_uts(table, write);
-	r = sysctl_string(&uts_table, name, nlen,
-		oldval, oldlenp, newval, newlen);
+	r = sysctl_string(&uts_table, oldval, oldlenp, newval, newlen);
 	put_uts(table, write, uts_table.data);
 	return r;
 }
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -166,7 +166,7 @@ static int max_priority[] = { 127 }; /* From DECnet spec */
 
 static int dn_forwarding_proc(ctl_table *, int, struct file *,
 			void __user *, size_t *, loff_t *);
-static int dn_forwarding_sysctl(ctl_table *table, int __user *name, int nlen,
+static int dn_forwarding_sysctl(ctl_table *table,
 			void __user *oldval, size_t __user *oldlenp,
 			void __user *newval, size_t newlen);
 
@@ -318,7 +318,7 @@ static int dn_forwarding_proc(ctl_table *table, int write,
 #endif
 }
 
-static int dn_forwarding_sysctl(ctl_table *table, int __user *name, int nlen,
+static int dn_forwarding_sysctl(ctl_table *table,
 			void __user *oldval, size_t __user *oldlenp,
 			void __user *newval, size_t newlen)
 {
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -132,7 +132,7 @@ static int parse_addr(__le16 *addr, char *str)
 }
 
 
-static int dn_node_address_strategy(ctl_table *table, int __user *name, int nlen,
+static int dn_node_address_strategy(ctl_table *table,
 				void __user *oldval, size_t __user *oldlenp,
 				void __user *newval, size_t newlen)
 {
@@ -217,7 +217,7 @@ static int dn_node_address_handler(ctl_table *table, int write,
 }
 
 
-static int dn_def_dev_strategy(ctl_table *table, int __user *name, int nlen,
+static int dn_def_dev_strategy(ctl_table *table,
 				void __user *oldval, size_t __user *oldlenp,
 				void __user *newval, size_t newlen)
 {
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1272,7 +1272,7 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 	return ret;
 }
 
-static int devinet_conf_sysctl(ctl_table *table, int __user *name, int nlen,
+static int devinet_conf_sysctl(ctl_table *table,
 			       void __user *oldval, size_t __user *oldlenp,
 			       void __user *newval, size_t newlen)
 {
@@ -1368,12 +1368,11 @@ int ipv4_doint_and_flush(ctl_table *ctl, int write,
 	return ret;
 }
 
-int ipv4_doint_and_flush_strategy(ctl_table *table, int __user *name, int nlen,
+int ipv4_doint_and_flush_strategy(ctl_table *table,
 				  void __user *oldval, size_t __user *oldlenp,
 				  void __user *newval, size_t newlen)
 {
-	int ret = devinet_conf_sysctl(table, name, nlen, oldval, oldlenp,
-				      newval, newlen);
+	int ret = devinet_conf_sysctl(table, oldval, oldlenp, newval, newlen);
 	struct net *net = table->extra2;
 
 	if (ret == 1)
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2896,8 +2896,6 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 }
 
 static int ipv4_sysctl_rtcache_flush_strategy(ctl_table *table,
-						int __user *name,
-						int nlen,
 						void __user *oldval,
 						size_t __user *oldlenp,
 						void __user *newval,
@@ -2960,16 +2958,13 @@ static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
 }
 
 static int ipv4_sysctl_rt_secret_interval_strategy(ctl_table *table,
-						   int __user *name,
-						   int nlen,
 						   void __user *oldval,
 						   size_t __user *oldlenp,
 						   void __user *newval,
 						   size_t newlen)
 {
 	int old = ip_rt_secret_interval;
-	int ret = sysctl_jiffies(table, name, nlen, oldval, oldlenp, newval,
-				 newlen);
+	int ret = sysctl_jiffies(table, oldval, oldlenp, newval, newlen);
 
 	rt_secret_reschedule(old);
 
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -67,8 +67,8 @@ static int ipv4_local_port_range(ctl_table *table, int write, struct file *filp,
 }
 
 /* Validate changes from sysctl interface. */
-static int ipv4_sysctl_local_port_range(ctl_table *table, int __user *name,
-					 int nlen, void __user *oldval,
+static int ipv4_sysctl_local_port_range(ctl_table *table,
+					 void __user *oldval,
 					 size_t __user *oldlenp,
 					void __user *newval, size_t newlen)
 {
@@ -83,7 +83,7 @@ static int ipv4_sysctl_local_port_range(ctl_table *table, int __user *name,
 		.extra2 = &ip_local_port_range_max,
 	};
 
-	ret = sysctl_intvec(&tmp, name, nlen, oldval, oldlenp, newval, newlen);
+	ret = sysctl_intvec(&tmp, oldval, oldlenp, newval, newlen);
 	if (ret == 0 && newval && newlen) {
 		if (range[1] < range[0])
 			ret = -EINVAL;
@@ -112,8 +112,8 @@ static int proc_tcp_congestion_control(ctl_table *ctl, int write, struct file *
 	return ret;
 }
 
-static int sysctl_tcp_congestion_control(ctl_table *table, int __user *name,
-					 int nlen, void __user *oldval,
+static int sysctl_tcp_congestion_control(ctl_table *table,
+					 void __user *oldval,
 					 size_t __user *oldlenp,
 					 void __user *newval, size_t newlen)
 {
@@ -125,7 +125,7 @@ static int sysctl_tcp_congestion_control(ctl_table *table, int __user *name,
 	int ret;
 
 	tcp_get_default_congestion_control(val);
-	ret = sysctl_string(&tbl, name, nlen, oldval, oldlenp, newval, newlen);
+	ret = sysctl_string(&tbl, oldval, oldlenp, newval, newlen);
 	if (ret == 1 && newval && newlen)
 		ret = tcp_set_default_congestion_control(val);
 	return ret;
@@ -168,8 +168,8 @@ static int proc_allowed_congestion_control(ctl_table *ctl,
 	return ret;
 }
 
-static int strategy_allowed_congestion_control(ctl_table *table, int __user *name,
-					       int nlen, void __user *oldval,
+static int strategy_allowed_congestion_control(ctl_table *table,
+					       void __user *oldval,
 					       size_t __user *oldlenp,
 					       void __user *newval,
 					       size_t newlen)
@@ -182,7 +182,7 @@ static int strategy_allowed_congestion_control(ctl_table *table, int __user *nam
 		return -ENOMEM;
 
 	tcp_get_available_congestion_control(tbl.data, tbl.maxlen);
-	ret = sysctl_string(&tbl, name, nlen, oldval, oldlenp, newval, newlen);
+	ret = sysctl_string(&tbl, oldval, oldlenp, newval, newlen);
 	if (ret == 1 && newval && newlen)
 		ret = tcp_set_allowed_congestion_control(tbl.data);
 	kfree(tbl.data);
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3982,7 +3982,6 @@ int addrconf_sysctl_forward(ctl_table *ctl, int write, struct file * filp,
 }
 
 static int addrconf_sysctl_forward_strategy(ctl_table *table,
-					    int __user *name, int nlen,
 					    void __user *oldval,
 					    size_t __user *oldlenp,
 					    void __user *newval, size_t newlen)
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1730,9 +1730,8 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, struct file * f
 	return ret;
 }
 
-int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name,
-				 int nlen, void __user *oldval,
-				 size_t __user *oldlenp,
+int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl,
+				 void __user *oldval, size_t __user *oldlenp,
 				 void __user *newval, size_t newlen)
 {
 	struct net_device *dev = ctl->extra1;
@@ -1745,13 +1744,11 @@ int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl, int __user *name,
 
 	switch (ctl->ctl_name) {
 	case NET_NEIGH_REACHABLE_TIME:
-		ret = sysctl_jiffies(ctl, name, nlen,
-				     oldval, oldlenp, newval, newlen);
+		ret = sysctl_jiffies(ctl, oldval, oldlenp, newval, newlen);
 		break;
 	case NET_NEIGH_RETRANS_TIME_MS:
 	case NET_NEIGH_REACHABLE_TIME_MS:
-		 ret = sysctl_ms_jiffies(ctl, name, nlen,
-					 oldval, oldlenp, newval, newlen);
+		 ret = sysctl_ms_jiffies(ctl, oldval, oldlenp, newval, newlen);
 		 break;
 	default:
 		ret = 0;

