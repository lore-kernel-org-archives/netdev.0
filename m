From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH] TCP: fix a bug that triggers large number of TCP RST by mistake
Date: Sat, 22 Jan 2011 11:06:17 -0800
Message-ID: <1295723177-23576-1-git-send-email-hkchu@google.com>
Cc: Jerry Chu <hkchu@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:25660 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038Ab1AXSUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 13:20:53 -0500
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p0OIKqWH015304
	for <netdev@vger.kernel.org>; Mon, 24 Jan 2011 10:20:52 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

This patch fixes a bug that causes TCP RST packets to be generated
on otherwise correctly behaved applications, e.g., no unread data
on close,..., etc. To trigger the bug, at least two conditions must
be met:

1. The FIN flag is set on the last data packet, i.e., it's not on a
separate, FIN only packet.
2. The size of the last data chunk on the receive side matches
exactly with the size of buffer posted by the receiver, and the
receiver closes the socket without any further read attempt.

This bug was first noticed on our netperf based testbed for our IW10
proposal to IETF where a large number of RST packets were observed.
netperf's read side code meets the condition 2 above 100%.

Before the fix, tcp_data_queue() will queue the last skb that meets
condition 1 to sk_receive_queue even though it has fully copied out
(skb_copy_datagram_iovec()) the data. Then if condition 2 is also met,
tcp_recvmsg() often returns all the copied out data successfully
without actually consuming the skb, due to a check
"if ((chunk = len - tp->ucopy.len) != 0) {"
and
"len -= chunk;"
after tcp_prequeue_process() that causes "len" to become 0 and an
early exit from the big while loop.

I don't see any reason not to free the skb whose data have been fully
consumed in tcp_data_queue(), regardless of the FIN flag.  We won't
get there if MSG_PEEK is on. Am I missing some arcane cases related
to urgent data?

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2549b29..eb7f82e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4399,7 +4399,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 			if (!skb_copy_datagram_iovec(skb, 0, tp->ucopy.iov, chunk)) {
 				tp->ucopy.len -= chunk;
 				tp->copied_seq += chunk;
-				eaten = (chunk == skb->len && !th->fin);
+				eaten = (chunk == skb->len);
 				tcp_rcv_space_adjust(sk);
 			}
 			local_bh_disable();
-- 
1.7.3.1

