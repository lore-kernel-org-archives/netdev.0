From: "David S. Miller" <davem@davemloft.net>
Subject: design for TSO performance fix
Date: Thu, 27 Jan 2005 16:31:46 -0800
Message-ID: <20050127163146.33b01e95.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, here is the best idea I've been able to come up with
so far.

The basic idea is that we stop trying to build TSO frames
in the actual transmit queue.  Instead, TSO packets are
built impromptu when we actually output packets on the
transmit queue.

Advantages:

1) No knowledge of TSO frames need exist anywhere besides
   tcp_write_xmit(), tcp_transmit_skb(), and
   tcp_xmit_retransmit_queue()

2) As a result of #1, all the pcount crap goes away.
   The need for two MSS state variables (mss_cache,
   and mss_cache_std) and assosciated complexity is
   eliminated as well.

3) Keeping TSO enabled after packet loss "just works".

4) CWND sampled at the correct moment when deciding
   the TSO packet arity.

The one disadvantage is that it might be a tiny bit more
expensive to build TSO frames.  But I am sure we can find
ways to optimize that quite well.

The main element of the TSO output logic is a function
that is schemed as follows:

static inline int tcp_skb_data_all_paged(struct sk_buff *skb)
{
	return (skb->len == skb->data_len);
}

/* If possible, append paged data of SRC_SKB onto the
 * tail of DST_SKB.
 */
static int skb_append_pages(struct sk_buff *dst_skb, struct sk_buff *src_skb)
{
	int i;

	if (!tcp_skb_data_all_paged(src_skb))
		return -EINVAL;

	for (i = 0; i < skb_shinfo(src_skb)->nr_frags; i++) {
		skb_frag_t *src_frag = &skb_shinfo(src_skb)->frags[i];
		skb_frag_t *dst_frag;
		int dst_frag_idx;

		dst_frag_idx = skb_shinfo(dst_skb)->nr_frags;

		if (skb_can_coalesce(dst_skb, dst_frag_idx,
				     src_frag->page, src_frag->page_offset)) {
			dst_frag = &skb_shinfo(dst_skb)->frags[dst_frag_idx-1];
			dst_frag->size += src_frag->size;
		} else {
			if (dst_frag_idx >= MAX_SKB_FRAGS)
				return -EMSGSIZE;

			dst_frag = &skb_shinfo(dst_skb)->frags[dst_frag_idx];
			skb_shinfo(dst_skb)->nr_frags = dst_frag_idx + 1;

			dst_frag->page = src_frag->page;
			get_page(src_frag->page);

			dst_frag->page_offset = src_frag->page_offset;
			dst_frag->size = src_frag->size;
		}
		skb->data_len += src_frag->size;
	}

	return 0;
}

static struct sk_buff *tcp_tso_build(struct sk_buff *head, int mss, int num)
{
	struct sk_buff *skb;
	struct sock *sk;
	int err;

	sk = head->sk;
	skb = alloc_skb(sk->sk_prot->max_header, GFP_ATOMIC);
	err = -ENOMEM;
	if (!skb)
		goto fail;

	err = 0;
	skb_shinfo(skb)->tso_size = mss;
	skb_shinfo(skb)->tso_segs = num;
	while (num--) {
		err = skb_append_pages(skb, head, &dst_frag_idx);
		if (err)
			goto fail;

		head = head->next;
	}
	return skb;

fail:
	if (skb) {
		int i;

		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];

			put_page(frag->page);
		}

		kfree_skb(skb);
	}
	return NULL;
}

If tcp_tso_build() fails, the caller just falls back to the
normal path of sending the frames non-TSO one-by-one.

The logic is simple because if TSO is being done we know
that all of the SKB data is paged (since SG+CSUM is a
requirement for TSO).  The one case where that
invariant might fail is due to a routing change (previous
device cannot do SG+CSUM, new device has full TSO capability)
and that is handled via the tcp_skb_data_all_paged() checks.

My thinking is that whatever added expensive this new scheme
has, is offset by the simplifications the rest of the TCP
stack will have since it will no longer need to know anything
about multiple MSS values and packet counts.

Comments?
