From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [sungem] proposal for a new locking strategy
Date: Mon, 06 Nov 2006 00:05:39 +1100
Message-ID: <1162731940.28571.245.camel@localhost.localdomain>
References: <5cac192f0611050500m19f72209vc349f235680023a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:41689 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S932679AbWKENFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Nov 2006 08:05:54 -0500
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f0611050500m19f72209vc349f235680023a1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-11-05 at 14:00 +0100, Eric Lemoine wrote:
> Hi!
> 
> Some (long) time ago benh wrote a blaming comment in sungem.c about
> that driver's locking strategy. That comment basically says that we
> probably don't need two spinlocks.

Yeah :) Note that I mostly blamed myself there ... Just never found the
time to sit down a figure out a proper locking.

> I agree!
> 
> Proposal:
> 
> Today's sungem effectively uses two spinlock's: "lock" and "tx_lock".
> 
> "tx_lock" is held by the xmit function when sending out a packet. Lots
> of functions grab "tx_lock" not to mess up with xmit (gem_stop_phy(),
> gem_change_mtu(), etc.).
> 
> All of these funcs also take "lock"!
> 
> What we could do is remove "lx_lock", have the above functions take
> only "lock", and rely on dev->_xmit_lock to protect the xmit func from
> reentrance. In that case, obviously, the driver wouldn't feature LLTX
> anymore.

We could probably do even better but yeah, a single lock is a good
start. Overall, I'm unhappy with the infrastructure provided by the
network stack though. (Might be better nowadays, but last I looked, for
example, I couldn't properly do things like stopping  MAPI poll from
set_multicast etc... due to locks held by the upper level).

> When (re-)configuring we'd now quiesce the device, with the new
> functions gem_netif_stop() and gem_full_lock(), in the same way as tg3
> does.
> 
> gem_interrupt(), gem_poll(), and gem_start_xmit() could become lockless. Fast!
> 
> Basically this proposal makes the data path faster, the control path
> slower, and simplifies the code by using one single spinlock within
> the driver.
> 
> If the idea seems reasonable to you guys I can go ahead and cook up something...

I certainly does. Bring on the patch ! :-)

Ben.


