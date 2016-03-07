From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 09/13] kcm: Splice support
Date: Mon, 7 Mar 2016 14:11:08 -0800
Message-ID: <1457388672-2600559-10-git-send-email-tom@herbertland.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:51133 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753707AbcCGWMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:12:12 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u27M964P021192
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 14:12:12 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21hgtcgf61-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:12:12 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 a354baa2e4b111e599860002c9521c9e-b91d7420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 14:12:10 -0800
In-Reply-To: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement kcm_splice_read. This is supported only for seqpacket.
Add kcm_seqpacket_ops and set splice read to kcm_splice_read.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/kcm/kcmsock.c | 98 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 96 insertions(+), 2 deletions(-)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index f938d7d..982ea5f 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1256,6 +1256,76 @@ out:
 	return copied ? : err;
 }
 
+static ssize_t kcm_sock_splice(struct sock *sk,
+			       struct pipe_inode_info *pipe,
+			       struct splice_pipe_desc *spd)
+{
+	int ret;
+
+	release_sock(sk);
+	ret = splice_to_pipe(pipe, spd);
+	lock_sock(sk);
+
+	return ret;
+}
+
+static ssize_t kcm_splice_read(struct socket *sock, loff_t *ppos,
+			       struct pipe_inode_info *pipe, size_t len,
+			       unsigned int flags)
+{
+	struct sock *sk = sock->sk;
+	struct kcm_sock *kcm = kcm_sk(sk);
+	long timeo;
+	struct kcm_rx_msg *rxm;
+	int err = 0;
+	size_t copied;
+	struct sk_buff *skb;
+
+	/* Only support splice for SOCKSEQPACKET */
+
+	timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+
+	lock_sock(sk);
+
+	skb = kcm_wait_data(sk, flags, timeo, &err);
+	if (!skb)
+		goto err_out;
+
+	/* Okay, have a message on the receive queue */
+
+	rxm = kcm_rx_msg(skb);
+
+	if (len > rxm->full_len)
+		len = rxm->full_len;
+
+	copied = skb_splice_bits(skb, sk, rxm->offset, pipe, len, flags,
+				 kcm_sock_splice);
+	if (copied < 0) {
+		err = copied;
+		goto err_out;
+	}
+
+	KCM_STATS_ADD(kcm->stats.rx_bytes, copied);
+
+	rxm->offset += copied;
+	rxm->full_len -= copied;
+
+	/* We have no way to return MSG_EOR. If all the bytes have been
+	 * read we still leave the message in the receive socket buffer.
+	 * A subsequent recvmsg needs to be done to return MSG_EOR and
+	 * finish reading the message.
+	 */
+
+	release_sock(sk);
+
+	return copied;
+
+err_out:
+	release_sock(sk);
+
+	return err;
+}
+
 /* kcm sock lock held */
 static void kcm_recv_disable(struct kcm_sock *kcm)
 {
@@ -1907,7 +1977,7 @@ static int kcm_release(struct socket *sock)
 	return 0;
 }
 
-static const struct proto_ops kcm_ops = {
+static const struct proto_ops kcm_dgram_ops = {
 	.family =	PF_KCM,
 	.owner =	THIS_MODULE,
 	.release =	kcm_release,
@@ -1928,6 +1998,28 @@ static const struct proto_ops kcm_ops = {
 	.sendpage =	sock_no_sendpage,
 };
 
+static const struct proto_ops kcm_seqpacket_ops = {
+	.family =	PF_KCM,
+	.owner =	THIS_MODULE,
+	.release =	kcm_release,
+	.bind =		sock_no_bind,
+	.connect =	sock_no_connect,
+	.socketpair =	sock_no_socketpair,
+	.accept =	sock_no_accept,
+	.getname =	sock_no_getname,
+	.poll =		datagram_poll,
+	.ioctl =	kcm_ioctl,
+	.listen =	sock_no_listen,
+	.shutdown =	sock_no_shutdown,
+	.setsockopt =	kcm_setsockopt,
+	.getsockopt =	kcm_getsockopt,
+	.sendmsg =	kcm_sendmsg,
+	.recvmsg =	kcm_recvmsg,
+	.mmap =		sock_no_mmap,
+	.sendpage =	sock_no_sendpage,
+	.splice_read =	kcm_splice_read,
+};
+
 /* Create proto operation for kcm sockets */
 static int kcm_create(struct net *net, struct socket *sock,
 		      int protocol, int kern)
@@ -1938,8 +2030,10 @@ static int kcm_create(struct net *net, struct socket *sock,
 
 	switch (sock->type) {
 	case SOCK_DGRAM:
+		sock->ops = &kcm_dgram_ops;
+		break;
 	case SOCK_SEQPACKET:
-		sock->ops = &kcm_ops;
+		sock->ops = &kcm_seqpacket_ops;
 		break;
 	default:
 		return -ESOCKTNOSUPPORT;
-- 
2.6.5
