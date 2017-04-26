From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bpf: restore skb->sk before pskb_trim() call
Date: Wed, 26 Apr 2017 09:09:23 -0700
Message-ID: <1493222963.6453.77.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34512 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751473AbdDZQJ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 12:09:26 -0400
Received: by mail-pg0-f65.google.com with SMTP id t7so1064301pgt.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 09:09:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While testing a fix [1] in ___pskb_trim(), addressing the WARN_ON_ONCE()
in skb_try_coalesce() reported by Andrey, I found that we had an skb
with skb->sk set but no skb->destructor.

This invalidated heuristic found in commit 158f323b9868 ("net: adjust
skb->truesize in pskb_expand_head()") and in cited patch.

Considering the BUG_ON(skb->sk) we have in skb_orphan(), we should
restrain the temporary setting to a minimal section.

[1] https://patchwork.ozlabs.org/patch/755570/ 
    net: adjust skb->truesize in ___pskb_trim()

Fixes: 8f917bba0042 ("bpf: pass sk to helper functions")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
---
 net/core/filter.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 9a37860a80fc78378705b681ec3b0468824cbcf4..a253a6197e6b37a7ae2fe451c646b01c861a3e22 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -98,8 +98,8 @@ int sk_filter_trim_cap(struct sock *sk, struct sk_buff *skb, unsigned int cap)
 
 		skb->sk = sk;
 		pkt_len = bpf_prog_run_save_cb(filter->prog, skb);
-		err = pkt_len ? pskb_trim(skb, max(cap, pkt_len)) : -EPERM;
 		skb->sk = save_sk;
+		err = pkt_len ? pskb_trim(skb, max(cap, pkt_len)) : -EPERM;
 	}
 	rcu_read_unlock();
 
