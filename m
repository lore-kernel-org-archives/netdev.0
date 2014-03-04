From: Jon Ringle <jon@ringle.org>
Subject: Fwd: Ethernet controller not starting
Date: Tue, 4 Mar 2014 07:34:59 -0500
Message-ID: <CAMwGMjxO3eV1t9VrBbL3SecwOJPs2rESGS6VEH60tne4Dx8tVw@mail.gmail.com>
References: <71F7AD3B89A7BF1E126CB3B1@C9882B18C00BA04428877CD4>
	<CAMwGMjwtZVPVaENWqNODPqkM4jAAOsLPrz8_xzRBgGP6_-_usQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
	rafael.j.wysocki@intel.com, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Christian Riesch <christian.riesch@omicron.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMwGMjwtZVPVaENWqNODPqkM4jAAOsLPrz8_xzRBgGP6_-_usQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 4, 2014 at 4:06 AM, Christian Riesch
<christian.riesch@omicron.at> wrote:
> [cc'ed netdev and davinci-linux-open-source]
>
>
> --On March 03, 2014 19:39 -0500 Jon Ringle <jon@ringle.org> wrote:
>
>> On Mon, Mar 3, 2014 at 6:43 PM, Rafael J. Wysocki <rjw@rjwysocki.net>
>> wrote:
>>>
>>> On Monday, March 03, 2014 02:41:01 PM Jon Ringle wrote:
>>>>
>>>> I'm working on porting an ARM board from linux-3.10 to linux-3.12 (now
>>>> the latest LTS kernel).
>>>> I found that Ethernet controller on the board no longer comes up on
>>>> linux-3.12. I was able to bisect the issue I'm having to the following
>>>> commit:
>>>>
>>>> >   45f0a85c8258741d11bda25c0a5669c06267204a is the first bad commit
>>>> >   commit 45f0a85c8258741d11bda25c0a5669c06267204a
>>>> >   Author: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
>>>> >   Date:   Mon Jun 3 21:49:52 2013 +0200
>>>> >
>>>> >       PM / Runtime: Rework the "runtime idle" helper routine
>>>> >
>>>> >       The "runtime idle" helper routine, rpm_idle(), currently ignores
>>>> >       return values from .runtime_idle() callbacks executed by it.
>>>> >       However, it turns out that many subsystems use
>>>> >       pm_generic_runtime_idle() which checks the return value of the
>>>> >       driver's callback and executes pm_runtime_suspend() for the
>>>> >       device unless that value is not 0.  If that logic is moved to
>>>> >       rpm_idle() instead, pm_generic_runtime_idle() can be dropped
>>>> >       and its users will not need any .runtime_idle() callbacks any
>>>> >       more.
>>>> >
>>>> >       Moreover, the PCI, SCSI, and SATA subsystems' .runtime_idle()
>>>> >       routines, pci_pm_runtime_idle(), scsi_runtime_idle(), and
>>>> >       ata_port_runtime_idle(), respectively, as well as a few drivers'
>>>> >       ones may be simplified if rpm_idle() calls rpm_suspend() after
>>>> >       0 has been returned by the .runtime_idle() callback executed by
>>>> >       it.
>>>> >
>>>> >       To reduce overall code bloat, make the changes described above.
>>>> >
>>>> >       Tested-by: Mika Westerberg <mika.westerberg@linux.intel.com>
>>>> >       Tested-by: Kevin Hilman <khilman@linaro.org>
>>>> >       Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
>>>> >       Acked-by: Kevin Hilman <khilman@linaro.org>
>>>> >       Reviewed-by: Ulf Hansson <ulf.hansson@linaro.org>
>>>> >       Acked-by: Alan Stern <stern@rowland.harvard.edu>
>>>>
>>>> Can anyone offer any suggestions on what I should be looking for to
>>>> fix this on my board?
>>>
>>>
>>> Any pointers to the driver in question?
>>
>>
>> drivers/net/ethernet/ti/davinci_emac.c
>>
>
> Hi Jon,
> I have successfully used the davinci_emac driver on a custom board with an
> AM1808 SoC with Kernel 3.13 a few weeks ago. So at least 3.13 should work.
> Did you try more recent kernel versions than 3.12?

I have not tried 3.13, but will do so today. Could I get a copy of
your .config for comparison purposes?

>
>
>> I also get the following output:
>>
>>          Starting Network Manager Wait Online...
>> [   30.946509] davinci_mdio davinci_mdio.0: resetting idled controller
>> [   30.953220] net net0: attached PHY driver [Generic PHY]
>> (mii_bus:phy_addr=davinci_mdio-0:00, id=7c0f1)
>> [   30.962938] IPv6: ADDRCONF(NETDEV_UP): net0: link is not ready
>> [   31.082087] genirq: Flags mismatch irq 33. 00000000 (net0) vs.
>> 00000000 (net0)
>
>
> Is it correct that this warning can only appear in case of shared
> interrupts? See kernel/irq/manage.c. Since we don't use shared interrupts
> here: Are you sure your board configuration is correct with regard to emac
> interrupts?

