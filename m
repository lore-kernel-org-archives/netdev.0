From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/9] netfilter: Compress hook function signatures.
Date: Fri, 03 Apr 2015 22:07:34 -0400 (EDT)
Message-ID: <20150403.220734.1272465850706339981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbbDDCHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 22:07:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently netfilter hooks have a function signature that is huge and
has many arguments.  This propagates from the hook entry points down
into the individual hook implementations themselves.

This means that if, for example, we want to change the type of one of
these arguments then we have to touch hundreds of locations.

The main initial motivation behind this is that we'd like to change
the signature of "okfn" so that a socket pointer can be passed in (and
reference counted properly) for the sake of using the proper socket
context in the case of tunnels whilst not releasing the top level user
socket from skb->sk (and thus releasing it's socket memory quota
usage) in order to accomodate this.

This also makes it clear who actually uses 'okfn', nf_queue().  It is
absolutely critical to make this obvious because any user of 'okfn'
down in these hook chains have the be strictly audited for
escapability.  Specifically, escapability of references to objects
outside of the packet processing path.  And that's exactly what
nf_queue() does via it's packet reinjection framework.

In fact this points out a bug in Jiri's original attempt to push the
socket pointer down through netfilter's okfn.  It didn't grab and drop
a reference to the socket in net/netfilter/nf_queue.c as needed.

Furthermore, so many code paths are simplified, and should in fact be
more efficient because we aren't passing in arguments that often are
simply not used by the netfilter hook at all.

Further simplifications are probably possible, but this series takes
care of the main cases.

Unfortunately I couldn't convert ebt_do_table() because ebtables is
complete and utter crap and uses ebt_do_table() outside of the hook
call chains.  But that should not be news to anyone.

Signed-off-by: David S. Miller <davem@davemloft.net>
