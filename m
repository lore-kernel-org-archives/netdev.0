From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 5/5] net: add skb.old_queue_mapping
Date: Tue, 14 Dec 2010 07:58:52 +0800
Message-ID: <AANLkTinz-3HWnin8OhxxLuCncKgU_Fh8Wq9CcGe2jjXE@mail.gmail.com>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
 <1292251414-5154-5-git-send-email-xiaosuo@gmail.com> <1292259412.2759.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:39728 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756872Ab0LMX7O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 18:59:14 -0500
Received: by fxm18 with SMTP id 18so64836fxm.2
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 15:59:13 -0800 (PST)
In-Reply-To: <1292259412.2759.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 12:56 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le lundi 13 d=E9cembre 2010 =E0 22:43 +0800, Changli Gao a =E9crit :
>> For the skbs returned from ifb, we should use the queue_mapping
>> saved before ifb.
>>
>> We save old queue_mapping in old_queue_mapping just before calling
>> dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
>> just before reinjecting the skb.
>>
>> dev_pick_tx() use the current queue_mapping for the skbs reinjected
>> by ifb.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>> ---
>> =A0drivers/net/ifb.c =A0 =A0 =A0| =A0 =A01 +
>> =A0include/linux/skbuff.h | =A0 =A03 +++
>> =A0net/core/dev.c =A0 =A0 =A0 =A0 | =A0 =A05 +++++
>> =A0net/sched/act_mirred.c | =A0 =A01 +
>> =A04 files changed, 10 insertions(+)
>> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
>> index 16c767b..481e4b1 100644
>> --- a/drivers/net/ifb.c
>> +++ b/drivers/net/ifb.c
>> @@ -95,6 +95,7 @@ static void ri_tasklet(unsigned long _dev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64_stats_update_end(&qp->syncp);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->skb_iif =3D dev->ifindex;
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb->queue_mapping =3D skb->old_queue_mapp=
ing;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (from & AT_EGRESS) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_queue_xmit(skb);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (from & AT_INGRESS) {
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 19f37a6..2ce2a96 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -403,6 +403,9 @@ struct sk_buff {
>> =A0 =A0 =A0 };
>>
>> =A0 =A0 =A0 __u16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vlan_tci;
>> +#ifdef CONFIG_NET_CLS_ACT
>> + =A0 =A0 __u16 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 old_queue_mappin=
g;
>> +#endif
>>
>
> Are you sure we need this field here ? Why not using cb[] for example=
 ?
>

skb->cb can only be used in the same layer, so we can't use it to save
a value crossing layers. A quick grep finds sch_netem just uses
skb->cb. Maybe we can put all the skb->cb in the qdisc layer and
old_queue_mapping in a structure as a new skb->cb. Is it OK? Thanks.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
