From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: pppol2tp over pppoe NULL pointer dereference
Date: Thu, 03 Nov 2011 09:47:44 +0100
Message-ID: <1320310064.2344.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
	 <1320186916.4728.1.camel@edumazet-laptop>
	 <CAKpUy7ZTpXtUDXB+NCxa4QBr3qiwo7aBW9DmUY8ADqO8FgrUpw@mail.gmail.com>
	 <1320217652.30178.1.camel@edumazet-laptop>
	 <CAKpUy7Y794CJkAEtbsbTecbPq+KkniSTx4ftCncohzGsuJfk-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Misha Labjuk <spiked.yar@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41178 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755679Ab1KCIrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 04:47:49 -0400
Received: by wyh15 with SMTP id 15so942859wyh.19
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2011 01:47:48 -0700 (PDT)
In-Reply-To: <CAKpUy7Y794CJkAEtbsbTecbPq+KkniSTx4ftCncohzGsuJfk-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 novembre 2011 =C3=A0 02:35 +0400, Misha Labjuk a =C3=A9crit=
 :
> Thanks!!  Panic disappeared.
>=20

Here is the official patch submission again (not mangled this time),
thanks !

[PATCH] l2tp: fix race in l2tp_recv_dequeue()

Misha Labjuk reported panics occurring in l2tp_recv_dequeue()

If we release reorder_q.lock, we must not keep a dangling pointer (tmp)=
,
since another thread could manipulate reorder_q.

Instead we must restart the scan at beginning of list.

Reported-by: Misha Labjuk <spiked.yar@gmail.com>
Tested-by: Misha Labjuk <spiked.yar@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/l2tp/l2tp_core.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 34b2dde..bf8d50c 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -397,6 +397,7 @@ static void l2tp_recv_dequeue(struct l2tp_session *=
session)
 	 * expect to send up next, dequeue it and any other
 	 * in-sequence packets behind it.
 	 */
+start:
 	spin_lock_bh(&session->reorder_q.lock);
 	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
 		if (time_after(jiffies, L2TP_SKB_CB(skb)->expires)) {
@@ -433,7 +434,7 @@ static void l2tp_recv_dequeue(struct l2tp_session *=
session)
 		 */
 		spin_unlock_bh(&session->reorder_q.lock);
 		l2tp_recv_dequeue_skb(session, skb);
-		spin_lock_bh(&session->reorder_q.lock);
+		goto start;
 	}
=20
 out:
