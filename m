From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Mon, 23 Apr 2012 23:38:21 +0200
Message-ID: <1335217101.5205.79.camel@edumazet-glaptop>
References: <1335201795.5205.35.camel@edumazet-glaptop>
	 <20120423.160149.1515408777176168288.davem@davemloft.net>
	 <1335213446.5205.65.camel@edumazet-glaptop>
	 <20120423.170101.1369764871919045849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org, therbert@google.com,
	ncardwell@google.com, maze@google.com, ycheng@google.com,
	ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:35676 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755631Ab2DWViZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 17:38:25 -0400
Received: by wejx9 with SMTP id x9so2604wej.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 14:38:24 -0700 (PDT)
In-Reply-To: <20120423.170101.1369764871919045849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-23 at 17:01 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 23 Apr 2012 22:37:26 +0200
> 
> > We could try to coalesce ACKs before backlogging them. I'll work on
> > this.
> 
> Great idea, although I wonder about the effect this could have on RTT
> measurements.  Instead of having N RTT measurements, we'd have just
> one.
> 
> Granted, what happens right now wrt. RTT measurements with such huge
> ACK backlogs isn't all that nice either.
> 
> Ideally, perhaps, we'd do a timestamp diff at the time we insert the
> packet into the backlog.  That way we wouldn't gain the RTT inaccuracy
> introduced by such queueing delays and ACK backlogs.
> 
> Another way to look at it is that the coalesced scheme would actually
> improve RTT measurements, since the most accurate (and least
> "delayed") of the timestamps would be the only one processed :-)

The big part of the work is not doing the coalesce, but also counting
the number of ACKS that are going to be carried into TCP stack if we
want cwnd being updated correctly.

Basically I'll have to add a new skb field (in cb[]) to properly count
number of ACKS 'included' in a single packet.

About the RTT, some congestion modules need TCP_CONG_RTT_STAMP but time
is taken when backlog processing is done, that is after backlog in/out
