From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Tue, 20 Dec 2011 09:03:41 +0100
Message-ID: <20111220080341.GM6348@secunet.com>
References: <20111216122147.GJ6348@secunet.com>
 <4EEB5602.2060806@iki.fi>
 <20111219135259.GK6348@secunet.com>
 <20111219.150903.108164273331779302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37329 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751610Ab1LTIDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Dec 2011 03:03:43 -0500
Content-Disposition: inline
In-Reply-To: <20111219.150903.108164273331779302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2011 at 03:09:03PM -0500, David Miller wrote:
> 
> Actually, adding yet another ID is pointless.
> 
> Just get rid of redirect_genid, and use net->ipv4.rt_genid for all of
> the necessary purposes.  

I already thought about such a solution, but is this really save?

What if somebody adds/deletes/flushes routes? rt_cache_invalidate()
is invoked and we increment net->ipv4.rt_genid. Then an icmp redirect
may appear and we call ip_rt_redirect() which sets the id on the
inetpeer to the new value of net->ipv4.rt_genid. After that,
ipv4_validate_peer() will find the generation id in proper state
and does not invalidate the learned pmtu value.

I think we could either have two separate generation ids for
pmtu and redirect handling, or we could handle both cases together
by accumulating check_peer_redir() and check_peer_pmtu() into a
check_peer() function. But the latter seems to be a bit too extensive
for a simple bug fix.
