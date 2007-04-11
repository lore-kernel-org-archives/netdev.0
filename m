From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/8] AFS: Correctly alter relocation state after update and
	show state in /proc
Date: Wed, 11 Apr 2007 20:10:17 +0100
Message-ID: <20070411191017.15499.61585.stgit@warthog.cambridge.redhat.com>
References: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753666AbXDKTKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 15:10:34 -0400
In-Reply-To: <20070411190956.15499.55352.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correctly alter the relocation state after update is complete by switching it
from "Updating" to "Valid".

Also display the record state in the vlocation database proc file.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/afs/proc.c      |   15 +++++++++++++--
 fs/afs/vlocation.c |    4 +++-
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/afs/proc.c b/fs/afs/proc.c
index 9e6af40..d5601f6 100644
--- a/fs/afs/proc.c
+++ b/fs/afs/proc.c
@@ -553,6 +553,16 @@ static void afs_proc_cell_volumes_stop(struct seq_file *p, void *v)
 	up_read(&cell->vl_sem);
 }
 
+const char afs_vlocation_states[][4] = {
+	[AFS_VL_NEW]			= "New",
+	[AFS_VL_CREATING]		= "Crt",
+	[AFS_VL_VALID]			= "Val",
+	[AFS_VL_NO_VOLUME]		= "NoV",
+	[AFS_VL_UPDATING]		= "Upd",
+	[AFS_VL_VOLUME_DELETED]		= "Del",
+	[AFS_VL_UNCERTAIN]		= "Unc",
+};
+
 /*
  * display a header line followed by a load of volume lines
  */
@@ -563,13 +573,14 @@ static int afs_proc_cell_volumes_show(struct seq_file *m, void *v)
 
 	/* display header on line 1 */
 	if (v == (void *) 1) {
-		seq_puts(m, "USE VLID[0]  VLID[1]  VLID[2]  NAME\n");
+		seq_puts(m, "USE STT VLID[0]  VLID[1]  VLID[2]  NAME\n");
 		return 0;
 	}
 
 	/* display one cell per line on subsequent lines */
-	seq_printf(m, "%3d %08x %08x %08x %s\n",
+	seq_printf(m, "%3d %s %08x %08x %08x %s\n",
 		   atomic_read(&vlocation->usage),
+		   afs_vlocation_states[vlocation->state],
 		   vlocation->vldb.vid[0],
 		   vlocation->vldb.vid[1],
 		   vlocation->vldb.vid[2],
diff --git a/fs/afs/vlocation.c b/fs/afs/vlocation.c
index f0f4419..9af1fe8 100644
--- a/fs/afs/vlocation.c
+++ b/fs/afs/vlocation.c
@@ -657,7 +657,7 @@ static void afs_vlocation_updater(struct work_struct *work)
 	switch (ret) {
 	case 0:
 		afs_vlocation_apply_update(vl, &vldb);
-		vl->state = AFS_VL_UPDATING;
+		vl->state = AFS_VL_VALID;
 		break;
 	case -ENOMEDIUM:
 		vl->state = AFS_VL_VOLUME_DELETED;
@@ -691,6 +691,8 @@ static void afs_vlocation_updater(struct work_struct *work)
 		timeout = afs_vlocation_update_timeout;
 	}
 
+	ASSERT(list_empty(&vl->update));
+
 	list_add_tail(&vl->update, &afs_vlocation_updates);
 
 	_debug("timeout %ld", timeout);

