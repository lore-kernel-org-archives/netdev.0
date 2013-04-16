From: Paul Moore <pmoore@redhat.com>
Subject: [RFC PATCH 3/3] net: move sk_buff->secmark into a security blob in
 skb_shared_info
Date: Tue, 16 Apr 2013 16:39:25 -0400
Message-ID: <20130416203925.10474.4599.stgit@localhost>
References: <20130416202437.10474.45713.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130416202437.10474.45713.stgit@localhost>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves the "secmark" field from where it currently lives
in the sk_buff struct to a newly overloaded field in the
skb_shared_info struct.  There are two main reasons for making this
change 1) we shrink sk_buff from 256 bytes to 248 bytes (on x86_64)
(the sk_buff breakdown is shown below) and 2) we gain a LSM security
blob.

There are two catches to this change 1) the secmark value is now the
same for a sk_buff and all its associated clones and 2) we overload
the "destructor_arg" field in the skb_shared_info struct.  The
secmark/clone issue is not a problem as SELinux, the only user, keeps
the secmark value consistent across clone calls and it seems
reasonable that any other LSM using secmark would do the same as the
LSM security attributes are generally tied to the packet's data and
not the sk_buff metadata.  The overloading issue is a bit more
awkward, but with the sk_buff and skb_shared_info structures already
carefully pruned for size, adding a new field is not an option (so
says DaveM) make replacement or overloading of an existing field the
only viable options.  Not finding a field suitable for replacement,
this patch opts for the overloading option and choose the
"destructor_arg" field due to its size and usage within the core
network stack.

The "destructor_arg" overloading is done in such a way that there
should be no impact when the LSM is disabled at compile time, and
only an additional function call when the LSM is enabled but the
hooks are not in use by the active LSM.  When the LSM is enabled and
the active LSM is making use of the new hooks there will be some
additional overhead, but that is to be expected.

For reference, here is the breakdown of the sk_buff struct:

BEFORE:
struct sk_buff {
        struct sk_buff *           next;                 /*     0     8 */
        struct sk_buff *           prev;                 /*     8     8 */
        ktime_t                    tstamp;               /*    16     8 */
        struct sock *              sk;                   /*    24     8 */
        struct net_device *        dev;                  /*    32     8 */
        char                       cb[48];               /*    40    48 */
        /* --- cacheline 1 boundary (64 bytes) was 24 bytes ago --- */
        long unsigned int          _skb_refdst;          /*    88     8 */
        struct sec_path *          sp;                   /*    96     8 */
        unsigned int               len;                  /*   104     4 */
        unsigned int               data_len;             /*   108     4 */
        __u16                      mac_len;              /*   112     2 */
        __u16                      hdr_len;              /*   114     2 */
        union {
                __wsum             csum;                 /*           4 */
                struct {
                        __u16      csum_start;           /*   116     2 */
                        __u16      csum_offset;          /*   118     2 */
                };                                       /*           4 */
        };                                               /*   116     4 */
        __u32                      priority;             /*   120     4 */
        int                        flags1_begin[0];      /*   124     0 */
        __u8                       local_df:1;           /*   124: 7  1 */
        __u8                       cloned:1;             /*   124: 6  1 */
        __u8                       ip_summed:2;          /*   124: 4  1 */
        __u8                       nohdr:1;              /*   124: 3  1 */
        __u8                       nfctinfo:3;           /*   124: 0  1 */
        __u8                       pkt_type:3;           /*   125: 5  1 */
        __u8                       fclone:2;             /*   125: 3  1 */
        __u8                       ipvs_property:1;      /*   125: 2  1 */
        __u8                       peeked:1;             /*   125: 1  1 */
        __u8                       nf_trace:1;           /*   125: 0  1 */

        /* XXX 2 bytes hole, try to pack */

        /* --- cacheline 2 boundary (128 bytes) --- */
        int                        flags1_end[0];        /*   128     0 */
        __be16                     protocol;             /*   128     2 */

        /* XXX 6 bytes hole, try to pack */

        void                       (*destructor)(struct sk_buff *);
                                                         /*   136     8 */
        struct nf_conntrack *      nfct;                 /*   144     8 */
        struct sk_buff *           nfct_reasm;           /*   152     8 */
        struct nf_bridge_info *    nf_bridge;            /*   160     8 */
        int                        skb_iif;              /*   168     4 */
        __u32                      rxhash;               /*   172     4 */
        __u16                      vlan_tci;             /*   176     2 */
        __u16                      tc_index;             /*   178     2 */
        __u16                      tc_verd;              /*   180     2 */
        __u16                      queue_mapping;        /*   182     2 */
        int                        flags2_begin[0];      /*   184     0 */
        __u8                       ndisc_nodetype:2;     /*   184: 6  1 */
        __u8                       pfmemalloc:1;         /*   184: 5  1 */
        __u8                       ooo_okay:1;           /*   184: 4  1 */
        __u8                       l4_rxhash:1;          /*   184: 3  1 */
        __u8                       wifi_acked_valid:1;   /*   184: 2  1 */
        __u8                       wifi_acked:1;         /*   184: 1  1 */
        __u8                       no_fcs:1;             /*   184: 0  1 */
        __u8                       head_frag:1;          /*   185: 7  1 */
        __u8                       encapsulation:1;      /*   185: 6  1 */

