From: Lubomir Rintel <lkundrak@v3.sk>
Subject: RE: [PATCH] libertas sdio: remove CMD_FUNC_INIT call
Date: Tue, 19 Feb 2013 05:46:43 +0100
Message-ID: <1361249203.14137.27.camel@unicorn.kokotovo>
References: <1358493883-28433-1-git-send-email-lkundrak@v3.sk>
	 <477F20668A386D41ADCC57781B1F70430D140B07DE@SC-VEXCH1.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Harro Haan <hrhaan@gmail.com>, Dan Williams <dcbw@redhat.com>,
	"libertas-dev@lists.infradead.org" <libertas-dev@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bing Zhao <bzhao@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <477F20668A386D41ADCC57781B1F70430D140B07DE@SC-VEXCH1.marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-01-18 at 12:28 -0800, Bing Zhao wrote:
> Hi Lubomir,
> 
> > It actually times out on a 8688 present in GuruPlug with sd8688.bin
> > (md5=7233401e9687f8c880da547beed4324e) firmware (that's present in
> > linux-firmware tree), but the adapter works fine.
> > 
> > For that firmware times out with libertas_uap [1] as well, though it succeeds
> > with sd8688_ap.bin (md5=52cd8f8296b9a7e1d3835d57416256b2) that was originally
> > shipped with GuruPlug. That firmware is not in linux-firmware tree and btmrvl
> > driver might win the race programming the 8688 with sd8688.bin anyway.
> > 
> > [1] https://github.com/lkundrak/linux/tree/libertas_uap
> > ---
> >  drivers/net/wireless/libertas/if_sdio.c |   14 --------------
> >  1 files changed, 0 insertions(+), 14 deletions(-)
> > 
> > diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
> > index 2ecab49..3c4c555 100644
> > --- a/drivers/net/wireless/libertas/if_sdio.c
> > +++ b/drivers/net/wireless/libertas/if_sdio.c
> > @@ -825,20 +825,6 @@ static void if_sdio_finish_power_on(struct if_sdio_card *card)
> > 
> >  	sdio_release_host(func);
> > 
> > -	/*
> > -	 * FUNC_INIT is required for SD8688 WLAN/BT multiple functions
> > -	 */
> > -	if (card->model == MODEL_8688) {
> > -		struct cmd_header cmd;
> > -
> > -		memset(&cmd, 0, sizeof(cmd));
> > -
> > -		lbs_deb_sdio("send function INIT command\n");
> > -		if (__lbs_cmd(priv, CMD_FUNC_INIT, &cmd, sizeof(cmd),
> > -				lbs_cmd_copyback, (unsigned long) &cmd))
> > -			netdev_alert(priv->dev, "CMD_FUNC_INIT cmd failed\n");
> > -	}
> > -
> 
> Removing FUNC_INIT could break things in some scenarios.
> Could you please test the following case?
> 
> 1. insmod liberates -> download firmware, send FUNC_INIT, ...
> 2. rmmod libertas -> send FUNC_SHUTDOWN command to firmware; BT is still working.
> 3. insmod libertas -> skip firmware downloading, send FUNC_INIT, ...
> 
> If FUNC_INIT is removed, I don't expect step 3 to work.

In case btmrvl_sdio is loaded, the driver always locks up in FUNC_INIT
upon probe time, thus I'm not able to proceed to further steps.

