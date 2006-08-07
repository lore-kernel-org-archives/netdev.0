From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH RESEND 2/2] update sunrpc to use in-kernel sockets API
Date: Mon, 07 Aug 2006 16:00:32 -0700
Message-ID: <1154991632.11916.6.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:19360 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751008AbWHGXFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 19:05:34 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k77N5XAT021041
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 19:05:34 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k77N5XdB286718
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 19:05:33 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k77N5Xfi014529
	for <netdev@vger.kernel.org>; Mon, 7 Aug 2006 19:05:33 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update sunrpc to use in-kernel sockets API.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
Acked-by: James Morris <jmorris@namei.org>

---

 net/sunrpc/svcsock.c  |   38 ++++++++++++++------------------------
 net/sunrpc/xprtsock.c |    8 ++++----
 2 files changed, 18 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d9a9573..953aff8 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -388,7 +388,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	/* send head */
 	if (slen == xdr->head[0].iov_len)
 		flags = 0;
-	len = sock->ops->sendpage(sock, rqstp->rq_respages[0], 0, xdr->head[0].iov_len, flags);
+	len = kernel_sendpage(sock, rqstp->rq_respages[0], 0, xdr->head[0].iov_len, flags);
 	if (len != xdr->head[0].iov_len)
 		goto out;
 	slen -= xdr->head[0].iov_len;
@@ -400,7 +400,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	while (pglen > 0) {
 		if (slen == size)
 			flags = 0;
-		result = sock->ops->sendpage(sock, *ppage, base, size, flags);
+		result = kernel_sendpage(sock, *ppage, base, size, flags);
 		if (result > 0)
 			len += result;
 		if (result != size)
@@ -413,7 +413,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	}
 	/* send tail */
 	if (xdr->tail[0].iov_len) {
-		result = sock->ops->sendpage(sock, rqstp->rq_respages[rqstp->rq_restailpage], 
+		result = kernel_sendpage(sock, rqstp->rq_respages[rqstp->rq_restailpage],
 					     ((unsigned long)xdr->tail[0].iov_base)& (PAGE_SIZE-1),
 					     xdr->tail[0].iov_len, 0);
 
@@ -434,13 +434,10 @@ out:
 static int
 svc_recv_available(struct svc_sock *svsk)
 {
-	mm_segment_t	oldfs;
 	struct socket	*sock = svsk->sk_sock;
 	int		avail, err;
 
-	oldfs = get_fs(); set_fs(KERNEL_DS);
-	err = sock->ops->ioctl(sock, TIOCINQ, (unsigned long) &avail);
-	set_fs(oldfs);
+	err = kernel_sock_ioctl(sock, TIOCINQ, (unsigned long) &avail);
 
 	return (err >= 0)? avail : err;
 }
@@ -472,7 +469,7 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	 * at accept time. FIXME
 	 */
 	alen = sizeof(rqstp->rq_addr);
-	sock->ops->getname(sock, (struct sockaddr *)&rqstp->rq_addr, &alen, 1);
+	kernel_getpeername(sock, (struct sockaddr *)&rqstp->rq_addr, &alen);
 
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
 		rqstp->rq_sock, iov[0].iov_base, iov[0].iov_len, len);
@@ -758,7 +755,6 @@ svc_tcp_accept(struct svc_sock *svsk)
 	struct svc_serv	*serv = svsk->sk_server;
 	struct socket	*sock = svsk->sk_sock;
 	struct socket	*newsock;
-	const struct proto_ops *ops;
 	struct svc_sock	*newsvsk;
 	int		err, slen;
 
@@ -766,29 +762,23 @@ svc_tcp_accept(struct svc_sock *svsk)
 	if (!sock)
 		return;
 
-	err = sock_create_lite(PF_INET, SOCK_STREAM, IPPROTO_TCP, &newsock);
-	if (err) {
+	clear_bit(SK_CONN, &svsk->sk_flags);
+	err = kernel_accept(sock, &newsock, O_NONBLOCK);
+	if (err < 0) {
 		if (err == -ENOMEM)
 			printk(KERN_WARNING "%s: no more sockets!\n",
 			       serv->sv_name);
-		return;
-	}
-
-	dprintk("svc: tcp_accept %p allocated\n", newsock);
-	newsock->ops = ops = sock->ops;
-
-	clear_bit(SK_CONN, &svsk->sk_flags);
-	if ((err = ops->accept(sock, newsock, O_NONBLOCK)) < 0) {
-		if (err != -EAGAIN && net_ratelimit())
+		else if (err != -EAGAIN && net_ratelimit())
 			printk(KERN_WARNING "%s: accept failed (err %d)!\n",
 				   serv->sv_name, -err);
-		goto failed;		/* aborted connection or whatever */
+		return;
 	}
+
 	set_bit(SK_CONN, &svsk->sk_flags);
 	svc_sock_enqueue(svsk);
 
 	slen = sizeof(sin);
-	err = ops->getname(newsock, (struct sockaddr *) &sin, &slen, 1);
+	err = kernel_getpeername(newsock, (struct sockaddr *) &sin, &slen);
 	if (err < 0) {
 		if (net_ratelimit())
 			printk(KERN_WARNING "%s: peername failed (err %d)!\n",
@@ -1406,14 +1396,14 @@ svc_create_socket(struct svc_serv *serv,
 	if (sin != NULL) {
 		if (type == SOCK_STREAM)
 			sock->sk->sk_reuse = 1; /* allow address reuse */
-		error = sock->ops->bind(sock, (struct sockaddr *) sin,
+		error = kernel_bind(sock, (struct sockaddr *) sin,
 						sizeof(*sin));
 		if (error < 0)
 			goto bummer;
 	}
 
 	if (protocol == IPPROTO_TCP) {
-		if ((error = sock->ops->listen(sock, 64)) < 0)
+		if ((error = kernel_listen(sock, 64)) < 0)
 			goto bummer;
 	}
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 441bd53..8b319e3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -207,7 +207,7 @@ static inline int xs_sendpages(struct so
 		base &= ~PAGE_CACHE_MASK;
 	}
 
-	sendpage = sock->ops->sendpage ? : sock_no_sendpage;
+	sendpage = kernel_sendpage;
 	do {
 		int flags = XS_SENDMSG_FLAGS;
 
@@ -986,7 +986,7 @@ static int xs_bindresvport(struct rpc_xp
 
 	do {
 		myaddr.sin_port = htons(port);
-		err = sock->ops->bind(sock, (struct sockaddr *) &myaddr,
+		err = kernel_bind(sock, (struct sockaddr *) &myaddr,
 						sizeof(myaddr));
 		if (err == 0) {
 			xprt->port = port;
@@ -1081,7 +1081,7 @@ static void xs_tcp_reuse_connection(stru
 	 */
 	memset(&any, 0, sizeof(any));
 	any.sa_family = AF_UNSPEC;
-	result = sock->ops->connect(sock, &any, sizeof(any), 0);
+	result = kernel_connect(sock, &any, sizeof(any), 0);
 	if (result)
 		dprintk("RPC:      AF_UNSPEC connect return code %d\n",
 				result);
@@ -1151,7 +1151,7 @@ static void xs_tcp_connect_worker(void *
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
-	status = sock->ops->connect(sock, (struct sockaddr *) &xprt->addr,
+	status = kernel_connect(sock, (struct sockaddr *) &xprt->addr,
 			sizeof(xprt->addr), O_NONBLOCK);
 	dprintk("RPC: %p  connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt), sock->sk->sk_state);


