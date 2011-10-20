From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [IEEE802.15.4][6LoWPAN] draft for
	fragmentation support
Date: Thu, 20 Oct 2011 17:54:32 +0400
Message-ID: <4EA02818.9000206@gmail.com>
References: <20111020111718.GA32181@avtobot.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111020111718.GA32181-AUGNqIMGY+aR2kOLt6zJ8ErlnG4Plg33XqFh9Ls21Oc@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/20/2011 03:17 PM, Alexander Smirnov wrote:
 > Hello everybody,
 >
 > below is the patch which adds support for fragmentation in 6LoWPAN

Thanks for the patch!

 > point to point networks. This activity needs because of difference
 > in MTU: 1280 ipv6 and 128 ieee802.15.4

127.

 >
 > This patch is just a draft. Could anyone please look at
 > it and let me know your opinion.
 >
 > The most doubtful moments for me are:
 > 1. Should the list 'frag_list' and the mutex 'flist_lock' be
 > included into dev private data?

I'd also think about being lock-free here via using RCU.

 > 2. Can I use 'dev_queue_xmit' to send fragments to queue?

Yes.

It seems I see the source of your problems. You try to fragment skb from 
the header_create function. It is not designed for this task. Please, 
don't do this! You are not the owner of the skb ATM. You can't just drop 
it from that function. Strictly speaking you can't be sure that this skb 
will really hit the device queue.

You really should push this part into queue processing on the device.


 > From 48472bae269b7b1a4047967ec21eadb217c4fd6d Mon Sep 17 00:00:00 2001
 > From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
 > Date: Thu, 20 Oct 2011 15:02:36 +0400
 > Subject: [PATCH] 6LoWPAN fragmentation support
 >
 > Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
 > ---
 >  net/ieee802154/6lowpan.c |  286 
+++++++++++++++++++++++++++++++++++++++++++++-
 >  net/ieee802154/6lowpan.h |    3 +
 >  2 files changed, 288 insertions(+), 1 deletions(-)
 >
 > diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
 > index 96877bd..1923ec7 100644
 > --- a/net/ieee802154/6lowpan.c
 > +++ b/net/ieee802154/6lowpan.c
 > @@ -113,6 +113,24 @@ struct lowpan_dev_record {
 >      struct list_head list;
 >  };
 >
 > +struct lowpan_fragment {
 > +    u8 in_progress;            /* assembling is in progress */
 > +    struct sk_buff *skb;        /* skb to be assembled */
 > +    u8 *data;            /* data to be stored */
 > +    struct mutex lock;        /* concurency lock */
 > +    u16 length;            /* frame length to be assemled */
 > +    u32 bytes_rcv;            /* bytes received */
 > +    u16 tag;            /* current fragment tag */
 > +    struct timer_list timer;    /* assembling timer */
 > +    struct list_head list;        /* fragments list handler */
 > +};
 > +
 > +static unsigned short fragment_tag;

What is this? Is it a part of 6lowpan standard? There is a long history 
behind being able to predict various packet/stream parameters. Please 
rethink and adjust this.

