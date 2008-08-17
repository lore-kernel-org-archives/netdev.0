From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] net: forcedeth use pci_choose_state instead of PCI_D3hot - v2
Date: Sun, 17 Aug 2008 12:16:32 -0700
Message-ID: <86802c440808171216s1d87c4e3t965b3a93bf4b87f4@mail.gmail.com>
References: <1218954333-12819-1-git-send-email-yhlu.kernel@gmail.com>
	 <200808171502.02946.rjw@sisk.pl> <200808171855.58384.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@redhat.com>, "Ingo Molnar" <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:62031 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbYHQTQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 15:16:33 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1688751rvb.1
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2008 12:16:32 -0700 (PDT)
In-Reply-To: <200808171855.58384.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 9:55 AM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Sunday, 17 of August 2008, Rafael J. Wysocki wrote:
>> On Sunday, 17 of August 2008, Yinghai Lu wrote:
>> > after
>> >
>> > | commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
>> > | Author: Tobias Diedrich <ranma+kernel@tdiedrich.de>
>> > | Date:   Sun May 18 15:02:37 2008 +0200
>> > |
>> > |    [netdrvr] forcedeth: setup wake-on-lan before shutting down
>> > |
>> > |    When hibernating in 'shutdown' mode, after saving the image the suspend hook
>> > |    is not called again.
>> > |    However, if the device is in promiscous mode, wake-on-lan will not work.
>> > |    This adds a shutdown hook to setup wake-on-lan before the final shutdown.
>> > |
>> > |    Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>
>> > |    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>> >
>> > my servers with nvidia mcp55 nic doesn't work with msi in second kernel by kexec
>> >
>> > after remove pci_set_power_state(, PCI_D3hot) that nic/msi will work again.
>> >
>> > check with e1000 is using pci_choose_state in _shutdown.
>
> This is wrong.
>
>> > So change that pci_choose_state(pdev, ...), and it works.
>>
>> Well, this doesn't look like a good solution to me, because you're putting
>> PMSG_SUSPEND in there, which is not correct for shutdown.  The right thing to
>> do would be to avoid changing the device power state if nv_shutdown() is
>> used for kexec or to rework the initialization of the adapter to handle the
>> case when it's initially in D3.
>>
>> Does it help if you just remove the pci_set_power_state(pdev, PCI_D3hot)
>> altogether?
>
> Ah, sorry.  I see it does.
>
> Actually, I think you can use pci_prepare_to_sleep() instead of
> pci_enable_wake() / pci_set_power_state() combo.  It wasn't designed for this
> purpose, but should work nevertheless.
>
> Can you please check if the appended patch works instead of your one?
>
> Rafael
>
> ---
> Fix the problem that boxes with NVidia MCP55 don't work with MSI
> in a kexeced kernel.
>
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> ---
>  drivers/net/forcedeth.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> Index: linux-2.6/drivers/net/forcedeth.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/forcedeth.c
> +++ linux-2.6/drivers/net/forcedeth.c
> @@ -5975,10 +5975,8 @@ static void nv_shutdown(struct pci_dev *
>        if (netif_running(dev))
>                nv_close(dev);
>
> -       pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> -       pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
>        pci_disable_device(pdev);
> -       pci_set_power_state(pdev, PCI_D3hot);
> +       pci_prepare_to_sleep(pdev);
>  }
>  #else
>  #define nv_suspend NULL
>
>

your patch doesn't work...  it seems that silicon has problem with D3Hot

calling  init_nic+0x0/0x1b
forcedeth: Reverse Engineered nForce ethernet driver. Version 0.61.
..
forcedeth 0000:00:09.0: BAR 0: got res [0xdefb9000-0xdefb9fff] bus
[0xdefb9000-0xdefb9fff] flags 0x20200
forcedeth 0000:00:09.0: BAR 0: error updating (0xdefb9000 != 0x000000)
forcedeth 0000:00:09.0: BAR 0: moved to bus [0xdefb9000-0xdefb9fff]
flags 0x20200
forcedeth 0000:00:09.0: BAR 1: got res [0x8080-0x8087] bus
[0x8080-0x8087] flags 0x20101
forcedeth 0000:00:09.0: BAR 1: moved to bus [0x8080-0x8087] flags 0x20101
forcedeth 0000:00:09.0: BAR 2: got res [0xdefbe000-0xdefbe0ff] bus
[0xdefbe000-0xdefbe0ff] flags 0x20200
forcedeth 0000:00:09.0: BAR 2: moved to bus [0xdefbe000-0xdefbe0ff]
flags 0x20200
forcedeth 0000:00:09.0: BAR 3: got res [0xdefb8c00-0xdefb8c0f] bus
[0xdefb8c00-0xdefb8c0f] flags 0x20200
forcedeth 0000:00:09.0: BAR 3: moved to bus [0xdefb8c00-0xdefb8c0f]
flags 0x20200
forcedeth 0000:00:09.0: enabling device (0000 -> 0003)
forcedeth 0000:00:09.0: PCI INT A -> Link[LMAD] -> GSI 20 (level, low) -> IRQ 20
forcedeth 0000:00:09.0: enabling bus mastering
forcedeth 0000:00:09.0: setting latency timer to 64
forcedeth 0000:00:09.0: Invalid Mac address detected: ff:ff:ff:ff:ff:ff
forcedeth 0000:00:09.0: Please complain to your hardware vendor.
Switching to a random MAC.
forcedeth 0000:00:09.0: open: Could not find a valid PHY.
forcedeth 0000:00:09.0: PCI INT A disabled
forcedeth: probe of 0000:00:09.0 failed with error -12

forcedeth 0000:80:08.0: BAR 0: got res [0xddefb000-0xddefbfff] bus
[0xddefb000-0xddefbfff] flags 0x20200
forcedeth 0000:80:08.0: BAR 0: moved to bus [0xddefb000-0xddefbfff]
flags 0x20200
forcedeth 0000:80:08.0: BAR 1: got res [0x4080-0x4087] bus
[0x4080-0x4087] flags 0x20101
forcedeth 0000:80:08.0: BAR 1: moved to bus [0x4080-0x4087] flags 0x20101
forcedeth 0000:80:08.0: BAR 2: got res [0xddefac00-0xddefacff] bus
[0xddefac00-0xddefacff] flags 0x20200
forcedeth 0000:80:08.0: BAR 2: moved to bus [0xddefac00-0xddefacff]
flags 0x20200
forcedeth 0000:80:08.0: BAR 3: got res [0xddefa800-0xddefa80f] bus
[0xddefa800-0xddefa80f] flags 0x20200
forcedeth 0000:80:08.0: BAR 3: moved to bus [0xddefa800-0xddefa80f]
flags 0x20200
forcedeth 0000:80:08.0: enabling device (0000 -> 0003)
forcedeth 0000:80:08.0: PCI INT A -> Link[IIM0] -> GSI 47 (level, low) -> IRQ 47
forcedeth 0000:80:08.0: enabling bus mastering
forcedeth 0000:80:08.0: setting latency timer to 64
nv_probe: set workarund bit for reversed mac addr
forcedeth 0000:80:08.0: ifname eth1, PHY OUI 0x5043 @ 2, addr 00:14:4f:8d:5d:b0
forcedeth 0000:80:08.0: highdma csum vlan pwrctl mgmt timirq gbit
lnktim msi desc-v3
...
initcall init_nic+0x0/0x1b returned 0 after 5351 msecs

YH
