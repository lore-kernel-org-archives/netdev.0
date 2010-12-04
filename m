From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 4 Dec 2010 22:45:19 +0800
Message-ID: <AANLkTimy_dK0uDCWqo3AZBKSvod+KnE6Om-CxrbFmPj+@mail.gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com> <4CFA3F01.20109@gmail.com>
 <1291472889.2159.18.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39007 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755114Ab0LDOpk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:45:40 -0500
Received: by fxm20 with SMTP id 20so3051709fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:45:39 -0800 (PST)
In-Reply-To: <1291472889.2159.18.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 4, 2010 at 10:28 PM, jamal <hadi@cyberus.ca> wrote:
> On Sat, 2010-12-04 at 14:15 +0100, Jarek Poplawski wrote:
>
>> > @@ -87,7 +83,7 @@ static void ri_tasklet(unsigned long dev)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(skb);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_dropped++;
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>
>> IMHO this line is a bugfix and should be a separate patch (for stabl=
e).
>
> Should be separate, yes.
> Bug? no.

If we breaks the loop when there are still skbs in tq and no skb in
rq, the skbs will be left in txq until new skbs are enqueued into rq.
In rare cases, no new skb is queued, then these skbs will stay in rq
forever.

-       if (__netif_tx_trylock(txq)) {
-               if ((skb =3D skb_peek(&dp->rq)) =3D=3D NULL) {
-                       dp->tasklet_pending =3D 0;
-                       if (netif_queue_stopped(_dev))
-                               netif_wake_queue(_dev);
-               } else {
-                       __netif_tx_unlock(txq);
-                       goto resched;
-               }
-               __netif_tx_unlock(txq);
-       } else {
-resched:
-               dp->tasklet_pending =3D 1;
-               tasklet_schedule(&dp->ifb_tasklet);
-       }
-


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
