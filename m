From: Al Viro <viro@ftp.linux.org.uk>
Subject: [PATCH 1/4] fix endianness bug in l2cap_sock_listen()
Date: Fri, 27 Jul 2007 13:57:06 +0100
Message-ID: <E1IEPNS-0005RS-7o@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	marcel@holtmann.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:45115 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761962AbXG0M5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 08:57:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We loop through psm values, calling __l2cap_get_sock_by_addr(psm, ...)
until we get NULL; then we set ->psm of our socket to htobs(psm).
IOW, we find unused psm value and put it into our socket.  So far, so
good, but...  __l2cap_get_sock_by_addr() compares its argument with
->psm of sockets.  IOW, the entire thing works correctly only on
little-endian.  On big-endian we'll get "no socket with such psm"
on the first iteration, since we won't find a socket with ->psm == 0x1001.
We will happily conclude that 0x1001 is unused and slap htobs(0x1001)
(i.e. 0x110) into ->psm of our socket.  Of course, the next time around
the same thing will repeat and we'll just get a fsckload of sockets
with the same ->psm assigned.

Fix: pass htobs(psm) to __l2cap_get_sock_by_addr() there.  All other
callers are already passing little-endian values and all places that
store something in ->psm are storing little-endian.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/bluetooth/l2cap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 670ff95..b82cbdd 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -748,7 +748,7 @@ static int l2cap_sock_listen(struct socket *sock, int backlog)
 		write_lock_bh(&l2cap_sk_list.lock);
 
 		for (psm = 0x1001; psm < 0x1100; psm += 2)
-			if (!__l2cap_get_sock_by_addr(psm, src)) {
+			if (!__l2cap_get_sock_by_addr(htobs(psm), src)) {
 				l2cap_pi(sk)->psm   = htobs(psm);
 				l2cap_pi(sk)->sport = htobs(psm);
 				err = 0;
-- 
1.5.3.GIT

