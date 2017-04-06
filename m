From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] mac80211: Fix clang warning about constant operand in
 logical operation
Date: Thu, 6 Apr 2017 15:42:38 -0700
Message-ID: <20170406224238.GA78690@google.com>
References: <20170406185633.91065-1-mka@chromium.org>
 <1491505878.11399.4.camel@sipsolutions.net>
 <20170406192452.GE145051@google.com>
 <1491513145.11399.8.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Grant Grundler <grundler@chromium.org>,
        Michael Davidson <md@google.com>,
        Greg Hackmann <ghackmann@google.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36731 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754403AbdDFWmk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 18:42:40 -0400
Received: by mail-pg0-f54.google.com with SMTP id g2so47400154pge.3
        for <netdev@vger.kernel.org>; Thu, 06 Apr 2017 15:42:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1491513145.11399.8.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El Thu, Apr 06, 2017 at 11:12:25PM +0200 Johannes Berg ha dit:

> On Thu, 2017-04-06 at 12:24 -0700, Matthias Kaehlcke wrote:
> 
> > I agree that the code looks worse :( I hoped to find a fix using a
> > preprocessor condition but wasn't successful.
> 
> It's actually easy - just remove the 'default ""' from Kconfig, and
> then the symbol won't be defined at all if it doesn't get a proper
> value. Then you can ifdef the whole thing.

Thanks, it would also require to move the initialization of
ieee80211_default_rc_algo into an ifdef. If you can live with such a
solution I'm happy to change it.

> > Some projects (like Chrome OS) build their kernel with all warnings
> > being treated as errors. Besides changing the 'offending' code the
> > alternatives are to disable the warning completely or to tell clang
> > not to use the builtin(s). IMO changing the code is the preferable
> > solution, especially since this is so far the only occurrence of the
> > warning that I have encountered.
> > 
> > I used goto instead of nested ifs since other functions in this file
> > use the same pattern. If nested ifs are preferred I can change that.
> 
> I don't really buy either argument. The warning is simply bogus - I'm
> very surprised you don't hit it with more similar macros or cases, like
> for example CONFIG_ENABLED(). Try
> 
> 	git grep 'IS_ENABLED(' | grep '&&'
> 
> and you'll find lots of places that seem like they should trigger this
> warning.

Indeed the warning is not triggered by these constructs. It seems
clang only emits the warning when the constant operand is not boolean.

> You're advocating to make the code worse - not very significantly in
> this case, but still - just to quiet a compiler warning.

For Chrome OS we need to quiet the warning in one way or another,
otherwise our builds will fail due to warnings being treated as
errors. I'm reluctant to disable the warning completely since it can
be useful to detect certain errors, e.g. the use of a logical operator
when bitwise was intended.

And yes, in this case I would favor the slight deterioration of a
small section of code over losing a potentially useful check on the
entire kernel code.

I agree that this is a bit of a corner case, the code is definitely
not buggy by itself, ideally clang would detect that the constant is
a result of its own optimization and skip the warning.

Obviously we can always apply a patch locally, but ideally we try to
upstream changes that seem of general use so that others and our
future selves can benefit from it.

I have no intention to insist on this, we can live with a local patch
if you don't think it is useful.

Cheers

Matthias
