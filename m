From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] AFS: Implement basic file write support
Date: Tue, 8 May 2007 17:00:51 -0700
Message-ID: <20070508170051.eb4751ce.akpm@linux-foundation.org>
References: <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com>
	<20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 08 May 2007 20:44:11 +0100
David Howells <dhowells@redhat.com> wrote:

> Implement support for writing to regular AFS files, including:
> 
>  (1) write
> 
>  (2) truncate
> 
>  (3) fsync, fdatasync
> 
>  (4) chmod, chown, chgrp, utime.
> 
> AFS writeback attempts to batch writes into as chunks as large as it can manage
> up to the point that it writes back 65535 pages in one chunk or it meets a
> locked page.
> 
> Furthermore, if a page has been written to using a particular key, then should
> another write to that page use some other key, the first write will be flushed
> before the second is allowed to take place.  If the first write fails due to a
> security error, then the page will be scrapped and reread before the second
> write takes place.
> 
> If a page is dirty and the callback on it is broken by the server, then the
> dirty data is not discarded (same behaviour as NFS).
> 
> Shared-writable mappings are not supported by this patch.


The below isn't a review - it's some random cherrypickling.

> ...
>
> +int afs_fs_store_data(struct afs_server *server, struct afs_writeback *wb,
> +		      pgoff_t first, pgoff_t last,
> +		      unsigned offset, unsigned to,
> +		      const struct afs_wait_mode *wait_mode)
> +{
> +	struct afs_vnode *vnode = wb->vnode;
> +	struct afs_call *call;
> +	loff_t size, pos, i_size;
> +	__be32 *bp;
> +
> +	_enter(",%x,{%x:%u},,",
> +	       key_serial(wb->key), vnode->fid.vid, vnode->fid.vnode);
> +
> +	size = to - offset;
> +	if (first != last)
> +		size += (loff_t)(last - first) << PAGE_SHIFT;
> +	pos = (loff_t)first << PAGE_SHIFT;
> +	pos += offset;
> +
> +	i_size = i_size_read(&vnode->vfs_inode);
> +	if (pos + size > i_size)
> +		i_size = size + pos;
> +
> +	_debug("size %llx, at %llx, i_size %llx",
> +	       (unsigned long long) size, (unsigned long long) pos,
> +	       (unsigned long long) i_size);
> +
> +	BUG_ON(i_size > 0xffffffff); // TODO: use 64-bit store

You're sure this isn't user-triggerable?

> +static int afs_prepare_page(struct afs_vnode *vnode, struct page *page,
> +			    struct key *key, unsigned offset, unsigned to)
> +{
> +	unsigned eof, tail, start, stop, len;
> +	loff_t i_size, pos;
> +	void *p;
> +	int ret;
> +
> +	_enter("");
> +
> +	if (offset == 0 && to == PAGE_SIZE)
> +		return 0;
> +
> +	p = kmap(page);
> +
> +	i_size = i_size_read(&vnode->vfs_inode);
> +	pos = (loff_t) page->index << PAGE_SHIFT;
> +	if (pos >= i_size) {
> +		/* partial write, page beyond EOF */
> +		_debug("beyond");
> +		if (offset > 0)
> +			memset(p, 0, offset);
> +		if (to < PAGE_SIZE)
> +			memset(p + to, 0, PAGE_SIZE - to);
> +		kunmap(page);
> +		return 0;
> +	}
> +
> +	if (i_size - pos >= PAGE_SIZE) {
> +		/* partial write, page entirely before EOF */
> +		_debug("before");
> +		tail = eof = PAGE_SIZE;
> +	} else {
> +		/* partial write, page overlaps EOF */
> +		eof = i_size - pos;
> +		_debug("overlap %u", eof);
> +		tail = max(eof, to);
> +		if (tail < PAGE_SIZE)
> +			memset(p + tail, 0, PAGE_SIZE - tail);
> +		if (offset > eof)
> +			memset(p + eof, 0, PAGE_SIZE - eof);
> +	}
> +
> +	kunmap(p);

kmap_atomic() could be used here and is better.

We have this zero_user_page() thing heading in which could perhaps be used
here also.


> +	ret = 0;
> +	if (offset > 0 || eof > to) {
> +		/* need to fill one or two bits that aren't going to be written
> +		 * (cover both fillers in one read if there are two) */
> +		start = (offset > 0) ? 0 : to;
> +		stop = (eof > to) ? eof : offset;
> +		len = stop - start;
> +		_debug("wr=%u-%u av=0-%u rd=%u@%u",
> +		       offset, to, eof, start, len);
> +		ret = afs_fill_page(vnode, key, start, len, page);
> +	}
> +
> +	_leave(" = %d", ret);
> +	return ret;
> +}
> +
> 
> ...

> +	ASSERTRANGE(wb->first, <=, index, <=, wb->last);

wow.

> +}
> +
> +/*
> + * finalise part of a write to a page
> + */
> +int afs_commit_write(struct file *file, struct page *page,
> +		     unsigned offset, unsigned to)
> +{
> +	struct afs_vnode *vnode = AFS_FS_I(file->f_dentry->d_inode);
> +	loff_t i_size, maybe_i_size;
> +
> +	_enter("{%x:%u},{%lx},%u,%u",
> +	       vnode->fid.vid, vnode->fid.vnode, page->index, offset, to);
> +
> +	maybe_i_size = (loff_t) page->index << PAGE_SHIFT;
> +	maybe_i_size += to;
> +
> +	i_size = i_size_read(&vnode->vfs_inode);
> +	if (maybe_i_size > i_size) {
> +		spin_lock(&vnode->writeback_lock);
> +		i_size = i_size_read(&vnode->vfs_inode);
> +		if (maybe_i_size > i_size)
> +			i_size_write(&vnode->vfs_inode, maybe_i_size);
> +		spin_unlock(&vnode->writeback_lock);
> +	}
> +
> +	set_page_dirty(page);
> +
> +	if (PageDirty(page))
> +		_debug("dirtied");
> +
> +	return 0;
> +}

