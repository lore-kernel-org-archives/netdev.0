From: Jia He <hejianet@gmail.com>
Subject: [PATCH v5 3/7] proc: Reduce cache miss in snmp6_seq_show
Date: Wed, 28 Sep 2016 14:22:24 +0800
Message-ID: <1475043748-18161-4-git-send-email-hejianet@gmail.com>
References: <1475043748-18161-1-git-send-email-hejianet@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33417 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753223AbcI1GXA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 02:23:00 -0400
In-Reply-To: <1475043748-18161-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to use the generic interfaces snmp_get_cpu_field{,64}_batch to
aggregate the data by going through all the items of each cpu sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/ipv6/proc.c | 32 +++++++++++++++++++++++---------
 1 file changed, 23 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 679253d0..e047701 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -30,6 +30,11 @@
 #include <net/transp_v6.h>
 #include <net/ipv6.h>
 
+#define MAX4(a, b, c, d) \
+	max_t(u32, max_t(u32, a, b), max_t(u32, c, d))
+#define SNMP_MIB_MAX MAX4(UDP_MIB_MAX, TCP_MIB_MAX, \
+			IPSTATS_MIB_MAX, ICMP_MIB_MAX)
+
 static int sockstat6_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
@@ -192,13 +197,19 @@ static void snmp6_seq_show_item(struct seq_file *seq, void __percpu *pcpumib,
 				const struct snmp_mib *itemlist)
 {
 	int i;
-	unsigned long val;
-
-	for (i = 0; itemlist[i].name; i++) {
-		val = pcpumib ?
-			snmp_fold_field(pcpumib, itemlist[i].entry) :
-			atomic_long_read(smib + itemlist[i].entry);
-		seq_printf(seq, "%-32s\t%lu\n", itemlist[i].name, val);
+	unsigned long buff[SNMP_MIB_MAX];
+
+	if (pcpumib) {
+		memset(buff, 0, sizeof(unsigned long) * SNMP_MIB_MAX);
+
+		snmp_get_cpu_field_batch(buff, itemlist, pcpumib);
+		for (i = 0; itemlist[i].name; i++)
+			seq_printf(seq, "%-32s\t%lu\n",
+				   itemlist[i].name, buff[i]);
+	} else {
+		for (i = 0; itemlist[i].name; i++)
+			seq_printf(seq, "%-32s\t%lu\n", itemlist[i].name,
+				   atomic_long_read(smib + itemlist[i].entry));
 	}
 }
 
@@ -206,10 +217,13 @@ static void snmp6_seq_show_item64(struct seq_file *seq, void __percpu *mib,
 				  const struct snmp_mib *itemlist, size_t syncpoff)
 {
 	int i;
+	u64 buff64[SNMP_MIB_MAX];
+
+	memset(buff64, 0, sizeof(unsigned long) * SNMP_MIB_MAX);
 
+	snmp_get_cpu_field64_batch(buff64, itemlist, mib, syncpoff);
 	for (i = 0; itemlist[i].name; i++)
-		seq_printf(seq, "%-32s\t%llu\n", itemlist[i].name,
-			   snmp_fold_field64(mib, itemlist[i].entry, syncpoff));
+		seq_printf(seq, "%-32s\t%llu\n", itemlist[i].name, buff64[i]);
 }
 
 static int snmp6_seq_show(struct seq_file *seq, void *v)
-- 
2.5.5
