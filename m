From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 06/10] tcp: Try to restore large SKBs while SACK processing
Date: Mon, 24 Nov 2008 16:22:03 +0200
Message-ID: <1227536527-29713-7-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52538 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093AbYKXOWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:12 -0500
In-Reply-To: <1227536527-29713-6-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During SACK processing, most of the benefits of TSO are eaten by
the SACK blocks that one-by-one fragment SKBs to MSS sized chunks.
Then we're in problems when cleanup work for them has to be done
when a large cumulative ACK comes. Try to return back to pre-split
state already while more and more SACK info gets discovered by
combining newly discovered SACK areas with the previous skb if
that's SACKed as well.

This approach has a number of benefits:

1) The processing overhead is spread more equally over the RTT
2) Write queue has less skbs to process (affect everything
   which has to walk in the queue past the sacked areas)
3) Write queue is consistent whole the time, so no other parts
   of TCP has to be aware of this (this was not the case with
   some other approach that was, well, quite intrusive all
   around).
4) Clean_rtx_queue can release most of the pages using single
   put_page instead of previous PAGE_SIZE/mss+1 calls

In case a hole is fully filled by the new SACK block, we attempt
to combine the next skb too which allows construction of skbs
that are even larger than what tso split them to and it handles
hole per on every nth patterns that often occur during slow start
overshoot pretty nicely. Though this to be really useful also
a retransmission would have to get lost since cumulative ACKs
advance one hole at a time in the most typical case.

TODO: handle upwards only merging. That should be rather easy
when segment is fully sacked but I'm leaving that as future
work item (it won't make very large difference anyway since
this current approach already covers quite a lot of normal
cases).

I was earlier thinking of some sophisticated way of tracking
timestamps of the first and the last segment but later on
realized that it won't be that necessary at all to store the
timestamp of the last segment. The cases that can occur are
basically either:
  1) ambiguous =3D> no sensible measurement can be taken anyway
  2) non-ambiguous is due to reordering =3D> having the timestamp
     of the last segment there is just skewing things more off
     than does some good since the ack got triggered by one of
     the holes (besides some substle issues that would make
     determining right hole/skb even harder problem). Anyway,
     it has nothing to do with this change then.

I choose to route some abnormal looking cases with goto noop,
some could be handled differently (eg., by stopping the
walking at that skb but again). In general, they either
shouldn't happen at all or are rare enough to make no difference
in practice.

In theory this change (as whole) could cause some macroscale
regression (global) because of cache misses that are taken over
the round-trip time but it gets very likely better because of much
less (local) cache misses per other write queue walkers and the
big recovery clearing cumulative ack.

Worth to note that these benefits would be very easy to get also
without TSO/GSO being on as long as the data is in pages so that
we can merge them. Currently I won't let that happen because
DSACK splitting at fragment that would mess up pcounts due to
sk_can_gso in tcp_set_skb_tso_segs. Once DSACKs fragments gets
avoided, we have some conditions that can be made less strict.

TODO: I will probably have to convert the excessive pointer
passing to struct sacktag_state... :-)

My testing revealed that considerable amount of skbs couldn't
be shifted because they were cloned (most likely still awaiting
tx reclaim)...

[The rest is considering future work instead since I got
repeatably EFAULT to tcpdump's recvfrom when I added
pskb_expand_head to deal with clones, so I separated that
into another, later patch]

=2E..To counter that, I gave up on the fifth advantage:

5) When growing previous SACK block, less allocs for new skbs
   are done, basically a new alloc is needed only when new hole
   is detected and when the previous skb runs out of frags space

=2E..which now only happens of if reclaim is fast enough to dispose
the clone before the SACK block comes in (the window is RTT long),
otherwise we'll have to alloc some.

