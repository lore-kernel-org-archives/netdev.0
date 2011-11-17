From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/5] tcp: use DSACKs that arrive when packets_out is 0
Date: Thu, 17 Nov 2011 03:34:17 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1111170323560.1205@melkinpaasi.cs.helsinki.fi>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com> <1321469885-10885-2-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1163713974-1321493657=:1205"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37054 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755243Ab1KQBeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:34:19 -0500
In-Reply-To: <1321469885-10885-2-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1163713974-1321493657=:1205
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Wed, 16 Nov 2011, Neal Cardwell wrote:

> The bug: Senders ignored DSACKs after recovery when there were no
> outstanding packets (a common scenario for HTTP servers).
> 
> The change: when there are no outstanding packets (the "no_queue" goto
> label), call tcp_fastretrans_alert() in order to use DSACKs to undo
> congestion window reductions.
> 
> Other patches in this series will provide other changes that are
> necessary to fully fix this problem.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv4/tcp_input.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index f772aaa..b49e418 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3788,6 +3788,10 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
>  	return 1;
>  
>  no_queue:
> +	/* If data was DSACKed, see if we can undo a cwnd reduction. */
> +	if (flag & FLAG_DSACKING_ACK)
> +		tcp_fastretrans_alert(sk, pkts_acked, newly_acked_sacked,
> +				      is_dupack, flag);

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

...however, there could be other undo related gotchas now added by this 
patch due to complexity of tcp_fastretrans_alert. It would probably be 
safer to just add the dsack undo related code here?

-- 
 i.
--8323329-1163713974-1321493657=:1205--
