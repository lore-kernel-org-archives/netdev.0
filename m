From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 03/13] ISDN: Add support for none reverse bitstreams to isdnhdc
Date: Wed, 8 Jul 2009 20:31:42 +0200
Message-ID: <c38fc3bc2ecddd4f5278131603e6964cbed071b2.1248546896.git.keil@b1-systems.de>
References: <cover.1248546896.git.keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752697AbZGYUPK@vger.kernel.org>
In-Reply-To: <cover.1248546896.git.keil@b1-systems.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The original isdnhdlc code was developed for devices which had
reversed bitorder in the byte stream. Adding code to handle normal
bitstreams as well.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hisax/st5481_b.c   |    5 ++-
 drivers/isdn/hisax/st5481_d.c   |    2 +-
 drivers/isdn/hisax/st5481_usb.c |   11 ++++--
 drivers/isdn/i4l/isdnhdlc.c     |   70 +++++++++++++++++++------------=
-------
 include/linux/isdn/hdlc.h       |   12 +++++--
 5 files changed, 56 insertions(+), 44 deletions(-)

diff --git a/drivers/isdn/hisax/st5481_b.c b/drivers/isdn/hisax/st5481_=
b.c
index 0074b60..95b1cdd 100644
--- a/drivers/isdn/hisax/st5481_b.c
+++ b/drivers/isdn/hisax/st5481_b.c
@@ -218,7 +218,10 @@ static void st5481B_mode(struct st5481_bcs *bcs, i=
nt mode)
 	if (bcs->mode !=3D L1_MODE_NULL) {
 		// Open the B channel
 		if (bcs->mode !=3D L1_MODE_TRANS) {
-			isdnhdlc_out_init(&b_out->hdlc_state, 0, bcs->mode =3D=3D L1_MODE_H=
DLC_56K);
+			u32 features =3D HDLC_BITREVERSE;
+			if (bcs->mode =3D=3D L1_MODE_HDLC_56K)
+				features |=3D HDLC_56KBIT;
+			isdnhdlc_out_init(&b_out->hdlc_state, features);
 		}
 		st5481_usb_pipe_reset(adapter, (bcs->channel+1)*2, NULL, NULL);
 =09
diff --git a/drivers/isdn/hisax/st5481_d.c b/drivers/isdn/hisax/st5481_=
d.c
index 077991c..39e8e49 100644
--- a/drivers/isdn/hisax/st5481_d.c
+++ b/drivers/isdn/hisax/st5481_d.c
@@ -417,7 +417,7 @@ static void dout_start_xmit(struct FsmInst *fsm, in=
t event, void *arg)
=20
 	DBG(2,"len=3D%d",skb->len);
=20
-	isdnhdlc_out_init(&d_out->hdlc_state, 1, 0);
+	isdnhdlc_out_init(&d_out->hdlc_state, HDLC_DCHANNEL | HDLC_BITREVERSE=
);
=20
 	if (test_and_set_bit(buf_nr, &d_out->busy)) {
 		WARNING("ep %d urb %d busy %#lx", EP_D_OUT, buf_nr, d_out->busy);
diff --git a/drivers/isdn/hisax/st5481_usb.c b/drivers/isdn/hisax/st548=
1_usb.c
index 2b3a055..10d41c5 100644
--- a/drivers/isdn/hisax/st5481_usb.c
+++ b/drivers/isdn/hisax/st5481_usb.c
@@ -637,10 +637,13 @@ void st5481_in_mode(struct st5481_in *in, int mod=
e)
 	usb_unlink_urb(in->urb[1]);
=20
 	if (in->mode !=3D L1_MODE_NULL) {
-		if (in->mode !=3D L1_MODE_TRANS)
-			isdnhdlc_rcv_init(&in->hdlc_state,
-				in->mode =3D=3D L1_MODE_HDLC_56K);
-	=09
+		if (in->mode !=3D L1_MODE_TRANS) {
+			u32 features =3D HDLC_BITREVERSE;
+
+			if (in->mode =3D=3D L1_MODE_HDLC_56K)
+				features |=3D HDLC_56KBIT;
+			isdnhdlc_rcv_init(&in->hdlc_state, features);
+		}
 		st5481_usb_pipe_reset(in->adapter, in->ep, NULL, NULL);
 		st5481_usb_device_ctrl_msg(in->adapter, in->counter,
 					   in->packet_size,
diff --git a/drivers/isdn/i4l/isdnhdlc.c b/drivers/isdn/i4l/isdnhdlc.c
index b80e55a..df345ce 100644
--- a/drivers/isdn/i4l/isdnhdlc.c
+++ b/drivers/isdn/i4l/isdnhdlc.c
@@ -2,6 +2,7 @@
  * isdnhdlc.c  --  General purpose ISDN HDLC decoder.
  *
  * Copyright (C)
+ *	2009	Karsten Keil		<keil@b1-systems.de>
  *	2002	Wolfgang M=C3=BCes		<wolfgang@iksw-muees.de>
  *	2001	Frode Isaksen		<fisaksen@bewan.com>
  *      2001	Kai Germaschewski	<kai.germaschewski@gmx.de>
@@ -25,6 +26,7 @@
 #include <linux/init.h>
 #include <linux/crc-ccitt.h>
 #include <linux/isdn/hdlc.h>
+#include <linux/bitrev.h>
=20
 /*-------------------------------------------------------------------*=
/
=20
@@ -48,35 +50,21 @@ enum {
 	HDLC_SENDFLAG_B1A6, HDLC_SENDFLAG_B7, STOPPED
 };
=20
-void isdnhdlc_rcv_init(struct isdnhdlc_vars *hdlc, int do_adapt56)
+void isdnhdlc_rcv_init(struct isdnhdlc_vars *hdlc, u32 features)
 {
-	hdlc->bit_shift =3D 0;
-	hdlc->hdlc_bits1 =3D 0;
-	hdlc->data_bits =3D 0;
-	hdlc->ffbit_shift =3D 0;
-	hdlc->data_received =3D 0;
+	memset(hdlc, 0, sizeof(struct isdnhdlc_vars));
 	hdlc->state =3D HDLC_GET_DATA;
-	hdlc->do_adapt56 =3D do_adapt56;
-	hdlc->dchannel =3D 0;
-	hdlc->crc =3D 0;
-	hdlc->cbin =3D 0;
-	hdlc->shift_reg =3D 0;
-	hdlc->ffvalue =3D 0;
-	hdlc->dstpos =3D 0;
+	if (features & HDLC_56KBIT)
+		hdlc->do_adapt56 =3D 1;
+	if (features & HDLC_BITREVERSE)
+		hdlc->do_bitreverse =3D 1;
 }
 EXPORT_SYMBOL(isdnhdlc_out_init);
=20
-void isdnhdlc_out_init(struct isdnhdlc_vars *hdlc, int is_d_channel,
-	int do_adapt56)
+void isdnhdlc_out_init(struct isdnhdlc_vars *hdlc, u32 features)
 {
-	hdlc->bit_shift =3D 0;
-	hdlc->hdlc_bits1 =3D 0;
-	hdlc->data_bits =3D 0;
-	hdlc->ffbit_shift =3D 0;
-	hdlc->data_received =3D 0;
-	hdlc->do_closing =3D 0;
-	hdlc->ffvalue =3D 0;
-	if (is_d_channel) {
+	memset(hdlc, 0, sizeof(struct isdnhdlc_vars));
+	if (features & HDLC_DCHANNEL) {
 		hdlc->dchannel =3D 1;
 		hdlc->state =3D HDLC_SEND_FIRST_FLAG;
 	} else {
@@ -85,16 +73,13 @@ void isdnhdlc_out_init(struct isdnhdlc_vars *hdlc, =
int is_d_channel,
 		hdlc->ffvalue =3D 0x7e;
 	}
 	hdlc->cbin =3D 0x7e;
-	hdlc->bit_shift =3D 0;
-	if (do_adapt56) {
+	if (features & HDLC_56KBIT) {
 		hdlc->do_adapt56 =3D 1;
-		hdlc->data_bits =3D 0;
 		hdlc->state =3D HDLC_SENDFLAG_B0;
-	} else {
-		hdlc->do_adapt56 =3D 0;
+	} else
 		hdlc->data_bits =3D 8;
-	}
-	hdlc->shift_reg =3D 0;
+	if (features & HDLC_BITREVERSE)
+		hdlc->do_bitreverse =3D 1;
 }
 EXPORT_SYMBOL(isdnhdlc_rcv_init);
=20
@@ -188,7 +173,11 @@ int isdnhdlc_decode(struct isdnhdlc_vars *hdlc, co=
nst u8 *src, int slen,
=20
 	while (slen > 0) {
 		if (hdlc->bit_shift =3D=3D 0) {
-			hdlc->cbin =3D *src++;
+			/* the code is for bitreverse streams */
+			if (hdlc->do_bitreverse =3D=3D 0)
+				hdlc->cbin =3D bitrev8(*src++);
+			else
+				hdlc->cbin =3D *src++;
 			slen--;
 			hdlc->bit_shift =3D 8;
 			if (hdlc->do_adapt56)
@@ -405,12 +394,15 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, c=
onst u8 *src, u16 slen,
 		case STOPPED:
 			while (dsize--)
 				*dst++ =3D 0xff;
-
 			return dsize;
 		case HDLC_SEND_FAST_FLAG:
 			hdlc->do_closing =3D 0;
 			if (slen =3D=3D 0) {
-				*dst++ =3D hdlc->ffvalue;
+				/* the code is for bitreverse streams */
+				if (hdlc->do_bitreverse =3D=3D 0)
+					*dst++ =3D bitrev8(hdlc->ffvalue);
+				else
+					*dst++ =3D hdlc->ffvalue;
 				len++;
 				dsize--;
 				break;
@@ -594,7 +586,11 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, co=
nst u8 *src, u16 slen,
 				hdlc->cbin =3D 0x7e;
 				hdlc->state =3D HDLC_SEND_FIRST_FLAG;
 			} else {
-				*dst++ =3D hdlc->cbin;
+				/* the code is for bitreverse streams */
+				if (hdlc->do_bitreverse =3D=3D 0)
+					*dst++ =3D bitrev8(hdlc->cbin);
+				else
+					*dst++ =3D hdlc->cbin;
 				hdlc->bit_shift =3D 0;
 				hdlc->data_bits =3D 0;
 				len++;
@@ -612,7 +608,11 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, co=
nst u8 *src, u16 slen,
 			}
 		}
 		if (hdlc->data_bits =3D=3D 8) {
-			*dst++ =3D hdlc->cbin;
+			/* the code is for bitreverse streams */
+			if (hdlc->do_bitreverse =3D=3D 0)
+				*dst++ =3D bitrev8(hdlc->cbin);
+			else
+				*dst++ =3D hdlc->cbin;
 			hdlc->data_bits =3D 0;
 			len++;
 			dsize--;
diff --git a/include/linux/isdn/hdlc.h b/include/linux/isdn/hdlc.h
index 8f3540c..4b3ecc4 100644
--- a/include/linux/isdn/hdlc.h
+++ b/include/linux/isdn/hdlc.h
@@ -6,6 +6,7 @@
  * controllers.
  *
  * Copyright (C)
+ *	2009	Karsten Keil		<keil@b1-systems.de>
  *	2002	Wolfgang M=C3=BCes		<wolfgang@iksw-muees.de>
  *	2001	Frode Isaksen		<fisaksen@bewan.com>
  *	2001	Kai Germaschewski	<kai.germaschewski@gmx.de>
@@ -50,8 +51,14 @@ struct isdnhdlc_vars {
 	u32 do_adapt56:1;
 	/* set if in closing phase (need to send CRC + flag) */
 	u32 do_closing:1;
+	/* set if data is bitreverse */
+	u32 do_bitreverse:1;
 };
=20
+/* Feature Flags */
+#define HDLC_56KBIT	0x01
+#define HDLC_DCHANNEL	0x02
+#define HDLC_BITREVERSE	0x04
=20
 /*
   The return value from isdnhdlc_decode is
@@ -62,13 +69,12 @@ struct isdnhdlc_vars {
 #define HDLC_CRC_ERROR         2
 #define HDLC_LENGTH_ERROR      3
=20
-extern void	isdnhdlc_rcv_init(struct isdnhdlc_vars *hdlc, int do_adapt=
56);
+extern void	isdnhdlc_rcv_init(struct isdnhdlc_vars *hdlc, u32 features=
);
=20
 extern int	isdnhdlc_decode(struct isdnhdlc_vars *hdlc, const u8 *src,
 			int slen, int *count, u8 *dst, int dsize);
=20
-extern void	isdnhdlc_out_init(struct isdnhdlc_vars *hdlc, int is_d_cha=
nnel,
-			int do_adapt56);
+extern void	isdnhdlc_out_init(struct isdnhdlc_vars *hdlc, u32 features=
);
=20
 extern int	isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const u8 *src,
 			u16 slen, int *count, u8 *dst, int dsize);
--=20
1.6.0.2
