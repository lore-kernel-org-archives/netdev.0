From: Michal Schmidt <mschmidt@redhat.com>
Subject: uninterruptible sleep in unix_dgram_recvmsg
Date: Thu, 4 Mar 2010 18:41:14 +0100
Message-ID: <20100304184114.62881b21@leela>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab0CDRlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 12:41:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David.

When multiple tasks call recv() on a AF_UNIX/SOCK_DGRAM socket where
noone sends anything, only the first one will sleep interruptibly. The
others are in uninterruptible sleep, causing artificial increase of
loadavg. After two minutes, the hung task watchdog triggers and prints
ugly warnings.

The bug is reported here (with a reproducer attached):
https://bugzilla.redhat.com/show_bug.cgi?id=529202

While the first task awaits the arrival of a packet in
skb_recv_datagram(), it holds the u->readlock mutex, on which the
other tasks will be waiting.

My first idea was to simply replace mutex_lock with
mutex_lock_interruptible. This solves the problem, but one
issue still remains - the receiving timeout (SO_RCVTIMEO) would start
ticking only after the process got the mutex and entered into
skb_recv_datagram().

So instead of that I started to think about why u->readlock is held
across skb_recv_datagram() anyway. I found that it was added in 2.6.10
by your patch "[AF_UNIX]: Serialize dgram read using semaphore just
like stream" which apparently fixed an exploitable race condition
(CAN-2004-1068).

I don't know what exactly u->readlock protects here.
IOW, what race would this patch cause?:

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f255119..01387da 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1660,9 +1660,9 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 	msg->msg_namelen = 0;
 
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	mutex_lock(&u->readlock);
 
-	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb) {
 		unix_state_lock(sk);
 		/* Signal EOF on disconnected non-blocking SEQPACKET socket. */
