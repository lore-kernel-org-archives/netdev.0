From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Tue, 16 Dec 2014 15:59:28 -0200
Message-ID: <54907300.9050902@gmail.com>
References: <20141213210251.GA12812@teela.fritz.box> <548EF90A.5070607@gmail.com> <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com> <CAErSpo5dqQE7nZ6zf2odgpHBWA3ZpTjhbgQKnY8YxQW+a+298w@mail.gmail.com> <1418750141.4248.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Rajat Jain <rajatxjain@gmail.com>,
	Nils Holland <nholland@tisys.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Rafael Wysocki <rjw@rjwysocki.net>,
	Prashant Sreedharan <prashant@broadcom.com>
To: Michael Chan <mchan@broadcom.com>,
	Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1418750141.4248.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-12-2014 15:15, Michael Chan wrote:
> On Tue, 2014-12-16 at 09:20 -0700, Bjorn Helgaas wrote:
>> I think we're in this path:
>>
>>      tg3_init_hw
>>        tg3_reset_hw
>>          tg3_disable_ints
>>          tg3_stop_fw
>>          tg3_write_sig_pre_reset
>>          tg3_chip_reset
>>            pci_device_is_present
>>              pci_bus_read_dev_vendor_id
>>
>> and in this case pci_device_is_present() also passes a timeout of zero
>> to pci_bus_read_dev_vendor_id().  My guess is that tg3 is resetting
>> the device, so it's not too surprising that the config read returns
>> CRS status immediately afterward.
>>
> At the point of calling pci_device_is_present(), chip reset hasn't
> started yet, so there should be no problem reading config space.
> 
> In all the newer tg3 chips, chip reset does not reset the PCIE block.
> So I think config space should always be accesible even during reset.

It's a 
02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5722 Gigabit Ethernet PCI Express
over here

I put a WARN_ON(1) after those printks, and this is what I got:

