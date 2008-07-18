From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 02:05:39 +0200
Message-ID: <19f34abd0807171705h31595809y944792ce697bede7@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
	 <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com>
	 <20080717235254.GA6833@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:56747 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760453AbYGRAFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 20:05:41 -0400
Received: by yw-out-2324.google.com with SMTP id 9so17012ywe.1
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 17:05:40 -0700 (PDT)
In-Reply-To: <20080717235254.GA6833@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 1:52 AM, Ingo Molnar <mingo@elte.hu> wrote:
>  If only we had some kernel technology that could track and validate
>  memory accesses, and point out the cases where we access uninitialized
>  memory, just like Valgrind?
>
> ... something like kmemcheck? ;-)

Cool :)

> So i booted that box with tip/master and kmemcheck enabled. (plus a few
> fixlets to make networking allocations be properly tracked by
> kmemcheck.)
>
> It was a slow bootup and long wait, but it gave a few hits here:

Hm, if you think it was that slow, I am suspecting you were also using
SLUB debugging.

This can actually be negative, since now SLUB will access the objects
(+redzone +padding) and possibly trick kmemcheck into thinking they
were initialized in the first place.

But what we are really looking for is "read from freed memory"
messages. So I would actually recommend this: Disable kmemcheck's
reporting of uninitialized memory, simply to make it easier to spot
the "freed" messages more easily.

Maybe something like this (warning: whitespace-munged):

diff --git a/arch/x86/mm/kmemcheck/error.c b/arch/x86/mm/kmemcheck/error.c
index 56410c6..6944cb7 100644
--- a/arch/x86/mm/kmemcheck/error.c
+++ b/arch/x86/mm/kmemcheck/error.c
@@ -98,6 +98,9 @@ void kmemcheck_error_save(enum kmemcheck_shadow state,
                return;
        prev_ip = regs->ip;

+       if (state == KMEMCHECK_SHADOW_UNINITIALIZED)
+               return;
+
        e = error_next_wr();
        if (!e)
                return;


If this only happens during boot, it would also be a good idea to
simply reboot the machine a lot...


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
