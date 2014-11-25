From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 15/17] [atm] switch vcc_sendmsg() to copy_from_iter()
Date: Tue, 25 Nov 2014 14:02:29 +0000
Message-ID: <1416924151-28698-15-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

... and make it handle multi-segment iovecs - deals with that
"fix this later" issue for free.  A bit of shame, really - it
had been there since 2.3.15pre3 when the whole thing went into the
tree, practically a historical artefact by now...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/atm/common.c |   17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/atm/common.c b/net/atm/common.c
index 9cd1cca..f591129 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -570,15 +570,16 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 }
 
 int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
-		size_t total_len)
+		size_t size)
 {
 	struct sock *sk = sock->sk;
 	DEFINE_WAIT(wait);
 	struct atm_vcc *vcc;
 	struct sk_buff *skb;
 	int eff, error;
-	const void __user *buff;
-	int size;
+	struct iov_iter from;
+
+	iov_iter_init(&from, WRITE, m->msg_iov, m->msg_iovlen, size);
 
 	lock_sock(sk);
 	if (sock->state != SS_CONNECTED) {
@@ -589,12 +590,6 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		error = -EISCONN;
 		goto out;
 	}
-	if (m->msg_iovlen != 1) {
-		error = -ENOSYS; /* fix this later @@@ */
-		goto out;
-	}
-	buff = m->msg_iov->iov_base;
-	size = m->msg_iov->iov_len;
 	vcc = ATM_SD(sock);
 	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
 	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
@@ -607,7 +602,7 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		error = 0;
 		goto out;
 	}
-	if (size < 0 || size > vcc->qos.txtp.max_sdu) {
+	if (size > vcc->qos.txtp.max_sdu) {
 		error = -EMSGSIZE;
 		goto out;
 	}
@@ -639,7 +634,7 @@ int vcc_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *m,
 		goto out;
 	skb->dev = NULL; /* for paths shared with net_device interfaces */
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
-	if (copy_from_user(skb_put(skb, size), buff, size)) {
+	if (copy_from_iter(skb_put(skb, size), size, &from) != size) {
 		kfree_skb(skb);
 		error = -EFAULT;
 		goto out;
-- 
1.7.10.4
