From: Eric Leblond <eric@regit.org>
Subject: [PATCH v2] af-packet: fix oops when socket is not present
Date: Tue,  6 Nov 2012 13:10:10 +0100
Message-ID: <1352203810-957-1-git-send-email-eric@regit.org>
References: <1352201642.3140.880.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stable@vger.kernel.org, Eric Leblond <eric@regit.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:49266 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab2KFMKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 07:10:40 -0500
In-Reply-To: <1352201642.3140.880.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to a NULL dereference, the following patch is causing oops
in normal trafic condition:

commit c0de08d04215031d68fa13af36f347a6cfa252ca
Author: Eric Leblond <eric@regit.org>
Date:=C2=A0=C2=A0 Thu Aug 16 22:02:58 2012 +0000

=C2=A0=C2=A0=C2=A0 af_packet: don't emit packet on orig fanout group

This buggy patch was a feature fix and has reached most stable
branches.

When skb->sk is NULL and when packet fanout is used, there is a
crash in match_fanout_group where skb->sk is accessed.
This patch fixes the issue by returning false as soon as the
socket is NULL: this correspond to the wanted behavior because
the kernel as to resend the skb to all the listening socket in
this case.

Signed-off-by: Eric Leblond <eric@regit.org>
---
 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b4978e2..83232a1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1666,7 +1666,7 @@ static inline int deliver_skb(struct sk_buff *skb=
,
=20
 static inline bool skb_loop_sk(struct packet_type *ptype, struct sk_bu=
ff *skb)
 {
-	if (ptype->af_packet_priv =3D=3D NULL)
+	if (!ptype->af_packet_priv || !skb->sk)
 		return false;
=20
 	if (ptype->id_match)
--=20
1.7.10.4
