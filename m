From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v6 3/9] ethtool: factorize ethtool_get_strings() and ethtool_get_sset_count()
Date: Wed, 16 Feb 2011 03:59:16 +0100 (CET)
Message-ID: <7746398ce165bf7831f8af79c8f677f81100b324.1297824704.git.mirq-linux@rere.qmqm.pl>
References: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57726 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756523Ab1BPC7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 21:59:19 -0500
In-Reply-To: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed for unified offloads patch.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   35 +++++++++++++++++++++++------------
 1 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9eb8277..85aaeab 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -172,6 +172,25 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
=20
 /* Handlers for each ethtool command */
=20
+static int __ethtool_get_sset_count(struct net_device *dev, int sset)
+{
+	const struct ethtool_ops *ops =3D dev->ethtool_ops;
+
+	if (ops && ops->get_sset_count && ops->get_strings)
+		return ops->get_sset_count(dev, sset);
+	else
+		return -EOPNOTSUPP;
+}
+
+static void __ethtool_get_strings(struct net_device *dev,
+	u32 stringset, u8 *data)
+{
+	const struct ethtool_ops *ops =3D dev->ethtool_ops;
+
+	/* ops->get_strings is valid because checked earlier */
+	ops->get_strings(dev, stringset, data);
+}
+
 static int ethtool_get_settings(struct net_device *dev, void __user *u=
seraddr)
 {
 	struct ethtool_cmd cmd =3D { .cmd =3D ETHTOOL_GSET };
@@ -252,14 +271,10 @@ static noinline_for_stack int ethtool_get_sset_in=
fo(struct net_device *dev,
 						    void __user *useraddr)
 {
 	struct ethtool_sset_info info;
-	const struct ethtool_ops *ops =3D dev->ethtool_ops;
 	u64 sset_mask;
 	int i, idx =3D 0, n_bits =3D 0, ret, rc;
 	u32 *info_buf =3D NULL;
=20
-	if (!ops->get_sset_count)
-		return -EOPNOTSUPP;
-
 	if (copy_from_user(&info, useraddr, sizeof(info)))
 		return -EFAULT;
=20
@@ -286,7 +301,7 @@ static noinline_for_stack int ethtool_get_sset_info=
(struct net_device *dev,
 		if (!(sset_mask & (1ULL << i)))
 			continue;
=20
-		rc =3D ops->get_sset_count(dev, i);
+		rc =3D __ethtool_get_sset_count(dev, i);
 		if (rc >=3D 0) {
 			info.sset_mask |=3D (1ULL << i);
 			info_buf[idx++] =3D rc;
@@ -1287,17 +1302,13 @@ static int ethtool_self_test(struct net_device =
*dev, char __user *useraddr)
 static int ethtool_get_strings(struct net_device *dev, void __user *us=
eraddr)
 {
 	struct ethtool_gstrings gstrings;
-	const struct ethtool_ops *ops =3D dev->ethtool_ops;
 	u8 *data;
 	int ret;
=20
-	if (!ops->get_strings || !ops->get_sset_count)
-		return -EOPNOTSUPP;
-
 	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
 		return -EFAULT;
=20
-	ret =3D ops->get_sset_count(dev, gstrings.string_set);
+	ret =3D __ethtool_get_sset_count(dev, gstrings.string_set);
 	if (ret < 0)
 		return ret;
=20
@@ -1307,7 +1318,7 @@ static int ethtool_get_strings(struct net_device =
*dev, void __user *useraddr)
 	if (!data)
 		return -ENOMEM;
=20
-	ops->get_strings(dev, gstrings.string_set, data);
+	__ethtool_get_strings(dev, gstrings.string_set, data);
=20
 	ret =3D -EFAULT;
 	if (copy_to_user(useraddr, &gstrings, sizeof(gstrings)))
@@ -1317,7 +1328,7 @@ static int ethtool_get_strings(struct net_device =
*dev, void __user *useraddr)
 		goto out;
 	ret =3D 0;
=20
- out:
+out:
 	kfree(data);
 	return ret;
 }
--=20
1.7.2.3

