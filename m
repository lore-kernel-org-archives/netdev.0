From: syrine.tl@gmail.com
Subject: [PATCH] Fixes missing Null Check
Date: Mon, 11 Feb 2013 14:02:40 +0100
Message-ID: <1360587760-6211-1-git-send-email-syrine.tlili@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Syrine Tlili <syrine.tl@gmail.com>
To: matt.fleming@intel.com, sage@inktank.com, isdn@linux-pingi.de,
	megaraidlinux@lsi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Syrine Tlili <syrine.tl@gmail.com>

This patch fixes missing null check of memory allocation functions return values.

Signed-off-by: Syrine Tlili <syrine.tl@gmail.com>
---
 arch/x86/platform/efi/efi.c | 2 ++
 drivers/isdn/mISDN/fsm.c    | 2 ++
 drivers/scsi/megaraid.c     | 7 +++++++
 fs/ceph/mdsmap.c            | 2 ++
 4 files changed, 13 insertions(+)

diff --git a/arch/x86/platform/efi/efi.c b/arch/x86/platform/efi/efi.c
index 77cf009..88b60e0 100644
--- a/arch/x86/platform/efi/efi.c
+++ b/arch/x86/platform/efi/efi.c
@@ -924,6 +924,8 @@ void __init efi_enter_virtual_mode(void)
 		new_memmap = krealloc(new_memmap,
 				      (count + 1) * memmap.desc_size,
 				      GFP_KERNEL);
+		if (!new_memmap)
+			return -ENOMEM;
 		memcpy(new_memmap + (count * memmap.desc_size), md,
 		       memmap.desc_size);
 		count++;
diff --git a/drivers/isdn/mISDN/fsm.c b/drivers/isdn/mISDN/fsm.c
index 26477d4..09000dd 100644
--- a/drivers/isdn/mISDN/fsm.c
+++ b/drivers/isdn/mISDN/fsm.c
@@ -34,6 +34,8 @@ mISDN_FsmNew(struct Fsm *fsm,
 
 	fsm->jumpmatrix = kzalloc(sizeof(FSMFNPTR) * fsm->state_count *
 				  fsm->event_count, GFP_KERNEL);
+	if (!fsm->jumpmatrix)
+		return -ENOMEM;
 
 	for (i = 0; i < fncount; i++)
 		if ((fnlist[i].state >= fsm->state_count) ||
diff --git a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
index 9504ec0..e6d1822 100644
--- a/drivers/scsi/megaraid.c
+++ b/drivers/scsi/megaraid.c
@@ -4437,6 +4437,8 @@ mega_internal_command(adapter_t *adapter, megacmd_t *mc, mega_passthru *pthru)
 	memset(scb, 0, sizeof(scb_t));
 
 	sdev = kzalloc(sizeof(struct scsi_device), GFP_KERNEL);
+	if (!sdev)
+		goto err_out;
 	scmd->device = sdev;
 
 	memset(adapter->int_cdb, 0, sizeof(adapter->int_cdb));
@@ -4482,6 +4484,11 @@ mega_internal_command(adapter_t *adapter, megacmd_t *mc, mega_passthru *pthru)
 	scsi_free_command(GFP_KERNEL, scmd);
 
 	return rval;
+
+err_out:
+	mutex_unlock(&adapter->int_mtx);
+	scsi_free_command(GFP_KERNEL, scmd);
+	return -ENOMEM;
 }
 
 
diff --git a/fs/ceph/mdsmap.c b/fs/ceph/mdsmap.c
index 73b7d44..d04ab8b 100644
--- a/fs/ceph/mdsmap.c
+++ b/fs/ceph/mdsmap.c
@@ -132,6 +132,8 @@ struct ceph_mdsmap *ceph_mdsmap_decode(void **p, void *end)
 				m->m_info[mds].export_targets =
 					kcalloc(num_export_targets, sizeof(u32),
 						GFP_NOFS);
+				if (m->m_info[mds].export_targets == NULL)
+					goto badmem;
 				for (j = 0; j < num_export_targets; j++)
 					m->m_info[mds].export_targets[j] =
 					       ceph_decode_32(&pexport_targets);
-- 
1.7.11.7
