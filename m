From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage. Move away from char device ioctls.
Date: Fri, 26 Oct 2007 14:44:59 +0400
Message-ID: <20071026104459.GA15295@2ka.mipt.ru>
References: <20070914185429.GA9439@2ka.mipt.ru> <46EADC02.9070409@garzik.org> <20070915122957.GA25752@2ka.mipt.ru> <20070915172446.GC2990@schatzie.adilger.int> <AC64AEB4-4090-4E73-A53C-2ACF94B49AD5@mac.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Dilger <adilger@clusterfs.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Kyle Moffett <mrmacman_g4@mac.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AC64AEB4-4090-4E73-A53C-2ACF94B49AD5@mac.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Returning back to this, since block based storage, which can act as a
shared storage/transport layer, is ready with 5'th release of the DST.

My couple of notes on proposed data distribution algorithm in FS.

On Sun, Sep 16, 2007 at 03:07:11AM -0400, Kyle Moffett (mrmacman_g4@mac.com) wrote:
> >I actually think there is a place for this - and improvements are  
> >definitely welcome.  Even Lustre needs block-device level  
> >redundancy currently, though we will be working to make Lustre- 
> >level redundancy available in the future (the problem is WAY harder  
> >than it seems at first glance, if you allow writeback caches at the  
> >clients and servers).
> 
> I really think that to get proper non-block-device-level filesystem  
> redundancy you need to base it on something similar to the GIT  
> model.  Data replication is done in specific-sized chunks indexed by  
> SHA-1 sum and you actually have a sort of "merge algorithm" for when  
> local and remote changes differ.  The OS would only implement a very  
> limited list of merge algorithms, IE one of:
> 
> (A)  Don't merge, each client gets its own branch and merges are manual
> (B)  Most recent changed version is made the master every X-seconds/ 
> open/close/write/other-event.
> (C)  The tree at X (usually a particular client/server) is always  
> used as the master when there are conflicts.

This looks like a good way to work with offline clients (where I recall
Coda), after offline node modified data, it should be merged back to the
cluster with different algorithms.

Data (supposed to be) written to the failed node during its offline time
will be resynced from other nodes when failed one is online, there are
no problems and/or special algorithms to be used here.

Filesystem replication is not a 100% 'git way' - git tree contains
already combined objects - i.e. the last blob for given path does not
contain its history, only ready to be used data, while filesystem,
especially that one which requires simultaneous write from different
threads/nodes, should implement copy-on-write semantics, essentially
putting all new data (git commit) to the new location and then collect
it from different extents to present a ready file.

At least that is how I see the filesystem I'm working on.

...

> There's a lot of other technical details which would need resolution  
> in an actual implementation, but this is enough of a summary to give  
> you the gist of the concept.  Most likely there will be some major  
> flaw which makes it impossible to produce reliably, but the concept  
> contains the things I would be interested in for a real "networked  
> filesystem".

Git semantics and copy-on-write has actually quite a lot in common (on
high enough level of abstraction), but SHA1 index is not a possible 
issue in filesystem - even besides amount of data to be hashed before
key is ready. Key should also contain enough information about what
underlying data is - git does not store that information (tree, blob or
whatever) in its keys, since it does not require it. At least that is
how I see it to be implemented.

Overall I see this new project as a true copy-on-write FS.

Thanks.

> Cheers,
> Kyle Moffett

-- 
	Evgeniy Polyakov
