From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next] tcp: Revert "tcp: tcp_probe: use spin_lock_bh()"
Date: Tue, 21 Feb 2017 06:21:47 -0800
Message-ID: <20170221142147.19154-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Ricardo Nabinger Sanchez <rnsanchez@gmail.com>,
        Eric Dumazet <edumazet@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36337 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752842AbdBUOWC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 09:22:02 -0500
Received: by mail-pg0-f41.google.com with SMTP id s67so25494471pgb.3
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 06:22:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit e70ac171658679ecf6bea4bbd9e9325cd6079d2b.

jtcp_rcv_established() is in fact called with hard irq being disabled.

Initial bug report from Ricardo Nabinger Sanchez [1] still needs
to be investigated, but does not look like a TCP bug.

[1] https://www.spinics.net/lists/netdev/msg420960.html

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: kernel test robot <xiaolong.ye@intel.com>
Cc: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>
---
 net/ipv4/tcp_probe.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 3d063eb3784828b142874c92fd2db026bea0f3b3..f6c50af24a64737672f7ede2ff41158bfed5f1b4 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -117,7 +117,7 @@ static void jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	     (fwmark > 0 && skb->mark == fwmark)) &&
 	    (full || tp->snd_cwnd != tcp_probe.lastcwnd)) {
 
-		spin_lock_bh(&tcp_probe.lock);
+		spin_lock(&tcp_probe.lock);
 		/* If log fills, just silently drop */
 		if (tcp_probe_avail() > 1) {
 			struct tcp_log *p = tcp_probe.log + tcp_probe.head;
@@ -157,7 +157,7 @@ static void jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			tcp_probe.head = (tcp_probe.head + 1) & (bufsize - 1);
 		}
 		tcp_probe.lastcwnd = tp->snd_cwnd;
-		spin_unlock_bh(&tcp_probe.lock);
+		spin_unlock(&tcp_probe.lock);
 
 		wake_up(&tcp_probe.wait);
 	}
-- 
2.11.0.483.g087da7b7c-goog
