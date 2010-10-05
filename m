From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: fix WARN_ON when writing to bond_master sysfs
 file (v2)
Date: Tue, 5 Oct 2010 09:39:21 -0400
Message-ID: <20101005133921.GA18071@hmsreliant.think-freely.org>
References: <20101004202112.GA27897@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40311 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937Ab0JENj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 09:39:29 -0400
Content-Disposition: inline
In-Reply-To: <20101004202112.GA27897@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, V2 of this patch, taking Stephens notes into account.  Switched to using
__dev_get_by_name to avoid reference count inc/dec.


Fix a WARN_ON failure in bond_masters sysfs file

Got a report of this warning recently

bonding: bond0 is being created...
------------[ cut here ]------------
WARNING: at fs/proc/generic.c:590 proc_register+0x14d/0x185()
Hardware name: ProLiant BL465c G1
proc_dir_entry 'bonding/bond0' already registered
Modules linked in: bonding ipv6 tg3 bnx2 shpchp amd64_edac_mod edac_core
ipmi_si
ipmi_msghandler serio_raw i2c_piix4 k8temp edac_mce_amd hpwdt microcode hpsa
cc
iss radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core [last unloaded:
scsi_wai
t_scan]
Pid: 935, comm: ifup-eth Not tainted 2.6.33.5-124.fc13.x86_64 #1
Call Trace:
[<ffffffff8104b54c>] warn_slowpath_common+0x77/0x8f
[<ffffffff8104b5b1>] warn_slowpath_fmt+0x3c/0x3e
[<ffffffff8114bf0b>] proc_register+0x14d/0x185
[<ffffffff8114c20c>] proc_create_data+0x87/0xa1
[<ffffffffa0211e9b>] bond_create_proc_entry+0x55/0x95 [bonding]
[<ffffffffa0215e5d>] bond_init+0x95/0xd0 [bonding]
[<ffffffff8138cd97>] register_netdevice+0xdd/0x29e
[<ffffffffa021240b>] bond_create+0x8e/0xb8 [bonding]
[<ffffffffa021c4be>] bonding_store_bonds+0xb3/0x1c1 [bonding]
[<ffffffff812aec85>] class_attr_store+0x27/0x29
[<ffffffff8115423d>] sysfs_write_file+0x10f/0x14b
[<ffffffff81101acf>] vfs_write+0xa9/0x106
[<ffffffff81101be2>] sys_write+0x45/0x69
[<ffffffff81009b02>] system_call_fastpath+0x16/0x1b
---[ end trace a677c3f7f8b16b1e ]---
bonding: Bond creation failed.

It happens because a user space writer to bond_master can try to register and
already existing bond interface name.  Fix it by teaching bond_create to check
for the existance of devices with that name first in cases where a non-NULL name
parameter has been passed in

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 bond_main.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fb70c3e..985cbc1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -5168,6 +5168,15 @@ int bond_create(struct net *net, const char *name)
 		res = dev_alloc_name(bond_dev, "bond%d");
 		if (res < 0)
 			goto out;
+	} else {
+		/*
+		 * If we're given a name to register
+		 * we need to ensure that its not already
+		 * registered
+		 */
+		res = -EEXIST;
+		if (__dev_get_by_name(net, name) != NULL)
+			goto out;
 	}
 
 	res = register_netdevice(bond_dev);
