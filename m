From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH V2] audit: log 32-bit socketcalls
Date: Fri, 13 Jan 2017 10:06:37 -0500
Message-ID: <20170113150637.GB3087@madcap2.tricolour.ca>
References: <dd937da01da72da9277e44ed79abd1f4618c14c5.1484297765.git.rgb@redhat.com>
 <1484318543.5300.1.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-audit@redhat.com, Kangkook Jee <aixer77@gmail.com>,
        Paul Moore <pmoore@redhat.com>, Steve Grubb <sgrubb@redhat.com>
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1484318543.5300.1.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-01-13 09:42, Eric Paris wrote:
> On Fri, 2017-01-13 at 04:51 -0500, Richard Guy Briggs wrote:
> > 32-bit socketcalls were not being logged by audit on x86_64 systems.
> > Log them.  This is basically a duplicate of the call from
> > net/socket.c:sys_socketcall(), but it addresses the impedance
> > mismatch
> > between 32-bit userspace process and 64-bit kernel audit.
> > 
> > See: https://github.com/linux-audit/audit-kernel/issues/14
> > 
> > Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> > 
> > --
> > v2:
> >    Move work to audit_socketcall_compat() and use
> > audit_dummy_context().
> > ---
> >  include/linux/audit.h |   16 ++++++++++++++++
> >  net/compat.c          |   15 +++++++++++++--
> >  2 files changed, 29 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/audit.h b/include/linux/audit.h
> > index 9d4443f..43d8003 100644
> > --- a/include/linux/audit.h
> > +++ b/include/linux/audit.h
> > @@ -387,6 +387,18 @@ static inline int audit_socketcall(int nargs,
> > unsigned long *args)
> >  		return __audit_socketcall(nargs, args);
> >  	return 0;
> >  }
> > +static inline int audit_socketcall_compat(int nargs, u32 *args)
> > +{
> > +	if (unlikely(!audit_dummy_context())) {
> 
> I've always hated these likely/unlikely. Mostly because I think they
> are so often wrong. I believe this says that you compiled audit in but
> you expect it to be explicitly disabled. While that is (recently) true
> in Fedora I highly doubt that's true on the vast majority of systems
> that have audit compiled in.

It has been argued that audit should have pretty much no performance
impact if it is not in use and that if it is, we're willing to take the
more significant overhead of the rest of the code for the sake of one
test to determine whether or not to follow this code path.  The audit
subsystem isn't everyone's favourite baby so not making performance
worse for non-audit-users might help play nice in the community.  I did
contemplate Hanlon's Razor when wondering if this call had been left out
to avoid thunking complications or overhead.

In this case, compat users are less likely to raise a stink about
performance issues, so this situation is not particularly critical.

> I think all of the likely/unlikely need to just be abandoned, but at
> least don't add more? It certainly wouldn't be the first time I was
> wrong, and I haven't profiled it. But the function would definitely
> look better if coded

This is a seperate issue and I agree about simply bailing early rather
than putting the rest of the function in one conditional.  Given the
scoping though, the local variables aren't needed to be allocated in the
unlikely case, but I'm sure the compiler optimizer knows better than we
do how to make this go fast...

In both cases, I thought there was value in making
audit_socketcall_compat() as similar in logic to audit_socketcall() as
possible to make them easier to maintain.

Is either issue a cause for patch respin?  If so, I'll want to normalize
the two functions for consistency.

> static inline int audit_socketcall_compat(int nargs, u32 *args)
> {
>     if (audit_cummy_context()) {
>         return 0
>     }
>     int i;
>     unsigned long a[AUDITSC_ARGS];
> 
>     [...]
> }
> 
> > +		int i;
> > +		unsigned long a[AUDITSC_ARGS];
> > +
> > +		for (i=0; i<nargs; i++)
> > +			a[i] = (unsigned long)args[i];
> > +		return __audit_socketcall(nargs, a);
> > +	}
> > +	return 0;
> > +}
> >  static inline int audit_sockaddr(int len, void *addr)
> >  {
> >  	if (unlikely(!audit_dummy_context()))
> > @@ -513,6 +525,10 @@ static inline int audit_socketcall(int nargs,
> > unsigned long *args)
> >  {
> >  	return 0;
> >  }
> > +static inline int audit_socketcall_compat(int nargs, u32 *args)
> > +{
> > +	return 0;
> > +}
> >  static inline void audit_fd_pair(int fd1, int fd2)
> >  { }
> >  static inline int audit_sockaddr(int len, void *addr)
> > diff --git a/net/compat.c b/net/compat.c
> > index 1cd2ec0..f0404d4 100644
> > --- a/net/compat.c
> > +++ b/net/compat.c
> > @@ -22,6 +22,7 @@
> >  #include <linux/filter.h>
> >  #include <linux/compat.h>
> >  #include <linux/security.h>
> > +#include <linux/audit.h>
> >  #include <linux/export.h>
> >  
> >  #include <net/scm.h>
> > @@ -781,14 +782,24 @@ COMPAT_SYSCALL_DEFINE5(recvmmsg, int, fd,
> > struct compat_mmsghdr __user *, mmsg,
> >  
> >  COMPAT_SYSCALL_DEFINE2(socketcall, int, call, u32 __user *, args)
> >  {
> > +	unsigned int len;
> >  	int ret;
> > -	u32 a[6];
> > +	u32 a[AUDITSC_ARGS];
> >  	u32 a0, a1;
> >  
> >  	if (call < SYS_SOCKET || call > SYS_SENDMMSG)
> >  		return -EINVAL;
> > -	if (copy_from_user(a, args, nas[call]))
> > +	len = nas[call];
> > +	if (len > sizeof(a))
> > +		return -EINVAL;
> > +
> > +	if (copy_from_user(a, args, len))
> >  		return -EFAULT;
> > +
> > +	ret = audit_socketcall_compat(len/sizeof(a[0]), a);
> > +	if (ret)
> > +		return ret;
> > +
> >  	a0 = a[0];
> >  	a1 = a[1];
> >  

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
