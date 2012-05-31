From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC v2 PATCH 3/3] tcp: SYN retransmits,
	fallback to slow-locked/no-cookie path
Date: Thu, 31 May 2012 15:40:08 +0200
Message-ID: <20120531134008.10311.63345.stgit@localhost.localdomain>
References: <20120531133807.10311.79711.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 0304ds2-fs.1.fullrate.dk ([89.150.128.48]:11057 "EHLO
	firesoul.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758032Ab2EaNhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 09:37:48 -0400
In-Reply-To: <20120531133807.10311.79711.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle retransmitted SYN packets, by falling back to the slow
locked processing path (instead of dropping the reqsk, as
previous patch).

This will handle the case, where the original SYN/ACK didn't get
dropped, but somehow were delayed in the network and the
SYN-retransmission timer on the client-side fires before the
SYN/ACK reaches the client.

Notice, this does introduce a new SYN attack vector.  Using this
vector of false retransmits, on big machine in testlab, the performance
is reduced to 251Kpps SYN packets (compared to approx 400Kpps
when early dropping reqsk's. SYN generator speed 750Kpps).

Signed-off-by: Martin Topholm <mph@hoth.dk>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/ipv4/tcp_ipv4.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 29e9c4a..d2ff5c3 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1307,24 +1307,22 @@ int tcp_v4_syn_conn_limit(struct sock *sk, struct sk_buff *skb)
 
 	/* Check for existing connection request (reqsk) as this might
 	 *   be a retransmitted SYN which have gotten into the
-	 *   reqsk_queue.  If so, we choose to drop the reqsk, and use
-	 *   SYN cookies to restore the state later, even-though this
-	 *   can cause issues, if the original SYN/ACK didn't get
+	 *   reqsk_queue.  If so, we simple fallback to the slow
+	 *   locked processing path.  Even-though this might introduce
+	 *   a new SYN attack vector.
+	 *   This will handle the case, where the original SYN/ACK didn't get
 	 *   dropped, but somehow were delayed in the network and the
 	 *   SYN-retransmission timer on the client-side fires before
-	 *   the SYN/ACK reaches the client.  We choose to neglect
-	 *   this situation as we are under attack, and don't want to
-	 *   open an attack vector, of falling back to the slow locked
-	 *   path.
+	 *   the SYN/ACK reaches the client.
 	 */
 	bh_lock_sock(sk);
 	exist_req = inet_csk_search_req(sk, &prev, tcp_hdr(skb)->source, saddr, daddr);
-	if (exist_req) { /* Drop existing reqsk */
+	if (exist_req) {
 		if (TCP_SKB_CB(skb)->seq == tcp_rsk(exist_req)->rcv_isn)
 			net_warn_ratelimited("Retransmitted SYN from %pI4"
-					     " (orig reqsk dropped)", &saddr);
-
-		inet_csk_reqsk_queue_drop(sk, exist_req, prev);
+					     " (don't do SYN cookie)", &saddr);
+		bh_unlock_sock(sk);
+		goto no_limit;
 	}
 	bh_unlock_sock(sk);
 
