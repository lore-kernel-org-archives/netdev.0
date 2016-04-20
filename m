From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: [PATCH V2] net: stmmac: socfpga: Remove re-registration of reset
 controller
Date: Tue, 19 Apr 2016 21:04:14 -0500
Message-ID: <5716E39E.3010905@opensource.altera.com>
References: <1461110753-7641-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peppe.cavallaro@st.com>, <alexandre.torgue@st.com>,
	Matthew Gerlach <mgerlach@opensource.altera.com>,
	"David S . Miller" <davem@davemloft.net>
To: Marek Vasut <marex@denx.de>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0093.outbound.protection.outlook.com ([65.55.169.93]:55017
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751723AbcDTChR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 22:37:17 -0400
In-Reply-To: <1461110753-7641-1-git-send-email-marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/19/2016 07:05 PM, Marek Vasut wrote:
> Both socfpga_dwmac_parse_data() in dwmac-socfpga.c and stmmac_dvr_probe()
> in stmmac_main.c functions call devm_reset_control_get() to register an
> reset controller for the stmmac. This results in an attempt to register
> two reset controllers for the same non-shared reset line.
> 
> The first attempt to register the reset controller works fine. The second
> attempt fails with warning from the reset controller core, see below.
> The warning is produced because the reset line is non-shared and thus
> it is allowed to have only up-to one reset controller associated with
> that reset line, not two or more.
> 
> The solution is not great. Since the hardware needs to toggle the reset
> before calling stmmac_dvr_probe() to perform mandatory preconfiguration,
> this patch splits socfpga_dwmac_init_probe() from socfpga_dwmac_init().
> 
> The socfpga_dwmac_init_probe() temporarily registers the reset controller,
> performs the pre-configuration and unregisters the reset controller again.
> This function is only called from the socfpga_dwmac_probe().
> 
> The original socfpga_dwmac_init() is tweaked to use reset controller
> pointer from the stmmac_priv (private data of the stmmac core) instead
> of the local instance, which was used before.
> 
> Finally, plat_dat->exit and socfpga_dwmac_exit() is no longer necessary,
> since the functionality is already performed by the stmmac core.
> 
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 1 at drivers/reset/core.c:187 __of_reset_control_get+0x218/0x270
> Modules linked in:
> CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.6.0-rc4-next-20160419-00015-gabb2477-dirty #4
> Hardware name: Altera SOCFPGA
> [<c010f290>] (unwind_backtrace) from [<c010b82c>] (show_stack+0x10/0x14)
> [<c010b82c>] (show_stack) from [<c0373da4>] (dump_stack+0x94/0xa8)
> [<c0373da4>] (dump_stack) from [<c011bcc0>] (__warn+0xec/0x104)
> [<c011bcc0>] (__warn) from [<c011bd88>] (warn_slowpath_null+0x20/0x28)
> [<c011bd88>] (warn_slowpath_null) from [<c03a6eb4>] (__of_reset_control_get+0x218/0x270)
> [<c03a6eb4>] (__of_reset_control_get) from [<c03a701c>] (__devm_reset_control_get+0x54/0x90)
> [<c03a701c>] (__devm_reset_control_get) from [<c041fa30>] (stmmac_dvr_probe+0x1b4/0x8e8)
> [<c041fa30>] (stmmac_dvr_probe) from [<c04298c8>] (socfpga_dwmac_probe+0x1b8/0x28c)
> [<c04298c8>] (socfpga_dwmac_probe) from [<c03d6ffc>] (platform_drv_probe+0x4c/0xb0)
> [<c03d6ffc>] (platform_drv_probe) from [<c03d54ec>] (driver_probe_device+0x224/0x2bc)
> [<c03d54ec>] (driver_probe_device) from [<c03d5630>] (__driver_attach+0xac/0xb0)
> [<c03d5630>] (__driver_attach) from [<c03d382c>] (bus_for_each_dev+0x6c/0xa0)
> [<c03d382c>] (bus_for_each_dev) from [<c03d4ad4>] (bus_add_driver+0x1a4/0x21c)
> [<c03d4ad4>] (bus_add_driver) from [<c03d60ac>] (driver_register+0x78/0xf8)
> [<c03d60ac>] (driver_register) from [<c0101760>] (do_one_initcall+0x40/0x170)
> [<c0101760>] (do_one_initcall) from [<c0800e38>] (kernel_init_freeable+0x1dc/0x27c)
> [<c0800e38>] (kernel_init_freeable) from [<c05d1bd4>] (kernel_init+0x8/0x114)
> [<c05d1bd4>] (kernel_init) from [<c01076f8>] (ret_from_fork+0x14/0x3c)
> ---[ end trace 059d2fbe87608fa9 ]---
> 

Odd, I hadn't seen this error before. I would have noticed it, but I
haven't ran linux-next for a few days.

I see that this error was introduced on linux-next/next-20160414. The
error was not there prior to that. While I agree that the extra call to
get the reset control is not needed, I wonder what commit between
next-20160413 and next-20160414 exposed this error. I'll try to dig this
some more.

Dinh
