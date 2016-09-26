From: Jia He <hejianet@gmail.com>
Subject: [PATCH v4 4/7] proc: Reduce cache miss in sctp_snmp_seq_show
Date: Mon, 26 Sep 2016 16:09:12 +0800
Message-ID: <1474877355-12920-5-git-send-email-hejianet@gmail.com>
References: <1474877355-12920-1-git-send-email-hejianet@gmail.com>
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
In-Reply-To: <1474877355-12920-1-git-send-email-hejianet@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is to use the generic interface snmp_get_cpu_field{,64}_batch to
aggregate the data by going through all the items of each cpu sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
---
 net/sctp/proc.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index ef8ba77..0487c01 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -75,11 +75,15 @@ static int sctp_snmp_seq_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq->private;
 	int i;
+	unsigned long buff[SCTP_MIB_MAX];
 
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
