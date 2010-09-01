From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 1 Sep 2010 21:11:06 +0200
Message-ID: <20100901191106.GB25227@midget.suse.cz>
References: <20136.1283288063@death>
 <20100901122356.GB9468@ff.dom.local>
 <20100901133056.GB12447@midget.suse.cz>
 <20100901151856.GB3091@del.dom.local>
 <20100901153730.GC3091@del.dom.local>
 <20100901190037.GA3030@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, markine@google.com,
	chavey@google.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:48346 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753835Ab0IATJb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 15:09:31 -0400
Content-Disposition: inline
In-Reply-To: <20100901190037.GA3030@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 09:00:37PM +0200, Jarek Poplawski wrote:
> On Wed, Sep 01, 2010 at 05:37:30PM +0200, Jarek Poplawski wrote:
> > On Wed, Sep 01, 2010 at 05:18:56PM +0200, Jarek Poplawski wrote:
> > > On Wed, Sep 01, 2010 at 03:30:56PM +0200, Jiri Bohac wrote:
> > > > On Wed, Sep 01, 2010 at 12:23:56PM +0000, Jarek Poplawski wrote:
> > > > > On 2010-08-31 22:54, Jay Vosburgh wrote:
> > > > > > 	What prevents this from deadlocking such that cpu A is in
> > > > > > bond_close, holding RTNL and in cancel_delayed_work_sync, while cpu B is
> > > > > > in the above function, trying to acquire RTNL?
> > > > > 
> > > > > I guess this one isn't cancelled in bond_close, so it should be safe.
> > > > 
> > > > Nah, Jay was correct. Although this work item is not explicitly
> > > > cancelled with cancel_delayed_work_sync(), it is on the same
> > > > workqueue as work items that are being cancelled with
> > > > cancel_delayed_work_sync(), so this can still cause a deadlock.
> > > > Fixed in the new version of the patch by putting these on a
> > > > separate workqueue.
> > > > 
> > > 
> > > Maybe I miss something, but the same workqueue shouldn't matter here.
> > 
> > Hmm... I missed your point completely and Jay was correct!
> 
> Hmm#2... Alas, after getting back my sobriety, I've to say that Jay
> was wrong: the same workqueue shouldn't matter here. Similar things
> are done by other network code with the kernel-global workqueue, eg.
> in tg3_close(), rhine_close() etc. 

But these don't do rtnl_lock() inside the work item, do they?
That is the main issue here: dev_close() is called with rtnl held
and so it cannot wait for completion of work items that grab rtnl
themselves.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

