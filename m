From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vfs: avoid taking locks if inode not in lists
Date: Wed, 27 Jul 2011 17:21:05 +0200
Message-ID: <1311780065.2356.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
	 <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 26 juillet 2011 =C3=A0 11:36 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 26 juillet 2011 =C3=A0 05:03 -0400, Christoph Hellwig a =C3=A9=
crit :
> > On Tue, Jul 26, 2011 at 10:21:06AM +0200, Eric Dumazet wrote:
> > > Well, not 'last' contention point, as we still hit remove_inode_h=
ash(),
> >=20
> > There should be no ned to put pipe or anon inodes on the inode hash=
=2E
> > Probably sockets don't need it either, but I'd need to look at it i=
n
> > detail.
> >=20
> > > inode_wb_list_del()
> >=20
> > The should never be on the wb list either, doing an unlocked check =
for
> > actually beeing on the list before taking the lock should help you.
>=20
> Yes, it might even help regular inodes ;)
>=20
> >=20
> > > inode_lru_list_del(),
> >=20
> > No real need to keep inodes in the LRU if we only allocate them usi=
ng
> > new_inode but never look them up either.  You might want to try set=
ting
> > .drop_inode to generic_delete_inode for these.
>=20
> Yes, I'll take a look, thanks.

If I am not mistaken, we can add unlocked checks on the three hot spots=
=2E

After following patch, a close(socket(PF_INET, SOCK_DGRAM, 0)) pair on
my dev machine takes ~3us instead of ~9us.

Maybe its better to split it in three patches, just let me know.

22us -> 3us, thats a nice patch series ;)

Thanks

[PATCH] vfs: avoid taking locks if inode not in lists

sockets and pipes inodes destruction hits three possibly contended
locks :

system-wide inode_hash_lock in remove_inode_hash()
superblock s_inode_lru_lock in inode_lru_list_del()
bdi wb.list_lock in inode_wb_list_del()

Before even taking locks, we can perform an unlocked test to check if
inode can possibly be in the lists.

On a 2x4x2 machine, a close(socket()) pair can be 200% faster with thes=
e
changes.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 fs/fs-writeback.c |   10 ++++++----
 fs/inode.c        |    6 ++++++
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 1599aa9..8b90bdb 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -182,11 +182,13 @@ void bdi_start_background_writeback(struct backin=
g_dev_info *bdi)
  */
 void inode_wb_list_del(struct inode *inode)
 {
-	struct backing_dev_info *bdi =3D inode_to_bdi(inode);
+	if (!list_empty(&inode->i_wb_list)) {
+		struct backing_dev_info *bdi =3D inode_to_bdi(inode);
=20
-	spin_lock(&bdi->wb.list_lock);
-	list_del_init(&inode->i_wb_list);
-	spin_unlock(&bdi->wb.list_lock);
+		spin_lock(&bdi->wb.list_lock);
+		list_del_init(&inode->i_wb_list);
+		spin_unlock(&bdi->wb.list_lock);
+	}
 }
=20
 /*
diff --git a/fs/inode.c b/fs/inode.c
index d0c72ff..796a420 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -338,6 +338,9 @@ static void inode_lru_list_add(struct inode *inode)
=20
 static void inode_lru_list_del(struct inode *inode)
 {
+	if (list_empty(&inode->i_lru))
+		return;
+
 	spin_lock(&inode->i_sb->s_inode_lru_lock);
 	if (!list_empty(&inode->i_lru)) {
 		list_del_init(&inode->i_lru);
@@ -406,6 +409,9 @@ EXPORT_SYMBOL(__insert_inode_hash);
  */
 void remove_inode_hash(struct inode *inode)
 {
+	if (inode_unhashed(inode))
+		return;
+
 	spin_lock(&inode_hash_lock);
 	spin_lock(&inode->i_lock);
 	hlist_del_init(&inode->i_hash);


--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
