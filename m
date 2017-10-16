From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 2/2] smc: add SMC rendezvous protocol
Date: Mon, 16 Oct 2017 17:42:02 +0200
Message-ID: <20171016154202.72635-3-ubraun@linux.vnet.ibm.com>
References: <20171016154202.72635-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:39694 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754073AbdJPPmN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 11:42:13 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9GFdmFP017442
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 11:42:13 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dmwrb6wrx-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 11:42:12 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 16 Oct 2017 16:42:10 +0100
In-Reply-To: <20171016154202.72635-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SMC protocol [1] uses a rendezvous protocol to negotiate SMC
capability between peers. The current Linux implementation does not yet
use this rendezvous protocol and, thus, is not compliant to RFC7609 and
incompatible with other SMC implementations like in zOS.
This patch adds support for the SMC rendezvous protocol. It uses a new
TCP experimental option. With this option, SMC capabilities are
exchanged between the peers during the TCP three way handshake.

[1] SMC-R Informational RFC: http://www.rfc-editor.org/info/rfc7609

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/af_smc.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 745f145d4c4d..f1842da9d90e 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -390,6 +390,12 @@ static int smc_connect_rdma(struct smc_sock *smc)
 	int rc = 0;
 	u8 ibport;
 
+	if (!tcp_sk(smc->clcsock->sk)->syn_smc) {
+		/* peer has not signalled SMC-capability */
+		smc->use_fallback = true;
+		goto out_connected;
+	}
+
 	/* IPSec connections opt out of SMC-R optimizations */
 	if (using_ipsec(smc)) {
 		reason_code = SMC_CLC_DECL_IPSEC;
@@ -555,6 +561,7 @@ static int smc_connect(struct socket *sock, struct sockaddr *addr,
 	}
 
 	smc_copy_sock_settings_to_clc(smc);
+	tcp_sk(smc->clcsock->sk)->syn_smc = 1;
 	rc = kernel_connect(smc->clcsock, addr, alen, flags);
 	if (rc)
 		goto out;
@@ -752,6 +759,7 @@ static void smc_listen_work(struct work_struct *work)
 	struct smc_clc_msg_proposal pclc;
 	struct smc_ib_device *smcibdev;
 	struct sockaddr_in peeraddr;
+	bool lgr_lock_taken = false;
 	struct smc_link *link;
 	int reason_code = 0;
 	int rc = 0, len;
@@ -759,6 +767,12 @@ static void smc_listen_work(struct work_struct *work)
 	u8 prefix_len;
 	u8 ibport;
 
+	/* check if peer is smc capable */
+	if (!tcp_sk(newclcsock->sk)->syn_smc) {
+		new_smc->use_fallback = true;
+		goto out_connected;
+	}
+
 	/* do inband token exchange -
 	 *wait for and receive SMC Proposal CLC message
 	 */
@@ -802,6 +816,7 @@ static void smc_listen_work(struct work_struct *work)
 
 	/* allocate connection / link group */
 	mutex_lock(&smc_create_lgr_pending);
+	lgr_lock_taken = true;
 	local_contact = smc_conn_create(new_smc, peeraddr.sin_addr.s_addr,
 					smcibdev, ibport, &pclc.lcl, 0);
 	if (local_contact < 0) {
@@ -882,7 +897,8 @@ static void smc_listen_work(struct work_struct *work)
 	if (newsmcsk->sk_state == SMC_INIT)
 		newsmcsk->sk_state = SMC_ACTIVE;
 enqueue:
-	mutex_unlock(&smc_create_lgr_pending);
+	if (lgr_lock_taken)
+		mutex_unlock(&smc_create_lgr_pending);
 	lock_sock_nested(&lsmc->sk, SINGLE_DEPTH_NESTING);
 	if (lsmc->sk.sk_state == SMC_LISTEN) {
 		smc_accept_enqueue(&lsmc->sk, newsmcsk);
@@ -963,6 +979,7 @@ static int smc_listen(struct socket *sock, int backlog)
 	 * them to the clc socket -- copy smc socket options to clc socket
 	 */
 	smc_copy_sock_settings_to_clc(smc);
+	tcp_sk(smc->clcsock->sk)->syn_smc = 1;
 
 	rc = kernel_listen(smc->clcsock, backlog);
 	if (rc)
@@ -1405,6 +1422,7 @@ static int __init smc_init(void)
 		goto out_sock;
 	}
 
+	static_key_slow_inc(&tcp_have_smc);
 	return 0;
 
 out_sock:
@@ -1429,6 +1447,7 @@ static void __exit smc_exit(void)
 		list_del_init(&lgr->list);
 		smc_lgr_free(lgr); /* free link group */
 	}
+	static_key_slow_dec(&tcp_have_smc);
 	smc_ib_unregister_client();
 	sock_unregister(PF_SMC);
 	proto_unregister(&smc_proto);
-- 
2.13.5
