From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH 4/6] proc: Reduce cache miss in xfrm_statistics_seq_show
Date: Tue, 30 Aug 2016 00:03:58 +0800
Message-ID: <1472486640-1111-5-git-send-email-hejianet@gmail.com>
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

This patch exchanges the two loop for collecting the percpu
statistics data. This can reduce cache misses by going through
all the items of each cpu sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/xfrm/xfrm_proc.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 9c4fbd8..c9df546 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -51,11 +51,20 @@ static const struct snmp_mib xfrm_mib_list[] = {
 static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
-	int i;
-	for (i = 0; xfrm_mib_list[i].name; i++)
+	int i, c;
+	unsigned long buff[LINUX_MIB_XFRMMAX];
+
+	memset(buff, 0, sizeof(unsigned long) * LINUX_MIB_XFRMMAX);
+
+	for_each_possible_cpu(c)
+		for (i = 0; xfrm_mib_list[i].name != NULL; i++)
+			buff[i] += snmp_get_cpu_field(
+						net->mib.xfrm_statistics,
+						c, xfrm_mib_list[i].entry);
+	for (i = 0; xfrm_mib_list[i].name != NULL; i++)
 		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
-			   snmp_fold_field(net->mib.xfrm_statistics,
-					   xfrm_mib_list[i].entry));
+						buff[i]);
+
 	return 0;
 }
 
-- 
1.8.3.1
