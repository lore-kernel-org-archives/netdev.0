From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH v2 2/6] proc: Reduce cache miss in snmp6_seq_show
Date: Tue,  6 Sep 2016 10:30:05 +0800
Message-ID: <1473129009-20478-3-git-send-email-hejianet@gmail.com>
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

This patch exchanges the two loop for collecting the percpu
statistics data. This can reduce cache misses by going through
all the items of each cpu sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/ipv6/proc.c | 47 ++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 36 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 679253d0..c834646 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -30,6 +30,13 @@
 #include <net/transp_v6.h>
 #include <net/ipv6.h>
 
+#define MAX(a, b) ((u32)(a) >= (u32)(b) ? (a) : (b))
+
+#define MAX4(a, b, c, d) \
+	MAX(MAX(a, b), MAX(c, d))
+#define SNMP_MIB_MAX MAX4(UDP_MIB_MAX, TCP_MIB_MAX, \
+			IPSTATS_MIB_MAX, ICMP_MIB_MAX)
+
 static int sockstat6_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
@@ -191,25 +198,43 @@ static void snmp6_seq_show_item(struct seq_file *seq, void __percpu *pcpumib,
 				atomic_long_t *smib,
 				const struct snmp_mib *itemlist)
 {
-	int i;
-	unsigned long val;
-
-	for (i = 0; itemlist[i].name; i++) {
-		val = pcpumib ?
-			snmp_fold_field(pcpumib, itemlist[i].entry) :
-			atomic_long_read(smib + itemlist[i].entry);
-		seq_printf(seq, "%-32s\t%lu\n", itemlist[i].name, val);
+	int i, c;
+	unsigned long buff[SNMP_MIB_MAX];
+
+	memset(buff, 0, sizeof(unsigned long) * SNMP_MIB_MAX);
+
+	if (pcpumib) {
+		for_each_possible_cpu(c)
+			for (i = 0; itemlist[i].name; i++)
+				buff[i] += snmp_get_cpu_field(pcpumib, c,
+							itemlist[i].entry);
+		for (i = 0; itemlist[i].name; i++)
+			seq_printf(seq, "%-32s\t%lu\n",
+				   itemlist[i].name, buff[i]);
+	} else {
+		for (i = 0; itemlist[i].name; i++)
+			seq_printf(seq, "%-32s\t%lu\n", itemlist[i].name,
+				   atomic_long_read(smib + itemlist[i].entry));
 	}
 }
 
 static void snmp6_seq_show_item64(struct seq_file *seq, void __percpu *mib,
 				  const struct snmp_mib *itemlist, size_t syncpoff)
 {
-	int i;
+	int i, c;
+	u64 buff[SNMP_MIB_MAX];
+
+	memset(buff, 0, sizeof(unsigned long) * SNMP_MIB_MAX);
 
+	for_each_possible_cpu(c) {
+		for (i = 0; itemlist[i].name; i++) {
+			buff[i] += snmp_get_cpu_field64(mib, c,
+							itemlist[i].entry,
+							syncpoff);
+		}
+	}
 	for (i = 0; itemlist[i].name; i++)
-		seq_printf(seq, "%-32s\t%llu\n", itemlist[i].name,
-			   snmp_fold_field64(mib, itemlist[i].entry, syncpoff));
+		seq_printf(seq, "%-32s\t%llu\n", itemlist[i].name, buff[i]);
 }
 
 static int snmp6_seq_show(struct seq_file *seq, void *v)
-- 
1.8.3.1