Ideally (if it's not contra the standard) this could be a part of a hash 
(probably even 16 bits from CRC32 could work) calculated from a set of 
values like jiffies, cpu number, some other variables.

 > +
 > +/* TODO: bind mutex and list to device */
 > +static LIST_HEAD(lowpan_fragments);
 > +struct mutex flist_lock;
 > +
 >  static inline struct
 >  lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
 >  {
 > @@ -244,6 +262,18 @@ static u8 lowpan_fetch_skb_u8(struct sk_buff *skb)
 >      return ret;
 >  }
 >
 > +static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
 > +{
 > +    u16 ret;
 > +
 > +    BUG_ON(skb->len < 2);
 > +
 > +    ret = skb->data[0] | (skb->data[1] << 8);
 > +    skb_pull(skb, 2);
 > +    return ret;
 > +}
 > +
 > +static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct 
net_device *dev);
 >  static int lowpan_header_create(struct sk_buff *skb,
 >                 struct net_device *dev,
 >                 unsigned short type, const void *_daddr,
 > @@ -467,9 +497,102 @@ static int lowpan_header_create(struct sk_buff 
*skb,
 >          memcpy(&(sa.hwaddr), saddr, 8);
 >
 >          mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
 > +
 > +        /* frame fragmentation */
 > +
 > +        /*
 > +         * if payload + mac header doesn't fit MTU-sized frame
 > +         * we need to fragment it.
 > +         */
 > +        if (skb->len > (127 - 24)) { /* MTU - MAC_HEADER_LENGTH */

Magic constants. And the statement will have to be adjusted  after 
adding security handling. Does 6lowpan specify the maximum fragment 
size? IIRC there is a setting in the standard which exactly describes
which should be the maximum data size: either 127 - max_header - 
max_security_header or just 'data + MPDU headers should fit into 127'.

Could you please recheck this in both standards?

 > +            struct sk_buff *fr_skb;
 > +            u16 b_sent = 0;
 > +            unsigned short payload_len = skb->len;
 > +            int stat = 0;
 > +
 > +            pr_debug("%s: the frame is too big (0x%x),"
 > +                 "fragmentation needed, using tag = 0x%x\n",
 > +                 __func__, payload_len, fragment_tag);
 > +
 > +            fr_skb = skb_copy(skb, GFP_KERNEL);
 > +            if (!fr_skb)
 > +                goto error;
 > +
 > +            /* 40-bit - fragment dispatch size */
 > +            head = kzalloc(5, GFP_KERNEL);

No real need to kzalloc. Could you please allocate it on stack?

 > +            if (!head)
 > +                goto error;
 > +
 > +            /* first fagment header */
 > +            head[0] = LOWPAN_DISPATCH_FRAG1 | (payload_len & 0x7);
 > +            head[1] = (payload_len >> 3) & 0xff;
 > +            head[2] = fragment_tag & 0xff;
 > +            head[3] = fragment_tag >> 8;
 > +

This is not atomic!!! You should get the fragment tag value once for the 
whole skb and then use the same value in the whole function.

 > +
 > +            lowpan_raw_dump_inline(__func__, "first header",
 > +                            head, 4);
 > +
 > +            memcpy(skb_push(fr_skb, 4), head, 4);

And what if there is no 4-byte space for the header?

 > +            skb_trim(fr_skb, LOWPAN_FRAG_SIZE);
 > +
 > +            dev_hard_header(fr_skb, lowpan_dev_info(dev)->real_dev,
 > +                type, (void *)&da, (void *)&sa, fr_skb->len);
 > +
 > +            /* send fragment to dev queue */
 > +            dev_queue_xmit(fr_skb);
 > +
 > +            /* next fragments headers */
 > +            head[0] |= 0x20;

Magic value

 > +
 > +            lowpan_raw_dump_inline(__func__, "next headers",
 > +                            head, 5);
 > +
 > +            while (b_sent < payload_len) {
 > +                /* not the first fragment */
 > +                if (b_sent)
 > +                    skb_pull(skb, LOWPAN_FRAG_SIZE);

Are you the owner of the original skb here? Seems you are not. So you 
can't change the original skb.

 > +
 > +                pr_debug("%s: preparing fragment %d\n",
 > +                    __func__, b_sent / LOWPAN_FRAG_SIZE);
 > +
 > +                /*
 > +                 * create copy of current buffer and trim it
 > +                 * down to fragment size
 > +                 */
 > +                fr_skb = skb_copy(skb, GFP_KERNEL);
 > +                if (!fr_skb)
 > +                    goto error;
 > +
 > +                skb_trim(fr_skb, LOWPAN_FRAG_SIZE);
 > +
 > +                /* add fragment header */
 > +                head[4] = b_sent / 8;
 > +                memcpy(skb_push(fr_skb, 5), head, 5);
 > +
 > +                b_sent += LOWPAN_FRAG_SIZE;
 > +
 > +                lowpan_raw_dump_table(__func__,
 > +                   "fragment data", fr_skb->data, fr_skb->len);
 > +
 > +                stat = dev_hard_header(fr_skb,
 > +                    lowpan_dev_info(dev)->real_dev, type,
 > +                    (void *)&da, (void *)&sa, fr_skb->len);
 > +
 > +                dev_queue_xmit(fr_skb);
 > +            }

I don't like this piece of code. Please refactor it to a separate 
function that can send both first and next fragments.

Also I don't see a point in copying original skb again and again. It 
would be wiser to allocate fragment skb's via dev_alloc_skb, reserve 
header space, push fragmentation header, then memcpy the rest of the data.
Or you can use non-linear skb's referencing fragments from the data part 
of the original skb.


 > +
 > +            /* TODO: what's the correct way to skip default skb? */
 > +
 > +            fragment_tag++;

Hmmm.

 > +            return stat;
 > +        } else
 >          return dev_hard_header(skb, lowpan_dev_info(dev)->real_dev,
 >                  type, (void *)&da, (void *)&sa, skb->len);
 >      }
 > +error:
 > +    kfree_skb(skb);
 > +    return -ENOMEM;
 >  }
 >
 >  static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr *hdr)
 > @@ -511,6 +634,23 @@ static int lowpan_skb_deliver(struct sk_buff 
*skb, struct ipv6hdr *hdr)
 >      return stat;
 >  }
 >
 > +static void lowpan_fragment_timer_expired(unsigned long tag)
 > +{
 > +    struct lowpan_fragment *entry, *tmp;
 > +
 > +    pr_debug("%s: timer expired for frame with tag %lu\n", __func__, 
tag);
 > +
 > +    mutex_lock(&flist_lock);
 > +    list_for_each_entry_safe(entry, tmp, &lowpan_fragments, list)
 > +        if (entry->tag == tag) {
 > +            list_del(&entry->list);
 > +            kfree(entry->data);
 > +            kfree(entry);
 > +            break;
 > +        }
 > +    mutex_unlock(&flist_lock);
 > +}

