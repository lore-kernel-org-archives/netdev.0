From: David Miller <davem@davemloft.net>
Subject: SPLICE_F_NONBLOCK semantics...
Date: Thu, 01 Oct 2009 15:11:02 -0700 (PDT)
Message-ID: <20091001.151102.09812927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jgunthorpe@obsidianresearch.com,
	vl@samba.org, opurdila@ixiacom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60716
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752617AbZJAWKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 18:10:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Linus, I plan on putting the fix below into my tree.

It depends upon our interpretation of how you intended the
SPLICE_F_NONBLOCK flag to work when you added it way back
when.

Could you take a quick look and make sure our interpretation matches
your intent?  This behavior has been bugging people for a while and I
want to close this out, one way or another.

Thanks!

[PATCH] net: splice() from tcp to pipe should take into account O_NONBLOCK

tcp_splice_read() doesnt take into account socket's O_NONBLOCK flag

Before this patch :

splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE); 
causes a random endless block (if pipe is full) and
splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK);
will return 0 immediately if the TCP buffer is empty.

User application has no way to instruct splice() that socket should be in blocking mode
but pipe in nonblock more.

Many projects cannot use splice(tcp -> pipe) because of this flaw.
 
http://git.samba.org/?p=samba.git;a=history;f=source3/lib/recvfile.c;h=ea0159642137390a0f7e57a123684e6e63e47581;hb=HEAD
http://lkml.indiana.edu/hypermail/linux/kernel/0807.2/0687.html

Linus introduced  SPLICE_F_NONBLOCK in commit 29e350944fdc2dfca102500790d8ad6d6ff4f69d
(splice: add SPLICE_F_NONBLOCK flag )

  It doesn't make the splice itself necessarily nonblocking (because the
  actual file descriptors that are spliced from/to may block unless they
  have the O_NONBLOCK flag set), but it makes the splice pipe operations
  nonblocking.


Linus intention was clear : let SPLICE_F_NONBLOCK control the splice pipe mode only


This patch instruct tcp_splice_read() to use the underlying file O_NONBLOCK
flag, as other socket operations do.


Users will then call :

splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK ); 

to block on data coming from socket (if file is in blocking mode),
and not block on pipe output (to avoid deadlock)

First version of this patch was submitted by Octavian Purdila

Reported-by: Volker Lendecke <vl@samba.org>
Reported-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 21387eb..8cdfab6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -580,7 +580,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 
 	lock_sock(sk);
 
-	timeo = sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);
+	timeo = sock_rcvtimeo(sk, sock->file->f_flags & O_NONBLOCK);
 	while (tss.len) {
 		ret = __tcp_splice_read(sk, &tss);
 		if (ret < 0)
