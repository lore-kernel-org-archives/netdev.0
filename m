From: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 1/3] dtb: xgene: fix: Backward compatibility with
 older firmware
Date: Fri, 9 Jan 2015 15:59:26 +0000
Message-ID: <1420819166.21186.38.camel@citrix.com>
References: <1415044796-5081-1-git-send-email-isubramanian@apm.com>
	 <1415044796-5081-2-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <patches-qTEPVZfXA3Y@public.gmane.org>,
	<kchudgar-qTEPVZfXA3Y@public.gmane.org>
To: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415044796-5081-2-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Iyappan,

On Mon, 2014-11-03 at 11:59 -0800, Iyappan Subramanian wrote:
> The following kernel crash was reported when using older firmware (<= 1.13.28).
> 
> [    0.980000] libphy: APM X-Gene MDIO bus: probed
> [    1.130000] Unhandled fault: synchronous external abort (0x96000010) at 0xffffff800009a17c
> [    1.140000] Internal error: : 96000010 [#1] SMP
> [    1.140000] Modules linked in:
> [    1.140000] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.17.0+ #21
> [    1.140000] task: ffffffc3f0110000 ti: ffffffc3f0064000 task.ti: ffffffc3f0064000
> [    1.140000] PC is at ioread32+0x58/0x68
> [    1.140000] LR is at xgene_enet_setup_ring+0x18c/0x1cc

I'm seeing what appears to be a similar crash (see the end) when booting
using UEFI firmware, which provides the DTB itself (as opposed to using
the kernel provided one like with u-boot).

Trying to boot using the kernel DTB instead of the firmware provided one
fails, I think because the UEFI firmware normally updates a bunch of
stuff at runtime in what it provides, but it can't in the external one.
(i.e. it has the wrong spintable stuff for cpu bringup)

This is running Debian's 3.16 kernel, which has the APM Ethernet related
stuff backported:
$ git log --oneline v3.16.7..debian/jessie/xgene 
        b2553d6 arm64: removed using of the mask attribute in the dts for reset bit.
        2d209a4 arm64: add missing dts entry for X-Gene platform.
        60651f8 dtb: Add SGMII based 1GbE node to APM X-Gene SoC device tree
        3f3c3da dtb: Add 10GbE node to APM X-Gene SoC device tree
        33b5408 drivers: net: xgene: fix: Use separate resources
        092e35e drivers: net: xgene: Backward compatibility with older firmware
        9f2bc2c drivers: net: xgene: Rewrite buggy loop in xgene_enet_ecc_init()
        c566829 drivers: net: xgene: Add SGMII based 1GbE ethtool support
        30bf224 drivers: net: xgene: Add SGMII based 1GbE support
        0d03931 drivers: net: xgene: Preparing for adding SGMII based 1GbE
        23a92cd drivers: net: xgene: Add 10GbE ethtool support
        226068a drivers: net: xgene: Add 10GbE support
        33f8dba drivers: net: xgene: Preparing for adding 10GbE support
        a7b5fd0 dts: Add bindings for APM X-Gene SoC ethernet driver
        82df3ba drivers: net: NET_XGENE should depend on HAS_DMA
        0dcba55 net: xgene: fix possible NULL dereference in xgene_enet_free_desc_rings()
        2aa3e0d net: xgene: Check negative return value of xgene_enet_get_ring_size()
        589e045 drivers: net: Add APM X-Gene SoC ethernet driver support.
        
With the builtin DTB I see:

        (initramfs) od -A x -t x4 /proc/device-tree/soc/ethernet@17020000/reg
        000000 00000000 00000217 00000000 00d10000
        000010 00000000 00000317 00000000 00040000
        000020 00000000 00000010 00000000 00020000
        
Which seems to correspond to before your patch.

I'm running mustang_sw_1.13.29-beta, using the mustang_tianocore_ubt.fd
method to launch from u-boot.

Ian.

[    7.662085] Unhandled fault: synchronous external abort (0x96000010) at 0xffffff800009a208
[    7.670332] Internal error: : 96000010 [#1] SMP
[    7.674839] Modules linked in: xgene_enet(+) of_mdio libphy dm_mod(+)
[    7.681300] CPU: 0 PID: 97 Comm: systemd-udevd Not tainted 3.16.0-4-arm64 #1 Debian 3.16.7-ckt2-1
[    7.690126] task: ffffffc3f9ca0c80 ti: ffffffc3f9d2c000 task.ti: ffffffc3f9d2c000
[    7.697571] PC is at ioread32+0x58/0x68
[    7.701388] LR is at xgene_ring_mgr_init+0x28/0x58 [xgene_enet]
[    7.707276] pc : [<ffffffc0002e5318>] lr : [<ffffffbffc035d18>] pstate: a0000145
[    7.714632] sp : ffffffc3f9d2f9c0
[    7.717926] x29: ffffffc3f9d2f9c0 x28: 0000000000000001 
[    7.723229] x27: ffffffc0006fa000 x26: 0000000000000000 
[    7.728533] x25: ffffffc3f9ce9000 x24: ffffffc3f9ce9000 
[    7.733836] x23: ffffffc3eb876010 x22: ffffffc3eb876000 
[    7.739138] x21: ffffffc000763000 x20: ffffffc3f9ce98c0 
[    7.744443] x19: ffffffc3f9ce98c0 x18: 00000000c3663f63 
[    7.749745] x17: 00000000c14123be x16: 00000000ca92bd38 
[    7.755048] x15: 00000000d02a0bde x14: 0000000000000000 
[    7.760350] x13: 0000000000000000 x12: 0000000000000000 
[    7.765652] x11: 0000000000000000 x10: 0000000000000000 
[    7.770955] x9 : 0000000000000000 x8 : 0000000000000000 
[    7.776257] x7 : 0000000000000000 x6 : 0000000000000000 
[    7.781559] x5 : ffffffc00074b310 x4 : 0000000000000000 
[    7.786861] x3 : 0000000000000000 x2 : 000000000003ffff 
[    7.792165] x1 : ffffff800009a208 x0 : ffffff800009a208 
[    7.797467] 
[    7.798948] Process systemd-udevd (pid: 97, stack limit = 0xffffffc3f9d2c058)
[    7.806046] Stack: (0xffffffc3f9d2f9c0 to 0xffffffc3f9d30000)
[    7.811762] f9c0: f9d2f9d0 ffffffc3 fc035d18 ffffffbf f9d2f9f0 ffffffc3 fc035d6c ffffffbf
[    7.819897] f9e0: f9ce98c0 ffffffc3 f9d2f9e0 ffffffc3 f9d2fa30 ffffffc3 fc038110 ffffffbf
[    7.828032] fa00: f9ce98c0 ffffffc3 f9ce9000 ffffffc3 00763000 ffffffc0 f9ce9000 ffffffc3
[    7.836167] fa20: 0000005c 00000000 00000000 00000000 f9d2fa80 ffffffc3 00343d24 ffffffc0
[    7.844302] fa40: eb876010 ffffffc3 fc039f38 ffffffbf 0075d000 ffffffc0 00000000 00000000
[    7.852436] fa60: fc039f60 ffffffbf 00000000 00000000 00000001 00000000 00000000 00000000
[    7.860571] fa80: f9d2faa0 ffffffc3 00341ad0 ffffffc0 eb876010 ffffffc3 007cb000 ffffffc0
[    7.868706] faa0: f9d2faf0 ffffffc3 00341edc ffffffc0 eb876010 ffffffc3 fc039f60 ffffffbf
[    7.876840] fac0: eb876070 ffffffc3 00000000 00000000 0073d000 ffffffc0 00000000 00000000
[    7.884974] fae0: fec449c0 ffffffc0 0033fa04 ffffffc0 f9d2fb20 ffffffc3 0033f9f8 ffffffc0
[    7.893109] fb00: 00000000 00000000 fc039f60 ffffffbf 00341e30 ffffffc0 00000000 00000000
[    7.901244] fb20: f9d2fb70 ffffffc3 003414f8 ffffffc0 fc039f60 ffffffbf f9c5d100 ffffffc3
[    7.909378] fb40: 0073dd40 ffffffc0 ffffffe0 00000000 f9d2fb70 ffffffc3 00000000 00000000
[    7.917512] fb60: eba48aa8 ffffffc3 ff4328e8 ffffffc3 f9d2fb90 ffffffc3 003410b4 ffffffc0
[    7.925647] fb80: fc039f60 ffffffbf fc039f60 ffffffbf f9d2fbd0 ffffffc3 0034276c ffffffc0
[    7.933781] fba0: fc039f60 ffffffbf fec4df00 ffffffc0 00000000 00000000 fc03d000 ffffffbf
[    7.941916] fbc0: f9d2c000 ffffffc3 0073dd40 ffffffc0 f9d2fc00 ffffffc3 00343cec ffffffc0
[    7.950050] fbe0: fc039f38 ffffffbf fec4df00 ffffffc0 006e07a0 ffffffc0 f9d2fc40 ffffffc3
[    7.958185] fc00: f9d2fc30 ffffffc3 fc03d01c ffffffbf 006e07a0 ffffffc0 00081490 ffffffc0
[    7.966319] fc20: 006e07a0 ffffffc0 fc03a240 ffffffbf f9d2fc40 ffffffc3 000814a0 ffffffc0
[    7.974453] fc40: f9d2fcc0 ffffffc3 00109f30 ffffffc0 f9d2fe70 ffffffc3 00000001 00000000
[    7.982588] fc60: fc03a258 ffffffbf f9d2c000 ffffffc3 fc03a290 ffffffbf fc03a240 ffffffbf
[    7.990723] fc80: 0007d000 ffffff80 00000001 00000000 fc03a258 ffffffbf f9d2c000 ffffffc3
[    7.998857] fca0: f9d2fcc0 ffffffc3 00109efc ffffffc0 f9d2fe70 ffffffc3 0010a264 ffffffc0
[    8.006992] fcc0: f9d2fe40 ffffffc3 0010a8d8 ffffffc0 00000000 00000000 00000009 00000000
[    8.015126] fce0: 94b29108 0000007f 94c78ee4 0000007f 60000000 00000000 00000015 00000000
[    8.023261] fd00: 00000118 00000000 00000111 00000000 006e4000 ffffffc0 f9d2c000 ffffffc3
[    8.031395] fd20: ff588500 ffffffc3 00106ad8 ffffffc0 fec449d0 ffffffc0 00000072 00000000
[    8.039530] fd40: 0000006e 00000000 005e7140 ffffffc0 0000003f 00000000 0000feff 00000000
[    8.047664] fd60: 0000fff1 00000000 0000001b 00000000 f9d2fde0 ffffffc3 0075a648 ffffffc0
[    8.055799] fd80: 0075a3c8 ffffffc0 fc03d028 ffffffbf f9d2fec4 ffffffc3 000000f1 ffffff80
[    8.063933] fda0: f9d2fe80 ffffffc3 94b29108 0000007f 006fa5b0 ffffffc0 007641a0 ffffffc0
[    8.072068] fdc0: 60000000 00000000 00000015 00000000 00000010 00000000 0000138c 00000000
[    8.080203] fde0: 00000001 ffff81a4 00000001 00000000 00000000 00000000 00000000 00000000
[    8.088337] fe00: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    8.096471] fe20: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    8.104605] fe40: fb748da0 0000007f 0008421c ffffffc0 00000000 00000000 00000000 00000000
[    8.112740] fe60: ffffffff ffffffff 00000009 00000000 0007d000 ffffff80 0000e3b8 00000000
[    8.120874] fe80: 0008acb8 ffffff80 00083c8e ffffff80 00085428 ffffff80 00005478 00000000
[    8.129009] fea0: 00005c40 00000000 fc03a178 ffffffbf 00000005 00000000 0000001a 0000001b
[    8.137143] fec0: 00000012 0000000d 0000000c 00000000 00000009 00000000 94b29108 0000007f
[    8.145278] fee0: 00000000 00000000 00000009 00000000 00000000 00000000 00000041 00000000
[    8.153412] ff00: 00000001 00000000 00000001 00000000 00000111 00000000 6dff7364 644d3965
[    8.161547] ff20: 00000000 00000000 0000000a 00000000 00000004 00000000 00000004 00000000
[    8.169681] ff40: 67782f65 2d656e65 94cfa588 0000007f 94b3b290 0000007f 94c78ec0 0000007f
[    8.177816] ff60: fb748b00 0000007f 74bd9070 00000055 00000000 00000000 94b29108 0000007f
[    8.185950] ff80: 00020000 00000000 fb7493c8 0000007f 74bd9200 00000055 74be13e0 00000055
[    8.194084] ffa0: 00000000 00000000 00000000 00000000 00020000 00000000 fb748da0 0000007f
[    8.202219] ffc0: 94b22d44 0000007f fb748da0 0000007f 94c78ee4 0000007f 60000000 00000000
[    8.210353] ffe0: 00000009 00000000 00000111 00000000 00000000 00000000 00000000 00000000
[    8.218487] Call trace:
[    8.220920] [<ffffffc0002e5318>] ioread32+0x58/0x68
[    8.225773] [<ffffffbffc035d14>] xgene_ring_mgr_init+0x24/0x58 [xgene_enet]
[    8.232699] [<ffffffbffc035d68>] xgene_enet_reset+0x20/0x17c [xgene_enet]
[    8.239452] [<ffffffbffc03810c>] xgene_enet_probe+0x2c4/0x784 [xgene_enet]
[    8.246292] [<ffffffc000343d20>] platform_drv_probe+0x28/0x60
[    8.252008] [<ffffffc000341acc>] driver_probe_device+0xa4/0x3ac
[    8.257896] [<ffffffc000341ed8>] __driver_attach+0xa8/0xb0
[    8.263352] [<ffffffc00033f9f4>] bus_for_each_dev+0x68/0xac
[    8.268895] [<ffffffc0003414f4>] driver_attach+0x2c/0x38
[    8.274177] [<ffffffc0003410b0>] bus_add_driver+0x16c/0x248
[    8.279720] [<ffffffc000342768>] driver_register+0x6c/0x138
[    8.285262] [<ffffffc000343ce8>] __platform_driver_register+0x74/0x84
[    8.291670] [<ffffffbffc03d018>] $x+0x18/0x24 [xgene_enet]
[    8.297127] [<ffffffc00008149c>] do_one_initcall+0xcc/0x1bc
[    8.302671] [<ffffffc000109f2c>] load_module+0x1a20/0x220c
[    8.308127] [<ffffffc00010a8d4>] SyS_finit_module+0x94/0xc0
[    8.313670] Code: 97ffffa5 12800000 a8c17bfd d65f03c0 (b9400000) 
[    8.319746] ---[ end trace f59ed15aa4f2049f ]---


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
