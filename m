From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 1/1] isdn: Use kernel_{send,recv}msg instead of open coding
Date: Thu, 21 May 2009 12:41:26 -0300
Message-ID: <20090521154126.GH5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reducing the number of direct users of sock_{recv,send}msg.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index abe5749..8caf40e 100644
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
+	len = kernel_sendmsg(socket, &hc->sendmsg, len);
 	/* give socket back */
 	hc->socket = socket; /* no locking required */
 
@@ -661,7 +657,6 @@ l1oip_socket_thread(void *data)
 	int ret = 0;
 	struct msghdr msg;
 	struct iovec iov;
-	mm_segment_t oldfs;
 	struct sockaddr_in sin_rx;
 	unsigned char recvbuf[1500];
 	int recvlen;
@@ -731,10 +726,7 @@ l1oip_socket_thread(void *data)
 	while (!signal_pending(current)) {
 		iov.iov_base = recvbuf;
 		iov.iov_len = sizeof(recvbuf);
-		oldfs = get_fs();
-		set_fs(KERNEL_DS);
-		recvlen = sock_recvmsg(socket, &msg, sizeof(recvbuf), 0);
-		set_fs(oldfs);
+		recvlen = kernel_recvmsg(socket, &msg, sizeof(recvbuf), 0);
 		if (recvlen > 0) {
 			l1oip_socket_parse(hc, &sin_rx, recvbuf, recvlen);
 		} else {
