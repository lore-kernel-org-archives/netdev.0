From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 5/5] caif: Plug memory leak for checksum error
Date: Sun, 22 May 2011 23:18:54 +0200
Message-ID: <1306099134-12989-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:52543 "EHLO pmx.vmail.no"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755368Ab1EVVTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2011 17:19:07 -0400
In-Reply-To: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of checksum error, the framing layer returns -EILSEQ, but
does not free the packet. Plug this hole by freeing the packet if
-EILSEQ is returned.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_dev.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 366ca0f..682c0fe 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -142,6 +142,7 @@ static int receive(struct sk_buff *skb, struct net_=
device *dev,
 {
 	struct cfpkt *pkt;
 	struct caif_device_entry *caifd;
+	int err;
=20
 	pkt =3D cfpkt_fromnative(CAIF_DIR_IN, skb);
=20
@@ -159,7 +160,11 @@ static int receive(struct sk_buff *skb, struct net=
_device *dev,
 	caifd_hold(caifd);
 	rcu_read_unlock();
=20
-	caifd->layer.up->receive(caifd->layer.up, pkt);
+	err =3D caifd->layer.up->receive(caifd->layer.up, pkt);
+
+	/* For -EILSEQ the packet is not freed so so it now */
+	if (err =3D=3D -EILSEQ)
+		cfpkt_destroy(pkt);
=20
 	/* Release reference to stack upwards */
 	caifd_put(caifd);
--=20
1.7.0.4

