From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vfs: conditionally call inode_wb_list_del()
Date: Thu, 28 Jul 2011 06:11:47 +0200
Message-ID: <1311826307.2697.19.camel@edumazet-laptop>
References: <1311633550.2576.33.camel@schen9-DESK>
	 <20110725225154.GD22133@ZenIV.linux.org.uk>
	 <1311636178.2576.34.camel@schen9-DESK>
	 <1311660013.2996.6.camel@edumazet-laptop>
	 <1311668466.2355.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110726090357.GA13013@infradead.org>
	 <1311672994.2355.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1311780065.2356.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110727204415.GA13308@infradead.org>
	 <20110727205957.GC8006@one.firstfloor.org>
	 <20110727210104.GA9066@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Matthew Wilcox <matthew@wil.cx>,
	Anton Blanchard <anton@samba.org>, npiggin@kernel.dk,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20110727210104.GA9066@infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 27 juillet 2011 =C3=A0 17:01 -0400, Christoph Hellwig a =C3=
=A9crit :
> On Wed, Jul 27, 2011 at 10:59:57PM +0200, Andi Kleen wrote:
> > > Btw, I wonder if you should micro-optimize things a bit further b=
y
> > > moving the unhashed checks from the deletion functions into the c=
allers
> > > and thus save a function call for each of them.
> >=20
> > If the caller is in the same file modern gcc is able to do that aut=
omatically
> > if you're lucky enough ("partial inlining")
> >=20
> > I would not uglify the code for it.
>=20
> Depending on how you look at it the code might actually be a tad
> cleaner.  One of called functions is outside of inode.c.
>=20

Thats right, thanks again for your valuable input Christoph.

The following is a clear win, since we avoid the call to external
function.

[PATCH] vfs: conditionally call inode_wb_list_del()

Some inodes (pipes, sockets, ...) are not in bdi writeback list.

evict() can avoid calling inode_wb_list_del() and its expensive spinloc=
k
by checking inode i_wb_list being empty or not.

At this point, no other cpu/user can concurrently manipulate this inode
i_wb_list

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 fs/inode.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/inode.c b/fs/inode.c
index d0c72ff..9dab13a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -454,7 +454,9 @@ static void evict(struct inode *inode)
 	BUG_ON(!(inode->i_state & I_FREEING));
 	BUG_ON(!list_empty(&inode->i_lru));
=20
-	inode_wb_list_del(inode);
+	if (!list_empty(&inode->i_wb_list))
+		inode_wb_list_del(inode);
+
 	inode_sb_list_del(inode);
=20
 	if (op->evict_inode) {


--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
