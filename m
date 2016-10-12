From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Wed, 12 Oct 2016 16:06:13 +0300
Message-ID: <1476277573.7776.30.camel@coelho.fi>
References: <20161010071943.4717-1-chris@rorvick.com>
         <1476108164.5210.11.camel@coelho.fi> <1476180668.17022.21.camel@tiscali.nl>
         <CAEUsAPbEf=hr1ki267qKpenWW_UBO93KY8q6-EdqWpk15Yhcnw@mail.gmail.com>
         <1476275099.7776.28.camel@coelho.fi> <1476275787.9670.12.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Oren Givon <oren.givon@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>, Chris Rorvick <chris@rorvick.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from paleale.coelho.fi ([176.9.41.70]:48444 "EHLO
        farmhouse.coelho.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933740AbcJLNZE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 09:25:04 -0400
In-Reply-To: <1476275787.9670.12.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-12 at 14:36 +0200, Paul Bolle wrote:
> On Wed, 2016-10-12 at 15:24 +0300, Luca Coelho wrote:
> > Okay... Actually this is a structure in the BIOS and the actual method
> > we call is SPLC.  The SPLC method may return one item from this table,
> > or something entirely different, possible one of the three values
> > depending on a configuration option or so.
> > 
> > Can you to find and send me the actual SPLC method that we call, from
> > your BIOS?
> 
> 
> It seems Chris and I basically have identical setups, so I'll answer.

Thanks! Yeah, I implied any of you two. ;)


> There are 20 SPLC methods in the BIOS. The first reads
>     Method (SPLC, 0, Serialized)
>     {
>         DerefOf (SPLX [One]) [Zero] = DOM1 /* \DOM1 */
>         DerefOf (SPLX [One]) [One] = LIM1 /* \LIM1 */
>         DerefOf (SPLX [One]) [0x02] = TIM1 /* \TIM1 */
>         DerefOf (SPLX [0x02]) [Zero] = DOM2 /* \DOM2 */
>         DerefOf (SPLX [0x02]) [One] = LIM2 /* \LIM2 */
>         DerefOf (SPLX [0x02]) [0x02] = TIM2 /* \TIM2 */
>         DerefOf (SPLX [0x03]) [Zero] = DOM3 /* \DOM3 */
>         DerefOf (SPLX [0x03]) [One] = LIM3 /* \LIM3 */
>         DerefOf (SPLX [0x03]) [0x02] = TIM3 /* \TIM3 */
>         Return (SPLX) /* \_SB_.PCI0.RP01.PXSX.SPLX */
>     }
> 
> The only difference is in the last comment. Ie, RP01 is increased until
> it reaches RP20. (The machine has 20 PCI devices according to lspci. I
> have no clue how to match that RPxx number to the 20 devices showing up
> in lspci, sorry.)

No problem, these BIOSes are usually quite cryptic. :) But what you're
saying makes sense.  They have added the SPLC method to all PCI root-
ports (which is what RP stands for here).

And, the values in the SPLX structs are being changed here, to DOM1,
LIM1, TIM1 etc., before being returned.  This also matches your
description that, at runtime, you got something different than the pure
dump.  If you follow these DOM*, LIM*, TIM* symbols, you'll probably
end up getting the values you observed at runtime.

Basically this tells me that indeed 3 "structs" are being returned (as
your dumps already showed).  And, according to the specs that I found
(which unfortunately are confidential, so I can't share) this is
correct and the driver code is broken.

I'll send you a patch for testing soon.

Thanks for all the help!