        /* XXX 6 bits hole, try to pack */
        /* XXX 2 bytes hole, try to pack */

        int                        flags2_end[0];        /*   188     0 */
        dma_cookie_t               dma_cookie;           /*   188     4 */
        /* --- cacheline 3 boundary (192 bytes) --- */
        __u32                      secmark;              /*   192     4 */
        union {
                __u32              mark;                 /*           4 */
                __u32              dropcount;            /*           4 */
                __u32              reserved_tailroom;    /*           4 */
        };                                               /*   196     4 */
        sk_buff_data_t             inner_transport_header; /* 200     4 */
        sk_buff_data_t             inner_network_header; /*   204     4 */
        sk_buff_data_t             transport_header;     /*   208     4 */
        sk_buff_data_t             network_header;       /*   212     4 */
        sk_buff_data_t             mac_header;           /*   216     4 */
        sk_buff_data_t             tail;                 /*   220     4 */
        sk_buff_data_t             end;                  /*   224     4 */

        /* XXX 4 bytes hole, try to pack */

        unsigned char *            head;                 /*   232     8 */
        unsigned char *            data;                 /*   240     8 */
        unsigned int               truesize;             /*   248     4 */
        atomic_t                   users;                /*   252     4 */
        /* --- cacheline 4 boundary (256 bytes) --- */

        /* size: 256, cachelines: 4, members: 62 */
        /* sum members: 242, holes: 4, sum holes: 14 */
        /* bit holes: 1, sum bit holes: 6 bits */
};

AFTER:
struct sk_buff_test {
        struct sk_buff *           next;                 /*     0     8 */
        struct sk_buff *           prev;                 /*     8     8 */
        ktime_t                    tstamp;               /*    16     8 */
        struct sock *              sk;                   /*    24     8 */
        struct net_device *        dev;                  /*    32     8 */
        char                       cb[48];               /*    40    48 */
        /* --- cacheline 1 boundary (64 bytes) was 24 bytes ago --- */
        long unsigned int          _skb_refdst;          /*    88     8 */
        struct sec_path *          sp;                   /*    96     8 */
        unsigned int               len;                  /*   104     4 */
        unsigned int               data_len;             /*   108     4 */
        __u16                      mac_len;              /*   112     2 */
        __u16                      hdr_len;              /*   114     2 */
        union {
                __wsum             csum;                 /*           4 */
                struct {
                        __u16      csum_start;           /*   116     2 */
                        __u16      csum_offset;          /*   118     2 */
                };                                       /*           4 */
        };                                               /*   116     4 */
        __u32                      priority;             /*   120     4 */
        int                        flags1_begin[0];      /*   124     0 */
        __u8                       local_df:1;           /*   124: 7  1 */
        __u8                       cloned:1;             /*   124: 6  1 */
        __u8                       ip_summed:2;          /*   124: 4  1 */
        __u8                       nohdr:1;              /*   124: 3  1 */
        __u8                       nfctinfo:3;           /*   124: 0  1 */
        __u8                       pkt_type:3;           /*   125: 5  1 */
        __u8                       fclone:2;             /*   125: 3  1 */
        __u8                       ipvs_property:1;      /*   125: 2  1 */
        __u8                       peeked:1;             /*   125: 1  1 */
        __u8                       nf_trace:1;           /*   125: 0  1 */

        /* XXX 2 bytes hole, try to pack */

        /* --- cacheline 2 boundary (128 bytes) --- */
        int                        flags1_end[0];        /*   128     0 */
        __be16                     protocol;             /*   128     2 */

        /* XXX 6 bytes hole, try to pack */

