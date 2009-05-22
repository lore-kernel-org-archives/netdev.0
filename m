From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 1/1 v2] isdn: Use kernel_{send,recv}msg instead of open
	coding
Date: Fri, 22 May 2009 12:37:24 -0300
Message-ID: <20090522153723.GA26133@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: isdn@linux-pingi.de, paul.moore@hp.com, netdev@vger.kernel.org,
	vanhoof@redhat.com, williams@redhat.com,
	linux-security-module@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

	I've fixed it up and did a make allmodconfig, no problems, I
think this time it is OK.

$ rm -f ../allmodconfig/drivers/isdn/mISDN/l1oip_core.o
$ make O=../allmodconfig drivers/isdn/mISDN/l1oip_core.o
  Using /home/acme_unencrypted/git/linux-2.6-tip as source for kernel
  GEN     /home/acme_unencrypted/git/allmodconfig/Makefile
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  SYMLINK include/asm -> include/asm-x86
  CALL    /home/acme_unencrypted/git/linux-2.6-tip/scripts/checksyscalls.sh
  CC      drivers/isdn/mISDN/l1oip_core.o
$

Regards,

- Arnaldo

commit cbe24f5d80209776a7e033c92a5882227a8360e6
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Fri May 22 12:32:05 2009 -0300

    isdn: Use kernel_{send,recv}msg instead of open coding
    
    Reducing the number of direct users of sock_{recv,send}msg.
    
    Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

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
index abe5749..910ac82 100644
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
 	unsigned char recvbuf[1500];
 	int recvlen;
@@ -708,16 +702,12 @@ l1oip_socket_thread(void *data)
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
@@ -729,12 +719,12 @@ l1oip_socket_thread(void *data)
 		printk(KERN_DEBUG "%s: socket created and open\n",
 			__func__);
 	while (!signal_pending(current)) {
-		iov.iov_base = recvbuf;
-		iov.iov_len = sizeof(recvbuf);
-		oldfs = get_fs();
-		set_fs(KERNEL_DS);
-		recvlen = sock_recvmsg(socket, &msg, sizeof(recvbuf), 0);
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
