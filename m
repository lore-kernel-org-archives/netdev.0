From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [IEEE802.15.4][6LoWPAN] draft for fragmentation support
Date: Thu, 20 Oct 2011 14:39:45 +0200
Message-ID: <1319114385.3781.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111020111718.GA32181@avtobot.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dbaryshkov@gmail.com, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jonsmirl@gmail.com
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:51436 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab1JTMju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 08:39:50 -0400
Received: by gyb13 with SMTP id 13so2727547gyb.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 05:39:50 -0700 (PDT)
In-Reply-To: <20111020111718.GA32181@avtobot.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 octobre 2011 =C3=A0 15:17 +0400, Alexander Smirnov a =C3=A9=
crit :
> Hello everybody,
>=20
> below is the patch which adds support for fragmentation in 6LoWPAN
> point to point networks. This activity needs because of difference
> in MTU: 1280 ipv6 and 128 ieee802.15.4
>=20
> This patch is just a draft. Could anyone please look at
> it and let me know your opinion.
>=20

I removed janitor list, since this patch is certainly not a janitor one=
=2E

> The most doubtful moments for me are:
> 1. Should the list 'frag_list' and the mutex 'flist_lock' be
> included into dev private data?

	The mutex is wrong, you need a spinlock since run from softirq handler=
=2E
 	Allocations should use GFP_ATOMIC for same reason.

> 2. Can I use 'dev_queue_xmit' to send fragments to queue?

	Well, it is not very clean, but it seems there is no alternative

> 3. Creating new 'skb' instead of copying and modifying main one.

	You cant do that without making sure you own the skb and its data.
	Think about a sniffer running...


4) No limitation on number of in-flight fragments.=20
You can consume lot of ram and have a list with 65536 elements...