[    1.550640] pci 0000:02:00.0: 1st 1 1
[    1.550643] pci 0000:02:00.0: crs_timeout: 0
[    1.550645] ------------[ cut here ]------------
[    1.550651] WARNING: CPU: 6 PID: 364 at drivers/pci/probe.c:1445 pci_bus_read_dev_vendor_id+0x1d4/0x1e0()
[    1.550652] Modules linked in: i915(+) raid0 i2c_algo_bit drm_kms_helper drm e1000e(+) tg3(+) ptp pps_core video
[    1.550660] CPU: 6 PID: 364 Comm: systemd-udevd Not tainted 3.18.0-rc6+ #8
[    1.550661] Hardware name: Dell Inc. OptiPlex 9010/03K80F, BIOS A15 08/12/2013
[    1.550662]  0000000000000000 000000004de2d8dc ffff8807eabdf948 ffffffff8173db46
[    1.550665]  0000000000000000 0000000000000000 ffff8807eabdf988 ffffffff81094d41
[    1.550667]  ffff8807eabdf968 ffff8807f1e27000 0000000000000000 0000000000000000
[    1.550669] Call Trace:
[    1.550675]  [<ffffffff8173db46>] dump_stack+0x46/0x58
[    1.550679]  [<ffffffff81094d41>] warn_slowpath_common+0x81/0xa0
[    1.550681]  [<ffffffff81094e5a>] warn_slowpath_null+0x1a/0x20
[    1.550683]  [<ffffffff813b2864>] pci_bus_read_dev_vendor_id+0x1d4/0x1e0
[    1.550687]  [<ffffffff813b7c3e>] pci_device_is_present+0x2e/0x50
[    1.550693]  [<ffffffffa003364f>] tg3_chip_reset+0x2f/0x940 [tg3]
[    1.550697]  [<ffffffffa0033f9f>] tg3_halt+0x3f/0x1e0 [tg3]
[    1.550701]  [<ffffffffa0044f83>] tg3_init_one+0xb83/0x1a40 [tg3]
[    1.550705]  [<ffffffff8127d2bb>] ? kernfs_activate+0x7b/0xf0
[    1.550708]  [<ffffffff813bbdc5>] local_pci_probe+0x45/0xa0
[    1.550711]  [<ffffffff8127fa8d>] ? sysfs_do_create_link_sd.isra.2+0x6d/0xc0
[    1.550714]  [<ffffffff813bd1b9>] pci_device_probe+0xf9/0x150
[    1.550717]  [<ffffffff814906fd>] driver_probe_device+0x12d/0x3d0
[    1.550720]  [<ffffffff81490a7b>] __driver_attach+0x9b/0xa0
[    1.550722]  [<ffffffff814909e0>] ? __device_attach+0x40/0x40
[    1.550724]  [<ffffffff8148e4f3>] bus_for_each_dev+0x73/0xc0
[    1.550726]  [<ffffffff814900ee>] driver_attach+0x1e/0x20
[    1.550729]  [<ffffffff8148fcb0>] bus_add_driver+0x180/0x250
[    1.550731]  [<ffffffffa0050000>] ? 0xffffffffa0050000
[    1.550733]  [<ffffffff81491274>] driver_register+0x64/0xf0
[    1.550735]  [<ffffffff813bb72b>] __pci_register_driver+0x4b/0x50
[    1.550739]  [<ffffffffa005001e>] tg3_driver_init+0x1e/0x1000 [tg3]
[    1.550742]  [<ffffffff81002144>] do_one_initcall+0xd4/0x210
[    1.550747]  [<ffffffff811cbc42>] ? __vunmap+0xc2/0x110
[    1.550751]  [<ffffffff8111336b>] load_module+0x1cab/0x2730
[    1.550753]  [<ffffffff8110efc0>] ? store_uevent+0x70/0x70
[    1.550756]  [<ffffffff8120b090>] ? kernel_read+0x50/0x80
[    1.550760]  [<ffffffff81113fa6>] SyS_finit_module+0xa6/0xd0
[    1.550763]  [<ffffffff81745129>] system_call_fastpath+0x12/0x17
[    1.550764] ---[ end trace 4cc3153e369484ea ]---
[    1.550963] tg3 0000:02:00.0 eth0: Tigon3 [partno(BCM95722) rev a200] (PCI Express) MAC address 00:0a:f7:2b:9b:39
[    1.550965] tg3 0000:02:00.0 eth0: attached PHY is 5722/5756 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[    1.550966] tg3 0000:02:00.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[    1.550967] tg3 0000:02:00.0 eth0: dma_rwctrl[76180000] dma_mask[64-bit]
[    1.556112] tg3 0000:02:00.0 p1p1: renamed from eth0
...

