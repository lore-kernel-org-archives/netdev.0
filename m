From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Sat, 29 Sep 2007 17:32:41 +0200
Message-ID: <46FE7019.4030705@trash.net>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50534 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753878AbXI2PdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 11:33:03 -0400
In-Reply-To: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Eric W. Biederman <ebiederm@xmission.com> wrote:
> 
>>Currently we have the call path:
>>macvlan_open -> dev_unicast_add -> __dev_set_rx_mode ->
>>       __dev_set_promiscuity -> ASSERT_RTNL -> mutex_trylock
>>
>>When mutex debugging is on taking a mutex complains if we are not
>>allowed to sleep.  At that point we have called netif_tx_lock_bh
>>so we are clearly not allowed to sleep.  Arguably this is not a
>>problem for mutex_trylock.
> 
> 
> Actually holding the TX lock here is a bug.  We're going to
> call down into the hardware with __dev_set_promiscuity, which
> may sleep (think USB NICs), so we definitely shouldn't be holding
> any spin locks.
> 
> Patrick, could we avoid taking the TX lock here somehow?


For unicast addresses its not strictly necessary since they may
only be changed under the RTNL anyway. The reason why it takes
the tx_lock is for consistency with multicast address handling,
which can't rely on the RTNL since IPv6 changes them from
BH context. The idea was that the ->set_rx_mode function should
handle both secondary unicast and multicast addresses for
simplicity.

But I don't understand the problem, if this doesn't work for
unicast addresses, why does it work for multicast addresses
and ->set_multicast_list? I had a quick look at some USB
network drivers but couldn't spot anything special ..
