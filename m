From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH] xfrm: do not assume that template resolving always returns xfrms
Date: Tue, 13 Jul 2010 10:29:42 +0300
Message-ID: <1279006182-11421-1-git-send-email-timo.teras@iki.fi>
References: <20100712.212041.236240543.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux@horizon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:48931 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414Ab0GMHaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 03:30:25 -0400
Received: by ewy23 with SMTP id 23so1014696ewy.19
        for <netdev@vger.kernel.org>; Tue, 13 Jul 2010 00:30:23 -0700 (PDT)
In-Reply-To: <20100712.212041.236240543.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_resolve_and_create_bundle() assumed that, if policies indicated
presence of xfrms, bundle template resolution would always return
some xfrms. This is not true for 'use' level policies which can
result in no xfrm's being applied if there is no suitable xfrm states.
This fixes a crash by this incorrect assumption.

Reported-by: George Spelvin <linux@horizon.com>
Bisected-by: George Spelvin <linux@horizon.com>
Tested-by: George Spelvin <linux@horizon.com>
Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
 net/xfrm/xfrm_policy.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index af1c173..a7ec5a8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1594,8 +1594,8 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy=
 **pols, int num_pols,
=20
 	/* Try to instantiate a bundle */
 	err =3D xfrm_tmpl_resolve(pols, num_pols, fl, xfrm, family);
-	if (err < 0) {
-		if (err !=3D -EAGAIN)
+	if (err <=3D 0) {
+		if (err !=3D 0 && err !=3D -EAGAIN)
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTPOLERROR);
 		return ERR_PTR(err);
 	}
@@ -1678,6 +1678,13 @@ xfrm_bundle_lookup(struct net *net, struct flowi=
 *fl, u16 family, u8 dir,
 			goto make_dummy_bundle;
 		dst_hold(&xdst->u.dst);
 		return oldflo;
+	} else if (new_xdst =3D=3D NULL) {
+		num_xfrms =3D 0;
+		if (oldflo =3D=3D NULL)
+			goto make_dummy_bundle;
+		xdst->num_xfrms =3D 0;
+		dst_hold(&xdst->u.dst);
+		return oldflo;
 	}
=20
 	/* Kill the previous bundle */
@@ -1760,6 +1767,10 @@ restart:
 				xfrm_pols_put(pols, num_pols);
 				err =3D PTR_ERR(xdst);
 				goto dropdst;
+			} else if (xdst =3D=3D NULL) {
+				num_xfrms =3D 0;
+				drop_pols =3D num_pols;
+				goto no_transform;
 			}
=20
 			spin_lock_bh(&xfrm_policy_sk_bundle_lock);
--=20
1.7.0.4

