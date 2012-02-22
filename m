From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] af_unix: MSG_TRUNC support for dgram sockets
Date: Wed, 22 Feb 2012 10:24:55 +0100
Message-ID: <1329902695.18384.101.camel@edumazet-laptop>
References: <1329287109.2555.44.camel@edumazet-laptop>
	 <CAFJW8X_1CNxe0PhxyaBjYSu0xNw0ymyDVFmsA0C5XsHK9F2D8Q@mail.gmail.com>
	 <1329309727.2437.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20120215.145511.1269077904303781879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: piergiorgio.beruto@gmail.com, netdev@vger.kernel.org,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38544 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877Ab2BVJZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 04:25:02 -0500
Received: by wgbdt10 with SMTP id dt10so6509542wgb.1
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 01:25:00 -0800 (PST)
In-Reply-To: <20120215.145511.1269077904303781879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Piergiorgio Beruto expressed the need to fetch size of first datagram in
queue for AF_UNIX sockets and suggested a patch against SIOCINQ ioctl.

I suggested instead to implement MSG_TRUNC support as a recv() input
flag, as already done for RAW, UDP & NETLINK sockets.

len = recv(fd, &byte, 1, MSG_PEEK | MSG_TRUNC);

MSG_TRUNC asks recv() to return the real length of the packet, even when
is was longer than the passed buffer.

There is risk that a userland application used MSG_TRUNC by accident
(since it had no effect on af_unix sockets) and this might break after
this patch.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Piergiorgio Beruto <piergiorgio.beruto@gmail.com>
CC: Michael Kerrisk <mtk.manpages@gmail.com>
---
 net/unix/af_unix.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 0be4d24..8ee85aa 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1845,7 +1845,7 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 		if (UNIXCB(skb).fp)
 			siocb->scm->fp = scm_fp_dup(UNIXCB(skb).fp);
 	}
-	err = size;
+	err = (flags & MSG_TRUNC) ? skb->len - skip : size;
 
 	scm_recv(sock, msg, siocb->scm, flags);
 
