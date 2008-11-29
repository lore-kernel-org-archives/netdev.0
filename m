From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH v2 3/5] fs: Introduce a per_cpu last_ino allocator
Date: Sat, 29 Nov 2008 09:44:16 +0100
Message-ID: <493100E0.4010009@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000501050205030308050301"
Cc: David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"kernel-testers@vger.kernel.org >> Kernel Testers List"
	<kernel-testers@vger.kernel.org>, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
To: Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <492DDB6A.8090806@cosmosbay.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000501050205030308050301
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

new_inode() dirties a contended cache line to get increasing
inode numbers.

Solve this problem by providing to each cpu a per_cpu variable,
feeded by the shared last_ino, but once every 1024 allocations.

This reduce contention on the shared last_ino, and give same
spreading ino numbers than before.
(same wraparound after 2^32 allocations)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 fs/inode.c |   35 ++++++++++++++++++++++++++++++++---
 1 files changed, 32 insertions(+), 3 deletions(-)


--------------000501050205030308050301
Content-Type: text/plain;
 name="last_ino.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="last_ino.patch"

diff --git a/fs/inode.c b/fs/inode.c
index f94f889..dc8e72a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -556,6 +556,36 @@ repeat:
 	return node ? inode : NULL;
 }
 
+#ifdef CONFIG_SMP
+/*
+ * Each cpu owns a range of 1024 numbers.
+ * 'shared_last_ino' is dirtied only once out of 1024 allocations,
+ * to renew the exhausted range.
+ */
+static DEFINE_PER_CPU(int, last_ino);
+
+static int last_ino_get(void)
+{
+	static atomic_t shared_last_ino;
+	int *p = &get_cpu_var(last_ino);
+	int res = *p;
+
+	if (unlikely((res & 1023) == 0))
+		res = atomic_add_return(1024, &shared_last_ino) - 1024;
+
+	*p = ++res;
+	put_cpu_var(last_ino);
+	return res;
+}
+#else
+static int last_ino_get(void)
+{
+	static int last_ino;
+
+	return ++last_ino;
+}
+#endif
+
 /**
  *	new_inode 	- obtain an inode
  *	@sb: superblock
@@ -575,7 +605,6 @@ struct inode *new_inode(struct super_block *sb)
 	 * error if st_ino won't fit in target struct field. Use 32bit counter
 	 * here to attempt to avoid that.
 	 */
-	static unsigned int last_ino;
 	struct inode * inode;
 
 	spin_lock_prefetch(&inode_lock);
@@ -583,11 +612,11 @@ struct inode *new_inode(struct super_block *sb)
 	inode = alloc_inode(sb);
 	if (inode) {
 		percpu_counter_inc(&nr_inodes);
+		inode->i_state = 0;
+		inode->i_ino = last_ino_get();
 		spin_lock(&inode_lock);
 		list_add(&inode->i_list, &inode_in_use);
 		list_add(&inode->i_sb_list, &sb->s_inodes);
-		inode->i_ino = ++last_ino;
-		inode->i_state = 0;
 		spin_unlock(&inode_lock);
 	}
 	return inode;

--------------000501050205030308050301--
