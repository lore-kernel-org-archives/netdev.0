From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Who's allowed to set a skb destructor?
Date: Fri, 6 Jul 2007 09:47:20 +0200
Message-ID: <20070706074720.GA2362@ff.dom.local>
References: <p733b032mec.fsf@bingen.suse.de> <20070705122849.GA4759@ff.dom.local> <20070705130640.GA24731@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brice Goglin <Brice.Goglin@ens-lyon.org>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Divy Le Ray <divy@chelsio.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:59504 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760829AbXGFHiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 03:38:51 -0400
Content-Disposition: inline
In-Reply-To: <20070705130640.GA24731@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 03:06:40PM +0200, Andi Kleen wrote:
> On Thu, Jul 05, 2007 at 02:28:50PM +0200, Jarek Poplawski wrote:
> > I wonder if it's very unsound to think about a one way list
> > of destructors. Of course, not owners could only clean their
> > private allocations. Woudn't this save some skb clonning,
> > copying or adding new fields for private infos?
> 
> skb cloning isn't very expensive when you need it. And they
> got a little private area you can use for your own stuff 
> while you have it queued (skb->cb) 
> 
> As a historical note one of the big changes during the Linux 2.0
> and 2.1 TCP rewrite was that TCP was changed to always clone for the
> retransmit queue. This cleaned up the code greatly and fixed
> many problems. Cloning was also especially optimized for this. When TCP 
> which is about one of the most performance critical protocols around can 
> afford it likely other code can too.

I've thought about this a bit more, and, if I don't miss something,
there is a possibility to use these things together: let's imagine
such simplified api:

- a driver which needs a bit of space to track skbs in a few places,
  registers itself with some function telling the size, maybe a
  callback/destructor and maybe a protocol id; some index is returned;
- if this is the first one registered, api allocates new space using
  skb clonning or some similar slab pool, to get blank space, and
  reserves space for this driver according to the index (internally
  mapped to some offset); since this moment every new skb is
  automatically 'cloned' and the driver can read/write its place using
  the api to map the requests;
- next registered drivers use the same 'clone', unless there is no
  more space, so next 'clones' are generated;
- the lifetime of such 'clones' is controlled similarly to the 'real 
  clones'; with the most basic version destructors could be avoided;
- some indexes could be made public constants to allow sharing.

Is this wrong?

Regards,
Jarek P.
