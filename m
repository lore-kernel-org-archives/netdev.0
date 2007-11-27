From: Florian Zumbiehl <florz@florz.de>
Subject: [PATCH][UNIX] EOF on non-blocking SOCK_SEQPACKET
Date: Tue, 27 Nov 2007 10:33:23 +0100
Message-ID: <20071127093323.GA2690@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from odnb-4d0aa522.pool.mediaWays.net ([77.10.165.34]:43504 "EHLO
	rain.florz.dyndns.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbXK0KTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 05:19:12 -0500
Received: from florz.florz.dyndns.org ([192.168.0.121])
	by rain.florz.dyndns.org with esmtp (Exim 4.63)
	(envelope-from <florz@florz.de>)
	id 1Iwwol-0001T5-TR
	for netdev@vger.kernel.org; Tue, 27 Nov 2007 10:33:23 +0100
Received: from florz by florz.florz.dyndns.org with local (Exim 3.35 #1 (Debian))
	id 1Iwwol-000189-00
	for <netdev@vger.kernel.org>; Tue, 27 Nov 2007 10:33:23 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am not absolutely sure whether this actually is a bug (as in: I've got
no clue what the standards say or what other implementations do), but at
least I was pretty surprised when I noticed that a recv() on a
non-blocking unix domain socket of type SOCK_SEQPACKET (which is connection
oriented, after all) where the remote end has closed the connection
returned -1 (EAGAIN) rather than 0 to indicate end of file.

This is a test case:

| #include <sys/types.h>
| #include <unistd.h>
| #include <sys/socket.h>
| #include <sys/un.h>
| #include <fcntl.h>
| #include <string.h>
| #include <stdlib.h>
| 
| int main(){
| 	int sock;
| 	struct sockaddr_un addr;
| 	char buf[4096];
| 	int pfds[2];
| 
| 	pipe(pfds);
| 	sock=socket(PF_UNIX,SOCK_SEQPACKET,0);
| 	addr.sun_family=AF_UNIX;
| 	strcpy(addr.sun_path,"/tmp/foobar_testsock");
| 	bind(sock,(struct sockaddr *)&addr,sizeof(addr));
| 	listen(sock,1);
| 	if(fork()){
| 		close(sock);
| 		sock=socket(PF_UNIX,SOCK_SEQPACKET,0);
| 		connect(sock,(struct sockaddr *)&addr,sizeof(addr));
| 		fcntl(sock,F_SETFL,fcntl(sock,F_GETFL)|O_NONBLOCK);
| 		close(pfds[1]);
| 		read(pfds[0],buf,sizeof(buf));
| 		recv(sock,buf,sizeof(buf),0); // <-- this one
| 	}else accept(sock,NULL,NULL);
| 	exit(0);
| }

If you try it, make sure /tmp/foobar_testsock doesn't exist.

The marked recv() returns -1 (EAGAIN) on 2.6.23.9. Below you find a
patch that fixes that.

Florian

---------------------------------------------------------------------------
Signed-off-by: Florian Zumbiehl <florz@florz.de>

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index a05c342..fa0aec5 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1632,8 +1632,13 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	mutex_lock(&u->readlock);
 
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
-	if (!skb)
+	if (!skb) {
+		unix_state_lock(sk);
+		if (sk->sk_type==SOCK_SEQPACKET && err==-EAGAIN && (sk->sk_shutdown&RCV_SHUTDOWN))
+			err=0; /* signal EOF on disconnected non-blocking SEQPACKET socket */
+		unix_state_unlock(sk);
 		goto out_unlock;
+	}
 
 	wake_up_interruptible(&u->peer_wait);
 
