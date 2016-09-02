From: Dave Jones <davej@codemonkey.org.uk>
Subject: ipv6: release dst in ping_v6_sendmsg
Date: Fri, 2 Sep 2016 14:39:50 -0400
Message-ID: <20160902183950.p3iv25jnuwmq74sg@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:37736 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752253AbcIBSjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 14:39:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neither the failure or success paths of ping_v6_sendmsg release
the dst it acquires.  This leads to a flood of warnings from
"net/core/dst.c:288 dst_release" on older kernels that
don't have 8bf4ada2e21378816b28205427ee6b0e1ca4c5f1 backported.

That patch optimistically hoped this had been fixed post 3.10, but
it seems at least one case wasn't, where I've seen this triggered
a lot from machines doing unprivileged icmp sockets.

Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 0900352c924c..0e983b694ee8 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -126,8 +126,10 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	rt = (struct rt6_info *) dst;
 
 	np = inet6_sk(sk);
-	if (!np)
-		return -EBADF;
+	if (!np) {
+		err = -EBADF;
+		goto dst_err_out;
+	}
 
 	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
 		fl6.flowi6_oif = np->mcast_oif;
@@ -163,6 +165,9 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	}
 	release_sock(sk);
 
+dst_err_out:
+	dst_release(dst);
+
 	if (err)
 		return err;
 
