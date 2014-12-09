From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [RFC PATCH net-next 04/11] atl1c: remove disable_irq from netpoll
 controller, use netpoll_irq_lock
Date: Tue, 9 Dec 2014 13:17:40 -0800
Message-ID: <CAMXMK6u8X6oio360Oh-FASmHZVcmnp8CisrRWBtDa1h_hid4UQ@mail.gmail.com>
References: <1418135842-21389-1-git-send-email-sd@queasysnail.net>
 <1418135842-21389-5-git-send-email-sd@queasysnail.net> <CAMXMK6t5NfPQFBxK1Qny45LCS6rwX4Ys1n4C7fsTPHXu=x_vuQ@mail.gmail.com>
 <20141209172310.GA14343@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Cliburn <jcliburn@gmail.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:62463 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609AbaLIVSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:18:02 -0500
Received: by mail-qg0-f44.google.com with SMTP id z60so1118697qgd.17
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 13:18:01 -0800 (PST)
In-Reply-To: <20141209172310.GA14343@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for clarifying. I'll see if I can find someone with an atl1c
device to test this.

-- Chris

On Tue, Dec 9, 2014 at 9:23 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> 2014-12-09, 16:13:33 +0000, Chris Snook wrote:
>> Could you explain the bug a little more for us? It's not obvious to me how
>> sleeping there is a problem.
>>
>> -- Chris
>
> Sorry for the lack of context.
>
> A might_sleep() check in disable_irq() was added in commit
> e22b886a8a43b ("sched/wait: Add might_sleep() checks") [1], and it
> triggers when using netconsole:
>
> BUG: sleeping function called from invalid context at kernel/irq/manage.c:104
> in_atomic(): 1, irqs_disabled(): 1, pid: 1, name: systemd
> no locks held by systemd/1.
> irq event stamp: 10102965
> hardirqs last  enabled at (10102965): [<ffffffff810cbafd>] vprintk_emit+0x2dd/0x6a0
> hardirqs last disabled at (10102964): [<ffffffff810cb897>] vprintk_emit+0x77/0x6a0
> softirqs last  enabled at (10102342): [<ffffffff810666aa>] __do_softirq+0x27a/0x6f0
> softirqs last disabled at (10102337): [<ffffffff81066e86>] irq_exit+0x56/0xe0
> Preemption disabled at:[<ffffffff817de50d>] printk_emit+0x31/0x33
>
> CPU: 1 PID: 1 Comm: systemd Not tainted 3.18.0-rc2-next-20141029-dirty #222
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140617_173321-var-lib-archbuild-testing-x86_64-tobias 04/01/2014
>  ffffffff81a82291 ffff88001e743978 ffffffff817df31d 0000000000000000
>  0000000000000000 ffff88001e7439a8 ffffffff8108dfa2 ffff88001e7439a8
>  ffffffff81a82291 0000000000000068 0000000000000000 ffff88001e7439d8
> Call Trace:
>  [<ffffffff817df31d>] dump_stack+0x4f/0x7c
>  [<ffffffff8108dfa2>] ___might_sleep+0x182/0x2b0
>  [<ffffffff8108e10a>] __might_sleep+0x3a/0xc0
>  [<ffffffff810ce358>] synchronize_irq+0x38/0xa0
>  [<ffffffff810ce633>] ? __disable_irq_nosync+0x43/0x70
>  [<ffffffff810ce690>] disable_irq+0x20/0x30
>  [<ffffffff815d7253>] e1000_netpoll+0x23/0x60
>  [<ffffffff81678d02>] netpoll_poll_dev+0x72/0x3a0
>  [<ffffffff817e9993>] ? _raw_spin_trylock+0x73/0x90
>  [<ffffffff8167920f>] ? netpoll_send_skb_on_dev+0x1df/0x2e0
>  [<ffffffff816791e7>] netpoll_send_skb_on_dev+0x1b7/0x2e0
>  [<ffffffff816795f3>] netpoll_send_udp+0x2e3/0x490
>
>
> The initial discussion of this problem is here: https://lkml.org/lkml/2014/10/29/523
>
>
> [1] https://lkml.org/lkml/2014/10/28/427
>
>
>> On Tue, Dec 9, 2014, 06:39 Sabrina Dubroca <sd@queasysnail.net> wrote:
>>
>> > disable_irq() may sleep, replace it with a spin_lock in the interrupt
>> > handler.
>> >
>> > No actual testing done, only compiled.
>> >
>> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
>> > Cc: Jay Cliburn <jcliburn@gmail.com>
>> > Cc: Chris Snook <chris.snook@gmail.com>
>> > ---
>> >  drivers/net/ethernet/atheros/atl1c/atl1c.h      |  3 +++
>> >  drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 12 ++++++++----
>> >  2 files changed, 11 insertions(+), 4 deletions(-)
>> >
>> > diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h
>> > b/drivers/net/ethernet/atheros/atl1c/atl1c.h
>> > index b9203d928938..8d97791e1516 100644
>> > --- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
>> > +++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
>> > @@ -49,6 +49,7 @@
>> >  #include <linux/workqueue.h>
>> >  #include <net/checksum.h>
>> >  #include <net/ip6_checksum.h>
>> > +#include <linux/netpoll.h>
>> >
>> >  #include "atl1c_hw.h"
>> >
>> > @@ -555,6 +556,8 @@ struct atl1c_adapter {
>> >         struct atl1c_rfd_ring rfd_ring;
>> >         struct atl1c_rrd_ring rrd_ring;
>> >         u32 bd_number;     /* board number;*/
>> > +
>> > +       struct netpoll_irq_lock netpoll_lock;
>> >  };
>> >
>> >  #define AT_WRITE_REG(a, reg, value) ( \
>> > diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
>> > b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
>> > index 72fb86b9aa24..7a1b11eb8e4e 100644
>> > --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
>> > +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
>> > @@ -826,6 +826,7 @@ static int atl1c_sw_init(struct atl1c_adapter *adapter)
>> >         atomic_set(&adapter->irq_sem, 1);
>> >         spin_lock_init(&adapter->mdio_lock);
>> >         spin_lock_init(&adapter->tx_lock);
>> > +       netpoll_irq_lock_init(&adapter->netpoll_lock);
>> >         set_bit(__AT_DOWN, &adapter->flags);
>> >
>> >         return 0;
>> > @@ -1584,10 +1585,11 @@ static irqreturn_t atl1c_intr(int irq, void *data)
>> >         struct pci_dev *pdev = adapter->pdev;
>> >         struct atl1c_hw *hw = &adapter->hw;
>> >         int max_ints = AT_MAX_INT_WORK;
>> > -       int handled = IRQ_NONE;
>> > +       irqreturn_t handled = IRQ_NONE;
>> >         u32 status;
>> >         u32 reg_data;
>> >
>> > +       netpoll_irq_lock(&adapter->netpoll_lock);
>> >         do {
>> >                 AT_READ_REG(hw, REG_ISR, &reg_data);
>> >                 status = reg_data & hw->intr_mask;
>> > @@ -1622,7 +1624,8 @@ static irqreturn_t atl1c_intr(int irq, void *data)
>> >                         /* reset MAC */
>> >                         set_bit(ATL1C_WORK_EVENT_RESET,
>> > &adapter->work_event);
>> >                         schedule_work(&adapter->common_task);
>> > -                       return IRQ_HANDLED;
>> > +                       handled = IRQ_HANDLED;
>> > +                       goto out;
>> >                 }
>> >
>> >                 if (status & ISR_OVER)
>> > @@ -1641,6 +1644,9 @@ static irqreturn_t atl1c_intr(int irq, void *data)
>> >         } while (--max_ints > 0);
>> >         /* re-enable Interrupt*/
>> >         AT_WRITE_REG(&adapter->hw, REG_ISR, 0);
>> > +
>> > +out:
>> > +       netpoll_irq_unlock(&adapter->netpoll_lock);
>> >         return handled;
>> >  }
>> >
>> > @@ -1900,9 +1906,7 @@ static void atl1c_netpoll(struct net_device *netdev)
>> >  {
>> >         struct atl1c_adapter *adapter = netdev_priv(netdev);
>> >
>> > -       disable_irq(adapter->pdev->irq);
>> >         atl1c_intr(adapter->pdev->irq, netdev);
>> > -       enable_irq(adapter->pdev->irq);
>> >  }
>> >  #endif
>> >
>> > --
>> > 2.1.3
>> >
>> >
>
> --
> Sabrina