I added some additional printk's and see that emac_dev_open() seems to
get called again
and it is trying to call devm_request_irq() again for irq resources
(33-36) and fails when trying to get irq 33:

         Starting Network Manager Wait Online...
[   30.687505] emac_dev_open: trying to get irq 33
[   30.692314] emac_dev_open: got irq 33
[   30.696034] emac_dev_open: trying to get irq 34
[   30.700750] emac_dev_open: got irq 34
[   30.704469] emac_dev_open: trying to get irq 35
[   30.709088] emac_dev_open: got irq 35
[   30.712887] emac_dev_open: trying to get irq 36
[   30.717542] emac_dev_open: got irq 36
[   30.721507] davinci_mdio davinci_mdio.0: resetting idled controller
[   30.728909] net net0: attached PHY driver [Generic PHY]
(mii_bus:phy_addr=davinci_mdio-0:00, id=7c0f1)
[   30.738614] IPv6: ADDRCONF(NETDEV_UP): net0: link is not ready
[   30.847040] emac_dev_open: trying to get irq 33
[   30.851809] genirq: Flags mismatch irq 33. 00000000 (net0) vs.
00000000 (net0)
[   30.859125] CPU: 0 PID: 677 Comm: NetworkManager Not tainted
3.12.13-fs1-003-g5ae24fe-dirty+ #1234
[   30.868261] [<c000d9c4>] (unwind_backtrace+0x0/0x128) from
[<c000be14>] (show_stack+0x10/0x14)
[   30.877020] [<c000be14>] (show_stack+0x10/0x14) from [<c0046970>]
(__setup_irq+0x45c/0x4d4)
[   30.885499] [<c0046970>] (__setup_irq+0x45c/0x4d4) from
[<c0046b18>] (request_threaded_irq+0xa4/0x130)
[   30.894935] [<c0046b18>] (request_threaded_irq+0xa4/0x130) from
[<c00484e0>] (devm_request_threaded_irq+0x50/0x98)
[   30.905414] [<c00484e0>] (devm_request_threaded_irq+0x50/0x98) from
[<c02db4b4>] (emac_dev_open+0x3f4/0x4b8)
[   30.915364] [<c02db4b4>] (emac_dev_open+0x3f4/0x4b8) from
[<c0367b40>] (__dev_open+0xc0/0x130)
[   30.924086] [<c0367b40>] (__dev_open+0xc0/0x130) from [<c0367dc4>]
(__dev_change_flags+0x90/0x148)
[   30.933154] [<c0367dc4>] (__dev_change_flags+0x90/0x148) from
[<c0367f04>] (dev_change_flags+0x10/0x48)
[   30.942679] [<c0367f04>] (dev_change_flags+0x10/0x48) from
[<c0374510>] (do_setlink+0x2fc/0x838)
[   30.951591] [<c0374510>] (do_setlink+0x2fc/0x838) from [<c0374dec>]
(rtnl_newlink+0x2b4/0x458)
[   30.960328] [<c0374dec>] (rtnl_newlink+0x2b4/0x458) from
[<c03740b8>] (rtnetlink_rcv_msg+0x168/0x210)
[   30.969692] [<c03740b8>] (rtnetlink_rcv_msg+0x168/0x210) from
[<c037f50c>] (netlink_rcv_skb+0xac/0xc0)
[   30.979130] [<c037f50c>] (netlink_rcv_skb+0xac/0xc0) from
[<c0373f40>] (rtnetlink_rcv+0x1c/0x2c)
[   30.988040] [<c0373f40>] (rtnetlink_rcv+0x1c/0x2c) from
[<c037ee94>] (netlink_unicast+0x138/0x1e8)
[   30.997122] [<c037ee94>] (netlink_unicast+0x138/0x1e8) from
[<c037f2a4>] (netlink_sendmsg+0x2bc/0x37c)
[   31.006552] [<c037f2a4>] (netlink_sendmsg+0x2bc/0x37c) from
[<c0351f50>] (sock_sendmsg+0x84/0xa8)
[   31.015546] [<c0351f50>] (sock_sendmsg+0x84/0xa8) from [<c035338c>]
(___sys_sendmsg.part.35+0x268/0x278)
[   31.025150] [<c035338c>] (___sys_sendmsg.part.35+0x268/0x278) from
[<c03542e8>] (__sys_sendmsg+0x4c/0x7c)
[   ) from [<c0009560>] (ret_fast_syscall+0x0/0x2c)
[   31.043691] genirq: out_mask
[   31.046723] genirq: out_thread
[   31.049820] genirq: out_mput
[   31.052825] net net0: DaVinci EMAC: devm_request_irq() failed


> Is your configuration using device tree or not (my configuration
> is a none-devicetree one)?
No.

> I also wonder why your network device is net0, on
> my board it's eth0, maybe this triggers some bug?

I doubt that this is the source of the problem. The davinci_emac
interface is initiatially eth1 (we have a 2nd ethernet
port on board that initially is assigned eth0), I rename them eth1 ->
net0 and eth0 -> net1.
See http://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/

Jon
