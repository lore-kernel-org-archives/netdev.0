From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/2] af_iucv: Move sockaddr length checks to before accessing sa_family in bind and connect handlers
Date: Fri, 23 Jun 2017 19:32:28 +0200
Message-ID: <20170623173228.70128-3-jwi@linux.vnet.ibm.com>
References: <20170623173228.70128-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44806 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754849AbdFWRcx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 13:32:53 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5NHTK6C004494
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 13:32:42 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b93r6jb9t-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 13:32:42 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 23 Jun 2017 18:32:40 +0100
In-Reply-To: <20170623173228.70128-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mateusz Jurczyk <mjurczyk@google.com>

Verify that the caller-provided sockaddr structure is large enough to
contain the sa_family field, before accessing it in bind() and connect()
handlers of the AF_IUCV socket. Since neither syscall enforces a minimum
size of the corresponding memory region, very short sockaddrs (zero or
one byte long) result in operating on uninitialized memory while
referencing .sa_family.

Fixes: 52a82e23b9f2 ("af_iucv: Validate socket address length in iucv_sock_bind()")
Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
[jwi: removed unneeded null-check for addr]
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 05112094d76b..ac033e413bc5 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -715,10 +715,8 @@ static int iucv_sock_bind(struct socket *sock, struct sockaddr *addr,
 	char uid[9];
 
 	/* Verify the input sockaddr */
-	if (!addr || addr->sa_family != AF_IUCV)
-		return -EINVAL;
-
-	if (addr_len < sizeof(struct sockaddr_iucv))
+	if (addr_len < sizeof(struct sockaddr_iucv) ||
+	    addr->sa_family != AF_IUCV)
 		return -EINVAL;
 
 	lock_sock(sk);
@@ -862,7 +860,7 @@ static int iucv_sock_connect(struct socket *sock, struct sockaddr *addr,
 	struct iucv_sock *iucv = iucv_sk(sk);
 	int err;
 
-	if (addr->sa_family != AF_IUCV || alen < sizeof(struct sockaddr_iucv))
+	if (alen < sizeof(struct sockaddr_iucv) || addr->sa_family != AF_IUCV)
 		return -EINVAL;
 
 	if (sk->sk_state != IUCV_OPEN && sk->sk_state != IUCV_BOUND)
-- 
2.11.2
