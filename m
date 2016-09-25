From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 44/53] netfilter: seqadj: Fix the wrong ack adjust for the RST packet without ack
Date: Mon, 26 Sep 2016 01:06:54 +0200
Message-ID: <1474844823-2026-45-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54738 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034867AbcIYXIE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:08:04 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id B7675CA6C7
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:03 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A2576DA841
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:03 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7CBC4DA815
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:08:01 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_seqadj.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_seqadj.c b/net/netfilter/nf_conntrack_seqadj.c
index dff0f0cc59e4..ef7063eced7c 100644
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
@@ -184,27 +184,31 @@ int nf_ct_seq_adjust(struct sk_buff *skb,
 	else
 		seqoff = this_way->offset_before;
 
+	newseq = htonl(ntohl(tcph->seq) + seqoff);
+	inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, false);
+	pr_debug("Adjusting sequence number from %u->%u\n",
+		 ntohl(tcph->seq), ntohl(newseq));
+	tcph->seq = newseq;
+
+	if (!tcph->ack)
+		goto out;
+
 	if (after(ntohl(tcph->ack_seq) - other_way->offset_before,
 		  other_way->correction_pos))
 		ackoff = other_way->offset_after;
 	else
 		ackoff = other_way->offset_before;
 
-	newseq = htonl(ntohl(tcph->seq) + seqoff);
 	newack = htonl(ntohl(tcph->ack_seq) - ackoff);
-
-	inet_proto_csum_replace4(&tcph->check, skb, tcph->seq, newseq, false);
 	inet_proto_csum_replace4(&tcph->check, skb, tcph->ack_seq, newack,
 				 false);
-
-	pr_debug("Adjusting sequence number from %u->%u, ack from %u->%u\n",
+	pr_debug("Adjusting ack number from %u->%u, ack from %u->%u\n",
 		 ntohl(tcph->seq), ntohl(newseq), ntohl(tcph->ack_seq),
 		 ntohl(newack));
-
-	tcph->seq = newseq;
 	tcph->ack_seq = newack;
 
 	res = nf_ct_sack_adjust(skb, protoff, tcph, ct, ctinfo);
+out:
 	spin_unlock_bh(&ct->lock);
 
 	return res;
-- 
2.1.4
