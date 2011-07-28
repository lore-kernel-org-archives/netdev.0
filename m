From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vfs: avoid call to inode_lru_list_del() if possible
Date: Thu, 28 Jul 2011 06:55:13 +0200
Message-ID: <1311828913.2697.33.camel@edumazet-laptop>
References: <1311294452.2576.18.camel@schen9-DESK>
	 <20110723132411.GA22183@infradead.org>
	 <1311633550.2576.33.camel@schen9-DESK>
	 <20110725225154.GD22133@ZenIV.linux.org.uk>
	 <1311636178.2576.34.camel@schen9-DESK>
	 <1311660013.2996.6.camel@edumazet-laptop>
	 <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110726090357.GA13013@infradead.org>
	 <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311780065.2356.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110727204415.GA13308@infradead.org>
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
In-Reply-To: <20110727204415.GA13308@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 27 juillet 2011 =C3=A0 16:44 -0400, Christoph Hellwig a =C3=
=A9crit :
> On Wed, Jul 27, 2011 at 05:21:05PM +0200, Eric Dumazet wrote:
> > If I am not mistaken, we can add unlocked checks on the three hot s=
pots.
> >=20
> > After following patch, a close(socket(PF_INET, SOCK_DGRAM, 0)) pair=
 on
> > my dev machine takes ~3us instead of ~9us.
> >=20
> > Maybe its better to split it in three patches, just let me know.
>=20
> I think three patches would be a lot cleaner.
>=20
> As for safety of the unlocked checks:
>=20
>  - inode are either hashed when created or never, so that one looks
>    fine.
>  - same for the sb list.
>  - the writeback list is a bit more dynamic as we move things around
>    quite a bit.  But in additon to the inode_wb_list_del call from
>    evict() it only ever gets remove in writeback_single_inode, which
>    for a freeing inode can only be called from the callers of evict()=
=2E
>=20
> Btw, I wonder if you should micro-optimize things a bit further by
> moving the unhashed checks from the deletion functions into the calle=
rs
> and thus save a function call for each of them.
>=20

Here is the last patch, addressing inode_lru_list_del() call.

Only the call done from iput_final() can obviously benefit from checkin=
g
i_lru being empty or not, so it makes sense to perform the check at
caller site instead of doing it in inode_lru_list_del()

[PATCH] vfs: avoid call to inode_lru_list_del() if possible

inode_lru_list_del() is expensive because of per superblock lru locking=
,
while some inodes are not in lru list.

Adding a check in iput_final() can speedup pipe/sockets workloads on
SMP.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 fs/inode.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/inode.c b/fs/inode.c
index d0c72ff..b8b8939 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1328,7 +1328,8 @@ static void iput_final(struct inode *inode)
 	}
=20
 	inode->i_state |=3D I_FREEING;
-	inode_lru_list_del(inode);
+	if (!list_empty(&inode->i_lru))
+		inode_lru_list_del(inode);
 	spin_unlock(&inode->i_lock);
=20
 	evict(inode);


--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
