From: Mason <slash.tmp@free.fr>
Subject: Re: Problem with PHY state machine when using interrupts
Date: Mon, 24 Jul 2017 23:20:55 +0200
Message-ID: <c81e12bc-0f89-5eab-547e-f0c1ec389ad8@free.fr>
References: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
 <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr>
 <02e9e171-ec22-e491-5bc8-ef4b3ad7fec2@gmail.com>
 <e6a7a5df-b735-6f9c-6a2b-cded86ec6525@free.fr>
 <b0410a73-ff2d-ca06-93fa-17af2040c41c@gmail.com>
 <0f56083f-d43e-a141-1470-b76546af6d58@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:55776 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753123AbdGXVVK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 17:21:10 -0400
In-Reply-To: <0f56083f-d43e-a141-1470-b76546af6d58@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/07/2017 21:53, Florian Fainelli wrote:

> Well now that I see the possible interrupts generated, I indeed don't
> see how you can get a link down notification unless you somehow force
> the link down yourself, which would certainly happen in phy_suspend()
> when we set BMCR.pwrdwn, but that may be too late.
> 
> You should still expect the adjust_link() function to be called though
> with PHY_HALTED being set and that takes care of doing phydev->link = 0
> and netif_carrier_off(). If that still does not work, then see whether
> removing the call to phy_stop() does help (it really should).

The only functions setting phydev->state to PHY_HALTED
are phy_error() and phy_stop() AFAICT.

I am aware that when phy_state_machine() handles the
PHY_HALTED state, it will set phydev->link = 0;
and call netif_carrier_off() -- because that's where
I copied that code from.

My issue is that phy_state_machine() does not run when
I run 'ip set link dev eth0 down' from the command line.

If I'm reading the code right, phy_disconnect() actually
stops the state machine.

In interrupt mode, phy_state_machine() doesn't run
because no interrupt is generated.

In polling mode, phy_state_machine() doesn't run
because phy_disconnect() stops the state machine.

Introducing a sleep before phy_disconnect() gives
the state machine a chance to run in polling mode,
but it doesn't feel right, and doesn't fix the
other mode, which I'm using.

Looking at bcm_enet_stop() it calls phy_stop() and
phy_disconnect() just like the nb8800 driver...

I'm stumped.

Regards.
