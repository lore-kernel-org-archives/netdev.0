From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH v2 1/6] proc: Reduce cache miss in {snmp,netstat}_seq_show
Date: Tue,  6 Sep 2016 10:30:04 +0800
Message-ID: <1473129009-20478-2-git-send-email-hejianet@gmail.com>
References: <1473129009-20478-1-git-send-email-hejianet@gmail.com>
Cc: linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jia He <hejianet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473129009-20478-1-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch exchanges the two loop for collecting the percpu statistics
data. This can aggregate the data by going through all the items of each
cpu sequentially. Then snmp_seq_show is split into 2 parts to avoid build
warning "the frame size" larger than 1024.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/ipv4/proc.c | 112 ++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 81 insertions(+), 31 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 9f665b6..f413fdc 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -46,6 +46,9 @@
 #include <net/sock.h>
 #include <net/raw.h>
 
+#define MAX(a, b) ((u32)(a) >= (u32)(b) ? (a) : (b))
+#define TCPUDP_MIB_MAX MAX(UDP_MIB_MAX, TCP_MIB_MAX)
+
 /*
  *	Report socket allocation statistics [mea@utu.fi]
  */
@@ -378,13 +381,15 @@ static void icmp_put(struct seq_file *seq)
 /*
  *	Called from the PROCfs module. This outputs /proc/net/snmp.
  */
-static int snmp_seq_show(struct seq_file *seq, void *v)
+static int snmp_seq_show_ipstats(struct seq_file *seq, void *v)
 {
-	int i;
+	int i, c;
+	u64 buff64[IPSTATS_MIB_MAX];
 	struct net *net = seq->private;
 
-	seq_puts(seq, "Ip: Forwarding DefaultTTL");
+	memset(buff64, 0, IPSTATS_MIB_MAX * sizeof(u64));
 
+	seq_puts(seq, "Ip: Forwarding DefaultTTL");
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
 
@@ -393,57 +398,92 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 		   net->ipv4.sysctl_ip_default_ttl);
 
 	BUILD_BUG_ON(offsetof(struct ipstats_mib, mibs) != 0);
+
+	for_each_possible_cpu(c) {
+		for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
+			buff64[i] += snmp_get_cpu_field64(
+					net->mib.ip_statistics,
+					c, snmp4_ipstats_list[i].entry,
+					offsetof(struct ipstats_mib, syncp));
+	}
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
-		seq_printf(seq, " %llu",
-			   snmp_fold_field64(net->mib.ip_statistics,
-					     snmp4_ipstats_list[i].entry,
-					     offsetof(struct ipstats_mib, syncp)));
+		seq_printf(seq, " %llu", buff64[i]);
 
