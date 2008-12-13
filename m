From: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v3 6/7] fs: struct file move from call_rcu() to
 SLAB_DESTROY_BY_RCU
Date: Fri, 12 Dec 2008 20:07:56 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0812121958470.15781@quilx.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <493100B0.6090104@cosmosbay.com>
 <494196DD.5070600@cosmosbay.com> <200707241113.46834.nickpiggin@yahoo.com.au>
 <4941EC65.5040903@cosmosbay.com> <494295C6.2020906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org >> Kernel Testers List"
	<kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <494295C6.2020906-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Dec 2008, Eric Dumazet wrote:

> > a truly allocated file. At this point the file is
> > a truly allocated file but not anymore ours.

Its a valid file. Does ownership matter here?

> Reading again this mail I realise we call put_filp(file), while this should
> be fput(file) or put_filp(file), we dont know.
>
> Damned, this patch is wrong as is.
>
> Christoph, Paul, do you see the problem ?

Yes.

> In fget()/fget_light() we dont know if the other thread (the one who re-allocated the file,
> and tried to close it while we got a reference on file) had to call put_filp() or fput()
> to release its own reference. So we call atomic_long_dec_and_test() and cannot
> take the appropriate action (calling the full __fput() version or the small one,
> that some systems use to 'close' an not really opened file.

The difference is mainly that fput() does full processing whereas
put_filp() is used when we know that the file was not fully operational.
If the checks in __fput are able to handle the put_filp() situation by not
releasing resources that were not allocated then we should be fine.

> I believe put_filp() is only called on slowpath (error cases).

Looks like it. It seems to assume that no dentry is associated.

> Should we just zap it and always call fput() ?

Only if fput() can handle partially setup files.