With clones being handled I got these numbers (will be somewhat
worse without that), taken with fine-grained mibs:

                  TCPSackShifted 398
                   TCPSackMerged 877
            TCPSackShiftFallback 320
      TCPSACKCOLLAPSEFALLBACKGSO 0
  TCPSACKCOLLAPSEFALLBACKSKBBITS 0
  TCPSACKCOLLAPSEFALLBACKSKBDATA 0
    TCPSACKCOLLAPSEFALLBACKBELOW 0
    TCPSACKCOLLAPSEFALLBACKFIRST 1
 TCPSACKCOLLAPSEFALLBACKPREVBITS 318
      TCPSACKCOLLAPSEFALLBACKMSS 1
   TCPSACKCOLLAPSEFALLBACKNOHEAD 0
    TCPSACKCOLLAPSEFALLBACKSHIFT 0
          TCPSACKCOLLAPSENOOPSEQ 0
  TCPSACKCOLLAPSENOOPSMALLPCOUNT 0
     TCPSACKCOLLAPSENOOPSMALLLEN 0
             TCPSACKCOLLAPSEHOLE 12

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/skbuff.h |   33 ++++++
 include/net/tcp.h      |    5 +
 net/core/skbuff.c      |  140 ++++++++++++++++++++++++++
 net/ipv4/tcp_input.c   |  256 ++++++++++++++++++++++++++++++++++++++++=
++++++--
 4 files changed, 427 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a01b6f8..acf17af 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -493,6 +493,19 @@ static inline bool skb_queue_is_last(const struct =
sk_buff_head *list,
 }
