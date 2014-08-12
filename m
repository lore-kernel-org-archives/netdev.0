From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] net-timestamp: fix missing tcp fragmentation cases
Date: Tue, 12 Aug 2014 15:08:12 -0400
Message-ID: <1407870492-20193-1-git-send-email-willemb@google.com>
References: <CA+FuTSeSCPyr7Rb7v+Wzx9c7VY+kFgUwJsNh-=NzcJW-u8W24w@mail.gmail.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:37554 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754107AbaHLTIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 15:08:20 -0400
Received: by mail-ig0-f202.google.com with SMTP id r2so1059568igi.1
        for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 12:08:19 -0700 (PDT)
In-Reply-To: <CA+FuTSeSCPyr7Rb7v+Wzx9c7VY+kFgUwJsNh-=NzcJW-u8W24w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bytestream timestamps are correlated with a single byte in the skbuff,
recorded in skb_shinfo(skb)->tskey. When fragmenting skbuffs, ensure
that the tskey is set for the fragment in which the tskey falls
(seqno <= tskey < end_seqno).

The original implementation did not address fragmentation in
tcp_fragment or tso_fragment. Add code to inspect the sequence numbers
and move both tskey and the relevant tx_flags if necessary.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/tcp_output.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8fcfc91..ef4a051 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1069,6 +1069,21 @@ static void tcp_adjust_pcount(struct sock *sk, const struct sk_buff *skb, int de
 	tcp_verify_left_out(tp);
 }
 
+static void tcp_fragment_tstamp(struct sk_buff *skb, struct sk_buff *skb2)
+{
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+
+	if (unlikely(shinfo->tx_flags & SKBTX_ANY_TSTAMP) &&
+	    !before(shinfo->tskey, TCP_SKB_CB(skb2)->seq)) {
+		struct skb_shared_info *shinfo2 = skb_shinfo(skb2);
+		u8 tsflags = shinfo->tx_flags & SKBTX_ANY_TSTAMP;
+
+		shinfo->tx_flags &= ~tsflags;
+		shinfo2->tx_flags |= tsflags;
+		swap(shinfo->tskey, shinfo2->tskey);
+	}
+}
+
 /* Function to create two new TCP segments.  Shrinks the given segment
  * to the specified size and appends a new segment with the rest of the
  * packet to the list.  This won't be called frequently, I hope.
@@ -1136,6 +1151,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	 */
 	TCP_SKB_CB(buff)->when = TCP_SKB_CB(skb)->when;
 	buff->tstamp = skb->tstamp;
+	tcp_fragment_tstamp(skb, buff);
 
 	old_factor = tcp_skb_pcount(skb);
 
@@ -1652,6 +1668,7 @@ static int tso_fragment(struct sock *sk, struct sk_buff *skb, unsigned int len,
 
 	buff->ip_summed = skb->ip_summed = CHECKSUM_PARTIAL;
 	skb_split(skb, buff, len);
+	tcp_fragment_tstamp(skb, buff);
 
 	/* Fix up tso_factor for both original and new SKB.  */
 	tcp_set_skb_tso_segs(sk, skb, mss_now);
-- 
2.1.0.rc2.206.gedb03e5
