From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 1 May 2007 20:20:50 +0400
Message-ID: <20070501162050.GB21896@2ka.mipt.ru>
References: <20070501151354.GB1751@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49757 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754336AbXEAQ0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 12:26:18 -0400
Content-Disposition: inline
In-Reply-To: <20070501151354.GB1751@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 11:13:54AM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> Hello,

Hi Benjamin.

> While testing a failover scenario, I managed to trigger an ack storm 
> between a Linux box and another system.  Although the cause of this particular 
> ACK storm was due to the other box forgetting that it sent out a FIN (the 
> second node was unaware of the FIN the first sent in its dying gasp, which 
> is what I'm trying to fix, but it's a tricky race), the resulting Linux 
> behaviour wasn't very robust.  Is there any particularly good reason that 
> FIN flag gets cleared on a connection which is being shut down?  The trace 
> that motivates this can be seen at 
> http://www.kvack.org/~bcrl/ack-storm.log .  As near as I can tell, a 
> similar effect can occur between two Linux boxes if the right packets get 
> reordered/dropped during connection teardown.

Could you archive 24Mb file or cut more precise bits out of it?

> +++ b/net/ipv4/tcp_output.c
> -	TCP_SKB_CB(skb)->flags = flags & ~(TCPCB_FLAG_FIN|TCPCB_FLAG_PSH);
> +	TCP_SKB_CB(skb)->flags = flags & ~(TCPCB_FLAG_PSH);

Will it break 793 RFC:

while the FIN is considered
to occur after the last actual data octet in a segment in which it occurs.

...

In this case, a FIN segment can be constructed and placed on the
outgoing segment queue.  No further SENDs from the user will be
accepted by the TCP, and it enters the FIN-WAIT-1 state.
RECEIVEs are allowed in this state.  All segments preceding and
including FIN will be retransmitted until acknowledged.  When the
other TCP has both acknowledged the FIN and sent a FIN of its
own, the first TCP can ACK this FIN.  Note that a TCP receiving
a FIN will ACK but not send its own FIN until its user has
CLOSED the connection also.

According to your patch, several packets with fin bit might be sent,
including one with data. If another host does not receive fin
retransmit, then that logic is broken, and it can not be fixed by
duplicating fins, I would even say, that remote box should drop second
packet with fin, while it can carry data, which will break higher
connection logic.

-- 
	Evgeniy Polyakov
