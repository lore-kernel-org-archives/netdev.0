From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] gen_stats.c: Duplicate xstats buffer for later use
Date: Fri, 13 Feb 2015 14:47:05 -0800
Message-ID: <1423867625-1509-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, ignacy.gawedzki@green-communications.fr,
	David.Laight@aculab.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:48744 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbbBMWrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 17:47:17 -0500
Received: by mail-pa0-f51.google.com with SMTP id eu11so21698289pac.10
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 14:47:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communications.fr>

The gnet_stats_copy_app() function gets called, more often than not, wi=
th its
second argument a pointer to an automatic variable in the caller's stac=
k.
Therefore, to avoid copying garbage afterwards when calling
gnet_stats_finish_copy(), this data is better copied to a dynamically a=
llocated
memory that gets freed after use.

[xiyou.wangcong@gmail.com: remove a useless kfree()]

Signed-off-by: Ignacy Gaw=C4=99dzki <ignacy.gawedzki@green-communicatio=
ns.fr>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/gen_stats.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 0c08062..1e2f46a 100644
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
@@ -305,7 +308,9 @@ int
 gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
 {
 	if (d->compat_xstats) {
-		d->xstats =3D st;
+		d->xstats =3D kmemdup(st, len, GFP_ATOMIC);
+		if (!d->xstats)
+			goto err_out;
 		d->xstats_len =3D len;
 	}
=20
@@ -313,6 +318,11 @@ gnet_stats_copy_app(struct gnet_dump *d, void *st,=
 int len)
 		return gnet_stats_copy(d, TCA_STATS_APP, st, len);
=20
 	return 0;
+
+err_out:
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
1.8.3.1
