From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 1/4] kconfig: introduce the "imply" keyword
Date: Thu, 20 Oct 2016 14:29:02 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1610201349070.25105@knanqh.ubzr>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org> <1476920573-14384-2-git-send-email-nicolas.pitre@linaro.org> <44f95579-6c35-7592-08e3-d8dbb13026b2@solarflare.com> <alpine.LFD.2.20.1610201245230.25105@knanqh.ubzr>
 <fea29738-142d-0cb8-da85-cf376d1158e7@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33107 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932932AbcJTS3F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:29:05 -0400
Received: by mail-qk0-f176.google.com with SMTP id n189so110702982qke.0
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2016 11:29:05 -0700 (PDT)
In-Reply-To: <fea29738-142d-0cb8-da85-cf376d1158e7@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Oct 2016, Edward Cree wrote:

> On 20/10/16 18:04, Nicolas Pitre wrote:
> > On Thu, 20 Oct 2016, Edward Cree wrote:
> >> Also, I don't think having any FOO=y should preclude BAZ=m.  Suppose both
> >> FOO and FOO2 imply BAZ, FOO=y and FOO2=m.
> > Some people didn't like the fact that you could turn a driver from m to
> > y and silently lose some features if they were provided by a subsystem
> > that also used to be m, which arguably is not the same as being
> > explicitly disabled.  With "select" this is not a problem as the target
> > symbol is also promoted to y in that case, so I wanted to preserve that
> > property.
> Right, but that's an argument for pushing the subsystem's default to y,
> not for preventing changing the subsystem back to m afterwards.
> >> Then if BAZ-features are only
> >> desired for driver FOO2, BAz=m makes sense.
> > In that case it would make more sense to add a config option related to
> > FOO asking if BAZ features are desired for that driver (there is already
> > one occurrence of that with PTP).  Or you could simply drop the "imply"
> > statement from the FOO config entry.
> But the desire is a property of the user, not of the driver.  If you're
> willing to add CONFIG_FOO_BAZ to every combination of (driver, subsystem)
> then "imply" becomes unnecessary, doesn't it?

Absolutely.  And if that's something that inspires you please be my 
guest.  So far, though, this apparently didn't inspire the majority of 
driver authors who preferred to have a smaller set of config options and 
forcefully pull in the BAZ features with a "select".  But "select" comes 
with its set of evils which "imply" is meant to overcome.

> Conversely, if you *don't*
> want to have to do that, then "imply" needs to only ever deal in defaults,
> not in limitations.

As I explained, It still has to prevent BAZ=m if FOO moves from m to y 
otherwise this would effectively have the same result as BAZ=n in 
practice and that is not what people expect if BAZ actually isn't n in 
your .config file.  That's why "select" also has that particular 
semantic.

Here "imply" is meant to be a weaker form of "select".  If you prefer 
not to have that limitation imposed by either "select" and "imply" then 
simply don't use them at all.  Nothing forces you to use any of them if 
your code can cope with any config combination.

In those cases where "imply" is used, you could drop it altogether 
already. But that's for driver authors to decide. If they went with 
"select" in the first place, there might be a reason, and "imply" is 
there to preserve that reason, semantically at least, without the 
handcuff effect that "select" imposes on the whole thing.

> >> There is also the case of drivers with the ability to detect at runtime
> >> whether BAZ is present, rather than making the decision at build time, but
> >> I'm not sure how common that is.
> > Right now that's how PTP support is done.  Drivers can optimize things
> > at build time, but most of them simply cope with a NULL return from
> > ptp_clock_register().  Hence the imply statement becomes a big
> > configuration hint rather than some hard build dependency.
> Right, so those drivers can use PTP if they're y and PTP is m, as long 
> as the PTP module is loaded when they probe.

Not at the moment. There is no way for PTP to dynamically signal to 
interested drivers its presence at run time.  And drivers, when 
built-in, typically probe their hardware during the boot process even 
before you have the chance to load any module. If that ever changes, 
then the imply or select statement could simply be dropped.

> But current "imply" semantics won't allow that...

And that's on purpose.

> I think that Josh's suggestion (have the UI warn you if you set BAZ to m
> while FOO=y) is the right approach, but I also think it should be done
> now rather than at some unspecified future time.

Please advocate this with kconfig UI authors.  My recursion stack is 
already quite deep.

> Otherwise you forbid
> potentially valid configs.

Like I said, if FOO=y and BAZ=m is a valid config, all you have to do is 
omit "imply BAZ" or "select BAZ" from the FOO config entry.  It's as 
simple as that.


Nicolas
