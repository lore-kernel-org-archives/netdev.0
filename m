From: fgao@ikuai8.com
Subject: [PATCH nf v4] netfilter: seqadj: Fix the wrong ack adjust for the RST packet without ack
Date: Thu, 22 Sep 2016 14:29:55 +0800
Message-ID: <1474525795-25446-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: pablo@netfilter.org, kaber@trash.net,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg292.qq.com ([113.108.11.231]:52372 "EHLO smtpbg292.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753070AbcIVGbd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 02:31:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

It is valid that the TCP RST packet which does not set ack flag, and bytes
of ack number are zero. But current seqadj codes would adjust the "0" ack
to invalid ack number. Actually seqadj need to check the ack flag before
adjust it for these RST packets.

The following is my test case

client is 10.26.98.245, and add one iptable rule:
iptables  -I INPUT -p tcp --sport 12345 -m connbytes --connbytes 2:
--connbytes-dir reply --connbytes-mode packets -j REJECT --reject-with
tcp-reset
This iptables rule could generate on TCP RST without ack flag.

server:10.172.135.55
Enable the synproxy with seqadjust by the following iptables rules
iptables -t raw -A PREROUTING -i eth0 -p tcp -d 10.172.135.55 --dport 12345
-m tcp --syn -j CT --notrack

iptables -A INPUT -i eth0 -p tcp -d 10.172.135.55 --dport 12345 -m conntrack
--ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7
--mss 1460
iptables -A OUTPUT -o eth0 -p tcp -s 10.172.135.55 --sport 12345 -m conntrack
--ctstate INVALID,UNTRACKED -m tcp --tcp-flags SYN,RST,ACK SYN,ACK -j ACCEPT

The following is my test result.

1. packet trace on client
root@routers:/tmp# tcpdump -i eth0 tcp port 12345 -n
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
IP 10.26.98.245.45154 > 10.172.135.55.12345: Flags [S], seq 3695959829,
win 29200, options [mss 1460,sackOK,TS val 452367884 ecr 0,nop,wscale 7],
length 0
IP 10.172.135.55.12345 > 10.26.98.245.45154: Flags [S.], seq 546723266,
ack 3695959830, win 0, options [mss 1460,sackOK,TS val 15643479 ecr 452367884,
nop,wscale 7], length 0
IP 10.26.98.245.45154 > 10.172.135.55.12345: Flags [.], ack 1, win 229,
options [nop,nop,TS val 452367885 ecr 15643479], length 0
IP 10.172.135.55.12345 > 10.26.98.245.45154: Flags [.], ack 1, win 226,
options [nop,nop,TS val 15643479 ecr 452367885], length 0
IP 10.26.98.245.45154 > 10.172.135.55.12345: Flags [R], seq 3695959830,
win 0, length 0

2. seqadj log on server
[62873.867319] Adjusting sequence number from 602341895->546723267,
ack from 3695959830->3695959830
[62873.867644] Adjusting sequence number from 602341895->546723267,
ack from 3695959830->3695959830
[62873.869040] Adjusting sequence number from 3695959830->3695959830,
ack from 0->55618628

To summarize, it is clear that the seqadj codes adjust the 0 ack when receive
one TCP RST packet without ack.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v4: Don't invoke nf_ct_sack_adjust when no ack flag
 v3: Add the reproduce steps and packet trace
 v2: Regenerate because the first patch is removed
 v1: Initial patch

 net/netfilter/nf_conntrack_seqadj.c | 37 ++++++++++++++++++++-----------------
 1 file changed, 20 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index dff0f0c..80ab429 100644
--- a/net/netfilter/nf_conntrack_seqadj.c
+++ b/net/netfilter/nf_conntrack_seqadj.c
@@ -169,7 +169,7 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
 	s32 seqoff, ackoff;
 	struct nf_conn_seqadj *seqadj = nfct_seqadj(ct);
 	struct nf_ct_seqadj *this_way, *other_way;
-	int res;
+	int res = 1;
 
 	this_way  = &seqadj->seq[dir];
 	other_way = &seqadj->seq[!dir];
@@ -184,27 +184,30 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
 	else
 		seqoff = this_way->offset_before;
 
-	if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
-		  other_way->correction_pos))
-		ackoff = other_way->offset_after;
-	else
-		ackoff = other_way->offset_before;
-
 	newseq = htonl(ntohl(tcph->seq) + seqoff);
-	newack = htonl(ntohl(tcph->ack_seq) - ackoff);
-
 	inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, false);
-	inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack,
-				 false);
+	pr_debug("Adjusting sequence number from %u->%u\n",
+		 ntohl(tcph->seq), ntohl(newseq));
+	tcph->seq = newseq;
 
-	pr_debug("Adjusting sequence number from %u->%u, ack from %u->%u\n",
-		 ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
-		 ntohl(newack));
+	if (likely(tcph->ack)) {
+		if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
+			  other_way->correction_pos))
+			ackoff = other_way->offset_after;
+		else
+			ackoff = other_way->offset_before;
 
-	tcph->seq = newseq;
-	tcph->ack_seq = newack;
+		newack = htonl(ntohl(tcph->ack_seq) - ackoff);
+		inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq,
+					 newack, false);
+		pr_debug("Adjusting ack number from %u->%u, ack from %u->%u\n",
+			 ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
+			 ntohl(newack));
+		tcph->ack_seq = newack;
+
+		res = nf_ct_sack_adjust(skb, protoff, tcph, ct, ctinfo);
+	}
 
-	res = nf_ct_sack_adjust(skb, protoff, tcph, ct, ctinfo);
 	spin_unlock_bh(&ct->lock);
 
 	return res;
-- 
1.9.1
