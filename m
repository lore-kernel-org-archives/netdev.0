From: OBATA Noboru <noboru.obata.ar@hitachi.com>
Subject: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Mon, 25 Jun 2007 22:09:39 +0900 (JST)
Message-ID: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.hitachi.co.jp ([133.145.228.42]:38375 "EHLO
	mail7.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885AbXFYNJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 09:09:43 -0400
Received: from mlsv18.hitachi.co.jp (unknown [133.144.234.166])
	by mail7.hitachi.co.jp (Postfix) with ESMTP id 93AC437ACB
	for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 22:09:40 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: OBATA Noboru <noboru.obata.ar@hitachi.com>

Make TCP_RTO_MAX a variable, and allow a user to change it via a
new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
then guarantee TCP retransmission to be more controllable, say,
at least once per 10 seconds, by setting it to 10.  This is
quite helpful on failover-capable network devices, such as an
active-backup bonding device.  On such devices, it is desirable
that TCP retransmits a packet shortly after the failover, which
is what I would like to do with this patch.  Please see
Background and Problem below for rationale in detail.

Reading from /proc/sys/net/ipv4/tcp_rto_max shows the current
TCP_RTO_MAX in seconds.  The actual value of TCP_RTO_MAX is
stored in sysctl_tcp_rto_max in jiffies.

Writing to /proc/sys/net/ipv4/tcp_rto_max updates the
TCP_RTO_MAX, only if the new value is not smaller than
TCP_RTO_MIN, which is currently 0.2[sec].  Since tcp_rto_max is
an integer, the minimum value of /proc/sys/net/ipv4/tcp_rto_max
is 1, in substance.  Also the RtoMax entry in /proc/net/snmp is
updated.

Please note that this is effective in IPv6 as well.


Background and Problem
======================

When designing a TCP/IP based network system on failover-capable
network devices, people want to set timeouts hierarchically in
three layers, network device layer, TCP layer, and application
layer (bottom-up order), such that:

1. Network device layer detects a failure first and switch to a
   backup device (say, in 20sec).

2. TCP layer timeout & retransmission comes next, _hopefully_
   before the application layer timeout.

3. Application layer detects a network failure last (by, say,
   30sec timeout) and may trigger a system-level failover.

   * Note 1.  The timeouts for #1 and #2 are handled
     independently and there is no relationship between them.

   * Note 2.  The actual timeout settings (20sec or 30sec in
     this example) are often determined by systems requirement
     and so setting them to certain "safe values" (if any) are
     usually not possible.

If TCP retransmission misses the time frame between event #1
and #3 in Background above (between 20 and 30sec since network
failure), a failure causes the system-level failover where the
network-device-level failover should be enough.

The problem in this hierarchical timeout scheme is that TCP
layer does not guarantee the next retransmission to occur in
certain period of time.  In the above example, people expect TCP
to retransmit a packet between 20 and 30sec since network
failure, but it may not happen.

Starting from RTO=0.5sec for example, retransmission will occur
at time 0.5, 1.5, 3.5, 7.5, 15.5, and 31.5 as indicated by 'o'
in the following diagram, but miss the time frame between time
20 and 30.

       time: 0         10        20        30sec
             |         |         |         |
  App. layer |---------+---------+---------X  ==> system failover
   TCP layer oo-o---o--+----o----+---------+o <== expects retrans. b/w 20~30
Netdev layer |---------+---------X            ==> network failover


Signed-off-by: OBATA Noboru <noboru.obata.ar@hitachi.com>
---

 Documentation/networking/ip-sysctl.txt |    6 +
 include/linux/sysctl.h                 |    1
 include/net/tcp.h                      |    5 +
 net/ipv4/sysctl_net_ipv4.c             |   77 +++++++++++++++++++++++++
 net/ipv4/tcp_timer.c                   |    3
 5 files changed, 91 insertions(+), 1 deletion(-)

diff -uprN -X a/Documentation/dontdiff linux-2.6.22-rc5-orig/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
--- a/Documentation/networking/ip-sysctl.txt	2007-06-22 21:34:18.000000000 +0900
+++ b/Documentation/networking/ip-sysctl.txt	2007-06-25 16:07:21.000000000 +0900
@@ -340,6 +340,12 @@ tcp_rmem - vector of 3 INTEGERs: min, de
 	net.core.rmem_max, "static" selection via SO_RCVBUF does not use this.
 	Default: 87380*2 bytes.
 
+tcp_rto_max - INTEGER
+	Maximum time in seconds to which RTO can grow.  Exponential
+	backoff of RTO is bounded by this value.  The value must not be
+	smaller than 1.  Note this parameter is also effective for IPv6.
+	Default: 120
+
 tcp_sack - BOOLEAN
 	Enable select acknowledgments (SACKS).
 
diff -uprN -X a/Documentation/dontdiff linux-2.6.22-rc5-orig/include/linux/sysctl.h b/include/linux/sysctl.h
--- a/include/linux/sysctl.h	2007-06-22 21:34:33.000000000 +0900
+++ b/include/linux/sysctl.h	2007-06-25 16:27:29.000000000 +0900
@@ -441,6 +441,7 @@ enum
 	NET_TCP_ALLOWED_CONG_CONTROL=123,
 	NET_TCP_MAX_SSTHRESH=124,
 	NET_TCP_FRTO_RESPONSE=125,
