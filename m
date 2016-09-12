From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH] net: inet: diag: Fix an error handling
Date: Mon, 12 Sep 2016 08:02:13 +0200
Message-ID: <1473660133-9195-1-git-send-email-christophe.jaillet@wanadoo.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If 'inet_diag_lock_handler()' returns an error, we should not call
'inet_diag_unlock_handler()' on it.
'handler' is not a valid mutexc in this case.

This has been spotted with the folowing coccinelle script:
////////////////////////////
@@
expression x;
identifier f;
@@

*   if (IS_ERR(x))
    {
       ...
*      f(<+... x ...+>);
       ...
    }

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 net/ipv4/inet_diag.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index abfbe492ebfe..795af25cf84c 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -1134,7 +1134,6 @@ int inet_diag_handler_get_info(struct sk_buff *skb, struct sock *sk)
 
 	handler = inet_diag_lock_handler(sk->sk_protocol);
 	if (IS_ERR(handler)) {
-		inet_diag_unlock_handler(handler);
 		nlmsg_cancel(skb, nlh);
 		return PTR_ERR(handler);
 	}
-- 
2.7.4
