From: Alban Crequy <alban.crequy@collabora.co.uk>
Subject: [PATCH] AF_UNIX: Implement SO_TIMESTAMP and SO_TIMETAMPNS on Unix sockets
Date: Mon,  4 Oct 2010 19:01:34 +0100
Message-ID: <1286215294-29166-1-git-send-email-alban.crequy@collabora.co.uk>
References: <20101004190049.783f14ab@chocolatine.cbg.collabora.co.uk>
Cc: Lennart Poettering <lennart@poettering.net>,
	Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([93.93.128.226]:43830 "EHLO
	bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756725Ab0JDSEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 14:04:24 -0400
In-Reply-To: <20101004190049.783f14ab@chocolatine.cbg.collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace applications can already request to receive timestamps with:
setsockopt(sockfd, SOL_SOCKET, SO_TIMESTAMP, ...)

Although setsockopt() returns zero (success), timestamps are not added to the
ancillary data. This patch fixes that on SOCK_DGRAM and SOCK_SEQPACKET Unix
sockets.

Signed-off-by: Alban Crequy <alban.crequy@collabora.co.uk>
---
 net/unix/af_unix.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 617bea4..bca0c1e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1697,6 +1697,9 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	if (err)
 		goto out_free;
 
+	if (sock_flag(sk, SOCK_RCVTSTAMP))
+		__sock_recv_timestamp(msg, sk, skb);
+
 	if (!siocb->scm) {
 		siocb->scm = &tmp_scm;
 		memset(&tmp_scm, 0, sizeof(tmp_scm));
-- 
1.7.1

