From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] sock_diag: invert socket destroy broadcast check
Date: Fri, 24 Jun 2016 16:03:50 -0400
Message-ID: <1466798630-40553-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, kraig@google.com, eric.dumazet@gmail.com,
	ebiederm@xmission.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35964 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcFXUDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 16:03:54 -0400
Received: by mail-it0-f66.google.com with SMTP id h190so3691514ith.3
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 13:03:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Socket destruction is only broadcast for a socket sk if a diag
listener is registered and sk is not a kernel socket.

Invert the test to not even check for listeners for kernel sockets.

The sock_diag_has_destroy_listeners invocation dereferences
sock_net(sk), which for kernel sockets can be invalid as they do not
take a reference on the network namespace.

Fixes: b922622ec6ef ("sock_diag: don't broadcast kernel sockets")
Fixes: 26abe14379f8 ("net: Modify sk_alloc to not reference count the
                      netns of kernel sockets.")
Signed-off-by: Willem de Bruijn <willemb@google.com>

---

This patch fixes this immediate codepath. A broader issue of live
kernel sockets pointing to deleted namespaces may persist.

I observed skbs queued on a device queue in another namespace from
a kernel socket in SOCK_DEAD state with dangling sock_net(sk). Socket
refcnt is zero, but sk_wmem_alloc is not. (This was on an older
kernel, have not yet tried to reproduce on net).

It seems that we may need to reintroduce namespace reference counting
for kernel sockets (with two-stage deletion to avoid the circular
reference), scrub packets between namespaces, or reparent kernel
sockets to init_net on namespace destruction.
---
 net/core/sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 08bf97e..ba082b4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1473,7 +1473,7 @@ void sk_destruct(struct sock *sk)
 
 static void __sk_free(struct sock *sk)
 {
-	if (unlikely(sock_diag_has_destroy_listeners(sk) && sk->sk_net_refcnt))
+	if (unlikely(sk->sk_net_refcnt && sock_diag_has_destroy_listeners(sk)))
 		sock_diag_broadcast_destroy(sk);
 	else
 		sk_destruct(sk);
-- 
2.8.0.rc3.226.g39d4020
