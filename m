From: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
Subject: [mISDN PATCH v2 18/19] Use kernel_{send,
	recv}msg instead of open coding
Date: Fri, 22 May 2009 23:04:57 +0200
Message-ID: <1a4e959be14edc314d53d49da873c5b547dfc169.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <cover.1243024967.git.kkeil-Zw2aQviYsaUCyFmpLCWB8V3+hHH5wKcB@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Reducing the number of direct users of sock_{recv,send}msg.
Modified version to match the latest context.

Signed-off-by: Arnaldo Carvalho de Melo <acme-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Karsten Keil <keil-shG/GajIFYqbacvFa/9K2g@public.gmane.org>
---
 drivers/isdn/mISDN/l1oip.h      |    2 +-
 drivers/isdn/mISDN/l1oip_core.c |   24 +++++++-----------------
 2 files changed, 8 insertions(+), 18 deletions(-)

diff --git a/drivers/isdn/mISDN/l1oip.h b/drivers/isdn/mISDN/l1oip.h
index a23d575..bc26c89 100644
--- a/drivers/isdn/mISDN/l1oip.h
+++ b/drivers/isdn/mISDN/l1oip.h
@@ -76,7 +76,7 @@ struct l1oip {
 	struct sockaddr_in	sin_local;	/* local socket name */
 	struct sockaddr_in	sin_remote;	/* remote socket name */
 	struct msghdr		sendmsg;	/* ip message to send */
-	struct iovec		sendiov;	/* iov for message */
+	struct kvec		sendiov;	/* iov for message */
 
 	/* frame */
 	struct l1oip_chan	chan[128];	/* channel instances */
diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index d9cf83b..990e6a7 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -279,7 +279,6 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec, u8 channel, u32 chanmask,
 	int multi = 0;
 	u8 frame[len+32];
 	struct socket *socket = NULL;
-	mm_segment_t oldfs;
 
 	if (debug & DEBUG_L1OIP_MSG)
 		printk(KERN_DEBUG "%s: sending data to socket (len = %d)\n",
@@ -352,10 +351,7 @@ l1oip_socket_send(struct l1oip *hc, u8 localcodec, u8 channel, u32 chanmask,
 			"= %d)\n", __func__, len);
 	hc->sendiov.iov_base = frame;
 	hc->sendiov.iov_len  = len;
-	oldfs = get_fs();
-	set_fs(KERNEL_DS);
-	len = sock_sendmsg(socket, &hc->sendmsg, len);
-	set_fs(oldfs);
+	len = kernel_sendmsg(socket, &hc->sendmsg, &hc->sendiov, 1, len);
 	/* give socket back */
 	hc->socket = socket; /* no locking required */
 
@@ -660,8 +656,6 @@ l1oip_socket_thread(void *data)
 	struct l1oip *hc = (struct l1oip *)data;
 	int ret = 0;
 	struct msghdr msg;
-	struct iovec iov;
-	mm_segment_t oldfs;
 	struct sockaddr_in sin_rx;
 	unsigned char *recvbuf;
 	size_t recvbuf_size = 1500;
@@ -718,16 +712,12 @@ l1oip_socket_thread(void *data)
 	msg.msg_namelen = sizeof(sin_rx);
 	msg.msg_control = NULL;
 	msg.msg_controllen = 0;
-	msg.msg_iov = &iov;
-	msg.msg_iovlen = 1;
 
 	/* build send message */
 	hc->sendmsg.msg_name = &hc->sin_remote;
 	hc->sendmsg.msg_namelen = sizeof(hc->sin_remote);
 	hc->sendmsg.msg_control = NULL;
 	hc->sendmsg.msg_controllen = 0;
-	hc->sendmsg.msg_iov    = &hc->sendiov;
-	hc->sendmsg.msg_iovlen = 1;
 
 	/* give away socket */
 	spin_lock(&hc->socket_lock);
@@ -739,12 +729,12 @@ l1oip_socket_thread(void *data)
 		printk(KERN_DEBUG "%s: socket created and open\n",
 			__func__);
 	while (!signal_pending(current)) {
-		iov.iov_base = recvbuf;
-		iov.iov_len = recvbuf_size;
-		oldfs = get_fs();
-		set_fs(KERNEL_DS);
-		recvlen = sock_recvmsg(socket, &msg, recvbuf_size, 0);
-		set_fs(oldfs);
+		struct kvec iov = {
+			.iov_base = recvbuf,
+			.iov_len = sizeof(recvbuf),
+		};
+		recvlen = kernel_recvmsg(socket, &msg, &iov, 1,
+					 sizeof(recvbuf), 0);
 		if (recvlen > 0) {
 			l1oip_socket_parse(hc, &sin_rx, recvbuf, recvlen);
 		} else {
-- 
1.6.0.2
