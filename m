From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 3/3] AFS: Implement basic file write support
Date: Wed, 09 May 2007 11:25:47 +0100
Message-ID: <997.1178706347@redhat.com>
References: <20070508170051.eb4751ce.akpm@linux-foundation.org>  <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com> <20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070508170051.eb4751ce.akpm@linux-foundation.org> 
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:

> > +	BUG_ON(i_size > 0xffffffff); // TODO: use 64-bit store
> 
> You're sure this isn't user-triggerable?

Hmmm...  I'm not.  I'll whip up a patch for this.

> kmap_atomic() could be used here and is better.

Yeah.  It used to have something that slept in the middle of it, but that's no
longer there.  I'll add to the patch.

> We have this zero_user_page() thing heading in which could perhaps be used
> here also.

Okay.  I'll have a look at it once it's there.

> > +	ASSERTRANGE(wb->first, <=, index, <=, wb->last);
> 
> wow.

:-)

The assertions I've put in have been very useful.

> > +	set_page_dirty(page);
> > +
> > +	if (PageDirty(page))
> > +		_debug("dirtied");
> > +
> > +	return 0;
> > +}
> 
> One would normally run mark_inode_dirty() after any i_size_write()?

Not in this case, I assume, because set_page_dirty() ultimately calls
__mark_inode_dirty(), but I could be wrong.

> We can invalidate pages and we can truncate them and we can clean them. 
> But here we have a new operation, "killing".  I wonder what that is.

I can call it invalidation if you like, though that name is already reserved
as it were:-/  I suppose it might actually make sense for me to call
invalidatepage() myself.

> > +	if (wbc->sync_mode != WB_SYNC_NONE)
> > +		wait_on_page_writeback(page);
> 
> Didn't the VFS already do that?

I'm not entirely sure.  Looking at generic_writepages(), I guess so.  I'll
patch it out.

> > +	if (PageWriteback(page) || !PageDirty(page)) {
> > +		unlock_page(page);
> > +		return 0;
> > +	}
> 
> And some of that?

Yeah.  Seems so.  I'll patch that out too.

What I'd like to do is ditch writepage() entirely - I'm not sure it's entirely
necessary with the availability of writepages() - but I'll look at that
another time.

> I have this vague prehistoric memory that something can go wrong at the VFS
> level if the address_space writes back more pages than it was asked to. 
> But I forget what the issue was and it would be silly to have an issue
> with that anyway.  Something to keep an eye out for.

Okay.

Thanks for the 'cherry-pick'.  I'll hopefully have a revision patch for you
soon.

David
