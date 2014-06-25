From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next] pktgen: Allow setting frag sizes individually
Date: Wed, 25 Jun 2014 21:42:51 +0100
Message-ID: <1403728972-29548-3-git-send-email-zoltan.kiss@citrix.com>
References: <1403728972-29548-1-git-send-email-zoltan.kiss@citrix.com>
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
In-Reply-To: <1403728972-29548-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By defining the number of frags via "nfrags", their sizes get calculated by
pktgen. This patch allows their offsets and sizes to be specified via
"frag_off-len", in a comma separated list (e.g.
"frag_off-len 0-1,500-200,5000-10,9-100). The first is the offset
(0 <= offset < 2^16), second is size (0 < length <= 65536). This also determines
the number of frags, so it overwrites "frags" (and vice versa, "frags"
invalidate this setting)
xen-netback is prone to have problem with compound pages, as the memory granting
interface can only handle 4k pages. This extension of pktgen is proven to be
useful to test that.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Joe Perches <joe@perches.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
---
 net/core/pktgen.c |  134 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 127 insertions(+), 7 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 23b3a58..b8090a0 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -235,6 +235,11 @@ struct flow_state {
 /* flow flag bits */
 #define F_INIT   (1<<0)		/* flow has been initialized */
 
+struct frag_param {
+	int offset;
+	int length;
+};
+
 struct pktgen_dev {
 	/*
 	 * Try to keep frequent/infrequent used vars. separated.
@@ -256,6 +261,11 @@ struct pktgen_dev {
 	int max_pkt_size;
 	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
 	int nfrags;
+	/* offset-length pairs for the frags, only the first nfrags are valid,
+	 * and only if frags[0].length != 0, as zero frag size is not valid
+	 * (and neither negative)
+	 */
+	struct frag_param frags[MAX_SKB_FRAGS];
 	struct page *pages[MAX_SKB_FRAGS];
 	u64 delay;		/* nano-seconds */
 
@@ -539,6 +549,18 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 		   pkt_dev->nfrags, (unsigned long long) pkt_dev->delay,
 		   pkt_dev->clone_skb, pkt_dev->odevname);
 
+	if (pkt_dev->frags[0].length) {
+		int n;
+
+		for (n = 0; n < pkt_dev->nfrags; n++)
+			seq_printf(seq, "     %d. offset: %d length: %d%s\n", n,
+				   pkt_dev->frags[n].offset,
+				   pkt_dev->frags[n].length,
+				   n == pkt_dev->nfrags-1 ? "" : ",");
+	} else {
+			seq_printf(seq, "     No frag parameters defined\n");
+	}
+
 	seq_printf(seq, "     flows: %u flowlen: %u\n", pkt_dev->cflows,
 		   pkt_dev->lflow);
 
@@ -844,6 +866,50 @@ static ssize_t get_labels(const char __user *buffer, struct pktgen_dev *pkt_dev)
 	return i;
 }
 
+static ssize_t get_sizes(const char __user *buffer, struct pktgen_dev *pkt_dev)
+{
+	unsigned int n = 0;
+	char c;
+	ssize_t i = 0;
+	int len;
+
+	pkt_dev->nfrags = 0;
+	do {
+		unsigned long tmp;
+
+		len = num_arg(&buffer[i], 5, &tmp);
+		if (len <= 0)
+			return len;
+		/* Maximum skb size minus 1 */
+		if (tmp >= 65536)
+			return -EINVAL;
+		pkt_dev->frags[n].offset = tmp;
+		i += len;
+		if (get_user(c, &buffer[i]))
+			return -EFAULT;
+		if (c != '-')
+			return -EINVAL;
+		i++;
+
+		len = num_arg(&buffer[i], 5, &tmp);
+		if (len <= 0)
+			return len;
+		if (tmp < 1 || tmp > 65536)
+			return -EINVAL;
+		pkt_dev->frags[n].length = tmp;
+		i += len;
+		if (get_user(c, &buffer[i]))
+			return -EFAULT;
+		i++;
+		n++;
+		if (n > MAX_SKB_FRAGS)
+			return -E2BIG;
+	} while (c == ',');
+
+	pkt_dev->nfrags = n;
+	return i;
+}
+
 static ssize_t pktgen_if_write(struct file *file,
 			       const char __user * user_buffer, size_t count,
 			       loff_t * offset)
@@ -971,9 +1037,30 @@ static ssize_t pktgen_if_write(struct file *file,
 
 		i += len;
 		pkt_dev->nfrags = value;
+		/* Invalidate whatever was specified before */
+		pkt_dev->frags[0].length = 0;
 		sprintf(pg_result, "OK: frags=%u", pkt_dev->nfrags);
 		return count;
 	}
+
+	if (!strcmp(name, "frag_off-len")) {
+		unsigned int n, cnt;
+
+		len = get_sizes(&user_buffer[i], pkt_dev);
+		if (len < 0)
+			return len;
+		i += len;
+		cnt = sprintf(pg_result, "OK: frags=%u frag offsets-sizes=",
+			      pkt_dev->nfrags);
+		for (n = 0; n < pkt_dev->nfrags; n++)
+			cnt += sprintf(pg_result + cnt, "%d-%d%s",
+				       pkt_dev->frags[n].offset,
+				       pkt_dev->frags[n].length,
+				       n == pkt_dev->nfrags-1 ? "" : ",");
+
+		return count;
+	}
+
 	if (!strcmp(name, "delay")) {
 		len = num_arg(&user_buffer[i], 10, &value);
 		if (len < 0)
@@ -2730,12 +2817,24 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 	} else {
 		int frags = pkt_dev->nfrags;
 		int i, len;
-		int frag_len;
+		int frag_len = 0;
 
 
 		if (frags > MAX_SKB_FRAGS)
 			frags = MAX_SKB_FRAGS;
-		len = datalen - frags * PAGE_SIZE;
+
+		if (pkt_dev->frags[0].length) {
+			for (i = 0; i < frags; ++i)
+				frag_len += pkt_dev->frags[i].length;
+			if (frag_len > datalen) {
+				pr_err("Payload length (%d) smaller than frags (%d)\n",
+				       datalen, frag_len);
+				return;
+			}
+		} else
+			frag_len = frags * PAGE_SIZE;
+
+		len = datalen - frag_len;
 		if (len > 0) {
 			if (pkt_dev->flags & F_PATTERN)
 				offset = pattern_to_packet(skb_put(skb, len),
@@ -2743,29 +2842,44 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 							   &incomplete);
 			else
 				memset(skb_put(skb, len), 0, len);
-			datalen = frags * PAGE_SIZE;
+			datalen = frag_len;
 		}
 
 		i = 0;
 		frag_len = (datalen/frags) < PAGE_SIZE ?
 			   (datalen/frags) : PAGE_SIZE;
 		while (datalen > 0) {
-			int fragpage;
+			int fragpage, order = 0;
 			gfp_t flags = GFP_KERNEL;
 
-			if (pkt_dev->flags & F_PATTERN) {
+			if (pkt_dev->flags & F_PATTERN ||
+			    pkt_dev->frags[0].length) {
 				fragpage = i;
 			} else {
 				fragpage = 0;
 				flags |= __GFP_ZERO;
 			}
 
+			/* Free this page if we gonna need a compound one */
+			if (pkt_dev->frags[0].length) {
+				int max_off = pkt_dev->frags[i].offset +
+					      pkt_dev->frags[i].length;
+				order = get_order(max_off);
+				if (order) {
+					flags |= __GFP_COMP;
+					if (pkt_dev->pages[fragpage]) {
+						put_page(pkt_dev->pages[i]);
+						pkt_dev->pages[i] = NULL;
+					}
+				}
+			}
+
 			if (unlikely(!pkt_dev->pages[fragpage])) {
 				int node = numa_node_id();
 
 				if (pkt_dev->node >= 0 && (pkt_dev->flags & F_NODE))
 					node = pkt_dev->node;
-				pkt_dev->pages[fragpage] = alloc_pages_node(node, flags, 0);
+				pkt_dev->pages[fragpage] = alloc_pages_node(node, flags, order);
 				if (!pkt_dev->pages[fragpage])
 					break;
 			}
@@ -2773,8 +2887,14 @@ static void pktgen_finalize_skb(struct pktgen_dev *pkt_dev, struct sk_buff *skb,
 			skb_frag_set_page(skb, i, pkt_dev->pages[fragpage]);
 
 			skb_shinfo(skb)->frags[i].page_offset = 0;
+			if (pkt_dev->frags[0].length) {
+				skb_shinfo(skb)->frags[i].page_offset =
+					pkt_dev->frags[i].offset;
+				skb_frag_size_set(&skb_shinfo(skb)->frags[i],
+				                  pkt_dev->frags[i].length);
+			}
 			/*last fragment, fill rest of data*/
-			if (i == (frags - 1))
+			else if (i == (frags - 1))
 				skb_frag_size_set(&skb_shinfo(skb)->frags[i],
 				    (datalen < PAGE_SIZE ? datalen : PAGE_SIZE));
 			else
