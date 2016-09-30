From: Jia He <hejianet@gmail.com>
Subject: [PATCH v6 4/7] proc: Reduce cache miss in sctp_snmp_seq_show
Date: Fri, 30 Sep 2016 11:29:01 +0800
Message-ID: <1475206144-23228-5-git-send-email-hejianet@gmail.com>
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
Received: from mail-it0-f67.google.com ([209.85.214.67]:34249 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935716AbcI3D3i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 23:29:38 -0400
In-Reply-To: <1475206144-23228-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to use the generic interfaces snmp_get_cpu_field{,64}_batch to
aggregate the data by going through all the items of each cpu sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/sctp/proc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index ef8ba77..09e16c2 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -73,13 +73,17 @@ static const struct snmp_mib sctp_snmp_list[] = {
 /* Display sctp snmp mib statistics(/proc/net/sctp/snmp). */
 static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 {
+	unsigned long buff[SCTP_MIB_MAX];
 	struct net *net = seq->private;
 	int i;
 
+	memset(buff, 0, sizeof(unsigned long) * SCTP_MIB_MAX);
+
+	snmp_get_cpu_field_batch(buff, sctp_snmp_list,
+				 net->sctp.sctp_statistics);
 	for (i = 0; sctp_snmp_list[i].name != NULL; i++)
 		seq_printf(seq, "%-32s\t%ld\n", sctp_snmp_list[i].name,
-			   snmp_fold_field(net->sctp.sctp_statistics,
-				      sctp_snmp_list[i].entry));
+						buff[i]);
 
 	return 0;
 }
-- 
2.5.5
