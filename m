From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/1] net/smc: add SMC rendezvous protocol
Date: Tue, 10 Oct 2017 16:14:19 +0200
Message-ID: <20171010141419.88190-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        hwippel@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:48446 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932117AbdJJOOs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 10:14:48 -0400
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9AEEkZQ008334
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:14:48 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dgy2ftx78-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 10:14:47 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Tue, 10 Oct 2017 15:14:24 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ubraun@linux.vnet.ibm.com>

The SMC protocol [1] uses a rendezvous protocol to negotiate SMC
capability between peers. The current Linux implementation does not use
this rendezvous protocol and, thus, is not compliant to RFC7609 and
incompatible with other SMC implementations like in zOS. This patch adds
support for the SMC rendezvous protocol.

Details:

The SMC rendezvous protocol relies on the use of a new TCP experimental
option. With this option, SMC capabilities are exchanged between the
peers during the TCP three way handshake.

The goal of this patch is to leave common TCP code unmodified. Thus,
it uses netfilter hooks to intercept TCP SYN and SYN/ACK packets. For
outgoing packets originating from SMC sockets, the experimental option
is added. For inbound packets destined for SMC sockets, the experimental
option is checked.

Another goal was to minimize the performance impact on non-SMC traffic
(when SMC is enabled). The netfilter hooks used for SMC client
connections are active only during TCP connection establishment.
The netfilter hooks used for SMC servers are active as long as there are
listening SMC sockets.

When the hooks are active, the following additional operations are
performed on incoming and outgoing packets:
  (1) call SMC netfilter hook (all IPv4 packets)
  (2) check if TCP SYN or SYN/ACK packet (all IPv4 packets)
  (3) check if packet goes to/comes from SMC socket (SYN & SYN/ACK
      packets only)
  (4) check/add SMC experimental option (SMC sockets' SYN & SYN/ACK
      packets only)

References:
  [1] SMC-R Informational RFC: http://www.rfc-editor.org/info/rfc7609

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Kconfig  |   2 +-
 net/smc/Makefile |   2 +-
 net/smc/af_smc.c |  66 ++++++-
 net/smc/smc.h    |  10 +-
 net/smc/smc_rv.c | 543 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_rv.h |  31 ++++
 6 files changed, 646 insertions(+), 8 deletions(-)
 create mode 100644 net/smc/smc_rv.c
 create mode 100644 net/smc/smc_rv.h

diff --git a/net/smc/Kconfig b/net/smc/Kconfig
index c717ef0896aa..ad49086e8ed7 100644
--- a/net/smc/Kconfig
+++ b/net/smc/Kconfig
@@ -1,6 +1,6 @@
 config SMC
 	tristate "SMC socket protocol family"
-	depends on INET && INFINIBAND
+	depends on INET && INFINIBAND && NETFILTER
 	---help---
 	  SMC-R provides a "sockets over RDMA" solution making use of
 	  RDMA over Converged Ethernet (RoCE) technology to upgrade
diff --git a/net/smc/Makefile b/net/smc/Makefile
index 188104654b54..2155a7eff41d 100644
--- a/net/smc/Makefile
+++ b/net/smc/Makefile
@@ -1,4 +1,4 @@
 obj-$(CONFIG_SMC)	+= smc.o
 obj-$(CONFIG_SMC_DIAG)	+= smc_diag.o
 smc-y := af_smc.o smc_pnet.o smc_ib.o smc_clc.o smc_core.o smc_wr.o smc_llc.o
-smc-y += smc_cdc.o smc_tx.o smc_rx.o smc_close.o
+smc-y += smc_cdc.o smc_tx.o smc_rx.o smc_close.o smc_rv.o
diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 745f145d4c4d..290b9ff06e01 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -34,6 +34,7 @@
 #include <net/smc.h>
 
 #include "smc.h"
+#include "smc_rv.h"
 #include "smc_clc.h"
 #include "smc_llc.h"
 #include "smc_cdc.h"
@@ -109,6 +110,7 @@ static int smc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct smc_sock *smc;
+	int old_state;
 	int rc = 0;
 
 	if (!sk)
@@ -123,6 +125,7 @@ static int smc_release(struct socket *sock)
 		lock_sock_nested(sk, SINGLE_DEPTH_NESTING);
 	else
 		lock_sock(sk);
