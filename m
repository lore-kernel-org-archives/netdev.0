From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: accept u8 in IP_TOS ancillary data
Date: Wed, 07 Sep 2016 21:52:56 -0700
Message-ID: <1473310376.15733.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Francesco Fusco <ffusco@redhat.com>,
        Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34592 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751688AbcIHEw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 00:52:59 -0400
Received: by mail-pa0-f68.google.com with SMTP id gi6so1854777pac.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 21:52:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit f02db315b8d8 ("ipv4: IP_TOS and IP_TTL can be specified as
ancillary data") Francesco added IP_TOS values specified as integer.

However, kernel sends to userspace (at recvmsg() time) an IP_TOS value
in a single byte, when IP_RECVTOS is set on the socket.

It can be very useful to reflect all ancillary options as given by the
kernel in a subsequent sendmsg(), instead of aborting the sendmsg() with
EINVAL after Francesco patch.

So this patch extends IP_TOS ancillary to accept an u8, so that an UDP
server can simply reuse same ancillary block without having to mangle
it.

Jesper can then augment
https://github.com/netoptimizer/network-testing/blob/master/src/udp_example02.c
to add TOS reflection ;)

Fixes: f02db315b8d8 ("ipv4: IP_TOS and IP_TTL can be specified as ancillary data")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Francesco Fusco <ffusco@redhat.com> 
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/ipv4/ip_sockglue.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 71a52f4d4cffba2db9353f43dc817689bf4fab10..af4919792b6a812041dcb18ff30aa8b27482c7a2 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -284,9 +284,12 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
 			ipc->ttl = val;
 			break;
 		case IP_TOS:
-			if (cmsg->cmsg_len != CMSG_LEN(sizeof(int)))
+			if (cmsg->cmsg_len == CMSG_LEN(sizeof(int)))
+				val = *(int *)CMSG_DATA(cmsg);
+			else if (cmsg->cmsg_len == CMSG_LEN(sizeof(u8)))
+				val = *(u8 *)CMSG_DATA(cmsg);
+			else
 				return -EINVAL;
-			val = *(int *)CMSG_DATA(cmsg);
 			if (val < 0 || val > 255)
 				return -EINVAL;
 			ipc->tos = val;
