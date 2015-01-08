From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net 1/2] gen_stats.c: Duplicate xstats buffer for later use
Date: Thu, 8 Jan 2015 11:35:18 +0100
Message-ID: <20150108103518.GA7214@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:53973 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756315AbbAHKwL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 05:52:11 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Y9ARM-0003lN-1K
	for netdev@vger.kernel.org; Thu, 08 Jan 2015 11:35:44 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Y9AQw-0001sa-OC
	for netdev@vger.kernel.org; Thu, 08 Jan 2015 11:35:18 +0100
Content-Disposition: inline
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
 net/core/gen_stats.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 0c08062..5770a0e 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -305,7 +305,10 @@ int
 gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
 {
 	if (d->compat_xstats) {
-		d->xstats =3D st;
+		d->xstats =3D kmalloc(len, GFP_KERNEL);
+		if (!d->xstats)
+			goto kmalloc_failure;
+		memcpy(d->xstats, st, len);
 		d->xstats_len =3D len;
 	}
=20
@@ -313,6 +316,9 @@ gnet_stats_copy_app(struct gnet_dump *d, void *st, =
int len)
 		return gnet_stats_copy(d, TCA_STATS_APP, st, len);
=20
 	return 0;
+kmalloc_failure:
+	spin_unlock_bh(d->lock);
+	return -1;
 }
 EXPORT_SYMBOL(gnet_stats_copy_app);
=20
@@ -340,8 +346,13 @@ gnet_stats_finish_copy(struct gnet_dump *d)
 			return -1;
=20
 	if (d->compat_xstats && d->xstats) {
-		if (gnet_stats_copy(d, d->compat_xstats, d->xstats,
-			d->xstats_len) < 0)
+		int	result =3D gnet_stats_copy(d, d->compat_xstats,
+						 d->xstats, d->xstats_len);
+		kfree(d->xstats);
+		d->xstats =3D NULL;
+		d->xstats_len =3D 0;
+
+		if (result < 0)
 			return -1;
 	}
=20
--=20
1.9.1
