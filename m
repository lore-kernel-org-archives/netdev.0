From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sun, 7 Jul 2013 15:33:31 -0700
Message-ID: <CA+55aFyvZAQbaEyq5atQbTjHTz_hodzhWKX_7SRL8nq+yBA14A@mail.gmail.com>
References: <20130707.132133.1335860703202153192.davem@davemloft.net>
	<CA+55aFzgBXwye=ebPmEDN_6yqdKA6ZaD9hSUzbFjSacC_v3y5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f180.google.com ([209.85.128.180]:58631 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202Ab3GGWdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jul 2013 18:33:32 -0400
In-Reply-To: <CA+55aFzgBXwye=ebPmEDN_6yqdKA6ZaD9hSUzbFjSacC_v3y5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 7, 2013 at 2:27 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Because quite frankly, the fs/select.c changes make me go: "No way in
> hell". Partly because of the idiotic and completely undescriptive
> naming, partly because of the disgisting calling convetions with
> random flags variables passed in to be changed be helper functions.

Actually, I take that second one back. I mis-read things.

So I would suggest fixing this by:

 - get rid of all those idiotic "ll" things. They describe nothing at
all, and code like this

        if (ll_flag && can_ll && can_poll_ll(ll_start, ll_time))

   should have made anybody sane go "WTF?" and wonder about bad drugs.
Seriously, I'm disappointed code like this reaches me. In some random
driver I can see bad naming conventions like this, but in the core
kernel? We should have better taste.

 - talk about what it is, not short-hand. The "ll" stands for "low
latency", but that makes it sound all good. Make it describe what it
actually does: "busy loop", and write it out. So that people
understand what the actual downsides are. We're not a marketing group.
People shouldn't go "Oh, I like low-latency select(), I'll set that
latency value to 100usec". It should damn well be clear that this
enables BUSY LOOPING.

   So no POLL_LL crap. Call it POLL_BUSY_LOOP. Make everybody aware of
what it actually does.

 - Stop the marketing crap #2:

    "Recommended value is 50. May increase power usage"

   WTF? The default value is 0. Not 50. And I think "May increase
power usage" is the lie of the century. I don't see that there is any
"may" about it. Since when did we sugar-coat things?

 - I was confused by that whole ll_flag vs can_ll thing. "can_ll" is
not about whether we "can", it's actually "should_busy_loop", and
about whether we *should* busy loop. And to mention that nasty "lots
of nonsensical ll" line again:

                if (ll_flag && can_ll && can_poll_ll(ll_start, ll_time))

   that doesn't make much sense. If ll_flag isn't set, then can_ll
shouldn't have been set either, so why are we testing both values? And
because the code is mixing booleans with that mask, it's all
unnecessarily complicated in general. We'd be much better off having
"can_ll" be a mask value, and (along with renaming) we'd have

        unsigned int should_busy_loop = 0;
        ...
        should_busy_loop != mask & busy_loop_flag;

which does it all without conditionals, just by making the types
simpler. And then remove that "ll_flag && can_ll &&" which should be
just pointless, replacing it with just testing "should_busy_loop".

(That "can_poll_ll" and ll_start/ll_time should obviously *also* get
fixed naming-wise)

Finally, there is NO WAY IN HELL that busy-looping is ok if
need_resched is set. So this code also needs to make it very very
clear that it tests "current->need_resched" before busy-looping
anything at all.

End result: I think the code is salvageable and people who want this
kind of busy-looping can have it. But I really don't want to merge it
as-is. I think it was badly done, I think it was badly documented, and
I think somebody over-sold the feature by emphasizing the upsides and
not the problems.

                       Linus
