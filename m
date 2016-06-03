From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 05/15] smc: CLC handshake (incl. preparation steps)
Date: Fri,  3 Jun 2016 17:27:04 +0200
Message-ID: <201606031527.u53FQ0RC002637@mx0a-001b2d01.pphosted.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:59115 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752089AbcFCP1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 11:27:45 -0400
Received: from pps.filterd (m0049461.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u53FQ0RC002637
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 11:27:43 -0400
Received: from e06smtp17.uk.ibm.com (e06smtp17.uk.ibm.com [195.75.94.113])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23bbsej9k8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 11:27:43 -0400
Received: from localhost
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 3 Jun 2016 16:27:41 +0100
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
In-Reply-To: <cover.1464967161.git.ursula.braun@de.ibm.com>
References: <cover.1464967161.git.ursula.braun@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* CLC (Connection Layer Control) handshake

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Makefile  |   2 +-
 net/smc/af_smc.c  | 467 ++++++++++++++++++++++++++++++++++++++++++++++++++----
 net/smc/smc.h     |  24 ++-
 net/smc/smc_clc.c | 251 +++++++++++++++++++++++++++++
 net/smc/smc_clc.h | 111 +++++++++++++
 5 files changed, 824 insertions(+), 31 deletions(-)
 create mode 100644 net/smc/smc_clc.c
 create mode 100644 net/smc/smc_clc.h

diff --git a/net/smc/Makefile b/net/smc/Makefile
index 50f39ff..c0ad588 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,2 +1,2 @@
 obj-$(CONFIG_SMC)	+= smc.o
-smc-y := af_smc.o smc_pnet.o smc_ib.o
+smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 2fa3042..f8c60db 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -6,6 +6,13 @@
  *  offers an alternative communication option for TCP-protocol sockets
  *  applicable with RoCE-cards only
  *
+ *  Initial restrictions:
+ *    - non-blocking connect postponed
+ *    - IPv6 support postponed
+ *    - support for alternate links postponed
+ *    - partial support for non-blocking sockets only
+ *    - support for urgent data postponed
+ *
  *  Copyright IBM Corp. 2016
  *
  *  Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
@@ -17,12 +24,18 @@
 
 #include <linux/module.h>
 #include <linux/socket.h>
+#include <linux/inetdevice.h>
+#include <linux/workqueue.h>
 #include <net/sock.h>
+#include <net/tcp.h>
 
 #include "smc.h"
+#include "smc_clc.h"
 #include "smc_ib.h"
 #include "smc_pnet.h"
 
+static void smc_tcp_listen_work(struct work_struct *);
+
 static void smc_set_keepalive(struct sock *sk, int val)
 {
 	struct smc_sock *smc = smc_sk(sk);
@@ -94,6 +107,11 @@ static struct sock *smc_sock_alloc(struct net *net, struct socket *sock)
 	smc = smc_sk(sk);
 	smc->clcsock = NULL;
 	smc->use_fallback = 0;
+	smc->addr = NULL;
+	smc->listen_smc = NULL;
+	INIT_WORK(&smc->tcp_listen_work, smc_tcp_listen_work);
+	INIT_LIST_HEAD(&smc->accept_q);
+	spin_lock_init(&smc->accept_q_lock);
 
 	return sk;
 }
@@ -187,6 +205,123 @@ static void smc_copy_sock_settings_to_smc(struct smc_sock *smc)
 	smc_copy_sock_settings(&smc->sk, smc->clcsock->sk, SK_FLAGS_CLC_TO_SMC);
 }
 
