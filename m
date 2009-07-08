From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 01/13] ISDN: Make isdnhdlc usable for other ISDN drivers
Date: Wed, 8 Jul 2009 14:21:12 +0200
Message-ID: <cb3824bade2549d7ad059d5802da43312540fdee.1248546896.git.keil@b1-systems.de>
References: <cover.1248546896.git.keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from d112a2.x-mailer.de ([212.162.53.4]:57610 "EHLO
	d112a2.x-mailer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbZGYVCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 17:02:30 -0400
In-Reply-To: <cover.1248546896.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

isdnhdlc is useful for other ISDN drivers as well.
Move the include file to a central location and the source
to the central isdn location.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/Kconfig          |    6 +-
 drivers/isdn/hisax/Kconfig    |    6 +-
 drivers/isdn/hisax/Makefile   |    4 -
 drivers/isdn/hisax/isdnhdlc.c |  603 ---------------------------------=
--------
 drivers/isdn/hisax/isdnhdlc.h |   70 -----
 drivers/isdn/hisax/st5481.h   |    2 +-
 drivers/isdn/i4l/Kconfig      |   11 +
 drivers/isdn/i4l/Makefile     |    1 +
 drivers/isdn/i4l/isdnhdlc.c   |  603 +++++++++++++++++++++++++++++++++=
++++++++
 include/linux/isdn/hdlc.h     |   70 +++++
 10 files changed, 689 insertions(+), 687 deletions(-)
 delete mode 100644 drivers/isdn/hisax/isdnhdlc.c
 delete mode 100644 drivers/isdn/hisax/isdnhdlc.h
 create mode 100644 drivers/isdn/i4l/isdnhdlc.c
 create mode 100644 include/linux/isdn/hdlc.h

diff --git a/drivers/isdn/Kconfig b/drivers/isdn/Kconfig
index 02bdca6..022a194 100644
--- a/drivers/isdn/Kconfig
+++ b/drivers/isdn/Kconfig
@@ -21,8 +21,6 @@ menuconfig ISDN
=20
 if ISDN
=20
-source "drivers/isdn/mISDN/Kconfig"
-
 menuconfig ISDN_I4L
 	tristate "Old ISDN4Linux (deprecated)"
 	---help---
@@ -41,9 +39,9 @@ menuconfig ISDN_I4L
 	  It is still available, though, for use with adapters that are not
 	  supported by the new CAPI subsystem yet.
=20
-if ISDN_I4L
+source "drivers/isdn/mISDN/Kconfig"
+
 source "drivers/isdn/i4l/Kconfig"
-endif
=20
 menuconfig ISDN_CAPI
 	tristate "CAPI 2.0 subsystem"
diff --git a/drivers/isdn/hisax/Kconfig b/drivers/isdn/hisax/Kconfig
index 7832d8b..3464ebc 100644
--- a/drivers/isdn/hisax/Kconfig
+++ b/drivers/isdn/hisax/Kconfig
@@ -391,6 +391,7 @@ comment "HiSax sub driver modules"
 config HISAX_ST5481
 	tristate "ST5481 USB ISDN modem (EXPERIMENTAL)"
 	depends on USB && EXPERIMENTAL
+	select ISDN_HDLC
 	select CRC_CCITT
 	select BITREVERSE
 	help
@@ -418,11 +419,6 @@ config HISAX_FRITZ_PCIPNP
 	  (the latter also needs you to select "ISA Plug and Play support"
 	  from the menu "Plug and Play configuration")
=20
-config HISAX_HDLC
-	bool
-	depends on HISAX_ST5481
-	default y
-
 config HISAX_AVM_A1_PCMCIA
 	bool
 	depends on HISAX_AVM_A1_CS
diff --git a/drivers/isdn/hisax/Makefile b/drivers/isdn/hisax/Makefile
index c7a3794..ab638b0 100644
--- a/drivers/isdn/hisax/Makefile
+++ b/drivers/isdn/hisax/Makefile
@@ -16,10 +16,6 @@ obj-$(CONFIG_HISAX_HFCUSB)		+=3D hfc_usb.o
 obj-$(CONFIG_HISAX_HFC4S8S)		+=3D hfc4s8s_l1.o
 obj-$(CONFIG_HISAX_FRITZ_PCIPNP)        +=3D hisax_isac.o hisax_fcpcip=
np.o
=20
-ifdef CONFIG_HISAX_HDLC
-obj-$(CONFIG_ISDN_DRV_HISAX)		+=3D isdnhdlc.o
-endif
-
 # Multipart objects.
=20
 hisax_st5481-y 				:=3D st5481_init.o st5481_usb.o st5481_d.o \
diff --git a/drivers/isdn/hisax/isdnhdlc.c b/drivers/isdn/hisax/isdnhdl=
c.c
deleted file mode 100644
index c69a77a..0000000
--- a/drivers/isdn/hisax/isdnhdlc.c
+++ /dev/null
@@ -1,603 +0,0 @@
-/*
- * isdnhdlc.c  --  General purpose ISDN HDLC decoder.
- *
- *Copyright (C) 2002	Wolfgang M=C3=BCes      <wolfgang@iksw-muees.de>
- *		2001 	Frode Isaksen      <fisaksen@bewan.com>
- *              2001 	Kai Germaschewski  <kai.germaschewski@gmx.de>
- *
- *      This program is free software; you can redistribute it and/or =
modify
- *      it under the terms of the GNU General Public License as publis=
hed by
- *      the Free Software Foundation; either version 2 of the License,=
 or
- *      (at your option) any later version.
- *
- *      This program is distributed in the hope that it will be useful=
,
- *      but WITHOUT ANY WARRANTY; without even the implied warranty of
- *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- *      GNU General Public License for more details.
- *
- *      You should have received a copy of the GNU General Public Lice=
nse
- *      along with this program; if not, write to the Free Software
- *      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- */
-
-#include <linux/module.h>
-#include <linux/init.h>
-#include <linux/crc-ccitt.h>
-#include "isdnhdlc.h"
-
-/*-------------------------------------------------------------------*=
/
-
-MODULE_AUTHOR("Wolfgang M=C3=BCes <wolfgang@iksw-muees.de>, "
-	      "Frode Isaksen <fisaksen@bewan.com>, "
-	      "Kai Germaschewski <kai.germaschewski@gmx.de>");
-MODULE_DESCRIPTION("General purpose ISDN HDLC decoder");
-MODULE_LICENSE("GPL");
-
-/*-------------------------------------------------------------------*=
/
-
-enum {
-	HDLC_FAST_IDLE,HDLC_GET_FLAG_B0,HDLC_GETFLAG_B1A6,HDLC_GETFLAG_B7,
-	HDLC_GET_DATA,HDLC_FAST_FLAG
-};
-
-enum {
-	HDLC_SEND_DATA,HDLC_SEND_CRC1,HDLC_SEND_FAST_FLAG,
-	HDLC_SEND_FIRST_FLAG,HDLC_SEND_CRC2,HDLC_SEND_CLOSING_FLAG,
-	HDLC_SEND_IDLE1,HDLC_SEND_FAST_IDLE,HDLC_SENDFLAG_B0,
-	HDLC_SENDFLAG_B1A6,HDLC_SENDFLAG_B7,STOPPED
-};
-
-void isdnhdlc_rcv_init (struct isdnhdlc_vars *hdlc, int do_adapt56)
-{
-   	hdlc->bit_shift =3D 0;
-	hdlc->hdlc_bits1 =3D 0;
-	hdlc->data_bits =3D 0;
-	hdlc->ffbit_shift =3D 0;
-	hdlc->data_received =3D 0;
-	hdlc->state =3D HDLC_GET_DATA;
-	hdlc->do_adapt56 =3D do_adapt56;
-	hdlc->dchannel =3D 0;
-	hdlc->crc =3D 0;
-	hdlc->cbin =3D 0;
-	hdlc->shift_reg =3D 0;
-	hdlc->ffvalue =3D 0;
-	hdlc->dstpos =3D 0;
-}
-
-void isdnhdlc_out_init (struct isdnhdlc_vars *hdlc, int is_d_channel, =
int do_adapt56)
-{
-   	hdlc->bit_shift =3D 0;
-	hdlc->hdlc_bits1 =3D 0;
-	hdlc->data_bits =3D 0;
-	hdlc->ffbit_shift =3D 0;
-	hdlc->data_received =3D 0;
-	hdlc->do_closing =3D 0;
-	hdlc->ffvalue =3D 0;
-	if (is_d_channel) {
-		hdlc->dchannel =3D 1;
-		hdlc->state =3D HDLC_SEND_FIRST_FLAG;
-	} else {
-		hdlc->dchannel =3D 0;
-		hdlc->state =3D HDLC_SEND_FAST_FLAG;
-		hdlc->ffvalue =3D 0x7e;
-	}
-	hdlc->cbin =3D 0x7e;
-	hdlc->bit_shift =3D 0;
-	if(do_adapt56){
-		hdlc->do_adapt56 =3D 1;
-		hdlc->data_bits =3D 0;
-		hdlc->state =3D HDLC_SENDFLAG_B0;
-	} else {
-		hdlc->do_adapt56 =3D 0;
-		hdlc->data_bits =3D 8;
-	}
-	hdlc->shift_reg =3D 0;
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
-int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, const unsigned char *=
src,
-		     int slen, int *count, unsigned char *dst, int dsize)
-{
-	int status=3D0;
-
-	static const unsigned char fast_flag[]=3D{
-		0x00,0x00,0x00,0x20,0x30,0x38,0x3c,0x3e,0x3f
-	};
-
-	static const unsigned char fast_flag_value[]=3D{
-		0x00,0x7e,0xfc,0xf9,0xf3,0xe7,0xcf,0x9f,0x3f
-	};
-
-	static const unsigned char fast_abort[]=3D{
-		0x00,0x00,0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0xfe,0xff
-	};
-
-	*count =3D slen;
-
-	while(slen > 0){
-		if(hdlc->bit_shift=3D=3D0){
-			hdlc->cbin =3D *src++;
-			slen--;
-			hdlc->bit_shift =3D 8;
-			if(hdlc->do_adapt56){
-				hdlc->bit_shift --;
-			}
-		}
-
-		switch(hdlc->state){
-		case STOPPED:
-			return 0;
-		case HDLC_FAST_IDLE:
-			if(hdlc->cbin =3D=3D 0xff){
-				hdlc->bit_shift =3D 0;
-				break;
-			}
-			hdlc->state =3D HDLC_GET_FLAG_B0;
-			hdlc->hdlc_bits1 =3D 0;
-			hdlc->bit_shift =3D 8;
-			break;
-		case HDLC_GET_FLAG_B0:
-			if(!(hdlc->cbin & 0x80)) {
-				hdlc->state =3D HDLC_GETFLAG_B1A6;
-				hdlc->hdlc_bits1 =3D 0;
-			} else {
-				if(!hdlc->do_adapt56){
-					if(++hdlc->hdlc_bits1 >=3D8 ) if(hdlc->bit_shift=3D=3D1)
-						hdlc->state =3D HDLC_FAST_IDLE;
-				}
-			}
-			hdlc->cbin<<=3D1;
-			hdlc->bit_shift --;
-			break;
-		case HDLC_GETFLAG_B1A6:
-			if(hdlc->cbin & 0x80){
-				hdlc->hdlc_bits1++;
-				if(hdlc->hdlc_bits1=3D=3D6){
-					hdlc->state =3D HDLC_GETFLAG_B7;
-				}
-			} else {
-				hdlc->hdlc_bits1 =3D 0;
-			}
-			hdlc->cbin<<=3D1;
-			hdlc->bit_shift --;
-			break;
-		case HDLC_GETFLAG_B7:
-			if(hdlc->cbin & 0x80) {
-				hdlc->state =3D HDLC_GET_FLAG_B0;
-			} else {
-				hdlc->state =3D HDLC_GET_DATA;
-				hdlc->crc =3D 0xffff;
-				hdlc->shift_reg =3D 0;
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->data_bits =3D 0;
-				hdlc->data_received =3D 0;
-			}
-			hdlc->cbin<<=3D1;
-			hdlc->bit_shift --;
-			break;
-		case HDLC_GET_DATA:
-			if(hdlc->cbin & 0x80){
-				hdlc->hdlc_bits1++;
-				switch(hdlc->hdlc_bits1){
-				case 6:
-					break;
-				case 7:
-					if(hdlc->data_received) {
-						// bad frame
-						status =3D -HDLC_FRAMING_ERROR;
-					}
-					if(!hdlc->do_adapt56){
-						if(hdlc->cbin=3D=3Dfast_abort[hdlc->bit_shift+1]){
-							hdlc->state =3D HDLC_FAST_IDLE;
-							hdlc->bit_shift=3D1;
-							break;
-						}
-					} else {
-						hdlc->state =3D HDLC_GET_FLAG_B0;
-					}
-					break;
-				default:
-					hdlc->shift_reg>>=3D1;
-					hdlc->shift_reg |=3D 0x80;
-					hdlc->data_bits++;
-					break;
-				}
-			} else {
-				switch(hdlc->hdlc_bits1){
-				case 5:
-					break;
-				case 6:
-					if(hdlc->data_received){
-						if (hdlc->dstpos < 2) {
-							status =3D -HDLC_FRAMING_ERROR;
-						} else if (hdlc->crc !=3D 0xf0b8){
-							// crc error
-							status =3D -HDLC_CRC_ERROR;
-						} else {
-							// remove CRC
-							hdlc->dstpos -=3D 2;
-							// good frame
-							status =3D hdlc->dstpos;
-						}
-					}
-					hdlc->crc =3D 0xffff;
-					hdlc->shift_reg =3D 0;
-					hdlc->data_bits =3D 0;
-					if(!hdlc->do_adapt56){
-						if(hdlc->cbin=3D=3Dfast_flag[hdlc->bit_shift]){
-							hdlc->ffvalue =3D fast_flag_value[hdlc->bit_shift];
-							hdlc->state =3D HDLC_FAST_FLAG;
-							hdlc->ffbit_shift =3D hdlc->bit_shift;
-							hdlc->bit_shift =3D 1;
-						} else {
-							hdlc->state =3D HDLC_GET_DATA;
-							hdlc->data_received =3D 0;
-						}
-					} else {
-						hdlc->state =3D HDLC_GET_DATA;
-						hdlc->data_received =3D 0;
-					}
-					break;
-				default:
-					hdlc->shift_reg>>=3D1;
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
-			if(hdlc->data_bits=3D=3D8){
-				hdlc->data_bits =3D 0;
-				hdlc->data_received =3D 1;
-				hdlc->crc =3D crc_ccitt_byte(hdlc->crc, hdlc->shift_reg);
-
-				// good byte received
-				if (hdlc->dstpos < dsize) {
-					dst[hdlc->dstpos++] =3D hdlc->shift_reg;
-				} else {
-					// frame too long
-					status =3D -HDLC_LENGTH_ERROR;
-					hdlc->dstpos =3D 0;
-				}
-			}
-			hdlc->cbin <<=3D 1;
-			hdlc->bit_shift--;
-			break;
-		case HDLC_FAST_FLAG:
-			if(hdlc->cbin=3D=3Dhdlc->ffvalue){
-				hdlc->bit_shift =3D 0;
-				break;
-			} else {
-				if(hdlc->cbin =3D=3D 0xff){
-					hdlc->state =3D HDLC_FAST_IDLE;
-					hdlc->bit_shift=3D0;
-				} else if(hdlc->ffbit_shift=3D=3D8){
-					hdlc->state =3D HDLC_GETFLAG_B7;
-					break;
-				} else {
-					hdlc->shift_reg =3D fast_abort[hdlc->ffbit_shift-1];
-					hdlc->hdlc_bits1 =3D hdlc->ffbit_shift-2;
-					if(hdlc->hdlc_bits1<0)hdlc->hdlc_bits1 =3D 0;
-					hdlc->data_bits =3D hdlc->ffbit_shift-1;
-					hdlc->state =3D HDLC_GET_DATA;
-					hdlc->data_received =3D 0;
-				}
-			}
-			break;
-		default:
-			break;
-		}
-	}
-	*count -=3D slen;
-	return 0;
-}
-
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
-int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const unsigned char *s=
rc,
-		unsigned short slen, int *count,
-		unsigned char *dst, int dsize)
-{
-	static const unsigned char xfast_flag_value[] =3D {
-		0x7e,0x3f,0x9f,0xcf,0xe7,0xf3,0xf9,0xfc,0x7e
-	};
-
-	int len =3D 0;
-
-	*count =3D slen;
-
-	while (dsize > 0) {
-		if(hdlc->bit_shift=3D=3D0){
-			if(slen && !hdlc->do_closing){
-				hdlc->shift_reg =3D *src++;
-				slen--;
-				if (slen =3D=3D 0)
-					hdlc->do_closing =3D 1;  /* closing sequence, CRC + flag(s) */
-				hdlc->bit_shift =3D 8;
-			} else {
-				if(hdlc->state =3D=3D HDLC_SEND_DATA){
-					if(hdlc->data_received){
-						hdlc->state =3D HDLC_SEND_CRC1;
-						hdlc->crc ^=3D 0xffff;
-						hdlc->bit_shift =3D 8;
-						hdlc->shift_reg =3D hdlc->crc & 0xff;
-					} else if(!hdlc->do_adapt56){
-						hdlc->state =3D HDLC_SEND_FAST_FLAG;
-					} else {
-						hdlc->state =3D HDLC_SENDFLAG_B0;
-					}
-				}
-
-			}
-		}
-
-		switch(hdlc->state){
-		case STOPPED:
-			while (dsize--)
-				*dst++ =3D 0xff;
-
-			return dsize;
-		case HDLC_SEND_FAST_FLAG:
-			hdlc->do_closing =3D 0;
-			if(slen =3D=3D 0){
-				*dst++ =3D hdlc->ffvalue;
-				len++;
-				dsize--;
-				break;
-			}
-			if(hdlc->bit_shift=3D=3D8){
-				hdlc->cbin =3D hdlc->ffvalue>>(8-hdlc->data_bits);
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
-			if(++hdlc->hdlc_bits1 =3D=3D 6)
-				hdlc->state =3D HDLC_SENDFLAG_B7;
-			break;
-		case HDLC_SENDFLAG_B7:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if(slen =3D=3D 0){
-				hdlc->state =3D HDLC_SENDFLAG_B0;
-				break;
-			}
-			if(hdlc->bit_shift=3D=3D8){
-				hdlc->state =3D HDLC_SEND_DATA;
-				hdlc->crc =3D 0xffff;
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->data_received =3D 1;
-			}
-			break;
-		case HDLC_SEND_FIRST_FLAG:
-			hdlc->data_received =3D 1;
-			if(hdlc->data_bits=3D=3D8){
-				hdlc->state =3D HDLC_SEND_DATA;
-				hdlc->crc =3D 0xffff;
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if(hdlc->shift_reg & 0x01)
-				hdlc->cbin++;
-			hdlc->shift_reg >>=3D 1;
-			hdlc->bit_shift--;
-			if(hdlc->bit_shift=3D=3D0){
-				hdlc->state =3D HDLC_SEND_DATA;
-				hdlc->crc =3D 0xffff;
-				hdlc->hdlc_bits1 =3D 0;
-			}
-			break;
-		case HDLC_SEND_DATA:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if(hdlc->hdlc_bits1 =3D=3D 5){
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			if(hdlc->bit_shift=3D=3D8){
-				hdlc->crc =3D crc_ccitt_byte(hdlc->crc, hdlc->shift_reg);
-			}
-			if(hdlc->shift_reg & 0x01){
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
-			if(hdlc->hdlc_bits1 =3D=3D 5){
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			if(hdlc->shift_reg & 0x01){
-				hdlc->hdlc_bits1++;
-				hdlc->cbin++;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			} else {
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			}
-			if(hdlc->bit_shift=3D=3D0){
-				hdlc->shift_reg =3D (hdlc->crc >> 8);
-				hdlc->state =3D HDLC_SEND_CRC2;
-				hdlc->bit_shift =3D 8;
-			}
-			break;
-		case HDLC_SEND_CRC2:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if(hdlc->hdlc_bits1 =3D=3D 5){
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			if(hdlc->shift_reg & 0x01){
-				hdlc->hdlc_bits1++;
-				hdlc->cbin++;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			} else {
-				hdlc->hdlc_bits1 =3D 0;
-				hdlc->shift_reg >>=3D 1;
-				hdlc->bit_shift--;
-			}
-			if(hdlc->bit_shift=3D=3D0){
-				hdlc->shift_reg =3D 0x7e;
-				hdlc->state =3D HDLC_SEND_CLOSING_FLAG;
-				hdlc->bit_shift =3D 8;
-			}
-			break;
-		case HDLC_SEND_CLOSING_FLAG:
-			hdlc->cbin <<=3D 1;
-			hdlc->data_bits++;
-			if(hdlc->hdlc_bits1 =3D=3D 5){
-				hdlc->hdlc_bits1 =3D 0;
-				break;
-			}
-			if(hdlc->shift_reg & 0x01){
-				hdlc->cbin++;
-			}
-			hdlc->shift_reg >>=3D 1;
-			hdlc->bit_shift--;
-			if(hdlc->bit_shift=3D=3D0){
-				hdlc->ffvalue =3D xfast_flag_value[hdlc->data_bits];
-				if(hdlc->dchannel){
-					hdlc->ffvalue =3D 0x7e;
-					hdlc->state =3D HDLC_SEND_IDLE1;
-					hdlc->bit_shift =3D 8-hdlc->data_bits;
-					if(hdlc->bit_shift=3D=3D0)
-						hdlc->state =3D HDLC_SEND_FAST_IDLE;
-				} else {
-					if(!hdlc->do_adapt56){
-						hdlc->state =3D HDLC_SEND_FAST_FLAG;
-						hdlc->data_received =3D 0;
-					} else {
-						hdlc->state =3D HDLC_SENDFLAG_B0;
-						hdlc->data_received =3D 0;
-					}
-					// Finished with this frame, send flags
-					if (dsize > 1) dsize =3D 1;
-				}
-			}
-			break;
-		case HDLC_SEND_IDLE1:
-			hdlc->do_closing =3D 0;
-			hdlc->cbin <<=3D 1;
-			hdlc->cbin++;
-			hdlc->data_bits++;
-			hdlc->bit_shift--;
-			if(hdlc->bit_shift=3D=3D0){
-				hdlc->state =3D HDLC_SEND_FAST_IDLE;
-				hdlc->bit_shift =3D 0;
-			}
-			break;
-		case HDLC_SEND_FAST_IDLE:
-			hdlc->do_closing =3D 0;
-			hdlc->cbin =3D 0xff;
-			hdlc->data_bits =3D 8;
-			if(hdlc->bit_shift =3D=3D 8){
-				hdlc->cbin =3D 0x7e;
-				hdlc->state =3D HDLC_SEND_FIRST_FLAG;
-			} else {
-				*dst++ =3D hdlc->cbin;
-				hdlc->bit_shift =3D hdlc->data_bits =3D 0;
-				len++;
-				dsize =3D 0;
-			}
-			break;
-		default:
-			break;
-		}
-		if(hdlc->do_adapt56){
-			if(hdlc->data_bits=3D=3D7){
-				hdlc->cbin <<=3D 1;
-				hdlc->cbin++;
-				hdlc->data_bits++;
-			}
-		}
-		if(hdlc->data_bits=3D=3D8){
-			*dst++ =3D hdlc->cbin;
-			hdlc->data_bits =3D 0;
-			len++;
-			dsize--;
-		}
-	}
-	*count -=3D slen;
-
-	return len;
-}
-
-EXPORT_SYMBOL(isdnhdlc_rcv_init);
-EXPORT_SYMBOL(isdnhdlc_decode);
-EXPORT_SYMBOL(isdnhdlc_out_init);
-EXPORT_SYMBOL(isdnhdlc_encode);
diff --git a/drivers/isdn/hisax/isdnhdlc.h b/drivers/isdn/hisax/isdnhdl=
c.h
deleted file mode 100644
index cf0a95a..0000000
--- a/drivers/isdn/hisax/isdnhdlc.h
+++ /dev/null
@@ -1,70 +0,0 @@
-/*
- * isdnhdlc.h  --  General purpose ISDN HDLC decoder.
- *
- * Implementation of a HDLC decoder/encoder in software.
- * Neccessary because some ISDN devices don't have HDLC
- * controllers. Also included: a bit reversal table.
- *
- *Copyright (C) 2002    Wolfgang M=C3=BCes      <wolfgang@iksw-muees.d=
e>
- *		2001 	Frode Isaksen      <fisaksen@bewan.com>
- *              2001 	Kai Germaschewski  <kai.germaschewski@gmx.de>
- *
- *      This program is free software; you can redistribute it and/or =
modify
- *      it under the terms of the GNU General Public License as publis=
hed by
- *      the Free Software Foundation; either version 2 of the License,=
 or
- *      (at your option) any later version.
- *
- *      This program is distributed in the hope that it will be useful=
,
- *      but WITHOUT ANY WARRANTY; without even the implied warranty of
- *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- *      GNU General Public License for more details.
- *
- *      You should have received a copy of the GNU General Public Lice=
nse
- *      along with this program; if not, write to the Free Software
- *      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- */
-
-#ifndef __ISDNHDLC_H__
-#define __ISDNHDLC_H__
-
-struct isdnhdlc_vars {
-	int bit_shift;
-	int hdlc_bits1;
-	int data_bits;
-	int ffbit_shift; 	// encoding only
-	int state;
-	int dstpos;
-
-	unsigned short crc;
-
-	unsigned char cbin;
-	unsigned char shift_reg;
-	unsigned char ffvalue;
-
-	unsigned int data_received:1; 	// set if transferring data
-	unsigned int dchannel:1; 	// set if D channel (send idle instead of f=
lags)
-	unsigned int do_adapt56:1; 	// set if 56K adaptation
-	unsigned int do_closing:1; 	// set if in closing phase (need to send =
CRC + flag
-};
-
-
-/*
-  The return value from isdnhdlc_decode is
-  the frame length, 0 if no complete frame was decoded,
-  or a negative error number
-*/
-#define HDLC_FRAMING_ERROR     1
-#define HDLC_CRC_ERROR         2
-#define HDLC_LENGTH_ERROR      3
-
-extern void isdnhdlc_rcv_init (struct isdnhdlc_vars *hdlc, int do_adap=
t56);
-
-extern int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, const unsigned=
 char *src, int slen,int *count,
-	                    unsigned char *dst, int dsize);
-
-extern void isdnhdlc_out_init (struct isdnhdlc_vars *hdlc,int is_d_cha=
nnel,int do_adapt56);
-
-extern int isdnhdlc_encode (struct isdnhdlc_vars *hdlc,const unsigned =
char *src,unsigned short slen,int *count,
-	                    unsigned char *dst,int dsize);
-
-#endif /* __ISDNHDLC_H__ */
diff --git a/drivers/isdn/hisax/st5481.h b/drivers/isdn/hisax/st5481.h
index cff7a63..64f78a8 100644
--- a/drivers/isdn/hisax/st5481.h
+++ b/drivers/isdn/hisax/st5481.h
@@ -226,7 +226,7 @@ printk(KERN_WARNING "%s:%s: " format "\n" , __FILE_=
_,  __func__ , ## arg)
 #define INFO(format, arg...) \
 printk(KERN_INFO "%s:%s: " format "\n" , __FILE__,  __func__ , ## arg)
=20
-#include "isdnhdlc.h"
+#include <linux/isdn/hdlc.h>
 #include "fsm.h"
 #include "hisax_if.h"
 #include <linux/skbuff.h>
diff --git a/drivers/isdn/i4l/Kconfig b/drivers/isdn/i4l/Kconfig
index ed3510f..dd744ff 100644
--- a/drivers/isdn/i4l/Kconfig
+++ b/drivers/isdn/i4l/Kconfig
@@ -2,6 +2,8 @@
 # Old ISDN4Linux config
 #
=20
+if ISDN_I4L
+
 config ISDN_PPP
 	bool "Support synchronous PPP"
 	depends on INET
@@ -135,3 +137,12 @@ source "drivers/isdn/act2000/Kconfig"
 source "drivers/isdn/hysdn/Kconfig"
=20
 endmenu
+# end ISDN_I4L
+endif
+
+config ISDN_HDLC
+	tristate=20
+	depends on HISAX_ST5481
+	select CRC_CCITT
+	select BITREVERSE
+
diff --git a/drivers/isdn/i4l/Makefile b/drivers/isdn/i4l/Makefile
index 49a06c0..cb9d3bb 100644
--- a/drivers/isdn/i4l/Makefile
+++ b/drivers/isdn/i4l/Makefile
@@ -4,6 +4,7 @@
=20
 obj-$(CONFIG_ISDN_I4L)		+=3D isdn.o
 obj-$(CONFIG_ISDN_PPP_BSDCOMP)	+=3D isdn_bsdcomp.o
+obj-$(CONFIG_ISDN_HDLC)		+=3D isdnhdlc.o
=20
 # Multipart objects.
=20
diff --git a/drivers/isdn/i4l/isdnhdlc.c b/drivers/isdn/i4l/isdnhdlc.c
new file mode 100644
index 0000000..44ec741
--- /dev/null
+++ b/drivers/isdn/i4l/isdnhdlc.c
@@ -0,0 +1,603 @@
+/*
+ * isdnhdlc.c  --  General purpose ISDN HDLC decoder.
+ *
+ *Copyright (C) 2002	Wolfgang M=C3=BCes      <wolfgang@iksw-muees.de>
+ *		2001 	Frode Isaksen      <fisaksen@bewan.com>
+ *              2001 	Kai Germaschewski  <kai.germaschewski@gmx.de>
+ *
+ *      This program is free software; you can redistribute it and/or =
modify
+ *      it under the terms of the GNU General Public License as publis=
hed by
+ *      the Free Software Foundation; either version 2 of the License,=
 or
+ *      (at your option) any later version.
+ *
+ *      This program is distributed in the hope that it will be useful=
,
+ *      but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *      GNU General Public License for more details.
+ *
+ *      You should have received a copy of the GNU General Public Lice=
nse
+ *      along with this program; if not, write to the Free Software
+ *      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/crc-ccitt.h>
+#include <linux/isdn/hdlc.h>
+
+/*-------------------------------------------------------------------*=
/
+
+MODULE_AUTHOR("Wolfgang M=C3=BCes <wolfgang@iksw-muees.de>, "
+	      "Frode Isaksen <fisaksen@bewan.com>, "
+	      "Kai Germaschewski <kai.germaschewski@gmx.de>");
+MODULE_DESCRIPTION("General purpose ISDN HDLC decoder");
+MODULE_LICENSE("GPL");
+
+/*-------------------------------------------------------------------*=
/
+
+enum {
+	HDLC_FAST_IDLE,HDLC_GET_FLAG_B0,HDLC_GETFLAG_B1A6,HDLC_GETFLAG_B7,
+	HDLC_GET_DATA,HDLC_FAST_FLAG
+};
+
+enum {
+	HDLC_SEND_DATA,HDLC_SEND_CRC1,HDLC_SEND_FAST_FLAG,
+	HDLC_SEND_FIRST_FLAG,HDLC_SEND_CRC2,HDLC_SEND_CLOSING_FLAG,
+	HDLC_SEND_IDLE1,HDLC_SEND_FAST_IDLE,HDLC_SENDFLAG_B0,
+	HDLC_SENDFLAG_B1A6,HDLC_SENDFLAG_B7,STOPPED
+};
+
+void isdnhdlc_rcv_init (struct isdnhdlc_vars *hdlc, int do_adapt56)
+{
+   	hdlc->bit_shift =3D 0;
+	hdlc->hdlc_bits1 =3D 0;
+	hdlc->data_bits =3D 0;
+	hdlc->ffbit_shift =3D 0;
+	hdlc->data_received =3D 0;
+	hdlc->state =3D HDLC_GET_DATA;
+	hdlc->do_adapt56 =3D do_adapt56;
+	hdlc->dchannel =3D 0;
+	hdlc->crc =3D 0;
+	hdlc->cbin =3D 0;
+	hdlc->shift_reg =3D 0;
+	hdlc->ffvalue =3D 0;
+	hdlc->dstpos =3D 0;
+}
+
+void isdnhdlc_out_init (struct isdnhdlc_vars *hdlc, int is_d_channel, =
int do_adapt56)
+{
+   	hdlc->bit_shift =3D 0;
+	hdlc->hdlc_bits1 =3D 0;
+	hdlc->data_bits =3D 0;
+	hdlc->ffbit_shift =3D 0;
+	hdlc->data_received =3D 0;
+	hdlc->do_closing =3D 0;
+	hdlc->ffvalue =3D 0;
+	if (is_d_channel) {
+		hdlc->dchannel =3D 1;
+		hdlc->state =3D HDLC_SEND_FIRST_FLAG;
+	} else {
+		hdlc->dchannel =3D 0;
+		hdlc->state =3D HDLC_SEND_FAST_FLAG;
+		hdlc->ffvalue =3D 0x7e;
+	}
+	hdlc->cbin =3D 0x7e;
+	hdlc->bit_shift =3D 0;
+	if(do_adapt56){
+		hdlc->do_adapt56 =3D 1;
+		hdlc->data_bits =3D 0;
+		hdlc->state =3D HDLC_SENDFLAG_B0;
+	} else {
+		hdlc->do_adapt56 =3D 0;
+		hdlc->data_bits =3D 8;
+	}
+	hdlc->shift_reg =3D 0;
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
+int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, const unsigned char *=
src,
+		     int slen, int *count, unsigned char *dst, int dsize)
+{
+	int status=3D0;
+
+	static const unsigned char fast_flag[]=3D{
+		0x00,0x00,0x00,0x20,0x30,0x38,0x3c,0x3e,0x3f
+	};
+
+	static const unsigned char fast_flag_value[]=3D{
+		0x00,0x7e,0xfc,0xf9,0xf3,0xe7,0xcf,0x9f,0x3f
+	};
+
+	static const unsigned char fast_abort[]=3D{
+		0x00,0x00,0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0xfe,0xff
+	};
+
+	*count =3D slen;
+
+	while(slen > 0){
+		if(hdlc->bit_shift=3D=3D0){
+			hdlc->cbin =3D *src++;
+			slen--;
+			hdlc->bit_shift =3D 8;
+			if(hdlc->do_adapt56){
+				hdlc->bit_shift --;
+			}
+		}
+
+		switch(hdlc->state){
+		case STOPPED:
+			return 0;
+		case HDLC_FAST_IDLE:
+			if(hdlc->cbin =3D=3D 0xff){
+				hdlc->bit_shift =3D 0;
+				break;
+			}
+			hdlc->state =3D HDLC_GET_FLAG_B0;
+			hdlc->hdlc_bits1 =3D 0;
+			hdlc->bit_shift =3D 8;
+			break;
+		case HDLC_GET_FLAG_B0:
+			if(!(hdlc->cbin & 0x80)) {
+				hdlc->state =3D HDLC_GETFLAG_B1A6;
+				hdlc->hdlc_bits1 =3D 0;
+			} else {
+				if(!hdlc->do_adapt56){
+					if(++hdlc->hdlc_bits1 >=3D8 ) if(hdlc->bit_shift=3D=3D1)
+						hdlc->state =3D HDLC_FAST_IDLE;
+				}
+			}
+			hdlc->cbin<<=3D1;
+			hdlc->bit_shift --;
+			break;
+		case HDLC_GETFLAG_B1A6:
+			if(hdlc->cbin & 0x80){
+				hdlc->hdlc_bits1++;
+				if(hdlc->hdlc_bits1=3D=3D6){
+					hdlc->state =3D HDLC_GETFLAG_B7;
+				}
+			} else {
+				hdlc->hdlc_bits1 =3D 0;
+			}
+			hdlc->cbin<<=3D1;
+			hdlc->bit_shift --;
+			break;
+		case HDLC_GETFLAG_B7:
+			if(hdlc->cbin & 0x80) {
+				hdlc->state =3D HDLC_GET_FLAG_B0;
+			} else {
+				hdlc->state =3D HDLC_GET_DATA;
+				hdlc->crc =3D 0xffff;
+				hdlc->shift_reg =3D 0;
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->data_bits =3D 0;
+				hdlc->data_received =3D 0;
+			}
+			hdlc->cbin<<=3D1;
+			hdlc->bit_shift --;
+			break;
+		case HDLC_GET_DATA:
+			if(hdlc->cbin & 0x80){
+				hdlc->hdlc_bits1++;
+				switch(hdlc->hdlc_bits1){
+				case 6:
+					break;
+				case 7:
+					if(hdlc->data_received) {
+						// bad frame
+						status =3D -HDLC_FRAMING_ERROR;
+					}
+					if(!hdlc->do_adapt56){
+						if(hdlc->cbin=3D=3Dfast_abort[hdlc->bit_shift+1]){
+							hdlc->state =3D HDLC_FAST_IDLE;
+							hdlc->bit_shift=3D1;
+							break;
+						}
+					} else {
+						hdlc->state =3D HDLC_GET_FLAG_B0;
+					}
+					break;
+				default:
+					hdlc->shift_reg>>=3D1;
+					hdlc->shift_reg |=3D 0x80;
+					hdlc->data_bits++;
+					break;
+				}
+			} else {
+				switch(hdlc->hdlc_bits1){
+				case 5:
+					break;
+				case 6:
+					if(hdlc->data_received){
+						if (hdlc->dstpos < 2) {
+							status =3D -HDLC_FRAMING_ERROR;
+						} else if (hdlc->crc !=3D 0xf0b8){
+							// crc error
+							status =3D -HDLC_CRC_ERROR;
+						} else {
+							// remove CRC
+							hdlc->dstpos -=3D 2;
+							// good frame
+							status =3D hdlc->dstpos;
+						}
+					}
+					hdlc->crc =3D 0xffff;
+					hdlc->shift_reg =3D 0;
+					hdlc->data_bits =3D 0;
+					if(!hdlc->do_adapt56){
+						if(hdlc->cbin=3D=3Dfast_flag[hdlc->bit_shift]){
+							hdlc->ffvalue =3D fast_flag_value[hdlc->bit_shift];
+							hdlc->state =3D HDLC_FAST_FLAG;
+							hdlc->ffbit_shift =3D hdlc->bit_shift;
+							hdlc->bit_shift =3D 1;
+						} else {
+							hdlc->state =3D HDLC_GET_DATA;
+							hdlc->data_received =3D 0;
+						}
+					} else {
+						hdlc->state =3D HDLC_GET_DATA;
+						hdlc->data_received =3D 0;
+					}
+					break;
+				default:
+					hdlc->shift_reg>>=3D1;
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
+			if(hdlc->data_bits=3D=3D8){
+				hdlc->data_bits =3D 0;
+				hdlc->data_received =3D 1;
+				hdlc->crc =3D crc_ccitt_byte(hdlc->crc, hdlc->shift_reg);
+
+				// good byte received
+				if (hdlc->dstpos < dsize) {
+					dst[hdlc->dstpos++] =3D hdlc->shift_reg;
+				} else {
+					// frame too long
+					status =3D -HDLC_LENGTH_ERROR;
+					hdlc->dstpos =3D 0;
+				}
+			}
+			hdlc->cbin <<=3D 1;
+			hdlc->bit_shift--;
+			break;
+		case HDLC_FAST_FLAG:
+			if(hdlc->cbin=3D=3Dhdlc->ffvalue){
+				hdlc->bit_shift =3D 0;
+				break;
+			} else {
+				if(hdlc->cbin =3D=3D 0xff){
+					hdlc->state =3D HDLC_FAST_IDLE;
+					hdlc->bit_shift=3D0;
+				} else if(hdlc->ffbit_shift=3D=3D8){
+					hdlc->state =3D HDLC_GETFLAG_B7;
+					break;
+				} else {
+					hdlc->shift_reg =3D fast_abort[hdlc->ffbit_shift-1];
+					hdlc->hdlc_bits1 =3D hdlc->ffbit_shift-2;
+					if(hdlc->hdlc_bits1<0)hdlc->hdlc_bits1 =3D 0;
+					hdlc->data_bits =3D hdlc->ffbit_shift-1;
+					hdlc->state =3D HDLC_GET_DATA;
+					hdlc->data_received =3D 0;
+				}
+			}
+			break;
+		default:
+			break;
+		}
+	}
+	*count -=3D slen;
+	return 0;
+}
+
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
+int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const unsigned char *s=
rc,
+		unsigned short slen, int *count,
+		unsigned char *dst, int dsize)
+{
+	static const unsigned char xfast_flag_value[] =3D {
+		0x7e,0x3f,0x9f,0xcf,0xe7,0xf3,0xf9,0xfc,0x7e
+	};
+
+	int len =3D 0;
+
+	*count =3D slen;
+
+	while (dsize > 0) {
+		if(hdlc->bit_shift=3D=3D0){
+			if(slen && !hdlc->do_closing){
+				hdlc->shift_reg =3D *src++;
+				slen--;
+				if (slen =3D=3D 0)
+					hdlc->do_closing =3D 1;  /* closing sequence, CRC + flag(s) */
+				hdlc->bit_shift =3D 8;
+			} else {
+				if(hdlc->state =3D=3D HDLC_SEND_DATA){
+					if(hdlc->data_received){
+						hdlc->state =3D HDLC_SEND_CRC1;
+						hdlc->crc ^=3D 0xffff;
+						hdlc->bit_shift =3D 8;
+						hdlc->shift_reg =3D hdlc->crc & 0xff;
+					} else if(!hdlc->do_adapt56){
+						hdlc->state =3D HDLC_SEND_FAST_FLAG;
+					} else {
+						hdlc->state =3D HDLC_SENDFLAG_B0;
+					}
+				}
+
+			}
+		}
+
+		switch(hdlc->state){
+		case STOPPED:
+			while (dsize--)
+				*dst++ =3D 0xff;
+
+			return dsize;
+		case HDLC_SEND_FAST_FLAG:
+			hdlc->do_closing =3D 0;
+			if(slen =3D=3D 0){
+				*dst++ =3D hdlc->ffvalue;
+				len++;
+				dsize--;
+				break;
+			}
+			if(hdlc->bit_shift=3D=3D8){
+				hdlc->cbin =3D hdlc->ffvalue>>(8-hdlc->data_bits);
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
+			if(++hdlc->hdlc_bits1 =3D=3D 6)
+				hdlc->state =3D HDLC_SENDFLAG_B7;
+			break;
+		case HDLC_SENDFLAG_B7:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if(slen =3D=3D 0){
+				hdlc->state =3D HDLC_SENDFLAG_B0;
+				break;
+			}
+			if(hdlc->bit_shift=3D=3D8){
+				hdlc->state =3D HDLC_SEND_DATA;
+				hdlc->crc =3D 0xffff;
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->data_received =3D 1;
+			}
+			break;
+		case HDLC_SEND_FIRST_FLAG:
+			hdlc->data_received =3D 1;
+			if(hdlc->data_bits=3D=3D8){
+				hdlc->state =3D HDLC_SEND_DATA;
+				hdlc->crc =3D 0xffff;
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if(hdlc->shift_reg & 0x01)
+				hdlc->cbin++;
+			hdlc->shift_reg >>=3D 1;
+			hdlc->bit_shift--;
+			if(hdlc->bit_shift=3D=3D0){
+				hdlc->state =3D HDLC_SEND_DATA;
+				hdlc->crc =3D 0xffff;
+				hdlc->hdlc_bits1 =3D 0;
+			}
+			break;
+		case HDLC_SEND_DATA:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if(hdlc->hdlc_bits1 =3D=3D 5){
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			if(hdlc->bit_shift=3D=3D8){
+				hdlc->crc =3D crc_ccitt_byte(hdlc->crc, hdlc->shift_reg);
+			}
+			if(hdlc->shift_reg & 0x01){
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
+			if(hdlc->hdlc_bits1 =3D=3D 5){
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			if(hdlc->shift_reg & 0x01){
+				hdlc->hdlc_bits1++;
+				hdlc->cbin++;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			} else {
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			}
+			if(hdlc->bit_shift=3D=3D0){
+				hdlc->shift_reg =3D (hdlc->crc >> 8);
+				hdlc->state =3D HDLC_SEND_CRC2;
+				hdlc->bit_shift =3D 8;
+			}
+			break;
+		case HDLC_SEND_CRC2:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if(hdlc->hdlc_bits1 =3D=3D 5){
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			if(hdlc->shift_reg & 0x01){
+				hdlc->hdlc_bits1++;
+				hdlc->cbin++;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			} else {
+				hdlc->hdlc_bits1 =3D 0;
+				hdlc->shift_reg >>=3D 1;
+				hdlc->bit_shift--;
+			}
+			if(hdlc->bit_shift=3D=3D0){
+				hdlc->shift_reg =3D 0x7e;
+				hdlc->state =3D HDLC_SEND_CLOSING_FLAG;
+				hdlc->bit_shift =3D 8;
+			}
+			break;
+		case HDLC_SEND_CLOSING_FLAG:
+			hdlc->cbin <<=3D 1;
+			hdlc->data_bits++;
+			if(hdlc->hdlc_bits1 =3D=3D 5){
+				hdlc->hdlc_bits1 =3D 0;
+				break;
+			}
+			if(hdlc->shift_reg & 0x01){
+				hdlc->cbin++;
+			}
+			hdlc->shift_reg >>=3D 1;
+			hdlc->bit_shift--;
+			if(hdlc->bit_shift=3D=3D0){
+				hdlc->ffvalue =3D xfast_flag_value[hdlc->data_bits];
+				if(hdlc->dchannel){
+					hdlc->ffvalue =3D 0x7e;
+					hdlc->state =3D HDLC_SEND_IDLE1;
+					hdlc->bit_shift =3D 8-hdlc->data_bits;
+					if(hdlc->bit_shift=3D=3D0)
+						hdlc->state =3D HDLC_SEND_FAST_IDLE;
+				} else {
+					if(!hdlc->do_adapt56){
+						hdlc->state =3D HDLC_SEND_FAST_FLAG;
+						hdlc->data_received =3D 0;
+					} else {
+						hdlc->state =3D HDLC_SENDFLAG_B0;
+						hdlc->data_received =3D 0;
+					}
+					// Finished with this frame, send flags
+					if (dsize > 1) dsize =3D 1;
+				}
+			}
+			break;
+		case HDLC_SEND_IDLE1:
+			hdlc->do_closing =3D 0;
+			hdlc->cbin <<=3D 1;
+			hdlc->cbin++;
+			hdlc->data_bits++;
+			hdlc->bit_shift--;
+			if(hdlc->bit_shift=3D=3D0){
+				hdlc->state =3D HDLC_SEND_FAST_IDLE;
+				hdlc->bit_shift =3D 0;
+			}
+			break;
+		case HDLC_SEND_FAST_IDLE:
+			hdlc->do_closing =3D 0;
+			hdlc->cbin =3D 0xff;
+			hdlc->data_bits =3D 8;
+			if(hdlc->bit_shift =3D=3D 8){
+				hdlc->cbin =3D 0x7e;
+				hdlc->state =3D HDLC_SEND_FIRST_FLAG;
+			} else {
+				*dst++ =3D hdlc->cbin;
+				hdlc->bit_shift =3D hdlc->data_bits =3D 0;
+				len++;
+				dsize =3D 0;
+			}
+			break;
+		default:
+			break;
+		}
+		if(hdlc->do_adapt56){
+			if(hdlc->data_bits=3D=3D7){
+				hdlc->cbin <<=3D 1;
+				hdlc->cbin++;
+				hdlc->data_bits++;
+			}
+		}
+		if(hdlc->data_bits=3D=3D8){
+			*dst++ =3D hdlc->cbin;
+			hdlc->data_bits =3D 0;
+			len++;
+			dsize--;
+		}
+	}
+	*count -=3D slen;
+
+	return len;
+}
+
+EXPORT_SYMBOL(isdnhdlc_rcv_init);
+EXPORT_SYMBOL(isdnhdlc_decode);
+EXPORT_SYMBOL(isdnhdlc_out_init);
+EXPORT_SYMBOL(isdnhdlc_encode);
diff --git a/include/linux/isdn/hdlc.h b/include/linux/isdn/hdlc.h
new file mode 100644
index 0000000..cf0a95a
--- /dev/null
+++ b/include/linux/isdn/hdlc.h
@@ -0,0 +1,70 @@
+/*
+ * isdnhdlc.h  --  General purpose ISDN HDLC decoder.
+ *
+ * Implementation of a HDLC decoder/encoder in software.
+ * Neccessary because some ISDN devices don't have HDLC
+ * controllers. Also included: a bit reversal table.
+ *
+ *Copyright (C) 2002    Wolfgang M=C3=BCes      <wolfgang@iksw-muees.d=
e>
+ *		2001 	Frode Isaksen      <fisaksen@bewan.com>
+ *              2001 	Kai Germaschewski  <kai.germaschewski@gmx.de>
+ *
+ *      This program is free software; you can redistribute it and/or =
modify
+ *      it under the terms of the GNU General Public License as publis=
hed by
+ *      the Free Software Foundation; either version 2 of the License,=
 or
+ *      (at your option) any later version.
+ *
+ *      This program is distributed in the hope that it will be useful=
,
+ *      but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *      GNU General Public License for more details.
+ *
+ *      You should have received a copy of the GNU General Public Lice=
nse
+ *      along with this program; if not, write to the Free Software
+ *      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef __ISDNHDLC_H__
+#define __ISDNHDLC_H__
+
+struct isdnhdlc_vars {
+	int bit_shift;
+	int hdlc_bits1;
+	int data_bits;
+	int ffbit_shift; 	// encoding only
+	int state;
+	int dstpos;
+
+	unsigned short crc;
+
+	unsigned char cbin;
+	unsigned char shift_reg;
+	unsigned char ffvalue;
+
+	unsigned int data_received:1; 	// set if transferring data
+	unsigned int dchannel:1; 	// set if D channel (send idle instead of f=
lags)
+	unsigned int do_adapt56:1; 	// set if 56K adaptation
+	unsigned int do_closing:1; 	// set if in closing phase (need to send =
CRC + flag
+};
+
+
+/*
+  The return value from isdnhdlc_decode is
+  the frame length, 0 if no complete frame was decoded,
+  or a negative error number
+*/
+#define HDLC_FRAMING_ERROR     1
+#define HDLC_CRC_ERROR         2
+#define HDLC_LENGTH_ERROR      3
+
+extern void isdnhdlc_rcv_init (struct isdnhdlc_vars *hdlc, int do_adap=
t56);
+
+extern int isdnhdlc_decode (struct isdnhdlc_vars *hdlc, const unsigned=
 char *src, int slen,int *count,
+	                    unsigned char *dst, int dsize);
+
+extern void isdnhdlc_out_init (struct isdnhdlc_vars *hdlc,int is_d_cha=
nnel,int do_adapt56);
+
+extern int isdnhdlc_encode (struct isdnhdlc_vars *hdlc,const unsigned =
char *src,unsigned short slen,int *count,
+	                    unsigned char *dst,int dsize);
+
+#endif /* __ISDNHDLC_H__ */
--=20
1.6.0.2