=20
 /**
+ *	skb_queue_is_first - check if skb is the first entry in the queue
+ *	@list: queue head
+ *	@skb: buffer
+ *
+ *	Returns true if @skb is the first buffer on the list.
+ */
+static inline bool skb_queue_is_first(const struct sk_buff_head *list,
+				      const struct sk_buff *skb)
+{
+	return (skb->prev =3D=3D (struct sk_buff *) list);
+}
+
+/**
  *	skb_queue_next - return the next packet in the queue
  *	@list: queue head
  *	@skb: current buffer
@@ -511,6 +524,24 @@ static inline struct sk_buff *skb_queue_next(const=
 struct sk_buff_head *list,
 }
=20
 /**
+ *	skb_queue_prev - return the prev packet in the queue
+ *	@list: queue head
+ *	@skb: current buffer
+ *
+ *	Return the prev packet in @list before @skb.  It is only valid to
+ *	call this if skb_queue_is_first() evaluates to false.
+ */
+static inline struct sk_buff *skb_queue_prev(const struct sk_buff_head=
 *list,
+					     const struct sk_buff *skb)
+{
+	/* This BUG_ON may seem severe, but if we just return then we
+	 * are going to dereference garbage.
+	 */
+	BUG_ON(skb_queue_is_first(list, skb));
+	return skb->prev;
+}
+
+/**
  *	skb_get - reference buffer
  *	@skb: buffer to reference
  *
@@ -1652,6 +1683,8 @@ extern int             skb_splice_bits(struct sk_=
buff *skb,
 extern void	       skb_copy_and_csum_dev(const struct sk_buff *skb, u8=
 *to);
 extern void	       skb_split(struct sk_buff *skb,
 				 struct sk_buff *skb1, const u32 len);
+extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
+				 int shiftlen);
=20
 extern struct sk_buff *skb_segment(struct sk_buff *skb, int features);
=20
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 90b4c3b..2653924 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1192,6 +1192,11 @@ static inline struct sk_buff *tcp_write_queue_ne=
xt(struct sock *sk, struct sk_bu
 	return skb_queue_next(&sk->sk_write_queue, skb);
 }
=20
+static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, st=
ruct sk_buff *skb)
+{
+	return skb_queue_prev(&sk->sk_write_queue, skb);
+}
+
 #define tcp_for_write_queue(skb, sk)					\
 	skb_queue_walk(&(sk)->sk_write_queue, skb)
=20
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 267185a..844b8ab 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2018,6 +2018,146 @@ void skb_split(struct sk_buff *skb, struct sk_b=
uff *skb1, const u32 len)
 		skb_split_no_header(skb, skb1, len, pos);
 }
=20
+/* Shifting from/to a cloned skb is a no-go.
+ *
+ * TODO: handle cloned skbs by using pskb_expand_head()
+ */
+static int skb_prepare_for_shift(struct sk_buff *skb)
+{
+	return skb_cloned(skb);
+}
+
+/**
+ * skb_shift - Shifts paged data partially from skb to another
+ * @tgt: buffer into which tail data gets added
+ * @skb: buffer from which the paged data comes from
+ * @shiftlen: shift up to this many bytes
+ *
+ * Attempts to shift up to shiftlen worth of bytes, which may be less =
than
+ * the length of the skb, from tgt to skb. Returns number bytes shifte=
d.
+ * It's up to caller to free skb if everything was shifted.
+ *
+ * If @tgt runs out of frags, the whole operation is aborted.
+ *
+ * Skb cannot include anything else but paged data while tgt is allowe=
d
+ * to have non-paged data as well.
+ *
+ * TODO: full sized shift could be optimized but that would need
+ * specialized skb free'er to handle frags without up-to-date nr_frags=
=2E
+ */
+int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
+{
+	int from, to, merge, todo;
+	struct skb_frag_struct *fragfrom, *fragto;
+
+	BUG_ON(shiftlen > skb->len);
+	BUG_ON(skb_headlen(skb));	/* Would corrupt stream */
+
+	todo =3D shiftlen;
+	from =3D 0;
+	to =3D skb_shinfo(tgt)->nr_frags;
+	fragfrom =3D &skb_shinfo(skb)->frags[from];
+
+	/* Actual merge is delayed until the point when we know we can
+	 * commit all, so that we don't have to undo partial changes
+	 */
+	if (!to ||
+	    !skb_can_coalesce(tgt, to, fragfrom->page, fragfrom->page_offset)=
) {
+		merge =3D -1;
+	} else {
+		merge =3D to - 1;
+
+		todo -=3D fragfrom->size;
+		if (todo < 0) {
+			if (skb_prepare_for_shift(skb) ||
+			    skb_prepare_for_shift(tgt))
+				return 0;
+
+			fragto =3D &skb_shinfo(tgt)->frags[merge];
+
+			fragto->size +=3D shiftlen;
+			fragfrom->size -=3D shiftlen;
+			fragfrom->page_offset +=3D shiftlen;
+
+			goto onlymerged;
+		}
+
+		from++;
+	}
+
+	/* Skip full, not-fitting skb to avoid expensive operations */
+	if ((shiftlen =3D=3D skb->len) &&
+	    (skb_shinfo(skb)->nr_frags - from) > (MAX_SKB_FRAGS - to))
+		return 0;
+
+	if (skb_prepare_for_shift(skb) || skb_prepare_for_shift(tgt))
+		return 0;
+
+	while ((todo > 0) && (from < skb_shinfo(skb)->nr_frags)) {
+		if (to =3D=3D MAX_SKB_FRAGS)
+			return 0;
+
+		fragfrom =3D &skb_shinfo(skb)->frags[from];
+		fragto =3D &skb_shinfo(tgt)->frags[to];
+
+		if (todo >=3D fragfrom->size) {
+			*fragto =3D *fragfrom;
+			todo -=3D fragfrom->size;
+			from++;
+			to++;
+
+		} else {
+			get_page(fragfrom->page);
+			fragto->page =3D fragfrom->page;
+			fragto->page_offset =3D fragfrom->page_offset;
+			fragto->size =3D todo;
+
+			fragfrom->page_offset +=3D todo;
+			fragfrom->size -=3D todo;
+			todo =3D 0;
+
+			to++;
+			break;
+		}
+	}
+
+	/* Ready to "commit" this state change to tgt */
+	skb_shinfo(tgt)->nr_frags =3D to;
+
+	if (merge >=3D 0) {
+		fragfrom =3D &skb_shinfo(skb)->frags[0];
+		fragto =3D &skb_shinfo(tgt)->frags[merge];
+
+		fragto->size +=3D fragfrom->size;
+		put_page(fragfrom->page);
+	}
+
+	/* Reposition in the original skb */
+	to =3D 0;
+	while (from < skb_shinfo(skb)->nr_frags)
+		skb_shinfo(skb)->frags[to++] =3D skb_shinfo(skb)->frags[from++];
+	skb_shinfo(skb)->nr_frags =3D to;
+
+	BUG_ON(todo > 0 && !skb_shinfo(skb)->nr_frags);
+
+onlymerged:
+	/* Most likely the tgt won't ever need its checksum anymore, skb on
+	 * the other hand might need it if it needs to be resent
+	 */
+	tgt->ip_summed =3D CHECKSUM_PARTIAL;
+	skb->ip_summed =3D CHECKSUM_PARTIAL;
+
+	/* Yak, is it really working this way? Some helper please? */
+	skb->len -=3D shiftlen;
+	skb->data_len -=3D shiftlen;
+	skb->truesize -=3D shiftlen;
+	tgt->len +=3D shiftlen;
+	tgt->data_len +=3D shiftlen;
+	tgt->truesize +=3D shiftlen;
+
+	return shiftlen;
+}
+
 /**
  * skb_prepare_seq_read - Prepare a sequential read of skb data
  * @skb: the buffer to read
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 94533e4..8106421 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1241,6 +1241,8 @@ static int tcp_check_dsack(struct sock *sk, struc=
t sk_buff *ack_skb,
  * aligned portion of it that matches. Therefore we might need to frag=
ment
  * which may fail and creates some hassle (caller must handle error ca=
se
  * returns).
+ *
+ * FIXME: this could be merged to shift decision code
  */
 static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
 				 u32 start_seq, u32 end_seq)