One would normally run mark_inode_dirty() after any i_size_write()?

> +/*
> + * kill all the pages in the given range
> + */

We can invalidate pages and we can truncate them and we can clean them. 
But here we have a new operation, "killing".  I wonder what that is.

> +static void afs_kill_pages(struct afs_vnode *vnode, bool error,
> +			   pgoff_t first, pgoff_t last)
> +{
> +	struct pagevec pv;
> +	unsigned count, loop;
> +
> +	_enter("{%x:%u},%lx-%lx",
> +	       vnode->fid.vid, vnode->fid.vnode, first, last);
> +
> +	pagevec_init(&pv, 0);
> +
> +	do {
> +		_debug("kill %lx-%lx", first, last);
> +
> +		count = last - first + 1;
> +		if (count > PAGEVEC_SIZE)
> +			count = PAGEVEC_SIZE;
> +		pv.nr = find_get_pages_contig(vnode->vfs_inode.i_mapping,
> +					      first, count, pv.pages);
> +		ASSERTCMP(pv.nr, ==, count);
> +
> +		for (loop = 0; loop < count; loop++) {
> +			ClearPageUptodate(pv.pages[loop]);
> +			if (error)
> +				SetPageError(pv.pages[loop]);
> +			end_page_writeback(pv.pages[loop]);
> +		}
> +
> +		__pagevec_release(&pv);
> +	} while (first < last);
> +
> +	_leave("");
> +}
> +
> +/*
> + * write a page back to the server
> + * - the caller locked the page for us
> + */
> +int afs_writepage(struct page *page, struct writeback_control *wbc)
> +{
> +	struct backing_dev_info *bdi = page->mapping->backing_dev_info;
> +	struct afs_writeback *wb;
> +	int ret;
> +
> +	_enter("{%lx},", page->index);
> +
> +	if (wbc->sync_mode != WB_SYNC_NONE)
> +		wait_on_page_writeback(page);

Didn't the VFS already do that?

> +	if (PageWriteback(page) || !PageDirty(page)) {
> +		unlock_page(page);
> +		return 0;
> +	}

And some of that?

> +	wb = (struct afs_writeback *) page_private(page);
> +	ASSERT(wb != NULL);
> +
> +	ret = afs_write_back_from_locked_page(wb, page);
> +	unlock_page(page);
> +	if (ret < 0) {
> +		_leave(" = %d", ret);
> +		return 0;
> +	}
> +
> +	wbc->nr_to_write -= ret;
> +	if (wbc->nonblocking && bdi_write_congested(bdi))
> +		wbc->encountered_congestion = 1;
> +
> +	_leave(" = 0");
> +	return 0;
> +}

I have this vague prehistoric memory that something can go wrong at the VFS
level if the address_space writes back more pages than it was asked to. 
But I forget what the issue was and it would be silly to have an issue
with that anyway.  Something to keep an eye out for.


