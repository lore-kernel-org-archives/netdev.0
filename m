From: Pieter Smith <pieter@boesman.nl>
Subject: [PATCH 5/6] net/core: support compiling out splice
Date: Sat, 22 Nov 2014 22:00:00 +0100
Message-ID: <1416690001-20817-6-git-send-email-pieter@boesman.nl>
References: <1416690001-20817-1-git-send-email-pieter@boesman.nl>
Cc: Josh Triplett <josh@joshtriplett.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Willem de Bruijn <willemb@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, Jan Beulich <JBeulich@suse.com>,
	Miklos Szeredi <mszeredi@suse.cz>,
	linux-kernel@vger.kernel.org (open list),
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL])
To: pieter@boesman.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416690001-20817-1-git-send-email-pieter@boesman.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compile out splice support from networking core when the splice-family of
syscalls is not supported by the system (i.e. CONFIG_SYSCALL_SPLICE is
undefined).

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 include/linux/skbuff.h | 9 +++++++++
 net/core/skbuff.c      | 9 ++++++---
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index a59d934..8c28524 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2640,9 +2640,18 @@ int skb_copy_bits(const struct sk_buff *skb, int offset, void *to, int len);
 int skb_store_bits(struct sk_buff *skb, int offset, const void *from, int len);
 __wsum skb_copy_and_csum_bits(const struct sk_buff *skb, int offset, u8 *to,
 			      int len, __wsum csum);
+#ifdef CONFIG_SYSCALL_SPLICE
 int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int len,
 		    unsigned int flags);
+#else /* #ifdef CONFIG_SYSCALL_SPLICE */
+static inline int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
+		    struct pipe_inode_info *pipe, unsigned int len,
+		    unsigned int flags)
+{
+	return -EPERM;
+}
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
 void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to);
 unsigned int skb_zerocopy_headlen(const struct sk_buff *from);
 int skb_zerocopy(struct sk_buff *to, struct sk_buff *from,
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 61059a0..74fad8a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1781,9 +1781,9 @@ static bool __splice_segment(struct page *page, unsigned int poff,
  * Map linear and fragment data from the skb to spd. It reports true if the
  * pipe is full or if we already spliced the requested length.
  */
-static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
-			      unsigned int *offset, unsigned int *len,
-			      struct splice_pipe_desc *spd, struct sock *sk)
+static bool __maybe_unused __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
+					     unsigned int *offset, unsigned int *len,
+					     struct splice_pipe_desc *spd, struct sock *sk)
 {
 	int seg;
 
@@ -1821,6 +1821,7 @@ static bool __skb_splice_bits(struct sk_buff *skb, struct pipe_inode_info *pipe,
  * the frag list, if such a thing exists. We'd probably need to recurse to
  * handle that cleanly.
  */
+#ifdef CONFIG_SYSCALL_SPLICE
 int skb_splice_bits(struct sk_buff *skb, unsigned int offset,
 		    struct pipe_inode_info *pipe, unsigned int tlen,
 		    unsigned int flags)
@@ -1876,6 +1877,8 @@ done:
 
 	return ret;
 }
+#endif /* #ifdef CONFIG_SYSCALL_SPLICE */
+
 
 /**
  *	skb_store_bits - store bits from kernel buffer to skb
-- 
1.9.1