        void                       (*destructor)(struct sk_buff *);
                                                         /*   136     8 */
        struct nf_conntrack *      nfct;                 /*   144     8 */
        struct sk_buff *           nfct_reasm;           /*   152     8 */
        struct nf_bridge_info *    nf_bridge;            /*   160     8 */
        int                        skb_iif;              /*   168     4 */
        __u32                      rxhash;               /*   172     4 */
        __u16                      vlan_tci;             /*   176     2 */
        __u16                      tc_index;             /*   178     2 */
        __u16                      tc_verd;              /*   180     2 */
        __u16                      queue_mapping;        /*   182     2 */
        int                        flags2_begin[0];      /*   184     0 */
        __u8                       ndisc_nodetype:2;     /*   184: 6  1 */
        __u8                       pfmemalloc:1;         /*   184: 5  1 */
        __u8                       ooo_okay:1;           /*   184: 4  1 */
        __u8                       l4_rxhash:1;          /*   184: 3  1 */
        __u8                       wifi_acked_valid:1;   /*   184: 2  1 */
        __u8                       wifi_acked:1;         /*   184: 1  1 */
        __u8                       no_fcs:1;             /*   184: 0  1 */
        __u8                       head_frag:1;          /*   185: 7  1 */
        __u8                       encapsulation:1;      /*   185: 6  1 */

        /* XXX 6 bits hole, try to pack */
        /* XXX 2 bytes hole, try to pack */

        int                        flags2_end[0];        /*   188     0 */
        dma_cookie_t               dma_cookie;           /*   188     4 */
        /* --- cacheline 3 boundary (192 bytes) --- */
        union {
                __u32              mark;                 /*           4 */
                __u32              dropcount;            /*           4 */
                __u32              reserved_tailroom;    /*           4 */
        };                                               /*   192     4 */
        sk_buff_data_t             inner_transport_header; /* 196     4 */
        sk_buff_data_t             inner_network_header; /*   200     4 */
        sk_buff_data_t             transport_header;     /*   204     4 */
        sk_buff_data_t             network_header;       /*   208     4 */
        sk_buff_data_t             mac_header;           /*   212     4 */
        sk_buff_data_t             tail;                 /*   216     4 */
        sk_buff_data_t             end;                  /*   220     4 */
        unsigned char *            head;                 /*   224     8 */
        unsigned char *            data;                 /*   232     8 */
        unsigned int               truesize;             /*   240     4 */
        atomic_t                   users;                /*   244     4 */

        /* size: 248, cachelines: 4, members: 61 */
        /* sum members: 238, holes: 3, sum holes: 10 */
        /* bit holes: 1, sum bit holes: 6 bits */
        /* last cacheline: 56 bytes */
};

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/linux/security.h          |   71 ++++++++++++++++++++++++
 include/linux/skbuff.h            |   58 ++++++++++----------
 net/core/skbuff.c                 |   22 +++++++-
 net/ipv4/ip_output.c              |    2 -
 net/ipv6/ip6_output.c             |    2 -
 net/netfilter/xt_AUDIT.c          |    8 +--
 security/capability.c             |   28 ++++++++++
 security/security.c               |   52 ++++++++++++++++++
 security/selinux/hooks.c          |  108 ++++++++++++++++++++++++++++++++++---
 security/selinux/include/objsec.h |    6 ++
 10 files changed, 311 insertions(+), 46 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 464f123..53484af 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -19,6 +19,10 @@
  *
  */
 
+/* We include linux/skbuff.h at the very top to prevent problems with both
+ * linux/skbuff.h and linux/security.h including each other */
+#include <linux/skbuff.h>
+
 #ifndef __LINUX_SECURITY_H
 #define __LINUX_SECURITY_H
 
@@ -98,7 +102,6 @@ extern int cap_task_setnice(struct task_struct *p, int nice);
 extern int cap_vm_enough_memory(struct mm_struct *mm, long pages);
 
 struct msghdr;
-struct sk_buff;
 struct sock;
 struct sockaddr;
 struct socket;
@@ -1012,10 +1015,32 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	This hook can be used by the module to update any security state
  *	associated with the TUN device's security structure.
  *	@security pointer to the TUN devices's security structure.
+ * @skb_alloc:
+ *	This hook is called when a new packet is allocated and should be used
+ *	to allocate any per-packet security state.
+ *	@skb the packet
+ *	@gfp_mask allocation mask.
+ *	@flags the flags passed to __alloc_skb().
+ *	@node NUMA node, set to -1 if NUMA information is not available.
+ * @skb_free:
+ *	This hook is called when a packet is freed and should be used to
+ *	release any per-packet security state.
+ *	@skb the packet.
+ * @skb_security_copy:
+ *	This hook copies the security metadata from one packet to another.
+ *	@dst the destination packet.
+ *	@src the source packet.
  * @skb_owned_by:
  *	This hook sets the packet's owning sock.
  *	@skb is the packet.
  *	@sk the sock which owns the packet.
