From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: fix tcp_match_skb_to_sack() for unaligned SACK
 at end of an skb
Date: Wed, 18 Jun 2014 18:27:00 -0700
Message-ID: <1403141220.4559.12.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1403140503-9689-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Per Hurtig <per.hurtig@kau.se>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:41803 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756024AbaFSB1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 21:27:05 -0400
Received: by mail-wi0-f182.google.com with SMTP id bs8so2027440wib.15
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 18:27:03 -0700 (PDT)
In-Reply-To: <1403140503-9689-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-18 at 21:15 -0400, Neal Cardwell wrote:
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
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>
> ---

Thanks Neal !

Acked-by: Eric Dumazet <edumazet@google.com>

CC Per Hurtig, as we discovered this minor issue while backporting and
fully testing 
bef1909ee3ed1ca39231b260a8d3b4544ecd0c8f ("tcp: fixing TLP's FIN
recovery")
