From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: tcp: lost_cnt_hint is -1 due to tcp_shifted_skb() processing
Date: Sun, 12 Feb 2012 17:13:31 -0800
Message-ID: <CAGK4HS9HxYu6TKX=hvchuxHz7C0vgfhC+2xX2+z8RQTDT1E1Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38699 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab2BMBNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 20:13:32 -0500
Received: by vbjk17 with SMTP id k17so2776502vbj.19
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2012 17:13:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

With the current net-next, I noticed tp->lost_cnt_hint is -1 in some cases which
looks like a bug.

When skb  is SACKed and contents are shifted to prev skb,
tcp_shifted_skb() is called for further processing.  tcp_shifted_skb()
increments  TCP_SKB_CB(skb)->seq before calling tcp_sacktag_one().  This
results in the wrong value for skb->seq being passed to tcp_sacktag_one().

in tcp_shifted_skb():
---snip---

        if (skb == tp->lost_skb_hint)
                tp->lost_cnt_hint += pcount;

        TCP_SKB_CB(prev)->end_seq += shifted;
        TCP_SKB_CB(skb)->seq += shifted;

        ....

        /* We discard results */
        tcp_sacktag_one(skb, sk, state, dup_sack, pcount);

---snip---

If the skb _just_ prior to lost_skb_hint is SACKed, then the skb->seq that
is passed to tcp_sacktag_one() is equal to TCP_SKB_CB(tp->lost_skb_hint)->seq).
For the non-FACK SACK case in tcp_sacktag_one() (code snippet below), the
condition fails and tp->lost_cnt_hint is not updated. Eventually, when
lost_cnt_hint is decremented, it can go to -1 (maybe even lower?).

---snip---

in sacktag_one():
         /* Lost marker hint past SACKed? Tweak RFC3517 cnt */
                if (!tcp_is_fack(tp) && (tp->lost_skb_hint != NULL) &&
                    before(TCP_SKB_CB(skb)->seq,
                           TCP_SKB_CB(tp->lost_skb_hint)->seq))
                        tp->lost_cnt_hint += pcount;

---snip---
I assume there was a specific reasoning for updating skb->seq before calling
tcp_sacktag_one(). Maybe it is not valid for lost_cnt_hint?   Can this be
fixed by moving the tcp_sacktag_one() call so that it is called before the seq
number is incremented as in:

---snip---
        if (skb == tp->lost_skb_hint)
                tp->lost_cnt_hint += pcount;

        /* We discard results */
        tcp_sacktag_one(skb, sk, state, dup_sack, pcount);

        TCP_SKB_CB(prev)->end_seq += shifted;
        TCP_SKB_CB(skb)->seq += shifted;

        ....

---snip---

There is one additional concern.  tcp_sacktag_one() also uses
TCP_SKB_CB(skb)->seq to update the reordering metric.

                                /* New sack for not retransmitted frame,
                                 * which was in hole. It is reordering.
                                 */

                                if (before(TCP_SKB_CB(skb)->seq,
                                           tcp_highest_sack_seq(tp)))
                                        state->reord = min(fack_count,
                                                           state->reord);


>From what I understand, this path for reordering also has the same flaw as
outlined above for lost_cnt_hint i.e. it is passed the wrong seq number but the
correct pcount.  However, since tp->highest_sack points to the skb *after* the
skb with highest Sack,  the reordering metric may be updated correctly.

Is lost_cnt_hint going to -1 a real bug or expected behavior? If the fix
suggested above fixes the problem, I can submit a patch.

( The code in question was introduced in commit:
832d11c5cd076abc0aa1eaf7be96c81d1a59ce41 tcp: Try to restore large SKBs while
SACK processing.)


Thanks in advance for your time and feedback.

Vijay Subramanian
