From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix return value for partial writes
Date: Wed, 02 Nov 2016 14:41:50 -0700
Message-ID: <1478122910.7065.396.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34926 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757573AbcKBVlw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 17:41:52 -0400
Received: by mail-pf0-f195.google.com with SMTP id i88so2753649pfk.2
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 14:41:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After my commit, tcp_sendmsg() might restart its loop after
processing socket backlog.

If sk_err is set, we blindly return an error, even though we
copied data to user space before.

We should instead return number of bytes that could be copied,
otherwise user space might resend data and corrupt the stream.

This might happen if another thread is using recvmsg(MSG_ERRQUEUE)
to process timestamps.

Issue was diagnosed by Soheil and Willem, big kudos to them !

Fixes: d41a69f1d390f ("tcp: make tcp_sendmsg() aware of socket backlog")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3251fe71f39f..19e1468bf8ea 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1164,7 +1164,7 @@ int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 
 	err = -EPIPE;
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
-		goto out_err;
+		goto do_error;
 
 	sg = !!(sk->sk_route_caps & NETIF_F_SG);
 
