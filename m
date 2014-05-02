From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: fix cwnd limited checking to improve
 congestion control
Date: Fri, 02 May 2014 17:55:46 -0400 (EDT)
Message-ID: <20140502.175546.28469480433554767.davem@davemloft.net>
References: <1398874919.29914.175.camel@edumazet-glaptop2.roam.corp.google.com>
	<1398884293.29914.181.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbaEBVzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 17:55:48 -0400
In-Reply-To: <1398884293.29914.181.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Apr 2014 11:58:13 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Yuchung discovered tcp_is_cwnd_limited() was returning false in
> slow start phase even if the application filled the socket write queue.
> 
> All congestion modules take into account tcp_is_cwnd_limited()
> before increasing cwnd, so this behavior limits slow start from
> probing the bandwidth at full speed.
> 
> The problem is that even if write queue is full (aka we are _not_
> application limited), cwnd can be under utilized if TSO should auto
> defer or TCP Small queues decided to hold packets.
> 
> So the in_flight can be kept to smaller value, and we can get to the
> point tcp_is_cwnd_limited() returns false.
> 
> With TCP Small Queues and FQ/pacing, this issue is more visible.
> 
> We fix this by having tcp_cwnd_validate(), which is supposed to track
> such things, take into account unsent_segs, the number of segs that we
> are not sending at the moment due to TSO or TSQ, but intend to send
> real soon. Then when we are cwnd-limited, remember this fact while we
> are processing the window of ACKs that comes back.
> 
> For example, suppose we have a brand new connection with cwnd=10; we
> are in slow start, and we send a flight of 9 packets. By the time we
> have received ACKs for all 9 packets we want our cwnd to be 18.
> We implement this by setting tp->lsnd_pending to 9, and
> considering ourselves to be cwnd-limited while cwnd is less than
> twice tp->lsnd_pending (2*9 -> 18).
> 
> This makes tcp_is_cwnd_limited() more understandable, by removing
> the GSO/TSO kludge, that tried to work around the issue.
> 
> Note the in_flight parameter can be removed in a followup cleanup
> patch.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks Eric.

Indeed, once you remove the in_flight parameter from tcp_is_cwnd_limited()
you can subsequently delete it from the ->cong_avoid() method signature
and implementations.
