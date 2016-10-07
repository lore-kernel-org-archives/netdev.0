From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 1/2] Subject: [PATCH] af_iucv: enable control sends in case of SEND_SHUTDOWN
Date: Fri,  7 Oct 2016 15:51:47 +0200
Message-ID: <88ab8b08bdcf2f35fd04e9d0c67b250999d7da33.1475846599.git.ursula.braun@de.ibm.com>
References: <cover.1475846599.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60542 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756410AbcJGNv5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 09:51:57 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u97DndT3108056
        for <netdev@vger.kernel.org>; Fri, 7 Oct 2016 09:51:57 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25xap5p2gs-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2016 09:51:56 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 7 Oct 2016 14:51:54 +0100
In-Reply-To: <cover.1475846599.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1475846599.git.ursula.braun@de.ibm.com>
References: <cover.1475846599.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a socket program has shut down the socket for sending, it can still
receive an undetermined number of packets. The AF_IUCV protocol for
HIPER transport requires sending of a WIN flag from time to time
from the receiver to the sender, otherwise the peer cannot continue
sending. That means sending of control flags must still work, even
though the AF_IUCV socket is shutdown for sending data.
sock_alloc_send_skb() returns with error EPIPE, if socket sk_shutdown
is SEND_SHUTDOWN. Thus this patch temporarily removes the send
shutdown attribute from the socket to enable transfer of control
flags.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 02b45a8..88d0eaa 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -453,19 +453,27 @@ static void iucv_sever_path(struct sock *sk, int with_user_data)
 	}
 }
 
-/* Send FIN through an IUCV socket for HIPER transport */
+/* Send controlling flags through an IUCV socket for HIPER transport */
 static int iucv_send_ctrl(struct sock *sk, u8 flags)
 {
 	int err = 0;
 	int blen;
 	struct sk_buff *skb;
+	u8 shutdown = 0;
 
 	blen = sizeof(struct af_iucv_trans_hdr) + ETH_HLEN;
+	if (sk->sk_shutdown & SEND_SHUTDOWN) {
+		/* controlling flags should be sent anyway */
+		shutdown = sk->sk_shutdown;
+		sk->sk_shutdown &= RCV_SHUTDOWN;
+	}
 	skb = sock_alloc_send_skb(sk, blen, 1, &err);
 	if (skb) {
 		skb_reserve(skb, blen);
 		err = afiucv_hs_send(NULL, sk, skb, flags);
 	}
+	if (shutdown)
+		sk->sk_shutdown = shutdown;
 	return err;
 }
 
-- 
2.8.4
