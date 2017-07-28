From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [PATCH net] net: phy: Run state machine to completion
Date: Fri, 28 Jul 2017 12:57:44 +0200
Message-ID: <69ecff09-3822-31b3-99d2-ebd5ca888e7f@sigmadesigns.com>
References: <20170726192446.32045-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: Russell King <linux@arm.linux.org.uk>,
        Zach Brown <zach.brown@ni.com>,
        Nathan Sullivan <nathan.sullivan@ni.com>,
        Andrew Lunn <andrew@lunn.ch>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Mans Rullgard <mans@mansr.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726192446.32045-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/07/2017 21:24, Florian Fainelli wrote:

> Marc reported that he was not getting the PHY library adjust_link()
> callback function to run when calling phy_stop() + phy_disconnect()
> which does not indeed happen because we don't make sure we flush the
> PHYLIB delayed work and let it run to completion. We also need to have
> a synchronous call to phy_state_machine() in order to have the state
> machine actually act on PHY_HALTED, set the PHY device's link down, turn
> the network device's carrier off and finally call the adjust_link()
> function.
> 
> Reported-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
> Fixes: a390d1f379cf ("phylib: convert state_queue work to delayed_work")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> David, this dates back from before the commit mentioned in Fixes but it would
> be hard to backport to earlier kernels if we flagged the original design flaw
> that used timers. Also, I am not clear on the timer API whether there was a way
> to ensure timers would run to completion before they would be cancelled.
> 
> Marc, please add your Signed-off-by tag since you contributed the second line.
> 
> Thanks!
> 
>  drivers/net/phy/phy.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index d0626bf5c540..30e7c43e0d87 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -743,12 +743,17 @@ void phy_trigger_machine(struct phy_device *phydev, bool sync)
>   */
>  void phy_stop_machine(struct phy_device *phydev)
>  {
> +	/* Run the state machine to completion */
> +	flush_delayed_work(&phydev->state_queue);
>  	cancel_delayed_work_sync(&phydev->state_queue);
>  
>  	mutex_lock(&phydev->lock);
>  	if (phydev->state > PHY_UP && phydev->state != PHY_HALTED)
>  		phydev->state = PHY_UP;
>  	mutex_unlock(&phydev->lock);
> +
> +	/* Now we can run the state machine synchronously */
> +	phy_state_machine(&phydev->state_queue.work);

Hello Florian,

Sorry, I was AFK for a couple of days.

Thanks for putting the patch together!

I added dump_stack() at the top of phy_state_machine() to better
understand what's going on.

Action: set link down on the command-line

Results:

1) PHY in interrupt mode

[  136.238889] [<c0378518>] (phy_state_machine) from [<c0378a58>] (phy_stop_machine+0x4c/0x50)
[  136.247285] [<c0378a58>] (phy_stop_machine) from [<c0379c30>] (phy_disconnect+0x20/0x34)
[  136.255420] [<c0379c30>] (phy_disconnect) from [<c037d984>] (nb8800_stop+0x84/0xa0)
[  136.263118] [<c037d984>] (nb8800_stop) from [<c03f52a4>] (__dev_close_many+0x88/0xd0)
[  136.270989] [<c03f52a4>] (__dev_close_many) from [<c03f540c>] (__dev_close+0x24/0x38)
[  136.278862] [<c03f540c>] (__dev_close) from [<c03fdd98>] (__dev_change_flags+0x94/0x144)
[  136.286997] [<c03fdd98>] (__dev_change_flags) from [<c03fde60>] (dev_change_flags+0x18/0x48)
[  136.295481] [<c03fde60>] (dev_change_flags) from [<c0463350>] (devinet_ioctl+0x6e0/0x7a0)
[  136.303702] [<c0463350>] (devinet_ioctl) from [<c04657e0>] (inet_ioctl+0x194/0x1c0)
[  136.311400] [<c04657e0>] (inet_ioctl) from [<c03de2f8>] (sock_ioctl+0x148/0x2fc)
[  136.318837] [<c03de2f8>] (sock_ioctl) from [<c01dbe80>] (do_vfs_ioctl+0x9c/0x8e8)
[  136.326361] [<c01dbe80>] (do_vfs_ioctl) from [<c01dc700>] (SyS_ioctl+0x34/0x5c)
[  136.333710] [<c01dc700>] (SyS_ioctl) from [<c01076c0>] (ret_fast_syscall+0x0/0x3c)
[  136.341357] nb8800 26000.ethernet eth0: Link is Down

Above, phy_state_machine() is called synchronously from phy_stop_machine().


2) PHY in polling mode

