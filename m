From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] inet: cleanup of local_port_range
Date: Wed, 08 Oct 2008 23:13:58 +0200
Message-ID: <48ED2296.1090003@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080305090908000508050401"
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp19.orange.fr ([80.12.242.17]:14479 "EHLO smtp19.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbYJHVOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 17:14:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080305090908000508050401
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I noticed sysctl_local_port_range[] and its associated seqlock
sysctl_local_port_range_lock were on separate cache lines.
Moreover, sysctl_local_port_range[] was close to unrelated
variables, highly modified, leading to cache misses.

Moving these two variables in a structure can help data
locality and moving this structure to read_mostly section
helps sharing of this data among cpus.

Cleanup of extern declarations (moved in include file where
they belong), and use of inet_get_local_port_range()
accessor instead of direct access to ports values.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------080305090908000508050401
Content-Type: text/plain;
 name="local_ports.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="local_ports.patch"

diff --git a/include/net/ip.h b/include/net/ip.h
index d678ea3..2a77dde 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -178,6 +178,10 @@ extern unsigned long snmp_fold_field(void *mib[], int offt);
 extern int snmp_mib_init(void *ptr[2], size_t mibsize);
 extern void snmp_mib_free(void *ptr[2]);
 
+extern struct local_ports {
+	seqlock_t	lock;
+	int		range[2];
+	} sysctl_local_ports;
 extern void inet_get_local_port_range(int *low, int *high);
 
 extern int sysctl_ip_default_ttl;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 21fcc5a..bd1278a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -30,20 +30,22 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
 #endif
 
 /*
- * This array holds the first and last local port number.
+ * This struct holds the first and last local port number.
  */
-int sysctl_local_port_range[2] = { 32768, 61000 };
-DEFINE_SEQLOCK(sysctl_port_range_lock);
+struct local_ports sysctl_local_ports __read_mostly = {
+	.lock = SEQLOCK_UNLOCKED,
+	.range = { 32768, 61000 },
+};
 
 void inet_get_local_port_range(int *low, int *high)
 {
 	unsigned seq;
 	do {
-		seq = read_seqbegin(&sysctl_port_range_lock);
+		seq = read_seqbegin(&sysctl_local_ports.lock);
 
-		*low = sysctl_local_port_range[0];
-		*high = sysctl_local_port_range[1];
-	} while (read_seqretry(&sysctl_port_range_lock, seq));
+		*low = sysctl_local_ports.range[0];
+		*high = sysctl_local_ports.range[1];
+	} while (read_seqretry(&sysctl_local_ports.lock, seq));
 }
 EXPORT_SYMBOL(inet_get_local_port_range);
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e0689fd..276d047 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -26,16 +26,13 @@ static int tcp_retr1_max = 255;
 static int ip_local_port_range_min[] = { 1, 1 };
 static int ip_local_port_range_max[] = { 65535, 65535 };
 
-extern seqlock_t sysctl_port_range_lock;
-extern int sysctl_local_port_range[2];
-
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
 {
-	write_seqlock(&sysctl_port_range_lock);
-	sysctl_local_port_range[0] = range[0];
-	sysctl_local_port_range[1] = range[1];
-	write_sequnlock(&sysctl_port_range_lock);
+	write_seqlock(&sysctl_local_ports.lock);
+	sysctl_local_ports.range[0] = range[0];
+	sysctl_local_ports.range[1] = range[1];
+	write_sequnlock(&sysctl_local_ports.lock);
 }
 
 /* Validate changes from /proc interface. */
@@ -44,8 +41,7 @@ static int ipv4_local_port_range(ctl_table *table, int write, struct file *filp,
 				 size_t *lenp, loff_t *ppos)
 {
 	int ret;
-	int range[2] = { sysctl_local_port_range[0],
-			 sysctl_local_port_range[1] };
+	int range[2];
 	ctl_table tmp = {
 		.data = &range,
 		.maxlen = sizeof(range),
@@ -54,6 +50,7 @@ static int ipv4_local_port_range(ctl_table *table, int write, struct file *filp,
 		.extra2 = &ip_local_port_range_max,
 	};
 
+	inet_get_local_port_range(range, range + 1);
 	ret = proc_dointvec_minmax(&tmp, write, filp, buffer, lenp, ppos);
 
 	if (write && ret == 0) {
@@ -73,8 +70,7 @@ static int ipv4_sysctl_local_port_range(ctl_table *table, int __user *name,
 					void __user *newval, size_t newlen)
 {
 	int ret;
-	int range[2] = { sysctl_local_port_range[0],
-			 sysctl_local_port_range[1] };
+	int range[2];
 	ctl_table tmp = {
 		.data = &range,
 		.maxlen = sizeof(range),
@@ -83,6 +79,7 @@ static int ipv4_sysctl_local_port_range(ctl_table *table, int __user *name,
 		.extra2 = &ip_local_port_range_max,
 	};
 
+	inet_get_local_port_range(range, range + 1);
 	ret = sysctl_intvec(&tmp, name, nlen, oldval, oldlenp, newval, newlen);
 	if (ret == 0 && newval && newlen) {
 		if (range[1] < range[0])
@@ -396,8 +393,8 @@ static struct ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_LOCAL_PORT_RANGE,
 		.procname	= "ip_local_port_range",
-		.data		= &sysctl_local_port_range,
-		.maxlen		= sizeof(sysctl_local_port_range),
+		.data		= &sysctl_local_ports.range,
+		.maxlen		= sizeof(sysctl_local_ports.range),
 		.mode		= 0644,
 		.proc_handler	= &ipv4_local_port_range,
 		.strategy	= &ipv4_sysctl_local_port_range,

--------------080305090908000508050401--


