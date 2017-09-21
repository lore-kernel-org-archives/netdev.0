From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 3/9] net/smc: take RCU read lock for routing cache lookup
Date: Thu, 21 Sep 2017 09:16:28 +0200
Message-ID: <20170921071634.16883-4-ubraun@linux.vnet.ibm.com>
References: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:41292 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751854AbdIUHQq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:16:46 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8L7GeDd083925
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:16:45 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d48cy1b7c-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:16:45 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 21 Sep 2017 08:16:43 +0100
In-Reply-To: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

smc_netinfo_by_tcpsk() looks up the routing cache. Such a lookup requires
protection by an RCU read lock.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/af_smc.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 8c6d24b2995d..2e8d2dabac0c 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -282,6 +282,7 @@ int smc_netinfo_by_tcpsk(struct socket *clcsock,
 			 __be32 *subnet, u8 *prefix_len)
 {
 	struct dst_entry *dst = sk_dst_get(clcsock->sk);
+	struct in_device *in_dev;
 	struct sockaddr_in addr;
 	int rc = -ENOENT;
 	int len;
@@ -298,14 +299,17 @@ int smc_netinfo_by_tcpsk(struct socket *clcsock,
 	/* get address to which the internal TCP socket is bound */
 	kernel_getsockname(clcsock, (struct sockaddr *)&addr, &len);
 	/* analyze IPv4 specific data of net_device belonging to TCP socket */
-	for_ifa(dst->dev->ip_ptr) {
-		if (ifa->ifa_address != addr.sin_addr.s_addr)
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(dst->dev);
+	for_ifa(in_dev) {
+		if (!inet_ifa_match(addr.sin_addr.s_addr, ifa))
 			continue;
 		*prefix_len = inet_mask_len(ifa->ifa_mask);
 		*subnet = ifa->ifa_address & ifa->ifa_mask;
 		rc = 0;
 		break;
-	} endfor_ifa(dst->dev->ip_ptr);
+	} endfor_ifa(in_dev);
+	rcu_read_unlock();
 
 out_rel:
 	dst_release(dst);
-- 
2.13.5
