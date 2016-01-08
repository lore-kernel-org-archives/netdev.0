From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: tcp: add rcu locking in tcp_v6_send_synack()
Date: Fri, 08 Jan 2016 09:35:51 -0800
Message-ID: <1452274551.8255.232.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160107153248.GA30472@codemonkey.org.uk>
	 <1452181973.8255.213.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35059 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754715AbcAHRfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 12:35:53 -0500
Received: by mail-pf0-f175.google.com with SMTP id 65so12488553pff.2
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 09:35:53 -0800 (PST)
In-Reply-To: <1452181973.8255.213.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

When first SYNACK is sent, we already hold rcu_read_lock(), but this
is not true if a SYNACK is retransmitted, as a timer (soft) interrupt
does not hold rcu_read_lock()

Fixes: 45f6fad84cc30 ("ipv6: add complete rcu protection around np->opt")
Reported-by: Dave Jones <davej@codemonkey.org.uk>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/tcp_ipv6.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 6b8a8a9091fa..bd100b47c717 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -462,8 +462,10 @@ static int tcp_v6_send_synack(const struct sock *sk, struct dst_entry *dst,
 		if (np->repflow && ireq->pktopts)
 			fl6->flowlabel = ip6_flowlabel(ipv6_hdr(ireq->pktopts));
 
+		rcu_read_lock();
 		err = ip6_xmit(sk, skb, fl6, rcu_dereference(np->opt),
 			       np->tclass);
+		rcu_read_unlock();
 		err = net_xmit_eval(err);
 	}
 
