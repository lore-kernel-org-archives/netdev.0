From: pablo@netfilter.org
Subject: [PATCH 3/4] netfilter: Validate the sequence number of dataless ACK packets as well
Date: Thu, 13 Sep 2012 12:54:07 +0200
Message-ID: <1347533648-3451-4-git-send-email-pablo@netfilter.org>
References: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

We spare nothing by not validating the sequence number of dataless
ACK packets and enabling it makes harder off-path attacks.

See: "Reflection scan: an Off-Path Attack on TCP" by Jan Wrobel,
http://arxiv.org/abs/1201.2074

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_tcp.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index aba98f9..e046b37 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -630,15 +630,9 @@ static bool tcp_in_window(const struct nf_conn *ct,
 		ack = sack = receiver->td_end;
 	}
 
-	if (seq == end
-	    && (!tcph->rst
-		|| (seq == 0 && state->state == TCP_CONNTRACK_SYN_SENT)))
+	if (tcph->rst && seq == 0 && state->state == TCP_CONNTRACK_SYN_SENT)
 		/*
-		 * Packets contains no data: we assume it is valid
-		 * and check the ack value only.
-		 * However RST segments are always validated by their
-		 * SEQ number, except when seq == 0 (reset sent answering
-		 * SYN.
+		 * RST sent answering SYN.
 		 */
 		seq = end = sender->td_end;
 
-- 
1.7.10.4

