From: stufever@gmail.com
Subject: =?UTF-8?q?=5BPATCH=20RESEND=5D=20gianfar=3A=20reduce=20stack=20usage=20in=20gianfar=5Fethtool=2Ec?=
Date: Thu, 11 Aug 2011 15:00:37 +0800
Message-ID: <1313046037-21655-1-git-send-email-wangshaoyan.pt@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	sebastian.poehn@belden.com,
	Wang Shaoyan <wangshaoyan.pt@taobao.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Wang Shaoyan <wangshaoyan.pt@taobao.com>

  drivers/net/gianfar_ethtool.c:765: warning: the frame size of 2048 by=
tes is larger than 1024 bytes

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
--=20
1.7.4.1
