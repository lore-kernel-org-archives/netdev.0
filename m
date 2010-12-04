From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 4 Dec 2010 21:29:23 +0800
Message-ID: <AANLkTi=Wup0D0ZxTMa=VKkaawP4yAEP=rtw+CRwsJh3-@mail.gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com> <4CFA3F01.20109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39130 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754887Ab0LDN3p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 08:29:45 -0500
Received: by fxm20 with SMTP id 20so3017518fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 05:29:43 -0800 (PST)
In-Reply-To: <4CFA3F01.20109@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 4, 2010 at 9:15 PM, Jarek Poplawski <jarkao2@gmail.com> wro=
te:
> Changli Gao wrote:
>> tq is only used in ri_tasklet, so we move it from ifb_private to a
>> stack variable of ri_tasklet.
>>
>> skb_queue_splice_tail_init() is used instead of the open coded and s=
low
>> one.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0drivers/net/ifb.c | =A0 49 ++++++++++++--------------------------=
-----------
>> =A01 file changed, 12 insertions(+), 37 deletions(-)
>> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
>> index d1e362a..cd6e90d 100644
>> --- a/drivers/net/ifb.c
>> +++ b/drivers/net/ifb.c
>> @@ -39,9 +39,7 @@
>> =A0#define TX_Q_LIMIT =A0 =A032
>> =A0struct ifb_private {
>> =A0 =A0 =A0 struct tasklet_struct =A0 ifb_tasklet;
>> - =A0 =A0 int =A0 =A0 tasklet_pending;
>> =A0 =A0 =A0 struct sk_buff_head =A0 =A0 rq;
>> - =A0 =A0 struct sk_buff_head =A0 =A0 tq;
>> =A0};
>>
>> =A0static int numifbs =3D 2;
>> @@ -53,27 +51,25 @@ static int ifb_close(struct net_device *dev);
>>
>> =A0static void ri_tasklet(unsigned long dev)
>> =A0{
>> -
>> =A0 =A0 =A0 struct net_device *_dev =3D (struct net_device *)dev;
>> =A0 =A0 =A0 struct ifb_private *dp =3D netdev_priv(_dev);
>> =A0 =A0 =A0 struct net_device_stats *stats =3D &_dev->stats;
>> =A0 =A0 =A0 struct netdev_queue *txq;
>> =A0 =A0 =A0 struct sk_buff *skb;
>> + =A0 =A0 struct sk_buff_head tq;
>>
>> + =A0 =A0 __skb_queue_head_init(&tq);
>> =A0 =A0 =A0 txq =3D netdev_get_tx_queue(_dev, 0);
>> - =A0 =A0 if ((skb =3D skb_peek(&dp->tq)) =3D=3D NULL) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (__netif_tx_trylock(txq)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 while ((skb =3D skb_dequeu=
e(&dp->rq)) !=3D NULL) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_queue_=
tail(&dp->tq, skb);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __netif_tx_unlock(txq);
>> - =A0 =A0 =A0 =A0 =A0 =A0 } else {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* reschedule */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto resched;
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 if (!__netif_tx_trylock(txq)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 tasklet_schedule(&dp->ifb_tasklet);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 }
>> + =A0 =A0 skb_queue_splice_tail_init(&dp->rq, &tq);
>> + =A0 =A0 if (netif_tx_queue_stopped(txq))
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_tx_wake_queue(txq);
>> + =A0 =A0 __netif_tx_unlock(txq);
>>
>> - =A0 =A0 while ((skb =3D skb_dequeue(&dp->tq)) !=3D NULL) {
>> + =A0 =A0 while ((skb =3D __skb_dequeue(&tq)) !=3D NULL) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 from =3D G_TC_FROM(skb->tc_verd);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->tc_verd =3D 0;
>> @@ -87,7 +83,7 @@ static void ri_tasklet(unsigned long dev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(skb);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stats->tx_dropped++;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>
> IMHO this line is a bugfix and should be a separate patch (for stable=
).

It sounds reasonable.

>
> The rest looks OK to me but you could probably skip locking of dp->rq
> similarly to tq.
>

OK. Thanks.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
