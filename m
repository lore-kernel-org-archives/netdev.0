From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] net-timestamp: only report sw timestamp if reporting bit is set
Date: Wed,  3 Sep 2014 12:01:18 -0400
Message-ID: <1409760078-25930-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:47754 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756330AbaICQBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 12:01:21 -0400
Received: by mail-yk0-f201.google.com with SMTP id 142so977641ykq.2
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 09:01:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timestamping API has separate bits for generating and reporting
timestamps. A software timestamp should only be reported for a packet
when the packet has the relevant generation flag (SKBTX_..) set
and the socket has reporting bit SOF_TIMESTAMPING_SOFTWARE set.

The second check was accidentally removed. Reinstitute the original
behavior.

Tested:
  Without this patch, Documentation/networking/txtimestamp reports
  timestamps regardless of whether SOF_TIMESTAMPING_SOFTWARE is set.
  After the patch, it only reports them when the flag is set.

Fixes: f24b9be5957b ("net-timestamp: extend SCM_TIMESTAMPING ancillary data struct")

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h | 4 +---
 net/socket.c       | 3 +--
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7f2ab72..b9a5bd0 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -2165,9 +2165,7 @@ sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 	 */
 	if (sock_flag(sk, SOCK_RCVTSTAMP) ||
 	    (sk->sk_tsflags & SOF_TIMESTAMPING_RX_SOFTWARE) ||
-	    (kt.tv64 &&
-	     (sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE ||
-	      skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP)) ||
+	    (kt.tv64 && sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE) ||
 	    (hwtstamps->hwtstamp.tv64 &&
 	     (sk->sk_tsflags & SOF_TIMESTAMPING_RAW_HARDWARE)))
 		__sock_recv_timestamp(msg, sk, skb);
diff --git a/net/socket.c b/net/socket.c
index 95ee7d8..4eb09b3 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -734,8 +734,7 @@ void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	}
 
 	memset(&tss, 0, sizeof(tss));
-	if ((sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE ||
-	     skb_shinfo(skb)->tx_flags & SKBTX_ANY_SW_TSTAMP) &&
+	if ((sk->sk_tsflags & SOF_TIMESTAMPING_SOFTWARE) &&
 	    ktime_to_timespec_cond(skb->tstamp, tss.ts + 0))
 		empty = 0;
 	if (shhwtstamps &&
-- 
2.1.0.rc2.206.gedb03e5