@@ -1352,9 +1354,6 @@ static int tcp_sacktag_one(struct sk_buff *skb, s=
truct sock *sk,
=20
 		if (fack_count > tp->fackets_out)
 			tp->fackets_out =3D fack_count;
-
-		if (!before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(tp)))
-			tcp_advance_highest_sack(sk, skb);
 	}
=20
 	/* D-SACK. We can detect redundant retransmission in S|R and plain R
@@ -1369,12 +1368,231 @@ static int tcp_sacktag_one(struct sk_buff *skb=
, struct sock *sk,
 	return flag;
 }
=20
+static int tcp_shifted_skb(struct sock *sk, struct sk_buff *prev,
+			   struct sk_buff *skb, unsigned int pcount,
+			   int shifted, int fack_count, int *reord,
+			   int *flag, int mss)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	u8 dummy_sacked =3D TCP_SKB_CB(skb)->sacked;	/* We discard results */
+
+	BUG_ON(!pcount);
+
+	TCP_SKB_CB(prev)->end_seq +=3D shifted;
+	TCP_SKB_CB(skb)->seq +=3D shifted;
+
+	skb_shinfo(prev)->gso_segs +=3D pcount;
+	BUG_ON(skb_shinfo(skb)->gso_segs < pcount);
+	skb_shinfo(skb)->gso_segs -=3D pcount;
+
+	/* When we're adding to gso_segs =3D=3D 1, gso_size will be zero,
+	 * in theory this shouldn't be necessary but as long as DSACK
+	 * code can come after this skb later on it's better to keep
+	 * setting gso_size to something.
+	 */
+	if (!skb_shinfo(prev)->gso_size) {
+		skb_shinfo(prev)->gso_size =3D mss;
+		skb_shinfo(prev)->gso_type =3D sk->sk_gso_type;
+	}
+
+	/* CHECKME: To clear or not to clear? Mimics normal skb currently */
+	if (skb_shinfo(skb)->gso_segs <=3D 1) {
+		skb_shinfo(skb)->gso_size =3D 0;
+		skb_shinfo(skb)->gso_type =3D 0;
+	}
+
+	*flag |=3D tcp_sacktag_one(skb, sk, reord, 0, fack_count, &dummy_sack=
ed,
+				 pcount);
+
+	/* Difference in this won't matter, both ACKed by the same cumul. ACK=
 */
