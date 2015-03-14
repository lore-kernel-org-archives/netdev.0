From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] fix MSG_OOB test in caif_seqpkt_recvmsg()
Date: Sat, 14 Mar 2015 05:22:21 +0000
Message-ID: <20150314052221.GS29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49971 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbbCNFWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 01:22:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	It should be checking flags, not msg->msg_flags.  It's ->sendmsg()
instances that need to look for that in ->msg_flags, ->recvmsg() ones
(including the other ->recvmsg() instance in that file, as well as
unix_dgram_recvmsg() this one claims to be imitating) check in flags.
Braino had been introduced in commit dcda13 ("caif: Bugfix - use MSG_TRUNC
in receive") back in 2010, so it goes quite a while back.

Cc: stable@vger.kernel.org # 2.6.35
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 91aa225..1caa161 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -281,7 +281,7 @@ static int caif_seqpkt_recvmsg(struct socket *sock, struct msghdr *m,
 	int copylen;
 
 	ret = -EOPNOTSUPP;
-	if (m->msg_flags&MSG_OOB)
+	if (flags & MSG_OOB)
 		goto read_error;
 
 	skb = skb_recv_datagram(sk, flags, 0 , &ret);
