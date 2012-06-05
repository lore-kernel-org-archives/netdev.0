From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: fix a race in inetpeer_gc_worker()
Date: Tue, 05 Jun 2012 14:56:06 +0200
Message-ID: <1338900966.2760.2596.camel@edumazet-glaptop>
References: <1338888507.2760.2146.camel@edumazet-glaptop>
	 <20120605115640.GC27795@secunet.com>
	 <1338898752.2760.2482.camel@edumazet-glaptop>
	 <20120605124257.GE27795@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59110 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755897Ab2FEM4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 08:56:11 -0400
Received: by bkcji2 with SMTP id ji2so4559962bkc.19
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2012 05:56:10 -0700 (PDT)
In-Reply-To: <20120605124257.GE27795@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 14:42 +0200, Steffen Klassert wrote:
> On Tue, Jun 05, 2012 at 02:19:12PM +0200, Eric Dumazet wrote:
> > On Tue, 2012-06-05 at 13:56 +0200, Steffen Klassert wrote:
> > > On Tue, Jun 05, 2012 at 11:28:27AM +0200, Eric Dumazet wrote:
> > > > From: Eric Dumazet <edumazet@google.com>
> > > > 
> > > > commit 5faa5df1fa2024 (inetpeer: Invalidate the inetpeer tree along with
> > > > the routing cache) added a race :
> > > > 
> > > > Before freeing an inetpeer, we must respect a RCU grace period, and make
> > > > sure no user will attempt to increase refcnt.
> > > > 
> > > 
> > > As already mentioned in the other mail. In this case, I think
> > > we can just delete the inetpeer once the refcount got zero.
> > > 
> > 
> > Nope, a concurrent lookup can find an entry about to be freed.
> 
> Hm, I agree that we need rcu protection when we remove single entries
> from an inetpeer tree. But in this case we invalidate the entire tree.
> 
> The first lookup after inetpeer_invalidate_tree() was invoked should
> find an empty tree, base->root initialized to peer_avl_empty_rcu.
> 
> Maybe I'm wrong, but I don't see how a lookup should find such an
> old invalidated tree.
> 

You are absolutely wrong yes.

A concurrent lookup can read previous values of the root pointer, even
if you wrote a new value in it. Thats whole RCU point.

Only waiting a rcu grace period make sure all lookups can see the new
root pointer.

I'll send a v2 to avoid atomics in the worker itself.
