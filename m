From: Jia He <hejianet@gmail.com>
Subject: [PATCH v5 5/7] proc: Reduce cache miss in xfrm_statistics_seq_show
Date: Wed, 28 Sep 2016 14:22:26 +0800
Message-ID: <1475043748-18161-6-git-send-email-hejianet@gmail.com>
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
Received: from mail-io0-f195.google.com ([209.85.223.195]:36724 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753660AbcI1GXL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 02:23:11 -0400
In-Reply-To: <1475043748-18161-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to use the generic interfaces snmp_get_cpu_field{,64}_batch to
aggregate the data by going through all the items of each cpu sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/xfrm/xfrm_proc.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 9c4fbd8..dc0cea6 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -50,12 +50,18 @@ static const struct snmp_mib xfrm_mib_list[] = {
 
 static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
 {
-	struct net *net = seq->private;
 	int i;
+	struct net *net = seq->private;
+	unsigned long buff[LINUX_MIB_XFRMMAX];
+
+	memset(buff, 0, sizeof(unsigned long) * LINUX_MIB_XFRMMAX);
+
+	snmp_get_cpu_field_batch(buff, xfrm_mib_list,
+				 net->mib.xfrm_statistics);
 	for (i = 0; xfrm_mib_list[i].name; i++)
 		seq_printf(seq, "%-24s\t%lu\n", xfrm_mib_list[i].name,
-			   snmp_fold_field(net->mib.xfrm_statistics,
-					   xfrm_mib_list[i].entry));
+						buff[i]);
+
 	return 0;
 }
 
-- 
2.5.5
