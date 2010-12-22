From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH v5] kptr_restrict for hiding kernel pointers
Date: Wed, 22 Dec 2010 12:35:32 -0500
Message-ID: <1293039332.9820.262.camel@dan>
References: <1293037246.9820.236.camel@dan> <20101222171307.GA25611@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	eric.dumazet@gmail.com, tgraf@infradead.org, eugeneteo@kernel.org,
	kees.cook@canonical.com, davem@davemloft.net,
	a.p.zijlstra@chello.nl, akpm@linux-foundation.org,
	eparis@parisplace.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20101222171307.GA25611@elte.hu>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-12-22 at 18:13 +0100, Ingo Molnar wrote:
> * Dan Rosenberg <drosenberg@vsecurity.com> wrote:
> 
> > +	case 'K':
> > +		/*
> > +		 * %pK cannot be used in IRQ context because its test
> > +		 * for CAP_SYSLOG would be meaningless.
> > +		 */
> > +		if (in_irq() || in_serving_softirq() || in_nmi())
> > +			WARN_ONCE(1, "%%pK used in interrupt context.\n");
> 
> Hm, that bit looks possibly broken - some useful warning in irq context could print 
> a pointer into the syslog and this would generate a second warning? That probably 
> would crash as it recurses back into the printk code?
> 

I don't see a reason to ever use %pK to print to the syslog, since
reading it is now optionally protected with dmesg_restrict, and
stripping pointers from the syslog will cripple any post-mortem
debugging for everyone.  I understand the desire to prevent things from
breaking even if it's used incorrectly, but I'm not really convinced
that this would break anything even in this scenario.  The WARN_ONCE
will prevent any unbounded recursion.  I'm just not clear on how this
could cause a crash.

> Instead a warning could be inserted into the generated output instead, for example 
> 'pK-error' (carefully staying within pointer length limits).
> 

If it's used in IRQ context and its output needs to be read by a
userspace utility using %p to parse, this will break it.

-Dan


