From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [RFC PATCH v2 1/2] net: ethernet: nb8800: Reset HW block in ndo_open
Date: Wed, 02 Aug 2017 15:33:22 +0100
Message-ID: <yw1xwp6mghu5.fsf@mansr.com>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
        <d817da35-f977-5985-4aae-73617004fac3@free.fr>
        <yw1xbmnyi660.fsf@mansr.com>
        <ef36cd4a-b1b5-7505-34d1-250c736d6731@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:35100 "EHLO unicorn.mansr.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752149AbdHBOdY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 10:33:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 02/08/2017 13:02, Måns Rullgård wrote:
>
>> Mason wrote:
>> 
>>> Move all HW initializations to nb8800_init.
>>> This provides the basis for suspend/resume support.
>>> ---
>>>  drivers/net/ethernet/aurora/nb8800.c | 50 +++++++++++++++++-------------------
>>>  drivers/net/ethernet/aurora/nb8800.h |  1 +
>>>  2 files changed, 25 insertions(+), 26 deletions(-)
>> 
>> You're still not doing anything to preserve flow control and multicast
>> configuration, and those are probably not the only ones.
>
> I did handle flow control (as far as I can tell).
> The current settings are stored in:
> priv->pause_aneg, priv->pause_rx, priv->pause_tx
> and nb8800_pause_config() is called from nb8800_link_reconfigure()

I think the whole pause setup needs to be revisited.  It's a mess.
Maybe I'll find the time one day.

> I'll take a closer look at multicast settings.

You're currently losing all multicast setup as well as promiscuous mode
if that has been enabled.

>> Worse, you're now never tearing down dma properly, which means the
>> hardware can be left with active pointers to memory no longer allocated
>> to it.
>
> You're making it sound like there is a risk those pointers
> might be used somehow. There is no such risk AFAICT.
> The PHY is disconnected, NAPI is stopped, RX and TX have
> been disabled, and the ISR has been removed.

The interrupt handler and NAPI have nothing to do with it since they
only get involved *after* the hw has filled the buffers.  If you've
given the hardware control of a memory buffer, you should damn well take
it back before reusing that memory for something else.  Otherwise you'll
eventually have a very difficult to debug problem and a security risk.

> I have considered putting the HW block in reset (clock gated)
> at the end of nb8800_stop() to save power, which would make
> the issue you point out moot.

That's not necessarily possible.  It is on Sigma SoCs, but it doesn't
have to be.

> The reason I removed nb8800_dma_stop() in nb8800_stop()
> is because it hangs when called from nb8800_suspend().
> (It requires interrupts to make progress, and interrupts
> seem to be disabled when nb8800_suspend() is called.)

It shouldn't require interrupts.  If it does for some reason, that
should be fixed.

> Broader question for netdev:
>
> I've been wondering about costly close operations.
> If closing a device is complex (in terms of code), at which
> point does it become simpler to just reset the block, and
> avoid writing/maintaining/debugging the code performing
> said close operation?
>
>> Finally, you still haven't explained why the hw needs to be reset in
>> ndo_open().  Whatever is causing your lockup can almost certainly be
>> triggered in some other way too.  I will not accept this side-stepping
>> of the issue.
>
> (I was not aware that you were the final authority on which
> patches are accepted upstream.)
>
> FWIW, I have placed a formal request for the HW dev to
> investigate, as I could not reproduce on tango4, despite
> several days wasted on this issue.
>
> In the mean time, the driver in its current form does not
> support suspend/resume. How would *you* implement it?

I'm not saying it's a bad idea for suspend.  It might even be the only
way.

-- 
Måns Rullgård
