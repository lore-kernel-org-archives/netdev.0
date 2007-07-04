From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH -mm 2/9] netconsole: Code simplification
Date: Wed, 4 Jul 2007 23:13:53 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707042203260.757@cselinux1.cse.iitk.ac.in>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704110749.28520.92997.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070704134618.GA11115@waste.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:35597 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439AbXGDRWh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 13:22:37 -0400
In-Reply-To: <20070704134618.GA11115@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Jul 2007, Matt Mackall wrote:
> On Wed, Jul 04, 2007 at 04:37:49PM +0530, Satyam Sharma wrote:
> > [...]
> > (2) With this change, option_setup() is not required for modular netconsole.
> 
> How is this a simplification? You've taken code with no #ifdefs and
> added one! Please have both modular and nonmodular continue to use the
> same paths.

No, modular and non-modular do *not* take the same paths even in the
present code -- note that __setup() is a not even defined for modules.

If anything, the paths become somewhat "similar" *after* this patch.

Basically the present code is quite funny / strange, I'll explain why:

(1) For modular netconsole, the:

"module_param_string(netconsole, config, 256, 0);"

at the top of the file is what (effectively) does a:

strlcpy(config, "whatever", 256);

for us.

Note that __setup(option_setup) would be discarded at the preprocessor
stage itself for a modular build.

Then, in init_netconsole(), we call netpoll_parse_options() through
option_setup() ... the string (already copied into "config" due to the
module_param_string as I mentioned above) is then parsed and the
netpoll structure populated.

Then we proceed to do the netpoll_setup().

(2) For built-in netconsole:

__setup(option_setup) ensures a pointer to the option_setup() function
is put into the .init.text section starting at __setup__start ... then,
obsolete_checksetup() calls option_setup() with the appropriate string
from the kernel's command line [note that all this is happening even
before init_netconsole() gets called during the initcall process].

Anyway, obsolete_checksetup() calls option_setup() ->
netpoll_parse_options() that parses the passed string options that
matches after "netconsole=" [_not_ our "config" variable, which is a
redundant/unused variable in the built-in case] and populates the "np"
netpoll structure.

Then comes the kernel initcalls stage. init_netconsole() is duly called
when its time comes, and sees strlen(config) == 0 (note that config
is static and never populated in the built-in case that used the
"netconsole=" boot option). So, options_setup() is *not* called. But
that's no problem, "np" has already been populated after all.

And then we proceed to netpoll_setup() as usual.

Anyway, what I'm saying is that the _present_ code has radically different
codepaths, and the proposed patch _is_ a simplification because it makes
them somewhat more similar, as follows:

1. For modular netconsole, module_param_string effectively does a
strcpy(config, "whatever", 256); for us.

2. For built-in case, __setup effectively does _the same_ for us.

And for *both* the cases, init_netconsole() will call the
netpoll_parse_options() for us. Somewhat more similar, and simpler
(at least for me -- taste varies, of course).

BTW, you *don't* really want the exact same codepaths for both built-in
and modular netconsole anyway, believe me. If that's what you want, just
get rid of the __setup use in netconsole -- module_param_string works
equally good for modules when they are modular *or* when they are
built-in.

HOWEVER, this will introduce a regression: people will have to specify
the netconsole target specification as "netconsole.netconsole=..." on
the kernel command line, and not simply as "netconsole=" as they have
always been doing.

Perhaps I should've explained this a bit more verbosely in the changelog ...

Satyam
