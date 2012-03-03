From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: don't fragment SACKed skbs in tcp_mark_head_lost()
Date: Sat,  3 Mar 2012 02:36:51 -0500
Message-ID: <1330760211-25785-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f202.google.com ([74.125.82.202]:53952 "EHLO
	mail-we0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab2CCHgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 02:36:54 -0500
Received: by wejx9 with SMTP id x9so92203wej.1
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 23:36:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcp_mark_head_lost() we should not attempt to fragment a SACKed skb
to mark the first portion as lost. This is for two primary reasons:

(1) tcp_shifted_skb() coalesces adjacent regions of SACKed skbs. When
doing this, it preserves the sum of their packet counts in order to
reflect the real-world dynamics on the wire. But given that skbs can
have remainders that do not align to MSS boundaries, this packet count
preservation means that for SACKed skbs there is not necessarily a
direct linear relationship between tcp_skb_pcount(skb) and
skb->len. Thus tcp_mark_head_lost()'s previous attempts to fragment
off and mark as lost a prefix of length (packets - oldcnt)*mss from
SACKed skbs were leading to occasional failures of the WARN_ON(len >
skb->len) in tcp_fragment() (which used to be a BUG_ON(); see the
recent "crash in tcp_fragment" thread on netdev).

(2) there is no real point in fragmenting off part of a SACKed skb and
calling tcp_skb_mark_lost() on it, since tcp_skb_mark_lost() is a NOP
for SACKed skbs.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ee42d42..d9b83d1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2569,6 +2569,7 @@ static void tcp_mark_head_lost(struct sock *sk, int packets, int mark_head)
 
 		if (cnt > packets) {
 			if ((tcp_is_sack(tp) && !tcp_is_fack(tp)) ||
+			    (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) ||
 			    (oldcnt >= packets))
 				break;
 
-- 
1.7.7.3
