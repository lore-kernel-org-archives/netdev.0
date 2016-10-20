From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 1/4] kconfig: introduce the "imply" keyword
Date: Thu, 20 Oct 2016 16:10:43 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610201539100.25105@knanqh.ubzr>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org> <1476920573-14384-2-git-send-email-nicolas.pitre@linaro.org> <44f95579-6c35-7592-08e3-d8dbb13026b2@solarflare.com> <alpine.LFD.2.20.1610201245230.25105@knanqh.ubzr>
 <fea29738-142d-0cb8-da85-cf376d1158e7@solarflare.com> <alpine.LFD.2.20.1610201349070.25105@knanqh.ubzr> <3c91236f-6795-fdcc-c8a2-6e7b2fd7da66@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Edward Cree <ecree@solarflare.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <3c91236f-6795-fdcc-c8a2-6e7b2fd7da66@solarflare.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Oct 2016, Edward Cree wrote:

> On 20/10/16 19:29, Nicolas Pitre wrote:
> > On Thu, 20 Oct 2016, Edward Cree wrote:
> >> But the desire is a property of the user, not of the driver.  If you're
> >> willing to add CONFIG_FOO_BAZ to every combination of (driver, subsystem)
> >> then "imply" becomes unnecessary, doesn't it?
> > Absolutely.  And if that's something that inspires you please be my
> > guest.  So far, though, this apparently didn't inspire the majority of
> > driver authors who preferred to have a smaller set of config options and
> > forcefully pull in the BAZ features with a "select".  But "select" comes
> > with its set of evils which "imply" is meant to overcome.
> It really doesn't inspire me either ;)
> I was using it as a way to set up the converse, rather than as any kind of
> serious suggestion.
> And I agree that "imply", as it stands, is an improvement over "select" for
> these kinds of cases.  I just think it could be further improved.
> >> Conversely, if you *don't*
> >> want to have to do that, then "imply" needs to only ever deal in defaults,
> >> not in limitations.
> > As I explained, It still has to prevent BAZ=m if FOO moves from m to y
> > otherwise this would effectively have the same result as BAZ=n in
> > practice and that is not what people expect if BAZ actually isn't n in
> > your .config file.  That's why "select" also has that particular
> > semantic.
> If FOO "moves from" m to y (by which I'm assuming you mean a call to
> sym_set_tristate_value()), then by all means set BAZ=y.  But the user
> should then still be allowed to move BAZ from y to m without having to
> change FOO (though hopefully they will get warned about it somehow).

The case I'm most worried about is:

- open .config in $EDITOR
- change "CONFIG_FOO=m" to "CONFIG_FOO=y"
- save and exit
- make

The warning is most likely to be missed in that case, and if .config 
doesn't list CONFIG_BAZ as unset then this is likely to confuse people.

> > Here "imply" is meant to be a weaker form of "select".  If you prefer
> > not to have that limitation imposed by either "select" and "imply" then
> > simply don't use them at all.  Nothing forces you to use any of them if
> > your code can cope with any config combination.
> I'm interpreting "imply" as being more a way of saying "if you want FOO you
> probably want BAZ as well".  But maybe that should be yet another new
> keyword if it's so different from what you want "imply" to be.  "suggests",
> perhaps.

Indeed. That's exactly the keyword that came to my mind after I sent my 
previous reply.

> >> Right, so those drivers can use PTP if they're y and PTP is m, as long
> >> as the PTP module is loaded when they probe.
> > Not at the moment. There is no way for PTP to dynamically signal to
> > interested drivers its presence at run time.  And drivers, when
> > built-in, typically probe their hardware during the boot process even
> > before you have the chance to load any module. If that ever changes,
> > then the imply or select statement could simply be dropped.
> At least for PCIe devices, the driver can be un- and re-bound (despite
> being built-in) through sysfs.  So you (already) can re-probe them after
> loading PTP.  So driver=y && PTP=m is valid, today.

I agree with the principle, but the implementation just doesn't allow it 
at the moment. In a simplified form, what's there now in ptp.h is:

#if IS_REACHABLE(CONFIG_PTP)
extern struct ptp_clock *ptp_clock_register(...);
#else
static inline struct ptp_clock *ptp_clock_register(...) { return NULL; }
#endif

i.e. drivers may cope at runtime with PTP being absent, but there is no 
support for PTP to be loaded after drivers referring to it. Hence the 
use of "select" that I simply converted to "imply".

> >> I think that Josh's suggestion (have the UI warn you if you set BAZ to m
> >> while FOO=y) is the right approach, but I also think it should be done
> >> now rather than at some unspecified future time.
> > Please advocate this with kconfig UI authors.  My recursion stack is
> > already quite deep.
> If I'm reading your patch correctly, your symbol.c additions enforce this
> restriction, and AFAIK the UI can't override that by saying "Yeah I warned
> the user and he said it was fine".
> The kconfig UI API would need to change; sym_set_tristate_value() could
> grow an 'override-imply' flag, for instance.

The UI may tell the user about the restriction and suggest a way to 
overcome it by also changing the "impliers" to m.

Otherwise I much prefer to have a kconfig keyword that expresses the 
fact that it is actually OK to override it, like this "suggests" idea 
could do.

Sidenote: the kconfig language isn't coherent wrt english grammar as 
there is "depends on" but "select" rather than "selects". I interpreted 
"select" as using the imperative mood, hence the addition of "imply" 
rather than "implies".


Nicolas
