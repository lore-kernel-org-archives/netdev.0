From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: smsc911x_suspend crash (was: Re: [PATCH] ARM: shmobile: r8a7778: Add
 missing call to shmobile_init_late())
Date: Thu, 14 Aug 2014 10:52:30 +0200
Message-ID: <CAMuHMdV7u-9DQ=TGBYSh2GvQgzQE3EAabXoEGU=3N4XyZ_Dx6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Geert Uytterhoeven <geert+renesas@glider.be>,
	Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Kevin Hilman <khilman@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33597 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755211AbaHNIwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 04:52:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon,

(taking this to netdev for the crash in smsc911x_suspend())

On Thu, Aug 14, 2014 at 8:16 AM, Simon Horman <horms@verge.net.au> wrote:
> while this may be part of the puzzle my light testing shows
> that suspend-to-ram does not appear to work with this patch applied.

Thanks for testing!

> My procedure is as followw.
>
> 1. Apply this patch on top of renesas-devel-v3.16-20140811
> 2. make bockw_defconfig
> 3. Select CONFIG_SUSPEND
> 4. Update r8a7778-bockw.dts to include no_console_suspend in bootargs

Alternative:

echo 0 > /sys/module/printk/parameters/console_suspend

> 4. Boot and then:
>
>    i. echo enabled > /sys/devices/platform/sh-sci.0/tty/ttySC0/power/wakeup
>    ii. echo mem > /sys/power/wakeup_count

Uh?

echo mem > /sys/power/state

> root@debian:~# echo mem > /sys/power/wakeup_count
> -bash: echo: write error: Invalid argument

I guess there's an "echo mem > /sys/power/state" here?

> INIT: Id "2" respawning too fast: disabled for 5 minutes
> INIT: Id "1" respawning too fast: disabled for 5 minutes
> ate
> PM: Syncing filesystems ... done.
> Freezing user space processes ... (elapsed 0.002 seconds) done.
> Freezing remaining freezable tasks ... (elapsed 0.002 seconds) done.
> rtc-rx8581 0-0051: low voltage detected, date/time is not reliable.
> Unable to handle kernel NULL pointer dereference at virtual address 00000620
> pgd = cfbec000
> [00000620] *pgd=6fbd1831, *pte=00000000, *ppte=00000000
> Internal error: Oops: 17 [#1] ARM
> CPU: 0 PID: 1591 Comm: bash Not tainted 3.16.0-00001-g535da58-dirty #44
> task: cfaa54c0 ti: cfaa8000 task.ti: cfaa8000
> PC is at smsc911x_suspend+0x18/0x3c
> LR is at dpm_run_callback.isra.11+0x24/0x50
> pc : [<c01d588c>]    lr : [<c019c004>]    psr: a0000093
> sp : cfaa9d98  ip : cfaa9db0  fp : cfaa9dac
> r10: 00000000  r9 : c03fbe78  r8 : 00000000
> r7 : cfa24474  r6 : c0426b7c  r5 : c01d5874  r4 : a0000013
> r3 : 00000000  r2 : 00000000  r1 : cfa24440  r0 : 00000000

drivers/net/ethernet/smsc/smsc911x.c:

static int smsc911x_suspend(struct device *dev)
{
        struct net_device *ndev = dev_get_drvdata(dev);

So ndev == NULL, boom!

        struct smsc911x_data *pdata = netdev_priv(ndev);

        /* enable wake on LAN, energy detection and the external PME
         * signal. */
        smsc911x_reg_write(pdata, PMT_CTRL,
                PMT_CTRL_PM_MODE_D1_ | PMT_CTRL_WOL_EN_ |
                PMT_CTRL_ED_EN_ | PMT_CTRL_PME_EN_);

        return 0;
}

However, I don't immediately see how this can be NULL.
smsc911x_drv_probe() does call "platform_set_drvdata(pdev, dev);".

And

        struct net_device *ndev = dev_get_drvdata(dev);

should be equivalent to

        struct platform_device *pdev = to_platform_device(dev);
        struct net_device *ndev = platform_get_drvdata(pdev);

Another SMSC driver, drivers/net/ethernet/smsc/smc91x.c has an explicit
NULL-check for ndev:

static int smc_drv_resume(struct device *dev)
{
        struct platform_device *pdev = to_platform_device(dev);
        struct net_device *ndev = platform_get_drvdata(pdev);

        if (ndev) {
                struct smc_local *lp = netdev_priv(ndev);
                ....
        }
        return 0;
}

But other drivers like igb don't.

Anyone with a clue? Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
