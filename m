From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] Fix deadlock in netconsole with no carrier
Date: Tue, 26 Apr 2005 15:47:07 +0200
Message-ID: <m1pswhy7j8.fsf@muc.de>
References: <20050419135350.GH7715@wotan.suse.de>
	<20050419170650.GW21897@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050419170650.GW21897@waste.org> (Matt Mackall's message of
 "Tue, 19 Apr 2005 10:06:50 -0700")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Matt Mackall <mpm@selenic.com> writes:

[sorry for the late answer, but you dont seem to have cced the
answer to me so I lost it until now]

> On Tue, Apr 19, 2005 at 03:53:50PM +0200, Andi Kleen wrote:
>> 
>> I got a deadlock at boot with netconsole when the netword card
>> did not have a cable connected. This patch fixes this by limiting
>> the number of retries. 
>
> It should be waiting for carrier detect before proceeding. What NIC is that?


e1000

> I'm sure five retries is not enough.

Well, infinite is definitely too many. And the early netconsole
code already waits for carrier up, so waiting even longer in the
actual write does not make much sense to me. The problem with
spinning longer here is that when you boot on a system with no
carrier but netconsole configured it will waste a lot of time
uselessly spinning/polling here all the time. It is better 
to end this early. In theory you could do a more clever backoff
scheme and note when a device is always down, but I think 
the short retry combined with the long wait at early netconsole
init is nearly equivalent.

Without this patch my setup doesnt even boot so I would
appreciate if the patch could be applied.

>
>> Also when we run into the device spinlock dont poll all the time,
>> just spin.
>
> Two patches? Again, I don't think we should give up so easily.

For the device spinlock polling is useless because the
NIC is not actually out of resources, all you need to do 
is to spin. Polling too is a waste of CPU time.
In case polling is really needed (in case of a race) it will
be retried once the spinlock is free.

-Andi
