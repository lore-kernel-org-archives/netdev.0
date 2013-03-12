From: Alex Williamson <alex.williamson@redhat.com>
Subject: [PATCH] igb: Fix null pointer dereference
Date: Tue, 12 Mar 2013 14:09:16 -0600
Message-ID: <20130312200833.17121.47670.stgit@bling.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutile@redhat.com,
	linux-kernel@vger.kernel.org, sassmann@redhat.com
To: gregory.v.rose@intel.com, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The max_vfs= option has always been self limiting to the number of VFs
supported by the device.  fa44f2f1 added SR-IOV configuration via
sysfs, but in the process broke this self correction factor.  The
failing path is:

igb_probe
  igb_sw_init
    if (max_vfs > 7) {
        adapter->vfs_allocated_count = 7;
    ...
    igb_probe_vfs
    igb_enable_sriov(, max_vfs)
      if (num_vfs > 7) {
        err = -EPERM;
        ...

This leaves vfs_allocated_count = 7 and vf_data = NULL, so we bomb out
when igb_probe finally calls igb_reset.  It seems like a really bad
idea, and somewhat pointless, to set vfs_allocated_count separate from
vf_data, but limiting max_vfs is enough to avoid the null pointer.

Signed-off-by: Alex Williamson <alex.williamson@redhat.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ed79a1c..d5b8289 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2656,7 +2656,7 @@ static int igb_sw_init(struct igb_adapter *adapter)
 		if (max_vfs > 7) {
 			dev_warn(&pdev->dev,
 				 "Maximum of 7 VFs per PF, using max\n");
-			adapter->vfs_allocated_count = 7;
+			max_vfs = adapter->vfs_allocated_count = 7;
 		} else
 			adapter->vfs_allocated_count = max_vfs;
 		if (adapter->vfs_allocated_count)