[  209.338953] [<c0502248>] (__schedule+0x610/0x764) from [<bf20ae24>] (__lbs_cmd+0xb8/0x130 [libertas])
[  209.348340] [<bf20ae24>] (__lbs_cmd+0xb8/0x130 [libertas]) from [<bf222474>] (if_sdio_finish_power_on+0xec/0x1b0 [libertas_sdio])
[  209.360136] [<bf222474>] (if_sdio_finish_power_on+0xec/0x1b0 [libertas_sdio]) from [<bf2226c4>] (if_sdio_power_on+0x18c/0x20c [libertas_sdio])
[  209.373052] [<bf2226c4>] (if_sdio_power_on+0x18c/0x20c [libertas_sdio]) from [<bf222944>] (if_sdio_probe+0x200/0x31c [libertas_sdio])
[  209.385316] [<bf222944>] (if_sdio_probe+0x200/0x31c [libertas_sdio]) from [<bf01d820>] (sdio_bus_probe+0x94/0xfc [mmc_core])
[  209.396748] [<bf01d820>] (sdio_bus_probe+0x94/0xfc [mmc_core]) from [<c02e729c>] (driver_probe_device+0x12c/0x348)
[  209.407214] [<c02e729c>] (driver_probe_device+0x12c/0x348) from [<c02e7530>] (__driver_attach+0x78/0x9c)
[  209.416798] [<c02e7530>] (__driver_attach+0x78/0x9c) from [<c02e5658>] (bus_for_each_dev+0x50/0x88)
[  209.425946] [<c02e5658>] (bus_for_each_dev+0x50/0x88) from [<c02e6810>] (bus_add_driver+0x108/0x268)
[  209.435180] [<c02e6810>] (bus_add_driver+0x108/0x268) from [<c02e782c>] (driver_register+0xa4/0x134)
[  209.444426] [<c02e782c>] (driver_register+0xa4/0x134) from [<bf22601c>] (if_sdio_init_module+0x1c/0x3c [libertas_sdio])
[  209.455339] [<bf22601c>] (if_sdio_init_module+0x1c/0x3c [libertas_sdio]) from [<c00085b8>] (do_one_initcall+0x98/0x174)
[  209.466236] [<c00085b8>] (do_one_initcall+0x98/0x174) from [<c0076504>] (load_module+0x1c5c/0x1f80)
[  209.475390] [<c0076504>] (load_module+0x1c5c/0x1f80) from [<c007692c>] (sys_init_module+0x104/0x128)
[  209.484632] [<c007692c>] (sys_init_module+0x104/0x128) from [<c0008c40>] (ret_fast_syscall+0x0/0x38)

In case btmrvl_sdio is _not_ loaded, insmod returns, but driver locks up
waiting for FUNC_INIT to finish:

[  300.538859] [<c0502248>] (__schedule+0x610/0x764) from [<bf1fae24>] (__lbs_cmd+0xb8/0x130 [libertas])
[  300.548600] [<bf1fae24>] (__lbs_cmd+0xb8/0x130 [libertas]) from [<bf212474>] (if_sdio_finish_power_on+0xec/0x1b0 [libertas_sdio])
[  300.560398] [<bf212474>] (if_sdio_finish_power_on+0xec/0x1b0 [libertas_sdio]) from [<bf213230>] (if_sdio_do_prog_firmware+0x414/0x454 [libertas_sdio])
[  300.574052] [<bf213230>] (if_sdio_do_prog_firmware+0x414/0x454 [libertas_sdio]) from [<bf1fffbc>] (lbs_fw_loaded+0x24/0x58 [libertas])
[  300.586907] [<bf1fffbc>] (lbs_fw_loaded+0x24/0x58 [libertas]) from [<c02f02c0>] (request_firmware_work_func+0xb0/0xf4)
[  300.597746] [<c02f02c0>] (request_firmware_work_func+0xb0/0xf4) from [<c003ae0c>] (process_one_work+0x348/0x6a8)
[  300.608288] [<c003ae0c>] (process_one_work+0x348/0x6a8) from [<c003b408>] (worker_thread+0x268/0x390)
[  300.617630] [<c003b408>] (worker_thread+0x268/0x390) from [<c00414b0>] (kthread+0xc0/0xd4)
[  300.625947] [<c00414b0>] (kthread+0xc0/0xd4) from [<c0008ce8>] (ret_from_fork+0x14/0x20)
[  300.634135] 2 locks held by kworker/0:1/19:
[  300.638383]  #0:  (events){.+.+.+}, at: [<c003accc>] process_one_work+0x208/0x6a8
[  300.646512]  #1:  ((&fw_work->work)){+.+.+.}, at: [<c003accc>] process_one_work+0x208/0x6a8

If I remove the FUNC_INIT call, wifi works fine, but bluetooth stops
working after a network scan:

[root@megalodon lkundrak]# iwlist scan >/dev/null 2>&1
[root@megalodon lkundrak]# hcitool scan --flush
Device is not available: No such device
[root@megalodon lkundrak]# 

> 
> Thanks,
> Bing
> 
> >  	priv->fw_ready = 1;
> >  	wake_up(&card->pwron_waitq);
> > 
> > --
> > 1.7.1