[   23.545119] tg3 0000:02:00.0: irq 32 for MSI/MSI-X
[   25.424981] tg3 0000:02:00.0 p1p1: No firmware running
[   25.425686] pci 0000:02:00.0: 1st 1 1
[   25.425687] pci 0000:02:00.0: crs_timeout: 0
[   25.425687] ------------[ cut here ]------------
[   25.425691] WARNING: CPU: 0 PID: 1590 at drivers/pci/probe.c:1445 pci_bus_read_dev_vendor_id+0x1d4/0x1e0()
[   25.425692] Modules linked in: bridge stp llc openvswitch x86_pkg_temp_thermal coretemp kvm_intel kvm snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_co
dec_generic snd_hda_intel snd_hda_controller snd_hda_codec crct10dif_pclmul snd_hwdep crc32_pclmul crc32c_intel ghash_clmulni_intel snd_seq mei_me snd_seq_d
evice snd_pcm iTCO_wdt iTCO_vendor_support snd_timer mei snd lpc_ich i2c_i801 pcspkr mfd_core dcdbas serio_raw soundcore microcode ie31200_edac shpchp edac_
core nfsd auth_rpcgss nfs_acl lockd grace sunrpc binfmt_misc xfs libcrc32c i915 raid0 i2c_algo_bit drm_kms_helper drm e1000e tg3 ptp pps_core video
[   25.425714] CPU: 0 PID: 1590 Comm: ip Tainted: G        W      3.18.0-rc6+ #8
[   25.425715] Hardware name: Dell Inc. OptiPlex 9010/03K80F, BIOS A15 08/12/2013
[   25.425716]  0000000000000000 0000000097b01d0c ffff8807f0687408 ffffffff8173db46
[   25.425717]  0000000000000000 0000000000000000 ffff8807f0687448 ffffffff81094d41
[   25.425719]  ffff8807f0687428 ffff8807f1e27000 0000000000000000 0000000000000000
[   25.425720] Call Trace:
[   25.425723]  [<ffffffff8173db46>] dump_stack+0x46/0x58
[   25.425726]  [<ffffffff81094d41>] warn_slowpath_common+0x81/0xa0
[   25.425728]  [<ffffffff81094e5a>] warn_slowpath_null+0x1a/0x20
[   25.425729]  [<ffffffff813b2864>] pci_bus_read_dev_vendor_id+0x1d4/0x1e0
[   25.425733]  [<ffffffffa0028b47>] ? tg3_phy_auxctl_write+0x27/0x30 [tg3]
[   25.425735]  [<ffffffff813b7c3e>] pci_device_is_present+0x2e/0x50
[   25.425738]  [<ffffffffa003364f>] tg3_chip_reset+0x2f/0x940 [tg3]
[   25.425740]  [<ffffffffa003756d>] tg3_reset_hw+0x8d/0x2ce0 [tg3]
[   25.425743]  [<ffffffff81383f6a>] ? delay_tsc+0x4a/0x80
[   25.425744]  [<ffffffff81383eec>] ? __udelay+0x2c/0x30
[   25.425747]  [<ffffffffa0026be4>] ? _tw32_flush+0x44/0x80 [tg3]
[   25.425749]  [<ffffffffa003a216>] tg3_init_hw+0x56/0x60 [tg3]
[   25.425751]  [<ffffffffa003c0d5>] tg3_start+0xbe5/0x1210 [tg3]
[   25.425753]  [<ffffffff81383eec>] ? __udelay+0x2c/0x30
[   25.425755]  [<ffffffffa0026be4>] ? _tw32_flush+0x44/0x80 [tg3]
[   25.425757]  [<ffffffffa003c828>] tg3_open+0x128/0x2e0 [tg3]
[   25.425760]  [<ffffffff8162c6cf>] __dev_open+0xcf/0x140
[   25.425761]  [<ffffffff8162c9f1>] __dev_change_flags+0xa1/0x160
[   25.425762]  [<ffffffff8162cad9>] dev_change_flags+0x29/0x60
[   25.425764]  [<ffffffff8163a4a9>] do_setlink+0x399/0xa90
[   25.425766]  [<ffffffff8163ca7c>] rtnl_newlink+0x51c/0x740
[   25.425768]  [<ffffffff8163c653>] ? rtnl_newlink+0xf3/0x740
[   25.425771]  [<ffffffff811e730c>] ? new_slab+0x14c/0x490
[   25.425774]  [<ffffffff81303188>] ? security_capable+0x18/0x20
[   25.425776]  [<ffffffff8109cf7d>] ? ns_capable+0x2d/0x60
[   25.425778]  [<ffffffff816391a4>] rtnetlink_rcv_msg+0xa4/0x270
[   25.425780]  [<ffffffff8165840d>] ? __netlink_lookup+0x4d/0x70
[   25.425781]  [<ffffffff81639100>] ? rtnetlink_rcv+0x40/0x40
[   25.425783]  [<ffffffff8165c4a1>] netlink_rcv_skb+0xc1/0xe0
[   25.425784]  [<ffffffff816390ec>] rtnetlink_rcv+0x2c/0x40
[   25.425785]  [<ffffffff8165ba26>] netlink_unicast+0x106/0x210
[   25.425787]  [<ffffffff8165be55>] netlink_sendmsg+0x325/0x790
[   25.425788]  [<ffffffff8160de50>] sock_sendmsg+0xa0/0xe0
[   25.425791]  [<ffffffff8120e8cd>] ? lookup_real+0x1d/0x50
[   25.425792]  [<ffffffff8160e394>] ___sys_sendmsg+0x2f4/0x310
[   25.425794]  [<ffffffff8119bdf2>] ? lru_cache_add_active_or_unevictable+0x32/0xc0
[   25.425796]  [<ffffffff8160c673>] ? sock_destroy_inode+0x33/0x40
...
[   25.425794]  [<ffffffff8119bdf2>] ? lru_cache_add_active_or_unevictable+0x32/0xc0
[   25.425796]  [<ffffffff8160c673>] ? sock_destroy_inode+0x33/0x40
[   25.425798]  [<ffffffff8121bfd5>] ? __dentry_kill+0x145/0x1d0
[   25.425799]  [<ffffffff8121c105>] ? dput+0xa5/0x170
[   25.425800]  [<ffffffff81224f74>] ? mntput+0x24/0x40
[   25.425802]  [<ffffffff81206d6a>] ? __fput+0x17a/0x1e0
[   25.425803]  [<ffffffff8160ee21>] __sys_sendmsg+0x51/0x90
[   25.425805]  [<ffffffff8160ee72>] SyS_sendmsg+0x12/0x20
[   25.425807]  [<ffffffff81745129>] system_call_fastpath+0x12/0x17
[   25.425808] ---[ end trace 4cc3153e369484eb ]---
[   25.427385] pci 0000:02:00.0: 1st 1 1
[   25.427386] pci 0000:02:00.0: crs_timeout: 0
[   25.427387] ------------[ cut here ]------------
[   25.427389] WARNING: CPU: 0 PID: 1590 at drivers/pci/probe.c:1445 pci_bus_read_dev_vendor_id+0x1d4/0x1e0()
[   25.427389] Modules linked in: bridge stp llc openvswitch x86_pkg_temp_thermal coretemp kvm_intel kvm snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_codec_generic snd_hda_intel snd_hda_controller snd_hda_codec crct10dif_pclmul snd_hwdep crc32_pclmul crc32c_intel ghash_clmulni_intel snd_seq mei_me snd_seq_device snd_pcm iTCO_wdt iTCO_vendor_support snd_timer mei snd lpc_ich i2c_i801 pcspkr mfd_core dcdbas serio_raw soundcore microcode ie31200_edac shpchp edac_core nfsd auth_rpcgss nfs_acl lockd grace sunrpc binfmt_misc xfs libcrc32c i915 raid0 i2c_algo_bit drm_kms_helper drm e1000e tg3 ptp pps_core video
[   25.427403] CPU: 0 PID: 1590 Comm: ip Tainted: G        W      3.18.0-rc6+ #8
[   25.427404] Hardware name: Dell Inc. OptiPlex 9010/03K80F, BIOS A15 08/12/2013
[   25.427405]  0000000000000000 0000000097b01d0c ffff8807f0687488 ffffffff8173db46
[   25.427406]  0000000000000000 0000000000000000 ffff8807f06874c8 ffffffff81094d41
[   25.427416]  ffff8807f06874a8 ffff8807f1e27000 0000000000000000 0000000000000000
[   25.427417] Call Trace:
[   25.427418]  [<ffffffff8173db46>] dump_stack+0x46/0x58
[   25.427420]  [<ffffffff81094d41>] warn_slowpath_common+0x81/0xa0
[   25.427421]  [<ffffffff81094e5a>] warn_slowpath_null+0x1a/0x20
[   25.427423]  [<ffffffff813b2864>] pci_bus_read_dev_vendor_id+0x1d4/0x1e0
[   25.427425]  [<ffffffff813b7c3e>] pci_device_is_present+0x2e/0x50
[   25.427427]  [<ffffffffa003364f>] tg3_chip_reset+0x2f/0x940 [tg3]
[   25.427430]  [<ffffffffa0033f9f>] tg3_halt+0x3f/0x1e0 [tg3]
[   25.427433]  [<ffffffffa003c208>] tg3_start+0xd18/0x1210 [tg3]
[   25.427434]  [<ffffffff81383eec>] ? __udelay+0x2c/0x30
[   25.427437]  [<ffffffffa0026be4>] ? _tw32_flush+0x44/0x80 [tg3]
[   25.427439]  [<ffffffffa003c828>] tg3_open+0x128/0x2e0 [tg3]
[   25.427441]  [<ffffffff8162c6cf>] __dev_open+0xcf/0x140
[   25.427442]  [<ffffffff8162c9f1>] __dev_change_flags+0xa1/0x160
[   25.427443]  [<ffffffff8162cad9>] dev_change_flags+0x29/0x60
[   25.427445]  [<ffffffff8163a4a9>] do_setlink+0x399/0xa90
[   25.427448]  [<ffffffff8163ca7c>] rtnl_newlink+0x51c/0x740
[   25.427449]  [<ffffffff8163c653>] ? rtnl_newlink+0xf3/0x740
[   25.427449]  [<ffffffff8163c653>] ? rtnl_newlink+0xf3/0x740
[   25.427452]  [<ffffffff811e730c>] ? new_slab+0x14c/0x490
[   25.427454]  [<ffffffff81303188>] ? security_capable+0x18/0x20
[   25.427455]  [<ffffffff8109cf7d>] ? ns_capable+0x2d/0x60
[   25.427457]  [<ffffffff816391a4>] rtnetlink_rcv_msg+0xa4/0x270
[   25.427459]  [<ffffffff8165840d>] ? __netlink_lookup+0x4d/0x70
[   25.427460]  [<ffffffff81639100>] ? rtnetlink_rcv+0x40/0x40
[   25.427462]  [<ffffffff8165c4a1>] netlink_rcv_skb+0xc1/0xe0
[   25.427464]  [<ffffffff816390ec>] rtnetlink_rcv+0x2c/0x40
[   25.427465]  [<ffffffff8165ba26>] netlink_unicast+0x106/0x210
[   25.427466]  [<ffffffff8165be55>] netlink_sendmsg+0x325/0x790
[   25.427468]  [<ffffffff8160de50>] sock_sendmsg+0xa0/0xe0
[   25.427469]  [<ffffffff8120e8cd>] ? lookup_real+0x1d/0x50
[   25.427471]  [<ffffffff8160e394>] ___sys_sendmsg+0x2f4/0x310
[   25.427472]  [<ffffffff8119bdf2>] ? lru_cache_add_active_or_unevictable+0x32/0xc0
[   25.427475]  [<ffffffff8160c673>] ? sock_destroy_inode+0x33/0x40
[   25.427477]  [<ffffffff8121bfd5>] ? __dentry_kill+0x145/0x1d0
[   25.427478]  [<ffffffff8121c105>] ? dput+0xa5/0x170
[   25.427479]  [<ffffffff81224f74>] ? mntput+0x24/0x40
[   25.427481]  [<ffffffff81206d6a>] ? __fput+0x17a/0x1e0
[   25.427482]  [<ffffffff8160ee21>] __sys_sendmsg+0x51/0x90
[   25.427483]  [<ffffffff8160ee72>] SyS_sendmsg+0x12/0x20
[   25.427493]  [<ffffffff81745129>] system_call_fastpath+0x12/0x17
[   25.427494] ---[ end trace 4cc3153e369484ec ]---

  Marcelo
