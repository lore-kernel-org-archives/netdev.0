From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: adjust skb->truesize in ___pskb_trim()
Date: Wed, 26 Apr 2017 09:07:46 -0700
Message-ID: <1493222866.6453.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35188 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752029AbdDZQHs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 12:07:48 -0400
Received: by mail-pf0-f193.google.com with SMTP id a188so1039503pfa.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 09:07:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Andrey found a way to trigger the WARN_ON_ONCE(delta < len) in
skb_try_coalesce() using syzkaller and a filter attached to a TCP
socket.

As we did recently in commit 158f323b9868 ("net: adjust skb->truesize in
pskb_expand_head()") we can adjust skb->truesize from ___pskb_trim(),
via a call to skb_condense().

If all frags were freed, then skb->truesize can be recomputed.

This call can be done if skb is not yet owned, or destructor is
sock_edemux().

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/core/skbuff.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f86bf69cfb8d8bc17262cdba5d9f57a4726cd476..f1d04592ace02f32efa6e05df89c9a5e0023157f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1576,6 +1576,8 @@ int ___pskb_trim(struct sk_buff *skb, unsigned int len)
 		skb_set_tail_pointer(skb, len);
 	}
 
+	if (!skb->sk || skb->destructor == sock_edemux)
+		skb_condense(skb);
 	return 0;
 }
 EXPORT_SYMBOL(___pskb_trim);
