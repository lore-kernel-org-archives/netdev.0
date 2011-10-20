From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [IEEE802.15.4][6LoWPAN] draft for fragmentation support
Date: Thu, 20 Oct 2011 16:50:30 +0400
Message-ID: <CAJmB2rCe3BJKD07TOSyAT0vbDq_K1VHLOtECqeOMzaTsg3DokA@mail.gmail.com>
References: <20111020111718.GA32181@avtobot.ww600.siemens.net>
	<1319114385.3781.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jonsmirl@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:46046 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251Ab1JTMub convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 08:50:31 -0400
Received: by gyb13 with SMTP id 13so2736999gyb.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 05:50:30 -0700 (PDT)
In-Reply-To: <1319114385.3781.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

thank you for the replies. And another question I forgot to ask:

when I send fragments, I still have original skb buffer. What should I
do with it, is there any
"proper/good" ways to drop it? Because I've already fragmented it and
do not need to send
original skb to queue.

Thank you,
Alexander

2011/10/20 Eric Dumazet <eric.dumazet@gmail.com>:
> Le jeudi 20 octobre 2011 =E0 15:17 +0400, Alexander Smirnov a =E9crit=
 :
>> Hello everybody,
>>
>> below is the patch which adds support for fragmentation in 6LoWPAN
>> point to point networks. This activity needs because of difference
>> in MTU: 1280 ipv6 and 128 ieee802.15.4
>>
>> This patch is just a draft. Could anyone please look at
>> it and let me know your opinion.
>>
>
> I removed janitor list, since this patch is certainly not a janitor o=
ne.
>
>> The most doubtful moments for me are:
>> 1. Should the list 'frag_list' and the mutex 'flist_lock' be
>> included into dev private data?
>
> =A0 =A0 =A0 =A0The mutex is wrong, you need a spinlock since run from=
 softirq handler.
