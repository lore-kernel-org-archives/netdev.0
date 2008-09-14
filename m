From: Johann Baudy <johaahn@gmail.com>
Subject: [PATCH] sendfile() and UDP socket
Date: Sun, 14 Sep 2008 12:25:56 +0200
Message-ID: <1221387956.9204.7.camel@fry>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp7-g19.free.fr ([212.27.42.64]:39053 "EHLO smtp7-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992AbYINKZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Sep 2008 06:25:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Sendfile() over UDP socket are currently limited to ~ 64KBytes file (max cork.length).
Indeed, if you run sendfile() with a file size > 64KBytes over UDP socket, system call will stop and return ~64KBytes without sending anything on the network.
This patch is pushing ongoing frames when frames buffer is full, to prevent overflow.

Signed-off-by: Johann Baudy <johann.baudy@gmail.com>

 net/ipv4/udp.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8e42fbb..64e0857 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -743,7 +743,22 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 		 size_t size, int flags)
 {
 	struct udp_sock *up = udp_sk(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int ret;
+	int fragheaderlen;
+	struct ip_options *opt = NULL;
+
+	lock_sock(sk);
+	if (inet->cork.flags & IPCORK_OPT)
+		opt = inet->cork.opt;
+	fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
+
+	if (inet->cork.length + size >= 0xFFFF - fragheaderlen) {
+		ret = udp_push_pending_frames(sk);
+		if (ret)
+			goto out;
+	}
+	release_sock(sk);
 
 	if (!up->pending) {
 		struct msghdr msg = {	.msg_flags = flags|MSG_MORE };


