From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Tue, 12 Jun 2012 13:44:40 +0200
Message-ID: <20120612114440.GM27795@secunet.com>
References: <20120611.042024.1022194952800114410.davem@davemloft.net>
 <20120611.042813.401909584318598192.davem@davemloft.net>
 <20120611114256.GL27795@secunet.com>
 <20120611.160258.866525532025442350.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49376 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751593Ab2FLLos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2012 07:44:48 -0400
Content-Disposition: inline
In-Reply-To: <20120611.160258.866525532025442350.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 11, 2012 at 04:02:58PM -0700, David Miller wrote:
> 
> Here below is the kind of patch I was suggesting we make.  I did a
> simple test to make sure the update MTU code path is taken in
> raw_err().

I can confirm that your patch restores the old behaviour of ping.

> 
> But I'm having second thoughts about whether any of this is a good
> idea.
> 
> UDP works by notifying userspace of PMTU events.  And this is
> mandatory, if we're setting DF we have to get the user to decrease the
> size of it's datagram writes below the reported PMTU value.
> 
> As a consequence I believe RAW sockets should also work via
> notifications.
> 
> And therefore it can be argued that in neither case should we update
> the routing cache PMTU information.  

Should be ok as long as all userspace applications that use UDP or
RAW sockets handle pmtu event notifications properly.

ping might be a special case, but now the behaviour of a big
sized ping (say 1400 byte on a network that has a router with
mtu 1300 along the path) with IP_PMTUDISC_WANT might depend on
whether the cached pmtu informations are updated by a recent
tcp connection.

If we had no tcp connection before, we see the behaviour that
I described in my first mail. All packets have the DF bit set.

If a tcp connection updated the cached pmtu informations recently,
the packets don't have the DF bit set. They are fragmented according
the cached pmtu informations instead.

Other applications that do not care for pmtu event notifications
might be in a similar situation. So perhaps we need the kind of
patch you are suggested.
