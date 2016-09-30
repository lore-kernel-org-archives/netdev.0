From: Jia He <hejianet@gmail.com>
Subject: [PATCH v6 2/7] proc: Reduce cache miss in snmp_seq_show
Date: Fri, 30 Sep 2016 11:28:59 +0800
Message-ID: <1475206144-23228-3-git-send-email-hejianet@gmail.com>
References: <1475206144-23228-1-git-send-email-hejianet@gmail.com>
Cc: linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        marcelo.leitner@gmail.com, Jia He <hejianet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475206144-23228-1-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is to use the generic interfaces snmp_get_cpu_field{,64}_batch to
aggregate the data by going through all the items of each cpu sequentially.
Then snmp_seq_show is split into 2 parts to avoid build warning "the frame
size" larger than 1024.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/ipv4/proc.c | 70 ++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 47 insertions(+), 23 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 9f665b6..9d7a39a 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -46,6 +46,8 @@
 #include <net/sock.h>
 #include <net/raw.h>
 
+#define TCPUDP_MIB_MAX max_t(u32, UDP_MIB_MAX, TCP_MIB_MAX)
+
 /*
  *	Report socket allocation statistics [mea@utu.fi]
  */
@@ -378,13 +380,15 @@ static void icmp_put(struct seq_file *seq)
 /*
  *	Called from the PROCfs module. This outputs /proc/net/snmp.
  */
-static int snmp_seq_show(struct seq_file *seq, void *v)
+static int snmp_seq_show_ipstats(struct seq_file *seq, void *v)
 {
-	int i;
 	struct net *net = seq->private;
+	u64 buff64[IPSTATS_MIB_MAX];
+	int i;
 
-	seq_puts(seq, "Ip: Forwarding DefaultTTL");
+	memset(buff64, 0, IPSTATS_MIB_MAX * sizeof(u64));
 
+	seq_puts(seq, "Ip: Forwarding DefaultTTL");
 	for (i = 0; snmp4_ipstats_list[i].name != NULL; i++)
 		seq_printf(seq, " %s", snmp4_ipstats_list[i].name);
 
@@ -393,57 +397,77 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 		   net->ipv4.sysctl_ip_default_ttl);
 
 	BUILD_BUG_ON(offsetof(struct ipstats_mib, mibs) != 0);
+	snmp_get_cpu_field64_batch(buff64, snmp4_ipstats_list,
+				   net->mib.ip_statistics,
+				   offsetof(struct ipstats_mib, syncp));
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
+	unsigned long buff[TCPUDP_MIB_MAX];
+	struct net *net = seq->private;
+	int i;
+
+	memset(buff, 0, TCPUDP_MIB_MAX * sizeof(unsigned long));
 
 	seq_puts(seq, "\nTcp:");
 	for (i = 0; snmp4_tcp_list[i].name != NULL; i++)
 		seq_printf(seq, " %s", snmp4_tcp_list[i].name);
 
 	seq_puts(seq, "\nTcp:");
+	snmp_get_cpu_field_batch(buff, snmp4_tcp_list,
+				 net->mib.tcp_statistics);
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
+	snmp_get_cpu_field_batch(buff, snmp4_udp_list,
+				 net->mib.udp_statistics);
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
+	snmp_get_cpu_field_batch(buff, snmp4_udp_list,
+				 net->mib.udplite_statistics);
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
-- 
2.5.5