+	old_state = sk->sk_state;
 
 	if (smc->use_fallback) {
 		sk->sk_state = SMC_CLOSED;
@@ -132,6 +135,10 @@ static int smc_release(struct socket *sock)
 		sock_set_flag(sk, SOCK_DEAD);
 		sk->sk_shutdown |= SHUTDOWN_MASK;
 	}
+	if (old_state == SMC_LISTEN) {
+		smc_rv_nf_unregister_hook(sock_net(sk), &smc_nfho_serv);
+		kfree(smc->listen_pends);
+	}
 	if (smc->clcsock) {
 		sock_release(smc->clcsock);
 		smc->clcsock = NULL;
@@ -178,6 +185,7 @@ static struct sock *smc_sock_alloc(struct net *net, struct socket *sock)
 	sk->sk_destruct = smc_destruct;
 	sk->sk_protocol = SMCPROTO_SMC;
 	smc = smc_sk(sk);
+	smc->use_fallback = true; /* default: not SMC-capable */
 	INIT_WORK(&smc->tcp_listen_work, smc_tcp_listen_work);
 	INIT_LIST_HEAD(&smc->accept_q);
 	spin_lock_init(&smc->accept_q_lock);
@@ -390,6 +398,10 @@ static int smc_connect_rdma(struct smc_sock *smc)
 	int rc = 0;
 	u8 ibport;
 
+	if (smc->use_fallback)
+		/* peer has not signalled SMC-capability */
+		goto out_connected;
+
 	/* IPSec connections opt out of SMC-R optimizations */
 	if (using_ipsec(smc)) {
 		reason_code = SMC_CLC_DECL_IPSEC;
@@ -500,7 +512,6 @@ static int smc_connect_rdma(struct smc_sock *smc)
 	smc_tx_init(smc);
 
 out_connected:
-	smc_copy_sock_settings_to_clc(smc);
 	if (smc->sk.sk_state == SMC_INIT)
 		smc->sk.sk_state = SMC_ACTIVE;
 
@@ -555,7 +566,11 @@ static int smc_connect(struct socket *sock, struct sockaddr *addr,
 	}
 
 	smc_copy_sock_settings_to_clc(smc);
+	smc_rv_nf_register_hook(sock_net(sk), &smc_nfho_clnt);
+
 	rc = kernel_connect(smc->clcsock, addr, alen, flags);
+	if (rc != -EINPROGRESS)
+		smc_rv_nf_unregister_hook(sock_net(sk), &smc_nfho_clnt);
 	if (rc)
 		goto out;
 
@@ -574,10 +589,12 @@ static int smc_connect(struct socket *sock, struct sockaddr *addr,
 
 static int smc_clcsock_accept(struct smc_sock *lsmc, struct smc_sock **new_smc)
 {
+	struct smc_listen_pending *pnd;
 	struct sock *sk = &lsmc->sk;
 	struct socket *new_clcsock;
 	struct sock *new_sk;
-	int rc;
+	unsigned long flags;
+	int i, rc;
 
 	release_sock(&lsmc->sk);
 	new_sk = smc_sock_alloc(sock_net(sk), NULL);
@@ -613,6 +630,25 @@ static int smc_clcsock_accept(struct smc_sock *lsmc, struct smc_sock **new_smc)
 	}
 
 	(*new_smc)->clcsock = new_clcsock;
+
+	/* enable SMC-capability if an SMC-capable connecting socket is
+	 * contained in listen_pends; invalidate this entry
+	 */
+	spin_lock_irqsave(&lsmc->listen_pends_lock, flags);
+	for (i = 0; i < 2 * lsmc->sk.sk_max_ack_backlog; i++) {
+		pnd = lsmc->listen_pends + i;
+		if (pnd->used &&
+		    pnd->addr == new_clcsock->sk->sk_daddr &&
+		    pnd->port == new_clcsock->sk->sk_dport &&
+		    jiffies_to_msecs(get_jiffies_64() - pnd->time) <=
+						SMC_LISTEN_PEND_VALID_TIME) {
+			(*new_smc)->use_fallback = false;
+			pnd->used = false;
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&lsmc->listen_pends_lock, flags);
+
 out:
 	return rc;
 }
@@ -759,6 +795,10 @@ static void smc_listen_work(struct work_struct *work)
 	u8 prefix_len;
 	u8 ibport;
 
+	if (new_smc->use_fallback)
+		/* peer has not signalled SMC-capability */
+		goto out_connected;
+
 	/* do inband token exchange -
 	 *wait for and receive SMC Proposal CLC message
 	 */
@@ -929,7 +969,6 @@ static void smc_tcp_listen_work(struct work_struct *work)
 			continue;
 
 		new_smc->listen_smc = lsmc;
-		new_smc->use_fallback = false; /* assume rdma capability first*/
 		sock_hold(&lsmc->sk); /* sock_put in smc_listen_work */
 		INIT_WORK(&new_smc->smc_listen_work, smc_listen_work);
 		smc_copy_sock_settings_to_smc(new_smc);
@@ -954,16 +993,32 @@ static int smc_listen(struct socket *sock, int backlog)
 	if ((sk->sk_state != SMC_INIT) && (sk->sk_state != SMC_LISTEN))
 		goto out;
 
+	rc = -ENOMEM;
+	/* Addresses and ports of incoming SYN packets with experimental option
+	 * SMC are saved, but TCP might decide to drop them. Thus more slots
+	 * than the backlog value are allocated for pending connecting sockets
+	 */
+	smc->listen_pends = kzalloc(
+			2 * backlog * sizeof(struct smc_listen_pending),
+			GFP_KERNEL);
+	if (!smc->listen_pends)
+		goto out;
+	spin_lock_init(&smc->listen_pends_lock);
+
 	rc = 0;
 	if (sk->sk_state == SMC_LISTEN) {
 		sk->sk_max_ack_backlog = backlog;
 		goto out;
 	}
+
+	smc->use_fallback = false; /* listen sockets are SMC-capable */
 	/* some socket options are handled in core, so we could not apply
 	 * them to the clc socket -- copy smc socket options to clc socket
 	 */
 	smc_copy_sock_settings_to_clc(smc);
 
+	smc_rv_nf_register_hook(sock_net(sk), &smc_nfho_serv);
+
 	rc = kernel_listen(smc->clcsock, backlog);
 	if (rc)
 		goto out;
@@ -1114,7 +1169,7 @@ static unsigned int smc_poll(struct file *file, struct socket *sock,
 	struct sock *sk = sock->sk;
 	unsigned int mask = 0;
 	struct smc_sock *smc;
-	int rc;
+	int rc = 0;
 
 	smc = smc_sk(sock->sk);
 	if ((sk->sk_state == SMC_INIT) || smc->use_fallback) {
@@ -1123,6 +1178,7 @@ static unsigned int smc_poll(struct file *file, struct socket *sock,
 		/* if non-blocking connect finished ... */
 		lock_sock(sk);
 		if ((sk->sk_state == SMC_INIT) && (mask & POLLOUT)) {
+			smc_rv_nf_unregister_hook(sock_net(sk), &smc_nfho_clnt);
 			sk->sk_err = smc->clcsock->sk->sk_err;
 			if (sk->sk_err) {
 				mask |= POLLERR;
@@ -1348,7 +1404,6 @@ static int smc_create(struct net *net, struct socket *sock, int protocol,
 
 	/* create internal TCP socket for CLC handshake and fallback */
 	smc = smc_sk(sk);
-	smc->use_fallback = false; /* assume rdma capability first */
 	rc = sock_create_kern(net, PF_INET, SOCK_STREAM,
 			      IPPROTO_TCP, &smc->clcsock);
 	if (rc)
@@ -1370,6 +1425,7 @@ static int __init smc_init(void)
 {
 	int rc;
 
+	smc_rv_init();
 	rc = smc_pnet_init();
 	if (rc)
 		return rc;
diff --git a/net/smc/smc.h b/net/smc/smc.h
index 0ccd6fa387ad..96d7a20ba7db 100644
--- a/net/smc/smc.h
+++ b/net/smc/smc.h
@@ -167,6 +167,13 @@ struct smc_connection {
 	struct work_struct	close_work;	/* peer sent some closing */
 };
 
+struct smc_listen_pending {
+	u64		time;			/* time when entry was created*/
+	bool		used;			/* true if entry is in use */
+	__be32		addr;			/* address of a listen socket */
+	__be16		port;			/* port of a listen socket */
+};
+
 struct smc_sock {				/* smc sock container */
 	struct sock		sk;
 	struct socket		*clcsock;	/* internal tcp socket */
@@ -175,6 +182,8 @@ struct smc_sock {				/* smc sock container */
 	struct smc_sock		*listen_smc;	/* listen parent */
 	struct work_struct	tcp_listen_work;/* handle tcp socket accepts */
 	struct work_struct	smc_listen_work;/* prepare new accept socket */
+	struct smc_listen_pending *listen_pends;/* listen pending SYNs */
+	spinlock_t		listen_pends_lock; /* protects listen_pends */
 	struct list_head	accept_q;	/* sockets to be accepted */
 	spinlock_t		accept_q_lock;	/* protects accept_q */
 	struct delayed_work	sock_put_work;	/* final socket freeing */
@@ -271,5 +280,4 @@ int smc_conn_create(struct smc_sock *smc, __be32 peer_in_addr,
 		    struct smc_clc_msg_local *lcl, int srv_first_contact);
 struct sock *smc_accept_dequeue(struct sock *parent, struct socket *new_sock);
 void smc_close_non_accepted(struct sock *sk);
-
 #endif	/* __SMC_H */
diff --git a/net/smc/smc_rv.c b/net/smc/smc_rv.c
new file mode 100644
index 000000000000..4ce01dec808f
--- /dev/null
+++ b/net/smc/smc_rv.c
@@ -0,0 +1,543 @@
+/*
+ *  Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  SMC Rendezvous to determine SMC-capability of the peer
+ *
+ *  Copyright IBM Corp. 2017
+ *
+ *  Author(s):	Hans Wippel <hwippel@linux.vnet.ibm.com>
+ *		Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <net/tcp.h>
+
+#include "smc.h"
+#include "smc_rv.h"
+
+#define TCPOLEN_SMC			8
+#define TCPOLEN_SMC_BASE		6
+#define TCPOLEN_SMC_ALIGNED		2
+
+static const char TCPOPT_SMC_MAGIC[4] = {'\xe2', '\xd4', '\xc3', '\xd9'};
+
+/* in TCP header, replace EOL option and remaining header bytes with NOPs */
+static bool smc_rv_replace_eol_option(struct sk_buff *skb)
+{
+	struct tcphdr *tcph = tcp_hdr(skb);
+	int opt_bytes = tcp_optlen(skb);
+	unsigned char *buf;
+	int i = 0;
+
+	buf = (unsigned char *)(tcph + 1);
+	/* Parse TCP options. Based on tcp_parse_options in tcp_input.c */
+	while (i < opt_bytes) {
+		switch (buf[i]) {
+		/* one byte options */
+		case TCPOPT_EOL:
+			/* replace remaining bytes with NOPs */
+			while (i < opt_bytes) {
+				buf[i] = TCPOPT_NOP;
+				i++;
+			}
+			return true;
+		case TCPOPT_NOP:
+			i++;
+			continue;
+		default:
+			/* multi-byte options */
+			if (buf[i + 1] < 2 || i + buf[i + 1] > opt_bytes)
+				return false; /* bad option */
+			i += buf[i + 1];
+			continue;
+		}
+	}
+	return true;
+}
+
+/* check if TCP header contains SMC option */
+static bool smc_rv_has_smc_option(struct sk_buff *skb)
+{
+	struct tcphdr *tcph = tcp_hdr(skb);
+	int opt_bytes = tcp_optlen(skb);
+	unsigned char *buf;
+	int i = 0;
+
+	buf = (unsigned char *)(tcph + 1);
+	/* Parse TCP options. Based on tcp_parse_options in tcp_input.c */
+	while (i < opt_bytes) {
+		switch (buf[i]) {
+		/* one byte options */
+		case TCPOPT_EOL:
+			return false;
+		case TCPOPT_NOP:
+			i++;
+			continue;
+		default:
+			/* multi-byte options */
+			if (buf[i + 1] < 2)
+				return false; /* bad option */
+			/* check for SMC rendezvous option */
+			if (buf[i] == TCPOPT_EXP &&
+			    buf[i + 1] == TCPOLEN_SMC_BASE &&
+			    (opt_bytes - i >= TCPOLEN_SMC_BASE) &&
+			    !memcmp(&buf[i + 2], TCPOPT_SMC_MAGIC,
+						sizeof(TCPOPT_SMC_MAGIC)))
+				return true;
+			i += buf[i + 1];
+			continue;
+		}
+	}
+
+	return false;
+}
+
+/* Add SMC option to TCP header */
+static int smc_rv_add_smc_option(struct sk_buff *skb)
+{
+	unsigned char smc_opt[] = {TCPOPT_NOP, TCPOPT_NOP,
+				   TCPOPT_EXP, TCPOLEN_SMC_BASE,
+				   TCPOPT_SMC_MAGIC[0], TCPOPT_SMC_MAGIC[1],
+				   TCPOPT_SMC_MAGIC[2], TCPOPT_SMC_MAGIC[3]};
+	struct tcphdr *tcph = tcp_hdr(skb);
+	struct iphdr *iph = ip_hdr(skb);
+	int tcplen = 0;
+
+	if (skb_availroom(skb) < TCPOLEN_SMC)
+		return -EFAULT;
+
+	if (tcp_optlen(skb) + TCPOLEN_SMC > MAX_TCP_OPTION_SPACE)
+		return -EFAULT;
+
+	/* give up if there is data after the TCP header */
+	if (skb_headlen(skb) > ip_hdrlen(skb) + tcp_hdrlen(skb))
+		return -EFAULT;
+
+	if (smc_rv_has_smc_option(skb))
+		return -EFAULT;
+
+	if (!smc_rv_replace_eol_option(skb))
+		return -EFAULT;
+
+	iph->tot_len = cpu_to_be16(be16_to_cpu(iph->tot_len) + TCPOLEN_SMC);
+	iph->check = 0;
+	iph->check = ip_fast_csum(iph, iph->ihl);
+	skb_put_data(skb, smc_opt, TCPOLEN_SMC);
+	tcph->doff += TCPOLEN_SMC_ALIGNED;
+	tcplen = (skb->len - ip_hdrlen(skb));
+	tcph->check = 0;
+	tcph->check = tcp_v4_check(tcplen, iph->saddr, iph->daddr,
+				   csum_partial(tcph, tcplen, 0));
+	skb->ip_summed = CHECKSUM_NONE;
+	return 0;
+}
+
+/* return an smc socket with certain source and destination */
+static struct smc_sock *smc_rv_lookup_connecting_smc(struct net *net,
+						     __be32 dest_addr,
+						     __be16 dest_port,
+						     __be32 source_addr,
+						     __be16 source_port)
+{
+	struct smc_sock *smc = NULL;
+	struct hlist_head *head;
+	struct socket *clcsock;
+	struct sock *sk;
+
+	read_lock(&smc_proto.h.smc_hash->lock);
+	head = &smc_proto.h.smc_hash->ht;
+
+	if (hlist_empty(head))
+		goto out;
+
+	sk_for_each(sk, head) {
+		if (!net_eq(sock_net(sk), net))
+			continue;
+		if (sk->sk_state != SMC_INIT)
+			continue;
+		clcsock = smc_sk(sk)->clcsock;
+		if (!clcsock)
+			continue;
+		if (source_port != htons(clcsock->sk->sk_num))
+			continue;
+		if (source_addr != clcsock->sk->sk_rcv_saddr)
+			continue;
+		if (dest_port != clcsock->sk->sk_dport)
+			continue;
+		if (dest_addr == clcsock->sk->sk_daddr) {
+			smc = smc_sk(sk);
+			break;
+		}
+	}
+
+out:
+	read_unlock(&smc_proto.h.smc_hash->lock);
+	return smc;
+}
+
+/* for netfilter smc_rv_hook_out_clnt (outgoing SYN):
+ * check if there exists a connecting smc socket with certain source and
+ * destination
+ */
+static bool smc_rv_exists_connecting_smc(struct net *net,
+					 __be32 dest_addr,
+					 __be16 dest_port,
+					 __be32 source_addr,
+					 __be16 source_port)
+{
+	return (smc_rv_lookup_connecting_smc(net, dest_addr, dest_port,
+					     source_addr, source_port) ?
+								true : false);
+}
+
+/* for netfilter smc_rv_hook_in_clnt (incoming SYN ACK):
+ * enable SMC-capability for the corresponding socket
+ */
+static void smc_rv_accepting_smc_peer(struct net *net,
+				      __be32 dest_addr,
+				      __be16 dest_port,
+				      __be32 source_addr,
+				      __be16 source_port)
+{
+	struct smc_sock *smc;
+
+	smc = smc_rv_lookup_connecting_smc(net, dest_addr, dest_port,
+					   source_addr, source_port);
+	if (smc)
+		/* connection is SMC-capable */
+		smc->use_fallback = false;
+}
+
+/* return an smc socket listening on a certain port */
+static struct smc_sock *smc_rv_lookup_listen_socket(struct net *net,
+						    __be32 listen_addr,
+						    __be16 listen_port)
+{
+	struct smc_sock *smc = NULL;
+	struct hlist_head *head;
+	struct socket *clcsock;
+	struct sock *sk;
+
+	read_lock(&smc_proto.h.smc_hash->lock);
+	head = &smc_proto.h.smc_hash->ht;
+
+	if (hlist_empty(head))
+		goto out;
+
+	sk_for_each(sk, head) {
+		if (!net_eq(sock_net(sk), net))
+			continue;
+		if (sk->sk_state != SMC_LISTEN)
+			continue;
+		clcsock = smc_sk(sk)->clcsock;
+		if (listen_port != htons(clcsock->sk->sk_num))
+			continue;
+		if (!listen_addr || !clcsock->sk->sk_rcv_saddr ||
+		    listen_addr == clcsock->sk->sk_rcv_saddr) {
+			smc = smc_sk(sk);
+			break;
+		}
+	}
+
+out:
+	read_unlock(&smc_proto.h.smc_hash->lock);
+	return smc;
+}
+
+/* for netfilter smc_rv_hook_in_serv (incoming SYN):
+ * save addr and port of connecting smc peer
+ */
+static void smc_rv_connecting_smc_peer(struct net *net,
+				       __be32 listen_addr,
+				       __be16 listen_port,
+				       __be32 peer_addr,
+				       __be16 peer_port)
+{
+	struct smc_listen_pending *pnd;
+	struct smc_sock *lsmc;
+	unsigned long flags;
+	int i;
+
+	lsmc = smc_rv_lookup_listen_socket(net, listen_addr, listen_port);
+	if (!lsmc)
+		return;
+
+	spin_lock_irqsave(&lsmc->listen_pends_lock, flags);
+	for (i = 0; i < 2 * lsmc->sk.sk_max_ack_backlog; i++) {
+		pnd = lsmc->listen_pends + i;
+		/* either use an unused entry or reuse an outdated entry */
+		if (!pnd->used ||
+		    jiffies_to_msecs(get_jiffies_64() - pnd->time) >
+						SMC_LISTEN_PEND_VALID_TIME) {
+			pnd->used = true;
+			pnd->addr = peer_addr;
+			pnd->port = peer_port;
+			pnd->time = get_jiffies_64();
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&lsmc->listen_pends_lock, flags);
+}
+
+/* for netfilter smc_rv_hook_out_serv (outgoing SYN/ACK):
+ * remove listen_pends entry of connecting smc peer in case of a problem
+ */
+static void smc_rv_remove_smc_peer(struct net *net,
+				   __be32 listen_addr,
+				   __be16 listen_port,
+				   __be32 peer_addr,
+				   __be16 peer_port)
+{
+	struct smc_listen_pending *pnd;
+	struct smc_sock *lsmc;
+	unsigned long flags;
+	int i;
+
+	lsmc = smc_rv_lookup_listen_socket(net, listen_addr, listen_port);
+	if (!lsmc)
+		return;
+
+	spin_lock_irqsave(&lsmc->listen_pends_lock, flags);
+	for (i = 0; i < 2 * lsmc->sk.sk_max_ack_backlog; i++) {
+		pnd = lsmc->listen_pends + i;
+		if (pnd->used &&
+		    pnd->addr == peer_addr &&
+		    pnd->port == peer_port &&
+		    jiffies_to_msecs(get_jiffies_64() - pnd->time) <=
+						SMC_LISTEN_PEND_VALID_TIME) {
+			pnd->used = false;
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&lsmc->listen_pends_lock, flags);
+}
+
+/* for netfilter smc_rv_hook_out_serv (outgoing SYN ACK):
+ * check if there has been a connecting smc peer
+ */
+static bool smc_rv_exists_connecting_smc_peer(struct net *net,
+					      __be32 listen_addr,
+					      __be16 listen_port,
+					      __be32 peer_addr,
+					      __be16 peer_port)
+{
+	struct smc_listen_pending *pnd;
+	struct smc_sock *lsmc;
+	unsigned long flags;
+	int i;
+
+	lsmc = smc_rv_lookup_listen_socket(net, listen_addr, listen_port);
+	if (!lsmc)
+		return false;
+
+	spin_lock_irqsave(&lsmc->listen_pends_lock, flags);
+	for (i = 0; i < 2 * lsmc->sk.sk_max_ack_backlog; i++) {
+		pnd = lsmc->listen_pends + i;
+		if (pnd->used &&
+		    pnd->addr == peer_addr &&
+		    pnd->port == peer_port &&
+		    jiffies_to_msecs(get_jiffies_64() - pnd->time) <=
+						SMC_LISTEN_PEND_VALID_TIME) {
+			spin_unlock_irqrestore(&lsmc->listen_pends_lock, flags);
+			return true;
+		}
+	}
+	spin_unlock_irqrestore(&lsmc->listen_pends_lock, flags);
+	return false;
+}
+
+/* Netfilter hooks */
+
+/* netfilter hook for incoming packets (client) */
+static unsigned int smc_rv_hook_in_clnt(void *priv, struct sk_buff *skb,
+					const struct nf_hook_state *state)
+{
+	struct tcphdr *tcph = tcp_hdr(skb);
+	struct iphdr *iph;
+
+	if (skb_headlen(skb) - sizeof(*iph) < sizeof(*tcph))
+		return NF_ACCEPT;
+
+	iph = ip_hdr(skb);
+	if (iph->protocol != IPPROTO_TCP)
+		return NF_ACCEPT;
+
+	/* Local SMC client, incoming SYN,ACK from server
+	 * check if there really is a local SMC client
+	 * and tell the client connection if the server is SMC capable
+	 */
+	if (tcph->syn == 1 && tcph->ack == 1) {
+		/* check for experimental option */
+		if (!smc_rv_has_smc_option(skb))
+			return NF_ACCEPT;
+		/* add info about server SMC capability */
+		smc_rv_accepting_smc_peer(state->net, iph->saddr, tcph->source,
+					  iph->daddr, tcph->dest);
+	}
+	return NF_ACCEPT;
+}
+
+/* netfilter hook for incoming packets (server) */
+static unsigned int smc_rv_hook_in_serv(void *priv, struct sk_buff *skb,
+					const struct nf_hook_state *state)
+{
+	struct tcphdr *tcph = tcp_hdr(skb);
+	struct iphdr *iph;
+
+	if (skb_headlen(skb) - sizeof(*iph) < sizeof(*tcph))
+		return NF_ACCEPT;
+
+	iph = ip_hdr(skb);
+	if (iph->protocol != IPPROTO_TCP)
+		return NF_ACCEPT;
+
+	/* Local SMC Server, incoming SYN request from client
+	 * check if there is a local SMC server
+	 * and tell the server if there is a new SMC capable client
+	 */
+	if (tcph->syn == 1 && tcph->ack == 0) {
+		/* check for experimental option */
+		if (!smc_rv_has_smc_option(skb))
+			return NF_ACCEPT;
+		/* add info about new client SMC capability */
+		smc_rv_connecting_smc_peer(state->net, iph->daddr, tcph->dest,
+					   iph->saddr, tcph->source);
+	}
+	return NF_ACCEPT;
+}
+
+/* netfilter hook for outgoing packets (client) */
+static unsigned int smc_rv_hook_out_clnt(void *priv, struct sk_buff *skb,
+					 const struct nf_hook_state *state)
+{
+	struct tcphdr *tcph = tcp_hdr(skb);
+	struct iphdr *iph;
+
+	if (skb_headlen(skb) - sizeof(*iph) < sizeof(*tcph))
+		return NF_ACCEPT;
+
+	iph = ip_hdr(skb);
+	if (iph->protocol != IPPROTO_TCP)
+		return NF_ACCEPT;
+
+	/* Local SMC client, outgoing SYN request to server
+	 * add TCP experimental option if there really is a local SMC client
+	 */
+	if (tcph->syn == 1 && tcph->ack == 0) {
+		/* check for local SMC client */
+		if (!smc_rv_exists_connecting_smc(state->net,
+						  iph->daddr, tcph->dest,
+						  iph->saddr, tcph->source))
+			return NF_ACCEPT;
+		/* add experimental option */
+		smc_rv_add_smc_option(skb);
+	}
+	return NF_ACCEPT;
+}
+
+/* netfilter hook for outgoing packets (server) */
+static unsigned int smc_rv_hook_out_serv(void *priv, struct sk_buff *skb,
+					 const struct nf_hook_state *state)
+{
+	struct tcphdr *tcph = tcp_hdr(skb);
+	struct iphdr *iph;
+
+	if (skb_headlen(skb) - sizeof(*iph) < sizeof(*tcph))
+		return NF_ACCEPT;
+
+	iph = ip_hdr(skb);
+	if (iph->protocol != IPPROTO_TCP)
+		return NF_ACCEPT;
+
+	/* Local SMC server, outgoing SYN,ACK to client
+	 * add TCP experimental option if there really is a local SMC server
+	 */
+	if (tcph->syn == 1 && tcph->ack == 1) {
+		/* check if client's SYN contained the experimental option */
+		if (!smc_rv_exists_connecting_smc_peer(state->net,
+						       iph->saddr, tcph->source,
+						       iph->daddr, tcph->dest))
+			return NF_ACCEPT;
+		/* add experimental option */
+		if (smc_rv_add_smc_option(skb) < 0)
+			smc_rv_remove_smc_peer(state->net,
+					       iph->saddr, tcph->source,
+					       iph->daddr, tcph->dest);
+	}
+	return NF_ACCEPT;
+}
+
+static struct nf_hook_ops smc_nfho_ops_clnt[] = {
+	{
+		.hook = smc_rv_hook_in_clnt,
+		.hooknum = NF_INET_PRE_ROUTING,
+		.pf = PF_INET,
+		.priority = NF_IP_PRI_FIRST,
+	},
+	{
+		.hook = smc_rv_hook_out_clnt,
+		.hooknum = NF_INET_POST_ROUTING,
+		.pf = PF_INET,
+		.priority = NF_IP_PRI_FIRST,
+	},
+};
+
+static struct nf_hook_ops smc_nfho_ops_serv[] = {
+	{
+		.hook = smc_rv_hook_in_serv,
+		.hooknum = NF_INET_PRE_ROUTING,
+		.pf = PF_INET,
+		.priority = NF_IP_PRI_FIRST,
+	},
+	{
+		.hook = smc_rv_hook_out_serv,
+		.hooknum = NF_INET_POST_ROUTING,
+		.pf = PF_INET,
+		.priority = NF_IP_PRI_FIRST,
+	},
+};
+
+struct smc_nf_hook smc_nfho_clnt = {
+	.refcount = 0,
+	.hook = &smc_nfho_ops_clnt[0],
+};
+
+struct smc_nf_hook smc_nfho_serv = {
+	.refcount = 0,
+	.hook = &smc_nfho_ops_serv[0],
+};
+
+int smc_rv_nf_register_hook(struct net *net, struct smc_nf_hook *nfho)
+{
+	int rc = 0;
+
+	mutex_lock(&nfho->nf_hook_mutex);
+	if (!(nfho->refcount++)) {
+		rc = nf_register_net_hooks(net, nfho->hook, 2);
+		if (rc)
+			nfho->refcount--;
+	}
+	mutex_unlock(&nfho->nf_hook_mutex);
+	return rc;
+}
+
+void smc_rv_nf_unregister_hook(struct net *net, struct smc_nf_hook *nfho)
+{
+	mutex_lock(&nfho->nf_hook_mutex);
+	if (!(--nfho->refcount))
+		nf_unregister_net_hooks(net, nfho->hook, 2);
+	mutex_unlock(&nfho->nf_hook_mutex);
+}
+
+void __init smc_rv_init(void)
+{
+	mutex_init(&smc_nfho_clnt.nf_hook_mutex);
+	mutex_init(&smc_nfho_serv.nf_hook_mutex);
+}
diff --git a/net/smc/smc_rv.h b/net/smc/smc_rv.h
new file mode 100644
index 000000000000..c3bdf4c0a5cb
--- /dev/null
+++ b/net/smc/smc_rv.h
@@ -0,0 +1,31 @@
+/*
+ * Shared Memory Communications over RDMA (SMC-R) and RoCE
+ *
+ *  Definitions for SMC Rendezvous - SMC capability checking
+ *
+ *  Copyright IBM Corp. 2017
+ *
+ *  Author(s):	Hans Wippel <hwippel@linux.vnet.ibm.com>
+ *		Ursula Braun <ubraun@linux.vnet.ibm.com>
+ */
+
+#ifndef _SMC_RV_H
+#define _SMC_RV_H
+
+#include <linux/netfilter.h>
+
+#define SMC_LISTEN_PEND_VALID_TIME	(600 * HZ)
+
+struct smc_nf_hook {
+	struct mutex		nf_hook_mutex;	/* serialize nf register ops */
+	int			refcount;
+	struct nf_hook_ops	*hook;
+};
+
+extern struct smc_nf_hook smc_nfho_clnt;
+extern struct smc_nf_hook smc_nfho_serv;
+
+int smc_rv_nf_register_hook(struct net *net, struct smc_nf_hook *nfho);
+void smc_rv_nf_unregister_hook(struct net *net, struct smc_nf_hook *nfho);
+void smc_rv_init(void) __init;
+#endif
-- 
2.13.5
