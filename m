From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] SUNRPC: Compile out bufs for debug printks
Date: Wed, 20 Feb 2008 19:30:22 +0300
Message-ID: <47BC559E.5000101@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43153 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933625AbYBTQa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:30:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are many places, which declare the char buf[...] on the stack
to push it later into dprintk(). Since the dprintk sometimes (if the 
CONFIG_SYSCTL=n) becomes an empty do { } while (0) stub, these buffers
cause gcc to produce appropriate warnings.

Introduce a macro that declares that buf as __maybe_unused.

More candidates for patching are found by Joe Perches.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 0822646..b7e179e 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -153,7 +153,7 @@ lockd(struct svc_rqst *rqstp)
 	 */
 	while ((nlmsvc_users || !signalled()) && nlmsvc_pid == current->pid) {
 		long timeout = MAX_SCHEDULE_TIMEOUT;
-		char buf[RPC_MAX_ADDRBUFLEN];
+		DECLARE_RPC_BUF(buf);
 
 		if (signalled()) {
 			flush_signals(current);
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 385437e..5643f44 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -436,7 +436,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 	dprintk("lockd: SM_NOTIFY     called\n");
 	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
 	 || ntohs(saddr.sin_port) >= 1024) {
-		char buf[RPC_MAX_ADDRBUFLEN];
+		DECLARE_RPC_BUF(buf);
 		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n",
 				svc_print_addr(rqstp, buf, sizeof(buf)));
 		return rpc_system_err;
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 88379cc..5f0cf50 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -468,7 +468,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 	dprintk("lockd: SM_NOTIFY     called\n");
 	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
 	 || ntohs(saddr.sin_port) >= 1024) {
-		char buf[RPC_MAX_ADDRBUFLEN];
+		DECLARE_RPC_BUF(buf);
 		printk(KERN_WARNING "lockd: rejected NSM callback from %s\n",
 				svc_print_addr(rqstp, buf, sizeof(buf)));
 		return rpc_system_err;
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bd185a5..33950dc 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -165,7 +165,7 @@ void nfs_callback_down(void)
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
 	struct nfs_client *clp;
-	char buf[RPC_MAX_ADDRBUFLEN];
+	DECLARE_RPC_BUF(buf);
 
 	/* Don't talk to strangers */
 	clp = nfs_find_client(svc_addr(rqstp), 4);
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 8fbd2dc..94fe70e 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -101,7 +101,7 @@ static __be32 nfsd_setuser_and_check_port(struct svc_rqst *rqstp,
 {
 	/* Check if the request originated from a secure port. */
 	if (!rqstp->rq_secure && EX_SECURE(exp)) {
-		char buf[RPC_MAX_ADDRBUFLEN];
+		DECLARE_RPC_BUF(buf);
 		dprintk(KERN_WARNING
 		       "nfsd: request from insecure port %s!\n",
 		       svc_print_addr(rqstp, buf, sizeof(buf)));
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 977a71f..66383ae 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -148,7 +148,7 @@ nfsd_proc_read(struct svc_rqst *rqstp, struct nfsd_readargs *argp,
 	 */
 
 	if (NFSSVC_MAXBLKSIZE_V2 < argp->count) {
-		char buf[RPC_MAX_ADDRBUFLEN];
+		DECLARE_RPC_BUF(buf);
 		printk(KERN_NOTICE
 			"oversized read request from %s (%d bytes)\n",
 				svc_print_addr(rqstp, buf, sizeof(buf)),
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 64c9755..fd701e6 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -402,6 +402,8 @@ char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
 
 #define	RPC_MAX_ADDRBUFLEN	(63U)
 
+#define DECLARE_RPC_BUF(name)	char name[RPC_MAX_ADDRBUFLEN] __maybe_unused
+
 /*
  * When we want to reduce the size of the reserved space in the response
  * buffer, we need to take into account the size of any checksum data that
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a290e15..895d365 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -813,7 +813,7 @@ svc_printk(struct svc_rqst *rqstp, const char *fmt, ...)
 {
 	va_list args;
 	int 	r;
-	char 	buf[RPC_MAX_ADDRBUFLEN];
+	DECLARE_RPC_BUF(buf);
 
 	if (!net_ratelimit())
 		return 0;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1d3e5fc..87dc4bc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -175,7 +175,7 @@ static int svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 	size_t		base = xdr->page_base;
 	unsigned int	pglen = xdr->page_len;
 	unsigned int	flags = MSG_MORE;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	DECLARE_RPC_BUF(buf);
 
 	slen = xdr->len;
 
@@ -716,7 +716,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	struct socket	*newsock;
 	struct svc_sock	*newsvsk;
 	int		err, slen;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	DECLARE_RPC_BUF(buf);
 
 	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
 	if (!sock)
@@ -1206,7 +1206,7 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	struct socket	*sock;
 	int		error;
 	int		type;
-	char		buf[RPC_MAX_ADDRBUFLEN];
+	DECLARE_RPC_BUF(buf);
 	struct sockaddr_storage addr;
 	struct sockaddr *newsin = (struct sockaddr *)&addr;
 	int		newlen;