+ * @skb_destructor_arg_set:
+ *	This hook sets the packet's destructor argument.
+ *	@skb packet.
+ *	@ptr pointer to the destructor argument.
+ * @skb_destructor_arg_get:
+ *	This hook returns the packet's destructor argument.
+ *	@skb the packet.
  * @skb_secmark_set:
  *	This hook sets the secmark on a packet.
  *	@skb the packet.
@@ -1649,7 +1674,12 @@ struct security_operations {
 	int (*tun_dev_attach_queue) (void *security);
 	int (*tun_dev_attach) (struct sock *sk, void *security);
 	int (*tun_dev_open) (void *security);
+	int (*skb_alloc) (struct sk_buff *skb, gfp_t gfp_mask, int flags, int node);
+	void (*skb_free) (struct sk_buff *skb);
+	void (*skb_security_copy) (struct sk_buff *dst, const struct sk_buff *src);
 	void (*skb_owned_by) (struct sk_buff *skb, struct sock *sk);
+	void (*skb_destructor_arg_set) (struct sk_buff *skb, void *ptr);
+	void *(*skb_destructor_arg_get) (const struct sk_buff *skb);
 	void (*skb_secmark_set) (struct sk_buff *skb, u32 secmark);
 	u32 (*skb_secmark_get) (const struct sk_buff *skb);
 #endif	/* CONFIG_SECURITY_NETWORK */
@@ -2601,6 +2631,13 @@ int security_tun_dev_create(void);
 int security_tun_dev_attach_queue(void *security);
 int security_tun_dev_attach(struct sock *sk, void *security);
 int security_tun_dev_open(void *security);
+int security_skb_alloc(struct sk_buff *skb, gfp_t gfp_mask, int flags, int node);
+void security_skb_free(struct sk_buff *skb);
+void security_skb_ref(struct sk_buff *skb);
+void security_skb_unref(struct sk_buff *skb);
+void security_skb_security_copy(struct sk_buff *dst, const struct sk_buff *src);
+void security_skb_destructor_arg_set(struct sk_buff *skb, void *ptr);
+void *security_skb_destructor_arg_get(const struct sk_buff *skb);
 void security_skb_owned_by(struct sk_buff *skb, struct sock *sk);
 void security_skb_secmark_set(struct sk_buff *skb, u32 secmark);
 u32 security_skb_secmark_get(const struct sk_buff *skb);
@@ -2797,10 +2834,42 @@ static inline int security_tun_dev_open(void *security)
 	return 0;
 }
 
+static inline int security_skb_alloc(struct sk_buff *skb, gfp_t gfp_mask, int flags, int node)
+{
+	return 0;
+}
+
+static inline void security_skb_free(struct sk_buff *skb)
+{
+}
+
+static inline void security_skb_ref(struct sk_buff *skb)
+{
+}
+
+static inline void security_skb_unref(struct sk_buff *skb)
+{
+}
+
+static inline void security_skb_security_copy(struct sk_buff *dst,
+					      const struct sk_buff *src)
+{
+}
+
 static inline void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 {
 }
 
+static inline void security_skb_destructor_arg_set(struct sk_buff *skb, void *ptr)
+{
+	skb_shinfo(skb)->destructor_arg = ptr;
+}
+
+static inline void *security_skb_destructor_arg_get(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->destructor_arg;
+}
+
 static inline void security_skb_secmark_set(struct sk_buff *skb, u32 secmark)
 {
 }
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0998af3..58c559e9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -253,6 +253,25 @@ struct ubuf_info {
 	unsigned long desc;
 };
 
+/* Used by skb_shared_info->opt_data when the LSM is using the security blob,
+ * otherwise the destructor_arg pointer is stored directly in
+ * skb_shared_info->destructor_arg.  Only the LSMs should ever use this struct
+ * directly, the network stack should use the skb_destructor_arg_{set,get}()
+ * helper functions. */
+struct skb_opt_info {
+	void *destructor_arg;
+
+	/* Used to keep track of the security pointer below; not the
+	 * destructor_arg field above which is covered by the
+	 * skb_shared_info protections. */
+	atomic_t sec_refcnt;
+
+	/* This must always be the last element so the LSM can allocate the
+	 * skb_opt_info struct and their own state struct with a single
+	 * allocation. */
+	unsigned char security[0];
+};
+
 /* This data is invariant across clones and lives at
  * the end of the header data, ie. at skb->end.
  */
