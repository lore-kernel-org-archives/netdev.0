From: Jonas Jensen <jonas.jensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] phy: Add MOXA RTL8201CP PHY support
Date: Mon, 4 Nov 2013 14:50:35 +0100
Message-ID: <CACmBeS3aUq_yPVg_GaKmQRQMhAmO8RZVzUGY=T6Ghn7v0sP8Dw@mail.gmail.com>
References: <1383317673-14704-1-git-send-email-jonas.jensen@gmail.com>
	<CAGVrzcYfdChFNgkh=VAFZQfCRHyNTe_pZxx1Z6Sz1S8_1vzgtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGVrzcYfdChFNgkh=VAFZQfCRHyNTe_pZxx1Z6Sz1S8_1vzgtA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks for the replies.

On 1 November 2013 18:01, Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org> wrote:
>> +       dev_err(&bus->dev, "%s timed out\n", __func__);
>
> I would keep these as a debugging aid and not spawn error messages on
> the console by default.

Done.


>> +       snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii", dev_name(&pdev->dev));
>
> If you only support device tree probing, this might be fine, but you
> might want to be safe in case someone does a !OF instantiation and
> also use pdev->id as an additional unique identifier, so something
> like:
>
> %s-%d-mii, pdev->name, pdev->id
>
> will work.

Done.


