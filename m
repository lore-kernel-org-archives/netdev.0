From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: Fwd: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Wed, 10 Aug 2011 15:11:21 +0200
Message-ID: <1312981881.29613.22.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux Netdev <netdev@vger.kernel.org>, wangshaoyan.pt@taobao.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56129 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab1HJNNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 09:13:51 -0400
Received: by wyg24 with SMTP id 24so696463wyg.19
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2011 06:13:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was annoyed by the compiler warning for quite a long time ...

Patch seems to work. Please put version information in your email heade=
r on future patches.


Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>
Reviewed-and-tested-by: Sebastian P=C3=B6hn <sebastian.poehn@belden.com=
>

---
 drivers/net/gianfar_ethtool.c |   26 +++++++++++++++++++++-----
 1 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtoo=
l.c
index 6e35069..25a8c2a 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -686,10 +686,21 @@ static int gfar_ethflow_to_filer_table(struct gfa=
r_private *priv, u64 ethflow, u
 {
 	unsigned int last_rule_idx =3D priv->cur_filer_idx;
 	unsigned int cmp_rqfpr;
-	unsigned int local_rqfpr[MAX_FILER_IDX + 1];
-	unsigned int local_rqfcr[MAX_FILER_IDX + 1];
+	unsigned int *local_rqfpr;
+	unsigned int *local_rqfcr;
 	int i =3D 0x0, k =3D 0x0;
 	int j =3D MAX_FILER_IDX, l =3D 0x0;
+	int ret =3D 1;
+
+	local_rqfpr =3D kmalloc(sizeof(unsigned int) * (MAX_FILER_IDX + 1),
+		GFP_KERNEL);
+	local_rqfcr =3D kmalloc(sizeof(unsigned int) * (MAX_FILER_IDX + 1),
+		GFP_KERNEL);
+	if (!local_rqfpr || !local_rqfcr) {
+		pr_err("Out of memory\n");
+		ret =3D 0;
+		goto err;
+	}
=20
 	switch (class) {
 	case TCP_V4_FLOW:
@@ -706,7 +717,8 @@ static int gfar_ethflow_to_filer_table(struct gfar_=
private *priv, u64 ethflow, u
 		break;
 	default:
 		pr_err("Right now this class is not supported\n");
-		return 0;
+		ret =3D 0;
+		goto err;
 	}
=20
 	for (i =3D 0; i < MAX_FILER_IDX + 1; i++) {
@@ -721,7 +733,8 @@ static int gfar_ethflow_to_filer_table(struct gfar_=
private *priv, u64 ethflow, u
=20
 	if (i =3D=3D MAX_FILER_IDX + 1) {
 		pr_err("No parse rule found, can't create hash rules\n");
-		return 0;
+		ret =3D 0;
+		goto err;
 	}
=20
 	/* If a match was found, then it begins the starting of a cluster rul=
e
@@ -765,7 +778,10 @@ static int gfar_ethflow_to_filer_table(struct gfar=
_private *priv, u64 ethflow, u
 		priv->cur_filer_idx =3D priv->cur_filer_idx - 1;
 	}
=20
-	return 1;
+err:
+	kfree(local_rqfcr);
+	kfree(local_rqfpr);
+	return ret;
 }
=20
 static int gfar_set_hash_opts(struct gfar_private *priv, struct ethtoo=
l_rxnfc *cmd)





