From: Eric Paris <eparis@redhat.com>
Subject: Re: linux-next: Tree for Apr 12
Date: Mon, 04 Jun 2012 18:46:17 -0400
Message-ID: <1338849977.2860.9.camel@localhost>
References: <20120412145931.9ec6f2b51655071795d60d1d@canb.auug.org.au>
	 <20120412142415.564710b8.akpm@linux-foundation.org>
	 <20120604150455.7a80b311.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>,
	Stephen Smalley <sds@tycho.nsa.gov>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120604150455.7a80b311.akpm@linux-foundation.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-04 at 15:04 -0700, Andrew Morton wrote:
> On Thu, 12 Apr 2012 14:24:15 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Thu, 12 Apr 2012 14:59:31 +1000
> > Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > 
> > > I have created today's linux-next tree at
> > > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> > 
> > This isn't working for me.  Some time between April 3 and April 12
> > someone merged something into the non-mm part of linux-next which broke
> > ssh.
> > 
> > I boot the box and everything seems to come up OK, but attemtps to ssh
> > into the machine fail with
> > 
> > X11 forwarding request failed on channel 0
> > Last login: Thu Apr 12 13:04:35 2012 from akpm.corp.google.com
> > Connection to akpm2 closed.
> > 
> > I took a peek in the `strace ssh' output.
> > 
> > Good:
> > 
> > 17815 write(5, "Last login: Thu Apr 12 13:27:23 "..., 65) = 65
> > 17815 select(7, [3 4], [], NULL, {120, 0}) = 1 (in [3], left {119, 770798})
> > 17815 read(3, "\21O\200\366Mv\343\222\332\251\2403L\376Y18\2047\336\244\226p-+X\2%\2119\314\255"..., 8192) = 80
> > 17815 select(7, [3 4], [5], NULL, {120, 0}) = 1 (out [5], left {119, 999987})
> > 17815 write(5, "\r\33[m\17\33[27m\33[24m\33[Jakpm2:/home/ak"..., 39) = 39
> > 17815 select(7, [3 4], [], NULL, {120, 0}) = 1 (in [4], left {118, 801111})
> > 17815 read(4, "\4", 16384)              = 1
> > 17815 select(7, [3 4], [3], NULL, {120, 0}) = 1 (out [3], left {119, 999991})
> > 17815 write(3, "\235J\5\340\234\21\266\207\26e\362\327\2\332\1\267\272\200\364\267?/\320L\341\35\350{+M:\222"..., 48) = 48
> > 
> > 
> > Bad:
> > 
> > 9305  write(5, "Last login: Thu Apr 12 13:02:54 "..., 65) = 65
> > 9305  select(7, [3 4], [], NULL, {120, 0}) = 1 (in [3], left {119, 945541})
> > 9305  read(3, "f\357\250~\260i\2259\320\3258\262)O\364;_\251\360-\314\31\374]\326\300\356\364\370S\3105"..., 8192) = 128
> > 9305  close(5)                          = 0
> > 9305  close(4)                          = 0
> > 
> > That read() is returning a lot more data.
> > 
> > It appears that we've done something which breaks X forwarding.  I
> > won't be able to look any further into this until Monday.
> 
> This regression is now in mainline.  I've bisected it to an SELinux
> patch, below.  I have confirmed that reverting just that patch from
> current mainline fixes the regression.
> 
> Using openssh-server-4.3p2-14.fc6 on FC6.
> 
> 
> commit 95dbf739313f09c8d859bde1373bc264ef979337
> Author:     Eric Paris <eparis@redhat.com>
> AuthorDate: Wed Apr 4 13:45:34 2012 -0400
> Commit:     Eric Paris <eparis@redhat.com>
> CommitDate: Mon Apr 9 12:22:49 2012 -0400
> 
>     SELinux: check OPEN on truncate calls
>     
>     In RH BZ 578841 we realized that the SELinux sandbox program was allowed to
>     truncate files outside of the sandbox.  The reason is because sandbox
>     confinement is determined almost entirely by the 'open' permission.  The idea
>     was that if the sandbox was unable to open() files it would be unable to do
>     harm to those files.  This turns out to be false in light of syscalls like
>     truncate() and chmod() which don't require a previous open() call.  I looked
>     at the syscalls that did not have an associated 'open' check and found that
>     truncate(), did not have a seperate permission and even if it did have a
>     separate permission such a permission owuld be inadequate for use by
>     sandbox (since it owuld have to be granted so liberally as to be useless).
>     This patch checks the OPEN permission on truncate.  I think a better solution
>     for sandbox is a whole new permission, but at least this fixes what we have
>     today.
>     
>     Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index d85b793..f7d7e77 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2708,6 +2708,7 @@ static int selinux_inode_setattr(struct dentry *dentry, struct iattr *iattr)
>  {
>  	const struct cred *cred = current_cred();
>  	unsigned int ia_valid = iattr->ia_valid;
> +	__u32 av = FILE__WRITE;
>  
>  	/* ATTR_FORCE is just used for ATTR_KILL_S[UG]ID. */
>  	if (ia_valid & ATTR_FORCE) {
> @@ -2721,7 +2722,10 @@ static int selinux_inode_setattr(struct dentry *dentry, struct iattr *iattr)
>  			ATTR_ATIME_SET | ATTR_MTIME_SET | ATTR_TIMES_SET))
>  		return dentry_has_perm(cred, dentry, FILE__SETATTR);
>  
> -	return dentry_has_perm(cred, dentry, FILE__WRITE);
> +	if (ia_valid & ATTR_SIZE)
> +		av |= FILE__OPEN;
> +
> +	return dentry_has_perm(cred, dentry, av);
>  }
>  
>  static int selinux_inode_getattr(struct vfsmount *mnt, struct dentry *dentry)

Very odd indeed...  I can only assume you are SELinux enforcing and have
a denial every time this fails.  Can you send me that denial?

I really do not want to revert this and feel that the only right fix is
going to be to update your selinux policy to allow this new check.  I'd
rather not allow (whatever program) to truncate() files willy-nilly (in
violation of the intentions of selinux policy)

I'm sorry I never saw it sooner.  We've had it in RHEL for even longer
than the 3 months it's been in -next.  I think the 'right' fix is going
to have to be an update to SELinux policy (for your long dead system, if
you give me the denial I can build you a new policy) rather than leaving
the potential security hole in mainline...

-Eric
