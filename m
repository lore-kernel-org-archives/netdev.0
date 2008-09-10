From: "Johann Baudy" <johaahn@gmail.com>
Subject: [PATCH] sendfile() and UDP socket
Date: Wed, 10 Sep 2008 14:39:55 +0200
Message-ID: <7e0dd21a0809100539r6fb7857cm3c74601bb8a29aa7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:60357 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbYIJMj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 08:39:56 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2498642wfd.4
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2008 05:39:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Sendfile() over UDP socket are currently limited to ~ 64KBytes file
(max cork.length).
Indeed, if you run sendfile() with a file size > 64KBytes over UDP
socket, system call will stop and return ~64KBytes without sending
anything on the network.
This patch is pushing ongoing frames when frames buffer is full, to
prevent overflow.

Signed-off-by: Johann Baudy <johann.baudy@gmail.com>

 net/ipv4/udp.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 56fcda3..d019e13 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -743,7 +743,22 @@ int udp_sendpage(struct sock *sk, struct page
*page, int offset,
                 size_t size, int flags)
 {
        struct udp_sock *up = udp_sk(sk);
+       struct inet_sock *inet = inet_sk(sk);
        int ret;
+       int fragheaderlen;
+       struct ip_options *opt = NULL;
+
+       lock_sock(sk);
+       if (inet->cork.flags & IPCORK_OPT)
+               opt = inet->cork.opt;
+       fragheaderlen = sizeof(struct iphdr) + (opt ? opt->optlen : 0);
+
+       if (inet->cork.length + size >= 0xFFFF - fragheaderlen) {
+               ret = udp_push_pending_frames(sk);
+               if (ret)
+                       goto out;
+       }
+       release_sock(sk);

        if (!up->pending) {
                struct msghdr msg = {   .msg_flags = flags|MSG_MORE };
