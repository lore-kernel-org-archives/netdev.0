From: Jia He <hejianet@gmail.com>
Subject: [PATCH v5 4/7] proc: Reduce cache miss in sctp_snmp_seq_show
Date: Wed, 28 Sep 2016 14:22:25 +0800
Message-ID: <1475043748-18161-5-git-send-email-hejianet@gmail.com>
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
Received: from mail-io0-f196.google.com ([209.85.223.196]:33447 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753340AbcI1GXG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 02:23:06 -0400
In-Reply-To: <1475043748-18161-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to use the generic interfaces snmp_get_cpu_field{,64}_batch to
aggregate the data by going through all the items of each cpu sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/sctp/proc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index ef8ba77..9e7f4a7 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -73,13 +73,17 @@ static const struct snmp_mib sctp_snmp_list[] = {
 /* Display sctp snmp mib statistics(/proc/net/sctp/snmp). */
 static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 {
-	struct net *net = seq->private;
 	int i;
+	struct net *net = seq->private;
+	unsigned long buff[SCTP_MIB_MAX];
+
+	memset(buff, 0, sizeof(unsigned long) * SCTP_MIB_MAX);
 
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
