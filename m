From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: kernel 2.6.23.8: KERNEL: assertion in net/ipv4/tcp_input.c
Date: Mon, 3 Dec 2007 15:34:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712030840540.26423@kivilampi-30.cs.helsinki.fi>
References: <200712030100.26283.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56818 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbXLCNex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 08:34:53 -0500
In-Reply-To: <200712030100.26283.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Dec 2007, Wolfgang Walter wrote:

> with kernel 2.6.23.8 we saw a
> 
> KERNEL: assertion ((int)tcp_packets_in_flight(tp) >= 0) failed at 
> net/ipv4/tcp_input.c (1292)

Is this the only message? Are there any Leak printouts?
Any tweaking done to TCP related sysctls?
And for completeness, is GSO enabled (ethtool -k)?

Most likely I broke the manual synchronization for left_out in sacktag by 
skipping over it when packets_out == 0 but so far I haven't been able to 
figure out how such state could develop in the first place... Ie., I 
couldn't find a case where tcp_fastretrans_alert wouldn't be called if 
left_out was non-zero (and it did the sync_left_out after modifying
either sacked_out or lost_out, IIRC).

...If you can reproduce it, you could try if this patch below changes 
anything (should silence the assert and trigger earlier a WARN_ON or
two :-)). ...If this triggers, then I'm sure we can pollute TCP code
by a larger number of more costly checks to catch it in early.

This might reveal a long-standing inconsistency of left_out in some
case I just couldn't come up with by code review. Left_out will be
(is) anyway dropped as unnecessary in 2.6.24. In 2.6.23 sync for
left_out occurs quite soon after that BUG_TRAP anyway so the effect
won't be too dramatic, prior_in_flight would be once stale, won't
lead to big problems (either missed cnwd or cwnd_cnt increment, or
failure to do application limited check at that particular ACK).

Thanks anyway for the report. ...If I figure something out here, I'll
let you know.

--

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c9298a7..0c5194d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1012,8 +1012,12 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_window))
 		return 0;
 
-	if (!tp->packets_out)
+	if (!tp->packets_out) {
+		WARN_ON(tp->sacked_out);
+		WARN_ON(tp->lost_out);
+		WARN_ON(tp->left_out);
 		goto out;
+	}
 
 	/* SACK fastpath:
 	 * if the only SACK change is the increase of the end_seq of
@@ -1277,14 +1281,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		}
 	}
 
+out:
+
 	tp->left_out = tp->sacked_out + tp->lost_out;
 
 	if ((reord < tp->fackets_out) && icsk->icsk_ca_state != TCP_CA_Loss &&
 	    (!tp->frto_highmark || after(tp->snd_una, tp->frto_highmark)))
 		tcp_update_reordering(sk, ((tp->fackets_out + 1) - reord), 0);
 
-out:
-
 #if FASTRETRANS_DEBUG > 0
 	BUG_TRAP((int)tp->sacked_out >= 0);
 	BUG_TRAP((int)tp->lost_out >= 0);
