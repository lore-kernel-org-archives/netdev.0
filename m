From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 07/10] net: only allow paged fragments with the same destructor to be coalesced.
Date: Tue, 10 Apr 2012 15:26:21 +0100
Message-ID: <1334067984-7706-7-git-send-email-ian.campbell@citrix.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xen.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:3234 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754409Ab2DJOcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 10:32:41 -0400
In-Reply-To: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
---
 include/linux/skbuff.h |    7 +++++--
 net/core/skbuff.c      |    1 +
 net/ipv4/ip_output.c   |    2 +-
 net/ipv4/tcp.c         |    4 ++--
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6ac283e..8593ac2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2014,13 +2014,16 @@ static inline int skb_add_data(struct sk_buff *=
skb,
 }
=20
 static inline int skb_can_coalesce(struct sk_buff *skb, int i,
-				   const struct page *page, int off)
+				   const struct page *page,
+				   const struct skb_frag_destructor *destroy,
+				   int off)
 {
 	if (i) {
 		const struct skb_frag_struct *frag =3D &skb_shinfo(skb)->frags[i - 1=
];
=20
 		return page =3D=3D skb_frag_page(frag) &&
-		       off =3D=3D frag->page_offset + skb_frag_size(frag);
+		       off =3D=3D frag->page_offset + skb_frag_size(frag) &&
+		       frag->page.destructor =3D=3D destroy;
 	}
 	return 0;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9ec88ce..e63a4a6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2323,6 +2323,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff=
 *skb, int shiftlen)
 	 */
 	if (!to ||
 	    !skb_can_coalesce(tgt, to, skb_frag_page(fragfrom),
+			      fragfrom->page.destructor,
 			      fragfrom->page_offset)) {
 		merge =3D -1;
 	} else {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index ff302bd..9e4eca6 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1243,7 +1243,7 @@ ssize_t	ip_append_page(struct sock *sk, struct fl=
owi4 *fl4, struct page *page,
 		i =3D skb_shinfo(skb)->nr_frags;
 		if (len > size)
 			len =3D size;
-		if (skb_can_coalesce(skb, i, page, offset)) {
+		if (skb_can_coalesce(skb, i, page, NULL, offset)) {
 			skb_frag_size_add(&skb_shinfo(skb)->frags[i-1], len);
 		} else if (i < MAX_SKB_FRAGS) {
 			get_page(page);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index cfd7edd..b1612e9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -804,7 +804,7 @@ new_segment:
 			copy =3D size;
=20
 		i =3D skb_shinfo(skb)->nr_frags;
-		can_coalesce =3D skb_can_coalesce(skb, i, page, offset);
+		can_coalesce =3D skb_can_coalesce(skb, i, page, NULL, offset);
 		if (!can_coalesce && i >=3D MAX_SKB_FRAGS) {
 			tcp_mark_push(tp, skb);
 			goto new_segment;
@@ -1013,7 +1013,7 @@ new_segment:
=20
 				off =3D sk->sk_sndmsg_off;
=20
-				if (skb_can_coalesce(skb, i, page, off) &&
+				if (skb_can_coalesce(skb, i, page, NULL, off) &&
 				    off !=3D PAGE_SIZE) {
 					/* We can extend the last page
 					 * fragment. */
--=20
1.7.2.5