@@ -272,9 +291,12 @@ struct skb_shared_info {
 	 */
 	atomic_t	dataref;
 
-	/* Intermediate layers must ensure that destructor_arg
-	 * remains valid until skb destructor */
-	void *		destructor_arg;
+	/* Intermediate layers must ensure that the union fields remain valid
+	 * until the skb is freed.  See the comments for skb_opt_info above. */
+	union {
+		void *			destructor_arg;
+		struct skb_opt_info *	opt_data;
+	};
 
 	/* must be last field, see pskb_expand_head() */
 	skb_frag_t	frags[MAX_SKB_FRAGS];
@@ -381,7 +403,6 @@ typedef unsigned char *sk_buff_data_t;
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
- *	@secmark: security marking
  *	@mark: Generic packet mark
  *	@dropcount: total number of sk_receive_queue overflows
  *	@vlan_tci: vlan tag control information
@@ -494,9 +515,6 @@ struct sk_buff {
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
 #endif
-#ifdef CONFIG_NETWORK_SECMARK
-	__u32			secmark;
-#endif
 	union {
 		__u32		mark;
 		__u32		dropcount;
@@ -523,7 +541,6 @@ struct sk_buff {
  */
 #include <linux/slab.h>
 
-
 #define SKB_ALLOC_FCLONE	0x01
 #define SKB_ALLOC_RX		0x02
 
@@ -695,6 +712,9 @@ static inline unsigned int skb_end_offset(const struct sk_buff *skb)
 
 /* Internal */
 #define skb_shinfo(SKB)	((struct skb_shared_info *)(skb_end_pointer(SKB)))
+#define skb_optinfo(SKB) (skb_shinfo(SKB)->opt_data)
+
+#include <linux/security.h>
 
 /**
  *	skb_destructor_arg_set - set the packet's destructor argument
@@ -703,7 +723,7 @@ static inline unsigned int skb_end_offset(const struct sk_buff *skb)
  */
 static inline void skb_destructor_arg_set(struct sk_buff *skb, void *ptr)
 {
-	skb_shinfo(skb)->destructor_arg = ptr;
+	security_skb_destructor_arg_set(skb, ptr);
 }
 
 /**
@@ -712,7 +732,7 @@ static inline void skb_destructor_arg_set(struct sk_buff *skb, void *ptr)
  */
 static inline void *skb_destructor_arg_get(const struct sk_buff *skb)
 {
-	return skb_shinfo(skb)->destructor_arg;
+	return security_skb_destructor_arg_get(skb);
 }
 
 static inline struct skb_shared_hwtstamps *skb_hwtstamps(struct sk_buff *skb)
@@ -2701,24 +2721,6 @@ static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 	__nf_copy(dst, src);
 }
 
-#ifdef CONFIG_NETWORK_SECMARK
-static inline void skb_copy_secmark(struct sk_buff *to, const struct sk_buff *from)
-{
-	to->secmark = from->secmark;
-}
-
-static inline void skb_init_secmark(struct sk_buff *skb)
-{
-	skb->secmark = 0;
-}
-#else
-static inline void skb_copy_secmark(struct sk_buff *to, const struct sk_buff *from)
-{ }
-
-static inline void skb_init_secmark(struct sk_buff *skb)
-{ }
-#endif
-
 static inline void skb_set_queue_mapping(struct sk_buff *skb, u16 queue_mapping)
 {
 	skb->queue_mapping = queue_mapping;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e4fa549..9d4ea5f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -70,6 +70,7 @@
 #include <asm/uaccess.h>
 #include <trace/events/skb.h>
 #include <linux/highmem.h>
+#include <linux/security.h>
 
 struct kmem_cache *skbuff_head_cache __read_mostly;
 static struct kmem_cache *skbuff_fclone_cache __read_mostly;
@@ -271,12 +272,20 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t gfp_mask,
 		child->fclone = SKB_FCLONE_UNAVAILABLE;
 		child->pfmemalloc = pfmemalloc;
 	}
+
+	if (security_skb_alloc(skb, gfp_mask, flags, node) < 0)
+		goto data;
+
 out:
 	return skb;
 nodata:
 	kmem_cache_free(cache, skb);
 	skb = NULL;
 	goto out;
+data:
+	kfree_skb(skb);
+	skb = NULL;
+	goto out;
 }
 EXPORT_SYMBOL(__alloc_skb);
 
@@ -328,7 +337,14 @@ struct sk_buff *build_skb(void *data, unsigned int frag_size)
 	atomic_set(&shinfo->dataref, 1);
 	kmemcheck_annotate_variable(shinfo->destructor_arg);
 
+	if (security_skb_alloc(skb, GFP_ATOMIC, 0, -1) < 0)
+		goto free_skb;
+
 	return skb;
+
+free_skb:
+	kmem_cache_free(skbuff_head_cache, skb);
+	return NULL;
 }
 EXPORT_SYMBOL(build_skb);
 
@@ -514,6 +530,8 @@ static void skb_release_data(struct sk_buff *skb)
 		if (skb_has_frag_list(skb))
 			skb_drop_fraglist(skb);
 
+		security_skb_free(skb);
+
 		skb_free_head(skb);
 	}
 }
