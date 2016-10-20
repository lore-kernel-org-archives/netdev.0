From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 1/4] kconfig: introduce the "imply" keyword
Date: Thu, 20 Oct 2016 13:04:08 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610201245230.25105@knanqh.ubzr>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org> <1476920573-14384-2-git-send-email-nicolas.pitre@linaro.org> <44f95579-6c35-7592-08e3-d8dbb13026b2@solarflare.com>
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
In-Reply-To: <44f95579-6c35-7592-08e3-d8dbb13026b2@solarflare.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Oct 2016, Edward Cree wrote:

> On 20/10/16 00:42, Nicolas Pitre wrote:
> > diff --git a/Documentation/kbuild/kconfig-language.txt b/Documentation/kbuild/kconfig-language.txt
> > index 069fcb3eef..c96127f648 100644
> > --- a/Documentation/kbuild/kconfig-language.txt
> > +++ b/Documentation/kbuild/kconfig-language.txt
> > @@ -113,6 +113,33 @@ applicable everywhere (see syntax).
> >       That will limit the usefulness but on the other hand avoid
> >       the illegal configurations all over.
> >
> > +- weak reverse dependencies: "imply" <symbol> ["if" <expr>]
> > +  This is similar to "select" as it enforces a lower limit on another
> > +  symbol except that the "implied" config symbol's value may still be
> > +  set to n from a direct dependency or with a visible prompt.
> > +  Given the following example:
> > +
> > +  config FOO
> > +     tristate
> > +     imply BAZ
> > +
> > +  config BAZ
> > +     tristate
> > +     depends on BAr
> > +
> > +  The following values are possible:
> > +
> > +     FOO             BAR             BAR's default   choice for BAZ
> Should the third column not be "BAZ's default"?

Indeed.  Good catch.

> > +     --------------- --------------- --------------- --------------
> > +     n               y               n               N/m/y
> > +     m               y               m               M/y/n
> > +     y               y               y               Y/n
> > +     y               n               *               N
> Also, I don't think having any FOO=y should preclude BAZ=m.  Suppose both
> FOO and FOO2 imply BAZ, FOO=y and FOO2=m.

Some people didn't like the fact that you could turn a driver from m to 
y and silently lose some features if they were provided by a subsystem 
that also used to be m, which arguably is not the same as being 
explicitly disabled.  With "select" this is not a problem as the target 
symbol is also promoted to y in that case, so I wanted to preserve that 
property.

> Then if BAZ-features are only
> desired for driver FOO2, BAz=m makes sense.

In that case it would make more sense to add a config option related to 
FOO asking if BAZ features are desired for that driver (there is already 
one occurrence of that with PTP).  Or you could simply drop the "imply" 
statement from the FOO config entry.

> There is also the case of drivers with the ability to detect at runtime
> whether BAZ is present, rather than making the decision at build time, but
> I'm not sure how common that is.

Right now that's how PTP support is done.  Drivers can optimize things 
at build time, but most of them simply cope with a NULL return from 
ptp_clock_register().  Hence the imply statement becomes a big 
configuration hint rather than some hard build dependency.


Nicolas