+	NET_TCP_RTO_MAX=126,
 };
 
 enum {
diff -uprN -X a/Documentation/dontdiff linux-2.6.22-rc5-orig/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2007-06-22 21:34:33.000000000 +0900
+++ b/include/net/tcp.h	2007-06-22 21:40:05.000000000 +0900
@@ -121,7 +121,9 @@ extern void tcp_time_wait(struct sock *s
 #define TCP_DELACK_MIN	4U
 #define TCP_ATO_MIN	4U
 #endif
-#define TCP_RTO_MAX	((unsigned)(120*HZ))
+extern int sysctl_tcp_rto_max;
+#define TCP_RTO_MAX	((unsigned)(sysctl_tcp_rto_max))
+#define TCP_RTO_MAX_DEFAULT	((unsigned)(120*HZ))
 #define TCP_RTO_MIN	((unsigned)(HZ/5))
 #define TCP_TIMEOUT_INIT ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value	*/
 
@@ -203,6 +205,7 @@ extern int sysctl_tcp_synack_retries;
 extern int sysctl_tcp_retries1;
 extern int sysctl_tcp_retries2;
 extern int sysctl_tcp_orphan_retries;
+extern int sysctl_tcp_rto_max;
 extern int sysctl_tcp_syncookies;
 extern int sysctl_tcp_retrans_collapse;
 extern int sysctl_tcp_stdurg;
diff -uprN -X a/Documentation/dontdiff linux-2.6.22-rc5-orig/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
--- a/net/ipv4/sysctl_net_ipv4.c	2007-06-22 21:34:33.000000000 +0900
+++ b/net/ipv4/sysctl_net_ipv4.c	2007-06-25 16:27:53.000000000 +0900
@@ -186,6 +186,74 @@ static int strategy_allowed_congestion_c
 
 }
 
+static int proc_tcp_rto_max(ctl_table *ctl, int write, struct file *filp,
+			    void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int val = *(int *)ctl->data;
+	int ret;
+
+	ret = proc_dointvec_jiffies(ctl, write, filp, buffer, lenp, ppos);
+	if (ret)
+		return ret;
+
+	if (write && *(int *)ctl->data != val) {
+		if (*(int *)ctl->data < TCP_RTO_MIN) {
+			*(int *)ctl->data = val;
+			return -EINVAL;
+		}
+		TCP_ADD_STATS_USER(TCP_MIB_RTOMAX,
+				   (*(int *)ctl->data - val) * 1000 / HZ);
+	}
+
+	return 0;
+}
+
+static int strategy_tcp_rto_max(ctl_table *table, int __user *name,
+				int nlen, void __user *oldval,
+				size_t __user *oldlenp,
+				void __user *newval, size_t newlen)
+{
+	int *valp = table->data;
+	int new;
+
+	if (!newval || !newlen)
+		return 0;
+
+	if (newlen != sizeof(int))
+		return -EINVAL;
+
+	if (get_user(new, (int __user *)newval))
+		return -EFAULT;
+
+	if (new * HZ == *valp)
+		return 0;
+
+	if (new * HZ < TCP_RTO_MIN)
+		return -EINVAL;
+
+	if (oldval && oldlenp) {
+		size_t len;
+
+		if (get_user(len, oldlenp))
+			return -EFAULT;
+
+		if (len) {
+			if (len > table->maxlen)
+				len = table->maxlen;
+			if (put_user(*valp / HZ, (int __user *)oldval))
+				return -EFAULT;
+			if (put_user(len, oldlenp))
+				return -EFAULT;
+		}
+	}
+
+	TCP_ADD_STATS_USER(TCP_MIB_RTOMAX, (new * HZ - *valp) * 1000 / HZ);
+
+	*valp = new * HZ;
+
+	return 1;
+}
+
 ctl_table ipv4_table[] = {
 	{
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -363,6 +431,15 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec
 	},
 	{
+		.ctl_name	= NET_TCP_RTO_MAX,
+		.procname	= "tcp_rto_max",
+		.data		= &sysctl_tcp_rto_max,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_tcp_rto_max,
+		.strategy	= &strategy_tcp_rto_max
+	},
+	{
 		.ctl_name	= NET_IPV4_TCP_FIN_TIMEOUT,
 		.procname	= "tcp_fin_timeout",
 		.data		= &sysctl_tcp_fin_timeout,
diff -uprN -X a/Documentation/dontdiff linux-2.6.22-rc5-orig/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
--- a/net/ipv4/tcp_timer.c	2007-06-22 21:34:33.000000000 +0900
+++ b/net/ipv4/tcp_timer.c	2007-06-22 21:39:35.000000000 +0900
@@ -31,6 +31,9 @@ int sysctl_tcp_keepalive_intvl __read_mo
 int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
 int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
 int sysctl_tcp_orphan_retries __read_mostly;
+int sysctl_tcp_rto_max __read_mostly = TCP_RTO_MAX_DEFAULT;
+
+EXPORT_SYMBOL(sysctl_tcp_rto_max);
 
 static void tcp_write_timer(unsigned long);
 static void tcp_delack_timer(unsigned long);
