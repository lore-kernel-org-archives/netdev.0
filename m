From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next 1/4 v5] pktgen: Fill the payload optionally with a pattern
Date: Wed, 30 Jul 2014 17:20:09 +0100
Message-ID: <1406737212-23351-2-git-send-email-zoltan.kiss@citrix.com>
References: <1406737212-23351-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Joe Perches <joe@perches.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Mathias Krause <minipli@googlemail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406737212-23351-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduces a new flag called PATTERN, which puts a non-periodic, predicatble
pattern into the payload. This was useful to reproduce an otherwise intermittent
bug in xen-netback [1], where checksum checking doesn't help.
The pattern is a repetition of "%lu ", a series of increasing numbers divided by
space. The value of the number is the size of the preceding payload area. E.g.
"1 3 5 "..." 1000 1005 1010"
If the pattern is used, every frag will have its own page, unlike before, so it
needs more memory.

[1] 5837574: xen-netback: Fix grant ref resolution in RX path

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Joe Perches <joe@perches.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
---
v2: some bugfixes for pattern_to_packet, as my upcoming patch revealed some

v3:
- move the space in the pattern after the number, it just feels more intuitive
- show this setting when the flags are queried

v4:
- keep the zero flag always

v5:
- indentation fix
- fix handling *incomplete in pattern_to_packet()

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8b849dd..ab30856 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -202,6 +202,7 @@
 #define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id() */
 #define F_NODE          (1<<15)	/* Node memory alloc*/
 #define F_UDPCSUM       (1<<16)	/* Include UDP checksum */