@@ -707,8 +725,6 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 #endif
 	new->vlan_tci		= old->vlan_tci;
-
-	skb_copy_secmark(new, old);
 }
 
 /*
@@ -1062,6 +1078,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		if (skb_has_frag_list(skb))
 			skb_clone_fraglist(skb);
 
+		security_skb_ref(skb);
+
 		skb_release_data(skb);
 	} else {
 		skb_free_head(skb);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 5e12dca..c2fb026 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -437,7 +437,7 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	to->ipvs_property = from->ipvs_property;
 #endif
-	skb_copy_secmark(to, from);
+	security_skb_security_copy(to, from);
 }
 
 /*
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 155eccf..4d176b7 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -520,7 +520,7 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
 	to->nf_trace = from->nf_trace;
 #endif
-	skb_copy_secmark(to, from);
+	security_skb_security_copy(to, from);
 }
 
 int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
index 3228d7f..4fa6d27 100644
--- a/net/netfilter/xt_AUDIT.c
+++ b/net/netfilter/xt_AUDIT.c
@@ -123,6 +123,7 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_audit_info *info = par->targinfo;
 	struct audit_buffer *ab;
+	u32 secmark;
 
 	if (audit_enabled == 0)
 		goto errout;
@@ -167,10 +168,9 @@ audit_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		break;
 	}
 
-#ifdef CONFIG_NETWORK_SECMARK
-	if (skb->secmark)
-		audit_log_secctx(ab, skb->secmark);
-#endif
+	secmark = security_skb_secmark_get(skb);
+	if (secmark)
+		audit_log_secctx(ab, secmark);
 
 	audit_log_end(ab);
 
diff --git a/security/capability.c b/security/capability.c
index b7c0ef2..1ff3b6f 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -738,10 +738,33 @@ static int cap_tun_dev_open(void *security)
 	return 0;
 }
 
+static int cap_skb_alloc(struct sk_buff *skb, gfp_t gfp_mask, int flags, int node)
+{
+	return 0;
+}
+
+static void cap_skb_free(struct sk_buff *skb)
+{
+}
+
+static void cap_skb_security_copy(struct sk_buff *dst, const struct sk_buff *src)
+{
+}
+
 static void cap_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 {
 }
 
+static void cap_skb_destructor_arg_set(struct sk_buff *skb, void *ptr)
+{
+	skb_shinfo(skb)->destructor_arg = ptr;
+}
+
+static void *cap_skb_destructor_arg_get(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->destructor_arg;
+}
+
 static void cap_skb_secmark_set(struct sk_buff *skb, u32 secmark)
 {
 }
@@ -1084,7 +1107,12 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, tun_dev_open);
 	set_to_cap_if_null(ops, tun_dev_attach_queue);
 	set_to_cap_if_null(ops, tun_dev_attach);
+	set_to_cap_if_null(ops, skb_alloc);
+	set_to_cap_if_null(ops, skb_free);
+	set_to_cap_if_null(ops, skb_security_copy);
 	set_to_cap_if_null(ops, skb_owned_by);
+	set_to_cap_if_null(ops, skb_destructor_arg_set);
+	set_to_cap_if_null(ops, skb_destructor_arg_get);
 	set_to_cap_if_null(ops, skb_secmark_set);
 	set_to_cap_if_null(ops, skb_secmark_get);
 #endif	/* CONFIG_SECURITY_NETWORK */
diff --git a/security/security.c b/security/security.c
index 7e2b7c7..11aa73b 100644
--- a/security/security.c
+++ b/security/security.c
@@ -24,6 +24,7 @@
 #include <linux/mount.h>
 #include <linux/personality.h>
 #include <linux/backing-dev.h>
+#include <linux/skbuff.h>
 #include <net/flow.h>
 
 #define MAX_LSM_EVM_XATTR	2
@@ -1290,11 +1291,62 @@ int security_tun_dev_open(void *security)
 }
 EXPORT_SYMBOL(security_tun_dev_open);
 
