From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net v3] gen_stats.c: Duplicate xstats buffer for later use
Date: Thu, 8 Jan 2015 14:30:37 +0100
Message-ID: <20150108133037.GA10389@zenon.in.qult.net>
References: <20150108123343.GA8541@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:54408 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756981AbbAHNbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 08:31:03 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Y9DAd-0004T2-3e
	for netdev@vger.kernel.org; Thu, 08 Jan 2015 14:30:39 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Y9DAb-0002ja-Ty
	for netdev@vger.kernel.org; Thu, 08 Jan 2015 14:30:38 +0100
Content-Disposition: inline
In-Reply-To: <20150108123343.GA8541@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gnet_stats_copy_app() function gets called, more often than not, wi=
th its
second argument a pointer to an automatic variable in the caller's stac=
k.
Therefore, to avoid copying garbage afterwards when calling
gnet_stats_finish_copy(), this data is better copied to a dynamically a=
llocated
memory that gets freed after use.

Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.=
fr>
---
 net/core/gen_stats.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 0c08062..c9f1fa8 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -32,6 +32,9 @@ gnet_stats_copy(struct gnet_dump *d, int type, void *=
buf, int size)
 	return 0;
=20
 nla_put_failure:
+	kfree(d->xstats);
+	d->xstats =3D NULL;
+	d->xstats_len =3D 0;
 	spin_unlock_bh(d->lock);
 	return -1;
 }
@@ -305,7 +308,10 @@ int
 gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
 {
 	if (d->compat_xstats) {
-		d->xstats =3D st;
+		kfree(d->xstats);
+		d->xstats =3D kmemdup(st, len, GFP_ATOMIC);
+		if (!d->xstats)
+			goto kmalloc_failure;
 		d->xstats_len =3D len;
 	}
=20
@@ -313,6 +319,10 @@ gnet_stats_copy_app(struct gnet_dump *d, void *st,=
 int len)
 		return gnet_stats_copy(d, TCA_STATS_APP, st, len);
=20
 	return 0;
+kmalloc_failure:
+	d->xstats_len =3D 0;
+	spin_unlock_bh(d->lock);
+	return -1;
 }
 EXPORT_SYMBOL(gnet_stats_copy_app);
=20
@@ -345,6 +355,9 @@ gnet_stats_finish_copy(struct gnet_dump *d)
 			return -1;
 	}
=20
+	kfree(d->xstats);
+	d->xstats =3D NULL;
+	d->xstats_len =3D 0;
 	spin_unlock_bh(d->lock);
 	return 0;
 }
--=20
2.1.0
