From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: [PATCH v3] net: introduce helper macro for_each_cmsghdr
Date: Thu, 11 Dec 2014 11:22:04 +0800
Message-ID: <54890DDC.3040402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce helper macro for_each_cmsghdr as a wrapper of the enumerating
cmsghdr from msghdr, just cleanup.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
v3:
 -drop the changes about user-land programs as David suggested.
v2:
 -use the lower-case macro name as Joe suggested.

 crypto/af_alg.c        |    2 +-
 include/linux/socket.h |    4 ++++
 net/core/scm.c         |    3 +--
 net/dccp/proto.c       |    5 ++---
 net/ipv4/ip_sockglue.c |    2 +-
 net/ipv6/datagram.c    |    2 +-
 net/iucv/af_iucv.c     |    4 +---
 net/rds/send.c         |    4 ++--
 net/rxrpc/ar-output.c  |    2 +-
 net/sctp/socket.c      |    3 +--
 10 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 6a3ad80..bc21f52 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -399,7 +399,7 @@ int af_alg_cmsg_send(struct msghdr *msg, struct af_alg_control *con)
 {
 	struct cmsghdr *cmsg;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	for_each_cmsghdr(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 		if (cmsg->cmsg_level != SOL_ALG)
diff --git a/include/linux/socket.h b/include/linux/socket.h
index bb9b836..0e71278 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -94,6 +94,10 @@ struct cmsghdr {
 			     (cmsg)->cmsg_len <= (unsigned long) \
 			     ((mhdr)->msg_controllen - \
 			      ((char *)(cmsg) - (char *)(mhdr)->msg_control)))
+#define for_each_cmsghdr(cmsg, msg) \
+	for (cmsg = CMSG_FIRSTHDR(msg); \
+	     cmsg; \
+	     cmsg = CMSG_NXTHDR(msg, cmsg))
 
 /*
  *	Get the next cmsg header
diff --git a/net/core/scm.c b/net/core/scm.c
index b442e7e..3b6899b 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -129,8 +129,7 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 	struct cmsghdr *cmsg;
 	int err;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg))
-	{
+	for_each_cmsghdr(cmsg, msg) {
 		err = -EINVAL;
 
 		/* Verify that cmsg_len is at least sizeof(struct cmsghdr) */
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 5ab6627..e7413a9 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -703,7 +703,7 @@ EXPORT_SYMBOL_GPL(compat_dccp_getsockopt);
 
 static int dccp_msghdr_parse(struct msghdr *msg, struct sk_buff *skb)
 {
-	struct cmsghdr *cmsg = CMSG_FIRSTHDR(msg);
+	struct cmsghdr *cmsg;
 
 	/*
 	 * Assign an (opaque) qpolicy priority value to skb->priority.
@@ -717,8 +717,7 @@ static int dccp_msghdr_parse(struct msghdr *msg, struct sk_buff *skb)
 	 */
 	skb->priority = 0;
 
-	for (; cmsg != NULL; cmsg = CMSG_NXTHDR(msg, cmsg)) {
-
+	for_each_cmsghdr(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 9daf217..839db9d 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -192,7 +192,7 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
 	int err, val;
 	struct cmsghdr *cmsg;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	for_each_cmsghdr(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2cdc383..7252965 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -640,7 +640,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 	int len;
 	int err = 0;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	for_each_cmsghdr(cmsg, msg) {
 		int addr_type;
 
 		if (!CMSG_OK(msg, cmsg)) {
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index a089b6b..b69d87e 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1070,9 +1070,7 @@ static int iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	txmsg.class = 0;
 
 	/* iterate over control messages */
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg;
-		cmsg = CMSG_NXTHDR(msg, cmsg)) {
-
+	for_each_cmsghdr(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg)) {
 			err = -EINVAL;
 			goto out;
diff --git a/net/rds/send.c b/net/rds/send.c
index 0a64541..b23e7b8 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -826,7 +826,7 @@ static int rds_rm_size(struct msghdr *msg, int data_len)
 	int cmsg_groups = 0;
 	int retval;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	for_each_cmsghdr(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
@@ -878,7 +878,7 @@ static int rds_cmsg_send(struct rds_sock *rs, struct rds_message *rm,
 	struct cmsghdr *cmsg;
 	int ret = 0;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	for_each_cmsghdr(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 0b4b9a7..83b4616 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -45,7 +45,7 @@ static int rxrpc_sendmsg_cmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	if (msg->msg_controllen == 0)
 		return -EINVAL;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	for_each_cmsghdr(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 634a2ab..a3802ed 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6592,8 +6592,7 @@ static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
 	struct cmsghdr *cmsg;
 	struct msghdr *my_msg = (struct msghdr *)msg;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg != NULL;
-	     cmsg = CMSG_NXTHDR(my_msg, cmsg)) {
+	for_each_cmsghdr(cmsg, my_msg) {
 		if (!CMSG_OK(my_msg, cmsg))
 			return -EINVAL;
 
-- 
1.7.7
