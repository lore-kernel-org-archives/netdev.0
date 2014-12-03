From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: use MAX_HEADER for headroom reserve in output path
Date: Wed,  3 Dec 2014 12:13:58 +0100
Message-ID: <1417605238-9936-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	robert@swiecki.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982AbaLCLOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 06:14:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To accomodate for enough headroom for tunnels, use MAX_HEADER instead
of LL_MAX_HEADER. Robert reported that he has hit after roughly 40hrs
of trinity an skb_under_panic() via SCTP output path (see reference).
I couldn't reproduce it from here, but not using MAX_HEADER as elsewher=
e
in other protocols might be one possible cause for this.

In any case, it looks like accounting on chunks themself seems to look
good as the skb already passed the SCTP output path and did not hit
any skb_over_panic(). Given tunneling was enabled in his .config, the
headroom would have been expanded by MAX_HEADER in this case.

Reported-by: Robert =C5=9Awi=C4=99cki <robert@swiecki.net>
Reference: https://lkml.org/lkml/2014/12/1/507
=46ixes: 594ccc14dfe4d ("[SCTP] Replace incorrect use of dev_alloc_skb =
with alloc_skb in sctp_packet_transmit().")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/output.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 42dffd4..fc5e45b 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -401,12 +401,12 @@ int sctp_packet_transmit(struct sctp_packet *pack=
et)
 	sk =3D chunk->skb->sk;
=20
 	/* Allocate the new skb.  */
-	nskb =3D alloc_skb(packet->size + LL_MAX_HEADER, GFP_ATOMIC);
+	nskb =3D alloc_skb(packet->size + MAX_HEADER, GFP_ATOMIC);
 	if (!nskb)
 		goto nomem;
=20
 	/* Make sure the outbound skb has enough header room reserved. */
-	skb_reserve(nskb, packet->overhead + LL_MAX_HEADER);
+	skb_reserve(nskb, packet->overhead + MAX_HEADER);
=20
 	/* Set the owning socket so that we know where to get the
 	 * destination IP address.
--=20
1.7.11.7
