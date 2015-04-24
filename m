From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: mdio-gpio: support access that may sleep
Date: Fri, 24 Apr 2015 08:56:34 -0700
Message-ID: <553A67B2.3040400@gmail.com>
References: <1429722414-18173-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150424.110455.2117537129018647564.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: David Miller <davem@davemloft.net>,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35536 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031381AbbDXP5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:57:47 -0400
In-Reply-To: <20150424.110455.2117537129018647564.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/15 08:04, David Miller wrote:
> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Wed, 22 Apr 2015 13:06:54 -0400
> 
>> Some systems using mdio-gpio may use gpio on message based busses, which
>> require sleeping (e.g. gpio from an I2C I/O expander).
>>
>> Since this driver does not use IRQ handler, it is safe to use the
>> _cansleep suffixed gpio accessors.
>>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Since this is down underneath the layer of an MII bus, you cannot
> universally say that these routines are always called in a sleepable
> context.
> 
> The PHY layer, and the driver itself above that, might call these
> routines from timers, interruptes etc.

The PHY library calls these routines from its state machine workqueue
for that reason, or from process context (when invoked via ethtool
ioctl). The only special case is phy_mac_interrupt() which is callable
from interrupt context, but schedules the state machine workqueue anyway
to circumvent the "in-interrupt" context.

If we were not doing that, there would be a number of things broken, for
instance the per-MDIO bus mutex would not protect us from anything.

> 
> In fact, since the whole point of this driver is to provide a specific
> implementation for programming registers over an MII bus, it's quite
> rediculuous to say that just because interrupts are not used in this
> implementation it means that sleeping is always valid.
> 
> You have to look at all of the (real and potential) users, all the way
> up into the specific ethernet drivers.

It seems to me like this patch in itself is ok, but if there are
particular drivers you believe are at risk, then yes, we definitively
need to audit those.
-- 
Florian
