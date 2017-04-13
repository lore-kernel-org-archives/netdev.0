From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: [PATCH net-next] l2tp: device MTU setup, tunnel socket needs a
 lock
Date: Wed, 12 Apr 2017 18:31:04 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1704121825410.1923@nelson51.eng.vyatta.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kleptog@svana.org, jchapman@katalix.com, davem@redhat.com,
        nprachan@brocade.com, rshearma@brocade.com,
        stephen@networkplumber.org, sdietric@brocade.com,
        ciwillia@brocade.com, lboccass@brocade.com, dfawcus@brocade.com,
        bhong@brocade.com, jblunck@brocade.com, g.nault@alphalink.fr,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35708 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755242AbdDMBbF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 21:31:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The MTU overhead calculation in L2TP device set-up
merged via commit b784e7ebfce8cfb16c6f95e14e8532d0768ab7ff
needs to be adjusted to lock the tunnel socket while
referencing the sub-data structures to derive the
socket's IP overhead.

Reported-by: Guillaume Nault <g.nault@alphalink.fr>
Tested-by: Guillaume Nault <g.nault@alphalink.fr>
Signed-off-by: R. Parameswaran <rparames@brocade.com>
---
 include/linux/net.h | 2 +-
 net/l2tp/l2tp_eth.c | 2 ++
 net/socket.c        | 2 +-
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index a42fab2..abcfa46 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -298,7 +298,7 @@ int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
 int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how);
 
-/* Following routine returns the IP overhead imposed by a socket.  */
+/* Routine returns the IP overhead imposed by a (caller-protected) socket. */
 u32 kernel_sock_ip_overhead(struct sock *sk);
 
 #define MODULE_ALIAS_NETPROTO(proto) \
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 138566a..b722d55 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -225,7 +225,9 @@ static void l2tp_eth_adjust_mtu(struct l2tp_tunnel *tunnel,
 		dev->needed_headroom += session->hdr_len;
 		return;
 	}
+	lock_sock(tunnel->sock);
 	l3_overhead = kernel_sock_ip_overhead(tunnel->sock);
+	release_sock(tunnel->sock);
 	if (l3_overhead == 0) {
 		/* L3 Overhead couldn't be identified, this could be
 		 * because tunnel->sock was NULL or the socket's
diff --git a/net/socket.c b/net/socket.c
index eea9970..c2564eb 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -3360,7 +3360,7 @@ EXPORT_SYMBOL(kernel_sock_shutdown);
 /* This routine returns the IP overhead imposed by a socket i.e.
  * the length of the underlying IP header, depending on whether
  * this is an IPv4 or IPv6 socket and the length from IP options turned
- * on at the socket.
+ * on at the socket. Assumes that the caller has a lock on the socket.
  */
 u32 kernel_sock_ip_overhead(struct sock *sk)
 {
-- 
2.1.4
