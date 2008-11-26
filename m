From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 3/6] fs: Introduce a per_cpu last_ino allocator
Date: Thu, 27 Nov 2008 00:32:24 +0100
Message-ID: <492DDC88.2050305@cosmosbay.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040706040803030002020404"
Cc: David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42584 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755462AbYKZXc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 18:32:57 -0500
In-Reply-To: <20081121153453.GA23713@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040706040803030002020404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

new_inode() dirties a contended cache line to get inode numbers.

Solve this problem by providing to each cpu a per_cpu variable,
feeded by the shared last_ino, but once every 1024 allocations.

This reduce contention on the shared last_ino.

Note : last_ino_get() method must be called with preemption
disabled on SMP.


(socket8 bench result : no differences, but this is because inode_lock
cost is too heavy)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 fs/inode.c |   27 +++++++++++++++++++++++++--
 1 files changed, 25 insertions(+), 2 deletions(-)

--------------040706040803030002020404
Content-Type: text/plain;
 name="last_ino.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="last_ino.patch"

diff --git a/fs/inode.c b/fs/inode.c
index 0487ddb..d850050 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -534,6 +534,30 @@ repeat:
 	return node ? inode : NULL;
 }
 
+#ifdef CONFIG_SMP
+/*
+ * each cpu owns a block of 1024 numbers.
+ * The global 'last_ino' is dirtied once every 1024 allocations
+ */
+static DEFINE_PER_CPU(int, cpu_ino_alloc) = {0};
+static int last_ino_get(void)
+{
+	static atomic_t last_ino;
+	int *ptr = &__raw_get_cpu_var(cpu_ino_alloc);
+
+	if (unlikely((*ptr & 1023) == 0))
+		*ptr = atomic_add_return(1024, &last_ino);
+	return --(*ptr);
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
@@ -553,7 +577,6 @@ struct inode *new_inode(struct super_block *sb)
 	 * error if st_ino won't fit in target struct field. Use 32bit counter
 	 * here to attempt to avoid that.
 	 */
-	static unsigned int last_ino;
 	struct inode * inode;
 
 	spin_lock_prefetch(&inode_lock);
@@ -564,7 +587,7 @@ struct inode *new_inode(struct super_block *sb)
 		inodes_stat.nr_inodes++;
 		list_add(&inode->i_list, &inode_in_use);
 		list_add(&inode->i_sb_list, &sb->s_inodes);
-		inode->i_ino = ++last_ino;
+		inode->i_ino = last_ino_get();
 		inode->i_state = 0;
 		spin_unlock(&inode_lock);
 	}

--------------040706040803030002020404--
