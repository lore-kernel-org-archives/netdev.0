From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: tcp_probe: use spin_lock_bh()
Date: Tue, 14 Feb 2017 17:11:14 -0800
Message-ID: <1487121074.8227.71.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170214172858.07d4393a@darkbook.lan.box>
         <20170214.144648.771654199689384203.davem@davemloft.net>
         <CAMyjOU+1CAC-VLL0JBABnbzWGZPLncqy6jXWQpVkd6vnXi-3pA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34657 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdBOBLS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 20:11:18 -0500
Received: by mail-io0-f194.google.com with SMTP id c80so10879030iod.1
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 17:11:18 -0800 (PST)
In-Reply-To: <CAMyjOU+1CAC-VLL0JBABnbzWGZPLncqy6jXWQpVkd6vnXi-3pA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_rcv_established() can now run in process context.

We need to disable BH while acquiring tcp probe spinlock,
or risk a deadlock.

Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>
---
 net/ipv4/tcp_probe.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index f6c50af24a64737672f7ede2ff41158bfed5f1b4..3d063eb3784828b142874c92fd2db026bea0f3b3 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -117,7 +117,7 @@ static void jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	     (fwmark > 0 && skb->mark == fwmark)) &&
 	    (full || tp->snd_cwnd != tcp_probe.lastcwnd)) {
 
-		spin_lock(&tcp_probe.lock);
+		spin_lock_bh(&tcp_probe.lock);
 		/* If log fills, just silently drop */
 		if (tcp_probe_avail() > 1) {
 			struct tcp_log *p = tcp_probe.log + tcp_probe.head;
@@ -157,7 +157,7 @@ static void jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 			tcp_probe.head = (tcp_probe.head + 1) & (bufsize - 1);
 		}
 		tcp_probe.lastcwnd = tp->snd_cwnd;
-		spin_unlock(&tcp_probe.lock);
+		spin_unlock_bh(&tcp_probe.lock);
 
 		wake_up(&tcp_probe.wait);
 	}
