From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vfs: dont chain pipe/anon/socket on superblock s_inodes
 list
Date: Tue, 26 Jul 2011 10:21:06 +0200
Message-ID: <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110717010427.GC5359@parisc-linux.org>
	 <20110717084630.GC8006@one.firstfloor.org>
	 <1310977028.5756.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110718154008.GA29593@infradead.org>
	 <20110718155141.GA11013@ZenIV.linux.org.uk>
	 <1311093158.2707.75.camel@schen9-DESK>
	 <20110721204042.GB31405@ZenIV.linux.org.uk>
	 <1311294452.2576.18.camel@schen9-DESK>
	 <20110723132411.GA22183@infradead.org>
	 <1311633550.2576.33.camel@schen9-DESK>
	 <20110725225154.GD22133@ZenIV.linux.org.uk>
	 <1311636178.2576.34.camel@schen9-DESK>
	 <1311660013.2996.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Hellwig <hch@infradead.org>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Anton Blanchard <anton@samba.org>, npiggin@kernel.dk,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Tim Chen <tim.c.chen@linux.intel.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1311660013.2996.6.camel@edumazet-laptop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 26 juillet 2011 =C3=A0 08:00 +0200, Eric Dumazet a =C3=A9crit =
:

> Next step is to not chain pipes/sockets into superblock s_inodes list
>=20
> inode_sb_list_add()/inode_sb_list_del() is the very last contention
> point because of spin_lock(&inode_sb_list_lock);

Well, not 'last' contention point, as we still hit remove_inode_hash(),
inode_wb_list_del(), inode_lru_list_del(), but thats a clear win on my
2x4x2 machine : 9 seconds instead of 22 on a close(socket()) benchmark.


[PATCH] vfs: dont chain pipe/anon/socket on superblock s_inodes list

Workloads using pipes and sockets hit inode_sb_list_lock contention.

superblock s_inodes list is needed for quota, dirty, pagecache and
fsnotify management. pipe/anon/socket fs are clearly not candidates for
these.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 fs/anon_inodes.c   |    2 +-
 fs/inode.c         |   31 +++++++++++++++++++++----------
 fs/pipe.c          |    2 +-
 include/linux/fs.h |    3 ++-
 net/socket.c       |    2 +-
 5 files changed, 26 insertions(+), 14 deletions(-)

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 4d433d3..269499e 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -187,7 +187,7 @@ EXPORT_SYMBOL_GPL(anon_inode_getfd);
  */
 static struct inode *anon_inode_mkinode(void)
 {
-	struct inode *inode =3D new_inode(anon_inode_mnt->mnt_sb);
+	struct inode *inode =3D __new_inode(anon_inode_mnt->mnt_sb);
=20
 	if (!inode)
 		return ERR_PTR(-ENOMEM);
diff --git a/fs/inode.c b/fs/inode.c
index 96c77b8..8a6d62b 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -362,9 +362,11 @@ EXPORT_SYMBOL_GPL(inode_sb_list_add);
=20
 static inline void inode_sb_list_del(struct inode *inode)
 {
-	spin_lock(&inode_sb_list_lock);
-	list_del_init(&inode->i_sb_list);
-	spin_unlock(&inode_sb_list_lock);
+	if (!list_empty(&inode->i_sb_list)) {
+		spin_lock(&inode_sb_list_lock);
+		list_del_init(&inode->i_sb_list);
+		spin_unlock(&inode_sb_list_lock);
+	}
 }
=20
 static unsigned long hash(struct super_block *sb, unsigned long hashva=
l)
@@ -796,6 +798,19 @@ unsigned int get_next_ino(void)
 }
 EXPORT_SYMBOL(get_next_ino);
=20
+struct inode *__new_inode(struct super_block *sb)
+{
+	struct inode *inode =3D alloc_inode(sb);
+
+	if (inode) {
+		spin_lock(&inode->i_lock);
+		inode->i_state =3D 0;
+		spin_unlock(&inode->i_lock);
+		INIT_LIST_HEAD(&inode->i_sb_list);
+	}
+	return inode;
+}
+
 /**
  *	new_inode 	- obtain an inode
  *	@sb: superblock
@@ -814,13 +829,9 @@ struct inode *new_inode(struct super_block *sb)
=20
 	spin_lock_prefetch(&inode_sb_list_lock);
=20
-	inode =3D alloc_inode(sb);
-	if (inode) {
-		spin_lock(&inode->i_lock);
-		inode->i_state =3D 0;
-		spin_unlock(&inode->i_lock);
-		inode_sb_list_add(inode);
-	}
+	inode =3D __new_inode(sb);
+	if (inode)
+			inode_sb_list_add(inode);
 	return inode;
 }
 EXPORT_SYMBOL(new_inode);
diff --git a/fs/pipe.c b/fs/pipe.c
index 1b7f9af..937b962 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -948,7 +948,7 @@ static const struct dentry_operations pipefs_dentry=
_operations =3D {
=20
 static struct inode * get_pipe_inode(void)
 {
-	struct inode *inode =3D new_inode(pipe_mnt->mnt_sb);
+	struct inode *inode =3D __new_inode(pipe_mnt->mnt_sb);
 	struct pipe_inode_info *pipe;
=20
 	if (!inode)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a665804..60be54f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2310,7 +2310,8 @@ extern void __iget(struct inode * inode);
 extern void iget_failed(struct inode *);
 extern void end_writeback(struct inode *);
 extern void __destroy_inode(struct inode *);
-extern struct inode *new_inode(struct super_block *);
+extern struct inode *__new_inode(struct super_block *sb);
+extern struct inode *new_inode(struct super_block *sb);
 extern void free_inode_nonrcu(struct inode *inode);
 extern int should_remove_suid(struct dentry *);
 extern int file_remove_suid(struct file *);
diff --git a/net/socket.c b/net/socket.c
index 02dc82d..b4b8a08 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -467,7 +467,7 @@ static struct socket *sock_alloc(void)
 	struct inode *inode;
 	struct socket *sock;
=20
-	inode =3D new_inode(sock_mnt->mnt_sb);
+	inode =3D __new_inode(sock_mnt->mnt_sb);
 	if (!inode)
 		return NULL;
=20


--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
