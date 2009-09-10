From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] isdn: fix netjet/isdnhdlc build errors
Date: Thu, 10 Sep 2009 15:15:41 -0700
Message-ID: <20090910151541.00cabcbc.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Karsten Keil <isdn@linux-pingi.de>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:46650 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753942AbZIJWPu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 18:15:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Randy Dunlap <randy.dunlap@oracle.com>

The netjet driver uses isdnhdlc interfaces (as does another ISDN
driver), so move that driver source file into the top-level
drivers/isdn/ directory and make it available to any ISDN drivers.

=46ixes these build errors:

ERROR: "isdnhdlc_decode" [drivers/isdn/hardware/mISDN/netjet.ko] undefi=
ned!
ERROR: "isdnhdlc_encode" [drivers/isdn/hardware/mISDN/netjet.ko] undefi=
ned!
ERROR: "isdnhdlc_out_init" [drivers/isdn/hardware/mISDN/netjet.ko] unde=
fined!
ERROR: "isdnhdlc_rcv_init" [drivers/isdn/hardware/mISDN/netjet.ko] unde=
fined!

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Karsten Keil <isdn@linux-pingi.de>
---
 drivers/isdn/Kconfig        |    5=20
 drivers/isdn/Makefile       |    2=20
 drivers/isdn/i4l/Kconfig    |    6=20
 drivers/isdn/i4l/Makefile   |    1=20
 drivers/isdn/i4l/isdnhdlc.c |  630 ----------------------------------
 drivers/isdn/isdnhdlc.c     |  630 ++++++++++++++++++++++++++++++++++
 6 files changed, 637 insertions(+), 637 deletions(-)

--- linux-next-20090909.orig/drivers/isdn/Makefile
+++ linux-next-20090909/drivers/isdn/Makefile
@@ -15,3 +15,5 @@ obj-$(CONFIG_ISDN_DRV_LOOP)		+=3D isdnloop
 obj-$(CONFIG_ISDN_DRV_ACT2000)		+=3D act2000/
 obj-$(CONFIG_HYSDN)			+=3D hysdn/
 obj-$(CONFIG_ISDN_DRV_GIGASET)		+=3D gigaset/
+
+obj-$(CONFIG_ISDN_HDLC)		+=3D isdnhdlc.o
--- linux-next-20090909.orig/drivers/isdn/i4l/Makefile
+++ linux-next-20090909/drivers/isdn/i4l/Makefile
@@ -4,7 +4,6 @@
=20
 obj-$(CONFIG_ISDN_I4L)		+=3D isdn.o
 obj-$(CONFIG_ISDN_PPP_BSDCOMP)	+=3D isdn_bsdcomp.o
-obj-$(CONFIG_ISDN_HDLC)		+=3D isdnhdlc.o
=20
 # Multipart objects.
