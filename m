From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix zero cwnd in tcp_cwnd_reduction
Date: Wed, 06 Jan 2016 16:52:54 -0500 (EST)
Message-ID: <20160106.165254.1745372810992238038.davem@davemloft.net>
References: <1452112958-1589-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oleksandr@natalenko.name,
	ncardwell@google.com, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbcAFVw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 16:52:56 -0500
In-Reply-To: <1452112958-1589-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed,  6 Jan 2016 12:42:38 -0800

> Patch 3759824da87b ("tcp: PRR uses CRB mode by default and SS mode
> conditionally") introduced a bug that cwnd may become 0 when both
> inflight and sndcnt are 0 (cwnd = inflight + sndcnt). This may lead
> to a div-by-zero if the connection starts another cwnd reduction
> phase by setting tp->prior_cwnd to the current cwnd (0) in
> tcp_init_cwnd_reduction().
> 
> To prevent this we skip PRR operation when nothing is acked or
> sacked. Then cwnd must be positive in all cases as long as ssthresh
> is positive:
> 
> 1) The proportional reduction mode
>    inflight > ssthresh > 0
> 
> 2) The reduction bound mode
>   a) inflight == ssthresh > 0
> 
>   b) inflight < ssthresh
>      sndcnt > 0 since newly_acked_sacked > 0 and inflight < ssthresh
> 
> Therefore in all cases inflight and sndcnt can not both be 0.
> We check invalid tp->prior_cwnd to avoid potential div0 bugs.
> 
> In reality this bug is triggered only with a sequence of less common
> events.  For example, the connection is terminating an ECN-triggered
> cwnd reduction with an inflight 0, then it receives reordered/old
> ACKs or DSACKs from prior transmission (which acks nothing). Or the
> connection is in fast recovery stage that marks everything lost,
> but fails to retransmit due to local issues, then receives data
> packets from other end which acks nothing.
> 
> Fixes: 3759824da87b ("tcp: PRR uses CRB mode by default and SS mode conditionally")
> Reported-by: Oleksandr Natalenko <oleksandr@natalenko.name>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks!
