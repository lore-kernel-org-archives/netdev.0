From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: tcp_make_synack() should clear skb->tstamp
Date: Thu, 09 Apr 2015 13:31:56 -0700
Message-ID: <1428611516.25985.275.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33951 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378AbbDIUb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 16:31:58 -0400
Received: by iget9 with SMTP id t9so2346227ige.1
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 13:31:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I noticed tcpdump was giving funky timestamps for locally
generated SYNACK messages on loopback interface.

11:42:46.938990 IP 127.0.0.1.48245 > 127.0.0.2.23850: S
945476042:945476042(0) win 43690 <mss 65495,nop,nop,sackOK,nop,wscale 7>

20:28:58.502209 IP 127.0.0.2.23850 > 127.0.0.1.48245: S
3160535375:3160535375(0) ack 945476043 win 43690 <mss
65495,nop,nop,sackOK,nop,wscale 7>

This is because we need to clear skb->tstamp before
entering lower stack, otherwise net_timestamp_check()
does not set skb->tstamp.

Fixes: 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1db253e36045..d520492ba698 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2929,6 +2929,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	}
 #endif
 
+	/* Do not fool tcpdump (if any), clean our debris */
+	skb->tstamp.tv64 = 0;
 	return skb;
 }
 EXPORT_SYMBOL(tcp_make_synack);
