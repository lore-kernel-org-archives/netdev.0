From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH] net: fec: ptp: avoid register access when ipg clock is
 disabled
Date: Mon, 21 Jul 2014 12:02:37 +0800
Message-ID: <20140721040235.GA3159@dragon>
References: <1405910155-29760-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <b20596@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <richardcochran@gmail.com>
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns-bn1lp0143.outbound.protection.outlook.com ([207.46.163.143]:56630
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750985AbaGUECx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 00:02:53 -0400
Content-Disposition: inline
In-Reply-To: <1405910155-29760-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2014 at 10:35:55AM +0800, Fugang Duan wrote:
> FEC ptp driver start one period timer to read 1588 counter register in the
> ptp init function that is called after FEC driver is probed.
> 
> To save power, after FEC probe finish, FEC driver disable all clocks including
> ipg clock that is needed for register access.
> 
> i.MX5x, i.MX6q/dl/sl FEC register access don't cause system hang when ipg clock
> is disabled, just return zero value. But for i.MX6sx SOC, it cause system hang.
> 
> To avoid the issue, we need to check ptp stack is on, and then start to do ptp
> init and start period timer to read 1588 timer counter. After FEC is stopped,
> it needs to cancel the period timer.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Hmm, did you test the patch?  Here is what I got.

[    1.140488] ------------[ cut here ]------------
[    1.145122] Kernel BUG at 80034478 [verbose debug info unavailable]
[    1.151398] Internal error: Oops - BUG: 0 [#1] SMP ARM
[    1.156544] Modules linked in:
[    1.159628] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.16.0-rc3-00001-g774a94dd8770-dirty #268
[    1.168335] task: be078000 ti: be074000 task.ti: be074000
[    1.173752] PC is at mod_timer+0x148/0x160
[    1.177859] LR is at add_timer+0x20/0x28
[    1.181793] pc : [<80034478>]    lr : [<80034554>]    psr: 60000113
[    1.181793] sp : be075cc0  ip : be075cf0  fp : be075cec
[    1.193277] r10: 80400880  r9 : 00000000  r8 : ffffffff
[    1.198508] r7 : be3037a0  r6 : 00000000  r5 : 00000000  r4 : be3037e4
[    1.205041] r3 : 00000000  r2 : 00000000  r1 : 00000000  r0 : be3037e4
[    1.211577] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
[    1.218892] Control: 10c5387d  Table: 8000404a  DAC: 00000015
[    1.224645] Process swapper/0 (pid: 1, stack limit = 0xbe074240)
[    1.230658] Stack: (0xbe075cc0 to 0xbe076000)
[    1.235028] 5cc0: be303780 00000000 be075ce4 be302000 be30377c be303780 be3037a0 ffffffff
[    1.243216] 5ce0: be075cfc be075cf0 80034554 8003433c be075d3c be075d00 80400d04 80034540
[    1.251403] 5d00: be127800 60000113 43d94bd4 00000000 be075d3c be302000 00000000 be303700
[    1.259591] 5d20: be127800 be302600 00001748 000017f8 be075d6c be075d40 80400fb4 80400bdc
[    1.267778] 5d40: 00000010 be302000 be127800 be127810 8117ac70 000016e8 00000000 00000001
[    1.275964] 5d60: be075dc4 be075d70 803ffa74 80400ee8 00000000 00000001 be075dac be075d88
[    1.284150] 5d80: 80147e84 801448c0 be127810 00000001 00000000 00000000 8094efe4 be127810
[    1.292338] 5da0: 8094efe4 00000000 00000000 8094efe4 00000000 00000000 be075ddc be075dc8
[    1.300524] 5dc0: 8035ceb8 803ff704 81178390 be127810 be075e04 be075de0 8035b948 8035cea4
[    1.308710] 5de0: be127810 8094efe4 be127844 00000000 808ebaf8 be074000 be075e24 be075e08
[    1.316897] 5e00: 8035bb0c 8035b848 be10e7dc 00000000 8094efe4 8035ba70 be075e4c be075e28
[    1.325083] 5e20: 80359f88 8035ba7c be0038a8 be10e7d0 be38a158 8094efe4 be38a180 80941db8
[    1.333269] 5e40: be075e5c be075e50 8035b438 80359f38 be075e84 be075e60 8035b0ac 8035b424
[    1.341457] 5e60: 8084bae0 be075e70 8094efe4 80919f58 be389200 808b856c be075e9c be075e88
[    1.349643] 5e80: 8035c1c4 8035afdc 80919f58 80919f58 be075eac be075ea0 8035cdd8 8035c150
[    1.357830] 5ea0: be075ebc be075eb0 808ebb10 8035cd94 be075f54 be075ec0 8000899c 808ebb04
[    1.366018] 5ec0: 60000153 80926060 00000001 ffffffed be075eec be075ee0 80067968 80067794
[    1.374204] 5ee0: be075f0c be075ef0 be075f00 be075ef8 808b856c befffb21 80696d94 000000c6
[    1.382390] 5f00: be075f54 be075f10 80045058 808b8578 be075f34 00000006 befffb29 00000006
[    1.390576] 5f20: 808b5458 80851d50 be075f54 8090aa64 00000006 80972ac0 808b856c 000000c6
[    1.398762] 5f40: 808fdce4 808fdcf0 be075f94 be075f58 808b8d68 80008920 00000006 00000006
[    1.406948] 5f60: 808b856c 0851511b be074000 00000000 8066f7d4 00000000 00000000 00000000
[    1.415134] 5f80: 00000000 00000000 be075fac be075f98 8066f7e4 808b8c70 ffffffff 00000000
[    1.423322] 5fa0: 00000000 be075fb0 8000ec28 8066f7e0 00000000 00000000 00000000 00000000
[    1.431507] 5fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    1.439693] 5fe0: 00000000 00000000 00000000 00000000 00000013 00000000 deff7f6f f95817df
[    1.447873] Backtrace:
[    1.450351] [<80034330>] (mod_timer) from [<80034554>] (add_timer+0x20/0x28)
[    1.457405]  r8:ffffffff r7:be3037a0 r6:be303780 r5:be30377c r4:be302000
[    1.464212] [<80034534>] (add_timer) from [<80400d04>] (fec_ptp_start_cyclecounter+0x134/0x15c)
[    1.472923] [<80400bd0>] (fec_ptp_start_cyclecounter) from [<80400fb4>] (fec_ptp_init+0xd8/0x1ac)
[    1.481800]  r10:000017f8 r9:00001748 r8:be302600 r7:be127800 r6:be303700 r5:00000000
[    1.489721]  r4:be302000
[    1.492282] [<80400edc>] (fec_ptp_init) from [<803ffa74>] (fec_probe+0x37c/0xafc)
[    1.499769]  r10:00000001 r9:00000000 r8:000016e8 r7:8117ac70 r6:be127810 r5:be127800
[    1.507689]  r4:be302000 r3:00000010
[    1.511314] [<803ff6f8>] (fec_probe) from [<8035ceb8>] (platform_drv_probe+0x20/0x50)
[    1.519149]  r10:00000000 r9:00000000 r8:8094efe4 r7:00000000 r6:00000000 r5:8094efe4
[    1.527068]  r4:be127810
[    1.529630] [<8035ce98>] (platform_drv_probe) from [<8035b948>] (driver_probe_device+0x10c/0x234)
[    1.538507]  r5:be127810 r4:81178390
[    1.542127] [<8035b83c>] (driver_probe_device) from [<8035bb0c>] (__driver_attach+0x9c/0xa0)
[    1.550569]  r10:be074000 r8:808ebaf8 r7:00000000 r6:be127844 r5:8094efe4 r4:be127810
[    1.558501] [<8035ba70>] (__driver_attach) from [<80359f88>] (bus_for_each_dev+0x5c/0x90)
[    1.566682]  r6:8035ba70 r5:8094efe4 r4:00000000 r3:be10e7dc
[    1.572419] [<80359f2c>] (bus_for_each_dev) from [<8035b438>] (driver_attach+0x20/0x28)
[    1.580427]  r6:80941db8 r5:be38a180 r4:8094efe4
[    1.585105] [<8035b418>] (driver_attach) from [<8035b0ac>] (bus_add_driver+0xdc/0x1dc)
[    1.593032] [<8035afd0>] (bus_add_driver) from [<8035c1c4>] (driver_register+0x80/0xfc)
[    1.601040]  r7:808b856c r6:be389200 r5:80919f58 r4:8094efe4
[    1.606778] [<8035c144>] (driver_register) from [<8035cdd8>] (__platform_driver_register+0x50/0x64)
[    1.615827]  r5:80919f58 r4:80919f58
[    1.619454] [<8035cd88>] (__platform_driver_register) from [<808ebb10>] (fec_driver_init+0x18/0x20)
[    1.628513] [<808ebaf8>] (fec_driver_init) from [<8000899c>] (do_one_initcall+0x88/0x1d4)
[    1.636705] [<80008914>] (do_one_initcall) from [<808b8d68>] (kernel_init_freeable+0x104/0x1d4)
[    1.645409]  r10:808fdcf0 r9:808fdce4 r8:000000c6 r7:808b856c r6:80972ac0 r5:00000006
[    1.653327]  r4:8090aa64
[    1.655893] [<808b8c64>] (kernel_init_freeable) from [<8066f7e4>] (kernel_init+0x10/0xf4)
[    1.664075]  r10:00000000 r9:00000000 r8:00000000 r7:00000000 r6:00000000 r5:8066f7d4
[    1.671993]  r4:00000000
[    1.674558] [<8066f7d4>] (kernel_init) from [<8000ec28>] (ret_from_fork+0x14/0x2c)
[    1.682131]  r4:00000000 r3:ffffffff
[    1.685750] Code: e0065015 eaffffbd e3a08001 eaffffea (e7f001f2)
[    1.691873] ---[ end trace 456faf700d2d5df1 ]---
[    1.696588] Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
[    1.696588]
[    1.705739] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
