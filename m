From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [ANN] Unified dynamic storage for different socket types instead of separate hash tables.
Date: Tue, 27 Mar 2007 17:35:33 +0400
Message-ID: <20070327133532.GA24398@2ka.mipt.ru>
References: <20070322185944.GA3802@2ka.mipt.ru> <20070322.120346.41643926.davem@davemloft.net> <20070322191449.GA25274@2ka.mipt.ru> <20070322.122120.115923509.davem@davemloft.net> <p73bqie69ze.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54020 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753837AbXC0NgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 09:36:00 -0400
Content-Disposition: inline
In-Reply-To: <p73bqie69ze.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2007 at 04:23:49PM +0200, Andi Kleen (andi@firstfloor.org) wrote:
> > 2) An extra list insert/delete to give list of all sockets
> 
> That is currently limited by readlock on the hash buckets. I suspect
> any change to a trie with less atomic operations will make it faster.

The best case for trie is to attach a bitmask of used/free slots per
each trie node since it is based on arrays, so that list is not needed
at all. I thought about additional list of all sockets just because I
decided to not drop one of the hlist_node from sock_common, so it could
be reused for other purposes.
That hlist node is used for netlink broadcasting, but netlink case can 
be solved by moving sk_bind_node into private area and drop additional 
8/16 bytes from socket structure.

Trie nodes are protected through RCU, so it is possible to count
not-yet-freed socket as long as miss just-added ones.
I do not think this information can contain anyhow correct information,
since we have essentially the same problem with hash bucket locks -
until bucket is locked, we can not count for just-to-be-added sockets
and count those ones which will be dropped just after lock is released
in case removing function spins/waits for that bucket.

> -Andi

-- 
	Evgeniy Polyakov
