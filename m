From: Misha Labjuk <spiked.yar@gmail.com>
Subject: Re: PROBLEM: pppol2tp over pppoe NULL pointer dereference
Date: Thu, 3 Nov 2011 02:35:41 +0400
Message-ID: <CAKpUy7Y794CJkAEtbsbTecbPq+KkniSTx4ftCncohzGsuJfk-w@mail.gmail.com>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
	<1320186916.4728.1.camel@edumazet-laptop>
	<CAKpUy7ZTpXtUDXB+NCxa4QBr3qiwo7aBW9DmUY8ADqO8FgrUpw@mail.gmail.com>
	<1320217652.30178.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52627 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907Ab1KBWfl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 18:35:41 -0400
Received: by iage36 with SMTP id e36so617884iag.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 15:35:41 -0700 (PDT)
In-Reply-To: <1320217652.30178.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks!!  Panic disappeared.

2011/11/2 Eric Dumazet <eric.dumazet@gmail.com>:
> OK thanks, could you try the following patch as well ?
>
> If we release reorder_q.lock, we must not keep a dangling pointer (tm=
p)
> and restart the whole loop.
>
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 34b2dde..bf8d50c 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -397,6 +397,7 @@ static void l2tp_recv_dequeue(struct l2tp_session=
 *session)
> =A0 =A0 =A0 =A0 * expect to send up next, dequeue it and any other
> =A0 =A0 =A0 =A0 * in-sequence packets behind it.
> =A0 =A0 =A0 =A0 */
> +start:
> =A0 =A0 =A0 =A0spin_lock_bh(&session->reorder_q.lock);
> =A0 =A0 =A0 =A0skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (time_after(jiffies, L2TP_SKB_CB(sk=
b)->expires)) {
> @@ -433,7 +434,7 @@ static void l2tp_recv_dequeue(struct l2tp_session=
 *session)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_bh(&session->reorder_q.loc=
k);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0l2tp_recv_dequeue_skb(session, skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_bh(&session->reorder_q.lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto start;
> =A0 =A0 =A0 =A0}
>
> =A0out:
>