+int security_skb_alloc(struct sk_buff *skb, gfp_t gfp_mask, int flags, int node)
+{
+	int rc;
+
+	rc = security_ops->skb_alloc(skb, gfp_mask, flags, node);
+	if (rc == 0)
+		atomic_set(&skb_optinfo(skb)->sec_refcnt, 1);
+	return rc;
+}
+
+void security_skb_free(struct sk_buff *skb)
+{
+	struct skb_opt_info *skb_opt = skb_optinfo(skb);
+
+	BUG_ON(skb_opt == NULL);
+
+	if (atomic_dec_and_test(&skb_opt->sec_refcnt))
+		security_ops->skb_free(skb);
+	else
+		/* we keep the security data we need to reset the rest */
+		skb_opt->destructor_arg = NULL;
+}
+
+void security_skb_ref(struct sk_buff *skb)
+{
+	atomic_inc(&skb_optinfo(skb)->sec_refcnt);
+}
+
+void security_skb_unref(struct sk_buff *skb)
+{
+	atomic_dec(&skb_optinfo(skb)->sec_refcnt);
+}
+
+void security_skb_security_copy(struct sk_buff *dst, const struct sk_buff *src)
+{
+	security_ops->skb_security_copy(dst, src);
+}
+EXPORT_SYMBOL(security_skb_security_copy);
+
 void security_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 {
 	security_ops->skb_owned_by(skb, sk);
 }
 
+void security_skb_destructor_arg_set(struct sk_buff *skb, void *ptr)
+{
+	security_ops->skb_destructor_arg_set(skb, ptr);
+}
+EXPORT_SYMBOL(security_skb_destructor_arg_set);
+
+void *security_skb_destructor_arg_get(const struct sk_buff *skb)
+{
+	return security_ops->skb_destructor_arg_get(skb);
+}
+EXPORT_SYMBOL(security_skb_destructor_arg_get);
+
 void security_skb_secmark_set(struct sk_buff *skb, u32 secmark)
 {
 	security_ops->skb_secmark_set(skb, secmark);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5021cf7..2b60493 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -131,6 +131,8 @@ int selinux_enabled = 1;
 
 static struct kmem_cache *sel_inode_cache;
 
+static struct kmem_cache *sel_skb_cache;
+
 /**
  * selinux_secmark_enabled - Check to see if SECMARK is currently enabled
  *
@@ -3473,19 +3475,97 @@ static void selinux_task_to_inode(struct task_struct *p,
 	isec->initialized = 1;
 }
 
+static int selinux_skb_alloc(struct sk_buff *skb,
+			     gfp_t gfp_mask, int flags, int node)
+{
+	struct skb_opt_info *skb_opt;
+	gfp_t gfp = gfp_mask & ~__GFP_DMA;
+
+	if (node < 0)
+		skb_opt = kmem_cache_alloc(sel_skb_cache, gfp);
+	else
+		skb_opt = kmem_cache_alloc_node(sel_skb_cache, gfp, node);
+	if (skb_opt == NULL)
+		return -ENOMEM;
+	memset(skb_opt, 0,
+	       sizeof(struct skb_opt_info)+sizeof(struct skb_security_struct));
+	skb_optinfo(skb) = skb_opt;
+
+	return 0;
+}
+
+static void selinux_skb_free(struct sk_buff *skb)
+{
+	struct skb_opt_info *skb_opt = skb_optinfo(skb);
+
+	BUG_ON(skb_opt == NULL);
+
+	skb_optinfo(skb) = NULL;
+	kmem_cache_free(sel_skb_cache, skb_opt);
+}
+
+static void selinux_skb_security_copy(struct sk_buff *dst,
+				      const struct sk_buff *src)
+{
+	struct skb_security_struct *skbsec_dst;
+	struct skb_security_struct *skbsec_src;
+
+	BUG_ON(skb_optinfo(dst) == NULL || skb_optinfo(src) == NULL);
+	if (skb_optinfo(dst) == NULL || skb_optinfo(src) == NULL)
+		return;
+
+	/* NOTE: skb_security(x) can't be NULL if skb_optinfo(x) is valid */
+	skbsec_src = skb_security(src);
+	skbsec_dst = skb_security(dst);
+
+	/* check if we are copying the security metadata between clones, we
+	 * may not need this check, but it is cheap insurance */
+	if (skbsec_dst == skbsec_src)
+		return;
+
+	/* copy the security metadata */
+	skbsec_dst->secmark = skbsec_src->secmark;
+}
+
 static void selinux_skb_owned_by(struct sk_buff *skb, struct sock *sk)
 {
 	skb_set_owner_w(skb, sk);
 }
 
+static void selinux_skb_destructor_arg_set(struct sk_buff *skb, void *ptr)
+{
+	struct skb_opt_info *skb_opt = skb_optinfo(skb);
+
+	BUG_ON(skb_opt == NULL);
+	if (skb_opt == NULL)
+		return;
+
+	skb_opt->destructor_arg = ptr;
+}
+
+static void *selinux_skb_destructor_arg_get(const struct sk_buff *skb)
+{
+	struct skb_opt_info *skb_opt = skb_optinfo(skb);
+
+	BUG_ON(skb_opt == NULL);
+	if (skb_opt == NULL)
+		return NULL;
+
+	return skb_opt->destructor_arg;
+}
+
 static void selinux_skb_secmark_set(struct sk_buff *skb, u32 secmark)
 {
-	skb->secmark = secmark;
+	BUG_ON(skb_optinfo(skb) == NULL);
+
+	skb_security(skb)->secmark = secmark;
 }
 
 static u32 selinux_skb_secmark_get(const struct sk_buff *skb)
 {
-	return skb->secmark;
+	BUG_ON(skb_optinfo(skb) == NULL);
+
+	return skb_security(skb)->secmark;
 }
 
 /* Returns error only if unable to parse addresses */
