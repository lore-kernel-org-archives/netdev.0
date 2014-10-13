From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH] nf_conntrack_proto_tcp: allow server to become a client in TW handling
Date: Mon, 13 Oct 2014 13:09:28 -0300
Message-ID: <a9618c5db692413c2970201b5206bcd357438399.1413216136.git.mleitner@redhat.com>
References: <5419B546.40702@redhat.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <5419B546.40702@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 net/netfilter/nf_conntrack_proto_tcp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 44d1ea32570a07338dc39f34624bd823b6f76916..d87b6423ffb21e0f8f9b6ef25ef51c1cb5f54ad6 100644
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
1.9.3

