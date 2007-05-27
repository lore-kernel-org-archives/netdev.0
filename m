From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] ATM: fix warning
Date: Sun, 27 May 2007 06:40:20 -0400
Message-ID: <20070527104020.GA10665@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:33176 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154AbXE0KkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 May 2007 06:40:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The compiler warning

drivers/atm/firestream.c: In function =E2=80=98top_off_fp=E2=80=99:
drivers/atm/firestream.c:1505: warning: cast to pointer from integer of=
 different size

does indicate a bug, albeit a minor one.  Fixed, by using a 32-bit
temporary prior to the call to bus_to_virt().

The larger bug is still present:  the entire driver assumes that machin=
e
pointers are 32-bit, as it stores pointers in 32-bit hardware registers=
=2E
This is obvious to anyone who knows the driver well, but for the casual
readers it is helpfully noted with FIXME.

Signed-off-by: Jeff Garzik <jeff@garzik.org>

diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 9c67df5..7f6d02c 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1475,6 +1475,7 @@ static void top_off_fp (struct fs_dev *dev, struc=
t freepool *fp,
 	struct FS_BPENTRY *qe, *ne;
 	struct sk_buff *skb;
 	int n =3D 0;
+	u32 qe_tmp;
=20
 	fs_dprintk (FS_DEBUG_QUEUE, "Topping off queue at %x (%d-%d/%d)\n",=20
 		    fp->offset, read_fs (dev, FP_CNT (fp->offset)), fp->n,=20
@@ -1502,10 +1503,16 @@ static void top_off_fp (struct fs_dev *dev, str=
uct freepool *fp,
 		ne->skb =3D skb;
 		ne->fp =3D fp;
=20
-		qe =3D (struct FS_BPENTRY *) (read_fs (dev, FP_EA(fp->offset)));
-		fs_dprintk (FS_DEBUG_QUEUE, "link at %p\n", qe);
-		if (qe) {
-			qe =3D bus_to_virt ((long) qe);
+		/*
+		 * FIXME: following code encodes and decodes
+		 * machine pointers (could be 64-bit) into a
+		 * 32-bit register.
+		 */
+
+		qe_tmp =3D read_fs (dev, FP_EA(fp->offset));
+		fs_dprintk (FS_DEBUG_QUEUE, "link at %x\n", qe_tmp);
+		if (qe_tmp) {
+			qe =3D bus_to_virt ((long) qe_tmp);
 			qe->next =3D virt_to_bus(ne);
 			qe->flags &=3D ~FP_FLAGS_EPI;
 		} else
