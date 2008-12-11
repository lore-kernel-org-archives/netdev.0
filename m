From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH v3 3/7] fs: Introduce a per_cpu last_ino allocator
Date: Thu, 11 Dec 2008 23:39:18 +0100
Message-ID: <49419696.9080509@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com> <493100B0.6090104@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"kernel-testers@vger.kernel.org >> Kernel Testers List"
	<kernel-testers@vger.kernel.org>, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:35435 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758691AbYLKWjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 17:39:54 -0500
In-Reply-To: <493100B0.6090104@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
