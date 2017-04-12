From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [RFC PATCH 5/7] net: don't make false software transmit timestamps
Date: Wed, 12 Apr 2017 16:17:35 +0200
Message-ID: <20170412141737.5881-6-mlichvar@redhat.com>
References: <20170412141737.5881-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33576 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753306AbdDLOR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 10:17:57 -0400
In-Reply-To: <20170412141737.5881-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If software timestamping is enabled by the SO_TIMESTAMP(NS) option
when a message without timestamp is already waiting in the queue, the
__sock_recv_timestamp() function will read the current time to make a
timestamp in order to always have something for the application.

However, this applies also to outgoing packets looped back to the error
queue when hardware timestamping is enabled by the SO_TIMESTAMPING
option. A software transmit timestamp made after the actual transmission
is added to messages with hardware timestamps.

Modify the function to save the current time as a software timestamp
only if it's for a received packet (i.e. it's not in the error queue).

CC: Richard Cochran <richardcochran@gmail.com>
CC: Willem de Bruijn <willemb@google.com>
Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>
---
 net/socket.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/socket.c b/net/socket.c
index f272019..32e78de 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -668,7 +668,8 @@ static bool skb_is_err_queue(const struct sk_buff *skb)
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb)
 {
-	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
+	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP) &&
+				   !skb_is_err_queue(skb);
 	struct scm_timestamping tss;
 	struct scm_ts_pktinfo ts_pktinfo;
 	int empty = 1;
-- 
2.9.3