=20
--- linux-next-20090909.orig/drivers/isdn/i4l/isdnhdlc.c
+++ /dev/null
@@ -1,630 +0,0 @@
-/*
- * isdnhdlc.c  --  General purpose ISDN HDLC decoder.
- *
- * Copyright (C)
- *	2009	Karsten Keil		<keil@b1-systems.de>
- *	2002	Wolfgang M=FCes		<wolfgang@iksw-muees.de>
- *	2001	Frode Isaksen		<fisaksen@bewan.com>
- *      2001	Kai Germaschewski	<kai.germaschewski@gmx.de>
- *
- * This program is free software; you can redistribute it and/or modif=
y
- * it under the terms of the GNU General Public License as published b=
y
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- */
-
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/crc-ccitt.h>
-#include <linux/isdn/hdlc.h>
-#include <linux/bitrev.h>
-
-/*-------------------------------------------------------------------*=
/
-
-MODULE_AUTHOR("Wolfgang M=FCes <wolfgang@iksw-muees.de>, "
-	      "Frode Isaksen <fisaksen@bewan.com>, "
-	      "Kai Germaschewski <kai.germaschewski@gmx.de>");
-MODULE_DESCRIPTION("General purpose ISDN HDLC decoder");
-MODULE_LICENSE("GPL");
-
-/*-------------------------------------------------------------------*=
/
-
-enum {
-	HDLC_FAST_IDLE, HDLC_GET_FLAG_B0, HDLC_GETFLAG_B1A6, HDLC_GETFLAG_B7,
-	HDLC_GET_DATA, HDLC_FAST_FLAG
-};
-
-enum {
-	HDLC_SEND_DATA, HDLC_SEND_CRC1, HDLC_SEND_FAST_FLAG,
-	HDLC_SEND_FIRST_FLAG, HDLC_SEND_CRC2, HDLC_SEND_CLOSING_FLAG,
-	HDLC_SEND_IDLE1, HDLC_SEND_FAST_IDLE, HDLC_SENDFLAG_B0,
-	HDLC_SENDFLAG_B1A6, HDLC_SENDFLAG_B7, STOPPED, HDLC_SENDFLAG_ONE
-};
-
-void isdnhdlc_rcv_init(struct isdnhdlc_vars *hdlc, u32 features)
-{
-	memset(hdlc, 0, sizeof(struct isdnhdlc_vars));
-	hdlc->state =3D HDLC_GET_DATA;
-	if (features & HDLC_56KBIT)
-		hdlc->do_adapt56 =3D 1;
-	if (features & HDLC_BITREVERSE)
-		hdlc->do_bitreverse =3D 1;
-}
-EXPORT_SYMBOL(isdnhdlc_out_init);
-
-void isdnhdlc_out_init(struct isdnhdlc_vars *hdlc, u32 features)
-{
-	memset(hdlc, 0, sizeof(struct isdnhdlc_vars));
-	if (features & HDLC_DCHANNEL) {
-		hdlc->dchannel =3D 1;
-		hdlc->state =3D HDLC_SEND_FIRST_FLAG;
-	} else {
-		hdlc->dchannel =3D 0;
-		hdlc->state =3D HDLC_SEND_FAST_FLAG;
-		hdlc->ffvalue =3D 0x7e;
-	}
-	hdlc->cbin =3D 0x7e;
-	if (features & HDLC_56KBIT) {
-		hdlc->do_adapt56 =3D 1;
-		hdlc->state =3D HDLC_SENDFLAG_B0;
-	} else
-		hdlc->data_bits =3D 8;
-	if (features & HDLC_BITREVERSE)
-		hdlc->do_bitreverse =3D 1;
-}
-EXPORT_SYMBOL(isdnhdlc_rcv_init);
-
-static int
-check_frame(struct isdnhdlc_vars *hdlc)
-{
-	int status;
-
-	if (hdlc->dstpos < 2) 	/* too small - framing error */
-		status =3D -HDLC_FRAMING_ERROR;
-	else if (hdlc->crc !=3D 0xf0b8)	/* crc error */
-		status =3D -HDLC_CRC_ERROR;
-	else {
-		/* remove CRC */
-		hdlc->dstpos -=3D 2;
-		/* good frame */
-		status =3D hdlc->dstpos;
-	}
-	return status;
-}
-
-/*
-  isdnhdlc_decode - decodes HDLC frames from a transparent bit stream.
-
-  The source buffer is scanned for valid HDLC frames looking for
-  flags (01111110) to indicate the start of a frame. If the start of
-  the frame is found, the bit stuffing is removed (0 after 5 1's).
-  When a new flag is found, the complete frame has been received
-  and the CRC is checked.
-  If a valid frame is found, the function returns the frame length
-  excluding the CRC with the bit HDLC_END_OF_FRAME set.
-  If the beginning of a valid frame is found, the function returns
-  the length.
-  If a framing error is found (too many 1s and not a flag) the functio=
n
-  returns the length with the bit HDLC_FRAMING_ERROR set.
-  If a CRC error is found the function returns the length with the
-  bit HDLC_CRC_ERROR set.
-  If the frame length exceeds the destination buffer size, the functio=
n
-  returns the length with the bit HDLC_LENGTH_ERROR set.
-
-  src - source buffer
-  slen - source buffer length
-  count - number of bytes removed (decoded) from the source buffer
-  dst _ destination buffer
-  dsize - destination buffer size
-  returns - number of decoded bytes in the destination buffer and stat=
us
-  flag.
- */
-int isdnhdlc_decode(struct isdnhdlc_vars *hdlc, const u8 *src, int sle=
n,
-	int *count, u8 *dst, int dsize)
-{
-	int status =3D 0;
-
-	static const unsigned char fast_flag[] =3D {
-		0x00, 0x00, 0x00, 0x20, 0x30, 0x38, 0x3c, 0x3e, 0x3f
-	};
-
-	static const unsigned char fast_flag_value[] =3D {
-		0x00, 0x7e, 0xfc, 0xf9, 0xf3, 0xe7, 0xcf, 0x9f, 0x3f
-	};
-
-	static const unsigned char fast_abort[] =3D {
-		0x00, 0x00, 0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe, 0xff
-	};
-
-#define handle_fast_flag(h) \
-	do {\
-		if (h->cbin =3D=3D fast_flag[h->bit_shift]) {\
-			h->ffvalue =3D fast_flag_value[h->bit_shift];\
-			h->state =3D HDLC_FAST_FLAG;\
-			h->ffbit_shift =3D h->bit_shift;\
-			h->bit_shift =3D 1;\
-		} else {\
-			h->state =3D HDLC_GET_DATA;\
-			h->data_received =3D 0;\
-		} \
-	} while (0)
-
-#define handle_abort(h) \
-	do {\
-		h->shift_reg =3D fast_abort[h->ffbit_shift - 1];\
-		h->hdlc_bits1 =3D h->ffbit_shift - 2;\
-		if (h->hdlc_bits1 < 0)\
-			h->hdlc_bits1 =3D 0;\
-		h->data_bits =3D h->ffbit_shift - 1;\
-		h->state =3D HDLC_GET_DATA;\
-		h->data_received =3D 0;\
-	} while (0)
-
-	*count =3D slen;
-
-	while (slen > 0) {
-		if (hdlc->bit_shift =3D=3D 0) {
-			/* the code is for bitreverse streams */
-			if (hdlc->do_bitreverse =3D=3D 0)
-				hdlc->cbin =3D bitrev8(*src++);
-			else
-				hdlc->cbin =3D *src++;
-			slen--;
-			hdlc->bit_shift =3D 8;
-			if (hdlc->do_adapt56)
-				hdlc->bit_shift--;
-		}
-
-		switch (hdlc->state) {
-		case STOPPED:
-			return 0;
-		case HDLC_FAST_IDLE:
-			if (hdlc->cbin =3D=3D 0xff) {
-				hdlc->bit_shift =3D 0;
-				break;
-			}
-			hdlc->state =3D HDLC_GET_FLAG_B0;
-			hdlc->hdlc_bits1 =3D 0;
-			hdlc->bit_shift =3D 8;
-			break;
-		case HDLC_GET_FLAG_B0:
-			if (!(hdlc->cbin & 0x80)) {
-				hdlc->state =3D HDLC_GETFLAG_B1A6;
-				hdlc->hdlc_bits1 =3D 0;
-			} else {
-				if ((!hdlc->do_adapt56) &&
-				    (++hdlc->hdlc_bits1 >=3D 8) &&
-				    (hdlc->bit_shift =3D=3D 1))
-						hdlc->state =3D HDLC_FAST_IDLE;
-			}
-			hdlc->cbin <<=3D 1;
-			hdlc->bit_shift--;
-			break;
-		case HDLC_GETFLAG_B1A6:
-			if (hdlc->cbin & 0x80) {
-				hdlc->hdlc_bits1++;
-				if (hdlc->hdlc_bits1 =3D=3D 6)
-					hdlc->state =3D HDLC_GETFLAG_B7;
-			} else
-				hdlc->hdlc_bits1 =3D 0;
-			hdlc->cbin <<=3D 1;
-			hdlc->bit_shift--;
-			break;
-		case HDLC_GETFLAG_B7:
-			if (hdlc->cbin & 0x80) {
-				hdlc->state =3D HDLC_GET_FLAG_B0;
-			} else {
-				hdlc->state =3D HDLC_GET_DATA;
-				hdlc->crc =3D 0xffff;
-				hdlc->shift_reg =3D 0;
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->data_bits =3D 0;
-				hdlc->data_received =3D 0;
-			}
-			hdlc->cbin <<=3D 1;
-			hdlc->bit_shift--;
-			break;
-		case HDLC_GET_DATA:
-			if (hdlc->cbin & 0x80) {
-				hdlc->hdlc_bits1++;
-				switch (hdlc->hdlc_bits1) {
-				case 6:
-					break;
-				case 7:
-					if (hdlc->data_received)
-						/* bad frame */
-						status =3D -HDLC_FRAMING_ERROR;
-					if (!hdlc->do_adapt56) {
-						if (hdlc->cbin =3D=3D fast_abort
-						    [hdlc->bit_shift + 1]) {
-							hdlc->state =3D
-								HDLC_FAST_IDLE;
-							hdlc->bit_shift =3D 1;
-							break;
-						}
-					} else
-						hdlc->state =3D HDLC_GET_FLAG_B0;
-					break;
-				default:
-					hdlc->shift_reg >>=3D 1;
-					hdlc->shift_reg |=3D 0x80;
-					hdlc->data_bits++;
-					break;
-				}
-			} else {
-				switch (hdlc->hdlc_bits1) {
-				case 5:
-					break;
-				case 6:
-					if (hdlc->data_received)
-						status =3D check_frame(hdlc);
-					hdlc->crc =3D 0xffff;
-					hdlc->shift_reg =3D 0;
-					hdlc->data_bits =3D 0;
-					if (!hdlc->do_adapt56)
-						handle_fast_flag(hdlc);
-					else {
-						hdlc->state =3D HDLC_GET_DATA;
-						hdlc->data_received =3D 0;
-					}
-					break;
-				default:
-					hdlc->shift_reg >>=3D 1;
-					hdlc->data_bits++;
-					break;
-				}
-				hdlc->hdlc_bits1 =3D 0;
-			}
-			if (status) {
-				hdlc->dstpos =3D 0;
-				*count -=3D slen;
-				hdlc->cbin <<=3D 1;
-				hdlc->bit_shift--;
-				return status;
-			}
-			if (hdlc->data_bits =3D=3D 8) {
-				hdlc->data_bits =3D 0;
-				hdlc->data_received =3D 1;
-				hdlc->crc =3D crc_ccitt_byte(hdlc->crc,
-						hdlc->shift_reg);
-
-				/* good byte received */
-				if (hdlc->dstpos < dsize)
-					dst[hdlc->dstpos++] =3D hdlc->shift_reg;
-				else {
-					/* frame too long */
-					status =3D -HDLC_LENGTH_ERROR;
-					hdlc->dstpos =3D 0;
-				}
-			}
-			hdlc->cbin <<=3D 1;
-			hdlc->bit_shift--;
-			break;
-		case HDLC_FAST_FLAG:
-			if (hdlc->cbin =3D=3D hdlc->ffvalue) {
-				hdlc->bit_shift =3D 0;
-				break;
-			} else {
-				if (hdlc->cbin =3D=3D 0xff) {
-					hdlc->state =3D HDLC_FAST_IDLE;
-					hdlc->bit_shift =3D 0;
-				} else if (hdlc->ffbit_shift =3D=3D 8) {
-					hdlc->state =3D HDLC_GETFLAG_B7;
-					break;
-				} else
-					handle_abort(hdlc);
-			}
-			break;
-		default:
-			break;
-		}
-	}
-	*count -=3D slen;
-	return 0;
-}
-EXPORT_SYMBOL(isdnhdlc_decode);
-/*
-  isdnhdlc_encode - encodes HDLC frames to a transparent bit stream.
-
-  The bit stream starts with a beginning flag (01111110). After
-  that each byte is added to the bit stream with bit stuffing added
-  (0 after 5 1's).
-  When the last byte has been removed from the source buffer, the
-  CRC (2 bytes is added) and the frame terminates with the ending flag=
=2E
-  For the dchannel, the idle character (all 1's) is also added at the =
end.
-  If this function is called with empty source buffer (slen=3D0), flag=
s or
-  idle character will be generated.
-
-  src - source buffer
-  slen - source buffer length
-  count - number of bytes removed (encoded) from source buffer
-  dst _ destination buffer
-  dsize - destination buffer size
-  returns - number of encoded bytes in the destination buffer
-*/
-int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const u8 *src, u16 sle=
n,
-	int *count, u8 *dst, int dsize)
-{
-	static const unsigned char xfast_flag_value[] =3D {
-		0x7e, 0x3f, 0x9f, 0xcf, 0xe7, 0xf3, 0xf9, 0xfc, 0x7e
-	};
-
-	int len =3D 0;
-
-	*count =3D slen;
-
-	/* special handling for one byte frames */
-	if ((slen =3D=3D 1) && (hdlc->state =3D=3D HDLC_SEND_FAST_FLAG))
-		hdlc->state =3D HDLC_SENDFLAG_ONE;
-	while (dsize > 0) {
-		if (hdlc->bit_shift =3D=3D 0) {
-			if (slen && !hdlc->do_closing) {
-				hdlc->shift_reg =3D *src++;
-				slen--;
-				if (slen =3D=3D 0)
-					/* closing sequence, CRC + flag(s) */
-					hdlc->do_closing =3D 1;
-				hdlc->bit_shift =3D 8;
-			} else {
-				if (hdlc->state =3D=3D HDLC_SEND_DATA) {
-					if (hdlc->data_received) {
-						hdlc->state =3D HDLC_SEND_CRC1;
-						hdlc->crc ^=3D 0xffff;
-						hdlc->bit_shift =3D 8;
-						hdlc->shift_reg =3D
-							hdlc->crc & 0xff;
-					} else if (!hdlc->do_adapt56)
-						hdlc->state =3D
-							HDLC_SEND_FAST_FLAG;
-					else
-						hdlc->state =3D
-							HDLC_SENDFLAG_B0;
-				}
-
-			}
-		}
-
-		switch (hdlc->state) {
-		case STOPPED:
-			while (dsize--)
-				*dst++ =3D 0xff;
-			return dsize;
-		case HDLC_SEND_FAST_FLAG:
-			hdlc->do_closing =3D 0;
-			if (slen =3D=3D 0) {
-				/* the code is for bitreverse streams */
-				if (hdlc->do_bitreverse =3D=3D 0)
-					*dst++ =3D bitrev8(hdlc->ffvalue);
-				else
-					*dst++ =3D hdlc->ffvalue;
-				len++;
-				dsize--;
-				break;
-			}
-			/* fall through */
-		case HDLC_SENDFLAG_ONE:
-			if (hdlc->bit_shift =3D=3D 8) {
-				hdlc->cbin =3D hdlc->ffvalue >>
-					(8 - hdlc->data_bits);
-				hdlc->state =3D HDLC_SEND_DATA;
-				hdlc->crc =3D 0xffff;
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->data_received =3D 1;
-			}
-			break;
-		case HDLC_SENDFLAG_B0:
-			hdlc->do_closing =3D 0;
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			hdlc->hdlc_bits1 =3D 0;
-			hdlc->state =3D HDLC_SENDFLAG_B1A6;
-			break;
-		case HDLC_SENDFLAG_B1A6:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			hdlc->cbin++;
-			if (++hdlc->hdlc_bits1 =3D=3D 6)
-				hdlc->state =3D HDLC_SENDFLAG_B7;
-			break;
-		case HDLC_SENDFLAG_B7:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if (slen =3D=3D 0) {
-				hdlc->state =3D HDLC_SENDFLAG_B0;
-				break;
-			}
-			if (hdlc->bit_shift =3D=3D 8) {
-				hdlc->state =3D HDLC_SEND_DATA;
-				hdlc->crc =3D 0xffff;
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->data_received =3D 1;
-			}
-			break;
-		case HDLC_SEND_FIRST_FLAG:
-			hdlc->data_received =3D 1;
-			if (hdlc->data_bits =3D=3D 8) {
-				hdlc->state =3D HDLC_SEND_DATA;
-				hdlc->crc =3D 0xffff;
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if (hdlc->shift_reg & 0x01)
-				hdlc->cbin++;
-			hdlc->shift_reg >>=3D 1;
-			hdlc->bit_shift--;
-			if (hdlc->bit_shift =3D=3D 0) {
-				hdlc->state =3D HDLC_SEND_DATA;
-				hdlc->crc =3D 0xffff;
-				hdlc->hdlc_bits1 =3D 0;
-			}
-			break;
-		case HDLC_SEND_DATA:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if (hdlc->hdlc_bits1 =3D=3D 5) {
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			if (hdlc->bit_shift =3D=3D 8)
-				hdlc->crc =3D crc_ccitt_byte(hdlc->crc,
-					hdlc->shift_reg);
-			if (hdlc->shift_reg & 0x01) {
-				hdlc->hdlc_bits1++;
-				hdlc->cbin++;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			} else {
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			}
-			break;
-		case HDLC_SEND_CRC1:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if (hdlc->hdlc_bits1 =3D=3D 5) {
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			if (hdlc->shift_reg & 0x01) {
-				hdlc->hdlc_bits1++;
-				hdlc->cbin++;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			} else {
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			}
-			if (hdlc->bit_shift =3D=3D 0) {
-				hdlc->shift_reg =3D (hdlc->crc >> 8);
-				hdlc->state =3D HDLC_SEND_CRC2;
-				hdlc->bit_shift =3D 8;
-			}
-			break;
-		case HDLC_SEND_CRC2:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if (hdlc->hdlc_bits1 =3D=3D 5) {
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			if (hdlc->shift_reg & 0x01) {
-				hdlc->hdlc_bits1++;
-				hdlc->cbin++;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			} else {
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			}
-			if (hdlc->bit_shift =3D=3D 0) {
-				hdlc->shift_reg =3D 0x7e;
-				hdlc->state =3D HDLC_SEND_CLOSING_FLAG;
-				hdlc->bit_shift =3D 8;
-			}
-			break;
-		case HDLC_SEND_CLOSING_FLAG:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if (hdlc->hdlc_bits1 =3D=3D 5) {
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			if (hdlc->shift_reg & 0x01)
-				hdlc->cbin++;
-			hdlc->shift_reg >>=3D 1;
-			hdlc->bit_shift--;
-			if (hdlc->bit_shift =3D=3D 0) {
-				hdlc->ffvalue =3D
-					xfast_flag_value[hdlc->data_bits];
-				if (hdlc->dchannel) {
-					hdlc->ffvalue =3D 0x7e;
-					hdlc->state =3D HDLC_SEND_IDLE1;
-					hdlc->bit_shift =3D 8-hdlc->data_bits;
-					if (hdlc->bit_shift =3D=3D 0)
-						hdlc->state =3D
-							HDLC_SEND_FAST_IDLE;
-				} else {
-					if (!hdlc->do_adapt56) {
-						hdlc->state =3D
-							HDLC_SEND_FAST_FLAG;
-						hdlc->data_received =3D 0;
-					} else {
-						hdlc->state =3D HDLC_SENDFLAG_B0;
-						hdlc->data_received =3D 0;
-					}
-					/* Finished this frame, send flags */
-					if (dsize > 1)
-						dsize =3D 1;
-				}
-			}
-			break;
-		case HDLC_SEND_IDLE1:
-			hdlc->do_closing =3D 0;
-			hdlc->cbin <<=3D 1;
-			hdlc->cbin++;
-			hdlc->data_bits++;
-			hdlc->bit_shift--;
-			if (hdlc->bit_shift =3D=3D 0) {
-				hdlc->state =3D HDLC_SEND_FAST_IDLE;
-				hdlc->bit_shift =3D 0;
-			}
-			break;
-		case HDLC_SEND_FAST_IDLE:
-			hdlc->do_closing =3D 0;
-			hdlc->cbin =3D 0xff;
-			hdlc->data_bits =3D 8;
-			if (hdlc->bit_shift =3D=3D 8) {
-				hdlc->cbin =3D 0x7e;
-				hdlc->state =3D HDLC_SEND_FIRST_FLAG;
-			} else {
-				/* the code is for bitreverse streams */
-				if (hdlc->do_bitreverse =3D=3D 0)
-					*dst++ =3D bitrev8(hdlc->cbin);
-				else
-					*dst++ =3D hdlc->cbin;
-				hdlc->bit_shift =3D 0;
-				hdlc->data_bits =3D 0;
-				len++;
-				dsize =3D 0;
-			}
-			break;
-		default:
-			break;
-		}
-		if (hdlc->do_adapt56) {
-			if (hdlc->data_bits =3D=3D 7) {
-				hdlc->cbin <<=3D 1;
-				hdlc->cbin++;
-				hdlc->data_bits++;
-			}
-		}
-		if (hdlc->data_bits =3D=3D 8) {
-			/* the code is for bitreverse streams */
-			if (hdlc->do_bitreverse =3D=3D 0)
-				*dst++ =3D bitrev8(hdlc->cbin);
-			else
-				*dst++ =3D hdlc->cbin;
-			hdlc->data_bits =3D 0;
-			len++;
-			dsize--;
-		}
-	}
-	*count -=3D slen;
-
-	return len;
-}
-EXPORT_SYMBOL(isdnhdlc_encode);
--- /dev/null
+++ linux-next-20090909/drivers/isdn/isdnhdlc.c
@@ -0,0 +1,630 @@
+/*
+ * isdnhdlc.c  --  General purpose ISDN HDLC decoder.
+ *
+ * Copyright (C)
+ *	2009	Karsten Keil		<keil@b1-systems.de>
+ *	2002	Wolfgang M=FCes		<wolfgang@iksw-muees.de>
+ *	2001	Frode Isaksen		<fisaksen@bewan.com>
+ *      2001	Kai Germaschewski	<kai.germaschewski@gmx.de>
+ *
+ * This program is free software; you can redistribute it and/or modif=
y
+ * it under the terms of the GNU General Public License as published b=
y
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/crc-ccitt.h>
+#include <linux/isdn/hdlc.h>
+#include <linux/bitrev.h>
+
+/*-------------------------------------------------------------------*=
/
+
+MODULE_AUTHOR("Wolfgang M=FCes <wolfgang@iksw-muees.de>, "
+	      "Frode Isaksen <fisaksen@bewan.com>, "
+	      "Kai Germaschewski <kai.germaschewski@gmx.de>");
+MODULE_DESCRIPTION("General purpose ISDN HDLC decoder");
+MODULE_LICENSE("GPL");
+
+/*-------------------------------------------------------------------*=
/
+
+enum {
+	HDLC_FAST_IDLE, HDLC_GET_FLAG_B0, HDLC_GETFLAG_B1A6, HDLC_GETFLAG_B7,
+	HDLC_GET_DATA, HDLC_FAST_FLAG
+};
+
+enum {
+	HDLC_SEND_DATA, HDLC_SEND_CRC1, HDLC_SEND_FAST_FLAG,
+	HDLC_SEND_FIRST_FLAG, HDLC_SEND_CRC2, HDLC_SEND_CLOSING_FLAG,
+	HDLC_SEND_IDLE1, HDLC_SEND_FAST_IDLE, HDLC_SENDFLAG_B0,
+	HDLC_SENDFLAG_B1A6, HDLC_SENDFLAG_B7, STOPPED, HDLC_SENDFLAG_ONE
+};
+
+void isdnhdlc_rcv_init(struct isdnhdlc_vars *hdlc, u32 features)
+{
+	memset(hdlc, 0, sizeof(struct isdnhdlc_vars));
+	hdlc->state =3D HDLC_GET_DATA;
+	if (features & HDLC_56KBIT)
+		hdlc->do_adapt56 =3D 1;
+	if (features & HDLC_BITREVERSE)
+		hdlc->do_bitreverse =3D 1;
+}
+EXPORT_SYMBOL(isdnhdlc_out_init);
+
+void isdnhdlc_out_init(struct isdnhdlc_vars *hdlc, u32 features)
+{
+	memset(hdlc, 0, sizeof(struct isdnhdlc_vars));
+	if (features & HDLC_DCHANNEL) {
+		hdlc->dchannel =3D 1;
+		hdlc->state =3D HDLC_SEND_FIRST_FLAG;
+	} else {
+		hdlc->dchannel =3D 0;
+		hdlc->state =3D HDLC_SEND_FAST_FLAG;
+		hdlc->ffvalue =3D 0x7e;
+	}
+	hdlc->cbin =3D 0x7e;
+	if (features & HDLC_56KBIT) {
+		hdlc->do_adapt56 =3D 1;
+		hdlc->state =3D HDLC_SENDFLAG_B0;
+	} else
+		hdlc->data_bits =3D 8;
+	if (features & HDLC_BITREVERSE)
+		hdlc->do_bitreverse =3D 1;
+}
+EXPORT_SYMBOL(isdnhdlc_rcv_init);
+
+static int
+check_frame(struct isdnhdlc_vars *hdlc)
+{
+	int status;
+
+	if (hdlc->dstpos < 2) 	/* too small - framing error */
+		status =3D -HDLC_FRAMING_ERROR;
+	else if (hdlc->crc !=3D 0xf0b8)	/* crc error */
+		status =3D -HDLC_CRC_ERROR;
+	else {
+		/* remove CRC */
+		hdlc->dstpos -=3D 2;
+		/* good frame */
+		status =3D hdlc->dstpos;
+	}
+	return status;
+}
+
+/*
+  isdnhdlc_decode - decodes HDLC frames from a transparent bit stream.
+
+  The source buffer is scanned for valid HDLC frames looking for
+  flags (01111110) to indicate the start of a frame. If the start of
+  the frame is found, the bit stuffing is removed (0 after 5 1's).
+  When a new flag is found, the complete frame has been received
+  and the CRC is checked.
+  If a valid frame is found, the function returns the frame length
+  excluding the CRC with the bit HDLC_END_OF_FRAME set.
+  If the beginning of a valid frame is found, the function returns
+  the length.
+  If a framing error is found (too many 1s and not a flag) the functio=
n
+  returns the length with the bit HDLC_FRAMING_ERROR set.
+  If a CRC error is found the function returns the length with the
+  bit HDLC_CRC_ERROR set.
+  If the frame length exceeds the destination buffer size, the functio=
n
+  returns the length with the bit HDLC_LENGTH_ERROR set.
+
+  src - source buffer
+  slen - source buffer length
+  count - number of bytes removed (decoded) from the source buffer
+  dst _ destination buffer
+  dsize - destination buffer size
+  returns - number of decoded bytes in the destination buffer and stat=
us
+  flag.
+ */
+int isdnhdlc_decode(struct isdnhdlc_vars *hdlc, const u8 *src, int sle=
n,
+	int *count, u8 *dst, int dsize)
+{
+	int status =3D 0;
+
+	static const unsigned char fast_flag[] =3D {
+		0x00, 0x00, 0x00, 0x20, 0x30, 0x38, 0x3c, 0x3e, 0x3f
+	};
+
+	static const unsigned char fast_flag_value[] =3D {
+		0x00, 0x7e, 0xfc, 0xf9, 0xf3, 0xe7, 0xcf, 0x9f, 0x3f
+	};
+
+	static const unsigned char fast_abort[] =3D {
+		0x00, 0x00, 0x80, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc, 0xfe, 0xff
+	};
+
+#define handle_fast_flag(h) \
+	do {\
+		if (h->cbin =3D=3D fast_flag[h->bit_shift]) {\
+			h->ffvalue =3D fast_flag_value[h->bit_shift];\
+			h->state =3D HDLC_FAST_FLAG;\
+			h->ffbit_shift =3D h->bit_shift;\
+			h->bit_shift =3D 1;\
+		} else {\
+			h->state =3D HDLC_GET_DATA;\
+			h->data_received =3D 0;\
+		} \
+	} while (0)
+
+#define handle_abort(h) \
+	do {\
+		h->shift_reg =3D fast_abort[h->ffbit_shift - 1];\
+		h->hdlc_bits1 =3D h->ffbit_shift - 2;\
+		if (h->hdlc_bits1 < 0)\
+			h->hdlc_bits1 =3D 0;\
+		h->data_bits =3D h->ffbit_shift - 1;\
+		h->state =3D HDLC_GET_DATA;\
+		h->data_received =3D 0;\
+	} while (0)
+
+	*count =3D slen;
+
+	while (slen > 0) {
+		if (hdlc->bit_shift =3D=3D 0) {
+			/* the code is for bitreverse streams */
+			if (hdlc->do_bitreverse =3D=3D 0)
+				hdlc->cbin =3D bitrev8(*src++);
+			else
+				hdlc->cbin =3D *src++;
+			slen--;
+			hdlc->bit_shift =3D 8;
+			if (hdlc->do_adapt56)
+				hdlc->bit_shift--;
+		}
+
+		switch (hdlc->state) {
+		case STOPPED:
+			return 0;
+		case HDLC_FAST_IDLE:
+			if (hdlc->cbin =3D=3D 0xff) {
+				hdlc->bit_shift =3D 0;
+				break;
+			}
+			hdlc->state =3D HDLC_GET_FLAG_B0;
+			hdlc->hdlc_bits1 =3D 0;
+			hdlc->bit_shift =3D 8;
+			break;
+		case HDLC_GET_FLAG_B0:
+			if (!(hdlc->cbin & 0x80)) {
+				hdlc->state =3D HDLC_GETFLAG_B1A6;
+				hdlc->hdlc_bits1 =3D 0;
+			} else {
+				if ((!hdlc->do_adapt56) &&
+				    (++hdlc->hdlc_bits1 >=3D 8) &&
+				    (hdlc->bit_shift =3D=3D 1))
+						hdlc->state =3D HDLC_FAST_IDLE;
+			}
+			hdlc->cbin <<=3D 1;
+			hdlc->bit_shift--;
+			break;
+		case HDLC_GETFLAG_B1A6:
+			if (hdlc->cbin & 0x80) {
+				hdlc->hdlc_bits1++;
+				if (hdlc->hdlc_bits1 =3D=3D 6)
+					hdlc->state =3D HDLC_GETFLAG_B7;
+			} else
+				hdlc->hdlc_bits1 =3D 0;
+			hdlc->cbin <<=3D 1;
+			hdlc->bit_shift--;
+			break;
+		case HDLC_GETFLAG_B7:
+			if (hdlc->cbin & 0x80) {
+				hdlc->state =3D HDLC_GET_FLAG_B0;
+			} else {
+				hdlc->state =3D HDLC_GET_DATA;
+				hdlc->crc =3D 0xffff;
+				hdlc->shift_reg =3D 0;
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->data_bits =3D 0;
+				hdlc->data_received =3D 0;
+			}
+			hdlc->cbin <<=3D 1;
+			hdlc->bit_shift--;
+			break;
+		case HDLC_GET_DATA:
+			if (hdlc->cbin & 0x80) {
+				hdlc->hdlc_bits1++;
+				switch (hdlc->hdlc_bits1) {
+				case 6:
+					break;
+				case 7:
+					if (hdlc->data_received)
+						/* bad frame */
+						status =3D -HDLC_FRAMING_ERROR;
+					if (!hdlc->do_adapt56) {
+						if (hdlc->cbin =3D=3D fast_abort
+						    [hdlc->bit_shift + 1]) {
+							hdlc->state =3D
+								HDLC_FAST_IDLE;
+							hdlc->bit_shift =3D 1;
+							break;
+						}
+					} else
+						hdlc->state =3D HDLC_GET_FLAG_B0;
+					break;
+				default:
+					hdlc->shift_reg >>=3D 1;
+					hdlc->shift_reg |=3D 0x80;
+					hdlc->data_bits++;
+					break;
+				}
+			} else {
+				switch (hdlc->hdlc_bits1) {
+				case 5:
+					break;
+				case 6:
+					if (hdlc->data_received)
+						status =3D check_frame(hdlc);
+					hdlc->crc =3D 0xffff;
+					hdlc->shift_reg =3D 0;
+					hdlc->data_bits =3D 0;
+					if (!hdlc->do_adapt56)
+						handle_fast_flag(hdlc);
+					else {
+						hdlc->state =3D HDLC_GET_DATA;
+						hdlc->data_received =3D 0;
+					}
+					break;
+				default:
+					hdlc->shift_reg >>=3D 1;
+					hdlc->data_bits++;
+					break;
+				}
+				hdlc->hdlc_bits1 =3D 0;
+			}
+			if (status) {
+				hdlc->dstpos =3D 0;
+				*count -=3D slen;
+				hdlc->cbin <<=3D 1;
+				hdlc->bit_shift--;
+				return status;
+			}
+			if (hdlc->data_bits =3D=3D 8) {
+				hdlc->data_bits =3D 0;
+				hdlc->data_received =3D 1;
+				hdlc->crc =3D crc_ccitt_byte(hdlc->crc,
+						hdlc->shift_reg);
+
+				/* good byte received */
+				if (hdlc->dstpos < dsize)
+					dst[hdlc->dstpos++] =3D hdlc->shift_reg;
+				else {
+					/* frame too long */
+					status =3D -HDLC_LENGTH_ERROR;
+					hdlc->dstpos =3D 0;
+				}
+			}
+			hdlc->cbin <<=3D 1;
+			hdlc->bit_shift--;
+			break;
+		case HDLC_FAST_FLAG:
+			if (hdlc->cbin =3D=3D hdlc->ffvalue) {
+				hdlc->bit_shift =3D 0;
+				break;
+			} else {
+				if (hdlc->cbin =3D=3D 0xff) {
+					hdlc->state =3D HDLC_FAST_IDLE;
+					hdlc->bit_shift =3D 0;
+				} else if (hdlc->ffbit_shift =3D=3D 8) {
+					hdlc->state =3D HDLC_GETFLAG_B7;
+					break;
+				} else
+					handle_abort(hdlc);
+			}
+			break;
+		default:
+			break;
+		}
+	}
+	*count -=3D slen;
+	return 0;
+}
+EXPORT_SYMBOL(isdnhdlc_decode);
+/*
+  isdnhdlc_encode - encodes HDLC frames to a transparent bit stream.
+
+  The bit stream starts with a beginning flag (01111110). After
+  that each byte is added to the bit stream with bit stuffing added
+  (0 after 5 1's).
+  When the last byte has been removed from the source buffer, the
+  CRC (2 bytes is added) and the frame terminates with the ending flag=
=2E
+  For the dchannel, the idle character (all 1's) is also added at the =
end.
+  If this function is called with empty source buffer (slen=3D0), flag=
s or
+  idle character will be generated.
+
+  src - source buffer
+  slen - source buffer length
+  count - number of bytes removed (encoded) from source buffer
+  dst _ destination buffer
+  dsize - destination buffer size
+  returns - number of encoded bytes in the destination buffer
+*/
+int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const u8 *src, u16 sle=
n,
+	int *count, u8 *dst, int dsize)
+{
+	static const unsigned char xfast_flag_value[] =3D {
+		0x7e, 0x3f, 0x9f, 0xcf, 0xe7, 0xf3, 0xf9, 0xfc, 0x7e
+	};
+
+	int len =3D 0;
+
+	*count =3D slen;
+
+	/* special handling for one byte frames */
+	if ((slen =3D=3D 1) && (hdlc->state =3D=3D HDLC_SEND_FAST_FLAG))
+		hdlc->state =3D HDLC_SENDFLAG_ONE;
+	while (dsize > 0) {
+		if (hdlc->bit_shift =3D=3D 0) {
+			if (slen && !hdlc->do_closing) {
+				hdlc->shift_reg =3D *src++;
+				slen--;
+				if (slen =3D=3D 0)
+					/* closing sequence, CRC + flag(s) */
+					hdlc->do_closing =3D 1;
+				hdlc->bit_shift =3D 8;
+			} else {
+				if (hdlc->state =3D=3D HDLC_SEND_DATA) {
+					if (hdlc->data_received) {
+						hdlc->state =3D HDLC_SEND_CRC1;
+						hdlc->crc ^=3D 0xffff;
+						hdlc->bit_shift =3D 8;
+						hdlc->shift_reg =3D
+							hdlc->crc & 0xff;
+					} else if (!hdlc->do_adapt56)
+						hdlc->state =3D
+							HDLC_SEND_FAST_FLAG;
+					else
+						hdlc->state =3D
+							HDLC_SENDFLAG_B0;
+				}
+
+			}
+		}
+
+		switch (hdlc->state) {
+		case STOPPED:
+			while (dsize--)
+				*dst++ =3D 0xff;
+			return dsize;
+		case HDLC_SEND_FAST_FLAG:
+			hdlc->do_closing =3D 0;
+			if (slen =3D=3D 0) {
+				/* the code is for bitreverse streams */
+				if (hdlc->do_bitreverse =3D=3D 0)
+					*dst++ =3D bitrev8(hdlc->ffvalue);
+				else
+					*dst++ =3D hdlc->ffvalue;
+				len++;
+				dsize--;
+				break;
+			}
+			/* fall through */
+		case HDLC_SENDFLAG_ONE:
+			if (hdlc->bit_shift =3D=3D 8) {
+				hdlc->cbin =3D hdlc->ffvalue >>
+					(8 - hdlc->data_bits);
+				hdlc->state =3D HDLC_SEND_DATA;
+				hdlc->crc =3D 0xffff;
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->data_received =3D 1;
+			}
+			break;
+		case HDLC_SENDFLAG_B0:
+			hdlc->do_closing =3D 0;
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			hdlc->hdlc_bits1 =3D 0;
+			hdlc->state =3D HDLC_SENDFLAG_B1A6;
+			break;
+		case HDLC_SENDFLAG_B1A6:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			hdlc->cbin++;
+			if (++hdlc->hdlc_bits1 =3D=3D 6)
+				hdlc->state =3D HDLC_SENDFLAG_B7;
+			break;
+		case HDLC_SENDFLAG_B7:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if (slen =3D=3D 0) {
+				hdlc->state =3D HDLC_SENDFLAG_B0;
+				break;
+			}
+			if (hdlc->bit_shift =3D=3D 8) {
+				hdlc->state =3D HDLC_SEND_DATA;
+				hdlc->crc =3D 0xffff;
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->data_received =3D 1;
+			}
+			break;
+		case HDLC_SEND_FIRST_FLAG:
+			hdlc->data_received =3D 1;
+			if (hdlc->data_bits =3D=3D 8) {
+				hdlc->state =3D HDLC_SEND_DATA;
+				hdlc->crc =3D 0xffff;
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if (hdlc->shift_reg & 0x01)
+				hdlc->cbin++;
+			hdlc->shift_reg >>=3D 1;
+			hdlc->bit_shift--;
+			if (hdlc->bit_shift =3D=3D 0) {
+				hdlc->state =3D HDLC_SEND_DATA;
+				hdlc->crc =3D 0xffff;
+				hdlc->hdlc_bits1 =3D 0;
+			}
+			break;
+		case HDLC_SEND_DATA:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if (hdlc->hdlc_bits1 =3D=3D 5) {
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			if (hdlc->bit_shift =3D=3D 8)
+				hdlc->crc =3D crc_ccitt_byte(hdlc->crc,
+					hdlc->shift_reg);
+			if (hdlc->shift_reg & 0x01) {
+				hdlc->hdlc_bits1++;
+				hdlc->cbin++;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			} else {
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			}
+			break;
+		case HDLC_SEND_CRC1:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if (hdlc->hdlc_bits1 =3D=3D 5) {
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			if (hdlc->shift_reg & 0x01) {
+				hdlc->hdlc_bits1++;
+				hdlc->cbin++;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			} else {
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			}
+			if (hdlc->bit_shift =3D=3D 0) {
+				hdlc->shift_reg =3D (hdlc->crc >> 8);
+				hdlc->state =3D HDLC_SEND_CRC2;
+				hdlc->bit_shift =3D 8;
+			}
+			break;
+		case HDLC_SEND_CRC2:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if (hdlc->hdlc_bits1 =3D=3D 5) {
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			if (hdlc->shift_reg & 0x01) {
+				hdlc->hdlc_bits1++;
+				hdlc->cbin++;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			} else {
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			}
+			if (hdlc->bit_shift =3D=3D 0) {
+				hdlc->shift_reg =3D 0x7e;
+				hdlc->state =3D HDLC_SEND_CLOSING_FLAG;
+				hdlc->bit_shift =3D 8;
+			}
+			break;
+		case HDLC_SEND_CLOSING_FLAG:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if (hdlc->hdlc_bits1 =3D=3D 5) {
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			if (hdlc->shift_reg & 0x01)
+				hdlc->cbin++;
+			hdlc->shift_reg >>=3D 1;
+			hdlc->bit_shift--;
+			if (hdlc->bit_shift =3D=3D 0) {
+				hdlc->ffvalue =3D
+					xfast_flag_value[hdlc->data_bits];
+				if (hdlc->dchannel) {
+					hdlc->ffvalue =3D 0x7e;
+					hdlc->state =3D HDLC_SEND_IDLE1;
+					hdlc->bit_shift =3D 8-hdlc->data_bits;
+					if (hdlc->bit_shift =3D=3D 0)
+						hdlc->state =3D
+							HDLC_SEND_FAST_IDLE;
+				} else {
+					if (!hdlc->do_adapt56) {
+						hdlc->state =3D
+							HDLC_SEND_FAST_FLAG;
+						hdlc->data_received =3D 0;
+					} else {
+						hdlc->state =3D HDLC_SENDFLAG_B0;
+						hdlc->data_received =3D 0;
+					}
+					/* Finished this frame, send flags */
+					if (dsize > 1)
+						dsize =3D 1;
+				}
+			}
+			break;
+		case HDLC_SEND_IDLE1:
+			hdlc->do_closing =3D 0;
+			hdlc->cbin <<=3D 1;
+			hdlc->cbin++;
+			hdlc->data_bits++;
+			hdlc->bit_shift--;
+			if (hdlc->bit_shift =3D=3D 0) {
+				hdlc->state =3D HDLC_SEND_FAST_IDLE;
+				hdlc->bit_shift =3D 0;
+			}
+			break;
+		case HDLC_SEND_FAST_IDLE:
+			hdlc->do_closing =3D 0;
+			hdlc->cbin =3D 0xff;
+			hdlc->data_bits =3D 8;
+			if (hdlc->bit_shift =3D=3D 8) {
+				hdlc->cbin =3D 0x7e;
+				hdlc->state =3D HDLC_SEND_FIRST_FLAG;
+			} else {
+				/* the code is for bitreverse streams */
+				if (hdlc->do_bitreverse =3D=3D 0)
+					*dst++ =3D bitrev8(hdlc->cbin);
+				else
+					*dst++ =3D hdlc->cbin;
+				hdlc->bit_shift =3D 0;
+				hdlc->data_bits =3D 0;
+				len++;
+				dsize =3D 0;
+			}
+			break;
+		default:
+			break;
+		}
+		if (hdlc->do_adapt56) {
+			if (hdlc->data_bits =3D=3D 7) {
+				hdlc->cbin <<=3D 1;
+				hdlc->cbin++;
+				hdlc->data_bits++;
+			}
+		}
+		if (hdlc->data_bits =3D=3D 8) {
+			/* the code is for bitreverse streams */
+			if (hdlc->do_bitreverse =3D=3D 0)
+				*dst++ =3D bitrev8(hdlc->cbin);
+			else
+				*dst++ =3D hdlc->cbin;
+			hdlc->data_bits =3D 0;
+			len++;
+			dsize--;
+		}
+	}
+	*count -=3D slen;
+
+	return len;
+}
+EXPORT_SYMBOL(isdnhdlc_encode);
--- linux-next-20090909.orig/drivers/isdn/Kconfig
+++ linux-next-20090909/drivers/isdn/Kconfig
@@ -61,4 +61,9 @@ endif # ISDN_CAPI
=20
 source "drivers/isdn/gigaset/Kconfig"
=20
+config ISDN_HDLC
+	tristate
+	select CRC_CCITT
+	select BITREVERSE
+
 endif # ISDN
--- linux-next-20090909.orig/drivers/isdn/i4l/Kconfig
+++ linux-next-20090909/drivers/isdn/i4l/Kconfig
@@ -140,9 +140,3 @@ endmenu
 # end ISDN_I4L
 endif
=20
-config ISDN_HDLC
-	tristate=20
-	depends on HISAX_ST5481
-	select CRC_CCITT
-	select BITREVERSE
-




---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
