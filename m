From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Sat, 21 Oct 2017 20:52:14 -0700
Message-ID: <1508644334.30291.38.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171022033808.12641-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Koichiro Den <den@klaipeden.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:52211 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbdJVDwQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 23:52:16 -0400
Received: by mail-pf0-f194.google.com with SMTP id n14so14732167pfh.8
        for <netdev@vger.kernel.org>; Sat, 21 Oct 2017 20:52:16 -0700 (PDT)
In-Reply-To: <20171022033808.12641-1-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-10-22 at 12:38 +0900, Koichiro Den wrote:
> When retransmission on TSQ handler was introduced in the commit
> f9616c35a0d7 ("tcp: implement TSQ for retransmits"), the retransmitted
> skbs' timestamps were updated on the actual transmission. In the later
> commit 385e20706fac ("tcp: use tp->tcp_mstamp in output path"), it stops
> being done so. In the commit, the comment says "We try to refresh
> tp->tcp_mstamp only when necessary", and at present tcp_tsq_handler and
> tcp_v4_mtu_reduced applies to this. About the latter, it's okay since
> it's rare enough.
> 
> About the former, even though possible retransmissions on the tasklet
> comes just after the destructor run in NET_RX softirq handling, the time
> between them could be nonnegligibly large to the extent that
> tcp_rack_advance or rto rearming be affected if other (remaining) RX,
> BLOCK and (preceding) TASKLET sofirq handlings are unexpectedly heavy.
> 
> So in the same way as tcp_write_timer_handler does, doing tcp_mstamp_refresh
> ensures the accuracy of algorithms relying on it.
> 
> Signed-off-by: Koichiro Den <den@klaipeden.com>
> ---
>  net/ipv4/tcp_output.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Very nice catch, thanks a lot Koichiro.

This IMO would target net tree, since it is a bug fix.

Fixes: 385e20706fac ("tcp: use tp->tcp_mstamp in output path")

Thanks !

We should have caught that in our regression packetdrill tests...
