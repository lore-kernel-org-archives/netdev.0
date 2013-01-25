From: Alex Bligh <alex@alex.org.uk>
Subject: [RFC] [PATCH 2/7] net: only allow paged fragments with the same destructor to be coalesced.
Date: Fri, 25 Jan 2013 14:27:02 +0000
Message-ID: <1359124027-1170-3-git-send-email-alex@alex.org.uk>
References: <1359124027-1170-1-git-send-email-alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Alex Bligh <alex@alex.org.uk>,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>,
	Mel Gorman <mgorman@suse.de>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:60116 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670Ab3AYOh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 09:37:56 -0500
In-Reply-To: <1359124027-1170-1-git-send-email-alex@alex.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ian Campbell <ian.campbell at>

Signed-off-by: Ian Campbell <ian.campbell <at> citrix.com>
Cc: "David S. Miller" <davem <at> davemloft.net>
Cc: Alexey Kuznetsov <kuznet <at> ms2.inr.ac.ru>
Cc: "Pekka Savola (ipv6)" <pekkas <at> netcore.fi>
Cc: James Morris <jmorris <at> namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji <at> linux-ipv6.org>
Cc: Patrick McHardy <kaber <at> trash.net>
Cc: Eric Dumazet <eric.dumazet <at> gmail.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux <at> rere.qmqm.pl>
Cc: netdev <at> vger.kernel.org
Signed-off-by: Alex Bligh <alex@alex.org.uk>
---
 include/linux/skbuff.h |    7 +++++--
 net/core/skbuff.c      |    1 +
 net/ipv4/ip_output.c   |    2 +-
 net/ipv4/tcp.c         |    4 ++--
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2619a61..8a8eecd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1970,13 +1970,16 @@ static inline int skb_add_data(struct sk_buff *=
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
+		       off =3D=3D frag->page_offset + skb_frag_size(frag) &&=20
+		       frag->page.destructor =3D=3D destroy;
 	}
 	return 0;
 }
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8b46cad..425cd5a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2276,6 +2276,7 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff=
 *skb, int shiftlen)
 	 */
 	if (!to ||
 	    !skb_can_coalesce(tgt, to, skb_frag_page(fragfrom),
+			      fragfrom->page.destructor,
 			      fragfrom->page_offset)) {
 		merge =3D -1;
 	} else {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0bc95f3..3252e06 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1229,7 +1229,7 @@ ssize_t	ip_append_page(struct sock *sk, struct fl=
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
index 34f5db1..018de0c 100644
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
@@ -1008,7 +1008,7 @@ new_segment:
 				struct page *page =3D TCP_PAGE(sk);
 				int off =3D TCP_OFF(sk);
=20
-				if (skb_can_coalesce(skb, i, page, off) &&
+				if (skb_can_coalesce(skb, i, page, NULL, off) &&
 				    off !=3D PAGE_SIZE) {
 					/* We can extend the last page
 					 * fragment. */
--=20
1.7.9.5