[   54.045752] CPU: 3 PID: 892 Comm: kworker/3:1 Not tainted 4.13.0-rc1 #7
[   54.056435] Workqueue: events_power_efficient phy_state_machine
[   54.085399] [<c0378518>] (phy_state_machine) from [<c012e404>] (process_one_work+0x1d4/0x3ec)
[   54.093969] [<c012e404>] (process_one_work) from [<c012f250>] (worker_thread+0x268/0x554)
[   54.102189] [<c012f250>] (worker_thread) from [<c0133fd4>] (kthread+0x108/0x138)
[   54.109623] [<c0133fd4>] (kthread) from [<c0107778>] (ret_from_fork+0x14/0x3c)
[   54.116918] nb8800 26000.ethernet eth0: Link is Down

[   54.122100] CPU: 2 PID: 973 Comm: ip Not tainted 4.13.0-rc1 #7
[   54.155001] [<c0378518>] (phy_state_machine) from [<c0378a58>] (phy_stop_machine+0x4c/0x50)
[   54.163397] [<c0378a58>] (phy_stop_machine) from [<c0379c30>] (phy_disconnect+0x20/0x34)
[   54.171532] [<c0379c30>] (phy_disconnect) from [<c037d984>] (nb8800_stop+0x84/0xa0)
[   54.179231] [<c037d984>] (nb8800_stop) from [<c03f52a4>] (__dev_close_many+0x88/0xd0)
[   54.187103] [<c03f52a4>] (__dev_close_many) from [<c03f540c>] (__dev_close+0x24/0x38)
[   54.194975] [<c03f540c>] (__dev_close) from [<c03fdd98>] (__dev_change_flags+0x94/0x144)
[   54.203109] [<c03fdd98>] (__dev_change_flags) from [<c03fde60>] (dev_change_flags+0x18/0x48)
[   54.211594] [<c03fde60>] (dev_change_flags) from [<c0463350>] (devinet_ioctl+0x6e0/0x7a0)
[   54.219816] [<c0463350>] (devinet_ioctl) from [<c04657e0>] (inet_ioctl+0x194/0x1c0)
[   54.227513] [<c04657e0>] (inet_ioctl) from [<c03de2f8>] (sock_ioctl+0x148/0x2fc)
[   54.234950] [<c03de2f8>] (sock_ioctl) from [<c01dbe80>] (do_vfs_ioctl+0x9c/0x8e8)
[   54.242473] [<c01dbe80>] (do_vfs_ioctl) from [<c01dc700>] (SyS_ioctl+0x34/0x5c)
[   54.249821] [<c01dc700>] (SyS_ioctl) from [<c01076c0>] (ret_fast_syscall+0x0/0x3c)

Above() phy_state_machine() is called twice
- first supposedly after flush_delayed_work() => calls adjust_link()
- a second time by the explicit call => probably no-op

Therefore, my reasoning is that flush_delayed_work() is
unnecessary. The explicit call to phy_state_machine() at
the end of phy_stop_machine() will handle all cases.

What do you think?

Testing without flush_delayed_work() in polling mode:

[   58.819100] CPU: 0 PID: 968 Comm: ip Not tainted 4.13.0-rc1 #10
[   58.852098] [<c0378518>] (phy_state_machine) from [<c0378a50>] (phy_stop_machine+0x44/0x48)
[   58.860494] [<c0378a50>] (phy_stop_machine) from [<c0379c28>] (phy_disconnect+0x20/0x34)
[   58.868629] [<c0379c28>] (phy_disconnect) from [<c037d97c>] (nb8800_stop+0x84/0xa0)
[   58.876328] [<c037d97c>] (nb8800_stop) from [<c03f529c>] (__dev_close_many+0x88/0xd0)
[   58.884198] [<c03f529c>] (__dev_close_many) from [<c03f5404>] (__dev_close+0x24/0x38)
[   58.892071] [<c03f5404>] (__dev_close) from [<c03fdd90>] (__dev_change_flags+0x94/0x144)
[   58.900206] [<c03fdd90>] (__dev_change_flags) from [<c03fde58>] (dev_change_flags+0x18/0x48)
[   58.908690] [<c03fde58>] (dev_change_flags) from [<c0463348>] (devinet_ioctl+0x6e0/0x7a0)
[   58.916911] [<c0463348>] (devinet_ioctl) from [<c04657d8>] (inet_ioctl+0x194/0x1c0)
[   58.924608] [<c04657d8>] (inet_ioctl) from [<c03de2f0>] (sock_ioctl+0x148/0x2fc)
[   58.932046] [<c03de2f0>] (sock_ioctl) from [<c01dbe80>] (do_vfs_ioctl+0x9c/0x8e8)
[   58.939569] [<c01dbe80>] (do_vfs_ioctl) from [<c01dc700>] (SyS_ioctl+0x34/0x5c)
[   58.946917] [<c01dc700>] (SyS_ioctl) from [<c01076c0>] (ret_fast_syscall+0x0/0x3c)
[   58.954609] nb8800 26000.ethernet eth0: Link is Down

Above, the call to adjust_link() occurs from the explicit call
to phy_state_machine()

Regards.
