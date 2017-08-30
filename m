From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] kcm: do not attach PF_KCM sockets to avoid deadlock
Date: Wed, 30 Aug 2017 09:29:31 -0700
Message-ID: <1504110571.11498.120.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <tom@quantonium.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35059 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751416AbdH3Q3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 12:29:34 -0400
Received: by mail-pf0-f193.google.com with SMTP id g13so4622435pfm.2
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 09:29:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syzkaller had no problem to trigger a deadlock, attaching a KCM socket
to another one (or itself). (original syzkaller report was a very
confusing lockdep splat during a sendmsg())

It seems KCM claims to only support TCP, but no enforcement is done,
so we might need to add additional checks.

Fixes: ab7ac4eb9832 ("kcm: Kernel Connection Multiplexor module")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
 net/kcm/kcmsock.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 48e993b2dbcf1afae04968ed840e2e98c2cf6772..af4e76ac88ff0817398d1d7460a41f0cd5fe6f30 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1387,6 +1387,10 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	if (!csk)
 		return -EINVAL;
 
+	/* We must prevent loops or risk deadlock ! */
+	if (csk->sk_family == PF_KCM)
+		return -EOPNOTSUPP;
+
 	psock = kmem_cache_zalloc(kcm_psockp, GFP_KERNEL);
 	if (!psock)
 		return -ENOMEM;
