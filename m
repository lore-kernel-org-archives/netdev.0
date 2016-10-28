From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v2 1/5] kconfig: introduce the "imply" keyword
Date: Thu, 27 Oct 2016 23:10:46 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610272156050.14694@knanqh.ubzr>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org> <1477448931-29051-2-git-send-email-nicolas.pitre@linaro.org> <1477613871.2121.92.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="8323328-463955964-1477623663=:14694"
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Michal Marek <mmarek@suse.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477613871.2121.92.camel@tiscali.nl>
Content-ID: <alpine.LFD.2.20.1610272305320.14694@knanqh.ubzr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-463955964-1477623663=:14694
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.LFD.2.20.1610272305321.14694@knanqh.ubzr>

On Fri, 28 Oct 2016, Paul Bolle wrote:

> On Tue, 2016-10-25 at 22:28 -0400, Nicolas Pitre wrote:
> > The "imply" keyword is a weak version of "select" where the target
> > config symbol can still be turned off, avoiding those pitfalls that come
> > with the "select" keyword.
> > 
> > This is useful e.g. with multiple drivers that want to indicate their
> > ability to hook into a given subsystem
> 
> "hook into a [...] subsystem" is rather vague.

You could say: benefit from, contribute to, register with, or any 
combination of those. At some point there is no good way to remain 
generic. At least none came to my mind.

> >  while still being able to configure that subsystem out
> 
> s/being able to/allowing the user to/, correct? 

Correct.

> > and keep those drivers selected.
> 
> Perhaps replace that with: "without also having to unset these
> drivers"?

Sure. I currently have:

  This is useful e.g. with multiple drivers that want to indicate their
  ability to hook into an important secondary subsystem while allowing
  the user to configure that subsystem out without also having to unset
  these drivers.

> > +- weak reverse dependencies: "imply" <symbol> ["if" <expr>]
> 
> You probably got "["if" <expr>]" for free by copying what's there for
> select. But this series doesn't use it, so perhaps it would be better
> to not document it yet. But that is rather sneaky. Dunno.

If it is not documented then the chance that someone uses it are slim. 
And since it comes "for free" I don't see the point of making the tool 
less flexible. And not having this flexibility could make some 
transitions from "select" to "imply" needlessly difficult.

> > +  This is similar to "select" as it enforces a lower limit on another
> > +  symbol except that the "implied" config symbol's value may still be
> > +  set to n from a direct dependency or with a visible prompt.
> 
> This is seriously hard to parse. But it's late here, so it might just
> be me.

I tried to follow the existing style. I removed the word "config" from 
that paragraph as it looked redundant. Other than that, any improvements 
from someone more inspired than myself is welcome.

> > +  Given the following example:
> > +
> > +  config FOO
> > +	tristate
> > +	imply BAZ
> > +
> > +  config BAZ
> > +	tristate
> > +	depends on BAR
> > +
> > +  The following values are possible:
> > +
> > +	FOO		BAR		BAZ's default	choice for BAZ
> > +	---		---		-------------	--------------
> > +	n		y		n		N/m/y
> > +	m		y		m		M/y/n
> > +	y		y		y		Y/n
> 
> Also
> 	n		n		*		N
> 	m		n		*		N
> 
> Is that right?

Right.  Is it clearer if I list all combinations, or maybe:

	*		n		*		N

> > +	y		n		*		N
> 
> But what does '*' mean?

It's a wildcard meaning either of n, m, or y.

> What happens when a tristate symbol is implied by a symbol set to 'y'
> and by a symbol set to 'm'?

That's respectively the third and second rows in the table above.

> And in your example BAR is bool, right? Does the above get more
> complicated if BAR would be tristate?

If BAR=m then implying BAZ from FOO=y will force BAZ to y or n, 
bypassing the restriction provided by BAR like "select" does.  This is 
somewhat questionable for "select" to do that, and the code emits a 
warning when "select" bypasses a direct dependency set to n, but not 
when set to m. For now "imply" simply tries to be consistent with 
the "select" behavior.

> How does setting a direct default for BAZ interfere with the implied
> values?

It doesn't. An implied symbol may be promoted to a higher value than the 
default, not a lower value. So if the direct default is higher than the 
implied value then the default wins.

> >    b) Match dependency semantics:
> >  	b1) Swap all "select FOO" to "depends on FOO" or,
> >  	b2) Swap all "depends on FOO" to "select FOO"
> > +  c) Consider the use of "imply" instead of "select"
> 
> If memory serves me right this text was added after a long discussion
> with Luis Rodriguez. Luis might want to have a look at any 

The "imply" statement doesn't create the kind of dependency conflicts as 
"select" does. So I think it is worth mentioning as a possibility here.

> Haven't looked at the code yet, sorry. I'm still trying to see whether
> I can wrap my mind around this. It looks like just setting a default on
> another symbol, but there could be a twist I missed.

Setting a default was the purpose of my "suggest" patch. The "imply" 
statement still imposes a restriction similar to "select" where the 
implied symbol cannot be m if implied with y.

Some people didn't like the fact that you could turn a driver from m to
y and silently lose some features if they were provided by a subsystem
that also used to be m, which arguably is not the same as being
explicitly disabled.  With "select" this is not a problem as the target
symbol is also promoted to y in that case, so I wanted to preserve that
property with "imply".


Nicolas
--8323328-463955964-1477623663=:14694--
