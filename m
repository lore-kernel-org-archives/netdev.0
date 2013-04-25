From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] net: tun: release the reference of tun device in tun_recvmsg
Date: Thu, 25 Apr 2013 15:59:23 +0800
Message-ID: <1366876763-2671-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <201304250822.38944.a.miskiewicz@gmail.com>
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
	Gao feng <gaofeng@cn.fujitsu.com>
To: a.miskiewicz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:1658 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755342Ab3DYH56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 03:57:58 -0400
In-Reply-To: <201304250822.38944.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We forget to release the reference of tun device in tun_recvmsg.
bug introduced in commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
(tuntap: move socket to tun_file)

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/net/tun.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 0c9df2f..dcd0c19 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1471,14 +1471,17 @@ static int tun_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (!tun)
 		return -EBADFD;
 
-	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
-		return -EINVAL;
+	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC)) {
+		ret = -EINVAL;
+		goto out;
+	}
 	ret = tun_do_read(tun, tfile, iocb, m->msg_iov, total_len,
 			  flags & MSG_DONTWAIT);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
 		ret = flags & MSG_TRUNC ? ret : total_len;
 	}
+out:
 	tun_put(tun);
 	return ret;
 }
-- 
1.8.1.4
