From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 10/21] orinoco replace hermes_write_words() with hermes_write_bytes()
Date: Fri, 07 Apr 2006 04:10:39 -0400
Message-ID: <20060407081038.16107.39910.stgit@dv.roinet.com>
References: <20060407081019.16107.67672.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
In-Reply-To: <20060407081019.16107.67672.stgit-fdEtzkpK75rby3iVrkZq2A@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

The new function can write an odd number of bytes, thus making padding
unnecessary.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
---

 drivers/net/wireless/hermes.c      |   17 ++++++++---------
 drivers/net/wireless/hermes.h      |    7 +++++--
 drivers/net/wireless/spectrum_cs.c |    7 +++----
 3 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/hermes.c b/drivers/net/wireless/hermes.=
c
index 456d934..be24f01 100644
--- a/drivers/net/wireless/hermes.c
+++ b/drivers/net/wireless/hermes.c
@@ -400,8 +400,7 @@ int hermes_bap_pread(hermes_t *hw, int b
 }
=20
 /* Write a block of data to the chip's buffer, via the
- * BAP. Synchronization/serialization is the caller's problem. len
- * must be even.
+ * BAP. Synchronization/serialization is the caller's problem.
  *
  * Returns: < 0 on internal failure (errno), 0 on success, > 0 on error =
from firmware
  */
@@ -411,7 +410,7 @@ int hermes_bap_pwrite(hermes_t *hw, int=20
 	int dreg =3D bap ? HERMES_DATA1 : HERMES_DATA0;
 	int err =3D 0;
=20
-	if ( (len < 0) || (len % 2) )
+	if (len < 0)
 		return -EINVAL;
=20
 	err =3D hermes_bap_seek(hw, bap, id, offset);
@@ -419,7 +418,7 @@ int hermes_bap_pwrite(hermes_t *hw, int=20
 		goto out;
 =09
 	/* Actually do the transfer */
-	hermes_write_words(hw, dreg, buf, len/2);
+	hermes_write_bytes(hw, dreg, buf, len);
=20
  out:=09
 	return err;
@@ -427,7 +426,7 @@ int hermes_bap_pwrite(hermes_t *hw, int=20
=20
 /* Write a block of data to the chip's buffer with padding if
  * neccessary, via the BAP. Synchronization/serialization is the
- * caller's problem. len must be even.
+ * caller's problem.
  *
  * Returns: < 0 on internal failure (errno), 0 on success, > 0 on error =
from firmware
  */
@@ -437,7 +436,7 @@ int hermes_bap_pwrite_pad(hermes_t *hw,=20
 	int dreg =3D bap ? HERMES_DATA1 : HERMES_DATA0;
 	int err =3D 0;
=20
-	if (len < 0 || len % 2 || data_len > len)
+	if (len < 0 || data_len > len)
 		return -EINVAL;
=20
 	err =3D hermes_bap_seek(hw, bap, id, offset);
@@ -445,13 +444,13 @@ int hermes_bap_pwrite_pad(hermes_t *hw,=20
 		goto out;
=20
 	/* Transfer all the complete words of data */
-	hermes_write_words(hw, dreg, buf, data_len/2);
+	hermes_write_bytes(hw, dreg, buf, data_len);
 	/* If there is an odd byte left over pad and transfer it */
 	if (data_len & 1) {
 		u8 end[2];
 		end[1] =3D 0;
 		end[0] =3D ((unsigned char *)buf)[data_len - 1];
-		hermes_write_words(hw, dreg, end, 1);
+		hermes_write_bytes(hw, dreg, end, 2);
 		data_len ++;
 	}
 	/* Now send zeros for the padding */
@@ -534,7 +533,7 @@ int hermes_write_ltv(hermes_t *hw, int b
=20
 	count =3D length - 1;
=20
-	hermes_write_words(hw, dreg, value, count);
+	hermes_write_bytes(hw, dreg, value, count << 1);
=20
 	err =3D hermes_docmd_wait(hw, HERMES_CMD_ACCESS | HERMES_CMD_WRITE,=20
 				rid, NULL);
diff --git a/drivers/net/wireless/hermes.h b/drivers/net/wireless/hermes.=
h
index 34ccba2..e1b279e 100644
--- a/drivers/net/wireless/hermes.h
+++ b/drivers/net/wireless/hermes.h
@@ -408,10 +408,13 @@ static inline void hermes_read_words(str
 	ioread16_rep(hw->iobase + off, buf, count);
 }
=20
-static inline void hermes_write_words(struct hermes *hw, int off, const =
void *buf, unsigned count)
+static inline void hermes_write_bytes(struct hermes *hw, int off,
+				      const char *buf, unsigned count)
 {
 	off =3D off << hw->reg_spacing;
-	iowrite16_rep(hw->iobase + off, buf, count);
+	iowrite16_rep(hw->iobase + off, buf, count >> 1);
+	if (unlikely(count & 1))
+		iowrite8(buf[count - 1], hw->iobase + off);
 }
=20
 static inline void hermes_clear_words(struct hermes *hw, int off, unsign=
ed count)
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/sp=
ectrum_cs.c
index 14f4daa..c13a5b6 100644
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -343,8 +343,7 @@ spectrum_plug_pdi(hermes_t *hw, struct p
=20
 	/* do the actual plugging */
 	spectrum_aux_setaddr(hw, pdr_addr(pdr));
-	hermes_write_words(hw, HERMES_AUXDATA, pdi->data,
-			   pdi_len(pdi) / 2);
+	hermes_write_bytes(hw, HERMES_AUXDATA, pdi->data, pdi_len(pdi));
=20
 	return 0;
 }
@@ -424,8 +423,8 @@ spectrum_load_blocks(hermes_t *hw, const
=20
 	while (dblock_addr(blk) !=3D BLOCK_END) {
 		spectrum_aux_setaddr(hw, blkaddr);
-		hermes_write_words(hw, HERMES_AUXDATA, blk->data,
-				   blklen / 2);
+		hermes_write_bytes(hw, HERMES_AUXDATA, blk->data,
+				   blklen);
=20
 		blk =3D (struct dblock *) &blk->data[blklen];
 		blkaddr =3D dblock_addr(blk);



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
