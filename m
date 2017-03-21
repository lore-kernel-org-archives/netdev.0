From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 5/8] tun: support receiving skb through msg_control
Date: Tue, 21 Mar 2017 12:04:44 +0800
Message-ID: <1490069087-4783-6-git-send-email-jasowang@redhat.com>
References: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1490069087-4783-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This patch makes tun_recvmsg() can receive from skb from its caller
through msg_control. Vhost_net will be the first user.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 70dd9ec..a82bced 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1498,9 +1498,8 @@ static struct sk_buff *tun_ring_recv(struct tun_file *tfile, int noblock,
 
 static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 			   struct iov_iter *to,
-			   int noblock)
+			   int noblock, struct sk_buff *skb)
 {
-	struct sk_buff *skb;
 	ssize_t ret;
 	int err;
 
@@ -1509,10 +1508,12 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 	if (!iov_iter_count(to))
 		return 0;
 
-	/* Read frames from ring */
-	skb = tun_ring_recv(tfile, noblock, &err);
-	if (!skb)
-		return err;
+	if (!skb) {
+		/* Read frames from ring */
+		skb = tun_ring_recv(tfile, noblock, &err);
+		if (!skb)
+			return err;
+	}
 
 	ret = tun_put_user(tun, tfile, skb, to);
 	if (unlikely(ret < 0))
@@ -1532,7 +1533,7 @@ static ssize_t tun_chr_read_iter(struct kiocb *iocb, struct iov_iter *to)
 
 	if (!tun)
 		return -EBADFD;
-	ret = tun_do_read(tun, tfile, to, file->f_flags & O_NONBLOCK);
+	ret = tun_do_read(tun, tfile, to, file->f_flags & O_NONBLOCK, NULL);
 	ret = min_t(ssize_t, ret, len);
 	if (ret > 0)
 		iocb->ki_pos = ret;
@@ -1634,7 +1635,8 @@ static int tun_recvmsg(struct socket *sock, struct msghdr *m, size_t total_len,
 					 SOL_PACKET, TUN_TX_TIMESTAMP);
 		goto out;
 	}
-	ret = tun_do_read(tun, tfile, &m->msg_iter, flags & MSG_DONTWAIT);
+	ret = tun_do_read(tun, tfile, &m->msg_iter, flags & MSG_DONTWAIT,
+			  m->msg_control);
 	if (ret > (ssize_t)total_len) {
 		m->msg_flags |= MSG_TRUNC;
 		ret = flags & MSG_TRUNC ? ret : total_len;
-- 
2.7.4
