From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: remove bad timeout logic in fast recovery
Date: Fri, 17 May 2013 18:46:43 -0700
Message-ID: <1368841603.3301.131.camel@edumazet-glaptop>
References: <1368834305-29849-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com, ilpo.jarvinen@cs.helsinki.fi,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f52.google.com ([209.85.210.52]:33412 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390Ab3ERBqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 21:46:45 -0400
Received: by mail-da0-f52.google.com with SMTP id o9so2684495dan.25
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 18:46:45 -0700 (PDT)
In-Reply-To: <1368834305-29849-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 16:45 -0700, Yuchung Cheng wrote:
> tcp_timeout_skb() was intended to trigger fast recovery on timeout,
> unfortunately in reality it often causes spurious retransmission
> storms during fast recovery. The particular sign is fast retransmit
> over highest sacked sequence (SND.FACK).
> 
> Currently the RTO timer re-arming (as in RFC6298) offers a nice cushion
> to avoid spurious timeout: when SND.UNA advances the sender re-arms
> RTO and extends the timeout by icsk_rto. The sender does not offset
> the time elapsed since the packet at SND.UNA was sent.
> 
> But if the next (DUP)ACK arrives later than ~RTTVAR and triggers
> tcp_fastretrans_alert(), then tcp_timeout_skb() will mark any packet
> sent before icsk_rto interval lost, including one that's above the
> highest sacked sequence. Most likely a large part of scorebard will
> be marked.
> 
> If most packets are not lost then the subsequence DUPACKs with new
> SACK blockes will cause the sender to continue retransmit packets
> beyond SND.FACK spuriously right. Even only one packet is lost the
> sender may falsely retransmit almost the entire window.
> 
> The situation becomes common in the world of bufferbloat: the RTT
> continues to grow as the queue builds up but RTTVAR remains small and
> close to the minimum 200ms. If a data packet is lost and the DUPACK
> triggered by the next data packet is slightly delayed, then a spurious
> retransmission storm forms.
> 
> As the original comment on tcp_timeout_skb() suggests: the usefulness
> of this feature is questionable. It also wastes cycles walking the
> sack scoreboard and is actually harmful because of the false recovery.
> It's time to remove this.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  include/linux/tcp.h  |  1 -
>  include/net/tcp.h    |  1 -
>  net/ipv4/tcp_input.c | 65 +---------------------------------------------------
>  3 files changed, 1 insertion(+), 66 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
