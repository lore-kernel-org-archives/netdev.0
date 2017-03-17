From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 15/18] net, ipx: convert ipx_interface.refcnt from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 13:12:56 +0200
Message-ID: <1489749179-12063-16-git-send-email-elena.reshetova@intel.com>
References: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, 3chas3@gmail.com, ralf@linux-mips.org,
        stephen@networkplumber.org, jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        marcel@holtmann.org, johan.hedberg@gmail.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 include/net/ipx.h  | 7 ++++---
 net/ipx/af_ipx.c   | 6 +++---
 net/ipx/ipx_proc.c | 2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/ipx.h b/include/net/ipx.h
index e5cff68..2de1281 100644
--- a/include/net/ipx.h
+++ b/include/net/ipx.h
@@ -14,6 +14,7 @@
 #include <linux/ipx.h>
 #include <linux/list.h>
 #include <linux/slab.h>
+#include <linux/refcount.h>
 
 struct ipx_address {
 	__be32  net;
@@ -54,7 +55,7 @@ struct ipx_interface {
 	/* IPX address */
 	__be32			if_netnum;
 	unsigned char		if_node[IPX_NODE_LEN];
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 
 	/* physical device info */
 	struct net_device	*if_dev;
@@ -139,7 +140,7 @@ const char *ipx_device_name(struct ipx_interface *intrfc);
 
 static __inline__ void ipxitf_hold(struct ipx_interface *intrfc)
 {
-	atomic_inc(&intrfc->refcnt);
+	refcount_inc(&intrfc->refcnt);
 }
 
 void ipxitf_down(struct ipx_interface *intrfc);
@@ -157,7 +158,7 @@ int ipxrtr_ioctl(unsigned int cmd, void __user *arg);
 
 static __inline__ void ipxitf_put(struct ipx_interface *intrfc)
 {
-	if (atomic_dec_and_test(&intrfc->refcnt))
+	if (refcount_dec_and_test(&intrfc->refcnt))
 		ipxitf_down(intrfc);
 }
 
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index 8a9219f..0675b4a 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -308,7 +308,7 @@ void ipxitf_down(struct ipx_interface *intrfc)
 
 static void __ipxitf_put(struct ipx_interface *intrfc)
 {
-	if (atomic_dec_and_test(&intrfc->refcnt))
+	if (refcount_dec_and_test(&intrfc->refcnt))
 		__ipxitf_down(intrfc);
 }
 
@@ -876,7 +876,7 @@ static struct ipx_interface *ipxitf_alloc(struct net_device *dev, __be32 netnum,
 		intrfc->if_ipx_offset 	= ipx_offset;
 		intrfc->if_sknum 	= IPX_MIN_EPHEMERAL_SOCKET;
 		INIT_HLIST_HEAD(&intrfc->if_sklist);
-		atomic_set(&intrfc->refcnt, 1);
+		refcount_set(&intrfc->refcnt, 1);
 		spin_lock_init(&intrfc->if_sklist_lock);
 	}
 
@@ -1105,7 +1105,7 @@ static struct ipx_interface *ipxitf_auto_create(struct net_device *dev,
 		memcpy((char *)&(intrfc->if_node[IPX_NODE_LEN-dev->addr_len]),
 			dev->dev_addr, dev->addr_len);
 		spin_lock_init(&intrfc->if_sklist_lock);
-		atomic_set(&intrfc->refcnt, 1);
+		refcount_set(&intrfc->refcnt, 1);
 		ipxitf_insert(intrfc);
 		dev_hold(dev);
 	}
diff --git a/net/ipx/ipx_proc.c b/net/ipx/ipx_proc.c
index c1d247e..7d75e4c 100644
--- a/net/ipx/ipx_proc.c
+++ b/net/ipx/ipx_proc.c
@@ -53,7 +53,7 @@ static int ipx_seq_interface_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "%-11s", ipx_device_name(i));
 	seq_printf(seq, "%-9s", ipx_frame_name(i->if_dlink_type));
 #ifdef IPX_REFCNT_DEBUG
-	seq_printf(seq, "%6d", atomic_read(&i->refcnt));
+	seq_printf(seq, "%6d", refcount_read(&i->refcnt));
 #endif
 	seq_puts(seq, "\n");
 out:
-- 
2.7.4
