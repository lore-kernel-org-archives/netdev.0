From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 05/10] net/smc: always call the POLL_IN part of sk_wake_async
Date: Mon, 10 Apr 2017 14:58:00 +0200
Message-ID: <20170410125805.13653-6-ubraun@linux.vnet.ibm.com>
References: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:34972 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753379AbdDJM6X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:58:23 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3ACswmV060713
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:23 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29r8u8vc0f-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:58:23 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 10 Apr 2017 13:58:16 +0100
In-Reply-To: <20170410125805.13653-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wake up reading file descriptors for a closing socket as well, otherwise
some socket applications may stall.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 net/smc/smc_rx.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/smc/smc_rx.c b/net/smc/smc_rx.c
index c4ef9a4..f0c8b08 100644
--- a/net/smc/smc_rx.c
+++ b/net/smc/smc_rx.c
@@ -36,11 +36,10 @@ static void smc_rx_data_ready(struct sock *sk)
 	if (skwq_has_sleeper(wq))
 		wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
 						POLLRDNORM | POLLRDBAND);
+	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
 	if ((sk->sk_shutdown == SHUTDOWN_MASK) ||
 	    (sk->sk_state == SMC_CLOSED))
 		sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_HUP);
-	else
-		sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
 	rcu_read_unlock();
 }
 
-- 
2.10.2
