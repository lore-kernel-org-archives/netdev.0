From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] ath6kl: Unify sg_sz and buf_sz in ath6kl_sdio_alloc_prep_scat_req()
Date: Wed, 24 Apr 2013 14:02:34 +0200
Message-ID: <1366804954-20491-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:51739 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932275Ab3DXMCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 08:02:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sg_sz and buf_sz are initialized and used in a mutual exclusive way.
However, some versions of gcc are not smart enough to see this:

drivers/net/wireless/ath/ath6kl/sdio.c: In function =E2=80=98ath6kl_sdi=
o_alloc_prep_scat_req=E2=80=99:
drivers/net/wireless/ath/ath6kl/sdio.c:338: warning: =E2=80=98sg_sz=E2=80=
=99 may be used uninitialized in this function

Unify the sg_sz and buf_sz variables into a single size variable to kil=
l
the compiler warning.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/wireless/ath/ath6kl/sdio.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/sdio.c b/drivers/net/wirel=
ess/ath/ath6kl/sdio.c
index d111980..7638135 100644
--- a/drivers/net/wireless/ath/ath6kl/sdio.c
+++ b/drivers/net/wireless/ath/ath6kl/sdio.c
@@ -335,17 +335,17 @@ static int ath6kl_sdio_alloc_prep_scat_req(struct=
 ath6kl_sdio *ar_sdio,
 {
 	struct hif_scatter_req *s_req;
 	struct bus_request *bus_req;
-	int i, scat_req_sz, scat_list_sz, sg_sz, buf_sz;
+	int i, scat_req_sz, scat_list_sz, size;
 	u8 *virt_buf;
=20
 	scat_list_sz =3D (n_scat_entry - 1) * sizeof(struct hif_scatter_item)=
;
 	scat_req_sz =3D sizeof(*s_req) + scat_list_sz;
=20
 	if (!virt_scat)
-		sg_sz =3D sizeof(struct scatterlist) * n_scat_entry;
+		size =3D sizeof(struct scatterlist) * n_scat_entry;
 	else
-		buf_sz =3D  2 * L1_CACHE_BYTES +
-			  ATH6KL_MAX_TRANSFER_SIZE_PER_SCATTER;
+		size =3D  2 * L1_CACHE_BYTES +
+			ATH6KL_MAX_TRANSFER_SIZE_PER_SCATTER;
=20
 	for (i =3D 0; i < n_scat_req; i++) {
 		/* allocate the scatter request */
@@ -354,7 +354,7 @@ static int ath6kl_sdio_alloc_prep_scat_req(struct a=
th6kl_sdio *ar_sdio,
 			return -ENOMEM;
=20
 		if (virt_scat) {
-			virt_buf =3D kzalloc(buf_sz, GFP_KERNEL);
+			virt_buf =3D kzalloc(size, GFP_KERNEL);
 			if (!virt_buf) {
 				kfree(s_req);
 				return -ENOMEM;
@@ -364,7 +364,7 @@ static int ath6kl_sdio_alloc_prep_scat_req(struct a=
th6kl_sdio *ar_sdio,
 				(u8 *)L1_CACHE_ALIGN((unsigned long)virt_buf);
 		} else {
 			/* allocate sglist */
-			s_req->sgentries =3D kzalloc(sg_sz, GFP_KERNEL);
+			s_req->sgentries =3D kzalloc(size, GFP_KERNEL);
=20
 			if (!s_req->sgentries) {
 				kfree(s_req);
--=20
1.7.0.4
