From: David Howells <dhowells@redhat.com>
Subject: [PATCH 10/16] AFS: Handle multiple mounts of an AFS superblock
	correctly [try #4]
Date: Wed, 25 Apr 2007 16:49:48 +0100
Message-ID: <20070425154948.26581.96033.stgit@warthog.cambridge.redhat.com>
References: <20070425154854.26581.97692.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070425154854.26581.97692.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handle multiple mounts of an AFS superblock correctly, checking to see whether
the superblock is already initialised after calling sget() rather than just
unconditionally stamping all over it.

Also delete the "silent" parameter to afs_fill_super() as it's not used and
can, in any case, be obtained from sb->s_flags.

Signed-Off-By: David Howells <dhowells@redhat.com>
---

 fs/afs/super.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/afs/super.c b/fs/afs/super.c
index efc4fe6..77e6875 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -212,7 +212,7 @@ static int afs_test_super(struct super_block *sb, void *data)
 /*
  * fill in the superblock
  */
-static int afs_fill_super(struct super_block *sb, void *data, int silent)
+static int afs_fill_super(struct super_block *sb, void *data)
 {
 	struct afs_mount_params *params = data;
 	struct afs_super_info *as = NULL;
@@ -319,17 +319,23 @@ static int afs_get_sb(struct file_system_type *fs_type,
 		goto error;
 	}
 
-	sb->s_flags = flags;
-
-	ret = afs_fill_super(sb, &params, flags & MS_SILENT ? 1 : 0);
-	if (ret < 0) {
-		up_write(&sb->s_umount);
-		deactivate_super(sb);
-		goto error;
+	if (!sb->s_root) {
+		/* initial superblock/root creation */
+		_debug("create");
+		sb->s_flags = flags;
+		ret = afs_fill_super(sb, &params);
+		if (ret < 0) {
+			up_write(&sb->s_umount);
+			deactivate_super(sb);
+			goto error;
+		}
+		sb->s_flags |= MS_ACTIVE;
+	} else {
+		_debug("reuse");
+		ASSERTCMP(sb->s_flags, &, MS_ACTIVE);
 	}
-	sb->s_flags |= MS_ACTIVE;
-	simple_set_mnt(mnt, sb);
 
+	simple_set_mnt(mnt, sb);
 	afs_put_volume(params.volume);
 	afs_put_cell(params.default_cell);
 	_leave(" = 0 [%p]", sb);

