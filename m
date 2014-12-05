From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: [RESEND PATCH] net: introduce helper macra CMSG_FOREACH_HDR
Date: Fri, 5 Dec 2014 15:14:08 +0800
Message-ID: <54815B40.1050909@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce helper macra CMSG_FOREACH_HDR as a wrapper of the enumerating
cmsghdr from msghdr, just cleanup. 

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
 .../networking/timestamping/timestamping.c         |    4 +---
 .../networking/timestamping/txtimestamp.c          |    4 +---
 crypto/af_alg.c                                    |    2 +-
 include/linux/socket.h                             |    4 ++++
 net/core/scm.c                                     |    3 +--
 net/dccp/proto.c                                   |    5 ++---
 net/ipv4/ip_sockglue.c                             |    2 +-
 net/ipv6/datagram.c                                |    2 +-
 net/iucv/af_iucv.c                                 |    4 +---
 net/rds/send.c                                     |    4 ++--
 net/rxrpc/ar-output.c                              |    2 +-
 net/sctp/socket.c                                  |    3 +--
 12 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/Documentation/networking/timestamping/timestamping.c b/Documentation/networking/timestamping/timestamping.c
index 5cdfd74..3106e88 100644
--- a/Documentation/networking/timestamping/timestamping.c
+++ b/Documentation/networking/timestamping/timestamping.c
@@ -169,9 +169,7 @@ static void printpacket(struct msghdr *msg, int res,
 	       res,
 	       inet_ntoa(from_addr->sin_addr),
 	       msg->msg_controllen);
-	for (cmsg = CMSG_FIRSTHDR(msg);
-	     cmsg;
-	     cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		printf("   cmsg len %zu: ", cmsg->cmsg_len);
 		switch (cmsg->cmsg_level) {
 		case SOL_SOCKET:
diff --git a/Documentation/networking/timestamping/txtimestamp.c b/Documentation/networking/timestamping/txtimestamp.c
index b32fc2a..e44ef35 100644
--- a/Documentation/networking/timestamping/txtimestamp.c
+++ b/Documentation/networking/timestamping/txtimestamp.c
@@ -149,9 +149,7 @@ static void __recv_errmsg_cmsg(struct msghdr *msg, int payload_len)
 	struct scm_timestamping *tss = NULL;
 	struct cmsghdr *cm;
 
-	for (cm = CMSG_FIRSTHDR(msg);
-	     cm && cm->cmsg_len;
-	     cm = CMSG_NXTHDR(msg, cm)) {
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		if (cm->cmsg_level == SOL_SOCKET &&
 		    cm->cmsg_type == SCM_TIMESTAMPING) {
 			tss = (void *) CMSG_DATA(cm);
diff --git a/crypto/af_alg.c b/crypto/af_alg.c
index 6a3ad80..3df7d53 100644
--- a/crypto/af_alg.c
+++ b/crypto/af_alg.c
@@ -399,7 +399,7 @@ int af_alg_cmsg_send(struct msghdr *msg, struct af_alg_control *con)
 {
 	struct cmsghdr *cmsg;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 		if (cmsg->cmsg_level != SOL_ALG)
diff --git a/include/linux/socket.h b/include/linux/socket.h
index bb9b836..d4b592f 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -94,6 +94,10 @@ struct cmsghdr {
 			     (cmsg)->cmsg_len <= (unsigned long) \
 			     ((mhdr)->msg_controllen - \
 			      ((char *)(cmsg) - (char *)(mhdr)->msg_control)))
+#define CMSG_FOREACH_HDR(cmsg, msg)  \
+	for (cmsg = CMSG_FIRSTHDR(msg); \
+	     cmsg; \
+	     cmsg = CMSG_NXTHDR(msg, cmsg))
 
 /*
  *	Get the next cmsg header
diff --git a/net/core/scm.c b/net/core/scm.c
index b442e7e..e938c49 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -129,8 +129,7 @@ int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *p)
 	struct cmsghdr *cmsg;
 	int err;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg))
-	{
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		err = -EINVAL;
 
 		/* Verify that cmsg_len is at least sizeof(struct cmsghdr) */
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 5ab6627..d449cc5 100644
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
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 9daf217..14a6f71 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -192,7 +192,7 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
 	int err, val;
 	struct cmsghdr *cmsg;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 2cdc383..9895b98 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -640,7 +640,7 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 	int len;
 	int err = 0;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		int addr_type;
 
 		if (!CMSG_OK(msg, cmsg)) {
diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index a089b6b..eae4e08 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1070,9 +1070,7 @@ static int iucv_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	txmsg.class = 0;
 
 	/* iterate over control messages */
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg;
-		cmsg = CMSG_NXTHDR(msg, cmsg)) {
-
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg)) {
 			err = -EINVAL;
 			goto out;
diff --git a/net/rds/send.c b/net/rds/send.c
index 0a64541..1accb3e 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -826,7 +826,7 @@ static int rds_rm_size(struct msghdr *msg, int data_len)
 	int cmsg_groups = 0;
 	int retval;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
@@ -878,7 +878,7 @@ static int rds_cmsg_send(struct rds_sock *rs, struct rds_message *rm,
 	struct cmsghdr *cmsg;
 	int ret = 0;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 0b4b9a7..f915e7e 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -45,7 +45,7 @@ static int rxrpc_sendmsg_cmsg(struct rxrpc_sock *rx, struct msghdr *msg,
 	if (msg->msg_controllen == 0)
 		return -EINVAL;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
+	CMSG_FOREACH_HDR(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 634a2ab..58834d7 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6592,8 +6592,7 @@ static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
 	struct cmsghdr *cmsg;
 	struct msghdr *my_msg = (struct msghdr *)msg;
 
-	for (cmsg = CMSG_FIRSTHDR(msg); cmsg != NULL;
-	     cmsg = CMSG_NXTHDR(my_msg, cmsg)) {
+	CMSG_FOREACH_HDR(cmsg, my_msg) {
 		if (!CMSG_OK(my_msg, cmsg))
 			return -EINVAL;
 
-- 
1.7.7

.
