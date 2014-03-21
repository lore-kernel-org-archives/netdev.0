From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] sh_eth: pm_runtime should not need null operations
Date: Fri, 21 Mar 2014 11:57:23 +0100
Message-ID: <532C1B13.7000805@codethink.co.uk>
References: <1395396913-24354-1-git-send-email-ben.dooks@codethink.co.uk> <CAMuHMdWO-kNdWT_AxzAmCTrx3NerWpTG+auFNZTcL5hsbN+++A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdWO-kNdWT_AxzAmCTrx3NerWpTG+auFNZTcL5hsbN+++A@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/03/14 11:30, Geert Uytterhoeven wrote:
> Hi Ben,
>
> On Fri, Mar 21, 2014 at 11:15 AM, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
>> The driver has a no-op for the pm_runtime callbacks but
>> the pm_runtime core should correctly ignore drivers without
>> any pm_rumtime callback ops.
>
> The pm_runtime core doesn't ignore non-existing runtime_{suspend,resume}
> callbacks, it turns them into a failure withv -ENOSYS.
> Only non-existing runtime_idle callbacks are ignored.

I've added Rafael Wysocki as he may be able to add better
feedback to this issue.

[snip rpm_susend code block]

I got very confused here. The clock_ops sets dev->pm_domain
which over-rides the use of the dev->driver->pm entry as the
primary pm for the device. The code above the bit you snipped
does a ladder looking for the pm_runtime entry it calls and
would stop at finding dev->pm_domain as so:

from drivers/base/power/runtime.c:
     495         if (dev->pm_domain)
     496                 callback = dev->pm_domain->ops.runtime_suspend;
  ...
     502                 callback = dev->bus->pm->runtime_suspend;
     503         else
     504                 callback = NULL;


So for drivers on shmobile with drivers/sh/pm_runtime.c enabled
we would never call the drivers' entry as the ops that this code
introduces just calls the pm_clk calls and does not send the
events on.

If we send the events on, then we would use pm_generic_runtime_suspend()
to send it. This call treats the lack of runtime_pm driver entry as a
do nothing and return 0 which means in this case the code in sh_eth
is not necessary to have any pm_runtime functions.

This means depending on if we have a pm_domain in the path we get
different treatment of NULL runtime pm ops pointer. I am not sure
how to handle this, as IIRC a number of other drivers for Renesas
currently assume that the NULL case is going to be fine for them.

Changing pm_generic_runtime_suspend() to return ENOSYS would end
up breaking davinci and probably a number of other platforms.

So questions:

- Should rpm_suspend() ignore the lack of pm_runtime operations?
- Do we need to add a generic `ignore pm runtime callback`
- Are any other shmobile drivers similarly affected?

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
