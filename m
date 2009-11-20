From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 10:12:18 +0800
Message-ID: <412e6f7f0911191812uf0abc61w2f0d44f4d71bd55@mail.gmail.com>
References: <4B05D8DC.7020907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f180.google.com ([209.85.216.180]:52219 "EHLO
	mail-px0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757731AbZKTCMM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 21:12:12 -0500
Received: by pxi10 with SMTP id 10so2086746pxi.33
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 18:12:18 -0800 (PST)
In-Reply-To: <4B05D8DC.7020907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 7:46 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 9977288..9e134f6 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2000,6 +2001,7 @@ gso:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rcu_read_lock_bh();
>
> + =C2=A0 =C2=A0 =C2=A0 skb->sending_cpu =3D cpu =3D smp_processor_id(=
);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0txq =3D dev_pick_tx(dev, skb);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0q =3D rcu_dereference(txq->qdisc);

I think assigning cpu to skb->sending_cpu just before calling
hard_start_xmit is better, because the CPU which dequeues the skb will
be another one.

>
> @@ -2024,8 +2026,6 @@ gso:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 Either shot noqueue qdisc, it is e=
ven simpler 8)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (dev->flags & IFF_UP) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int cpu =3D smp_pr=
ocessor_id(); /* ok because BHs are off */
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (txq->xmit_=
lock_owner !=3D cpu) {
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0HARD_TX_LOCK(dev, txq, cpu);
> @@ -2967,7 +2967,7 @@ static void net_rx_action(struct softirq_action=
 *h)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_irq_enable();
> -
> + =C2=A0 =C2=A0 =C2=A0 xps_flush();

If there isn't any new skbs, the memory will be hold forever. I know
you want to eliminate unnecessary IPI, how about sending IPI only when
the remote xps_pcpu_queues are changed from empty to nonempty?


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
