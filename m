From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] sockopt: Make SO_BINDTODEVICE readable
Date: Fri, 19 Oct 2012 13:55:56 +0400
Message-ID: <508123AC.5080208@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:28611 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756911Ab2JSJ4F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 05:56:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SO_BINDTODEVICE option is the only SOL_SOCKET one that can be set, but
cannot be get via sockopt API. The only way we can find the device id a
socket is bound to is via sock-diag interface. But the diag works only on
hashed sockets, while the opt in question can be set for yet unhashed one.

That said, in order to know what device a socket is bound to (we do want
to know this in checkpoint-restore project) I propose to make this option
getsockopt-able and report the respective device index.

Another solution to the problem might be to teach the sock-diag reporting
info on unhashed sockets. Should I go this way instead?

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/net/core/sock.c b/net/core/sock.c
index 8a146cf..c49412c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1074,6 +1074,9 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 	case SO_NOFCS:
 		v.val = sock_flag(sk, SOCK_NOFCS);
 		break;
+	case SO_BINDTODEVICE:
+		v.val = sk->sk_bound_dev_if;
+		break;
 	default:
 		return -ENOPROTOOPT;
 	}