+#define F_PATTERN       (1<<17)	/* Fill the payload with a pattern */
 
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -257,7 +258,7 @@ struct pktgen_dev {
 	int max_pkt_size;
 	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
 	int nfrags;
-	struct page *page;
+	struct page *pages[MAX_SKB_FRAGS];
 	u64 delay;		/* nano-seconds */
 
 	__u64 count;		/* Default No packets to send */
@@ -638,6 +639,9 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 	if (pkt_dev->flags & F_UDPCSUM)
 		seq_puts(seq, "UDPCSUM  ");
 
+	if (pkt_dev->flags & F_PATTERN)
+		seq_puts(seq, "PATTERN  ");
+
 	if (pkt_dev->flags & F_MPLS_RND)
 		seq_puts(seq,  "MPLS_RND  ");
 
@@ -1128,12 +1132,14 @@ static ssize_t pktgen_if_write(struct file *file,
 		i += len;
 
 		if (node_possible(value)) {
+			int j;
 			pkt_dev->node = value;
 			sprintf(pg_result, "OK: node=%d", pkt_dev->node);
-			if (pkt_dev->page) {
-				put_page(pkt_dev->page);
-				pkt_dev->page = NULL;
-			}
+			for (j = 0; j < MAX_SKB_FRAGS; ++j)
+				if (pkt_dev->pages[j]) {
+					put_page(pkt_dev->pages[j]);
+					pkt_dev->pages[j] = NULL;
+				}
 		}
 		else
 			sprintf(pg_result, "ERROR: node not possible");
@@ -1243,6 +1249,12 @@ static ssize_t pktgen_if_write(struct file *file,
 		else if (strcmp(f, "!UDPCSUM") == 0)
 			pkt_dev->flags &= ~F_UDPCSUM;
 
+		else if (strcmp(f, "PATTERN") == 0)
+			pkt_dev->flags |= F_PATTERN;
+
+		else if (strcmp(f, "!PATTERN") == 0)
+			pkt_dev->flags &= ~F_PATTERN;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):\n%s",
@@ -2624,17 +2636,101 @@ static inline __be16 build_tci(unsigned int id, unsigned int cfi,
 	return htons(id | (cfi << 12) | (prio << 13));
 }
 
+/* Max number of digits. The sizeof equals to log base 2^8 (UINT_MAX), multiply
+ * with 3 is a cheap, rounded up conversion to log10
+ */
+#define UINT_MAX_DIGITS (3*sizeof(unsigned long)+1)
+
+/* Fill the buffer up with a pattern
+ * buf - pointer to buffer
+ * bufsize - size of the buffer
+ * start - starting value for the pattern
+ * incomplete - pointer to the offset inside the pattern, or 0 if none
+ *
+ * The pattern is a repetition of " %lu", a series of increasing numbers divided
+ * by space. The value of the number is "start" plus the size of the preceding
+ * space. E.g. if start is 1000, it starts like " 1000 1005 1010".
+ * If the last number doesn't fit, it gets truncated, and the number of leading
+ * characters is saved into incomplete. It can be passed then to the next call
+ * with the next buffer, and the pattern looks contiguous over scattered
+ * buffers.
+ * It returns "start" plus the offset of the byte after the last full
+ * pattern write.
+ */
+static unsigned long pattern_to_packet(char *buf,
+				       int bufsize,
+				       unsigned long start,
+				       unsigned int *incomplete)
+{
+	int len;
+	/* Only used when the pattern doesn't align to the buffer */
+	char temp[UINT_MAX_DIGITS];
+
+	if (*incomplete) {
+		int copylen, offset = *incomplete;
+
+		len = snprintf(temp, sizeof(temp), "%lu ", start);
+		copylen = len - *incomplete;
+		if (copylen > bufsize) {
+			/* The continuation of this number couldn't fit here */
+			copylen = bufsize;
+			*incomplete += bufsize;
+		} else {
+			*incomplete = 0;
+			start += len;
+		}
+		BUG_ON(offset + copylen > sizeof(temp));
+		memcpy(buf, temp + offset, copylen);
+		bufsize -= copylen;
+		buf += copylen;
+	}
+
+	while (bufsize > 0) {
+		BUG_ON(*incomplete);
+		len = snprintf(buf, bufsize, " %lu", start);
+		/* The last number doesn't fit, remember where it was truncated.
+		 */
+		if (len >= bufsize) {
+			/* snprintf always add a trailing zero, but actually we
+			 * need the last digit there
+			 */
+			len = snprintf(temp, sizeof(temp), " %lu", start);
+			memcpy(buf, temp, bufsize);
+			/* If the last number just fit without the trailing
+			 * zero, the next buffer can continue from an increased
+			 * offset.
+			 */
+			if (len == bufsize)
+				start += len;
+			else
+				*incomplete = bufsize;
+			return start;
+		}
+		bufsize -= len;
+		start += len;
+		buf += len;
+	}
+	return start;
+}
+
 static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 				int datalen)
 {
 	struct timeval timestamp;
 	struct pktgen_hdr *pgh;
+	unsigned long offset = 0;
+	unsigned int incomplete = 0;
 
 	pgh = (struct pktgen_hdr *)skb_put(skb, sizeof(*pgh));
 	datalen -= sizeof(*pgh);
 
 	if (pkt_dev->nfrags <= 0) {
-		memset(skb_put(skb, datalen), 0, datalen);
+		if (pkt_dev->flags & F_PATTERN)
+			offset = pattern_to_packet(skb_put(skb, datalen),
+						   datalen, offset,
+						   &incomplete);
+		else
+			memset(skb_put(skb, datalen), 0, datalen);
 	} else {
 		int frags = pkt_dev->nfrags;
 		int i, len;
@@ -2645,7 +2741,12 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 			frags = MAX_SKB_FRAGS;
 		len = datalen - frags * PAGE_SIZE;
 		if (len > 0) {
-			memset(skb_put(skb, len), 0, len);
+			if (pkt_dev->flags & F_PATTERN)
+				offset = pattern_to_packet(skb_put(skb, len),
+							   len, offset,
+							   &incomplete);
+			else
+				memset(skb_put(skb, len), 0, len);
 			datalen = frags * PAGE_SIZE;
 		}
 
@@ -2653,17 +2754,27 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 		frag_len = (datalen/frags) < PAGE_SIZE ?
 			   (datalen/frags) : PAGE_SIZE;
 		while (datalen > 0) {
-			if (unlikely(!pkt_dev->page)) {
+			int fragpage;
+			gfp_t flags = GFP_KERNEL | __GFP_ZERO;
+
+			if (pkt_dev->flags & F_PATTERN)
+				fragpage = i;
+			else
+				fragpage = 0;
+
+			if (unlikely(!pkt_dev->pages[fragpage])) {
 				int node = numa_node_id();
 
 				if (pkt_dev->node >= 0 && (pkt_dev->flags & F_NODE))
 					node = pkt_dev->node;
-				pkt_dev->page = alloc_pages_node(node, GFP_KERNEL | __GFP_ZERO, 0);
-				if (!pkt_dev->page)
+				pkt_dev->pages[fragpage] =
+					alloc_pages_node(node, flags, 0);
+				if (!pkt_dev->pages[fragpage])
 					break;
 			}
-			get_page(pkt_dev->page);
-			skb_frag_set_page(skb, i, pkt_dev->page);
+			get_page(pkt_dev->pages[fragpage]);
+			skb_frag_set_page(skb, i, pkt_dev->pages[fragpage]);
+
 			skb_shinfo(skb)->frags[i].page_offset = 0;
 			/*last fragment, fill rest of data*/
 			if (i == (frags - 1))
@@ -2672,6 +2783,10 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 			else
 				skb_frag_size_set(&skb_shinfo(skb)->frags[i], frag_len);
 			datalen -= skb_frag_size(&skb_shinfo(skb)->frags[i]);
+			if (pkt_dev->flags & F_PATTERN)
+				offset = pattern_to_packet(skb_frag_address(&skb_shinfo(skb)->frags[i]),
+							   skb_frag_size(&skb_shinfo(skb)->frags[i]),
+							   offset, &incomplete);
 			skb->len += skb_frag_size(&skb_shinfo(skb)->frags[i]);
 			skb->data_len += skb_frag_size(&skb_shinfo(skb)->frags[i]);
 			i++;
@@ -3681,6 +3796,8 @@ static void _rem_dev_from_if_list(struct pktgen_thread *t,
 static int pktgen_remove_device(struct pktgen_thread *t,
 				struct pktgen_dev *pkt_dev)
 {
+	int i;
+
 	pr_debug("remove_device pkt_dev=%p\n", pkt_dev);
 
 	if (pkt_dev->running) {
@@ -3708,8 +3825,9 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 	free_SAs(pkt_dev);
 #endif
 	vfree(pkt_dev->flows);
-	if (pkt_dev->page)
-		put_page(pkt_dev->page);
+	for (i = 0; i < MAX_SKB_FRAGS; ++i)
+		if (pkt_dev->pages[i])
+			put_page(pkt_dev->pages[i]);
 	kfree_rcu(pkt_dev, rcu);
 	return 0;
 }
