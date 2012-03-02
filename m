From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: fix tcp_retransmit_skb() to maintain MSS invariant
Date: Fri,  2 Mar 2012 09:27:29 -0500
Message-ID: <1330698449-2969-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:56208 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758764Ab2CBP3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 10:29:22 -0500
Received: by eaaq10 with SMTP id q10so65965eaa.1
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 07:29:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit fixes tcp_retransmit_skb() to respect the invariant that
an skb in the write queue that might be SACKed (that is, that precedes
tcp_send_head()) is either less than tcp_skb_mss(skb) or an integral
multiple of tcp_skb_mss(skb).

Various parts of the TCP code maintain or assume this invariant,
including at least tcp_write_xmit(), tcp_mss_split_point(),
tcp_match_skb_to_sack(), and tcp_shifted_skb().

tcp_retransmit_skb() did not maintain this invariant. It checked the
current MSS and called tcp_fragment() to make sure that the skb we're
retransmitting is at most cur_mss, but in the process it took the
excess bytes and created an arbitrary-length skb (one that is not
necessarily an integral multiple of its MSS) and inserted it in the
write queue after the skb we're retransmitting.

One potential indirect effect of this problem is tcp_shifted_skb()
creating a coalesced SACKed skb that has a pcount that is 1 too large
for its length. This happened because tcp_shifted_skb() assumed that
skbs are integral multiples of MSS, so you can just add pcounts of
input skbs to find the pcount of the output skb. Suspected specific
symtoms of this problem include the WARN_ON(len > skb->len) in
tcp_fragment() firing, as the 1-too-large pcount ripples though to
tcp_mark_head_lost() trying to chop off too many bytes to mark as
lost.

It's also possible this bug is related to recent reports of sacked_out
becoming negative.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c |   44 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4ff3b6d..13034ad 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2070,6 +2070,48 @@ static void tcp_retrans_try_collapse(struct sock *sk, struct sk_buff *to,
 	}
 }
 
+/* So we can retransmit skb, fragment it to be cur_mss bytes. In
+ * addition, we must maintain the invariant that whatever skbs we
+ * leave in the write queue are integral multiples of the MSS or a
+ * remaining small sub-MSS portion. This means we fragment the skb
+ * into potentially three skbs in the write queue:
+ *
+ *  (1) The first skb of exactly 1*cur_mss, which we will retransmit now.
+ *  (2) A "bulk" skb that is an integral multiple of the cur_mss
+ *  (3) A "left-over" skb that has any remaining portion smaller than cur_mss
+ *
+ * Since either of the two required fragmentation operations can fail
+ * (e.g. due to ENOMEM), and we want this invariant to be maintained
+ * if either fails, we chop off (3) first and then chop off (1).
+ *
+ * Returns non-zero if an error occurred which prevented the full splitting.
+ */
+static int tcp_retrans_mss_split(struct sock *sk, struct sk_buff *skb,
+				 unsigned int cur_mss)
+{
+	int err;
+	unsigned int len;
+
+	/* Chop off any "left-over" at end that is not aligned to cur_mss. */
+	if (cur_mss != tcp_skb_mss(skb)) {
+		len = skb->len - skb->len % cur_mss;
+		if (len < skb->len) {
+			err = tcp_fragment(sk, skb, len, cur_mss);
+			if (err < 0)
+				return err;
+		}
+	}
+
+	/* Chop off a single MSS at the beginning to retransmit now. */
+	if (skb->len > cur_mss) {
+		err = tcp_fragment(sk, skb, cur_mss, cur_mss);
+		if (err < 0)
+			return err;
+	}
+
+	return 0;
+}
+
 /* This retransmits one SKB.  Policy decisions and retransmit queue
  * state updates are done by the caller.  Returns non-zero if an
  * error occurred which prevented the send.
@@ -2115,7 +2157,7 @@ int tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		return -EAGAIN;
 
 	if (skb->len > cur_mss) {
-		if (tcp_fragment(sk, skb, cur_mss, cur_mss))
+		if (tcp_retrans_mss_split(sk, skb, cur_mss))
 			return -ENOMEM; /* We'll try again later. */
 	} else {
 		int oldpcount = tcp_skb_pcount(skb);
-- 
1.7.7.3
