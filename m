From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net 2/2] caif: Remove bad WARN_ON in caif_dev
Date: Tue, 17 Jan 2012 14:03:14 +0100
Message-ID: <1326805394-2662-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1326805394-2662-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:35509 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752767Ab2AQNDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 08:03:30 -0500
Received: by lahc1 with SMTP id c1so1502868lah.19
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 05:03:28 -0800 (PST)
In-Reply-To: <1326805394-2662-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove WARN_ON and bad handling of SKB without destructor callback
in caif_flow_cb. SKB without destructor cannot be handled as an
error case.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_dev.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 61570ee..673728a 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -146,15 +146,17 @@ void caif_flow_cb(struct sk_buff *skb)
 	spin_lock_bh(&caifd->flow_lock);
 	send_xoff =3D caifd->xoff;
 	caifd->xoff =3D 0;
-	if (!WARN_ON(caifd->xoff_skb_dtor =3D=3D NULL)) {
-		WARN_ON(caifd->xoff_skb !=3D skb);
-		dtor =3D caifd->xoff_skb_dtor;
-		caifd->xoff_skb =3D NULL;
-		caifd->xoff_skb_dtor =3D NULL;
-	}
+	dtor =3D caifd->xoff_skb_dtor;
+
+	if (WARN_ON(caifd->xoff_skb !=3D skb))
+		skb =3D NULL;
+
+	caifd->xoff_skb =3D NULL;
+	caifd->xoff_skb_dtor =3D NULL;
+
 	spin_unlock_bh(&caifd->flow_lock);
=20
-	if (dtor)
+	if (dtor && skb)
 		dtor(skb);
=20
 	if (send_xoff)
--=20
1.7.1