+/* determine subnet and mask of internal TCP socket */
+int smc_netinfo_by_tcpsk(struct socket *clcsock,
+			 __be32 *subnet, u8 *prefix_len)
+{
+	struct dst_entry *dst = sk_dst_get(clcsock->sk);
+	struct sockaddr_in addr;
+	int rc = -ENOENT;
+	int len;
+
+	if (!dst) {
+		rc = -ENOTCONN;
+		goto out;
+	}
+	if (!dst->dev) {
+		rc = -ENODEV;
+		goto out_rel;
+	}
+
+	/* get address to which the internal TCP socket is bound */
+	kernel_getsockname(clcsock, (struct sockaddr *)&addr, &len);
+	/* analyze IPv4 specific data of net_device belonging to TCP socket */
+	for_ifa(dst->dev->ip_ptr) {
+		if (ifa->ifa_address != addr.sin_addr.s_addr)
+			continue;
+		*prefix_len = inet_mask_len(ifa->ifa_mask);
+		*subnet = ifa->ifa_address & ifa->ifa_mask;
+		rc = 0;
+		break;
+	} endfor_ifa(dst->dev->ip_ptr);
+
+out_rel:
+	dst_release(dst);
+out:
+	return rc;
+}
+
+/* setup for RDMA connection of client */
+static int smc_connect_rdma(struct smc_sock *smc)
+{
+	struct smc_clc_msg_accept_confirm aclc;
+	struct smc_ib_device *smcibdev;
+	int reason_code = 0;
+	int rc = 0;
+	u8 ibport;
+
+	if (smc->clc_started)
+		return rc;
+	smc->clc_started = 1;
+
+	/* IPSec connections opt out of SMC-R optimizations */
+	if (using_ipsec(smc)) {
+		reason_code = SMC_CLC_DECL_IPSEC;
+		goto decline_rdma;
+	}
+
+	/* PNET table look up: search active ib_device and port
+	 * within same PNETID that also contains the ethernet device
+	 * used for the internal TCP socket
+	 */
+	smc_pnet_find_roce_resource(smc->clcsock->sk, &smcibdev, &ibport);
+	if (!smcibdev) {
+		reason_code = SMC_CLC_DECL_CNFERR; /* configuration error */
+		goto decline_rdma;
+	}
+
+	/* do inband token exchange */
+	reason_code = smc_clc_send_proposal(smc, smcibdev, ibport);
+	if (reason_code < 0) {
+		rc = reason_code;
+		goto out_err;
+	}
+	if (reason_code > 0) /* configuration error */
+		goto decline_rdma;
+	/* receive SMC Accept CLC message */
+	reason_code = smc_clc_wait_msg(smc, &aclc, sizeof(aclc),
+				       SMC_CLC_ACCEPT);
+	if (reason_code < 0) {
+		rc = reason_code;
+		goto out_err;
+	}
+	if (reason_code > 0)
+		goto decline_rdma;
+
+	/* tbd in follow-on patch: more steps to setup RDMA communcication,
+	 * create connection, link group, link
+	 */
+
+	/* tbd in follow-on patch: more steps to setup RDMA communcication,
+	 * create rmbs, map rmbs, rtoken_handling, modify_qp
+	 */
+
+	rc = smc_clc_send_confirm(smc);
+	if (rc)
+		goto out_err;
+
+	/* tbd in follow-on patch: llc_confirm */
+
+out_connected:
+	smc_copy_sock_settings_to_clc(smc);
+	smc->sk.sk_state = SMC_ACTIVE;
+
+	return rc;
+
+decline_rdma:
+	/* RDMA setup failed, switch back to TCP */
+	smc->use_fallback = 1;
+	if (reason_code && (reason_code != SMC_CLC_DECL_REPLY)) {
+		rc = smc_clc_send_decline(smc, reason_code, 0);
+		if (rc < sizeof(struct smc_clc_msg_decline))
+			goto out_err;
+	}
+	goto out_connected;
+
+out_err:
+	return rc;
+}
+
 static int smc_connect(struct socket *sock, struct sockaddr *addr,
 		       int alen, int flags)
 {
@@ -201,6 +336,7 @@ static int smc_connect(struct socket *sock, struct sockaddr *addr,
 		goto out_err;
 	if (addr->sa_family != AF_INET)
 		goto out_err;
+	smc->addr = addr;	/* needed for nonblocking connect */
 
 	lock_sock(sk);
 	switch (sk->sk_state) {
@@ -219,12 +355,12 @@ static int smc_connect(struct socket *sock, struct sockaddr *addr,
 	if (rc)
 		goto out;
 
-	sk->sk_state = SMC_ACTIVE;
-
-	/* always use TCP fallback as transport mechanism for now;
-	 * This will change once RDMA transport is implemented
-	 */
-	smc->use_fallback = 1;
+	/* setup RDMA connection */
+	rc = smc_connect_rdma(smc);
+	if (rc < 0)
+		goto out;
+	else
+		rc = 0; /* success cases including fallback */
 
 out:
 	release_sock(sk);
@@ -239,17 +375,32 @@ static int smc_clcsock_accept(struct smc_sock *lsmc, struct smc_sock **new_smc)
 	struct sock *new_sk;
 	int rc;
 
+	release_sock(&lsmc->sk);
 	new_sk = smc_sock_alloc(sock_net(sk), NULL);
 	if (!new_sk) {
 		rc = -ENOMEM;
 		lsmc->sk.sk_err = ENOMEM;
 		*new_smc = NULL;
+		lock_sock(&lsmc->sk);
 		goto out;
 	}
 	*new_smc = smc_sk(new_sk);
 
 	rc = kernel_accept(lsmc->clcsock, &new_clcsock, 0);
-	if (rc) {
+	lock_sock(&lsmc->sk);
+	if  (rc < 0) {
+		lsmc->sk.sk_err = -rc;
+		new_sk->sk_state = SMC_CLOSED;
+		sock_set_flag(new_sk, SOCK_DEAD);
+		sock_put(new_sk);
+		*new_smc = NULL;
+		goto out;
+	}
+	if (lsmc->sk.sk_state == SMC_CLOSED) {
+		if (new_clcsock)
+			sock_release(new_clcsock);
+		new_sk->sk_state = SMC_CLOSED;
+		sock_set_flag(new_sk, SOCK_DEAD);
 		sock_put(new_sk);
 		*new_smc = NULL;
 		goto out;
@@ -260,6 +411,216 @@ out:
 	return rc;
 }
 
+/* add a just created sock to the accept queue of the listen sock as
+ * candidate for a following socket accept call from user space
+ */
+static void smc_accept_enqueue(struct sock *parent, struct sock *sk)
+{
+	struct smc_sock *par = smc_sk(parent);
+
+	sock_hold(sk);
+	spin_lock(&par->accept_q_lock);
+	list_add_tail(&smc_sk(sk)->accept_q, &par->accept_q);
+	spin_unlock(&par->accept_q_lock);
+	sk_acceptq_added(parent);
+}
+
+/* remove a socket from the accept queue of its parental listening socket */
+static void smc_accept_unlink(struct sock *sk)
+{
+	struct smc_sock *par = smc_sk(sk)->listen_smc;
+
+	spin_lock(&par->accept_q_lock);
+	list_del_init(&smc_sk(sk)->accept_q);
+	spin_unlock(&par->accept_q_lock);
+	sk_acceptq_removed(&smc_sk(sk)->listen_smc->sk);
+	sock_put(sk);
+}
+
+/* remove a sock from the accept queue to bind it to a new socket created
+ * for a socket accept call from user space
+ */
+static struct sock *smc_accept_dequeue(struct sock *parent,
+				       struct socket *new_sock)
+{
+	struct smc_sock *isk, *n;
+	struct sock *new_sk;
+
+	list_for_each_entry_safe(isk, n, &smc_sk(parent)->accept_q, accept_q) {
+		new_sk = (struct sock *)isk;
+
+		smc_accept_unlink(new_sk);
+		if (new_sk->sk_state == SMC_CLOSED) {
+			/* tbd in follow-on patch: close this sock */
+			continue;
+		}
+		if (new_sock)
+			sock_graft(new_sk, new_sock);
+		return new_sk;
+	}
+	return NULL;
+}
+
+/* clean up for a created but never accepted sock */
+static void smc_close_non_accepted(struct sock *sk)
+{
+	struct smc_sock *smc = smc_sk(sk);
+
+	sock_hold(sk);
+	if (smc->clcsock) {
+		struct socket *tcp;
+
+		tcp = smc->clcsock;
+		smc->clcsock = NULL;
+		sock_release(tcp);
+	}
+	/* more closing stuff to be added with socket closing patch */
+	sock_put(sk);
+}
+
+/* setup for RDMA connection of server */
+static void smc_listen_work(struct work_struct *work)
+{
+	struct smc_sock *new_smc = container_of(work, struct smc_sock,
+						smc_listen_work);
+	struct socket *newclcsock = new_smc->clcsock;
+	struct smc_sock *lsmc = new_smc->listen_smc;
+	struct smc_clc_msg_accept_confirm cclc;
+	struct sock *newsmcsk = &new_smc->sk;
+	struct smc_clc_msg_proposal pclc;
+	struct smc_ib_device *smcibdev;
+	struct sockaddr_in peeraddr;
+	int reason_code = 0;
+	int rc = 0, len;
+	__be32 subnet;
+	u8 prefix_len;
+	u8 ibport;
+
+	/* do inband token exchange -
+	 *wait for and receive SMC Proposal CLC message
+	 */
+	reason_code = smc_clc_wait_msg(new_smc, &pclc, sizeof(pclc),
+				       SMC_CLC_PROPOSAL);
+	if (reason_code < 0)
+		goto out_err;
+	if (reason_code > 0)
+		goto decline_rdma;
+
+	/* IPSec connections opt out of SMC-R optimizations */
+	if (using_ipsec(new_smc)) {
+		reason_code = SMC_CLC_DECL_IPSEC;
+		goto decline_rdma;
+	}
+
+	/* PNET table look up: search active ib_device and port
+	 * within same PNETID that also contains the ethernet device
+	 * used for the internal TCP socket
+	 */
+	smc_pnet_find_roce_resource(newclcsock->sk, &smcibdev, &ibport);
+	if (!smcibdev) {
+		reason_code = SMC_CLC_DECL_CNFERR; /* configuration error */
+		goto decline_rdma;
+	}
+
+	/* determine subnet and mask from internal TCP socket */
+	rc = smc_netinfo_by_tcpsk(newclcsock, &subnet, &prefix_len);
+	if (rc) {
+		reason_code = SMC_CLC_DECL_CNFERR; /* configuration error */
+		goto decline_rdma;
+	}
+	if ((pclc.outgoing_subnet != subnet) ||
+	    (pclc.prefix_len != prefix_len)) {
+		reason_code = SMC_CLC_DECL_CNFERR; /* configuration error */
+		goto decline_rdma;
+	}
+
+	/* get address of the peer connected to the internal TCP socket */
+	kernel_getpeername(newclcsock, (struct sockaddr *)&peeraddr, &len);
+
+	/* tbd in follow-on patch: more steps to setup RDMA communcication,
+	 * create connection, link_group, link
+	 */
+
+	/* tbd in follow-on patch: more steps to setup RDMA communcication,
+	 * create rmbs, map rmbs
+	 */
+
+	rc = smc_clc_send_accept(new_smc);
+	if (rc)
+		goto out_err;
+
+	/* receive SMC Confirm CLC message */
+	reason_code = smc_clc_wait_msg(new_smc, &cclc, sizeof(cclc),
+				       SMC_CLC_CONFIRM);
+	if (reason_code < 0)
+		goto out_err;
+	if (reason_code > 0)
+		goto decline_rdma;
+
+	/* tbd in follow-on patch: more steps to setup RDMA communcication,
+	 * rtoken_handling, modify_qp
+	 */
+
+out_connected:
+	sk_refcnt_debug_inc(newsmcsk);
+	newsmcsk->sk_state = SMC_ACTIVE;
+enqueue:
+	lock_sock(&lsmc->sk);
+	if (lsmc->sk.sk_state == SMC_LISTEN) {
+		smc_accept_enqueue(&lsmc->sk, newsmcsk);
+	} else { /* no longer listening */
+		smc_close_non_accepted(newsmcsk);
+	}
+	release_sock(&lsmc->sk);
+
+	/* Wake up accept */
+	lsmc->sk.sk_data_ready(&lsmc->sk);
+	sock_put(&lsmc->sk); /* sock_hold in smc_tcp_listen_work */
+	return;
+
+decline_rdma:
+	/* RDMA setup failed, switch back to TCP */
+	new_smc->use_fallback = 1;
+	if (reason_code && (reason_code != SMC_CLC_DECL_REPLY)) {
+		rc = smc_clc_send_decline(new_smc, reason_code, 0);
+		if (rc < sizeof(struct smc_clc_msg_decline))
+			goto out_err;
+	}
+	goto out_connected;
+
+out_err:
+	newsmcsk->sk_state = SMC_CLOSED;
+	goto enqueue; /* queue new sock with sk_err set */
+}
+
+static void smc_tcp_listen_work(struct work_struct *work)
+{
+	struct smc_sock *lsmc = container_of(work, struct smc_sock,
+					     tcp_listen_work);
+	struct smc_sock *new_smc;
+	int rc = 0;
+
+	lock_sock(&lsmc->sk);
+	while (lsmc->sk.sk_state == SMC_LISTEN) {
+		rc = smc_clcsock_accept(lsmc, &new_smc);
+		if (rc)
+			goto out;
+		if (!new_smc)
+			continue;
+
+		new_smc->listen_smc = lsmc;
+		new_smc->use_fallback = 0; /* assume rdma capability first */
+		sock_hold(&lsmc->sk); /* sock_put in smc_listen_work */
+		INIT_WORK(&new_smc->smc_listen_work, smc_listen_work);
+		smc_copy_sock_settings_to_smc(new_smc);
+		schedule_work(&new_smc->smc_listen_work);
+	}
+
+out:
+	release_sock(&lsmc->sk);
+	lsmc->sk.sk_data_ready(&lsmc->sk); /* no more listening, wake accept */
+}
+
 static int smc_listen(struct socket *sock, int backlog)
 {
 	struct sock *sk = sock->sk;
@@ -289,6 +650,8 @@ static int smc_listen(struct socket *sock, int backlog)
 	sk->sk_max_ack_backlog = backlog;
 	sk->sk_ack_backlog = 0;
 	sk->sk_state = SMC_LISTEN;
+	INIT_WORK(&smc->tcp_listen_work, smc_tcp_listen_work);
+	schedule_work(&smc->tcp_listen_work);
 
 out:
 	release_sock(sk);
@@ -298,10 +661,11 @@ out:
 static int smc_accept(struct socket *sock, struct socket *new_sock,
 		      int flags)
 {
-	struct smc_sock *new_smc;
-	struct sock *sk = sock->sk;
+	struct sock *sk = sock->sk, *nsk;
+	DECLARE_WAITQUEUE(wait, current);
 	struct smc_sock *lsmc;
-	int rc;
+	long timeo;
+	int rc = 0;
 
 	lsmc = smc_sk(sk);
 	lock_sock(sk);
@@ -311,18 +675,30 @@ static int smc_accept(struct socket *sock, struct socket *new_sock,
 		goto out;
 	}
 
-	rc = smc_clcsock_accept(lsmc, &new_smc);
-	if (rc)
-		goto out;
-	sock_graft(&new_smc->sk, new_sock);
-	new_smc->sk.sk_state = SMC_ACTIVE;
-
-	smc_copy_sock_settings_to_smc(new_smc);
+	/* Wait for an incoming connection */
+	timeo = sock_rcvtimeo(sk, flags & O_NONBLOCK);
+	add_wait_queue_exclusive(sk_sleep(sk), &wait);
+	while (!(nsk = smc_accept_dequeue(sk, new_sock))) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (!timeo) {
+			rc = -EAGAIN;
+			break;
+		}
+		release_sock(sk);
+		timeo = schedule_timeout(timeo);
+		/* wakeup by sk_data_ready in smc_listen_work() */
+		sched_annotate_sleep();
+		lock_sock(sk);
+		if (signal_pending(current)) {
+			rc = sock_intr_errno(timeo);
+			break;
+		}
+	}
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(sk_sleep(sk), &wait);
 
-	/* always use TCP fallback as transport mechanism for now;
-	 * This will change once RDMA transport is implemented
-	 */
-	new_smc->use_fallback = 1;
+	if (!rc)
+		rc = sock_error(nsk);
 
 out:
 	release_sock(sk);
@@ -382,29 +758,61 @@ out:
 	return rc;
 }
 
+static unsigned int smc_accept_poll(struct sock *parent)
+{
+	struct smc_sock *isk;
+	struct sock *sk;
+
+	lock_sock(parent);
+	list_for_each_entry(isk, &smc_sk(parent)->accept_q, accept_q) {
+		sk = (struct sock *)isk;
+
+		if (sk->sk_state == SMC_ACTIVE) {
+			release_sock(parent);
+			return POLLIN | POLLRDNORM;
+		}
+	}
+	release_sock(parent);
+
+	return 0;
+}
+
 static unsigned int smc_poll(struct file *file, struct socket *sock,
 			     poll_table *wait)
 {
 	struct sock *sk = sock->sk;
 	unsigned int mask = 0;
 	struct smc_sock *smc;
+	int rc;
 
 	smc = smc_sk(sock->sk);
-	if ((sk->sk_state == SMC_INIT) || (sk->sk_state == SMC_LISTEN) ||
-	    smc->use_fallback) {
+	if ((sk->sk_state == SMC_INIT) || smc->use_fallback) {
+		/* delegate to CLC child sock */
 		mask = smc->clcsock->ops->poll(file, smc->clcsock, wait);
 		/* if non-blocking connect finished ... */
 		lock_sock(sk);
 		if ((sk->sk_state == SMC_INIT) && (mask & POLLOUT)) {
-			sk->sk_state = SMC_ACTIVE;
-			/* always use TCP fallback as transport mechanism;
-			 * This will change once RDMA transport is implemented
-			 */
-			smc->use_fallback = 1;
+			sk->sk_err = smc->clcsock->sk->sk_err;
+			if (sk->sk_err) {
+				mask |= POLLERR;
+			} else {
+				rc = smc_connect_rdma(smc);
+				if (rc < 0)
+					mask |= POLLERR;
+				else
+					/* success cases including fallback */
+					mask |= POLLOUT | POLLWRNORM;
+			}
 		}
 		release_sock(sk);
 	} else {
-		mask = sock_no_poll(file, sock, wait);
+		sock_poll_wait(file, sk_sleep(sk), wait);
+		if (sk->sk_state == SMC_LISTEN)
+			/* woken up by sk_data_ready in smc_listen_work() */
+			mask |= smc_accept_poll(sk);
+		if (sk->sk_err)
+			mask |= POLLERR;
+		/* for now - to be enhanced in follow-on patch */
 	}
 
 	return mask;
@@ -571,6 +979,7 @@ static int smc_create(struct net *net, struct socket *sock, int protocol,
 
 	/* create internal TCP socket for CLC handshake and fallback */
 	smc = smc_sk(sk);
+	smc->use_fallback = 0; /* assume rdma capability first */
 	rc = sock_create_kern(net, PF_INET, SOCK_STREAM,
 			      IPPROTO_TCP, &smc->clcsock);
 	if (rc)
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 8f5c014..8f8ed98 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -26,7 +26,14 @@ enum smc_state {		/* possible states of an SMC socket */
 struct smc_sock {				/* smc sock container */
 	struct sock		sk;
 	struct socket		*clcsock;	/* internal tcp socket */
-	u8			use_fallback : 1; /* fallback to tcp */
+	struct sockaddr		*addr;		/* inet connect address */
+	struct smc_sock		*listen_smc;	/* listen parent */
+	struct work_struct	tcp_listen_work;/* handle tcp socket accepts */
+	struct work_struct	smc_listen_work;/* prepare new accept socket */
+	struct list_head	accept_q;	/* sockets to be accepted */
+	spinlock_t		accept_q_lock;	/* protects accept_q */
+	u8			use_fallback : 1, /* fallback to tcp */
+				clc_started : 1;/* smc_connect_rdma ran */
 };
 
 static inline struct smc_sock *smc_sk(const struct sock *sk)
@@ -38,4 +45,19 @@ static inline struct smc_sock *smc_sk(const struct sock *sk)
 
 extern u8	local_systemid[SMC_SYSTEMID_LEN]; /* unique system identifier */
 
+#ifdef CONFIG_XFRM
+static inline bool using_ipsec(struct smc_sock *smc)
+{
+	return (smc->clcsock->sk->sk_policy[0] ||
+		smc->clcsock->sk->sk_policy[1]) ? 1 : 0;
+}
+#else
+static inline bool using_ipsec(struct smc_sock *smc)
+{
+	return 0;
+}
+#endif
+
+int smc_netinfo_by_tcpsk(struct socket *, __be32 *, u8 *);
+
 #endif	/* _SMC_H */
diff --git a/net/smc/smc_clc.c b/net/smc/smc_clc.c
new file mode 100644
index 0000000..95c0dc4
--- /dev/null
+++ b/net/smc/smc_clc.c
@@ -0,0 +1,251 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  CLC (connection layer control) handshake over initial TCP socket to
+ *  prepare for RDMA traffic
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#include <net/sock.h>
+#include <net/tcp.h>
+
+#include "smc.h"
+#include "smc_clc.h"
+#include "smc_ib.h"
+
+/* Wait for data on the tcp-socket, analyze received data
+ * Returns:
+ * 0 if success and it was not a decline that we received.
+ * SMC_CLC_DECL_REPLY if decline received for fallback w/o another decl send.
+ * clcsock error, -EINTR, -ECONNRESET, -EPROTO otherwise.
+ */
+int smc_clc_wait_msg(struct smc_sock *smc, void *buf, int buflen,
+		     u8 expected_type)
+{
+	struct sock *clc_sk = smc->clcsock->sk;
+	struct smc_clc_msg_hdr *clcm = buf;
+	struct msghdr msg = {NULL, 0};
+	int reason_code = 0;
+	DEFINE_WAIT(wait);
+	struct kvec vec;
+	int len, datlen;
+	int krflags;
+
+	/* peek the first few bytes to determine length of data to receive
+	 * so we don't consume any subsequent CLC message or payload data
+	 * in the TCP byte stream
+	 */
+	vec.iov_base = buf;
+	vec.iov_len = buflen;
+	krflags = MSG_PEEK | MSG_WAITALL;
+	smc->clcsock->sk->sk_rcvtimeo = CLC_WAIT_TIME;
+	len = kernel_recvmsg(smc->clcsock, &msg, &vec, 1,
+			     sizeof(struct smc_clc_msg_hdr), krflags);
+	if (signal_pending(current)) {
+		reason_code = -EINTR;
+		clc_sk->sk_err = EINTR;
+		smc->sk.sk_err = EINTR;
+		goto out;
+	}
+	if (clc_sk->sk_err) {
+		reason_code = -clc_sk->sk_err;
+		smc->sk.sk_err = clc_sk->sk_err;
+		goto out;
+	}
+	if (!len) { /* peer has performed orderly shutdown */
+		smc->sk.sk_err = ECONNRESET;
+		reason_code = -ECONNRESET;
+		goto out;
+	}
+	if (len < 0) {
+		smc->sk.sk_err = -len;
+		reason_code = len;
+		goto out;
+	}
+	datlen = ntohs(clcm->length);
+	if ((len < sizeof(struct smc_clc_msg_hdr)) ||
+	    (datlen < sizeof(struct smc_clc_msg_decline)) ||
+	    memcmp(clcm->eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER)) ||
+	    ((clcm->type != SMC_CLC_DECLINE) &&
+	     (clcm->type != expected_type))) {
+		smc->sk.sk_err = EPROTO;
+		reason_code = -EPROTO;
+		goto out;
+	}
+
+	/* receive the complete CLC message */
+	vec.iov_base = buf;
+	vec.iov_len = buflen;
+	memset(&msg, 0, sizeof(struct msghdr));
+	krflags = MSG_WAITALL;
+	smc->clcsock->sk->sk_rcvtimeo = CLC_WAIT_TIME;
+	len = kernel_recvmsg(smc->clcsock, &msg, &vec, 1, datlen, krflags);
+	if (len < datlen) {
+		smc->sk.sk_err = EPROTO;
+		reason_code = -EPROTO;
+		goto out;
+	}
+	if (clcm->type == SMC_CLC_DECLINE)
+		reason_code = SMC_CLC_DECL_REPLY;
+out:
+	return reason_code;
+}
+
+/* send CLC DECLINE message across internal TCP socket */
+int smc_clc_send_decline(struct smc_sock *smc, u32 peer_diag_info,
+			 u8 out_of_sync)
+{
+	struct smc_clc_msg_decline dclc;
+	struct msghdr msg;
+	struct kvec vec;
+	int len;
+
+	memset(&dclc, 0, sizeof(dclc));
+	memcpy(dclc.hdr.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
+	dclc.hdr.type = SMC_CLC_DECLINE;
+	dclc.hdr.length = htons(sizeof(struct smc_clc_msg_decline));
+	dclc.hdr.version = SMC_CLC_V1;
+	dclc.hdr.flag = out_of_sync ? 1 : 0;
+	memcpy(dclc.id_for_peer, local_systemid, sizeof(local_systemid));
+	dclc.peer_diagnosis = htonl(peer_diag_info);
+	memcpy(dclc.trl.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
+
+	memset(&msg, 0, sizeof(msg));
+	vec.iov_base = &dclc;
+	vec.iov_len = sizeof(struct smc_clc_msg_decline);
+	len = kernel_sendmsg(smc->clcsock, &msg, &vec, 1,
+			     sizeof(struct smc_clc_msg_decline));
+	if (len < sizeof(struct smc_clc_msg_decline))
+		smc->sk.sk_err = EPROTO;
+	if (len < 0)
+		smc->sk.sk_err = -len;
+	return len;
+}
+
+/* send CLC PROPOSAL message across internal TCP socket */
+int smc_clc_send_proposal(struct smc_sock *smc,
+			  struct smc_ib_device *smcibdev,
+			  u8 ibport)
+{
+	struct smc_clc_msg_proposal pclc;
+	int reason_code = 0;
+	struct msghdr msg;
+	struct kvec vec;
+	int len, rc;
+
+	/* send SMC Proposal CLC message */
+	memset(&pclc, 0, sizeof(pclc));
+	memcpy(pclc.hdr.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
+	pclc.hdr.type = SMC_CLC_PROPOSAL;
+	pclc.hdr.length = htons(sizeof(pclc));
+	pclc.hdr.version = SMC_CLC_V1;		/* SMC version */
+	memcpy(pclc.lcl.id_for_peer, local_systemid, sizeof(local_systemid));
+	memcpy(&pclc.lcl.gid, &smcibdev->gid[ibport - 1], SMC_GID_SIZE);
+	memcpy(&pclc.lcl.mac, &smcibdev->mac[ibport - 1],
+	       sizeof(smcibdev->mac[ibport - 1]));
+
+	/* determine subnet and mask from internal TCP socket */
+	rc = smc_netinfo_by_tcpsk(smc->clcsock, &pclc.outgoing_subnet,
+				  &pclc.prefix_len);
+	if (rc)
+		return SMC_CLC_DECL_CNFERR; /* configuration error */
+	memcpy(&pclc.trl.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
+	memset(&msg, 0, sizeof(msg));
+	vec.iov_base = &pclc;
+	vec.iov_len = sizeof(pclc);
+	/* due to the few bytes needed for clc-handshake this cannot block */
+	len = kernel_sendmsg(smc->clcsock, &msg, &vec, 1, sizeof(pclc));
+	if (len < sizeof(pclc)) {
+		if (len >= 0) {
+			reason_code = -ENETUNREACH;
+			smc->sk.sk_err = -reason_code;
+		} else {
+			smc->sk.sk_err = smc->clcsock->sk->sk_err;
+			reason_code = -smc->sk.sk_err;
+		}
+	}
+
+	return reason_code;
+}
+
+/* send CLC CONFIRM message across internal TCP socket */
+int smc_clc_send_confirm(struct smc_sock *smc)
+{
+	struct smc_clc_msg_accept_confirm cclc;
+	int reason_code = 0;
+	struct msghdr msg;
+	struct kvec vec;
+	int len;
+
+	/* send SMC Confirm CLC msg */
+	memset(&cclc, 0, sizeof(cclc));
+	memcpy(cclc.hdr.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
+	cclc.hdr.type = SMC_CLC_CONFIRM;
+	cclc.hdr.length = htons(sizeof(cclc));
+	cclc.hdr.version = SMC_CLC_V1;		/* SMC version */
+	memcpy(cclc.lcl.id_for_peer, local_systemid, sizeof(local_systemid));
+
+	/* tbd in follow-on patch: fill in link-related values */
+
+	/* tbd in follow-on patch: fill in rmb-related values */
+
+	cclc.conn_idx = 1; /* for now: 1 RMB = 1 RMBE */
+
+	memcpy(cclc.trl.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
+
+	memset(&msg, 0, sizeof(msg));
+	vec.iov_base = &cclc;
+	vec.iov_len = sizeof(cclc);
+	len = kernel_sendmsg(smc->clcsock, &msg, &vec, 1, sizeof(cclc));
+	if (len < sizeof(cclc)) {
+		if (len >= 0) {
+			reason_code = -ENETUNREACH;
+			smc->sk.sk_err = -reason_code;
+		} else {
+			smc->sk.sk_err = smc->clcsock->sk->sk_err;
+			reason_code = -smc->sk.sk_err;
+		}
+	}
+	return reason_code;
+}
+
+/* send CLC ACCEPT message across internal TCP socket */
+int smc_clc_send_accept(struct smc_sock *new_smc)
+{
+	struct smc_clc_msg_accept_confirm aclc;
+	struct msghdr msg;
+	struct kvec vec;
+	int rc = 0;
+	int len;
+
+	memset(&aclc, 0, sizeof(aclc));
+	memcpy(aclc.hdr.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
+	aclc.hdr.type = SMC_CLC_ACCEPT;
+	aclc.hdr.length = htons(sizeof(aclc));
+	aclc.hdr.version = SMC_CLC_V1;		/* SMC version */
+	memcpy(aclc.lcl.id_for_peer, local_systemid, sizeof(local_systemid));
+
+	/* tbd in follow-on patch: fill in link-related values */
+
+	/* tbd in follow-on patch: fill in rmb-related values */
+
+	aclc.conn_idx = 1;			/* as long as 1 RMB = 1 RMBE */
+	memcpy(aclc.trl.eyecatcher, SMC_EYECATCHER, sizeof(SMC_EYECATCHER));
+
+	memset(&msg, 0, sizeof(msg));
+	vec.iov_base = &aclc;
+	vec.iov_len = sizeof(aclc);
+	len = kernel_sendmsg(new_smc->clcsock, &msg, &vec, 1, sizeof(aclc));
+	if (len < sizeof(aclc)) {
+		if (len >= 0)
+			new_smc->sk.sk_err = EPROTO;
+		else
+			new_smc->sk.sk_err = new_smc->clcsock->sk->sk_err;
+		rc = sock_error(&new_smc->sk);
+	}
+
+	return rc;
+}
diff --git a/net/smc/smc_clc.h b/net/smc/smc_clc.h
new file mode 100644
index 0000000..565c62a
--- /dev/null
+++ b/net/smc/smc_clc.h
@@ -0,0 +1,111 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  CLC (connection layer control) handshake over initial TCP socket to
+ *  prepare for RDMA traffic
+ *
+ *  Copyright IBM Corp. 2016
+ *
+ *  Author(s):  Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#ifndef _SMC_CLC_H
+#define _SMC_CLC_H
+
+#include <rdma/ib_verbs.h>
+
+#include "smc.h"
+
+#define SMC_CLC_PROPOSAL	0x01
+#define SMC_CLC_ACCEPT		0x02
+#define SMC_CLC_CONFIRM		0x03
+#define SMC_CLC_DECLINE		0x04
+
+/* eye catcher "SMCR" EBCDIC for CLC messages */
+static const char SMC_EYECATCHER[4] = {'\xe2', '\xd4', '\xc3', '\xd9'};
+
+#define SMC_CLC_V1		0x1		/* SMC version                */
+#define CLC_WAIT_TIME		(6 * HZ)	/* max. wait time on clcsock  */
+#define SMC_CLC_DECL_MEM	0x01010000  /* insufficient memory resources  */
+#define SMC_CLC_DECL_TIMEOUT	0x02000000  /* timeout                        */
+#define SMC_CLC_DECL_CNFERR	0x03000000  /* configuration error            */
+#define SMC_CLC_DECL_IPSEC	0x03030000  /* IPsec usage                    */
+#define SMC_CLC_DECL_SYNCERR	0x04000000  /* synchronization error          */
+#define SMC_CLC_DECL_REPLY	0x06000000  /* reply to a received decline    */
+#define SMC_CLC_DECL_INTERR	0x99990000  /* internal error                 */
+
+struct smc_clc_msg_hdr {	/* header1 of clc messages */
+	u8 eyecatcher[4];	/* eye catcher */
+	u8 type;		/* proposal / accept / confirm / decline */
+	__be16 length;
+#if defined(__BIG_ENDIAN_BITFIELD)
+	u8 version : 4,
+	   flag    : 1,
+	   rsvd	   : 3;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	u8 rsvd    : 3,
+	   flag    : 1,
+	   version : 4;
+#endif
+} __packed;
+
+struct smc_clc_msg_trail {	/* trailer of clc messages */
+	u8 eyecatcher[4];
+} __packed;
+
+struct smc_clc_msg_local {	/* header2 of clc messages */
+	u8 id_for_peer[SMC_SYSTEMID_LEN]; /* unique system id */
+	union ib_gid gid;	/* gid of ib_device port */
+	u8 mac[6];		/* mac of ib_device port */
+} __packed;
+
+struct smc_clc_msg_proposal {	/* clc proposal message */
+	struct smc_clc_msg_hdr hdr;
+	struct smc_clc_msg_local lcl;
+	__be16 iparea_offset;	/* offset to IP address information area */
+	__be32 outgoing_subnet;	/* subnet mask */
+	u8 prefix_len;		/* number of significant bits in mask */
+	u8 reserved[2];
+	u8 ipv6_prefixes_cnt;	/* number of IPv6 prefixes in prefix array */
+	struct smc_clc_msg_trail trl; /* eye catcher "SMCR" EBCDIC */
+} __packed;
+
+struct smc_clc_msg_accept_confirm {	/* clc accept / confirm message */
+	struct smc_clc_msg_hdr hdr;
+	struct smc_clc_msg_local lcl;
+	u8 qpn[3];		/* QP number */
+	__be32 rmb_rkey;	/* RMB rkey */
+	u8 conn_idx;		/* Connection index, which RMBE in RMB */
+	__be32 rmbe_alert_token;/* unique connection id */
+#if defined(__BIG_ENDIAN_BITFIELD)
+	u8 rmbe_size : 4,	/* RMBE buf size (compressed notation) */
+	   qp_mtu   : 4;	/* QP mtu */
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	u8 qp_mtu   : 4,
+	   rmbe_size : 4;
+#endif
+	u8 reserved;
+	__be64 rmb_dma_addr;	/* RMB virtual address */
+	u8 reserved2;
+	u8 psn[3];		/* initial packet sequence number */
+	struct smc_clc_msg_trail trl; /* eye catcher "SMCR" EBCDIC */
+} __packed;
+
+struct smc_clc_msg_decline {	/* clc decline message */
+	struct smc_clc_msg_hdr hdr;
+	u8 id_for_peer[SMC_SYSTEMID_LEN]; /* sender peer_id */
+	__be32 peer_diagnosis;	/* diagnosis information */
+	u8 reserved2[4];
+	struct smc_clc_msg_trail trl; /* eye catcher "SMCR" EBCDIC */
+} __packed;
+
+struct smc_sock;
+struct smc_ib_device;
+
+int smc_clc_wait_msg(struct smc_sock *, void *, int, u8);
+int smc_clc_send_decline(struct smc_sock *, u32, u8);
+int smc_clc_send_proposal(struct smc_sock *, struct smc_ib_device *, u8);
+int smc_clc_send_confirm(struct smc_sock *);
+int smc_clc_send_accept(struct smc_sock *);
+
+#endif
-- 
2.6.6
