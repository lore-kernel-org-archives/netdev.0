From: Jia He <hejianet@gmail.com>
Subject: [PATCH v6 5/7] proc: Reduce cache miss in xfrm_statistics_seq_show
Date: Fri, 30 Sep 2016 11:29:02 +0800
Message-ID: <1475206144-23228-6-git-send-email-hejianet@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33641 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935913AbcI3D3s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 23:29:48 -0400
In-Reply-To: <1475206144-23228-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to use the generic interfaces snmp_get_cpu_field{,64}_batch to
aggregate the data by going through all the items of each cpu sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/xfrm/xfrm_proc.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 9c4fbd8..ba2b539 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -50,12 +50,18 @@ static const struct snmp_mib xfrm_mib_list[] = {
 
 static int xfrm_statistics_seq_show(struct seq_file *seq, void *v)
 {
+	unsigned long buff[LINUX_MIB_XFRMMAX];
 	struct net *net = seq->private;
 	int i;
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
