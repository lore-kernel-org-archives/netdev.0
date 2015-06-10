From: Keng Soon Cheah <keng.soon.cheah@ni.com>
Subject: Re: [PATCH RFC] net: phy: Introduced the PHY_AN_PENDING state
Date: Wed, 10 Jun 2015 15:09:21 +0800
Message-ID: <20150610070921.GA11225@pendev.apac.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resending as I didn't reply all.

On Tue, Jun 09, 2015 at 10:17:59PM -0700, Florian Fainelli wrote:
> 
> The typical way to work around these problems are to fix them at the PHY
> driver level, see below.
> 

My first attempt of work around is to target on the PHY driver but I
couldn't figure out a good way in doing that because

1. We use RT kernel. The jitter performance is very sensitive to the time
we spend in the kernel. Hence polling for auto-negotiation to complete
before starting a new one could hurt the system performance. Moreover,
I've seen the PHY takes up to 11s to complete auto-negotiation.

2. Ruling out status polling mean I have to switch to use some work
scheduling mechanism to let the PHY driver come back and check the
auto-negotiation status (which is what the state machine is doing now)
but this seem to even complicate the solution because the PHY state machine
has moved to PHY_AN state at the same time, but the auto-negotiation has
not really been fired yet. There are more conditions that need to be
consider to sync the PHY driver and the PHY state machine after the
previous auto-negotiation finish.

It looks like a dead end to me for continuing down the path of modifying
PHY driver. Do let me know if you have better idea to achieve the same
objective.

> 
> That sounds like a bug in the PHY state machine and/or the PHY driver if
> you are allowed to restart auto-negotiation while one is pending. Now
> that the PHY state machine has debug prints built-in, could you capture
> a trace of this failing case?
> 
> Is this observed with the generic PHY driver or a custom PHY driver?
> 

It's not really a problem in the state machine or PHY driver. A very common
scenario for an auto-negotiation to start before previous complete is at
system boot up where the previous auto-negotiation, either triggered by
hardware (because PHY come out from reset and auto-negotiate by itself)
or software (U-Boot triggering PHY software reset).

The other scenario that I'm able to induce the same effect is by doing
mii-tool -r in Linux.

> As usual with state machines, introducing a new state needs to be
> carefully done in order to make sure that all transitions are correct,
> so far I would rather work on finding the root cause/extending the
> timeout and/or making it configurable on a PHY-driver basis rather than
> having this additional state which is more error prone.
> 

I agree that introducing changes to the state machine will need careful
review and it's my last option within the constraint I have. I tried to
serialize the PHY_AN_PENDING and PHY_AN state to minimize the disruption
introduced to the state machine. There is only one entry to the
PHY_AN_PENDING state (via phy_start_aneg) and there is only one exit point
to continue with PHY_AN. The state machine would otherwise identical with
the original state machine.
Should the PHY drop to any state other than PHY_AN_PENDING, they will
always transition their state as usual.
Should the PHY state machine requires an auto-negotiation, it will always
enter PHY_AN_PENDING and always continue with PHY_AN as usual.
