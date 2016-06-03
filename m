From: Pau Espin Pedrol <pau.espin@tessares.net>
Subject: [PATCH net-next] tcp: accept RST if SEQ matches right edge of SACK block
Date: Fri,  3 Jun 2016 17:51:11 +0200
Message-ID: <1464969071-9947-1-git-send-email-pau.espin@tessares.net>
References: <1464966836.5939.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Pau Espin Pedrol <pau.espin@tessares.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36344 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbcFCPvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:51:32 -0400
Received: by mail-wm0-f51.google.com with SMTP id n184so2198588wmn.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 08:51:31 -0700 (PDT)
In-Reply-To: <1464966836.5939.189.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 5961 advises to only accept RST packets containing a seq number
matching the next expected seq number instead of the whole receive
window in order to avoid spoofing attacks.

However, this situation is not optimal in the case SACK is in use at the
time the RST is sent. I recently run into a scenario in which packet
losses were high while uploading data to a server, and userspace was
willing to frequently terminate connections by sending a RST. In
this case, the ACK sent on the receiver side (rcv_nxt) is frozen waiting
for a lost packet retransmission and a SACK block is used to let the
client continue uploading data. At some point later on, the client sends
the RST (snd_nxt), which matches the next expected seq number of the
SACK block on the receiver side which is going forward receiving data.

In this scenario, as RFC 5961 defines, the RST SEQ doesn't match the
frozen main ACK at receiver side and thus gets dropped and a challenge
ACK is sent, which gets usually lost due to network conditions. The main
consequence is that the connection stays alive for a while even if it
made sense to accept the RST. This can get really bad if lots of
connections like this one are created in few seconds, allocating all the
resources of the server easily.

For security reasons, not all SACK blocks are checked (there could be a
big amount of SACK blocks => acceptable SEQ numbers). Only up to the 4
most recently updated SACK blocks (selective_acks[4] field) are checked,
which are usually the ones with bigger probability to receive a RST as
next packet. This should make it still difficult for attackers to inject
a valid RST message.

This patch was tested in a 3.18 kernel and probed to improve the
situation in the scenario described above.

Signed-off-by: Pau Espin Pedrol <pau.espin@tessares.net>
---
 net/ipv4/tcp_input.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6c8f4cd0..8c5712a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5159,6 +5159,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 				  const struct tcphdr *th, int syn_inerr)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	bool rst_seq_match = false;
 
 	/* RFC1323: H1. Apply PAWS check first. */
 	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
@@ -5195,13 +5196,28 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 
 	/* Step 2: check RST bit */
 	if (th->rst) {
-		/* RFC 5961 3.2 :
-		 * If sequence number exactly matches RCV.NXT, then
+		/* RFC 5961 3.2 (extended to match against SACK too if available):
+		 * If seq num exactly matches RCV.NXT or a recently updated SACK block,
+		 * then
 		 *     RESET the connection
 		 * else
 		 *     Send a challenge ACK
 		 */
-		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt)
+		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt) {
+			rst_seq_match = true;
+		} else if (tcp_is_sack(tp)) {
+			struct tcp_sack_block *sp = &tp->selective_acks[0];
+			int this_sack;
+
+			for (this_sack = 0; this_sack < tp->rx_opt.num_sacks; ++this_sack) {
+				if (TCP_SKB_CB(skb)->seq == sp[this_sack].end_seq) {
+					rst_seq_match = true;
+					break;
+				}
+			}
+		}
+
+		if (rst_seq_match)
 			tcp_reset(sk);
 		else
 			tcp_send_challenge_ack(sk, skb);
-- 
2.5.0


-- 

------------------------------
DISCLAIMER.
This email and any files transmitted with it are confidential and intended 
solely for the use of the individual or entity to whom they are addressed. 
If you have received this email in error please notify the system manager. 
This message contains confidential information and is intended only for the 
individual named. If you are not the named addressee you should not 
disseminate, distribute or copy this e-mail. Please notify the sender 
immediately by e-mail if you have received this e-mail by mistake and 
delete this e-mail from your system. If you are not the intended recipient 
you are notified that disclosing, copying, distributing or taking any 
action in reliance on the contents of this information is strictly 
prohibited.
