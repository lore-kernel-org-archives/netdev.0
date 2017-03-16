From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 1/2] batman-adv: Keep fragments equally sized
Date: Thu, 16 Mar 2017 13:55:11 +0100
Message-ID: <20170316125512.30364-2-sw@simonwunderlich.de>
References: <20170316125512.30364-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170316125512.30364-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

The batman-adv fragmentation packets have the design problem that they
cannot be refragmented and cannot handle padding by the underlying link.
The latter often leads to problems when networks are incorrectly configured
and don't use a common MTU.

The sender could for example fragment a 1271 byte frame (plus external
ethernet header (14) and batadv unicast header (10)) to fit in a 1280 bytes
large MTU of the underlying link (max. 1294 byte frames). This would create
a 1294 bytes large frame (fragment 2) and a 55 bytes large frame
(fragment 1). The extra 54 bytes are the fragment header (20) added to each
fragment and the external ethernet header (14) for the second fragment.

Let us assume that the next hop is then not able to transport 1294 bytes to
its next hop. The 1294 byte large frame will be dropped but the 55 bytes
large fragment will still be forwarded to its destination.

Or let us assume that the underlying hardware requires that each frame has
a minimum size (e.g. 60 bytes). Then it will pad the 55 bytes frame to 60
bytes. The receiver of the 60 bytes frame will no longer be able to
correctly assemble the two frames together because it is not aware that 5
bytes of the 60 bytes frame are padding and don't belong to the reassembled
frame.

This can partly be avoided by splitting frames more equally. In this
example, the 675 and 674 bytes large fragment frames could both potentially
reach its destination without being too large or too small.

Reported-by: Martin Weinelt <martin-VjL1Zewfs7ir2odhgoY7gCae+QG6wtwz@public.gmane.org>
Fixes: ee75ed88879a ("batman-adv: Fragment and send skbs larger than mtu")
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Acked-by: Linus Lüssing <linus.luessing-djzkFPsfvsizQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/fragmentation.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 11149e5be4e0..106bda56ec98 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -404,7 +404,7 @@ bool batadv_frag_skb_fwd(struct sk_buff *skb,
  * batadv_frag_create - create a fragment from skb
  * @skb: skb to create fragment from
  * @frag_head: header to use in new fragment
- * @mtu: size of new fragment
+ * @fragment_size: size of new fragment
  *
  * Split the passed skb into two fragments: A new one with size matching the
  * passed mtu and the old one with the rest. The new skb contains data from the
@@ -414,11 +414,11 @@ bool batadv_frag_skb_fwd(struct sk_buff *skb,
  */
 static struct sk_buff *batadv_frag_create(struct sk_buff *skb,
 					  struct batadv_frag_packet *frag_head,
-					  unsigned int mtu)
+					  unsigned int fragment_size)
 {
 	struct sk_buff *skb_fragment;
 	unsigned int header_size = sizeof(*frag_head);
-	unsigned int fragment_size = mtu - header_size;
+	unsigned int mtu = fragment_size + header_size;
 
 	skb_fragment = netdev_alloc_skb(NULL, mtu + ETH_HLEN);
 	if (!skb_fragment)
@@ -456,7 +456,7 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 	struct sk_buff *skb_fragment;
 	unsigned int mtu = neigh_node->if_incoming->net_dev->mtu;
 	unsigned int header_size = sizeof(frag_header);
-	unsigned int max_fragment_size, max_packet_size;
+	unsigned int max_fragment_size, num_fragments;
 	int ret;
 
 	/* To avoid merge and refragmentation at next-hops we never send
@@ -464,10 +464,15 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 	 */
 	mtu = min_t(unsigned int, mtu, BATADV_FRAG_MAX_FRAG_SIZE);
 	max_fragment_size = mtu - header_size;
-	max_packet_size = max_fragment_size * BATADV_FRAG_MAX_FRAGMENTS;
+
+	if (skb->len == 0 || max_fragment_size == 0)
+		return -EINVAL;
+
+	num_fragments = (skb->len - 1) / max_fragment_size + 1;
+	max_fragment_size = (skb->len - 1) / num_fragments + 1;
 
 	/* Don't even try to fragment, if we need more than 16 fragments */
-	if (skb->len > max_packet_size) {
+	if (num_fragments > BATADV_FRAG_MAX_FRAGMENTS) {
 		ret = -EAGAIN;
 		goto free_skb;
 	}
@@ -507,7 +512,8 @@ int batadv_frag_send_packet(struct sk_buff *skb,
 			goto put_primary_if;
 		}
 
-		skb_fragment = batadv_frag_create(skb, &frag_header, mtu);
+		skb_fragment = batadv_frag_create(skb, &frag_header,
+						  max_fragment_size);
 		if (!skb_fragment) {
 			ret = -ENOMEM;
 			goto put_primary_if;
-- 
2.11.0
