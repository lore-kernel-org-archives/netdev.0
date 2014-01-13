From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 0/2] bonding: fix the sysfs warning when change the master's
 name
Date: Mon, 13 Jan 2014 21:08:06 +0800
Message-ID: <52D3E536.8080404@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:30192 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaAMNJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 08:09:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I change the master's name, and then rebuild the master and ensalve a nic again,
than I got the calltrace:

[329215.749344] WARNING: CPU: 0 PID: 4778 at fs/sysfs/dir.c:486 sysfs_warn_dup+0x87/0xa0()
[329215.749347] sysfs: cannot create duplicate filename '/devices/pci0000:00/0000:00:03.0/0000:02:00.0/net/eth100/upper_bond0'
[329215.749350] Modules linked in: bonding(O) igb af_packet edd bridge stp llc cpufreq_conservative cpufreq_userspace cpufreq_powersave microcode fuse loop dm_mod iTCO_wdt iTCO_vendor_support ipv6 dca i2c_algo_bit ptp i2c_i801 pps_core hid_generic bnx2 lpc_ich i2c_core button acpi_cpufreq serio_raw sg ehci_pci mfd_core pcspkr ext3 jbd mbcache usbhid hid uhci_hcd ehci_hcd sd_mod usbcore usb_common crc_t10dif crct10dif_common processor thermal_sys hwmon scsi_dh_emc scsi_dh_alua scsi_dh_hp_sw scsi_dh_rdac scsi_dh ata_generic ata_piix libata megaraid_sas scsi_mod [last unloaded: bonding]
[329215.749437] CPU: 0 PID: 4778 Comm: bash Tainted: G           O 3.13.0-rc6-0.7-default+ #32
[329215.749440] Hardware name: Huawei Technologies Co., Ltd. Tecal RH2285          /BC11BTSA              , BIOS CTSAV036 04/27/2011
[329215.749443]  00000000000001e6 ffff88032d4dbaf8 ffffffff814e27b8 ffff88032d4dbb38
[329215.749449]  ffffffff81048d07 ffff880330f7ae80 ffff88032cc24000 ffff88032cc24000
[329215.749455]  ffff880330f7ae80 ffff880330f7ae80 0000000000000001 ffff88032d4dbb98
[329215.749461] Call Trace:
[329215.749470]  [<ffffffff814e27b8>] dump_stack+0x6a/0x7a
[329215.749477]  [<ffffffff81048d07>] warn_slowpath_common+0x87/0xb0
[329215.749482]  [<ffffffff81048dd1>] warn_slowpath_fmt+0x41/0x50
[329215.749489]  [<ffffffff81292194>] ? strlcat+0x74/0x90
[329215.749494]  [<ffffffff81205b27>] sysfs_warn_dup+0x87/0xa0
[329215.749500]  [<ffffffff81205eed>] sysfs_add_one+0x4d/0x50
[329215.749505]  [<ffffffff81206f9e>] sysfs_do_create_link_sd+0xbe/0x210
[329215.749511]  [<ffffffff812951a0>] ? sprintf+0x40/0x50
[329215.749516]  [<ffffffff8120714b>] sysfs_create_link+0x2b/0x30
[329215.749523]  [<ffffffff8140a708>] __netdev_adjacent_dev_insert+0x1b8/0x270
[329215.749528]  [<ffffffff8140a7f8>] __netdev_adjacent_dev_link_lists+0x38/0x90
[329215.749533]  [<ffffffff8140a98b>] __netdev_upper_dev_link+0x13b/0x470
[329215.749538]  [<ffffffff8141319c>] ? __ethtool_get_settings+0x5c/0x90
[329215.749547]  [<ffffffffa0722179>] ? bond_update_speed_duplex+0x29/0x70 [bonding]
[329215.749552]  [<ffffffff8140acd1>] netdev_master_upper_dev_link_private+0x11/0x20
[329215.749561]  [<ffffffffa0729246>] bond_enslave+0x806/0xe40 [bonding]
[329215.749570]  [<ffffffffa073241f>] bonding_store_slaves+0x18f/0x1c0 [bonding]
[329215.749576]  [<ffffffff813757ab>] dev_attr_store+0x1b/0x20
[329215.749581]  [<ffffffff812049cc>] sysfs_write_file+0x15c/0x1f0
[329215.749587]  [<ffffffff81188897>] vfs_write+0xc7/0x1e0
[329215.749593]  [<ffffffff814e8d49>] ? retint_swapgs+0xe/0x13
[329215.749598]  [<ffffffff81188acd>] SyS_write+0x5d/0xa0
[329215.749604]  [<ffffffff814f11a2>] system_call_fastpath+0x16/0x1b

-----------------------[ cut here ]-----------------------------------

The reason is that when I change the master's name, there is no way to change
it for slave's upper_xxxx link, it is still the original name, when I release
the master, the link is still there, so if I rebuild a master and the slave
dev to this master again, the warning will occurs.

I fix the problem by export and use a new function netdev_upper_dev_rename(),
it will clean the old link and rebuild a new link for slave when the master's
name changed every time.

I beleave if the slave's name changed, the master still has the old dev link for
this slave, so I will test and fix it in next patchset.

Ding Tianhong (2):
  net: dev: add netdev_upper_dev_rename()
  bonding: rename the dev upper link if the master's name changed

 drivers/net/bonding/bond_main.c | 35 +++++++++++++++++++++++++
 include/linux/netdevice.h       |  3 +++
 net/core/dev.c                  | 57 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 95 insertions(+)

-- 
1.8.0
