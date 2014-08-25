From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: using rhashtable in inethash
Date: Mon, 25 Aug 2014 16:35:35 -0700
Message-ID: <1409009735.3173.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140825.161224.1108200625385309828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36074 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148AbaHYXfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 19:35:37 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so22161423pab.20
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 16:35:36 -0700 (PDT)
In-Reply-To: <20140825.161224.1108200625385309828.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-08-25 at 16:12 -0700, David Miller wrote:
> During the Networking Workshop I mentioned converting the inet hash
> tables over to rhashtable so that we don't allocate this insanely
> large hash table at boot time which goes largely unused.
> 
> I took a quick look at this last night and the only thing we really
> need is the addition of a set of rhashtable interfaces which use
> NULLs lists, as the inet hashtables currently require.
> 
> Also, I noticed in the netlink changes this really expensive
> synchronize_net() added to netlink_release(), is that _really_
> necessary?
> 
> That's really expensive and my impression was that such a sync is only
> needed during hash table resizing, not when getting rid of objects
> that we in an rhashtable.
> 
> Thomas?

After the workshop we had a discussion with Paul McKenney, Thomas, and
John where we discussed all this.

An other issue we raised was that the grow should happen in process
context, while inserts and deletes should happen from softirq.

We also mentioned the need of a per bucket spinlock, and keep the mutex
only to protect the resizes. (Or an array of spinlocks as used by TCP)

Paul gave a lot of ideas and this seems feasible.

Thomas agreed to work on all this. If not I can do this myself.

(Note that conntrack also uses the same nulls rcu hash tables)