>> +       /* Setting PHY_IGNORE_INTERRUPT here even if it has no effect,
>> +        * of_mdiobus_register() sets these PHY_POLL.
>> +        * Ideally, the interrupt from MAC controller could be used to
>> +        * detect link state changes, not polling, i.e. if there was
>> +        * a way phy_driver could set PHY_HAS_INTERRUPT but have that
>> +        * interrupt handled in ethernet drivercode.
>> +        */
>> +       for (i = 0; i < PHY_MAX_ADDR; i++)
>> +               bus->irq[i] = PHY_IGNORE_INTERRUPT;
>
> This type of configuration where the PHY interrupt is actually
> serviced by a link interrupt bit in the Ethernet MAC driver now works
> since 5ea94e768 ("phy: add phy_mac_interrupt() to use with
> PHY_IGNORE_INTERRUPT") so setting PHY_IGNORE_INTERRUPT is the right
> way to signal this and this will no longer make the PHY library poll
> for the link state.

Yes, I tried using phy_mac_interrupt() but had some difficulties (I'll
explain below). It seemed to be what I want and is wrapped with
EXPORT_SYMBOL().

However, as of next-20131104 I don't see how this works for DT probed
devices (those that set PHY_IGNORE_INTERRUPT).

As I tried to explain in my comment, of_mdiobus_register() assigns
PHY_POLL to the IRQ array:

drivers/of/of_mdio.c
..
int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
{
..
        /* Clear all the IRQ properties */
        if (mdio->irq)
                for (i=0; i<PHY_MAX_ADDR; i++)
                        mdio->irq[i] = PHY_POLL;
..
        for_each_available_child_of_node(np, child) {
..
                if (mdio->irq) {
                        mdio->irq[addr] = irq_of_parse_and_map(child, 0);
                        if (!mdio->irq[addr])
                                mdio->irq[addr] = PHY_POLL;
                }
..


PHY_IGNORE_INTERRUPT || PHY_POLL is not a valid interrupt.
The library ends up toggling (polling) between PHY_RUNNING and PHY_CHANGELINK:


drivers/net/phy/phy.c:
..
void phy_state_machine(struct work_struct *work)
{
..
                case PHY_RUNNING:
                        pr_info("%s: %s: PHY_RUNNING\n", __func__,
dev_name(&phydev->dev));
                        /* Only register a CHANGE if we are
                         * polling or ignoring interrupts
                         */
                        if (!phy_interrupt_is_valid(phydev))
                                phydev->state = PHY_CHANGELINK;
                        break;
..

include/linux/phy.h:
..
static inline bool phy_interrupt_is_valid(struct phy_device *phydev)
{
        return phydev->irq != PHY_POLL && phydev->irq != PHY_IGNORE_INTERRUPT;
}
..


This is why I ended up setting PHY_IGNORE_INTERRUPT and the comment
about its effectiveness. Polling works but the extra reads on the bus
seem unnecessary.
Ideas how they can be eliminated are appreciated.


Another problem, when phy_mac_interrupt() is called from NAPI it looks
like it's trying to take a lock it already has. I tried moving it out
of poll, placing it directly in IRQ handler, with the same result:

[   18.230000] moxart-ethernet 90900000.mac eth0: moxart_poll: PHYSTS_CHG
[   18.240000]
[   18.240000] =================================
[   18.240000] [ INFO: inconsistent lock state ]
[   18.240000] 3.12.0-rc7-next-20131104+ #1067 Not tainted
[   18.240000] ---------------------------------
[   18.240000] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
[   18.240000] kworker/0:1/123 [HC0[0]:SC0[0]:HE1:SE1] takes:
[   18.240000]  ((&dev->phy_queue)){+.?...}, at: [<c0028c08>]
process_one_work+0x13c/0x430
[   18.240000] {IN-SOFTIRQ-W} state was registered at:
[   18.240000]   [<c0055648>] mark_lock+0x144/0x670
[   18.240000]   [<c005777c>] __lock_acquire+0x5e4/0x1c24
[   18.240000]   [<c00592cc>] lock_acquire+0x6c/0x80
[   18.240000]   [<c002a024>] flush_work+0x44/0x278
[   18.240000]   [<c002a2e0>] __cancel_work_timer+0x88/0x124
[   18.240000]   [<c002a390>] cancel_work_sync+0x14/0x18
[   18.240000]   [<c01b0190>] phy_mac_interrupt+0x20/0x40
[   18.240000]   [<c01b3450>] moxart_poll+0x2b4/0x4b4
[   18.240000]   [<c01fe3c8>] net_rx_action+0x130/0x22c
[   18.240000]   [<c00174cc>] __do_softirq+0xe8/0x238
[   18.240000]   [<c0017a2c>] irq_exit+0xac/0xfc
[   18.240000]   [<c0009b40>] handle_IRQ+0x3c/0x8c
[   18.240000]   [<c0008534>] handle_irq+0x98/0xa8
[   18.240000]   [<c000c478>] __irq_svc+0x38/0x68
[   18.240000]   [<c00487ec>] rcu_idle_exit+0x78/0xdc
[   18.240000]   [<c0040618>] cpu_startup_entry+0x88/0x130
[   18.240000]   [<c026d3c8>] rest_init+0xb8/0xe0
[   18.240000]   [<c033ea1c>] start_kernel+0x298/0x2dc
[   18.240000] irq event stamp: 2659
[   18.240000] hardirqs last  enabled at (2659): [<c0276298>]
_raw_spin_unlock_irq+0x2c/0x60
[   18.240000] hardirqs last disabled at (2658): [<c02760f0>]
_raw_spin_lock_irq+0x28/0x78
[   18.240000] softirqs last  enabled at (2654): [<c0017568>]
__do_softirq+0x184/0x238
[   18.240000] softirqs last disabled at (2637): [<c0017a2c>] irq_exit+0xac/0xfc
[   18.240000]
[   18.240000] other info that might help us debug this:
[   18.240000]  Possible unsafe locking scenario:
[   18.240000]
[   18.240000]        CPU0
[   18.240000]        ----
[   18.240000]   lock([   18.240000] moxart-ethernet 90900000.mac
eth0: TX ring end reached
[   18.240000] (&dev->phy_queue));
[   18.240000]   <Interrupt>
[   18.240000]     lock((&dev->phy_queue));
[   18.240000]
[   18.240000]  *** DEADLOCK ***
[   18.240000]
[   18.240000] 1 lock held by kworker/0:1/123:
[   18.240000]  #0:  (events){.+.+..}, at: [<c0028c08>]
process_one_work+0x13c/0x430
[   18.240000]
[   18.240000] stack backtrace:
[   18.240000] CPU: 0 PID: 123 Comm: kworker/0:1 Not tainted
3.12.0-rc7-next-20131104+ #1067
[   18.240000] Workqueue: events phy_change
[   18.240000] [<c000d214>] (unwind_backtrace+0x0/0xf4) from
[<c000b964>] (show_stack+0x18/0x1c)
[   18.240000] [<c000b964>] (show_stack+0x18/0x1c) from [<c0271614>]
(dump_stack+0x20/0x28)
[   18.240000] [<c0271614>] (dump_stack+0x20/0x28) from [<c026fee0>]
(print_usage_bug.part.26+0x220/0x288)
[   18.240000] [<c026fee0>] (print_usage_bug.part.26+0x220/0x288) from
[<c0055b3c>] (mark_lock+0x638/0x670)
[   18.240000] [<c0055b3c>] (mark_lock+0x638/0x670) from [<c00577c4>]
(__lock_acquire+0x62c/0x1c24)
[   18.240000] [<c00577c4>] (__lock_acquire+0x62c/0x1c24) from
[<c00592cc>] (lock_acquire+0x6c/0x80)
[   18.240000] [<c00592cc>] (lock_acquire+0x6c/0x80) from [<c0028c70>]
(process_one_work+0x1a4/0x430)
[   18.240000] [<c0028c70>] (process_one_work+0x1a4/0x430) from
[<c0029304>] (worker_thread+0x13c/0x3dc)
[   18.240000] [<c0029304>] (worker_thread+0x13c/0x3dc) from
[<c002f500>] (kthread+0xb8/0xd4)
[   18.240000] [<c002f500>] (kthread+0xb8/0xd4) from [<c0009360>]
(ret_from_fork+0x14/0x34)
[   18.610000] libphy: phy_change


>> +       ret = of_mdiobus_register(bus, np);
>> +       if (ret < 0)
>> +               return ret;
>
> You still need to call mdiobus_free() here in case registration fails.

Done.


>> +/* RTL8201CP */
>> +static struct phy_driver rtl8201cp_driver = {
>> +       .phy_id         = 0x00008201,
>> +       .name           = "RTL8201CP Ethernet",
>> +       .phy_id_mask    = 0x0000ffff,
>> +       .features       = PHY_BASIC_FEATURES,
>
> If this PHY is internal to your SoC (same die/package) you should also
> add PHY_IS_INTERNAL to get a consistent ethtool reporting (among
> others).

I was wondering about that, and now I'm sure it should not be set, the
physical chip is separate, as can be seen here:

https://lh4.googleusercontent.com/-A-2FXDrObU8/UMcMc_K2vEI/AAAAAAAABwg/ldaLZ7ps1P4/w1331-h998-no/UC-7112-LX-picture4.jpg


Best regards,
Jonas
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
