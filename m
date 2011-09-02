From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH]  caif: fix a potential NULL dereference
Date: Fri, 02 Sep 2011 14:19:23 +0200
Message-ID: <1314965963.2573.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110902080716.GF2430@shale.localdomain>
	 <CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Sjur =?ISO-8859-1?Q?Br=E6ndeland?= <sjurbren@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46888 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860Ab1IBMTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 08:19:22 -0400
Received: by wwf5 with SMTP id 5so2863225wwf.1
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2011 05:19:21 -0700 (PDT)
In-Reply-To: <CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit bd30ce4bc0b7 (caif: Use RCU instead of spin-lock in caif_dev.c)
added a potential NULL dereference in case alloc_percpu() fails.

caif_device_alloc() can also use GFP_KERNEL instead of GFP_ATOMIC.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_dev.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 7c2fa0a..7f9ac07 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -93,10 +93,14 @@ static struct caif_device_entry *caif_device_alloc(=
struct net_device *dev)
 	caifdevs =3D caif_device_list(dev_net(dev));
 	BUG_ON(!caifdevs);
=20
-	caifd =3D kzalloc(sizeof(*caifd), GFP_ATOMIC);
+	caifd =3D kzalloc(sizeof(*caifd), GFP_KERNEL);
 	if (!caifd)
 		return NULL;
 	caifd->pcpu_refcnt =3D alloc_percpu(int);
+	if (!caifd->pcpu_refcnt) {
+		kfree(caifd);
+		return NULL;
+	}
 	caifd->netdev =3D dev;
 	dev_hold(dev);
 	return caifd;
