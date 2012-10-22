From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: RFC 5961 5.2 Blind Data Injection Attack
 Mitigation
Date: Mon, 22 Oct 2012 07:57:11 +0200
Message-ID: <1350885431.8609.250.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>, Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43569 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753627Ab2JVF5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 01:57:16 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so802751eek.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 22:57:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

RFC 5961 5.2 [Blind Data Injection Attack].[Mitigation]

  All TCP stacks MAY implement the following mitigation.  TCP stacks
  that implement this mitigation MUST add an additional input check to
  any incoming segment.  The ACK value is considered acceptable only if
  it is in the range of ((SND.UNA - MAX.SND.WND) <= SEG.ACK <=
  SND.NXT).  All incoming segments whose ACK value doesn't satisfy the
  above condition MUST be discarded and an ACK sent back.

Move tcp_send_challenge_ack() before tcp_ack() to avoid a forward
declaration.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Jerry Chu <hkchu@google.com>
---
 net/ipv4/tcp_input.c |   43 +++++++++++++++++++++++------------------
 1 file changed, 25 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 432c366..60cf836 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3552,6 +3552,24 @@ static bool tcp_process_frto(struct sock *sk, int flag)
 	return false;
 }
 
+/* RFC 5961 7 [ACK Throttling] */
+static void tcp_send_challenge_ack(struct sock *sk)
+{
+	/* unprotected vars, we dont care of overwrites */
+	static u32 challenge_timestamp;
+	static unsigned int challenge_count;
+	u32 now = jiffies / HZ;
+
+	if (now != challenge_timestamp) {
+		challenge_timestamp = now;
+		challenge_count = 0;
+	}
+	if (++challenge_count <= sysctl_tcp_challenge_ack_limit) {
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPCHALLENGEACK);
+		tcp_send_ack(sk);
+	}
+}
+
 /* This routine deals with incoming acks, but not outgoing ones. */
 static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 {
@@ -3571,8 +3589,14 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	/* If the ack is older than previous acks
 	 * then we can probably ignore it.
 	 */
-	if (before(ack, prior_snd_una))
+	if (before(ack, prior_snd_una)) {
+		/* RFC 5961 5.2 [Blind Data Injection Attack].[Mitigation] */
+		if (before(ack, prior_snd_una - tp->max_window)) {
+			tcp_send_challenge_ack(sk);
+			return -1;
+		}
 		goto old_ack;
+	}
 
 	/* If the ack includes data we haven't sent yet, discard
 	 * this segment (RFC793 Section 3.9).
@@ -5241,23 +5265,6 @@ out:
 }
 #endif /* CONFIG_NET_DMA */
 
-static void tcp_send_challenge_ack(struct sock *sk)
-{
-	/* unprotected vars, we dont care of overwrites */
-	static u32 challenge_timestamp;
-	static unsigned int challenge_count;
-	u32 now = jiffies / HZ;
-
-	if (now != challenge_timestamp) {
-		challenge_timestamp = now;
-		challenge_count = 0;
-	}
-	if (++challenge_count <= sysctl_tcp_challenge_ack_limit) {
-		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPCHALLENGEACK);
-		tcp_send_ack(sk);
-	}
-}
-
 /* Does PAWS and seqno based validation of an incoming segment, flags will
  * play significant role here.
  */
