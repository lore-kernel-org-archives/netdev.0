From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][PPPOL2TP] add missing sock_put() in
	pppol2tp_tunnel_closeall()
Date: Wed, 27 Feb 2008 11:48:37 +0000
Message-ID: <20080227114837.GA5795@ff.dom.local>
References: <20080225215837.GA3281@ami.dom.local> <47C402A2.8040401@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:32043 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbYB0Lre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 06:47:34 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2172132fga.17
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2008 03:47:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47C402A2.8040401@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And here is one more similar BTW fix.

Jarek P.

-------------->

Subject: [PPPOL2TP] add missing sock_put() in pppol2tp_tunnel_closeall()

Every skb removed from session->reorder_q needs sock_put().


Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 drivers/net/pppol2tp.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index e0b072d..ee9e2a7 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -1110,6 +1110,8 @@ static void pppol2tp_tunnel_closeall(struct pppol2tp_tunnel *tunnel)
 	for (hash = 0; hash < PPPOL2TP_HASH_SIZE; hash++) {
 again:
 		hlist_for_each_safe(walk, tmp, &tunnel->session_hlist[hash]) {
+			struct sk_buff *skb;
+
 			session = hlist_entry(walk, struct pppol2tp_session, hlist);
 
 			sk = session->sock;
@@ -1138,7 +1140,10 @@ again:
 			/* Purge any queued data */
 			skb_queue_purge(&sk->sk_receive_queue);
 			skb_queue_purge(&sk->sk_write_queue);
-			skb_queue_purge(&session->reorder_q);
+			while ((skb = skb_dequeue(&session->reorder_q))) {
+				kfree_skb(skb);
+				sock_put(sk);
+			}
 
 			release_sock(sk);
 			sock_put(sk);
