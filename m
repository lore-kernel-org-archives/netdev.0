From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: add a missing barrier in tcp_tasklet_func()
Date: Wed, 21 Dec 2016 05:42:43 -0800
Message-ID: <1482327763.8944.26.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36173 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758444AbcLUNmp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 08:42:45 -0500
Received: by mail-pg0-f68.google.com with SMTP id w68so10386180pgw.3
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 05:42:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Madalin reported crashes happening in tcp_tasklet_func() on powerpc64

Before TSQ_QUEUED bit is cleared, we must ensure the changes done
by list_del(&tp->tsq_node); are committed to memory, otherwise
corruption might happen, as an other cpu could catch TSQ_QUEUED
clearance too soon.

We can notice that old kernels were immune to this bug, because
TSQ_QUEUED was cleared after a bh_lock_sock(sk)/bh_unlock_sock(sk)
section, but they could have missed a kick to write additional bytes,
when NIC interrupts for a given flow are spread to multiple cpus.

Affected TCP flows would need an incoming ACK or RTO timer to add more
packets to the pipe. So overall situation should be better now.

Fixes: b223feb9de2a ("tcp: tsq: add shortcut in tcp_tasklet_func()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Madalin Bucur <madalin.bucur@nxp.com>
Tested-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 net/ipv4/tcp_output.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b45101f3d2bd2e0f0077305a061add4f7ea0de27..31a255b555ad86a3537c077862e3ea38f9b44284 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -769,6 +769,7 @@ static void tcp_tasklet_func(unsigned long data)
 		list_del(&tp->tsq_node);
 
 		sk = (struct sock *)tp;
+		smp_mb__before_atomic();
 		clear_bit(TSQ_QUEUED, &sk->sk_tsq_flags);
 
 		if (!sk->sk_lock.owned &&
