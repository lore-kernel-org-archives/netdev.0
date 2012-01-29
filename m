From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: fix tcp_trim_head() to adjust segment count with skb MSS
Date: Sat, 28 Jan 2012 22:29:46 -0500
Message-ID: <1327807786-27185-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f202.google.com ([209.85.216.202]:34352 "EHLO
	mail-qy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669Ab2A2DaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 22:30:00 -0500
Received: by qcsd17 with SMTP id d17so287024qcs.1
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 19:29:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit fixes tcp_trim_head() to recalculate the number of
segments in the skb with the skb's existing MSS, so trimming the head
causes the skb segment count to be monotonically non-increasing - it
should stay the same or go down, but not increase.

Previously tcp_trim_head() used the current MSS of the connection. But
if there was a decrease in MSS between original transmission and ACK
(e.g. due to PMTUD), this could cause tcp_trim_head() to
counter-intuitively increase the segment count when trimming bytes off
the head of an skb. This violated assumptions in tcp_tso_acked() that
tcp_trim_head() only decreases the packet count, so that packets_acked
in tcp_tso_acked() could underflow, leading tcp_clean_rtx_queue() to
pass u32 pkts_acked values as large as 0xffffffff to
ca_ops->pkts_acked().

As an aside, if tcp_trim_head() had really wanted the skb to reflect
the current MSS, it should have called tcp_set_skb_tso_segs()
unconditionally, since a decrease in MSS would mean that a
single-packet skb should now be sliced into multiple segments.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8c8de27..4ff3b6d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1141,11 +1141,9 @@ int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
 	sk_mem_uncharge(sk, len);
 	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
 
-	/* Any change of skb->len requires recalculation of tso
-	 * factor and mss.
-	 */
+	/* Any change of skb->len requires recalculation of tso factor. */
 	if (tcp_skb_pcount(skb) > 1)
-		tcp_set_skb_tso_segs(sk, skb, tcp_current_mss(sk));
+		tcp_set_skb_tso_segs(sk, skb, tcp_skb_mss(skb));
 
 	return 0;
 }
-- 
1.7.7.3
