From: Thomas Graf <tgraf@suug.ch>
Subject: Re: using rhashtable in inethash
Date: Tue, 26 Aug 2014 00:33:46 +0100
Message-ID: <20140825233346.GF30140@casper.infradead.org>
References: <20140825.161224.1108200625385309828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46695 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHYXdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 19:33:47 -0400
Content-Disposition: inline
In-Reply-To: <20140825.161224.1108200625385309828.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/14 at 04:12pm, David Miller wrote:
> During the Networking Workshop I mentioned converting the inet hash
> tables over to rhashtable so that we don't allocate this insanely
> large hash table at boot time which goes largely unused.

> I took a quick look at this last night and the only thing we really
> need is the addition of a set of rhashtable interfaces which use
> NULLs lists, as the inet hashtables currently require.

Eric brought this up as well last week. I see no problem using
a non-NULL token as the default to identify the end of the list.

We had a quick sitdown with Paul E. McKenney and came up with
some ideas that should allow doing that even with resizes taking
place by using the hash of the entry as the token.

We also discussed the possibility to do the resizing outside of
the insert/remove context and move it to a worker thread using
per bucket locks. We think that we may have found something that
might work and I will give that a shot. It will allow to use a
resizing rhashtable with the insert/remove being in atomic
context which I believe is needed for the inet cache.

> Also, I noticed in the netlink changes this really expensive
> synchronize_net() added to netlink_release(), is that _really_
> necessary?
>
> 
> That's really expensive and my impression was that such a sync is only
> needed during hash table resizing, not when getting rid of objects
> that we in an rhashtable.

The reason I added added the sync is because I could not see how
else to prevent the sock_put() in netlink_release() to release
socket memoray, specifically the embedded rhash_head, that is
possibly being accessed in a RCU protected reader traversing the
bucket. Such a reader would not hold a reference to the socket.
I may be missing something though and I'm happy to change this for
something better.
