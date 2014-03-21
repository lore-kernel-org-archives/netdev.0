From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: stmicro: stmmac: do not grab a mutex in irq
 off section
Date: Fri, 21 Mar 2014 13:35:37 -0400 (EDT)
Message-ID: <20140321.133537.1329677087354635241.davem@davemloft.net>
References: <1395331565-23074-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753938AbaCURf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 13:35:57 -0400
In-Reply-To: <1395331565-23074-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 20 Mar 2014 17:06:05 +0100

> |libphy: stmmac-0:01 - Link is Up - 1000/Full
> |BUG: sleeping function called from invalid context at kernel/locking/mutex.c:616
> |in_atomic(): 1, irqs_disabled(): 128, pid: 52, name: kworker/1:1
> |4 locks held by kworker/1:1/52:
> |
> | #0:  (events_power_efficient){.+.+..}, at: [<800383a4>] process_one_work+0x128/0x450
> | #1:  ((&(&dev->state_queue)->work)){+.+...}, at: [<800383a4>] process_one_work+0x128/0x450
> | #2:  (&dev->lock#2){+.+...}, at: [<8025d9a4>] phy_state_machine+0x1c/0x39c
> | #3:  (&(&priv->lock)->rlock){+.....}, at: [<802661b4>] stmmac_adjust_link+0x34/0x228
> |CPU: 1 PID: 52 Comm: kworker/1:1 Not tainted 3.13.0-dirty #24
> |Workqueue: events_power_efficient phy_state_machine
> |[<8034eff4>] (mutex_lock_nested+0x28/0x434) from [<8025f35c>] (mdiobus_read+0x44/0x70)
> |[<8025f35c>] (mdiobus_read+0x44/0x70) from [<8025ea40>] (genphy_update_link+0x18/0x50)
> |[<8025ea40>] (genphy_update_link+0x18/0x50) from [<8025ea84>] (genphy_read_status+0xc/0x180)
> |[<8025ea84>] (genphy_read_status+0xc/0x180) from [<8025cbd0>] (phy_init_eee+0x4c/0x2ac)
> |[<8025cbd0>] (phy_init_eee+0x4c/0x2ac) from [<8026516c>] (stmmac_eee_init+0x40/0x104)
> |[<8026516c>] (stmmac_eee_init+0x40/0x104) from [<80266298>] (stmmac_adjust_link+0x118/0x228)
> |[<80266298>] (stmmac_adjust_link+0x118/0x228) from [<8025dbc4>] (phy_state_machine+0x23c/0x39c)
> |[<8025dbc4>] (phy_state_machine+0x23c/0x39c) from [<80038420>] (process_one_work+0x1a4/0x450)
> |stmmac: Energy-Efficient Ethernet initialized
> 
> stmmac_eee_init() is called in other places without this spin lock.
> In stmmac_adjust_link() I just moved the unlock prior phy_print_status()
> as it does not look like this lock protects stmmac_eee_init() (except it
> ensures that does not get called twice).
> For the resume case I moved stmmac_eee_init() out of stmmac_hw_setup()
> and added it to both callers after the lock is dropped.
> DaveM pointed out a problem with two concurent calls to
> stmmac_eee_init() which would be bad. For that there is this
> eee_init_lock mutex now.
> 
> Cc: peppe.cavallaro@st.com
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

We can't let the state machine re-enter stmmac_adjust_link() while we are invoking
stmmac_eee_init().

It calls phy_init_eee() which expects a stable set of PHY state, including the
duplex and connection settings, which can change if we don't hold a lock across
all of this.
