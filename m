From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree
Date: Fri, 20 May 2011 16:18:16 +1000
Message-ID: <20110520161816.dda6f1fd.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dipankar Sarma <dipankar@in.ibm.com>
To: Linus <torvalds@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the final tree, today's linux-next build (sparc32 defconfig)
failed like this:

mm/page_alloc.c: In function '__free_pages_bootmem':
mm/page_alloc.c:704: error: implicit declaration of function 'prefetchw'
fs/dcache.c: In function '__d_lookup_rcu':
fs/dcache.c:1810: error: implicit declaration of function 'prefetch'
fs/inode.c: In function 'new_inode':
fs/inode.c:894: error: implicit declaration of function 'spin_lock_prefetch'
net/core/skbuff.c: In function '__alloc_skb':
net/core/skbuff.c:184: error: implicit declaration of function 'prefetchw'
In file included from net/ipv4/ip_forward.c:32:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141: error: implicit declaration of function 'prefetch'
In file included from net/ipv6/af_inet6.c:48:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141: error: implicit declaration of function 'prefetch'
net/unix/af_unix.c: In function 'unix_ioctl':
net/unix/af_unix.c:2066: error: implicit declaration of function 'prefetch'
In file included from net/sunrpc/xprtsock.c:44:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141: error: implicit declaration of function 'prefetch'
kernel/rcutiny.c: In function 'rcu_process_callbacks':
kernel/rcutiny.c:180: error: implicit declaration of function 'prefetch'

Caused by commit e66eed651fd1 ("list: remove prefetching from regular list
iterators").

I added the following patch for today:

>From 1a101eb2766057372006b1b487d05f40fe899478 Mon Sep 17 00:00:00 2001
From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 20 May 2011 16:08:48 +1000
Subject: [PATCH] include prefetch.h where needed

Commit e66eed651fd1 ("list: remove prefetching from regular list
iterators") removed the include of prefetch.h from list.h.

fixes these build errors on sparc:

mm/page_alloc.c: In function '__free_pages_bootmem':
mm/page_alloc.c:704: error: implicit declaration of function 'prefetchw'
fs/dcache.c: In function '__d_lookup_rcu':
fs/dcache.c:1810: error: implicit declaration of function 'prefetch'
fs/inode.c: In function 'new_inode':
fs/inode.c:894: error: implicit declaration of function 'spin_lock_prefetch'
net/core/skbuff.c: In function '__alloc_skb':
net/core/skbuff.c:184: error: implicit declaration of function 'prefetchw'
In file included from net/ipv4/ip_forward.c:32:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141: error: implicit declaration of function 'prefetch'
In file included from net/ipv6/af_inet6.c:48:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141: error: implicit declaration of function 'prefetch'
net/unix/af_unix.c: In function 'unix_ioctl':
net/unix/af_unix.c:2066: error: implicit declaration of function 'prefetch'
In file included from net/sunrpc/xprtsock.c:44:
include/net/udp.h: In function 'udp_csum_outgoing':
include/net/udp.h:141: error: implicit declaration of function 'prefetch'
kernel/rcutiny.c: In function 'rcu_process_callbacks':
kernel/rcutiny.c:180: error: implicit declaration of function 'prefetch'

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 fs/dcache.c            |    1 +
 fs/inode.c             |    1 +
 include/linux/skbuff.h |    1 +
 kernel/rcutiny.c       |    1 +
 mm/page_alloc.c        |    1 +
 net/core/skbuff.c      |    1 +
 6 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 22a0ef4..18b2a1f 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -35,6 +35,7 @@
 #include <linux/hardirq.h>
 #include <linux/bit_spinlock.h>
 #include <linux/rculist_bl.h>
+#include <linux/prefetch.h>
 #include "internal.h"
 
 /*
diff --git a/fs/inode.c b/fs/inode.c
index 33c963d..c77081f 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -26,6 +26,7 @@
 #include <linux/posix_acl.h>
 #include <linux/ima.h>
 #include <linux/cred.h>
+#include <linux/prefetch.h>
 #include "internal.h"
 
 /*
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 79aafbb..f963b8f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/prefetch.h>
 
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
diff --git a/kernel/rcutiny.c b/kernel/rcutiny.c
index 421abfd..7bbac7d 100644
--- a/kernel/rcutiny.c
+++ b/kernel/rcutiny.c
@@ -35,6 +35,7 @@
 #include <linux/init.h>
 #include <linux/time.h>
 #include <linux/cpu.h>
+#include <linux/prefetch.h>
 
 /* Controls for rcu_kthread() kthread, replacing RCU_SOFTIRQ used previously. */
 static struct task_struct *rcu_kthread_task;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 44b3d7b..9d5498e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -54,6 +54,7 @@
 #include <trace/events/kmem.h>
 #include <linux/ftrace_event.h>
 #include <linux/memcontrol.h>
+#include <linux/prefetch.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3e934fe..46cbd28 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -57,6 +57,7 @@
 #include <linux/init.h>
 #include <linux/scatterlist.h>
 #include <linux/errqueue.h>
+#include <linux/prefetch.h>
 
 #include <net/protocol.h>
 #include <net/dst.h>
-- 
1.7.5.1

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
