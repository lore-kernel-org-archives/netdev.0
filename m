From: Ben Hutchings <bhutchings@solarflare.com>
Subject: SR-IOV setup race between PCI and rtnetlink
Date: Thu, 16 Feb 2012 18:22:32 +0000
Message-ID: <1329416552.2601.37.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shradha Shah <sshah@solarflare.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34956 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753312Ab2BPSWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 13:22:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A customer hit this WARNING from rtnetlink:

------------[ cut here ]------------
WARNING: at net/core/rtnetlink.c:1568 rtmsg_ifinfo+0x25a/0x260() (Not tainted)
Hardware name: ProLiant DL380 G7
Modules linked in: bonding ipv6 dm_mirror dm_region_hash dm_log power_meter
hpilo hpwdt bnx2 onload(U) sfc_char(U) sfc_resource(U) sfc_affinity(U)
sfc_tune(U) sfc(U) mdio sg microcode serio_raw iTCO_wdt iTCO_vendor_support
i7core_edac edac_core shpchp ext4 mbcache jbd2 sd_mod crc_t10dif hpsa radeon
ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core dm_multipath dm_mod [last
unloaded: scsi_wait_scan]
Pid: 1927, comm: ifup-eth Not tainted 2.6.32-131.6.1.el6.x86_64 #1
Call Trace:
[<ffffffff810670f7>] ? warn_slowpath_common+0x87/0xc0
[<ffffffff8106714a>] ? warn_slowpath_null+0x1a/0x20
[<ffffffff8142da9a>] ? rtmsg_ifinfo+0x25a/0x260
[<ffffffff8108a928>] ? synchronize_sched+0x58/0x60
[<ffffffff8108a8b0>] ? wakeme_after_rcu+0x0/0x20
[<ffffffff8141c42e>] ? netdev_set_master+0x6e/0xd0
[<ffffffffa041191f>] ? bond_enslave+0x22f/0xd00 [bonding]
[<ffffffff814da624>] ? printk+0x41/0x45
[<ffffffffa041afd7>] ? bonding_store_slaves+0x2a7/0x420 [bonding]
[<ffffffff81336900>] ? dev_attr_store+0x20/0x30
[<ffffffff811e4d95>] ? sysfs_write_file+0xe5/0x170
[<ffffffff81172748>] ? vfs_write+0xb8/0x1a0
[<ffffffff810d1ad2>] ? audit_syscall_entry+0x272/0x2a0
[<ffffffff81173181>] ? sys_write+0x51/0x90
[<ffffffff8100b172>] ? system_call_fastpath+0x16/0x1b
---[ end trace 7676a5a34ad7b8ee ]---
------------[ cut here ]------------

This was seen with OpenOnload on RHEL 6.1, but I believe the same issue
exists with the changes I just submitted against net-next.

The WARNING is produced by:
		/* -EMSGSIZE implies BUG in if_nlmsg_size() */
		WARN_ON(err == -EMSGSIZE);

rtnl_vfinfo_size(), rtnl_fill_ifinfo(), etc. use dev_num_vf() to get the
number of VFs that will be included in the message, i.e. they ask the
PCI device and not the net device.

The number of VFs is changed by pci_enable_sriov(), which obviously does
not acquire the RTNL lock.  Further, it is unsafe for its callers to
hold the RTNL lock, because it may synchronously bind the new VFs to
drivers that themselves acquire the RTNL in their probe functions.  So
the number of VFs may change between the time at which the message size
is calculated and the time at which it is built.

Now rtnl_fill_ifinfo() will stop trying to add VF information as soon as
ndo_get_vf_config() returns an error.  If the driver implementation
ensures that it returns errors until after pci_enable_sriov() returns
and it has reacquired the RTNL lock, the message doesn't actually get
any bigger and the WARNING won't be hit.

However we really need the VFs to be configurable immediately, so that
the VF driver can communicate with the PF driver (sfc).  I could add an
separate flag to keep the RTNL interface disabled while the inter-driver
interface is enabled, but that doesn't seem like the right thing to do.

Perhaps there should be a net device op to return the number of VFs,
which the net driver must then only change while holding the RTNL lock?
RTNL would then use that instead of dev_num_vf().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
