From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH v5] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 22:26:09 +0100
Message-ID: <20101222212609.GD3139@elte.hu>
References: <1293037246.9820.236.camel@dan>
 <20101222171307.GA25611@elte.hu>
 <1293039332.9820.262.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	eric.dumazet@gmail.com, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org,
	eparis@parisplace.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1293039332.9820.262.camel@dan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Dan Rosenberg <drosenberg@vsecurity.com> wrote:

> On Wed, 2010-12-22 at 18:13 +0100, Ingo Molnar wrote:
> > * Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> > 
> > > +	case 'K':
> > > +		/*
> > > +		 * %pK cannot be used in IRQ context because its test
> > > +		 * for CAP_SYSLOG would be meaningless.
> > > +		 */
> > > +		if (in_irq() || in_serving_softirq() || in_nmi())
> > > +			WARN_ONCE(1, "%%pK used in interrupt context.\n");
> > 
> > Hm, that bit looks possibly broken - some useful warning in irq context could print 
> > a pointer into the syslog and this would generate a second warning? That probably 
> > would crash as it recurses back into the printk code?
> > 
> 
> I don't see a reason to ever use %pK to print to the syslog, since
> reading it is now optionally protected with dmesg_restrict, and
> stripping pointers from the syslog will cripple any post-mortem
> debugging for everyone.  I understand the desire to prevent things from
> breaking even if it's used incorrectly, but I'm not really convinced
> that this would break anything even in this scenario.  The WARN_ONCE
> will prevent any unbounded recursion.  I'm just not clear on how this
> could cause a crash.

It's a simple QOI issue. We simply do not add kernel facilities that can produce a 
stack overflow, memory corruption and triple fault if a rare debug statement 
triggers in an IRQ context by accident:

	printk(KERN_WARN "driver bar: bug foo in function %pK\n");

> > Instead a warning could be inserted into the generated output instead, for 
> > example 'pK-error' (carefully staying within pointer length limits).
> 
> If it's used in IRQ context and its output needs to be read by a
> userspace utility using %p to parse, this will break it.

Didnt you just say that it should not be used from IRQ context? There wont be any 
user-space tool to read it - it's a simple robustness change: the warning as you 
implemented it can crash the system. I suggested an implementation that would emit 
the warning in a more robust way.

Thanks,

	Ingo
