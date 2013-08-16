From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH 2/3] [RFC] TCP syncookies: introduce sysctl to configure the
 MSS tables
Date: Fri, 16 Aug 2013 02:03:03 +0200
Message-ID: <20130816000303.GB11950@midget.suse.cz>
References: <520A3B4A.1050704@jakoblell.com>
 <20130815235743.GA25665@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakob Lell <jakob@jakoblell.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46309 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767Ab3HPADI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Aug 2013 20:03:08 -0400
Content-Disposition: inline
In-Reply-To: <20130815235743.GA25665@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(compile-tested only)

This patch introduces two new sysctls
	net.ipv4.tcp_syncookies_mss_table
	net.ipv6.tcp_syncookies_mss_table
to manipulate the TCP syncookie MSS tables

Signed-off-by: Jiri Bohac <jbohac@suse.cz>
---
 Documentation/networking/ip-sysctl.txt | 22 +++++++++++--
 include/net/tcp.h                      |  9 ++++++
 net/ipv4/syncookies.c                  | 13 +++++---
 net/ipv4/sysctl_net_ipv4.c             | 57 ++++++++++++++++++++++++++++++++++
 net/ipv6/syncookies.c                  | 13 +++++---
 net/ipv6/sysctl_net_ipv6.c             | 20 ++++++++++++
 6 files changed, 122 insertions(+), 12 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 1074290..f49a741 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -440,6 +440,20 @@ tcp_syncookies - BOOLEAN
 	SYN flood warnings in logs not being really flooded, your server
 	is seriously misconfigured.
 
+tcp_syncookies_mss_table - vector of INTEGERs
+	TCP connections initiated with TCP syncookies are limited to a
+	pre-defined set of MSS values. The more possible values, the better
+	the MSS can correspond with the MSS originally sent by the client.
+	However, more possible MSS values means less effort tu successfully 
+	spoof a TCP sonnection.
+
+	The sysctl is an array of possible MSS values, sorted from smallest to
+	largest. If a zero value is present, all following values will be
+	ignored.
+
+	This setting only applies to TCP over IPv4. IPv6 has its own sysctl.
+
+
 tcp_fastopen - INTEGER
 	Enable TCP Fast Open feature (draft-ietf-tcpm-fastopen) to send data
 	in the opening SYN packet. To use this feature, the client application
@@ -1042,8 +1056,12 @@ delon.nicolas@wanadoo.fr
 
 /proc/sys/net/ipv6/* Variables:
 
-IPv6 has no global variables such as tcp_*.  tcp_* settings under ipv4/ also
-apply to IPv6 [XXX?].
+tcp_syncookies_mss_table - vector of INTEGERs
+	see the TCP/IPv4 description 
+
+
+IPv6 has no other global variables such as tcp_*.  tcp_* settings under ipv4/ i
+also apply to IPv6 [XXX?].
 
 bindv6only - BOOLEAN
 	Default value for IPV6_V6ONLY socket option,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index d198005..460ffe9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -482,8 +482,15 @@ extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
 				    struct ip_options *opt);
 #ifdef CONFIG_SYN_COOKIES
+#define TCP_SYNCOOKIES_MSS_COUNT_MAX 8
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
 				     __u16 *mss);
+extern int sysctl_tcp4_syncookies_mss[TCP_SYNCOOKIES_MSS_COUNT_MAX];
+extern int sysctl_tcp4_syncookies_mss_count;
+int tcp_syncookies_mss_sysctl(struct ctl_table *ctl, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos, int *count);
+
 #else
 static inline __u32 cookie_v4_init_sequence(struct sock *sk,
 					    struct sk_buff *skb,
@@ -502,6 +509,8 @@ extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb);
 #ifdef CONFIG_SYN_COOKIES
 extern __u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb,
 				     __u16 *mss);
+extern int sysctl_tcp6_syncookies_mss[TCP_SYNCOOKIES_MSS_COUNT_MAX];
+extern int sysctl_tcp6_syncookies_mss_count;
 #else
 static inline __u32 cookie_v6_init_sequence(struct sock *sk,
 					    struct sk_buff *skb,
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index cf1b720..af0692f 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -145,7 +145,7 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, __be32 saddr, __be32 daddr,
  *
  * Table must be sorted.
  */