Rather than using a timer here, I'd use a delayed job (that can drop 
several fragmentated packets at once, if it's execution is delayed) plus 
a sorted fragments list to ease the calculation of the next fragment 
time out wipe.

 > +
 >  static int
 >  lowpan_process_data(struct sk_buff *skb)
 >  {
 > @@ -525,6 +665,139 @@ lowpan_process_data(struct sk_buff *skb)
 >      if (skb->len < 2)
 >          goto drop;
 >      iphc0 = lowpan_fetch_skb_u8(skb);
 > +
 > +    /* fragments assmebling */
 > +    switch (iphc0 & 0xf8) {
 > +    /* first fragment of the frame */
 > +    case LOWPAN_DISPATCH_FRAG1:
 > +    {
 > +        struct lowpan_fragment *entry, *frame;
 > +        u16 tag;
 > +
 > +        lowpan_raw_dump_inline(__func__, "first frame fragment header",
 > +                                skb->data, 3);
 > +
 > +        tmp = lowpan_fetch_skb_u8(skb);
 > +        tag = lowpan_fetch_skb_u16(skb);
 > +
 > +        /*
 > +         * check if frame assembling with the same tag is
 > +         * already in progress
 > +         */
 > +        rcu_read_lock();
 > +        list_for_each_entry_rcu(entry, &lowpan_fragments, list)
 > +            if (entry->tag == tag) {
 > +                pr_debug("%s ERROR: frame with this tag is"
 > +                     "alredy in assembling", __func__);
 > +                goto drop_rcu;
 > +            }
 > +        rcu_read_unlock();

I'm not quite sure that your RCU/locking usage is correct.

 > +
 > +        /* alloc new frame structure */
 > +        frame = kzalloc(sizeof(struct lowpan_fragment), GFP_KERNEL);
 > +        if (!frame)
 > +            goto drop;
 > +
 > +        INIT_LIST_HEAD(&frame->list);
 > +
 > +        frame->bytes_rcv = 0;
 > +        frame->length = (iphc0 & 7) | (tmp << 3);
 > +        frame->tag = tag;
 > +        /* allocate buffer for frame assembling */
 > +        frame->data = kzalloc(frame->length, GFP_KERNEL);

Why not allocate an skb here? You can do all fragments processing on the 
top of one skb + ranges handling.

BTW: Did you study the skb reassembly code of IPv4?

 > +        if (!frame->data) {
 > +            kfree(frame);
 > +            goto drop;
 > +        }
 > +
 > +        pr_debug("%s: frame to be assembled: length = 0x%x, "
 > +             "tag = 0x%x\n", __func__, frame->length, frame->tag);
 > +
 > +        init_timer(&frame->timer);
 > +        /* (number of fragments) * (fragment processing time-out) */
 > +        frame->timer.expires = jiffies +
 > +          (frame->length / LOWPAN_FRAG_SIZE + 1) * LOWPAN_FRAG_TIMEOUT;
 > +        frame->timer.data = tag;
 > +        frame->timer.function = lowpan_fragment_timer_expired;
 > +
 > +        add_timer(&frame->timer);
 > +
 > +        mutex_lock(&flist_lock);
 > +        list_add_tail(&frame->list, &lowpan_fragments);
 > +        mutex_unlock(&flist_lock);
 > +
 > +        return kfree_skb(skb), 0;
 > +    }
 > +    /* second and next fragment of the frame */
 > +    case LOWPAN_DISPATCH_FRAGN:
 > +    {
 > +        u16 tag;
 > +        struct lowpan_fragment *entry, *t;
 > +
 > +        lowpan_raw_dump_inline(__func__, "next fragment header",
 > +                    skb->data, 4);
 > +
 > +        lowpan_fetch_skb_u8(skb); /* skip frame length byte */
 > +        tag = lowpan_fetch_skb_u16(skb);
 > +
 > +        rcu_read_lock();
 > +        list_for_each_entry_rcu(entry, &lowpan_fragments, list)
 > +            if (entry->tag == tag)
 > +                break;
 > +        rcu_read_unlock();
 > +
 > +        if (entry->tag != tag) {
 > +            pr_debug("%s ERROR: no frame structure found for this"
 > +                 "fragment", __func__);
 > +            goto drop;
 > +        }

Can you be sure that you won't receive fragments out of order? No, you 
can not!

 > +
 > +        tmp = lowpan_fetch_skb_u8(skb); /* fetch offset */
 > +
 > +        lowpan_raw_dump_table(__func__, "next fragment payload",
 > +                    skb->data, skb->len);
 > +
 > +        /* if payload fits buffer, copy it */
 > +        if ((tmp * 8 + skb->len) <= entry->length) /* TODO: likely? */
 > +            memcpy(entry->data + tmp * 8, skb->data, skb->len);
 > +        else
 > +            goto drop;
 > +
 > +        entry->bytes_rcv += skb->len;
 > +
 > +        pr_debug("%s: frame length = 0x%x, bytes received = 0x%x\n",
 > +             __func__, entry->length, entry->bytes_rcv);
 > +
 > +        /* frame assembling complete */
 > +        if (entry->bytes_rcv == entry->length) {
 > +            struct sk_buff *tmp = skb;


WTF?

 > +
 > +            mutex_lock(&flist_lock);
 > +            list_for_each_entry_safe(entry, t, &lowpan_fragments, list)
 > +                if (entry->tag == tag) {
 > +                    list_del(&entry->list);
 > +                    /* copy and clear skb */
 > +                    skb = skb_copy_expand(skb, entry->length, 
skb_tailroom(skb), GFP_KERNEL);
 > +                    skb_pull(skb, skb->len);
 > +                    /* copy new data to skb */
 > +                    memcpy(skb_push(skb, entry->length), 
entry->data, entry->length);
 > +                    kfree_skb(tmp);
 > +                    del_timer(&entry->timer);
 > +                    kfree(entry->data);
 > +                    kfree(entry);

This is not the optimal way to code this. Consider reading about string 
concatenation in Java or Python.

 > +
 > +                    iphc0 = lowpan_fetch_skb_u8(skb);
 > +                    break;
 > +                }
 > +            mutex_unlock(&flist_lock);
 > +            break;
 > +        }
 > +        return kfree_skb(skb), 0;
 > +    }
 > +    default:
 > +        break;
 > +    }
 > +
 >      iphc1 = lowpan_fetch_skb_u8(skb);
 >
 >      _saddr = mac_cb(skb)->sa.hwaddr;
 > @@ -674,6 +947,8 @@ lowpan_process_data(struct sk_buff *skb)
 >      lowpan_raw_dump_table(__func__, "raw header dump", (u8 *)&hdr,
 >                              sizeof(hdr));
 >      return lowpan_skb_deliver(skb, &hdr);
 > +drop_rcu:
 > +    rcu_read_unlock();
 >  drop:
 >      kfree(skb);
 >      return -EINVAL;
 > @@ -765,8 +1040,15 @@ static int lowpan_rcv(struct sk_buff *skb, 
struct net_device *dev,
 >          goto drop;
 >
 >      /* check that it's our buffer */
 > -    if ((skb->data[0] & 0xe0) == 0x60)
 > +    switch (skb->data[0] & 0xe0) {
 > +    case 0x60:        /* ipv6 datagram */
 > +    case 0xc0:        /* first fragment header */
 > +    case 0xe0:        /* next fragments headers */
 >          lowpan_process_data(skb);
 > +        break;
 > +    default:
 > +        break;
 > +    }
 >
 >      return NET_RX_SUCCESS;
 >
 > @@ -793,6 +1075,8 @@ static int lowpan_newlink(struct net *src_net, 
struct net_device *dev,
 >      lowpan_dev_info(dev)->real_dev = real_dev;
 >      mutex_init(&lowpan_dev_info(dev)->dev_list_mtx);
 >
 > +    mutex_init(&flist_lock);
 > +
 >      entry = kzalloc(sizeof(struct lowpan_dev_record), GFP_KERNEL);
 >      if (!entry)
 >          return -ENOMEM;
 > diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
 > index 5d8cf80..e8e57c4 100644
 > --- a/net/ieee802154/6lowpan.h
 > +++ b/net/ieee802154/6lowpan.h
 > @@ -159,6 +159,9 @@
 >  #define LOWPAN_DISPATCH_FRAG1    0xc0 /* 11000xxx */
 >  #define LOWPAN_DISPATCH_FRAGN    0xe0 /* 11100xxx */
 >
 > +#define LOWPAN_FRAG_SIZE    40        /* fragment payload size */
 > +#define LOWPAN_FRAG_TIMEOUT    (HZ * 2)    /* processing time: 2 sec */

Is it a standard defined interval?


-- 
With best wishes
Dmitry

------------------------------------------------------------------------------
The demand for IT networking professionals continues to grow, and the
demand for specialized networking skills is growing even more rapidly.
Take a complimentary Learning@Ciosco Self-Assessment and learn 
about Cisco certifications, training, and career opportunities. 
http://p.sf.net/sfu/cisco-dev2dev
