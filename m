From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] tcp: abort orphan sockets stalling on zero
 window probes
Date: Wed, 01 Oct 2014 16:28:18 -0400 (EDT)
Message-ID: <20141001.162818.2113231293600688267.davem@davemloft.net>
References: <1412022038-14408-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, andrey.dmitrov@oktetlabs.ru,
	ncardwell@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573AbaJAU2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:28:21 -0400
In-Reply-To: <1412022038-14408-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 29 Sep 2014 13:20:38 -0700

> Currently we have two different policies for orphan sockets
> that repeatedly stall on zero window ACKs. If a socket gets
> a zero window ACK when it is transmitting data, the RTO is
> used to probe the window. The socket is aborted after roughly
> tcp_orphan_retries() retries (as in tcp_write_timeout()).
> 
> But if the socket was idle when it received the zero window ACK,
> and later wants to send more data, we use the probe timer to
> probe the window. If the receiver always returns zero window ACKs,
> icsk_probes keeps getting reset in tcp_ack() and the orphan socket
> can stall forever until the system reaches the orphan limit (as
> commented in tcp_probe_timer()). This opens up a simple attack
> to create lots of hanging orphan sockets to burn the memory
> and the CPU, as demonstrated in the recent netdev post "TCP
> connection will hang in FIN_WAIT1 after closing if zero window is
> advertised." http://www.spinics.net/lists/netdev/msg296539.html
> 
> This patch follows the design in RTO-based probe: we abort an orphan
> socket stalling on zero window when the probe timer reaches both
> the maximum backoff and the maximum RTO. For example, an 100ms RTT
> connection will timeout after roughly 153 seconds (0.3 + 0.6 +
> .... + 76.8) if the receiver keeps the window shut. If the orphan
> socket passes this check, but the system already has too many orphans
> (as in tcp_out_of_resources()), we still abort it but we'll also
> send an RST packet as the connection may still be active.
> 
> In addition, we change TCP_USER_TIMEOUT to cover (life or dead)
> sockets stalled on zero-window probes. This changes the semantics
> of TCP_USER_TIMEOUT slightly because it previously only applies
> when the socket has pending transmission.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Reported-by: Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>

Applied, thanks a lot.
