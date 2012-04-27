From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 5/5 net-next] net: makes skb_splice_bits() aware of
 skb->head_frag
Date: Fri, 27 Apr 2012 14:10:03 +0200
Message-ID: <1335528603.2775.246.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Tom Herbert <therbert@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:48424 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759994Ab2D0MKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 08:10:11 -0400
Received: by bkuw12 with SMTP id w12so444626bku.19
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2012 05:10:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

__skb_splice_bits() can check if skb to be spliced has its skb->head
mapped to a page fragment, instead of a kmalloc() area.

If so we can avoid a copy of the skb head and get a reference on
underlying page.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 net/core/skbuff.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2ad1ee7..e5bd086 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1699,14 +1699,18 @@ static bool __skb_splice_bits(struct sk_buff *s=
kb, struct pipe_inode_info *pipe,
 			      struct splice_pipe_desc *spd, struct sock *sk)
 {
 	int seg;
+	bool head_is_linear =3D !skb->head_frag;
=20
-	/*
-	 * map the linear part
+	/* map the linear part :
+	 * If skb->head_frag is set, this 'linear' part is backed
+	 * by a fragment, and we can avoid a copy.
 	 */
 	if (__splice_segment(virt_to_page(skb->data),
 			     (unsigned long) skb->data & (PAGE_SIZE - 1),
 			     skb_headlen(skb),
-			     offset, len, skb, spd, true, sk, pipe))
+			     offset, len, skb, spd,
+			     head_is_linear,
+			     sk, pipe))
 		return true;
=20
 	/*
