From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: [PATCH v1 net-next 4/6] net: don't make false software transmit timestamps
Date: Wed, 26 Apr 2017 16:50:33 +0200
Message-ID: <20170426145035.25846-5-mlichvar@redhat.com>
References: <20170426145035.25846-1-mlichvar@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59318 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S3001500AbdDZOuq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 10:50:46 -0400
In-Reply-To: <20170426145035.25846-1-mlichvar@redhat.com>
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
index 5ea5f29..68b9304 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -688,7 +688,8 @@ static void put_ts_pktinfo(struct msghdr *msg, struct sk_buff *skb)
 void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb)
 {
-	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP);
+	int need_software_tstamp = sock_flag(sk, SOCK_RCVTSTAMP) &&
+				   !skb_is_err_queue(skb);
 	struct scm_timestamping tss;
 	int empty = 1;
 	struct skb_shared_hwtstamps *shhwtstamps =
-- 
2.9.3