>  net/ieee802154/6lowpan.c |  286
> +++++++++++++++++++++++++++++++++++++++++++++-
>  net/ieee802154/6lowpan.h |    3 +
>  2 files changed, 288 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 96877bd..1923ec7 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -113,6 +113,24 @@ struct lowpan_dev_record {
>         struct list_head list;
>  };
> =20
> +struct lowpan_fragment {
> +       u8 in_progress;                 /* assembling is in progress
> */
> +       struct sk_buff *skb;            /* skb to be assembled */
> +       u8 *data;                       /* data to be stored */
> +       struct mutex lock;              /* concurency lock */
> +       u16 length;                     /* frame length to be assemle=
d
> */
> +       u32 bytes_rcv;                  /* bytes received */
> +       u16 tag;                        /* current fragment tag */
> +       struct timer_list timer;        /* assembling timer */
> +       struct list_head list;          /* fragments list handler
> */   =20
> +};
> +
> +static unsigned short fragment_tag;
> +
> +/* TODO: bind mutex and list to device */
> +static LIST_HEAD(lowpan_fragments);
> +struct mutex flist_lock;
> +
>  static inline struct
>  lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
>  {
> @@ -244,6 +262,18 @@ static u8 lowpan_fetch_skb_u8(struct sk_buff
> *skb)
>         return ret;
>  }
> =20
> +static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
> +{
> +       u16 ret;
> +
> +       BUG_ON(skb->len < 2);
>=20

	Hmm, check pskb_may_pull(skb, 2), or in caller.

	skb->len >=3D 2 doesnt mean you can access to skb->data[0] and
skb->data[1] : Data might be on a fragment, not on skb head.

> +
> +       ret =3D skb->data[0] | (skb->data[1] << 8);
> +       skb_pull(skb, 2);
> +       return ret;
> +}
> +
> +static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_devic=
e
> *dev);
>  static int lowpan_header_create(struct sk_buff *skb,
>                            struct net_device *dev,
>                            unsigned short type, const void *_daddr,
> @@ -467,9 +497,102 @@ static int lowpan_header_create(struct sk_buff
> *skb,
>                 memcpy(&(sa.hwaddr), saddr, 8);
> =20
>                 mac_cb(skb)->flags =3D IEEE802154_FC_TYPE_DATA;
> +
> +               /* frame fragmentation */
> +
> +               /*
> +                * if payload + mac header doesn't fit MTU-sized fram=
e
> +                * we need to fragment it.
> +                */
> +               if (skb->len > (127 - 24)) { /* MTU -
> MAC_HEADER_LENGTH */
> +                       struct sk_buff *fr_skb;
> +                       u16 b_sent =3D 0;
> +                       unsigned short payload_len =3D skb->len;
> +                       int stat =3D 0;
> +
> +                       pr_debug("%s: the frame is too big (0x%x),"
> +                                "fragmentation needed, using tag =3D=
 0x
> %x\n",
> +                                __func__, payload_len, fragment_tag)=
;
> +
> +                       fr_skb =3D skb_copy(skb, GFP_KERNEL);
>=20

			GFP_ATOMIC
>=20
And I wonder why you skb_copy(). You are not allowed to change skb like
that. ( when you later skb_push(fr_skb, 4), you are modifying this skb
data too...)
>=20
> +                       if (!fr_skb)
> +                               goto error;
> +
> +                       /* 40-bit - fragment dispatch size */
> +                       head =3D kzalloc(5, GFP_KERNEL);

			GFP_ATOMIC


> +                       if (!head)
> +                               goto error;
> +
> +                       /* first fagment header */
> +                       head[0] =3D LOWPAN_DISPATCH_FRAG1 | (payload_=
len
> & 0x7);
> +                       head[1] =3D (payload_len >> 3) & 0xff;
> +                       head[2] =3D fragment_tag & 0xff;
> +                       head[3] =3D fragment_tag >> 8;
> +
> +
> +                       lowpan_raw_dump_inline(__func__, "first
> header",
> +                                                       head, 4);
> +
> +                       memcpy(skb_push(fr_skb, 4), head, 4);
> +                       skb_trim(fr_skb, LOWPAN_FRAG_SIZE);
> +
> +                       dev_hard_header(fr_skb,
> lowpan_dev_info(dev)->real_dev,
> +                               type, (void *)&da, (void *)&sa,
> fr_skb->len);
> +
> +                       /* send fragment to dev queue */
> +                       dev_queue_xmit(fr_skb);
> +
> +                       /* next fragments headers */
> +                       head[0] |=3D 0x20;
> +
> +                       lowpan_raw_dump_inline(__func__, "next
> headers",
> +                                                       head, 5);
> +
> +                       while (b_sent < payload_len) {
> +                               /* not the first fragment */
> +                               if (b_sent)
> +                                       skb_pull(skb,
> LOWPAN_FRAG_SIZE);
> +
> +                               pr_debug("%s: preparing fragment %d
> \n",
> +                                   __func__, b_sent /
> LOWPAN_FRAG_SIZE);
> +
> +                               /*
> +                                * create copy of current buffer and
> trim it
> +                                * down to fragment size
> +                                */
> +                               fr_skb =3D skb_copy(skb, GFP_KERNEL);
> +                               if (!fr_skb)
> +                                       goto error;
> +
> +                               skb_trim(fr_skb, LOWPAN_FRAG_SIZE);
> +
> +                               /* add fragment header */
> +                               head[4] =3D b_sent / 8;
> +                               memcpy(skb_push(fr_skb, 5), head, 5);
> +
> +                               b_sent +=3D LOWPAN_FRAG_SIZE;
> +
> +                               lowpan_raw_dump_table(__func__,
> +                                  "fragment data", fr_skb->data,
> fr_skb->len);
> +
> +                               stat =3D dev_hard_header(fr_skb,
> +                                       lowpan_dev_info(dev)->real_de=
v, type,
> +                                       (void *)&da, (void *)&sa,
> fr_skb->len);
> +
> +                               dev_queue_xmit(fr_skb);
> +                       }
> +
> +                       /* TODO: what's the correct way to skip
> default skb? */
> +
> +                       fragment_tag++;
> +                       return stat;
> +               } else
>                 return dev_hard_header(skb,
> lowpan_dev_info(dev)->real_dev,
>                                 type, (void *)&da, (void *)&sa,
> skb->len);
>         }
> +error:
> +       kfree_skb(skb);
> +       return -ENOMEM;
>  }
> =20
>  static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr
> *hdr)
> @@ -511,6 +634,23 @@ static int lowpan_skb_deliver(struct sk_buff
> *skb, struct ipv6hdr *hdr)
>         return stat;
>  }
> =20
> +static void lowpan_fragment_timer_expired(unsigned long tag)
> +{
> +       struct lowpan_fragment *entry, *tmp;
> +
> +       pr_debug("%s: timer expired for frame with tag %lu\n",
> __func__, tag);
> +
> +       mutex_lock(&flist_lock);
>=20
>=20
	A mutex_lock() is not allowed in this context (softirq).
You must use a spinlock.
>=20
>=20
> +       list_for_each_entry_safe(entry, tmp, &lowpan_fragments, list)
> +               if (entry->tag =3D=3D tag) {
>=20
>=20
	Since you have a timer per entry, instead of doing a lookup to find
'tag', you could just say 'tag' is the pointer to your "struct
lowpan_fragment"

>=20
> +                       list_del(&entry->list);
> +                       kfree(entry->data);
> +                       kfree(entry);
> +                       break;
> +               }
> +       mutex_unlock(&flist_lock);
> +}
>=20

	struct lowpan_fragment *entry =3D (struct lowpan_fragment *)tag;
	spin_lock();
	list_del(&entry->list);
	kfree(entry->data);
	kfree(entry);
	spin_unlock();
