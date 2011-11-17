From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/5] tcp: use SACKs and DSACKs that arrive on ACKs below
 snd_una
Date: Thu, 17 Nov 2011 03:52:37 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111170344580.1205@melkinpaasi.cs.helsinki.fi>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com> <1321469885-10885-3-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-769977581-1321494757=:1205"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44219 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965Ab1KQBwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:52:39 -0500
In-Reply-To: <1321469885-10885-3-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-769977581-1321494757=:1205
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Wed, 16 Nov 2011, Neal Cardwell wrote:

> The bug: When the ACK field is below snd_una (which can happen when
> ACKs are reordered), senders ignored DSACKs (preventing undo) and did
> not call tcp_fastretrans_alert, so they did not increment
> prr_delivered to reflect newly-SACKed sequence ranges, and did not
> call tcp_xmit_retransmit_queue, thus passing up chances to send out
> more retransmitted and new packets based on any newly-SACKed packets.
> 
> The change: When the ACK field is below snd_una (the "old_ack" goto
> label), call tcp_fastretrans_alert to allow undo based on any
> newly-arrived DSACKs and try to send out more packets based on
> newly-SACKed packets.
> 
> Other patches in this series will provide other changes that are
> necessary to fully fix this problem.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv4/tcp_input.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index b49e418..751d390 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3805,10 +3805,14 @@ invalid_ack:
>  	return -1;
>  
>  old_ack:
> +	/* If data was SACKed, tag it and see if we should send more data.
> +	 * If data was DSACKed, see if we can undo a cwnd reduction.
> +	 */
>  	if (TCP_SKB_CB(skb)->sacked) {
> -		tcp_sacktag_write_queue(sk, skb, prior_snd_una);
> -		if (icsk->icsk_ca_state == TCP_CA_Open)
> -			tcp_try_keep_open(sk);
> +		flag |= tcp_sacktag_write_queue(sk, skb, prior_snd_una);
> +		newly_acked_sacked = tp->sacked_out - prior_sacked;
> +		tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
> +				      is_dupack, flag);

I gave FLAG_* some thought and couldn't find something that would go wrong 
here (due to goto not all flag enablers are checked for).

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

...unrelated to the fix, I realized that FRTO is not fully thought through 
in this old ACK case, also its RFC seems to lack considerations on what to 
do in such case. ...I'll need to think the FRTO stuff a bit more.

-- 
 i.
--8323329-769977581-1321494757=:1205--
