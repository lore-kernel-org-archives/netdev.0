From: pablo@netfilter.org
Subject: [PATCH 2/4] netfilter: Mark SYN/ACK packets as invalid from original direction
Date: Thu, 13 Sep 2012 12:54:06 +0200
Message-ID: <1347533648-3451-3-git-send-email-pablo@netfilter.org>
References: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43688 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757473Ab2IMKz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 06:55:28 -0400
In-Reply-To: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Clients should not send such packets. By accepting them, we open
up a hole by wich ephemeral ports can be discovered in an off-path
attack.

See: "Reflection scan: an Off-Path Attack on TCP" by Jan Wrobel,
http://arxiv.org/abs/1201.2074

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_tcp.c |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index a5ac11e..aba98f9 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -158,21 +158,18 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sCL -> sSS
  */
 /* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
-/*synack*/ { sIV, sIV, sIG, sIG, sIG, sIG, sIG, sIG, sIG, sSR },
+/*synack*/ { sIV, sIV, sSR, sIV, sIV, sIV, sIV, sIV, sIV, sSR },
 /*
  *	sNO -> sIV	Too late and no reason to do anything
  *	sSS -> sIV	Client can't send SYN and then SYN/ACK
  *	sS2 -> sSR	SYN/ACK sent to SYN2 in simultaneous open
- *	sSR -> sIG
- *	sES -> sIG	Error: SYNs in window outside the SYN_SENT state
- *			are errors. Receiver will reply with RST
- *			and close the connection.
- *			Or we are not in sync and hold a dead connection.
- *	sFW -> sIG
- *	sCW -> sIG
- *	sLA -> sIG
- *	sTW -> sIG
- *	sCL -> sIG
+ *	sSR -> sSR	Late retransmitted SYN/ACK in simultaneous open
+ *	sES -> sIV	Invalid SYN/ACK packets sent by the client
+ *	sFW -> sIV
+ *	sCW -> sIV
+ *	sLA -> sIV
+ *	sTW -> sIV
+ *	sCL -> sIV
  */
 /* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
 /*fin*/    { sIV, sIV, sFW, sFW, sLA, sLA, sLA, sTW, sCL, sIV },
-- 
1.7.10.4