> =A0 =A0 =A0 =A0Allocations should use GFP_ATOMIC for same reason.
>
>> 2. Can I use 'dev_queue_xmit' to send fragments to queue?
>
> =A0 =A0 =A0 =A0Well, it is not very clean, but it seems there is no a=
lternative
>
>> 3. Creating new 'skb' instead of copying and modifying main one.
>
> =A0 =A0 =A0 =A0You cant do that without making sure you own the skb a=
nd its data.
> =A0 =A0 =A0 =A0Think about a sniffer running...
>
>
> 4) No limitation on number of in-flight fragments.
> You can consume lot of ram and have a list with 65536 elements...
>
>
>
>
>
>> =A0net/ieee802154/6lowpan.c | =A0286
>> +++++++++++++++++++++++++++++++++++++++++++++-
>> =A0net/ieee802154/6lowpan.h | =A0 =A03 +
>> =A02 files changed, 288 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
>> index 96877bd..1923ec7 100644
>> --- a/net/ieee802154/6lowpan.c
>> +++ b/net/ieee802154/6lowpan.c
>> @@ -113,6 +113,24 @@ struct lowpan_dev_record {
>> =A0 =A0 =A0 =A0 struct list_head list;
>> =A0};
>>
>> +struct lowpan_fragment {
>> + =A0 =A0 =A0 u8 in_progress; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* ass=
embling is in progress
>> */
>> + =A0 =A0 =A0 struct sk_buff *skb; =A0 =A0 =A0 =A0 =A0 =A0/* skb to =
be assembled */
>> + =A0 =A0 =A0 u8 *data; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
/* data to be stored */
>> + =A0 =A0 =A0 struct mutex lock; =A0 =A0 =A0 =A0 =A0 =A0 =A0/* concu=
rency lock */
>> + =A0 =A0 =A0 u16 length; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*=
 frame length to be assemled
>> */
>> + =A0 =A0 =A0 u32 bytes_rcv; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* b=
ytes received */
>> + =A0 =A0 =A0 u16 tag; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
/* current fragment tag */
>> + =A0 =A0 =A0 struct timer_list timer; =A0 =A0 =A0 =A0/* assembling =
timer */
>> + =A0 =A0 =A0 struct list_head list; =A0 =A0 =A0 =A0 =A0/* fragments=
 list handler
>> */
>> +};
>> +
>> +static unsigned short fragment_tag;
>> +
>> +/* TODO: bind mutex and list to device */
>> +static LIST_HEAD(lowpan_fragments);
>> +struct mutex flist_lock;
>> +
>> =A0static inline struct
>> =A0lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
>> =A0{
>> @@ -244,6 +262,18 @@ static u8 lowpan_fetch_skb_u8(struct sk_buff
>> *skb)
>> =A0 =A0 =A0 =A0 return ret;
>> =A0}
>>
>> +static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
>> +{
>> + =A0 =A0 =A0 u16 ret;
>> +
>> + =A0 =A0 =A0 BUG_ON(skb->len < 2);
>>
>
> =A0 =A0 =A0 =A0Hmm, check pskb_may_pull(skb, 2), or in caller.
>
> =A0 =A0 =A0 =A0skb->len >=3D 2 doesnt mean you can access to skb->dat=
a[0] and
> skb->data[1] : Data might be on a fragment, not on skb head.
>
>> +
>> + =A0 =A0 =A0 ret =3D skb->data[0] | (skb->data[1] << 8);
>> + =A0 =A0 =A0 skb_pull(skb, 2);
>> + =A0 =A0 =A0 return ret;
>> +}
>> +
>> +static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_devi=
ce
>> *dev);
>> =A0static int lowpan_header_create(struct sk_buff *skb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct net_de=
vice *dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned shor=
t type, const void *_daddr,
>> @@ -467,9 +497,102 @@ static int lowpan_header_create(struct sk_buff
>> *skb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(&(sa.hwaddr), saddr, 8);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mac_cb(skb)->flags =3D IEEE802154_FC=
_TYPE_DATA;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* frame fragmentation */
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* if payload + mac header doesn't f=
it MTU-sized frame
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we need to fragment it.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb->len > (127 - 24)) { /* MTU -
>> MAC_HEADER_LENGTH */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *fr_skb=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 b_sent =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned short payload=
_len =3D skb->len;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int stat =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("%s: the fram=
e is too big (0x%x),"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"fr=
agmentation needed, using tag =3D 0x
>> %x\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__f=
unc__, payload_len, fragment_tag);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fr_skb =3D skb_copy(sk=
b, GFP_KERNEL);
>>
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GFP_ATOMIC
>>
> And I wonder why you skb_copy(). You are not allowed to change skb li=
ke
> that. ( when you later skb_push(fr_skb, 4), you are modifying this sk=
b
> data too...)
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!fr_skb)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto e=
rror;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* 40-bit - fragment d=
ispatch size */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head =3D kzalloc(5, GF=
P_KERNEL);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GFP_ATOMIC
>
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!head)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto e=
rror;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* first fagment heade=
r */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head[0] =3D LOWPAN_DIS=
PATCH_FRAG1 | (payload_len
>> & 0x7);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head[1] =3D (payload_l=
en >> 3) & 0xff;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head[2] =3D fragment_t=
ag & 0xff;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head[3] =3D fragment_t=
ag >> 8;
>> +
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lowpan_raw_dump_inline=
(__func__, "first
>> header",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head, 4);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(skb_push(fr_skb=
, 4), head, 4);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_trim(fr_skb, LOWPA=
N_FRAG_SIZE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_hard_header(fr_skb=
,
>> lowpan_dev_info(dev)->real_dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 type, =
(void *)&da, (void *)&sa,
>> fr_skb->len);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* send fragment to de=
v queue */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_queue_xmit(fr_skb)=
;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* next fragments head=
ers */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head[0] |=3D 0x20;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lowpan_raw_dump_inline=
(__func__, "next
>> headers",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head, 5);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (b_sent < payloa=
d_len) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* not=
 the first fragment */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (b_=
sent)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 skb_pull(skb,
>> LOWPAN_FRAG_SIZE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_deb=
ug("%s: preparing fragment %d
>> \n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 __func__, b_sent /
>> LOWPAN_FRAG_SIZE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* c=
reate copy of current buffer and
>> trim it
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* d=
own to fragment size
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fr_skb=
 =3D skb_copy(skb, GFP_KERNEL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!f=
r_skb)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 goto error;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_tr=
im(fr_skb, LOWPAN_FRAG_SIZE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* add=
 fragment header */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 head[4=
] =3D b_sent / 8;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy=
(skb_push(fr_skb, 5), head, 5);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 b_sent=
 +=3D LOWPAN_FRAG_SIZE;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lowpan=
_raw_dump_table(__func__,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
"fragment data", fr_skb->data,
>> fr_skb->len);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat =3D=
 dev_hard_header(fr_skb,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 lowpan_dev_info(dev)->real_dev, type,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 (void *)&da, (void *)&sa,
>> fr_skb->len);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_qu=
eue_xmit(fr_skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TODO: what's the co=
rrect way to skip
>> default skb? */
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fragment_tag++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return stat;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return dev_hard_header(skb,
>> lowpan_dev_info(dev)->real_dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 type=
, (void *)&da, (void *)&sa,
>> skb->len);
>> =A0 =A0 =A0 =A0 }
>> +error:
>> + =A0 =A0 =A0 kfree_skb(skb);
>> + =A0 =A0 =A0 return -ENOMEM;
>> =A0}
>>
>> =A0static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr
>> *hdr)
>> @@ -511,6 +634,23 @@ static int lowpan_skb_deliver(struct sk_buff
>> *skb, struct ipv6hdr *hdr)
>> =A0 =A0 =A0 =A0 return stat;
>> =A0}
>>
>> +static void lowpan_fragment_timer_expired(unsigned long tag)
>> +{
>> + =A0 =A0 =A0 struct lowpan_fragment *entry, *tmp;
>> +
>> + =A0 =A0 =A0 pr_debug("%s: timer expired for frame with tag %lu\n",
>> __func__, tag);
>> +
>> + =A0 =A0 =A0 mutex_lock(&flist_lock);
>>
>>
> =A0 =A0 =A0 =A0A mutex_lock() is not allowed in this context (softirq=
).
> You must use a spinlock.
>>
>>
>> + =A0 =A0 =A0 list_for_each_entry_safe(entry, tmp, &lowpan_fragments=
, list)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->tag =3D=3D tag) {
>>
>>
> =A0 =A0 =A0 =A0Since you have a timer per entry, instead of doing a l=
ookup to find
> 'tag', you could just say 'tag' is the pointer to your "struct
> lowpan_fragment"
>
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&entry->list)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(entry->data);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(entry);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 mutex_unlock(&flist_lock);
>> +}
>>
>
> =A0 =A0 =A0 =A0struct lowpan_fragment *entry =3D (struct lowpan_fragm=
ent *)tag;
> =A0 =A0 =A0 =A0spin_lock();
> =A0 =A0 =A0 =A0list_del(&entry->list);
> =A0 =A0 =A0 =A0kfree(entry->data);
> =A0 =A0 =A0 =A0kfree(entry);
> =A0 =A0 =A0 =A0spin_unlock();
>>
>> +
>> =A0static int
>> =A0lowpan_process_data(struct sk_buff *skb)
>> =A0{
>> @@ -525,6 +665,139 @@ lowpan_process_data(struct sk_buff *skb)
>> =A0 =A0 =A0 =A0 if (skb->len < 2)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>> =A0 =A0 =A0 =A0 iphc0 =3D lowpan_fetch_skb_u8(skb);
>> +
>> + =A0 =A0 =A0 /* fragments assmebling */
>> + =A0 =A0 =A0 switch (iphc0 & 0xf8) {
>
> =A0 =A0 =A0 =A00xf8 means ? Please use a macro or something...
>>
>> + =A0 =A0 =A0 /* first fragment of the frame */
>> + =A0 =A0 =A0 case LOWPAN_DISPATCH_FRAG1:
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lowpan_fragment *entry, *frame;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 tag;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lowpan_raw_dump_inline(__func__, "firs=
t frame fragment
>> header",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->data, 3);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D lowpan_fetch_skb_u8(skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag =3D lowpan_fetch_skb_u16(skb);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* check if frame assembling with th=
e same tag is
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* already in progress
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(entry, &lowpan=
_fragments,
>> list)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->tag =3D=3D =
tag) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_deb=
ug("%s ERROR: frame with this
>> tag is"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0"alredy in assembling",
>> __func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto d=
rop_rcu;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* alloc new frame structure */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame =3D kzalloc(sizeof(struct lowpan=
_fragment),
>> GFP_KERNEL);
>>
>>
> =A0 =A0 =A0 =A0GFP_ATOMIC
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!frame)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&frame->list);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->bytes_rcv =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->length =3D (iphc0 & 7) | (tmp <=
< 3);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->tag =3D tag;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* allocate buffer for frame assemblin=
g */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->data =3D kzalloc(frame->length,=
 GFP_KERNEL);
>>
>>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GFP_ATOMIC
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!frame->data) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(frame);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("%s: frame to be assembled: l=
ength =3D 0x%x, "
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"tag =3D 0x%x\n", _=
_func__, frame->length,
>> frame->tag);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 init_timer(&frame->timer);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* (number of fragments) * (fragment p=
rocessing
>> time-out) */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->timer.expires =3D jiffies +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (frame->length / LOWPAN_FRAG_SIZE =
+ 1) *
>> LOWPAN_FRAG_TIMEOUT;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->timer.data =3D tag;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->timer.function =3D lowpan_fragm=
ent_timer_expired;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_timer(&frame->timer);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&flist_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&frame->list, &lowpan_fr=
agments);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&flist_lock);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kfree_skb(skb), 0;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 /* second and next fragment of the frame */
>> + =A0 =A0 =A0 case LOWPAN_DISPATCH_FRAGN:
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 tag;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct lowpan_fragment *entry, *t;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lowpan_raw_dump_inline(__func__, "next=
 fragment
>> header",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 skb->data, 4);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lowpan_fetch_skb_u8(skb); /* skip fram=
e length byte */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tag =3D lowpan_fetch_skb_u16(skb);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(entry, &lowpan=
_fragments,
>> list)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->tag =3D=3D =
tag)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->tag !=3D tag) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("%s ERROR: no=
 frame structure found
>> for this"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"fr=
agment", __func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tmp =3D lowpan_fetch_skb_u8(skb); /* f=
etch offset */
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 lowpan_raw_dump_table(__func__, "next =
fragment
>> payload",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 skb->data, skb->len);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* if payload fits buffer, copy it */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((tmp * 8 + skb->len) <=3D entry->l=
ength) /* TODO:
>> likely? */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(entry->data + t=
mp * 8, skb->data,
>> skb->len);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry->bytes_rcv +=3D skb->len;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_debug("%s: frame length =3D 0x%x, b=
ytes received =3D 0x
>> %x\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, entry->le=
ngth, entry->bytes_rcv);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* frame assembling complete */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entry->bytes_rcv =3D=3D entry->len=
gth) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *tmp =3D=
 skb;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&flist_lock=
);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_sa=
fe(entry, t,
>> &lowpan_fragments, list)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (en=
try->tag =3D=3D tag) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 list_del(&entry->list);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 /* copy and clear skb */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 skb =3D skb_copy_expand(skb,
>> entry->length, skb_tailroom(skb), GFP_KERNEL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 skb_pull(skb, skb->len);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 /* copy new data to skb */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 memcpy(skb_push(skb,
>> entry->length), entry->data, entry->length);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 kfree_skb(tmp);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 del_timer(&entry->timer);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 kfree(entry->data);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 kfree(entry);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 iphc0 =3D
>> lowpan_fetch_skb_u8(skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&flist_lo=
ck);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return kfree_skb(skb), 0;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 }
>> +
>> =A0 =A0 =A0 =A0 iphc1 =3D lowpan_fetch_skb_u8(skb);
>>
>> =A0 =A0 =A0 =A0 _saddr =3D mac_cb(skb)->sa.hwaddr;
>> @@ -674,6 +947,8 @@ lowpan_process_data(struct sk_buff *skb)
>> =A0 =A0 =A0 =A0 lowpan_raw_dump_table(__func__, "raw header dump", (=
u8 *)&hdr,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(hdr));
>> =A0 =A0 =A0 =A0 return lowpan_skb_deliver(skb, &hdr);
>> +drop_rcu:
>> + =A0 =A0 =A0 rcu_read_unlock();
>> =A0drop:
>> =A0 =A0 =A0 =A0 kfree(skb);
>> =A0 =A0 =A0 =A0 return -EINVAL;
>> @@ -765,8 +1040,15 @@ static int lowpan_rcv(struct sk_buff *skb,
>> struct net_device *dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto drop;
>>
>> =A0 =A0 =A0 =A0 /* check that it's our buffer */
>> - =A0 =A0 =A0 if ((skb->data[0] & 0xe0) =3D=3D 0x60)
>> + =A0 =A0 =A0 switch (skb->data[0] & 0xe0) {
>> + =A0 =A0 =A0 case 0x60: =A0 =A0 =A0 =A0 =A0 =A0 =A0/* ipv6 datagram=
 */
>> + =A0 =A0 =A0 case 0xc0: =A0 =A0 =A0 =A0 =A0 =A0 =A0/* first fragmen=
t header */
>> + =A0 =A0 =A0 case 0xe0: =A0 =A0 =A0 =A0 =A0 =A0 =A0/* next fragment=
s headers */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lowpan_process_data(skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 return NET_RX_SUCCESS;
>>
>> @@ -793,6 +1075,8 @@ static int lowpan_newlink(struct net *src_net,
>> struct net_device *dev,
>> =A0 =A0 =A0 =A0 lowpan_dev_info(dev)->real_dev =3D real_dev;
>> =A0 =A0 =A0 =A0 mutex_init(&lowpan_dev_info(dev)->dev_list_mtx);
>>
>> + =A0 =A0 =A0 mutex_init(&flist_lock);
>>
>>
> =A0 =A0 =A0 =A0Doing this init each time a link is setup is wrong.
> =A0 =A0 =A0 =A0Do it once.
>>
>> +
>> =A0 =A0 =A0 =A0 entry =3D kzalloc(sizeof(struct lowpan_dev_record), =
GFP_KERNEL);
>> =A0 =A0 =A0 =A0 if (!entry)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
>> index 5d8cf80..e8e57c4 100644
>> --- a/net/ieee802154/6lowpan.h
>> +++ b/net/ieee802154/6lowpan.h
>> @@ -159,6 +159,9 @@
>> =A0#define LOWPAN_DISPATCH_FRAG1 =A00xc0 /* 11000xxx */
>> =A0#define LOWPAN_DISPATCH_FRAGN =A00xe0 /* 11100xxx */
>>
>> +#define LOWPAN_FRAG_SIZE =A0 =A0 =A0 40 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
/* fragment payload
>> size */
>> +#define LOWPAN_FRAG_TIMEOUT =A0 =A0(HZ * 2) =A0 =A0 =A0 =A0/* proce=
ssing time: 2
>> sec */
>> +
>> =A0/*
>> =A0 * Values of fields within the IPHC encoding first byte
>> =A0 * (C stands for compressed and I for inline)
>> --
>> 1.7.2.5
>>
>
>
>
