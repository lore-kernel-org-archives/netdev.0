From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: pppol2tp over pppoe NULL pointer dereference
Date: Wed, 02 Nov 2011 08:07:32 +0100
Message-ID: <1320217652.30178.1.camel@edumazet-laptop>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
	 <1320186916.4728.1.camel@edumazet-laptop>
	 <CAKpUy7ZTpXtUDXB+NCxa4QBr3qiwo7aBW9DmUY8ADqO8FgrUpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Misha Labjuk <spiked.yar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:35593 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813Ab1KBHHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 03:07:38 -0400
Received: by wyh15 with SMTP id 15so1145152wyh.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 00:07:37 -0700 (PDT)
In-Reply-To: <CAKpUy7ZTpXtUDXB+NCxa4QBr3qiwo7aBW9DmUY8ADqO8FgrUpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 novembre 2011 =C3=A0 09:04 +0400, Misha Labjuk a =C3=A9c=
rit :
> 2011/11/2 Eric Dumazet <eric.dumazet@gmail.com>:
> >
> > On what kind of NIC this is happening ?
> >
>=20
> Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit
> Ethernet controller (rev 02)
> Kernel driver in use: r8169

OK thanks, could you try the following patch as well ?

If we release reorder_q.lock, we must not keep a dangling pointer (tmp)
and restart the whole loop.

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
