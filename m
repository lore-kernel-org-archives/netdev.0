From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vfs: dont chain pipe/anon/socket on superblock
 s_inodes list
Date: Tue, 26 Jul 2011 11:36:34 +0200
Message-ID: <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110718155141.GA11013@ZenIV.linux.org.uk>
	 <1311093158.2707.75.camel@schen9-DESK>
	 <20110721204042.GB31405@ZenIV.linux.org.uk>
	 <1311294452.2576.18.camel@schen9-DESK>
	 <20110723132411.GA22183@infradead.org>
	 <1311633550.2576.33.camel@schen9-DESK>
	 <20110725225154.GD22133@ZenIV.linux.org.uk>
	 <1311636178.2576.34.camel@schen9-DESK>
	 <1311660013.2996.6.camel@edumazet-laptop>
	 <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110726090357.GA13013@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Anton Blanchard <anton@samba.org>, npiggin@kernel.dk,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33467 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760Ab1GZJgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 05:36:41 -0400
In-Reply-To: <20110726090357.GA13013@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 juillet 2011 =C3=A0 05:03 -0400, Christoph Hellwig a =C3=A9=
crit :
> On Tue, Jul 26, 2011 at 10:21:06AM +0200, Eric Dumazet wrote:
> > Well, not 'last' contention point, as we still hit remove_inode_has=
h(),
>=20
> There should be no ned to put pipe or anon inodes on the inode hash.
> Probably sockets don't need it either, but I'd need to look at it in
> detail.
>=20
> > inode_wb_list_del()
>=20
> The should never be on the wb list either, doing an unlocked check fo=
r
> actually beeing on the list before taking the lock should help you.

Yes, it might even help regular inodes ;)

>=20
> > inode_lru_list_del(),
>=20
> No real need to keep inodes in the LRU if we only allocate them using
> new_inode but never look them up either.  You might want to try setti=
ng
> .drop_inode to generic_delete_inode for these.

Yes, I'll take a look, thanks.

>=20
> > +struct inode *__new_inode(struct super_block *sb)
> > +{
> > +	struct inode *inode =3D alloc_inode(sb);
> > +
> > +	if (inode) {
> > +		spin_lock(&inode->i_lock);
> > +		inode->i_state =3D 0;
> > +		spin_unlock(&inode->i_lock);
> > +		INIT_LIST_HEAD(&inode->i_sb_list);
> > +	}
> > +	return inode;
> > +}
>=20
> This needs a much better name like new_inode_pseudo, and a kerneldoc=20
> comment explaining when it is safe to use, and the consequences, whic=
h
> appear to me:
>=20
>  - fs may never be unmount
>  - quotas can't work on the filesystem
>  - writeback can't work on the filesystem

Thanks for reviewing, here is v2 of the patch, addressing your comments=
=2E


[PATCH v2] vfs: dont chain pipe/anon/socket on superblock s_inodes list

Workloads using pipes and sockets hit inode_sb_list_lock contention.

superblock s_inodes list is needed for quota, dirty, pagecache and
fsnotify management. pipe/anon/socket fs are clearly not candidates for
these.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
v2: address Christoph comments

 fs/anon_inodes.c   |    2 +-
 fs/inode.c         |   39 ++++++++++++++++++++++++++++++---------
 fs/pipe.c          |    2 +-
 include/linux/fs.h |    3 ++-
 net/socket.c       |    2 +-
 5 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 4d433d3..f11e43e 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -187,7 +187,7 @@ EXPORT_SYMBOL_GPL(anon_inode_getfd);
  */
 static struct inode *anon_inode_mkinode(void)
 {
-	struct inode *inode =3D new_inode(anon_inode_mnt->mnt_sb);
+	struct inode *inode =3D new_inode_pseudo(anon_inode_mnt->mnt_sb);
=20
 	if (!inode)
 		return ERR_PTR(-ENOMEM);
diff --git a/fs/inode.c b/fs/inode.c
index 96c77b8..319b93b 100644
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
@@ -797,6 +799,29 @@ unsigned int get_next_ino(void)
 EXPORT_SYMBOL(get_next_ino);
=20
 /**
+ *	new_inode_pseudo 	- obtain an inode
+ *	@sb: superblock
+ *
+ *	Allocates a new inode for given superblock.
+ *	Inode wont be chained in superblock s_inodes list
+ *	This means :
+ *	- fs can't be unmount
+ *	- quotas, fsnotify, writeback can't work
+ */
+struct inode *new_inode_pseudo(struct super_block *sb)
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
+/**
  *	new_inode 	- obtain an inode
  *	@sb: superblock
  *
@@ -814,13 +839,9 @@ struct inode *new_inode(struct super_block *sb)
=20
 	spin_lock_prefetch(&inode_sb_list_lock);
=20
-	inode =3D alloc_inode(sb);
-	if (inode) {
-		spin_lock(&inode->i_lock);
-		inode->i_state =3D 0;
-		spin_unlock(&inode->i_lock);
+	inode =3D new_inode_pseudo(sb);
+	if (inode)
 		inode_sb_list_add(inode);
-	}
 	return inode;
 }
 EXPORT_SYMBOL(new_inode);
diff --git a/fs/pipe.c b/fs/pipe.c
index 1b7f9af..0e0be1d 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -948,7 +948,7 @@ static const struct dentry_operations pipefs_dentry=
_operations =3D {
=20
 static struct inode * get_pipe_inode(void)
 {
-	struct inode *inode =3D new_inode(pipe_mnt->mnt_sb);
+	struct inode *inode =3D new_inode_pseudo(pipe_mnt->mnt_sb);
 	struct pipe_inode_info *pipe;
=20
 	if (!inode)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a665804..cc363fa 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2310,7 +2310,8 @@ extern void __iget(struct inode * inode);
 extern void iget_failed(struct inode *);
 extern void end_writeback(struct inode *);
 extern void __destroy_inode(struct inode *);
-extern struct inode *new_inode(struct super_block *);
+extern struct inode *new_inode_pseudo(struct super_block *sb);
+extern struct inode *new_inode(struct super_block *sb);
 extern void free_inode_nonrcu(struct inode *inode);
 extern int should_remove_suid(struct dentry *);
 extern int file_remove_suid(struct file *);
diff --git a/net/socket.c b/net/socket.c
index 02dc82d..26ed35c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -467,7 +467,7 @@ static struct socket *sock_alloc(void)
 	struct inode *inode;
 	struct socket *sock;
=20
-	inode =3D new_inode(sock_mnt->mnt_sb);
+	inode =3D new_inode_pseudo(sock_mnt->mnt_sb);
 	if (!inode)
 		return NULL;
=20


