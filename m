From: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Subject: Re: [PATCH] fs: pipe/sockets/anon dentries should have themselves as parent
Date: Fri, 21 Nov 2008 11:43:45 -0700
Message-ID: <20081121184344.GC5707@parisc-linux.org>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121153626.GA9281@infradead.org> <4926F6C5.9030108@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org,
	cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, efault-Mmb7MZpHnFY@public.gmane.org,
	a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4926F6C5.9030108-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 21, 2008 at 06:58:29PM +0100, Eric Dumazet wrote:
> +/**
> + * d_alloc_unhashed - allocate unhashed dentry
> + * @inode: inode to allocate the dentry for
> + * @name: dentry name

It's normal to list the parameters in the order they're passed to the
function.  Not sure if we have a tool that checks for this or not --
Randy?

> + *
> + * Allocate an unhashed dentry for the inode given. The inode is
> + * instantiated and returned. %NULL is returned if there is insufficient
> + * memory. Unhashed dentries have themselves as a parent.
> + */
> + 
> +struct dentry * d_alloc_unhashed(const char *name, struct inode *inode)
> +{
> +	struct qstr q = { .name = name, .len = strlen(name) };
> +	struct dentry *res;
> +
> +	res = d_alloc(NULL, &q);
> +	if (res) {
> +		res->d_sb = inode->i_sb;
> +		res->d_parent = res;
> +		/*
> +		 * We dont want to push this dentry into global dentry hash table.
> +		 * We pretend dentry is already hashed, by unsetting DCACHE_UNHASHED
> +		 * This permits a working /proc/$pid/fd/XXX on sockets,pipes,anon
> +		 */

Line length ... as checkpatch would have warned you ;-)

And there are several other grammatical nitpicks with this comment.  Try
this:

		/*
		 * We don't want to put this dentry in the global dentry
		 * hash table, so we pretend the dentry is already hashed
		 * by unsetting DCACHE_UNHASHED.  This permits 
		 * /proc/$pid/fd/XXX t work for sockets, pipes and
		 * anonymous files (signalfd, timerfd, etc).
		 */

> +		res->d_flags &= ~DCACHE_UNHASHED;
> +		res->d_flags |= DCACHE_DISCONNECTED;

Is this really better than:

		res->d_flags = res->d_flags & ~DCACHE_UNHASHED |
						DCACHE_DISCONNECTED;

Anyway, nice cleanup.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
