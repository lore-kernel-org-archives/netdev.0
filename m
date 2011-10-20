From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [IEEE802.15.4][6LoWPAN] draft for
	fragmentation support
Date: Thu, 20 Oct 2011 19:11:57 +0400
Message-ID: <CAJmB2rDd76VdY=zL3+8ScyWB9jQT0hZPuS-rr07f4eSR2h_KSQ@mail.gmail.com>
References: <20111020111718.GA32181@avtobot.ww600.siemens.net>
	<4EA02818.9000206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <4EA02818.9000206-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

2011/10/20 Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> On 10/20/2011 03:17 PM, Alexander Smirnov wrote:
>> Hello everybody,
>>
>> below is the patch which adds support for fragmentation in 6LoWPAN
>
> Thanks for the patch!
>
>> point to point networks. This activity needs because of difference
>> in MTU: 1280 ipv6 and 128 ieee802.15.4
>
> 127.
>
>>
>> This patch is just a draft. Could anyone please look at
>> it and let me know your opinion.
>>
>> The most doubtful moments for me are:
>> 1. Should the list 'frag_list' and the mutex 'flist_lock' be
>> included into dev private data?
>
> I'd also think about being lock-free here via using RCU.
>
>> 2. Can I use 'dev_queue_xmit' to send fragments to queue?
>
> Yes.
>
> It seems I see the source of your problems. You try to fragment skb from =
the
> header_create function. It is not designed for this task. Please, don't do
> this! You are not the owner of the skb ATM. You can't just drop it from t=
hat
> function. Strictly speaking you can't be sure that this skb will really h=
it
> the device queue.
>
> You really should push this part into queue processing on the device.
>
>
>> From 48472bae269b7b1a4047967ec21eadb217c4fd6d Mon Sep 17 00:00:00 2001
>> From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Thu, 20 Oct 2011 15:02:36 +0400
>> Subject: [PATCH] 6LoWPAN fragmentation support
>>
>> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
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
>> =A0 =A0 =A0struct list_head list;
>> =A0};
>>
>> +struct lowpan_fragment {
>> + =A0 =A0u8 in_progress; =A0 =A0 =A0 =A0 =A0 =A0/* assembling is in prog=
ress */
>> + =A0 =A0struct sk_buff *skb; =A0 =A0 =A0 =A0/* skb to be assembled */
>> + =A0 =A0u8 *data; =A0 =A0 =A0 =A0 =A0 =A0/* data to be stored */
>> + =A0 =A0struct mutex lock; =A0 =A0 =A0 =A0/* concurency lock */
>> + =A0 =A0u16 length; =A0 =A0 =A0 =A0 =A0 =A0/* frame length to be asseml=
ed */
>> + =A0 =A0u32 bytes_rcv; =A0 =A0 =A0 =A0 =A0 =A0/* bytes received */
>> + =A0 =A0u16 tag; =A0 =A0 =A0 =A0 =A0 =A0/* current fragment tag */
>> + =A0 =A0struct timer_list timer; =A0 =A0/* assembling timer */
>> + =A0 =A0struct list_head list; =A0 =A0 =A0 =A0/* fragments list handler=
 */
>> +};
>> +
>> +static unsigned short fragment_tag;
>
> What is this? Is it a part of 6lowpan standard? There is a long history
> behind being able to predict various packet/stream parameters. Please
> rethink and adjust this.
>
> Ideally (if it's not contra the standard) this could be a part of a hash
> (probably even 16 bits from CRC32 could work) calculated from a set of
> values like jiffies, cpu number, some other variables.
>
>> +
>> +/* TODO: bind mutex and list to device */
>> +static LIST_HEAD(lowpan_fragments);
>> +struct mutex flist_lock;
>> +
>> =A0static inline struct
>> =A0lowpan_dev_info *lowpan_dev_info(const struct net_device *dev)
>> =A0{
>> @@ -244,6 +262,18 @@ static u8 lowpan_fetch_skb_u8(struct sk_buff *skb)
>> =A0 =A0 =A0return ret;
>> =A0}
>>
>> +static u16 lowpan_fetch_skb_u16(struct sk_buff *skb)
>> +{
>> + =A0 =A0u16 ret;
>> +
>> + =A0 =A0BUG_ON(skb->len < 2);
>> +
>> + =A0 =A0ret =3D skb->data[0] | (skb->data[1] << 8);
>> + =A0 =A0skb_pull(skb, 2);
>> + =A0 =A0return ret;
>> +}
>> +
>> +static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device
>> *dev);
>> =A0static int lowpan_header_create(struct sk_buff *skb,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct net_device *dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned short type, const void *_daddr,
>> @@ -467,9 +497,102 @@ static int lowpan_header_create(struct sk_buff *sk=
b,
>> =A0 =A0 =A0 =A0 =A0memcpy(&(sa.hwaddr), saddr, 8);
>>
>> =A0 =A0 =A0 =A0 =A0mac_cb(skb)->flags =3D IEEE802154_FC_TYPE_DATA;
>> +
>> + =A0 =A0 =A0 =A0/* frame fragmentation */
>> +
>> + =A0 =A0 =A0 =A0/*
>> + =A0 =A0 =A0 =A0 * if payload + mac header doesn't fit MTU-sized frame
>> + =A0 =A0 =A0 =A0 * we need to fragment it.
>> + =A0 =A0 =A0 =A0 */
>> + =A0 =A0 =A0 =A0if (skb->len > (127 - 24)) { /* MTU - MAC_HEADER_LENGTH=
 */
>
> Magic constants. And the statement will have to be adjusted =A0after addi=
ng
> security handling. Does 6lowpan specify the maximum fragment size? IIRC
> there is a setting in the standard which exactly describes
> which should be the maximum data size: either 127 - max_header -
> max_security_header or just 'data + MPDU headers should fit into 127'.
>
> Could you please recheck this in both standards?
>
>> + =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *fr_skb;
>> + =A0 =A0 =A0 =A0 =A0 =A0u16 b_sent =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0unsigned short payload_len =3D skb->len;
>> + =A0 =A0 =A0 =A0 =A0 =A0int stat =3D 0;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0pr_debug("%s: the frame is too big (0x%x),"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "fragmentation needed, using tag =3D 0=
x%x\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, payload_len, fragment_tag);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0fr_skb =3D skb_copy(skb, GFP_KERNEL);
>> + =A0 =A0 =A0 =A0 =A0 =A0if (!fr_skb)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0/* 40-bit - fragment dispatch size */
>> + =A0 =A0 =A0 =A0 =A0 =A0head =3D kzalloc(5, GFP_KERNEL);
>
> No real need to kzalloc. Could you please allocate it on stack?
>
>> + =A0 =A0 =A0 =A0 =A0 =A0if (!head)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0/* first fagment header */
>> + =A0 =A0 =A0 =A0 =A0 =A0head[0] =3D LOWPAN_DISPATCH_FRAG1 | (payload_le=
n & 0x7);
>> + =A0 =A0 =A0 =A0 =A0 =A0head[1] =3D (payload_len >> 3) & 0xff;
>> + =A0 =A0 =A0 =A0 =A0 =A0head[2] =3D fragment_tag & 0xff;
>> + =A0 =A0 =A0 =A0 =A0 =A0head[3] =3D fragment_tag >> 8;
>> +
>
> This is not atomic!!! You should get the fragment tag value once for the
> whole skb and then use the same value in the whole function.
>
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0lowpan_raw_dump_inline(__func__, "first header",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0head, 4);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0memcpy(skb_push(fr_skb, 4), head, 4);
>
> And what if there is no 4-byte space for the header?
>
>> + =A0 =A0 =A0 =A0 =A0 =A0skb_trim(fr_skb, LOWPAN_FRAG_SIZE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0dev_hard_header(fr_skb, lowpan_dev_info(dev)->r=
eal_dev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0type, (void *)&da, (void *)&sa, fr_skb-=
>len);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0/* send fragment to dev queue */
>> + =A0 =A0 =A0 =A0 =A0 =A0dev_queue_xmit(fr_skb);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0/* next fragments headers */
>> + =A0 =A0 =A0 =A0 =A0 =A0head[0] |=3D 0x20;
>
> Magic value
>
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0lowpan_raw_dump_inline(__func__, "next headers",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0head, 5);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0while (b_sent < payload_len) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* not the first fragment */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (b_sent)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_pull(skb, LOWPAN_FRAG_SIZE);
>
> Are you the owner of the original skb here? Seems you are not. So you can=
't
> change the original skb.
>
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_debug("%s: preparing fragment %d\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, b_sent / LOWPAN_FRAG_=
SIZE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * create copy of current buffer and tr=
im it
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * down to fragment size
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fr_skb =3D skb_copy(skb, GFP_KERNEL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!fr_skb)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_trim(fr_skb, LOWPAN_FRAG_SIZE);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* add fragment header */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0head[4] =3D b_sent / 8;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(skb_push(fr_skb, 5), head, 5);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0b_sent +=3D LOWPAN_FRAG_SIZE;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lowpan_raw_dump_table(__func__,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "fragment data", fr_skb->data, fr_=
skb->len);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat =3D dev_hard_header(fr_skb,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lowpan_dev_info(dev)->real_dev,=
 type,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(void *)&da, (void *)&sa, fr_sk=
b->len);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_queue_xmit(fr_skb);
>> + =A0 =A0 =A0 =A0 =A0 =A0}
>
> I don't like this piece of code. Please refactor it to a separate function
> that can send both first and next fragments.
>
> Also I don't see a point in copying original skb again and again. It would
> be wiser to allocate fragment skb's via dev_alloc_skb, reserve header spa=
ce,
> push fragmentation header, then memcpy the rest of the data.
> Or you can use non-linear skb's referencing fragments from the data part =
of
> the original skb.
>
>
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0/* TODO: what's the correct way to skip default=
 skb? */
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0fragment_tag++;
>
> Hmmm.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0return stat;
>> + =A0 =A0 =A0 =A0} else
>> =A0 =A0 =A0 =A0 =A0return dev_hard_header(skb, lowpan_dev_info(dev)->rea=
l_dev,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0type, (void *)&da, (void *)&sa, skb->=
len);
>> =A0 =A0 =A0}
>> +error:
>> + =A0 =A0kfree_skb(skb);
>> + =A0 =A0return -ENOMEM;
>> =A0}
>>
>> =A0static int lowpan_skb_deliver(struct sk_buff *skb, struct ipv6hdr *hd=
r)
>> @@ -511,6 +634,23 @@ static int lowpan_skb_deliver(struct sk_buff *skb,
>> struct ipv6hdr *hdr)
>> =A0 =A0 =A0return stat;
>> =A0}
>>
>> +static void lowpan_fragment_timer_expired(unsigned long tag)
>> +{
>> + =A0 =A0struct lowpan_fragment *entry, *tmp;
>> +
>> + =A0 =A0pr_debug("%s: timer expired for frame with tag %lu\n", __func__,
>> tag);
>> +
>> + =A0 =A0mutex_lock(&flist_lock);
>> + =A0 =A0list_for_each_entry_safe(entry, tmp, &lowpan_fragments, list)
>> + =A0 =A0 =A0 =A0if (entry->tag =3D=3D tag) {
>> + =A0 =A0 =A0 =A0 =A0 =A0list_del(&entry->list);
>> + =A0 =A0 =A0 =A0 =A0 =A0kfree(entry->data);
>> + =A0 =A0 =A0 =A0 =A0 =A0kfree(entry);
>> + =A0 =A0 =A0 =A0 =A0 =A0break;
>> + =A0 =A0 =A0 =A0}
>> + =A0 =A0mutex_unlock(&flist_lock);
>> +}
>
> Rather than using a timer here, I'd use a delayed job (that can drop seve=
ral
> fragmentated packets at once, if it's execution is delayed) plus a sorted
> fragments list to ease the calculation of the next fragment time out wipe.
>
>> +
>> =A0static int
>> =A0lowpan_process_data(struct sk_buff *skb)
>> =A0{
>> @@ -525,6 +665,139 @@ lowpan_process_data(struct sk_buff *skb)
>> =A0 =A0 =A0if (skb->len < 2)
>> =A0 =A0 =A0 =A0 =A0goto drop;
>> =A0 =A0 =A0iphc0 =3D lowpan_fetch_skb_u8(skb);
>> +
>> + =A0 =A0/* fragments assmebling */
>> + =A0 =A0switch (iphc0 & 0xf8) {
>> + =A0 =A0/* first fragment of the frame */
>> + =A0 =A0case LOWPAN_DISPATCH_FRAG1:
>> + =A0 =A0{
>> + =A0 =A0 =A0 =A0struct lowpan_fragment *entry, *frame;
>> + =A0 =A0 =A0 =A0u16 tag;
>> +
>> + =A0 =A0 =A0 =A0lowpan_raw_dump_inline(__func__, "first frame fragment =
header",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->da=
ta, 3);
>> +
>> + =A0 =A0 =A0 =A0tmp =3D lowpan_fetch_skb_u8(skb);
>> + =A0 =A0 =A0 =A0tag =3D lowpan_fetch_skb_u16(skb);
>> +
>> + =A0 =A0 =A0 =A0/*
>> + =A0 =A0 =A0 =A0 * check if frame assembling with the same tag is
>> + =A0 =A0 =A0 =A0 * already in progress
>> + =A0 =A0 =A0 =A0 */
>> + =A0 =A0 =A0 =A0rcu_read_lock();
>> + =A0 =A0 =A0 =A0list_for_each_entry_rcu(entry, &lowpan_fragments, list)
>> + =A0 =A0 =A0 =A0 =A0 =A0if (entry->tag =3D=3D tag) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pr_debug("%s ERROR: frame with this tag=
 is"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "alredy in assembling", __func=
__);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto drop_rcu;
>> + =A0 =A0 =A0 =A0 =A0 =A0}
>> + =A0 =A0 =A0 =A0rcu_read_unlock();
>
> I'm not quite sure that your RCU/locking usage is correct.
>
>> +
>> + =A0 =A0 =A0 =A0/* alloc new frame structure */
>> + =A0 =A0 =A0 =A0frame =3D kzalloc(sizeof(struct lowpan_fragment), GFP_K=
ERNEL);
>> + =A0 =A0 =A0 =A0if (!frame)
>> + =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>> +
>> + =A0 =A0 =A0 =A0INIT_LIST_HEAD(&frame->list);
>> +
>> + =A0 =A0 =A0 =A0frame->bytes_rcv =3D 0;
>> + =A0 =A0 =A0 =A0frame->length =3D (iphc0 & 7) | (tmp << 3);
>> + =A0 =A0 =A0 =A0frame->tag =3D tag;
>> + =A0 =A0 =A0 =A0/* allocate buffer for frame assembling */
>> + =A0 =A0 =A0 =A0frame->data =3D kzalloc(frame->length, GFP_KERNEL);
>
> Why not allocate an skb here? You can do all fragments processing on the =
top
> of one skb + ranges handling.
>
> BTW: Did you study the skb reassembly code of IPv4?
>
>> + =A0 =A0 =A0 =A0if (!frame->data) {
>> + =A0 =A0 =A0 =A0 =A0 =A0kfree(frame);
>> + =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>> + =A0 =A0 =A0 =A0}
>> +
>> + =A0 =A0 =A0 =A0pr_debug("%s: frame to be assembled: length =3D 0x%x, "
>> + =A0 =A0 =A0 =A0 =A0 =A0 "tag =3D 0x%x\n", __func__, frame->length, fra=
me->tag);
>> +
>> + =A0 =A0 =A0 =A0init_timer(&frame->timer);
>> + =A0 =A0 =A0 =A0/* (number of fragments) * (fragment processing time-ou=
t) */
>> + =A0 =A0 =A0 =A0frame->timer.expires =3D jiffies +
>> + =A0 =A0 =A0 =A0 =A0(frame->length / LOWPAN_FRAG_SIZE + 1) * LOWPAN_FRA=
G_TIMEOUT;
>> + =A0 =A0 =A0 =A0frame->timer.data =3D tag;
>> + =A0 =A0 =A0 =A0frame->timer.function =3D lowpan_fragment_timer_expired;
>> +
>> + =A0 =A0 =A0 =A0add_timer(&frame->timer);
>> +
>> + =A0 =A0 =A0 =A0mutex_lock(&flist_lock);
>> + =A0 =A0 =A0 =A0list_add_tail(&frame->list, &lowpan_fragments);
>> + =A0 =A0 =A0 =A0mutex_unlock(&flist_lock);
>> +
>> + =A0 =A0 =A0 =A0return kfree_skb(skb), 0;
>> + =A0 =A0}
>> + =A0 =A0/* second and next fragment of the frame */
>> + =A0 =A0case LOWPAN_DISPATCH_FRAGN:
>> + =A0 =A0{
>> + =A0 =A0 =A0 =A0u16 tag;
>> + =A0 =A0 =A0 =A0struct lowpan_fragment *entry, *t;
>> +
>> + =A0 =A0 =A0 =A0lowpan_raw_dump_inline(__func__, "next fragment header",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->data, 4);
>> +
>> + =A0 =A0 =A0 =A0lowpan_fetch_skb_u8(skb); /* skip frame length byte */
>> + =A0 =A0 =A0 =A0tag =3D lowpan_fetch_skb_u16(skb);
>> +
>> + =A0 =A0 =A0 =A0rcu_read_lock();
>> + =A0 =A0 =A0 =A0list_for_each_entry_rcu(entry, &lowpan_fragments, list)
>> + =A0 =A0 =A0 =A0 =A0 =A0if (entry->tag =3D=3D tag)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> + =A0 =A0 =A0 =A0rcu_read_unlock();
>> +
>> + =A0 =A0 =A0 =A0if (entry->tag !=3D tag) {
>> + =A0 =A0 =A0 =A0 =A0 =A0pr_debug("%s ERROR: no frame structure found fo=
r this"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "fragment", __func__);
>> + =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>> + =A0 =A0 =A0 =A0}
>
> Can you be sure that you won't receive fragments out of order? No, you can
> not!
>
>> +
>> + =A0 =A0 =A0 =A0tmp =3D lowpan_fetch_skb_u8(skb); /* fetch offset */
>> +
>> + =A0 =A0 =A0 =A0lowpan_raw_dump_table(__func__, "next fragment payload",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->data, skb->len);
>> +
>> + =A0 =A0 =A0 =A0/* if payload fits buffer, copy it */
>> + =A0 =A0 =A0 =A0if ((tmp * 8 + skb->len) <=3D entry->length) /* TODO: l=
ikely? */
>> + =A0 =A0 =A0 =A0 =A0 =A0memcpy(entry->data + tmp * 8, skb->data, skb->l=
en);
>> + =A0 =A0 =A0 =A0else
>> + =A0 =A0 =A0 =A0 =A0 =A0goto drop;
>> +
>> + =A0 =A0 =A0 =A0entry->bytes_rcv +=3D skb->len;
>> +
>> + =A0 =A0 =A0 =A0pr_debug("%s: frame length =3D 0x%x, bytes received =3D=
 0x%x\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 __func__, entry->length, entry->bytes_rcv);
>> +
>> + =A0 =A0 =A0 =A0/* frame assembling complete */
>> + =A0 =A0 =A0 =A0if (entry->bytes_rcv =3D=3D entry->length) {
>> + =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *tmp =3D skb;
>
>
> WTF?
>
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0mutex_lock(&flist_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry_safe(entry, t, &lowpan_frag=
ments, list)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (entry->tag =3D=3D tag) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del(&entry->list);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* copy and clear skb */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb =3D skb_copy_expand(skb, en=
try->length,
>> skb_tailroom(skb), GFP_KERNEL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_pull(skb, skb->len);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* copy new data to skb */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(skb_push(skb, entry->len=
gth), entry->data,
>> entry->length);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree_skb(tmp);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_timer(&entry->timer);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(entry->data);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kfree(entry);
>
> This is not the optimal way to code this. Consider reading about string
> concatenation in Java or Python.
>
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iphc0 =3D lowpan_fetch_skb_u8(s=
kb);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> + =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&flist_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0break;
>> + =A0 =A0 =A0 =A0}
>> + =A0 =A0 =A0 =A0return kfree_skb(skb), 0;
>> + =A0 =A0}
>> + =A0 =A0default:
>> + =A0 =A0 =A0 =A0break;
>> + =A0 =A0}
>> +
>> =A0 =A0 =A0iphc1 =3D lowpan_fetch_skb_u8(skb);
>>
>> =A0 =A0 =A0_saddr =3D mac_cb(skb)->sa.hwaddr;
>> @@ -674,6 +947,8 @@ lowpan_process_data(struct sk_buff *skb)
>> =A0 =A0 =A0lowpan_raw_dump_table(__func__, "raw header dump", (u8 *)&hdr,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(hdr));
>> =A0 =A0 =A0return lowpan_skb_deliver(skb, &hdr);
>> +drop_rcu:
>> + =A0 =A0rcu_read_unlock();
>> =A0drop:
>> =A0 =A0 =A0kfree(skb);
>> =A0 =A0 =A0return -EINVAL;
>> @@ -765,8 +1040,15 @@ static int lowpan_rcv(struct sk_buff *skb, struct
>> net_device *dev,
>> =A0 =A0 =A0 =A0 =A0goto drop;
>>
>> =A0 =A0 =A0/* check that it's our buffer */
>> - =A0 =A0if ((skb->data[0] & 0xe0) =3D=3D 0x60)
>> + =A0 =A0switch (skb->data[0] & 0xe0) {
>> + =A0 =A0case 0x60: =A0 =A0 =A0 =A0/* ipv6 datagram */
>> + =A0 =A0case 0xc0: =A0 =A0 =A0 =A0/* first fragment header */
>> + =A0 =A0case 0xe0: =A0 =A0 =A0 =A0/* next fragments headers */
>> =A0 =A0 =A0 =A0 =A0lowpan_process_data(skb);
>> + =A0 =A0 =A0 =A0break;
>> + =A0 =A0default:
>> + =A0 =A0 =A0 =A0break;
>> + =A0 =A0}
>>
>> =A0 =A0 =A0return NET_RX_SUCCESS;
>>
>> @@ -793,6 +1075,8 @@ static int lowpan_newlink(struct net *src_net, stru=
ct
>> net_device *dev,
>> =A0 =A0 =A0lowpan_dev_info(dev)->real_dev =3D real_dev;
>> =A0 =A0 =A0mutex_init(&lowpan_dev_info(dev)->dev_list_mtx);
>>
>> + =A0 =A0mutex_init(&flist_lock);
>> +
>> =A0 =A0 =A0entry =3D kzalloc(sizeof(struct lowpan_dev_record), GFP_KERNE=
L);
>> =A0 =A0 =A0if (!entry)
>> =A0 =A0 =A0 =A0 =A0return -ENOMEM;
>> diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
>> index 5d8cf80..e8e57c4 100644
>> --- a/net/ieee802154/6lowpan.h
>> +++ b/net/ieee802154/6lowpan.h
>> @@ -159,6 +159,9 @@
>> =A0#define LOWPAN_DISPATCH_FRAG1 =A0 =A00xc0 /* 11000xxx */
>> =A0#define LOWPAN_DISPATCH_FRAGN =A0 =A00xe0 /* 11100xxx */
>>
>> +#define LOWPAN_FRAG_SIZE =A0 =A040 =A0 =A0 =A0 =A0/* fragment payload s=
ize */
>> +#define LOWPAN_FRAG_TIMEOUT =A0 =A0(HZ * 2) =A0 =A0/* processing time: =
2 sec */
>
> Is it a standard defined interval?
>
>
> --
> With best wishes
> Dmitry
>

Hi Dmitry,

please don't judge so strictly. This patch doesn't pretend to be
merged. It's just a draft and I only asked some help regarding how to
implement some doubtful moments. And you gave it to me ;-)

But in any case thanks a lot to everybody!

With best regards,
Alexander

---------------------------------------------------------------------------=
---
The demand for IT networking professionals continues to grow, and the
demand for specialized networking skills is growing even more rapidly.
Take a complimentary Learning@Ciosco Self-Assessment and learn =

about Cisco certifications, training, and career opportunities. =

http://p.sf.net/sfu/cisco-dev2dev
