From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATH net] ipv4: keep skb->dst around in presence of IP options
Date: Sat, 04 Feb 2017 11:16:52 -0800
Message-ID: <1486235812.21871.145.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34415 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751142AbdBDTQz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 14:16:55 -0500
Received: by mail-it0-f68.google.com with SMTP id o185so4589120itb.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 11:16:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Andrey Konovalov got crashes in __ip_options_echo() when a NULL skb->dst
is accessed.

ipv4_pktinfo_prepare() should not drop the dst if (evil) IP options
are present.

We could refine the test to the presence of ts_needtime or srr,
but IP options are not often used, so let's be conservative.

Thanks to syzkaller team for finding this bug.

Fixes: d826eb14ecef ("ipv4: PKTINFO doesnt need dst reference")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/ipv4/ip_sockglue.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8a4409dd390aac7fcb88383af1550a2f967d..c4fcf9d713cca64a3afaec1628692739d9fa 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1243,7 +1243,14 @@ void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb)
 		pktinfo->ipi_ifindex = 0;
 		pktinfo->ipi_spec_dst.s_addr = 0;
 	}
-	skb_dst_drop(skb);
+	/* We need to keep the dst for __ip_options_echo()
+	 * We could restrict the test to opt.ts_needtime || opt.srr,
+	 * but the following is good enough as IP options are not often used.
+	 */
+	if (unlikely(IPCB(skb)->opt.optlen))
+		skb_dst_force(skb);
+	else
+		skb_dst_drop(skb);
 }
 
 int ip_setsockopt(struct sock *sk, int level,
