From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH 1/6] proc: Reduce cache miss in {snmp,netstat}_seq_show
Date: Tue, 30 Aug 2016 00:03:55 +0800
Message-ID: <1472486640-1111-2-git-send-email-hejianet@gmail.com>
References: <1472486640-1111-1-git-send-email-hejianet@gmail.com>
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
In-Reply-To: <1472486640-1111-1-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch exchanges the two loop for collecting the percpu statistics
data. This can aggregate the data by going through all the items of each
cpu sequentially. In snmp_seq_show, just use one buff copy to dislay the
Udp and UdpLite data because they are the same.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/ipv4/proc.c | 78 ++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 50 insertions(+), 28 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 9f665b6..ed09566 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -380,11 +380,15 @@ static void icmp_put(struct seq_file *seq)
  */
 static int snmp_seq_show(struct seq_file *seq, void *v)
 {
-	int i;
+	int i, c;
+	unsigned long buff[TCP_MIB_MAX];
+	u64 buff64[IPSTATS_MIB_MAX];
 	struct net *net = seq->private;
 
-	seq_puts(seq, "Ip: Forwarding DefaultTTL");
+	memset(buff, 0, TCP_MIB_MAX * sizeof(unsigned long));
+	memset(buff64, 0, IPSTATS_MIB_MAX * sizeof(u64));
 
+	seq_puts(seq, "Ip: Forwarding DefaultTTL");
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
 
@@ -393,11 +397,16 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
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
 
 	icmp_put(seq);	/* RFC 2011 compatibility */
 	icmpmsg_put(seq);
@@ -407,38 +416,41 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
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
 
+	memset(buff, 0, TCP_MIB_MAX * sizeof(unsigned long));
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
 
 	/* the UDP and UDP-Lite MIBs are the same */
 	seq_puts(seq, "\nUdpLite:");
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
@@ -464,29 +476,39 @@ static const struct file_operations snmp_seq_fops = {
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
