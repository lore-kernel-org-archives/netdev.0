From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH v2 1/5] kconfig: introduce the "imply" keyword
Date: Fri, 28 Oct 2016 02:17:51 +0200
Message-ID: <1477613871.2121.92.camel@tiscali.nl>
References: <1477448931-29051-1-git-send-email-nicolas.pitre@linaro.org>
         <1477448931-29051-2-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>,
        Edward Cree <ecree@solarflare.com>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Michal Marek <mmarek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477448931-29051-2-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-10-25 at 22:28 -0400, Nicolas Pitre wrote:
> The "imply" keyword is a weak version of "select" where the target
> config symbol can still be turned off, avoiding those pitfalls that come
> with the "select" keyword.
> 
> This is useful e.g. with multiple drivers that want to indicate their
> ability to hook into a given subsystem

"hook into a [...] subsystem" is rather vague.

>  while still being able to configure that subsystem out

s/being able to/allowing the user to/, correct? 

> and keep those drivers selected.

Perhaps replace that with: "without also having to unset these
drivers"?

> Currently, the same effect can almost be achieved with:
> 
> config DRIVER_A
> 	tristate
> 
> config DRIVER_B
> 	tristate
> 
> config DRIVER_C
> 	tristate
> 
> config DRIVER_D
> 	tristate
> 
> [...]
> 
> config SUBSYSTEM_X
> 	tristate
> 	default DRIVER_A || DRIVER_B || DRIVER_C || DRIVER_D || [...]
> 
> This is unwieldly

unwieldy

> to maintain especially with a large number of drivers.
> Furthermore, there is no easy way to restrict the choice for SUBSYSTEM_X
> to y or n, excluding m, when some drivers are built-in. The "select"
> keyword allows for excluding m, but it excludes n as well. Hence
> this "imply" keyword.  The above becomes:
> 
> config DRIVER_A
> 	tristate
> 	imply SUBSYSTEM_X
> 
> config DRIVER_B
> 	tristate
> 	imply SUBSYSTEM_X
> 
> [...]
> 
> config SUBSYSTEM_X
> 	tristate
> 
> This is much cleaner, and way more flexible than "select". SUBSYSTEM_X
> can still be configured out, and it can be set as a module when none of
> the drivers are selected or all of them are also modular.

[I already commented on this sentence in a previous message.]

> --- a/Documentation/kbuild/kconfig-language.txt
> +++ b/Documentation/kbuild/kconfig-language.txt

>  	That will limit the usefulness but on the other hand avoid
>  	the illegal configurations all over.
>  
> +- weak reverse dependencies: "imply" <symbol> ["if" <expr>]

You probably got "["if" <expr>]" for free by copying what's there for
select. But this series doesn't use it, so perhaps it would be better
to not document it yet. But that is rather sneaky. Dunno.

> +  This is similar to "select" as it enforces a lower limit on another
> +  symbol except that the "implied" config symbol's value may still be
> +  set to n from a direct dependency or with a visible prompt.

This is seriously hard to parse. But it's late here, so it might just
be me.

> +  Given the following example:
> +
> +  config FOO
> +	tristate
> +	imply BAZ
> +
> +  config BAZ
> +	tristate
> +	depends on BAR
> +
> +  The following values are possible:
> +
> +	FOO		BAR		BAZ's default	choice for BAZ
> +	---		---		-------------	--------------
> +	n		y		n		N/m/y
> +	m		y		m		M/y/n
> +	y		y		y		Y/n

Also
	n		n		*		N
	m		n		*		N

Is that right?

> +	y		n		*		N

But what does '*' mean?

What happens when a tristate symbol is implied by a symbol set to 'y'
and by a symbol set to 'm'?

And in your example BAR is bool, right? Does the above get more
complicated if BAR would be tristate?

How does setting a direct default for BAZ interfere with the implied
values?

> +  This is useful e.g. with multiple drivers that want to indicate their
> +  ability to hook into a given subsystem while still being able to
> +  configure that subsystem out and keep those drivers selected.

See my comments above.

>    b) Match dependency semantics:
>  	b1) Swap all "select FOO" to "depends on FOO" or,
>  	b2) Swap all "depends on FOO" to "select FOO"
> +  c) Consider the use of "imply" instead of "select"

If memory serves me right this text was added after a long discussion
with Luis Rodriguez. Luis might want to have a look at any 

Haven't looked at the code yet, sorry. I'm still trying to see whether
I can wrap my mind around this. It looks like just setting a default on
another symbol, but there could be a twist I missed.


Paul Bolle
