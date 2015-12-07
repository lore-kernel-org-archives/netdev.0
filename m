From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: sctp: fix lockdep splat in sctp_v6_get_dst()
Date: Mon, 07 Dec 2015 08:25:21 -0800
Message-ID: <1449505521.25029.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151206002517.GB14181@codemonkey.org.uk>
	 <1449364386.25029.38.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151206013708.GA19228@codemonkey.org.uk>
	 <1449366988.25029.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36092 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932710AbbLGQZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 11:25:23 -0500
Received: by pacdm15 with SMTP id dm15so127197350pac.3
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 08:25:23 -0800 (PST)
In-Reply-To: <1449366988.25029.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While cooking the sctp np->opt rcu fixes, I forgot to move
one rcu_read_unlock() after the added rcu_dereference() in
sctp_v6_get_dst()

This gave lockdep warnings reported by Dave Jones.

Fixes: c836a8ba9386 ("ipv6: sctp: add rcu protection around np->opt")
Reported-by: Dave Jones <davej@codemonkey.org.uk>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sctp/ipv6.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index acb45b8c2a9d..d28c0b4c9128 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -323,14 +323,13 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 			}
 		}
 	}
-	rcu_read_unlock();
-
 	if (baddr) {
 		fl6->saddr = baddr->v6.sin6_addr;
 		fl6->fl6_sport = baddr->v6.sin6_port;
 		final_p = fl6_update_dst(fl6, rcu_dereference(np->opt), &final);
 		dst = ip6_dst_lookup_flow(sk, fl6, final_p);
 	}
+	rcu_read_unlock();
 
 out:
 	if (!IS_ERR_OR_NULL(dst)) {
