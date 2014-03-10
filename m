From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 5/5] skbuff: skb_segment: orphan frags before copying
Date: Mon, 10 Mar 2014 19:28:08 +0200
Message-ID: <1394468807-25980-6-git-send-email-mst@redhat.com>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbenc@redhat.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Simon Horman <horms@verge.net.au>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miklos Szeredi <mszeredi@suse.cz>,
	=?us-ascii?Q?=3D=3Fus-ascii=3FB=3FPT9VVEYtOD9xP1BldGVyPTIwUGFuPTI4PUU2?=
	 =?us-ascii?Q?PUJEPTk4PUU1PThEPUFC=3F=3D_=3D=3Fus-ascii=3FB=3FPUU1PUI5PUIz?=
	 =?us-ascii?Q?PTI5Pz0=3D=3F=3D?= <panweiping3@gmail.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1394468807-25980-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

skb_segment copies frags around, so we need
to copy them carefully to avoid accessing
user memory after reporting completion to userspace
through a callback.

skb_segment doesn't normally happen on datapath:
TSO needs to be disabled - so disabling zero copy
in this case does not look like a big deal.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/skbuff.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 64ee4e6..ae11f78 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2857,6 +2857,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	skb_frag_t *frag = skb_shinfo(head_skb)->frags;
 	unsigned int mss = skb_shinfo(head_skb)->gso_size;
 	unsigned int doffset = head_skb->data - skb_mac_header(head_skb);
+	struct sk_buff *frag_skb = head_skb;
 	unsigned int offset = doffset;
 	unsigned int tnl_hlen = skb_tnl_header_len(head_skb);
 	unsigned int headroom;
@@ -2901,6 +2902,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 			i = 0;
 			nfrags = skb_shinfo(list_skb)->nr_frags;
 			frag = skb_shinfo(list_skb)->frags;
+			frag_skb = list_skb;
 			pos += skb_headlen(list_skb);
 
 			while (pos < offset + len) {
@@ -2988,6 +2990,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 				i = 0;
 				nfrags = skb_shinfo(list_skb)->nr_frags;
 				frag = skb_shinfo(list_skb)->frags;
+				frag_skb = list_skb;
 
 				BUG_ON(!nfrags);
 
@@ -3002,6 +3005,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 				goto err;
 			}
 
+			if (unlikely(skb_orphan_frags(frag_skb, GFP_ATOMIC)))
+				goto err;
+
 			*nskb_frag = *frag;
 			__skb_frag_ref(nskb_frag);
 			size = skb_frag_size(nskb_frag);
-- 
MST
