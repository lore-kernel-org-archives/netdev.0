From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH RESEND] uts: Set default hostname to "localhost", rather
 than "(none)"
Date: Mon, 11 Apr 2011 11:53:10 -0700
Message-ID: <20110411185309.GA13391@feather>
References: <20110411050155.GA2507@feather>
 <20110411080254.403d3166@nehalam>
 <BANLkTinVGTOAsxG1CiJO1mSGRxBSNP5P4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTinVGTOAsxG1CiJO1mSGRxBSNP5P4Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 11, 2011 at 08:12:40AM -0700, Linus Torvalds wrote:
> On Mon, Apr 11, 2011 at 8:02 AM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > It makes sense but this behavior has existed so long in Linux
> > that some distro might actually be depending on it.

I checked fairly thoroughly for evidence of userspace relying on
"(none)", and found no instances of that.  Userspace typically just says
"I haven't set it yet, so nobody has set it yet", and unconditionally
sets the hostname.  dhclient doesn't rely on "(none)", distro networking
scripts don't rely on "(none)", the hostname tool doesn't rely on
"(none)", and nothing else I've found looks for "(none)".

That said, I'll certainly acknowledge that some random userspace bits
somewhere could have relied on this behavior.  Would a transitional
period help at all here?  Alternatively, see below.

> Yes. Also, quite frankly, I do _not_ think that "localhost" is in any
> way a more correct hostname.
> 
> I'd rather have an obviously invalid hostname for a machine that
> hasn't been set up correctly than one that might work by random
> chance.

Choosing "localhost" for systems that don't configure a hostname at
least makes it fairly likely that you can resolve the system hostname.
So, "localhost" will have a tendency to Just Work, but seeing a hostname
of "localhost" will still obviously remind a user that they ought to set
the hostname to something more sensible on a network-connected box.  On
a non-networked box, localhost makes perfect sense, and the box need not
configure anything else.  Similarly, this default would also make sense
for various types of virtual systems.

Also, "(none)" doesn't necessarily represent an "invalid" hostname.
In general, tools seem to assume the validity of the system hostname,
and use it wherever the hostname appears.  (For that matter, as some
recent security vulnerabilities have demonstrated, "valid hostname"
doesn't necessarily mean "alphanumeric"; both DNS and DHCP will happily
hand out a hostname with crazy characters in it, including '(' and ')'.)

I wrote this patch with the same motivation as the option to mount
devtmpfs on /dev automatically: it makes systems behave more or less
sanely in the absence of explicit setup, even though more explicit setup
may produce a more optimal configuration (just as devtmpfs makes all
devices root:root in the absence of a better configuration).  It would
often make sense for embedded or virtual systems.

In general, I'd rather see the kernel provide a configuration that will
work in at least some cases and do no worse in others (requiring
explicit configuration), rather than a configuration which will not work
in any cases and *always* requires explicit userspace configuration.

If the above does not provide a sufficiently good argument for changing
the default (perhaps with a transition period added), would you consider
accepting a patch which added a CONFIG_DEFAULT_UTS_HOSTNAME, defaulting
to "(none)"?  Then systems could choose to use that configuration option
if they know their userspace will work with it.

- Josh Triplett