-	icmp_put(seq);	/* RFC 2011 compatibility */
-	icmpmsg_put(seq);
+	return 0;
+}
+
+static int snmp_seq_show_tcp_udp(struct seq_file *seq, void *v)
+{
+	int i, c;
+	unsigned long buff[TCPUDP_MIB_MAX];
+	struct net *net = seq->private;
+
+	memset(buff, 0, TCPUDP_MIB_MAX * sizeof(unsigned long));
 
 	seq_puts(seq, "\nTcp:");
 	for (i = 0; snmp4_tcp_list[i].name != NULL; i++)
 		seq_printf(seq, " %s", snmp4_tcp_list[i].name);
 
 	seq_puts(seq, "\nTcp:");
+	for_each_possible_cpu(c) {
+		for (i = 0; snmp4_tcp_list[i].name != NULL; i++)
+			buff[i] += snmp_get_cpu_field(net->mib.tcp_statistics,
+						c, snmp4_tcp_list[i].entry);
+	}
+
 	for (i = 0; snmp4_tcp_list[i].name != NULL; i++) {
 		/* MaxConn field is signed, RFC 2012 */
 		if (snmp4_tcp_list[i].entry == TCP_MIB_MAXCONN)
-			seq_printf(seq, " %ld",
-				   snmp_fold_field(net->mib.tcp_statistics,
-						   snmp4_tcp_list[i].entry));
+			seq_printf(seq, " %ld", buff[i]);
 		else
-			seq_printf(seq, " %lu",
-				   snmp_fold_field(net->mib.tcp_statistics,
-						   snmp4_tcp_list[i].entry));
+			seq_printf(seq, " %lu", buff[i]);
 	}
 
+	memset(buff, 0, TCPUDP_MIB_MAX * sizeof(unsigned long));
+
+	for_each_possible_cpu(c) {
+		for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+			buff[i] += snmp_get_cpu_field(net->mib.udp_statistics,
+						c, snmp4_udp_list[i].entry);
+	}
 	seq_puts(seq, "\nUdp:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %s", snmp4_udp_list[i].name);
-
 	seq_puts(seq, "\nUdp:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
-		seq_printf(seq, " %lu",
-			   snmp_fold_field(net->mib.udp_statistics,
-					   snmp4_udp_list[i].entry));
+		seq_printf(seq, " %lu", buff[i]);
+
+	memset(buff, 0, TCPUDP_MIB_MAX * sizeof(unsigned long));
 
 	/* the UDP and UDP-Lite MIBs are the same */
 	seq_puts(seq, "\nUdpLite:");
+	for_each_possible_cpu(c) {
+		for (i = 0; snmp4_udp_list[i].name != NULL; i++)
+			buff[i] += snmp_get_cpu_field(net->mib.udplite_statistics,
+						c, snmp4_udp_list[i].entry);
+	}
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
 		seq_printf(seq, " %s", snmp4_udp_list[i].name);
-
 	seq_puts(seq, "\nUdpLite:");
 	for (i = 0; snmp4_udp_list[i].name != NULL; i++)
-		seq_printf(seq, " %lu",
-			   snmp_fold_field(net->mib.udplite_statistics,
-					   snmp4_udp_list[i].entry));
+		seq_printf(seq, " %lu", buff[i]);
 
 	seq_putc(seq, '\n');
 	return 0;
 }
 
+static int snmp_seq_show(struct seq_file *seq, void *v)
+{
+	snmp_seq_show_ipstats(seq, v);
+
+	icmp_put(seq);	/* RFC 2011 compatibility */
+	icmpmsg_put(seq);
+
+	snmp_seq_show_tcp_udp(seq, v);
+
+	return 0;
+}
+
 static int snmp_seq_open(struct inode *inode, struct file *file)
 {
 	return single_open_net(inode, file, snmp_seq_show);
@@ -464,29 +504,39 @@ static const struct file_operations snmp_seq_fops = {
  */
 static int netstat_seq_show(struct seq_file *seq, void *v)
 {
-	int i;
+	int i, c;
+	unsigned long buff[LINUX_MIB_MAX];
+	u64 buff64[IPSTATS_MIB_MAX];
 	struct net *net = seq->private;
 
+	memset(buff, 0, sizeof(unsigned long) * LINUX_MIB_MAX);
+	memset(buff64, 0, sizeof(u64) * IPSTATS_MIB_MAX);
+
 	seq_puts(seq, "TcpExt:");
 	for (i = 0; snmp4_net_list[i].name != NULL; i++)
 		seq_printf(seq, " %s", snmp4_net_list[i].name);
 
 	seq_puts(seq, "\nTcpExt:");
+	for_each_possible_cpu(c)
+		for (i = 0; snmp4_net_list[i].name != NULL; i++)
+			buff[i] += snmp_get_cpu_field(net->mib.net_statistics,
+						c, snmp4_net_list[i].entry);
 	for (i = 0; snmp4_net_list[i].name != NULL; i++)
-		seq_printf(seq, " %lu",
-			   snmp_fold_field(net->mib.net_statistics,
-					   snmp4_net_list[i].entry));
+		seq_printf(seq, " %lu", buff[i]);
 
 	seq_puts(seq, "\nIpExt:");
 	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %s", snmp4_ipextstats_list[i].name);
 
 	seq_puts(seq, "\nIpExt:");
+	for_each_possible_cpu(c)
+		for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
+			buff64[i] += snmp_get_cpu_field64(
+					net->mib.ip_statistics,
+					c, snmp4_ipextstats_list[i].entry,
+					offsetof(struct ipstats_mib, syncp));
 	for (i = 0; snmp4_ipextstats_list[i].name != NULL; i++)
-		seq_printf(seq, " %llu",
-			   snmp_fold_field64(net->mib.ip_statistics,
-					     snmp4_ipextstats_list[i].entry,
-					     offsetof(struct ipstats_mib, syncp)));
+		seq_printf(seq, " %llu", buff64[i]);
 
 	seq_putc(seq, '\n');
 	return 0;
-- 
1.8.3.1
