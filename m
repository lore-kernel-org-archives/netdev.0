From: Joe Perches <joe@perches.com>
Subject: Re: [af-packet 2/2] Enhance af-packet to provide (near
 zero)lossless packet capture functionality
Date: Tue, 07 Jun 2011 21:18:06 -0700
Message-ID: <1307506686.22272.49.camel@Joe-Laptop>
References: <1307502786-1396-1-git-send-email-loke.chetan@gmail.com>
	 <1307502786-1396-3-git-send-email-loke.chetan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, kaber@trash.net, johann.baudy@gnu-log.net,
	Chetan Loke <lokec@ccs.neu.edu>
To: Chetan Loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2619 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822Ab1FHESI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 00:18:08 -0400
In-Reply-To: <1307502786-1396-3-git-send-email-loke.chetan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-07 at 23:13 -0400, Chetan Loke wrote:
> Signed-off-by: Chetan Loke <lokec@ccs.neu.edu>

just trivia:

> ---
>  net/packet/af_packet.c |  878 +++++++++++++++++++++++++++++++++++++++++++++---
[]
> +/* kbdq - kernel block descriptor queue */
> +struct kbdq_core {
> +	struct pgv	*pkbdq;
> +	unsigned int	hdrlen;
> +	unsigned char	reset_pending_on_curr_blk;
> +	unsigned char   delete_blk_timer;
> +	unsigned short	kactive_blk_num;
> +	unsigned short	hole_bytes_size;
> +	char		*pkblk_start;
> +	char		*pkblk_end;
> +	int		kblk_size;
> +	unsigned int	knum_blocks;
> +	uint64_t	knxt_seq_num;
> +	char		*prev;
> +	char		*nxt_offset;
> +
> +	/* last_kactive_blk_num:
> +	 * trick to see if user-space has caught up
> +	 * in order to avoid refreshing timer when every single pkt arrives.
> +	 */
> +	unsigned short	last_kactive_blk_num;
> +
> +	atomic_t	blk_fill_in_prog;
> +
> +	/* Default is set to 8ms */
> +#define DEFAULT_PRB_RETIRE_TOV	(8)
> +
> +	unsigned short  retire_blk_tov;
> +	unsigned long	tov_in_jiffies;
> +
> +	/* timer to retire an outstanding block */
> +	struct timer_list retire_blk_timer;
> +};

You could align the member entries a bit more,
maybe move last_kactive_blk_num after retire_blk_tov

[]

> @@ -248,8 +322,11 @@ static void __packet_set_status(struct packet_sock *po, void *frame, int status)
>  		h.h2->tp_status = status;
>  		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
>  		break;
> +	case TPACKET_V3:
>  	default:
> -		pr_err("TPACKET version not supported\n");
> +		pr_err("<%s> TPACKET version not supported.Who is calling?\
> +			Dumping stack.\n", __func__);

whitespace defect because of line continuation.  Maybe just:
		WARN(1, "TPACKET version not supported\n");

>  		BUG();
>  	}
>  
> @@ -274,8 +351,11 @@ static int __packet_get_status(struct packet_sock *po, void *frame)
>  	case TPACKET_V2:
>  		flush_dcache_page(pgv_to_page(&h.h2->tp_status));
>  		return h.h2->tp_status;
> +	case TPACKET_V3:
>  	default:
> -		pr_err("TPACKET version not supported\n");
> +		pr_err("<%s> TPACKET version:%d not supported.\
> +			Dumping stack.\n", __func__, po->tp_version);
> +		dump_stack();

here too.

		WARN(1, "TPACKET version %d not supported\n", po->tp_version);

>  		BUG();
>  		return 0;
>  	}
[]
> +static void prb_open_block(struct kbdq_core *pkc1, struct block_desc *pbd1)
> +{
> +	pr_err("<%s> ERROR block:%p is NOT FREE status:%d\
> +			kactive_blk_num:%d\n",
> +			__func__, pbd1, BLOCK_STATUS(pbd1), pkc1->kactive_blk_num);
> +	dump_stack();
> +	BUG();

here too.  maybe just:
	WARN(1, "%s: ERROR block:%p is not free.  status: %s kactive_blk_num:%d\n"
	     __func__, pbd1, BLOCK_STATUS(pbd1), pkc1->kactive_blk_num);

> +static inline void packet_increment_rx_head(struct packet_sock *po,
> +					    struct packet_ring_buffer *rb)
> +{
> +	switch (po->tp_version) {
> +	case TPACKET_V1:
> +	case TPACKET_V2:
> +		return packet_increment_head(rb);
> +	case TPACKET_V3:
> +	default:
> +		pr_err("<%s> TPACKET version:%d not supported.\
> +			Dumping stack.\n", __func__, po->tp_version);

whitespace, WARN(1, etc...


> @@ -2412,7 +3168,7 @@ out_free_pgvec:
>  	goto out;
>  }
>  
> -static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
> +static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>  		int closing, int tx_ring)
>  {
>  	struct pgv *pg_vec = NULL;
> @@ -2421,7 +3177,17 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
>  	struct packet_ring_buffer *rb;
>  	struct sk_buff_head *rb_queue;
>  	__be16 num;
> -	int err;
> +	int err = -EINVAL;
> +	/* Added to avoid minimal code churn */
> +	struct tpacket_req *req = &req_u->req;
> +
> +	/* Opening a Tx-ring is NOT supported in TPACKET_V3 */
> +	if (!closing && tx_ring && (po->tp_version > TPACKET_V2)) {
> +		pr_err("<%s> Tx-ring is not supported on version:%d.\
> +			   Dumping stack.\n", __func__, po->tp_version);

whitespace, WARN(1, etc...