-static __u16 const msstab[] = {
+int sysctl_tcp4_syncookies_mss[TCP_SYNCOOKIES_MSS_COUNT_MAX] = {
 	64,
 	512,
 	536,
@@ -154,7 +154,9 @@ static __u16 const msstab[] = {
 	1460,
 	4312,
 	8960,
+	/* update sysctl_tcp4_syncookies_mss_count accordingly */
 };
+int sysctl_tcp4_syncookies_mss_count = 8;
 
 /*
  * This value is the age (in seconds) of syncookies which will always be
@@ -179,10 +181,10 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
 
 	tcp_synq_overflow(sk);
 
-	for (mssind = ARRAY_SIZE(msstab) - 1; mssind ; mssind--)
-		if (mss >= msstab[mssind])
+	for (mssind = sysctl_tcp4_syncookies_mss_count - 1; mssind ; mssind--)
+		if (mss >= sysctl_tcp4_syncookies_mss[mssind])
 			break;
-	*mssp = msstab[mssind];
+	*mssp = sysctl_tcp4_syncookies_mss[mssind];
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
 
@@ -204,7 +206,8 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 					    th->source, th->dest, seq,
 					    jiffies / (HZ * 60 * COOKIE_LIFETIME));
 
-	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
+	return mssind < sysctl_tcp4_syncookies_mss_count ?
+		sysctl_tcp4_syncookies_mss[mssind] : 0;
 }
 
 static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 610e324..b2e9266 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -235,6 +235,57 @@ static int ipv4_tcp_mem(struct ctl_table *ctl, int write,
 	return 0;
 }
 
+#ifdef CONFIG_SYN_COOKIES
+int tcp_syncookies_mss_sysctl(struct ctl_table *ctl, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos, int *count)
+{
+	int *table = ctl->data;
+	int old_table[TCP_SYNCOOKIES_MSS_COUNT_MAX];
+	int old_count, err, i, prev = 0;
+
+	if (write) {
+		memcpy(old_table, table, sizeof(old_table));
+		old_count = *count;
+		memset(ctl->data, 0, sizeof(old_table));
+	}
+
+	err = proc_dointvec(ctl, write, buffer, lenp, ppos);
+	if (!write)
+		return err;
+	if (err)
+		goto restore;
+
+	for (i = 0; i < TCP_SYNCOOKIES_MSS_COUNT_MAX; ++i) {
+		if (!table[i])
+			break;
+		if (table[i] < 64 ||
+		    table[i] > 65536 ||
+		    prev >= table[i]) {
+			err = -EINVAL;
+			goto restore;
+		}
+		prev = table[i];
+	}
+	*count = i;
+
+	return err;
+restore:
+	*count = old_count;
+	memcpy(table, old_table, sizeof(old_table));
+	return err;
+}
+EXPORT_SYMBOL(tcp_syncookies_mss_sysctl);
+
+static int tcp4_syncookies_mss_sysctl(struct ctl_table *ctl, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos)
+{
+	return tcp_syncookies_mss_sysctl(ctl, write, buffer, lenp, ppos,
+					   &sysctl_tcp4_syncookies_mss_count);
+}
+#endif
+
 static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 				 void __user *buffer, size_t *lenp,
 				 loff_t *ppos)
@@ -424,6 +474,13 @@ static struct ctl_table ipv4_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "tcp_syncookies_mss_table",
+		.data		= &sysctl_tcp4_syncookies_mss,
+		.maxlen		= sizeof(sysctl_tcp4_syncookies_mss),
+		.mode		= 0644,
+		.proc_handler	= tcp4_syncookies_mss_sysctl,
+	},
 #endif
 	{
 		.procname	= "tcp_fastopen",
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 46e8b27..4268448 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -25,7 +25,7 @@
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
 /* Table must be sorted. */
-static __u16 const msstab[] = {
+int sysctl_tcp6_syncookies_mss[TCP_SYNCOOKIES_MSS_COUNT_MAX] = {
 	64,
 	512,
 	536,
@@ -34,7 +34,9 @@ static __u16 const msstab[] = {
 	1500 - 60,
 	4460 - 60,
 	9000 - 60,
+	/* update sysctl_tcp6_syncookies_mss_count accordingly */
 };
+int sysctl_tcp6_syncookies_mss_count = 8;
 
 /*
  * This value is the age (in seconds) of syncookies which will always be
@@ -122,11 +124,11 @@ __u32 cookie_v6_init_sequence(struct sock *sk, const struct sk_buff *skb, __u16
 
 	tcp_synq_overflow(sk);
 
-	for (mssind = ARRAY_SIZE(msstab) - 1; mssind ; mssind--)
-		if (mss >= msstab[mssind])
+	for (mssind = sysctl_tcp6_syncookies_mss_count; mssind ; mssind--)
+		if (mss >= sysctl_tcp6_syncookies_mss[mssind])
 			break;
 
-	*mssp = msstab[mssind];
+	*mssp = sysctl_tcp6_syncookies_mss[mssind];
 
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
 
@@ -144,7 +146,8 @@ static inline int cookie_check(const struct sk_buff *skb, __u32 cookie)
 					    th->source, th->dest, seq,
 					    jiffies / (HZ * 60 * COOKIE_LIFETIME));
 
-	return mssind < ARRAY_SIZE(msstab) ? msstab[mssind] : 0;
+	return mssind < sysctl_tcp6_syncookies_mss_count ?
+		sysctl_tcp6_syncookies_mss[mssind] : 0;
 }
 
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 107b2f1..4492535 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -15,6 +15,17 @@
 #include <net/ipv6.h>
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
+#include <net/tcp.h>
+
+#ifdef CONFIG_SYN_COOKIES
+static int tcp6_syncookies_mss_sysctl(struct ctl_table *ctl, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos)
+{
+	return tcp_syncookies_mss_sysctl(ctl, write, buffer, lenp, ppos,
+					   &sysctl_tcp6_syncookies_mss_count);
+}
+#endif
 
 static struct ctl_table ipv6_table_template[] = {
 	{
@@ -35,6 +46,15 @@ static struct ctl_table ipv6_rotable[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+#ifdef CONFIG_SYN_COOKIES
+	{
+		.procname	= "tcp_syncookies_mss_table",
+		.data		= &sysctl_tcp6_syncookies_mss,
+		.maxlen		= sizeof(sysctl_tcp6_syncookies_mss),
+		.mode		= 0644,
+		.proc_handler	= tcp6_syncookies_mss_sysctl,
+	},
+#endif
 	{ }
 };
 

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
