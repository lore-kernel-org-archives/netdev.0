From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: refine SYN handling in tcp_validate_incoming
Date: Wed, 18 Jul 2012 00:29:30 +0200
Message-ID: <1342564170.2626.1243.camel@edumazet-glaptop>
References: <1342525290.2626.459.camel@edumazet-glaptop>
	 <CAGK4HS-AMWZ0Ef7G1pvWJ7XADsvxqsiX3tMCe2=oq+_46won6g@mail.gmail.com>
	 <1342560769.2626.1165.camel@edumazet-glaptop>
	 <CAGK4HS8MvP6L5Rvy4wJx2KhdTSSHfP7YPT44e9mrV_vsBZJ9jQ@mail.gmail.com>
	 <1342563706.2626.1228.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Kiran Kumar Kella <kkiran@broadcom.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47763 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757182Ab2GQW3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:29:35 -0400
Received: by yhmm54 with SMTP id m54so971593yhm.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 15:29:35 -0700 (PDT)
In-Reply-To: <1342563706.2626.1228.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Followup of commit 0c24604b68fc (tcp: implement RFC 5961 4.2)

As reported by Vijay Subramanian, we should send a challenge ACK
instead of a dup ack if a SYN flag is set on a packet received out of
window.

This permits the ratelimiting to work as intended, and to increase
correct SNMP counters.

Suggested-by: Vijay Subramanian <subramanian.vijay@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Vijay Subramanian <subramanian.vijay@gmail.com>
Cc: Kiran Kumar Kella <kkiran@broadcom.com>
---
 net/ipv4/tcp_input.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8aaec55..fdd49f1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5296,8 +5296,11 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 		 * an acknowledgment should be sent in reply (unless the RST
 		 * bit is set, if so drop the segment and return)".
 		 */
-		if (!th->rst)
+		if (!th->rst) {
+			if (th->syn)
+				goto syn_challenge;
 			tcp_send_dupack(sk, skb);
+		}
 		goto discard;
 	}
 
@@ -5327,6 +5330,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 	 * RFC 5691 4.2 : Send a challenge ack
 	 */
 	if (th->syn) {
+syn_challenge:
 		if (syn_inerr)
 			TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_INERRS);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNCHALLENGE);
