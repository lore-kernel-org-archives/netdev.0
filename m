From: syrine tlili <syrine.tl@gmail.com>
Subject: [PATCH] linux-3.8-rc6 Fix Missing Allocation Failure Checks
Date: Fri, 8 Feb 2013 15:35:52 +0100
Message-ID: <CAETb2JMQ05RGuBuaoD39Db1j9--sth-3u+JXG6jaZkTvQyVkPw@mail.gmail.com>
Reply-To: syrine.tl@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: matt.fleming@intel.com, sage@inktank.com, isdn@linux-pingi.de,
	megaraidlinux@lsi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Syrine Tlili <syrine.tl@gmail.com>

Check for memory allocation failures to avoid
NULL pointer dereferencing.

Signed-off-by: Syrine Tlili <syrine.tl@gmail.com>
---


diff -uprN -X linux-3.8-rc6-vanilla/Documentation/dontdiff
linux-3.8-rc6-vanilla/arch/x86/platform/efi/efi.c
b/arch/x86/platform/efi/efi.c
--- linux-3.8-rc6-vanilla/arch/x86/platform/efi/efi.c	2013-02-01
02:08:14.000000000 +0100
+++ b/arch/x86/platform/efi/efi.c	2013-02-06 20:33:36.390643500 +0100
@@ -924,6 +924,8 @@ void __init efi_enter_virtual_mode(void)
 		new_memmap = krealloc(new_memmap,
 				      (count + 1) * memmap.desc_size,
 				      GFP_KERNEL);
+		if (!new_memmap)
+			return -ENOMEM;
 		memcpy(new_memmap + (count * memmap.desc_size), md,
 		       memmap.desc_size);
 		count++;
diff -uprN -X linux-3.8-rc6-vanilla/Documentation/dontdiff
linux-3.8-rc6-vanilla/drivers/isdn/mISDN/fsm.c
b/drivers/isdn/mISDN/fsm.c
--- linux-3.8-rc6-vanilla/drivers/isdn/mISDN/fsm.c	2013-02-01
02:08:14.000000000 +0100
+++ b/drivers/isdn/mISDN/fsm.c	2013-02-06 20:33:01.772644948 +0100
@@ -34,6 +34,8 @@ mISDN_FsmNew(struct Fsm *fsm,

 	fsm->jumpmatrix = kzalloc(sizeof(FSMFNPTR) * fsm->state_count *
 				  fsm->event_count, GFP_KERNEL);
+	if (!fsm->jumpmatrix)
+		return -ENOMEM;

 	for (i = 0; i < fncount; i++)
 		if ((fnlist[i].state >= fsm->state_count) ||
diff -uprN -X linux-3.8-rc6-vanilla/Documentation/dontdiff
linux-3.8-rc6-vanilla/drivers/scsi/megaraid.c
b/drivers/scsi/megaraid.c
--- linux-3.8-rc6-vanilla/drivers/scsi/megaraid.c	2013-02-01
02:08:14.000000000 +0100
+++ b/drivers/scsi/megaraid.c	2013-02-06 21:22:23.051521099 +0100
@@ -4437,6 +4437,8 @@ mega_internal_command(adapter_t *adapter
 	memset(scb, 0, sizeof(scb_t));

 	sdev = kzalloc(sizeof(struct scsi_device), GFP_KERNEL);
+	if (!sdev)
+		goto err_out;
 	scmd->device = sdev;

 	memset(adapter->int_cdb, 0, sizeof(adapter->int_cdb));
@@ -4482,6 +4484,11 @@ mega_internal_command(adapter_t *adapter
 	scsi_free_command(GFP_KERNEL, scmd);

 	return rval;
+
+err_out:
+	mutex_unlock(&adapter->int_mtx);
+	scsi_free_command(GFP_KERNEL, scmd);
+	return -ENOMEM;
 }


diff -uprN -X linux-3.8-rc6-vanilla/Documentation/dontdiff
linux-3.8-rc6-vanilla/fs/ceph/mdsmap.c b/fs/ceph/mdsmap.c
--- linux-3.8-rc6-vanilla/fs/ceph/mdsmap.c	2013-02-01 02:08:14.000000000 +0100
+++ b/fs/ceph/mdsmap.c	2013-02-06 20:34:02.934642390 +0100
@@ -132,6 +132,8 @@ struct ceph_mdsmap *ceph_mdsmap_decode(v
 				m->m_info[mds].export_targets =
 					kcalloc(num_export_targets, sizeof(u32),
 						GFP_NOFS);
+				if (m->m_info[mds].export_targets == NULL)
+					goto badmem;
 				for (j = 0; j < num_export_targets; j++)
 					m->m_info[mds].export_targets[j] =
 					       ceph_decode_32(&pexport_targets);
