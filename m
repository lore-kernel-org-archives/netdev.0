From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: [PATCH] SUNRPC: Refactor gssx_dec_option_array() to kill uninitialized warning
Date: Mon,  6 May 2013 09:21:03 +0200
Message-ID: <1367824863-1857-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

net/sunrpc/auth_gss/gss_rpc_xdr.c: In function =E2=80=98gssx_dec_option=
_array=E2=80=99:
net/sunrpc/auth_gss/gss_rpc_xdr.c:258: warning: =E2=80=98creds=E2=80=99=
 may be used uninitialized in this function

Return early if count is zero, to make it clearer to the compiler (and =
the
casual reviewer) that no more processing is done.

Signed-off-by: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
---
 net/sunrpc/auth_gss/gss_rpc_xdr.c |   32 +++++++++++++++++------------=
---
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gs=
s_rpc_xdr.c
index 5c4c61d..a1e1b1a 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -264,25 +264,27 @@ static int gssx_dec_option_array(struct xdr_strea=
m *xdr,
 	if (unlikely(p =3D=3D NULL))
 		return -ENOSPC;
 	count =3D be32_to_cpup(p++);
-	if (count !=3D 0) {
-		/* we recognize only 1 currently: CREDS_VALUE */
-		oa->count =3D 1;
+	if (!count)
+		return 0;
=20
-		oa->data =3D kmalloc(sizeof(struct gssx_option), GFP_KERNEL);
-		if (!oa->data)
-			return -ENOMEM;
+	/* we recognize only 1 currently: CREDS_VALUE */
+	oa->count =3D 1;
=20
-		creds =3D kmalloc(sizeof(struct svc_cred), GFP_KERNEL);
-		if (!creds) {
-			kfree(oa->data);
-			return -ENOMEM;
-		}
+	oa->data =3D kmalloc(sizeof(struct gssx_option), GFP_KERNEL);
+	if (!oa->data)
+		return -ENOMEM;
=20
-		oa->data[0].option.data =3D CREDS_VALUE;
-		oa->data[0].option.len =3D sizeof(CREDS_VALUE);
-		oa->data[0].value.data =3D (void *)creds;
-		oa->data[0].value.len =3D 0;
+	creds =3D kmalloc(sizeof(struct svc_cred), GFP_KERNEL);
+	if (!creds) {
+		kfree(oa->data);
+		return -ENOMEM;
 	}
+
+	oa->data[0].option.data =3D CREDS_VALUE;
+	oa->data[0].option.len =3D sizeof(CREDS_VALUE);
+	oa->data[0].value.data =3D (void *)creds;
+	oa->data[0].value.len =3D 0;
+
 	for (i =3D 0; i < count; i++) {
 		gssx_buffer dummy =3D { 0, NULL };
 		u32 length;
--=20
1.7.0.4

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
