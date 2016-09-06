From: Jia He <hejianet@gmail.com>
Subject: [RFC PATCH v2 3/6] proc: Reduce cache miss in sctp_snmp_seq_show
Date: Tue,  6 Sep 2016 10:30:06 +0800
Message-ID: <1473129009-20478-4-git-send-email-hejianet@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35679 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754946AbcIFCag (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 22:30:36 -0400
In-Reply-To: <1473129009-20478-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exchanges the two loop for collecting the percpu
statistics data. This can reduce cache misses by going through
all the items of each cpu sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/sctp/proc.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index ef8ba77..085fb95 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -74,12 +74,19 @@ static const struct snmp_mib sctp_snmp_list[] = {
 static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
-	int i;
+	int i, c;
+	unsigned long buff[SCTP_MIB_MAX];
 
+	memset(buff, 0, sizeof(unsigned long) * SCTP_MIB_MAX);
+
+	for_each_possible_cpu(c)
+		for (i = 0; sctp_snmp_list[i].name != NULL; i++)
+			buff[i] += snmp_get_cpu_field(
+						net->sctp.sctp_statistics,
+						c, sctp_snmp_list[i].entry);
 	for (i = 0; sctp_snmp_list[i].name != NULL; i++)
 		seq_printf(seq, "%-32s\t%ld\n", sctp_snmp_list[i].name,
-			   snmp_fold_field(net->sctp.sctp_statistics,
-				      sctp_snmp_list[i].entry));
+						buff[i]);
 
 	return 0;
 }
-- 
1.8.3.1
