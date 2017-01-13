From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [RFC] [PATCH] audit: log 32-bit socketcalls
Date: Thu, 12 Jan 2017 23:08:18 -0500
Message-ID: <20170113040818.GB20259@madcap2.tricolour.ca>
References: <0eae0209607cd5b6e302676779e1de55f6bc6e61.1484224437.git.rgb@redhat.com>
 <CAHC9VhQwaLrBpput1ae0AVPChQd9DHC5Km533Sa-N4gayNrehw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-audit@redhat.com,
        netdev@vger.kernel.org
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHC9VhQwaLrBpput1ae0AVPChQd9DHC5Km533Sa-N4gayNrehw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-01-12 16:32, Paul Moore wrote:
> On Thu, Jan 12, 2017 at 7:36 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> > 32-bit socketcalls were not being logged by audit on x86_64 systems.
> > Log them.
> >
> > See: https://github.com/linux-audit/audit-kernel/issues/14
> >
> > Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> > ---
> >  net/compat.c |   18 ++++++++++++++++--
> >  1 files changed, 16 insertions(+), 2 deletions(-)
> 
> You should CC netdev on this patch; I'd also mention that you are
> simply duplicating the normal socketcall() auditing in the compat
> version (the only real difference being the argument size handling
> workaround).

D'ho! Completely forgot about netdev.

I thought of mentioning the size handling in the description, but
figured it was somewhat obvious right in the code.  I'll add a comment.

> > diff --git a/net/compat.c b/net/compat.c
> > index 1cd2ec0..86cacab 100644
> > --- a/net/compat.c
> > +++ b/net/compat.c
> > @@ -22,6 +22,7 @@
> >  #include <linux/filter.h>
> >  #include <linux/compat.h>
> >  #include <linux/security.h>
> > +#include <linux/audit.h>
> >  #include <linux/export.h>
> >
> >  #include <net/scm.h>
> > @@ -781,14 +782,27 @@ COMPAT_SYSCALL_DEFINE5(recvmmsg, int, fd, struct compat_mmsghdr __user *, mmsg,
> >
> >  COMPAT_SYSCALL_DEFINE2(socketcall, int, call, u32 __user *, args)
> >  {
> > +       unsigned int len, i;
> >         int ret;
> > -       u32 a[6];
> > +       u32 a[AUDITSC_ARGS];
> > +       unsigned long aa[AUDITSC_ARGS];
> >         u32 a0, a1;
> >
> >         if (call < SYS_SOCKET || call > SYS_SENDMMSG)
> >                 return -EINVAL;
> > -       if (copy_from_user(a, args, nas[call]))
> > +       len = nas[call];
> > +       if (len > sizeof(a))
> > +               return -EINVAL;
> > +
> > +       if (copy_from_user(a, args, len))
> >                 return -EFAULT;
> > +
> > +       for (i=0; i < len/sizeof(a[0]); i++)
> > +               aa[i] = (unsigned long)a[i];
> 
> It will be interesting to see if you get push back on this loop
> outside of audit_socketcall(); folks may want to see it wrapped up
> inside a audit_socketcall_compat() (or similar) function so it isn't
> needlessly called in a number of cases.  However, considering it is
> compat code, and not the common case it may be okay.

I thought about this, and was thinking a check of !audit_dummy_context()
here might be a solution, but audit_socketcall_compat is a much cleaner
idea.  I did also consider that it is compat code that won't have a lot
of performance nerds screaming, but that's no excuse...

> > +       ret = audit_socketcall(len/sizeof(a[0]), aa);
> > +       if (ret)
> > +               return ret;
> > +
> >         a0 = a[0];
> >         a1 = a[1];
> >
> > --
> > 1.7.1
> 
> -- 
> paul moore
> www.paul-moore.com

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
