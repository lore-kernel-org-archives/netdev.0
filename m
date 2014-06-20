From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix tcp_match_skb_to_sack() for unaligned
 SACK at end of an skb
Date: Thu, 19 Jun 2014 20:53:55 -0700 (PDT)
Message-ID: <20140619.205355.1845701003139639.davem@davemloft.net>
References: <1403140503-9689-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
	ilpo.jarvinen@helsinki.fi
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932480AbaFTDyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 23:54:02 -0400
In-Reply-To: <1403140503-9689-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Wed, 18 Jun 2014 21:15:03 -0400

> If there is an MSS change (or misbehaving receiver) that causes a SACK
> to arrive that covers the end of an skb but is less than one MSS, then
> tcp_match_skb_to_sack() was rounding up pkt_len to the full length of
> the skb ("Round if necessary..."), then chopping all bytes off the skb
> and creating a zero-byte skb in the write queue.
> 
> This was visible now because the recently simplified TLP logic in
> bef1909ee3ed1c ("tcp: fixing TLP's FIN recovery") could find that 0-byte
> skb at the end of the write queue, and now that we do not check that
> skb's length we could send it as a TLP probe.
> 
> Consider the following example scenario:
> 
>  mss: 1000
>  skb: seq: 0 end_seq: 4000  len: 4000
>  SACK: start_seq: 3999 end_seq: 4000
> 
> The tcp_match_skb_to_sack() code will compute:
> 
>  in_sack = false
>  pkt_len = start_seq - TCP_SKB_CB(skb)->seq = 3999 - 0 = 3999
>  new_len = (pkt_len / mss) * mss = (3999/1000)*1000 = 3000
>  new_len += mss = 4000
> 
> Previously we would find the new_len > skb->len check failing, so we
> would fall through and set pkt_len = new_len = 4000 and chop off
> pkt_len of 4000 from the 4000-byte skb, leaving a 0-byte segment
> afterward in the write queue.
> 
> With this new commit, we notice that the new new_len >= skb->len check
> succeeds, so that we return without trying to fragment.
> 
> Fixes: adb92db857ee ("tcp: Make SACK code to split only at mss boundaries")
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks Neal.
