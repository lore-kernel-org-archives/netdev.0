From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/8] netfilter: nf_conntrack: allow server to become a client in TW handling
Date: Mon, 27 Oct 2014 22:38:00 +0100
Message-ID: <1414445887-5108-2-git-send-email-pablo@netfilter.org>
References: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35969 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628AbaJ0Vgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 17:36:37 -0400
In-Reply-To: <1414445887-5108-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Leitner <mleitner@redhat.com>

When a port that was used to listen for inbound connections gets closed
and reused for outgoing connections (like rsh ends up doing for stderr
flow), current we may reject the SYN/ACK packet for the new connection
because tcp_conntracks states forbirds a port to become a client while
there is still a TIME_WAIT entry in there for it.

As TCP may expire the TIME_WAIT socket in 60s and conntrack's timeout
for it is 120s, there is a ~60s window that the application can end up
opening a port that conntrack will end up blocking.

This patch fixes this by simply allowing such state transition: if we
see a SYN, in TIME_WAIT state, on REPLY direction, move it to sSS. Note
that the rest of the code already handles this situation, more
specificly in tcp_packet(), first switch clause.

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_tcp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 44d1ea3..d87b642 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -213,7 +213,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
 	{
 /* REPLY */
 /* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
-/*syn*/	   { sIV, sS2, sIV, sIV, sIV, sIV, sIV, sIV, sIV, sS2 },
+/*syn*/	   { sIV, sS2, sIV, sIV, sIV, sIV, sIV, sSS, sIV, sS2 },
 /*
  *	sNO -> sIV	Never reached.
  *	sSS -> sS2	Simultaneous open
@@ -223,7 +223,7 @@ static const u8 tcp_conntracks[2][6][TCP_CONNTRACK_MAX] = {
  *	sFW -> sIV
  *	sCW -> sIV
  *	sLA -> sIV
- *	sTW -> sIV	Reopened connection, but server may not do it.
+ *	sTW -> sSS	Reopened connection, but server may have switched role
  *	sCL -> sIV
  */
 /* 	     sNO, sSS, sSR, sES, sFW, sCW, sLA, sTW, sCL, sS2	*/
-- 
1.7.10.4