@@ -4120,8 +4200,8 @@ static int selinux_sock_rcv_skb_compat(struct sock *sk, struct sk_buff *skb,
 		return err;
 
 	if (selinux_secmark_enabled()) {
-		err = avc_has_perm(sk_sid, skb->secmark, SECCLASS_PACKET,
-				   PACKET__RECV, &ad);
+		err = avc_has_perm(sk_sid, selinux_skb_secmark_get(skb),
+				   SECCLASS_PACKET, PACKET__RECV, &ad);
 		if (err)
 			return err;
 	}
@@ -4192,8 +4272,8 @@ static int selinux_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	}
 
 	if (secmark_active) {
-		err = avc_has_perm(sk_sid, skb->secmark, SECCLASS_PACKET,
-				   PACKET__RECV, &ad);
+		err = avc_has_perm(sk_sid, selinux_skb_secmark_get(skb),
+				   SECCLASS_PACKET, PACKET__RECV, &ad);
 		if (err)
 			return err;
 	}
@@ -4562,7 +4642,7 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb, int ifindex,
 	}
 
 	if (secmark_active)
-		if (avc_has_perm(peer_sid, skb->secmark,
+		if (avc_has_perm(peer_sid, selinux_skb_secmark_get(skb),
 				 SECCLASS_PACKET, PACKET__FORWARD_IN, &ad))
 			return NF_DROP;
 
@@ -4651,7 +4731,7 @@ static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
 		return NF_DROP;
 
 	if (selinux_secmark_enabled())
-		if (avc_has_perm(sksec->sid, skb->secmark,
+		if (avc_has_perm(sksec->sid, selinux_skb_secmark_get(skb),
 				 SECCLASS_PACKET, PACKET__SEND, &ad))
 			return NF_DROP_ERR(-ECONNREFUSED);
 
@@ -4722,7 +4802,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 		return NF_DROP;
 
 	if (secmark_active)
-		if (avc_has_perm(peer_sid, skb->secmark,
+		if (avc_has_perm(peer_sid, selinux_skb_secmark_get(skb),
 				 SECCLASS_PACKET, secmark_perm, &ad))
 			return NF_DROP_ERR(-ECONNREFUSED);
 
@@ -5680,7 +5760,12 @@ static struct security_operations selinux_ops = {
 	.tun_dev_attach_queue =		selinux_tun_dev_attach_queue,
 	.tun_dev_attach =		selinux_tun_dev_attach,
 	.tun_dev_open =			selinux_tun_dev_open,
+	.skb_alloc =			selinux_skb_alloc,
+	.skb_free =			selinux_skb_free,
+	.skb_security_copy =		selinux_skb_security_copy,
 	.skb_owned_by =			selinux_skb_owned_by,
+	.skb_destructor_arg_set =	selinux_skb_destructor_arg_set,
+	.skb_destructor_arg_get =	selinux_skb_destructor_arg_get,
 	.skb_secmark_set =		selinux_skb_secmark_set,
 	.skb_secmark_get =		selinux_skb_secmark_get,
 
@@ -5734,6 +5819,11 @@ static __init int selinux_init(void)
 	sel_inode_cache = kmem_cache_create("selinux_inode_security",
 					    sizeof(struct inode_security_struct),
 					    0, SLAB_PANIC, NULL);
+	sel_skb_cache = kmem_cache_create("selinux_skb_security",
+					  sizeof(struct skb_opt_info) +
+					   sizeof(struct skb_security_struct),
+					  0, SLAB_PANIC, NULL);
+
 	avc_init();
 
 	if (register_security(&selinux_ops))
diff --git a/security/selinux/include/objsec.h b/security/selinux/include/objsec.h
index aa47bca..7ec3623 100644
--- a/security/selinux/include/objsec.h
+++ b/security/selinux/include/objsec.h
@@ -110,6 +110,12 @@ struct sk_security_struct {
 	u16 sclass;			/* sock security class */
 };
 
+#define skb_security(SKB) \
+	((struct skb_security_struct *)(&(skb_optinfo(SKB)->security)))
+struct skb_security_struct {
+	int secmark;
+};
+
 struct tun_security_struct {
 	u32 sid;			/* SID for the tun device sockets */
 };

