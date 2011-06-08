From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [af-packet 2/2] Enhance af-packet to provide (near zero)lossless
 packet capture functionality
Date: Wed, 8 Jun 2011 18:01:03 -0400
Message-ID: <BANLkTi=AfvjVh7AZkQiABC8r=DrBYEGrug@mail.gmail.com>
References: <1307502786-1396-1-git-send-email-loke.chetan@gmail.com>
	<1307502786-1396-3-git-send-email-loke.chetan@gmail.com>
	<1307506686.22272.49.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, kaber@trash.net, johann.baudy@gnu-log.net,
	Chetan Loke <lokec@ccs.neu.edu>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:38223 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab1FHWBE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 18:01:04 -0400
Received: by pwi15 with SMTP id 15so449466pwi.19
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 15:01:03 -0700 (PDT)
In-Reply-To: <1307506686.22272.49.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2011 at 12:18 AM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2011-06-07 at 23:13 -0400, Chetan Loke wrote:
>> Signed-off-by: Chetan Loke <lokec@ccs.neu.edu>
>
> just trivia:
>
>> ---
>> =C2=A0net/packet/af_packet.c | =C2=A0878 +++++++++++++++++++++++++++=
++++++++++++++++++---
> []
>> +/* kbdq - kernel block descriptor queue */
>> +struct kbdq_core {
>> + =C2=A0 =C2=A0 struct pgv =C2=A0 =C2=A0 =C2=A0*pkbdq;
>> + =C2=A0 =C2=A0 unsigned int =C2=A0 =C2=A0hdrlen;
>> + =C2=A0 =C2=A0 unsigned char =C2=A0 reset_pending_on_curr_blk;
>> + =C2=A0 =C2=A0 unsigned char =C2=A0 delete_blk_timer;
>> + =C2=A0 =C2=A0 unsigned short =C2=A0kactive_blk_num;
>> + =C2=A0 =C2=A0 unsigned short =C2=A0hole_bytes_size;
>> + =C2=A0 =C2=A0 char =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*pkblk=
_start;
>> + =C2=A0 =C2=A0 char =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*pkblk=
_end;
>> + =C2=A0 =C2=A0 int =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kblk_s=
ize;
>> + =C2=A0 =C2=A0 unsigned int =C2=A0 =C2=A0knum_blocks;
>> + =C2=A0 =C2=A0 uint64_t =C2=A0 =C2=A0 =C2=A0 =C2=A0knxt_seq_num;
>> + =C2=A0 =C2=A0 char =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*prev;
>> + =C2=A0 =C2=A0 char =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*nxt_o=
ffset;
>> +
>> + =C2=A0 =C2=A0 /* last_kactive_blk_num:
>> + =C2=A0 =C2=A0 =C2=A0* trick to see if user-space has caught up
>> + =C2=A0 =C2=A0 =C2=A0* in order to avoid refreshing timer when ever=
y single pkt arrives.
>> + =C2=A0 =C2=A0 =C2=A0*/
>> + =C2=A0 =C2=A0 unsigned short =C2=A0last_kactive_blk_num;
>> +
>> + =C2=A0 =C2=A0 atomic_t =C2=A0 =C2=A0 =C2=A0 =C2=A0blk_fill_in_prog=
;
>> +
>> + =C2=A0 =C2=A0 /* Default is set to 8ms */
>> +#define DEFAULT_PRB_RETIRE_TOV =C2=A0 =C2=A0 =C2=A0 (8)
>> +
>> + =C2=A0 =C2=A0 unsigned short =C2=A0retire_blk_tov;
>> + =C2=A0 =C2=A0 unsigned long =C2=A0 tov_in_jiffies;
>> +
>> + =C2=A0 =C2=A0 /* timer to retire an outstanding block */
>> + =C2=A0 =C2=A0 struct timer_list retire_blk_timer;
>> +};
>
> You could align the member entries a bit more,
> maybe move last_kactive_blk_num after retire_blk_tov
>
> []
>
>> @@ -248,8 +322,11 @@ static void __packet_set_status(struct packet_s=
ock *po, void *frame, int status)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 h.h2->tp_status =3D=
 status;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 flush_dcache_page(p=
gv_to_page(&h.h2->tp_status));
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 case TPACKET_V3:
>> =C2=A0 =C2=A0 =C2=A0 default:
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_err("TPACKET version =
not supported\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_err("<%s> TPACKET ver=
sion not supported.Who is calling?\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 Dumping stack.\n", __func__);
>
> whitespace defect because of line continuation. =C2=A0Maybe just:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0WARN(1, "TPACK=
ET version not supported\n");
>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG();
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> @@ -274,8 +351,11 @@ static int __packet_get_status(struct packet_so=
ck *po, void *frame)
>> =C2=A0 =C2=A0 =C2=A0 case TPACKET_V2:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 flush_dcache_page(p=
gv_to_page(&h.h2->tp_status));
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return h.h2->tp_sta=
tus;
>> + =C2=A0 =C2=A0 case TPACKET_V3:
>> =C2=A0 =C2=A0 =C2=A0 default:
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_err("TPACKET version =
not supported\n");
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_err("<%s> TPACKET ver=
sion:%d not supported.\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 Dumping stack.\n", __func__, po->tp_version);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dump_stack();
>
> here too.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0WARN(1, "TPACK=
ET version %d not supported\n", po->tp_version);
>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> =C2=A0 =C2=A0 =C2=A0 }
> []
>> +static void prb_open_block(struct kbdq_core *pkc1, struct block_des=
c *pbd1)
>> +{
>> + =C2=A0 =C2=A0 pr_err("<%s> ERROR block:%p is NOT FREE status:%d\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 kactive_blk_num:%d\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 __func__, pbd1, BLOCK_STATUS(pbd1), pkc1->kactive_blk_num);
>> + =C2=A0 =C2=A0 dump_stack();
>> + =C2=A0 =C2=A0 BUG();
>
> here too. =C2=A0maybe just:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0WARN(1, "%s: ERROR block:%p is not free. =C2=
=A0status: %s kactive_blk_num:%d\n"
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __func__, pbd1, BLOCK_STATU=
S(pbd1), pkc1->kactive_blk_num);
>
>> +static inline void packet_increment_rx_head(struct packet_sock *po,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 struct packet_ring_buffer *rb)
>> +{
>> + =C2=A0 =C2=A0 switch (po->tp_version) {
>> + =C2=A0 =C2=A0 case TPACKET_V1:
>> + =C2=A0 =C2=A0 case TPACKET_V2:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return packet_increment_=
head(rb);
>> + =C2=A0 =C2=A0 case TPACKET_V3:
>> + =C2=A0 =C2=A0 default:
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_err("<%s> TPACKET ver=
sion:%d not supported.\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 Dumping stack.\n", __func__, po->tp_version);
>
> whitespace, WARN(1, etc...
>
>
>> @@ -2412,7 +3168,7 @@ out_free_pgvec:
>> =C2=A0 =C2=A0 =C2=A0 goto out;
>> =C2=A0}
>>
>> -static int packet_set_ring(struct sock *sk, struct tpacket_req *req=
,
>> +static int packet_set_ring(struct sock *sk, union tpacket_req_u *re=
q_u,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int closing, int tx=
_ring)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 struct pgv *pg_vec =3D NULL;
>> @@ -2421,7 +3177,17 @@ static int packet_set_ring(struct sock *sk, s=
truct tpacket_req *req,
>> =C2=A0 =C2=A0 =C2=A0 struct packet_ring_buffer *rb;
>> =C2=A0 =C2=A0 =C2=A0 struct sk_buff_head *rb_queue;
>> =C2=A0 =C2=A0 =C2=A0 __be16 num;
>> - =C2=A0 =C2=A0 int err;
>> + =C2=A0 =C2=A0 int err =3D -EINVAL;
>> + =C2=A0 =C2=A0 /* Added to avoid minimal code churn */
>> + =C2=A0 =C2=A0 struct tpacket_req *req =3D &req_u->req;
>> +
>> + =C2=A0 =C2=A0 /* Opening a Tx-ring is NOT supported in TPACKET_V3 =
*/
>> + =C2=A0 =C2=A0 if (!closing && tx_ring && (po->tp_version > TPACKET=
_V2)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pr_err("<%s> Tx-ring is =
not supported on version:%d.\
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0Dumping stack.\n", __func__, po->tp_version);
>
> whitespace, WARN(1, etc...
>
>
>

Sure, will address all the comments(sob,alignment,pr_err etc) in the
next iteration of the patch.

thanks
Chetan
