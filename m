From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 3/3] AFS: Implement basic file write support
Date: Thu, 10 May 2007 09:42:13 +1000
Message-ID: <46425C55.6050000@yahoo.com.au>
References: <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com> <20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070508194411.27477.7552.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells wrote:

> +/*
> + * prepare a page for being written to
> + */
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
> +
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
> +/*
> + * prepare to perform part of a write to a page
> + * - the caller holds the page locked, preventing it from being written out or
> + *   modified by anyone else
> + */
> +int afs_prepare_write(struct file *file, struct page *page,
> +		      unsigned offset, unsigned to)
> +{
> +	struct afs_writeback *candidate, *wb;
> +	struct afs_vnode *vnode = AFS_FS_I(file->f_dentry->d_inode);
> +	struct key *key = file->private_data;
> +	pgoff_t index;
> +	int ret;
> +
> +	_enter("{%x:%u},{%lx},%u,%u",
> +	       vnode->fid.vid, vnode->fid.vnode, page->index, offset, to);
> +
> +	candidate = kzalloc(sizeof(*candidate), GFP_KERNEL);
> +	if (!candidate)
> +		return -ENOMEM;
> +	candidate->vnode = vnode;
> +	candidate->first = candidate->last = page->index;
> +	candidate->offset_first = offset;
> +	candidate->to_last = to;
> +	candidate->usage = 1;
> +	candidate->state = AFS_WBACK_PENDING;
> +	init_waitqueue_head(&candidate->waitq);
> +
> +	if (!PageUptodate(page)) {
> +		_debug("not up to date");
> +		ret = afs_prepare_page(vnode, page, key, offset, to);
> +		if (ret < 0) {
> +			kfree(candidate);
> +			_leave(" = %d [prep]", ret);
> +			return ret;
> +		}
> +		SetPageUptodate(page);
> +	}


Why do you call SetPageUptodate when the page is not up to date?
That leaks uninitialised data, AFAIKS.

-- 
SUSE Labs, Novell Inc.
