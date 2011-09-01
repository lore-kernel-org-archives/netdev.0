From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH v2 -next] 6LoWPAN: fix skb_copy call
Date: Thu, 1 Sep 2011 16:34:54 +0400
Message-ID: <CAJmB2rDnzhxZ+++uFJeqzKGjt4q8k7iyn-XMxUKigfD2MEh6rQ@mail.gmail.com>
References: <1314879675-31989-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<1314881653-1104-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<1314878443.2823.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40830 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757191Ab1IAMfW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 08:35:22 -0400
In-Reply-To: <1314878443.2823.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

hmm, I think you are right.

=46irst 6LoWPAN implementation was developed as a part of MAC layer and
code was based on this layer approach. But now 6lowpan is
MAC-independent, it's just a netif_rx hook and looks like I missed
this moment during migration.

sorry for confusion.

With best regards,
Alexander

2011/9/1 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 01 septembre 2011 =E0 16:54 +0400, Alexander Smirnov a =E9cr=
it :
>> This patch fixes 2 issues in lowpan_skb_deliver function:
>> 1. Check for return status of skb_copy call;
>> 2. Use skb_copy with proper GFP flag depending on context.
>>
>> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
>> ---
>> =A0net/ieee802154/6lowpan.c | =A0 18 +++++++++++++++---
>> =A01 files changed, 15 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
>> index cf304cc..16100be 100644
>> --- a/net/ieee802154/6lowpan.c
>> +++ b/net/ieee802154/6lowpan.c
>> @@ -477,9 +477,15 @@ static int lowpan_skb_deliver(struct sk_buff *s=
kb, struct ipv6hdr *hdr)
>> =A0 =A0 =A0 struct sk_buff *new;
>> =A0 =A0 =A0 struct lowpan_dev_record *entry;
>> =A0 =A0 =A0 int stat =3D NET_RX_SUCCESS;
>> + =A0 =A0 gfp_t mask;
>>
>> - =A0 =A0 new =3D skb_copy_expand(skb, sizeof(struct ipv6hdr), skb_t=
ailroom(skb),
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
>> + =A0 =A0 if (in_interrupt())
>> + =A0 =A0 =A0 =A0 =A0 =A0 mask =3D GFP_ATOMIC;
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 mask =3D GFP_KERNEL;
>
> I am not sure to understand if lowpan_skb_deliver() can be called in
> pure process context. I feel we are in softirq handler or we have
> disabled BH, so GFP_ATOMIC is the only choice.
>
> If you are unsure, you could use following helper :
>
> =A0 =A0 =A0 =A0mask =3D gfp_any();
>
>> +
>> + =A0 =A0 new =3D skb_copy_expand(skb, sizeof(struct ipv6hdr),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 skb_tailroom(skb), mask);
>> =A0 =A0 =A0 kfree_skb(skb);
>>
>
>