+	TCP_SKB_CB(prev)->sacked |=3D (TCP_SKB_CB(skb)->sacked & TCPCB_EVER_R=
ETRANS);
+
+	tcp_clear_all_retrans_hints(tp);
+
+	if (skb->len > 0) {
+		BUG_ON(!tcp_skb_pcount(skb));
+		return 0;
+	}
+
+	/* Whole SKB was eaten :-) */
+
+	TCP_SKB_CB(skb)->flags |=3D TCP_SKB_CB(prev)->flags;
+	if (skb =3D=3D tcp_highest_sack(sk))
+		tcp_advance_highest_sack(sk, skb);
+
+	tcp_unlink_write_queue(skb, sk);
+	sk_wmem_free_skb(sk, skb);
+
+	return 1;
+}
+
+/* I wish gso_size would have a bit more sane initialization than
+ * something-or-zero which complicates things
+ */
+static int tcp_shift_mss(struct sk_buff *skb)
+{
+	int mss =3D tcp_skb_mss(skb);
+
+	if (!mss)
+		mss =3D skb->len;
+
+	return mss;
+}
+
+/* Shifting pages past head area doesn't work */
+static int skb_can_shift(struct sk_buff *skb)
+{
+	return !skb_headlen(skb) && skb_is_nonlinear(skb);
+}
+
+/* Try collapsing SACK blocks spanning across multiple skbs to a singl=
e
+ * skb.
+ */
+static struct sk_buff *tcp_shift_skb_data(struct sock *sk, struct sk_b=
uff *skb,
+					  u32 start_seq, u32 end_seq,
+					  int dup_sack, int *fack_count,
+					  int *reord, int *flag)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *prev;
+	int mss;
+	int pcount =3D 0;
+	int len;
+	int in_sack;
+
+	if (!sk_can_gso(sk))
+		goto fallback;
+
+	/* Normally R but no L won't result in plain S */
+	if (!dup_sack &&
+	    (TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) =3D=3D TCPCB_SACKED_RET=
RANS)
+		goto fallback;
+	if (!skb_can_shift(skb))
+		goto fallback;
+	/* This frame is about to be dropped (was ACKed). */
+	if (!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una))
+		goto fallback;
+
+	/* Can only happen with delayed DSACK + discard craziness */
+	if (unlikely(skb =3D=3D tcp_write_queue_head(sk)))
+		goto fallback;
+	prev =3D tcp_write_queue_prev(sk, skb);
+
+	if ((TCP_SKB_CB(prev)->sacked & TCPCB_TAGBITS) !=3D TCPCB_SACKED_ACKE=
D)
+		goto fallback;
+
+	in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq) &&
+		  !before(end_seq, TCP_SKB_CB(skb)->end_seq);
+
+	if (in_sack) {
+		len =3D skb->len;
+		pcount =3D tcp_skb_pcount(skb);
+		mss =3D tcp_shift_mss(skb);
+
+		/* TODO: Fix DSACKs to not fragment already SACKed and we can
+		 * drop this restriction as unnecessary
+		 */
+		if (mss !=3D tcp_shift_mss(prev))
+			goto fallback;
+	} else {
+		if (!after(TCP_SKB_CB(skb)->end_seq, start_seq))
+			goto noop;
+		/* CHECKME: This is non-MSS split case only?, this will
+		 * cause skipped skbs due to advancing loop btw, original
+		 * has that feature too
+		 */
+		if (tcp_skb_pcount(skb) <=3D 1)
+			goto noop;
+
+		in_sack =3D !after(start_seq, TCP_SKB_CB(skb)->seq);
+		if (!in_sack) {
+			/* TODO: head merge to next could be attempted here
+			 * if (!after(TCP_SKB_CB(skb)->end_seq, end_seq)),
+			 * though it might not be worth of the additional hassle
+			 *
+			 * ...we can probably just fallback to what was done
+			 * previously. We could try merging non-SACKed ones
+			 * as well but it probably isn't going to buy off
+			 * because later SACKs might again split them, and
+			 * it would make skb timestamp tracking considerably
+			 * harder problem.
+			 */
+			goto fallback;
+		}
+
+		len =3D end_seq - TCP_SKB_CB(skb)->seq;
+		BUG_ON(len < 0);
+		BUG_ON(len > skb->len);
+
+		/* MSS boundaries should be honoured or else pcount will
+		 * severely break even though it makes things bit trickier.
+		 * Optimize common case to avoid most of the divides
+		 */
+		mss =3D tcp_skb_mss(skb);
+
+		/* TODO: Fix DSACKs to not fragment already SACKed and we can
+		 * drop this restriction as unnecessary
+		 */
+		if (mss !=3D tcp_shift_mss(prev))
+			goto fallback;
+
+		if (len =3D=3D mss) {
+			pcount =3D 1;
+		} else if (len < mss) {
+			goto noop;
+		} else {
+			pcount =3D len / mss;
+			len =3D pcount * mss;
+		}
+	}
+
+	if (!skb_shift(prev, skb, len))
+		goto fallback;
+	if (!tcp_shifted_skb(sk, prev, skb, pcount, len, *fack_count, reord,
+			     flag, mss))
+		goto out;
+
+	/* Hole filled allows collapsing with the next as well, this is very
+	 * useful when hole on every nth skb pattern happens
+	 */
+	if (prev =3D=3D tcp_write_queue_tail(sk))
+		goto out;
+	skb =3D tcp_write_queue_next(sk, prev);
+
+	if (!skb_can_shift(skb))
+		goto out;
+	if (skb =3D=3D tcp_send_head(sk))
+		goto out;
+	if ((TCP_SKB_CB(skb)->sacked & TCPCB_TAGBITS) !=3D TCPCB_SACKED_ACKED=
)
+		goto out;
+
+	len =3D skb->len;
+	if (skb_shift(prev, skb, len)) {
+		pcount +=3D tcp_skb_pcount(skb);
+		tcp_shifted_skb(sk, prev, skb, tcp_skb_pcount(skb), len,
+				*fack_count, reord, flag, mss);
+	}
+
+out:
+	*fack_count +=3D pcount;
+	return prev;
+
+noop:
+	return skb;
+
+fallback:
+	return NULL;
+}
+
 static struct sk_buff *tcp_sacktag_walk(struct sk_buff *skb, struct so=
ck *sk,
 					struct tcp_sack_block *next_dup,
 					u32 start_seq, u32 end_seq,
 					int dup_sack_in, int *fack_count,
 					int *reord, int *flag)
 {
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	struct sk_buff *tmp;
+
 	tcp_for_write_queue_from(skb, sk) {
 		int in_sack =3D 0;
 		int dup_sack =3D dup_sack_in;
@@ -1395,18 +1613,42 @@ static struct sk_buff *tcp_sacktag_walk(struct =
sk_buff *skb, struct sock *sk,
 				dup_sack =3D 1;
 		}
=20
-		if (in_sack <=3D 0)
-			in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq,
-							end_seq);
+		/* skb reference here is a bit tricky to get right, since
+		 * shifting can eat and free both this skb and the next,
+		 * so not even _safe variant of the loop is enough.
+		 */
+		if (in_sack <=3D 0) {
+			tmp =3D tcp_shift_skb_data(sk, skb, start_seq,
+						 end_seq, dup_sack,
+						 fack_count, reord, flag);
+			if (tmp !=3D NULL) {
+				if (tmp !=3D skb) {
+					skb =3D tmp;
+					continue;
+				}
+			=09
+				in_sack =3D 0;
+			} else {
+				in_sack =3D tcp_match_skb_to_sack(sk, skb,
+								start_seq,
+								end_seq);
+			}
+		}
+
 		if (unlikely(in_sack < 0))
 			break;
=20
-		if (in_sack)
+		if (in_sack) {
 			*flag |=3D tcp_sacktag_one(skb, sk, reord, dup_sack,
 						 *fack_count,
 						 &(TCP_SKB_CB(skb)->sacked),
 						 tcp_skb_pcount(skb));
=20
+			if (!before(TCP_SKB_CB(skb)->seq,
+				    tcp_highest_sack_seq(tp)))
+				tcp_advance_highest_sack(sk, skb);
+		}
+
 		*fack_count +=3D tcp_skb_pcount(skb);
 	}
 	return skb;
--=20
1.5.2.2

