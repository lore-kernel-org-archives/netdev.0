From: Bjorn Helgaas <helgaas@kernel.org>
Subject: mlx4 BUG_ON in probe path
Date: Wed, 16 Nov 2016 12:25:27 -0600
Message-ID: <20161116182527.GC26600@bhelgaas-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Johannes Thumshirn <jthumshirn@suse.de>,
        linux-kernel@vger.kernel.org
To: Yishai Hadas <yishaih@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50154 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932870AbcKPSZc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 13:25:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yishai,

Johannes has been working on an mlx4 initialization problem on an
IBM x3850 X6.  The underlying problem is a PCI core issue -- we're
setting RCB in the Mellanox device, which means it thinks it can
generate 128-byte Completions, even though the Root Port above it
can't handle them.  That issue is
https://bugzilla.kernel.org/show_bug.cgi?id=187781

The machine crashed when this happened, apparently not because of any
error reported via AER, but because mlx4 contains a BUG_ON, probably
the one in mlx4_enter_error_state().

That one happens if pci_channel_offline() returns false.  Is this
telling us about a problem in PCI error handling, or is it just a case
where mlx4 isn't as smart as it could be?

Ideally, if mlx4 can't initialize the device, it should just return an
error from the probe function instead of crashing the whole machine.

Here's the crash (the entire dmesg log is in the bugzilla above):

  mlx4_core 0000:41:00.0: command 0xfff timed out (go bit not cleared)
  mlx4_core 0000:41:00.0: device is going to be reset
  mlx4_core 0000:41:00.0: Failed to obtain HW semaphore, aborting
  mlx4_core 0000:41:00.0: Fail to reset HCA
  ------------[ cut here ]------------
  kernel BUG at drivers/net/ethernet/mellanox/mlx4/catas.c:193!
  invalid opcode: 0000 [#1] SMP 
  Modules linked in: sr_mod(E) cdrom(E) uas(E) usb_storage(E) mlx4_core(E+) cdc_ether(E) usbnet(E) mii(E) joydev(E) x86_pkg_temp_thermal(E) intel_powerclamp(E) coretemp(E) kvm_intel(E) kvm(E) irqbypass(E) crct10dif_pclmul(E) crc32_pclmul(E) crc32c_intel(E) drbg(E) ansi_cprng(E) aesni_intel(E) iTCO_wdt(E) aes_x86_64(E) igb(E) ipmi_devintf(E) iTCO_vendor_support(E) lrw(E) gf128mul(E) glue_helper(E) ablk_helper(E) ptp(E) cryptd(E) pps_core(E) sb_edac(E) pcspkr(E) lpc_ich(E) ipmi_ssif(E) ioatdma(E) edac_core(E) shpchp(E) mfd_core(E) dca(E) wmi(E) ipmi_si(E) ipmi_msghandler(E) fjes(E) button(E) processor(E) acpi_pad(E) hid_generic(E) usbhid(E) ext4(E) crc16(E) jbd2(E) mbcache(E) sd_mod(E) mgag200(E) i2c_algo_bit(E) drm_kms_helper(E) syscopyarea(E) xhci_pci(E) sysfillrect(E) ehci_pci(E) sysimgbl
 t(E)
   fb_sys_fops(E) xhci_hcd(E) ehci_hcd(E) ttm(E) usbcore(E) drm(E) usb_common(E) megaraid_sas(E) dm_mirror(E) dm_region_hash(E) dm_log(E) sg(E) dm_multipath(E) dm_mod(E) scsi_dh_rdac(E) scsi_dh_emc(E) scsi_dh_alua(E) scsi_mod(E) autofs4(E)
  Supported: Yes
  CPU: 27 PID: 2867 Comm: modprobe Tainted: G            E      4.4.21-default #6
  Hardware name: IBM x3850 X6 -[3837Z7P]-/00FN772, BIOS -[A8E120CUS-1.30]- 08/22/2016
  task: ffff881fb2ff9280 ti: ffff881fbd3c4000 task.ti: ffff881fbd3c4000
  RIP: 0010:[<ffffffffa0446740>]  [<ffffffffa0446740>] mlx4_enter_error_state+0x240/0x320 [mlx4_core]
  RSP: 0018:ffff881fbd3c79a0  EFLAGS: 00010246
  RAX: ffff8820b2486e00 RBX: ffff883fbe240000 RCX: 0000000000000000
  RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffff881fbf63b000
  RBP: ffff8820b2486e60 R08: 0000000000000029 R09: ffff88803feda50f
  R10: 00000000000d1b50 R11: 0000000000000000 R12: 0000000000000000
  R13: 0000000000000000 R14: ffff883fbe240460 R15: 00000000fffffffb
  FS:  00007f7c55203700(0000) GS:ffff883fbf900000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00007f1813c88000 CR3: 0000003fbe637000 CR4: 00000000001406e0
  Stack:
   15b30000c0000100 ffff883fbe240000 0000000000000fff 0000000000000000
   ffffffffa0447d54 000000000000ffff ffffffff00000000 000000000000ea60
   0000000000000000 000000000000ea60 ffffc90031dba680 ffff883fbe240000
  Call Trace:
   [<ffffffffa0447d54>] __mlx4_cmd+0x594/0x8a0 [mlx4_core]
   [<ffffffffa045191b>] mlx4_map_cmd+0x2ab/0x3c0 [mlx4_core]
   [<ffffffffa045a855>] mlx4_load_one+0x515/0x1220 [mlx4_core]
   [<ffffffffa045bb69>] mlx4_init_one+0x4e9/0x6a0 [mlx4_core]
   [<ffffffff8135626f>] local_pci_probe+0x3f/0xa0
   [<ffffffff81357694>] pci_device_probe+0xd4/0x120
   [<ffffffff8144d0b7>] driver_probe_device+0x1f7/0x420
   [<ffffffff8144d35b>] __driver_attach+0x7b/0x80
   [<ffffffff8144afc8>] bus_for_each_dev+0x58/0x90
   [<ffffffff8144c519>] bus_add_driver+0x1c9/0x280
   [<ffffffff8144dccb>] driver_register+0x5b/0xd0
   [<ffffffffa03f911a>] mlx4_init+0x11a/0x1000 [mlx4_core]
   [<ffffffff81002138>] do_one_initcall+0xc8/0x1f0
   [<ffffffff81182a08>] do_init_module+0x5a/0x1d7
   [<ffffffff81103726>] load_module+0x1366/0x1c50
   [<ffffffff811041c0>] SYSC_finit_module+0x70/0xa0
   [<ffffffff815e14ae>] entry_SYSCALL_64_fastpath+0x12/0x71
