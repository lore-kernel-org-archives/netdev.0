From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH 6/6] fs: Introduce kern_mount_special() to mount
	special vfs
Date: Fri, 28 Nov 2008 09:26:04 +0000
Message-ID: <20081128092604.GL28946@ZenIV.linux.org.uk>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDCAB.1070204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, rth-hL46jP5Bxq7R7s880joybQ@public.gmane.org,
	ink-biIs/Y0ymYJMZLIVYojuPNP0rXTJTi09@public.gmane.org
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <492DDCAB.1070204-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 27, 2008 at 12:32:59AM +0100, Eric Dumazet wrote:
> This function arms a flag (MNT_SPECIAL) on the vfs, to avoid
> refcounting on permanent system vfs.
> Use this function for sockets, pipes, anonymous fds.

IMO that's pushing it past the point of usefulness; unless you can show
that this really gives considerable win on pipes et.al. *AND* that it
doesn't hurt other loads...

dput() part: again, I want to see what happens on other loads; it's probably
fine (and win is certainly more than from mntput() change), but...  The
thing is, atomic_dec_and_lock() in there is often done on dentries with
d_count > 1 and that's fairly cheap (and doesn't involve contention on
dcache_lock on sane targets).

FWIW, unless there's a really good reason to do alpha atomic_dec_and_lock()
in a special way, I'd try to compare with
        if (atomic_add_unless(&dentry->d_count, -1, 1))
                return;
	if (your flag)
		sod off to special
	spin_lock(&dcache_lock);
	if (atomic_dec_and_test(&dentry->d_count)) {
		spin_unlock(&dcache_lock);
		return;
	}
	the rest as usual

	As for the alpha... unless I'm misreading the assembler in
arch/alpha/lib/dec_and_lock.c, it looks like we have essentially an
implementation of atomic_add_unless() in there and one that just
might be better than what we've got in arch/alpha/include/asm/atomic.h.
How about
1:	ldl_l	x, addr
	cmpne	x, u, y	/* y = x != u */
	beq	y, 3f	/* if !y -> bugger off, return 0 */
	addl	x, a, y
	stl_c	y, addr	/* y <- *addr has not changed since ldl_l */
	beq	y, 2f
3:	/* return value is in y */
.subsection 2 /* out of the way */
2:	br	1b
.previous
for atomic_add_unless() guts?  With that we are rid of HAVE_DEC_LOCK and
get a uniform implementation of atomic_dec_and_lock() for all targets...

AFAICS, that would be
static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
{
	unsigned long temp, res;
	__asm__ __volatile__(
	"1:     ldl_l %0,%1\n"
	"       cmpne %0,%4,%2\n"
	"       beq %4,3f\n"
	"       addl %0,%3,%4\n"
	"       stl_c %2,%1\n"
	"       beq %2,2f\n"
	"3:\n"
        ".subsection 2\n"
        "2:     br 1b\n"
        ".previous"
        :"=&r" (temp), "=m" (v->counter), "=&r" (res)
        :"Ir" (a), "Ir" (u), "m" (v->counter) : "memory");
	smp_mb();
	return res;
}

static __inline__ int atomic64_add_unless(atomic64_t *v, long a, long u)
{
	unsigned long temp, res;
	__asm__ __volatile__(
	"1:     ldq_l %0,%1\n"
	"       cmpne %0,%4,%2\n"
	"       beq %4,3f\n"
	"       addq %0,%3,%4\n"
	"       stq_c %2,%1\n"
	"       beq %2,2f\n"
	"3:\n"
        ".subsection 2\n"
        "2:     br 1b\n"
        ".previous"
        :"=&r" (temp), "=m" (v->counter), "=&r" (res)
        :"Ir" (a), "Ir" (u), "m" (v->counter) : "memory");
	smp_mb();
	return res;
}

Comments?
