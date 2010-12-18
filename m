From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH v2] kptr_restrict for hiding kernel pointers from
 unprivileged users
Date: Fri, 17 Dec 2010 20:12:39 -0500
Message-ID: <1292634759.9764.26.camel@Dan>
References: <1292025924.2965.20.camel@Dan>
	 <20101217164431.08f3e730.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	jmorris@namei.org, eugeneteo@kernel.org, kees.cook@canonical.com,
	mingo@elte.hu, davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101217164431.08f3e730.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The changelog doesn't describe why CONFIG_SECURITY_KPTR_RESTRICT
> exists, nor why the kptr_restrict sysctl exists.  I can kinda guess why
> this was done, but it would be much better if your reasoning was
> present here.
> 
> And I'd question whether we need CONFIG_SECURITY_KPTR_RESTRICT at all. 
> Disabling it saves no memory.  Its presence just increases the level of
> incompatibility between different vendor's kernels and potentially
> doubles the number of kernels which distros must ship (which they of
> course won't do).  It might be better to add a kptr_restrict=1 kernel boot
> option (although people sometimes have problems with boot options in
> embedded environments).
> 
> All that being said, distro initscripts can just set the sysctl to the
> desired value before any non-root process has even started, but this
> apparently is far too hard for them :(
> 
> Finally, the changelog and the documentation changes don't tell us the
> full /proc path to the kptr_restrict pseudo-file.  That would be useful
> info.  Seems that it's /proc/sys/kernel/kptr_restrict?
> 

I'll send a clean-up patch tomorrow fixing the documentation issues.
I'm also willing to take more feedback on the need for a config - this
was the approach that was recommended to me recently with
dmesg_restrict, but I also understand your reasoning.

> >
> > ...
> >
> > --- a/lib/vsprintf.c
> > +++ b/lib/vsprintf.c
> > @@ -936,6 +936,8 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
> >  	return string(buf, end, uuid, spec);
> >  }
> >  
> > +int kptr_restrict = CONFIG_SECURITY_KPTR_RESTRICT;
> > +
> >  /*
> >   * Show a '%p' thing.  A kernel extension is that the '%p' is followed
> >   * by an extra set of alphanumeric characters that are extended format
> > @@ -979,6 +981,7 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
> >   *       Implements a "recursive vsnprintf".
> >   *       Do not use this feature without some mechanism to verify the
> >   *       correctness of the format string and va_list arguments.
> > + * - 'K' For a kernel pointer that should be hidden from unprivileged users
> >   *
> >   * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
> >   * function pointers are really function descriptors, which contain a
> > @@ -1035,6 +1038,21 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
> >  		return buf + vsnprintf(buf, end - buf,
> >  				       ((struct va_format *)ptr)->fmt,
> >  				       *(((struct va_format *)ptr)->va));
> > +	case 'K':
> > +		if (kptr_restrict) {
> > +			if (in_irq() || in_serving_softirq() || in_nmi())
> > +				WARN(1, "%%pK used in interrupt context.\n");
> > +
> > +			else if (capable(CAP_SYSLOG))
> > +				break;
> 
> And the reason why it's unusable in interrupt context is that we can't
> meaningfully check CAP_SYSLOG from interrupt.
> 
> Fair enough, but this does restrict %pK's usefulness.
> 
> I think I'd be more comfortable with a WARN_ONCE here.  If someone
> screws up then we don't want to spew thousands of repeated warnings at
> our poor users - one will do.
> 
> 

Agreed.

> 
> So what's next?  We need to convert 1,000,000 %p callsites to use %pK? 
> That'll be fun.  Please consider adding a new checkpatch rule which
> detects %p and asks people whether they should have used %pK.

The goal of this format specifier is specifically for pointers that are
exposed to unprivileged users.  I agree that hiding all kernel pointers
would be nice, but I don't expect the angry masses to ever agree to
that.  For now, I'll isolate specific cases, especially in /proc, that
are clear risks in terms of information leakage.  I'll also be skipping
over pointers written to the syslog, since I think hiding that
information is dmesg_restrict's job.

Thanks,
Dan