>=20
> +
>  static int
>  lowpan_process_data(struct sk_buff *skb)
>  {
> @@ -525,6 +665,139 @@ lowpan_process_data(struct sk_buff *skb)
>         if (skb->len < 2)
>                 goto drop;
>         iphc0 =3D lowpan_fetch_skb_u8(skb);
> +
> +       /* fragments assmebling */
> +       switch (iphc0 & 0xf8) {

	0xf8 means ? Please use a macro or something...
>=20
> +       /* first fragment of the frame */
> +       case LOWPAN_DISPATCH_FRAG1:
> +       {
> +               struct lowpan_fragment *entry, *frame;
> +               u16 tag;
> +
> +               lowpan_raw_dump_inline(__func__, "first frame fragmen=
t
> header",
> +                                                               skb->=
data, 3);
> +
> +               tmp =3D lowpan_fetch_skb_u8(skb);
> +               tag =3D lowpan_fetch_skb_u16(skb);
> +
> +               /*
> +                * check if frame assembling with the same tag is
> +                * already in progress
> +                */
> +               rcu_read_lock();
> +               list_for_each_entry_rcu(entry, &lowpan_fragments,
> list)
> +                       if (entry->tag =3D=3D tag) {
> +                               pr_debug("%s ERROR: frame with this
> tag is"
> +                                        "alredy in assembling",
> __func__);
> +                               goto drop_rcu;
> +                       }
> +               rcu_read_unlock();
> +
> +               /* alloc new frame structure */
> +               frame =3D kzalloc(sizeof(struct lowpan_fragment),
> GFP_KERNEL);
>=20
>=20
   	GFP_ATOMIC
>=20
> +               if (!frame)
> +                       goto drop;
> +
> +               INIT_LIST_HEAD(&frame->list);
> +
> +               frame->bytes_rcv =3D 0;
> +               frame->length =3D (iphc0 & 7) | (tmp << 3);
> +               frame->tag =3D tag;
> +               /* allocate buffer for frame assembling */
> +               frame->data =3D kzalloc(frame->length, GFP_KERNEL);
>=20
>=20
		GFP_ATOMIC

> +               if (!frame->data) {
> +                       kfree(frame);
> +                       goto drop;
> +               }
> +
> +               pr_debug("%s: frame to be assembled: length =3D 0x%x,=
 "
> +                        "tag =3D 0x%x\n", __func__, frame->length,
> frame->tag);
> +
> +               init_timer(&frame->timer);
> +               /* (number of fragments) * (fragment processing
> time-out) */
> +               frame->timer.expires =3D jiffies +
> +                 (frame->length / LOWPAN_FRAG_SIZE + 1) *
> LOWPAN_FRAG_TIMEOUT;
> +               frame->timer.data =3D tag;
> +               frame->timer.function =3D lowpan_fragment_timer_expir=
ed;
> +
> +               add_timer(&frame->timer);
> +
> +               mutex_lock(&flist_lock);
> +               list_add_tail(&frame->list, &lowpan_fragments);
> +               mutex_unlock(&flist_lock);
> +
> +               return kfree_skb(skb), 0;
> +       }
> +       /* second and next fragment of the frame */
> +       case LOWPAN_DISPATCH_FRAGN:
> +       {
> +               u16 tag;
> +               struct lowpan_fragment *entry, *t;
> +
> +               lowpan_raw_dump_inline(__func__, "next fragment
> header",
> +                                       skb->data, 4);
> +
> +               lowpan_fetch_skb_u8(skb); /* skip frame length byte *=
/
> +               tag =3D lowpan_fetch_skb_u16(skb);
> +
> +               rcu_read_lock();
> +               list_for_each_entry_rcu(entry, &lowpan_fragments,
> list)
> +                       if (entry->tag =3D=3D tag)
> +                               break;
> +               rcu_read_unlock();
> +
> +               if (entry->tag !=3D tag) {
> +                       pr_debug("%s ERROR: no frame structure found
> for this"
> +                                "fragment", __func__);
> +                       goto drop;
> +               }
> +
> +               tmp =3D lowpan_fetch_skb_u8(skb); /* fetch offset */
> +
> +               lowpan_raw_dump_table(__func__, "next fragment
> payload",
> +                                       skb->data, skb->len);
> +
> +               /* if payload fits buffer, copy it */
> +               if ((tmp * 8 + skb->len) <=3D entry->length) /* TODO:
> likely? */
> +                       memcpy(entry->data + tmp * 8, skb->data,
> skb->len);
> +               else
> +                       goto drop;
> +
> +               entry->bytes_rcv +=3D skb->len;
> +
> +               pr_debug("%s: frame length =3D 0x%x, bytes received =3D=
 0x
> %x\n",
> +                        __func__, entry->length, entry->bytes_rcv);
> +
> +               /* frame assembling complete */
> +               if (entry->bytes_rcv =3D=3D entry->length) {
> +                       struct sk_buff *tmp =3D skb;
> +
> +                       mutex_lock(&flist_lock);
> +                       list_for_each_entry_safe(entry, t,
> &lowpan_fragments, list)
> +                               if (entry->tag =3D=3D tag) {
> +                                       list_del(&entry->list);
> +                                       /* copy and clear skb */
> +                                       skb =3D skb_copy_expand(skb,
> entry->length, skb_tailroom(skb), GFP_KERNEL);
> +                                       skb_pull(skb, skb->len);
> +                                       /* copy new data to skb */
> +                                       memcpy(skb_push(skb,
> entry->length), entry->data, entry->length);
> +                                       kfree_skb(tmp);
> +                                       del_timer(&entry->timer);
> +                                       kfree(entry->data);
> +                                       kfree(entry);
> +
> +                                       iphc0 =3D
> lowpan_fetch_skb_u8(skb);
> +                                       break;
> +                               }
> +                       mutex_unlock(&flist_lock);
> +                       break;
> +               }
> +               return kfree_skb(skb), 0;
> +       }
> +       default:
> +               break;
> +       }
> +
>         iphc1 =3D lowpan_fetch_skb_u8(skb);
> =20
>         _saddr =3D mac_cb(skb)->sa.hwaddr;
> @@ -674,6 +947,8 @@ lowpan_process_data(struct sk_buff *skb)
>         lowpan_raw_dump_table(__func__, "raw header dump", (u8 *)&hdr=
,
>                                                         sizeof(hdr));
>         return lowpan_skb_deliver(skb, &hdr);
> +drop_rcu:
> +       rcu_read_unlock();
>  drop:
>         kfree(skb);
>         return -EINVAL;
> @@ -765,8 +1040,15 @@ static int lowpan_rcv(struct sk_buff *skb,
> struct net_device *dev,
>                 goto drop;
> =20
>         /* check that it's our buffer */
> -       if ((skb->data[0] & 0xe0) =3D=3D 0x60)
> +       switch (skb->data[0] & 0xe0) {
> +       case 0x60:              /* ipv6 datagram */
> +       case 0xc0:              /* first fragment header */
> +       case 0xe0:              /* next fragments headers */
>                 lowpan_process_data(skb);
> +               break;
> +       default:
> +               break;
> +       }
> =20
>         return NET_RX_SUCCESS;
> =20
> @@ -793,6 +1075,8 @@ static int lowpan_newlink(struct net *src_net,
> struct net_device *dev,
>         lowpan_dev_info(dev)->real_dev =3D real_dev;
>         mutex_init(&lowpan_dev_info(dev)->dev_list_mtx);
> =20
> +       mutex_init(&flist_lock);
>=20
>=20
	Doing this init each time a link is setup is wrong.
	Do it once.
>=20
> +
>         entry =3D kzalloc(sizeof(struct lowpan_dev_record), GFP_KERNE=
L);
>         if (!entry)
>                 return -ENOMEM;
> diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
> index 5d8cf80..e8e57c4 100644
> --- a/net/ieee802154/6lowpan.h
> +++ b/net/ieee802154/6lowpan.h
> @@ -159,6 +159,9 @@
>  #define LOWPAN_DISPATCH_FRAG1  0xc0 /* 11000xxx */
>  #define LOWPAN_DISPATCH_FRAGN  0xe0 /* 11100xxx */
> =20
> +#define LOWPAN_FRAG_SIZE       40              /* fragment payload
> size */
> +#define LOWPAN_FRAG_TIMEOUT    (HZ * 2)        /* processing time: 2
> sec */
> +
>  /*
>   * Values of fields within the IPHC encoding first byte
>   * (C stands for compressed and I for inline)
> --=20
> 1.7.2.5
>=20
