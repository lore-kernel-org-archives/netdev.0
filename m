From: "Andreas.Eversberg" <Andreas.Eversberg@versatel.de>
Subject: AW: [PATCH] ISDN cmx: Avoid potential NULL deref in dsp_cmx_send_member() and shrink code size.
Date: Mon, 20 Dec 2010 12:26:23 +0100
Message-ID: <B16317F2B1592B4492FC414114171CE604B08AEA@FLBVEXCH01.versatel.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"Julia Lawall" <julia@diku.dk>, "Tejun Heo" <tj@kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "Jesper Juhl" <jj@chaosbits.net>,
	"Karsten Keil" <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxintlb12fl.versatel.de ([62.214.97.106]:53929 "EHLO
	mxintlb12fl.versatel.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757337Ab0LTMCA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 07:02:00 -0500
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi jesper,

thanx for finding the bug. i think the right solution to solve the prob=
lem would be:

                if (dsp->conf && dsp->conf->software && dsp->conf->hard=
ware)
                        tx_data_only =3D 1;
->              if (dsp->echo.software && dsp->echo.hardware)
                        tx_data_only =3D 1;

this is how it looks in the 'socket' branch of mISDN git respository. i=
t has been fixed already. but i cannot tell in which commit. my current=
 head is this commit:
commit 45a51eed1c554a4891b48b88c270f4f95bd21df0

what branch do you use?=20

regards,

andreas


-----Urspr=FCngliche Nachricht-----
Von: Jesper Juhl [mailto:jj@chaosbits.net]=20
Gesendet: Samstag, 18. Dezember 2010 23:34
An: Karsten Keil
Cc: David S. Miller; Julia Lawall; Tejun Heo; netdev@vger.kernel.org; l=
inux-kernel@vger.kernel.org; Andreas Eversberg
Betreff: [PATCH] ISDN cmx: Avoid potential NULL deref in dsp_cmx_send_m=
ember() and shrink code size.

Hi there,

In drivers/isdn/mISDN/dsp_cmx.c::dsp_cmx_send_member() we currently hav=
e=20
this code:

           if (dsp->conf && dsp->conf->software && dsp->conf->hardware)
                   tx_data_only =3D 1;
           if (dsp->conf->software && dsp->echo.hardware)
                   tx_data_only =3D 1;

The first line implies that 'dsp->conf' may be NULL. If it is, then the=
=20
third line will dereference a NULL pointer.

This patch reworks the code so that we avoid the potential NULL deref.
It also has the added benefit that the object file size shrinks a bit.

before:
   text    data     bss     dec     hex filename
  18840     112    5784   24736    60a0 drivers/isdn/mISDN/dsp_cmx.o
after:
   text    data     bss     dec     hex filename
  18816     112    5776   24704    6080 drivers/isdn/mISDN/dsp_cmx.o


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 dsp_cmx.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

 compile tested only

diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.=
c
index 76d9e67..f76f595 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1326,10 +1326,9 @@ dsp_cmx_send_member(struct dsp *dsp, int len, s3=
2 *c, int members)
 			dsp->last_tx =3D 0;
 			return;
 		}
-		if (dsp->conf && dsp->conf->software && dsp->conf->hardware)
-			tx_data_only =3D 1;
-		if (dsp->conf->software && dsp->echo.hardware)
-			tx_data_only =3D 1;
+		if (dsp->conf && dsp->conf->software)
+			if (dsp->conf->hardware || dsp->echo.hardware)
+				tx_data_only =3D 1;
 	}
=20
 #ifdef CMX_DEBUG



--=20
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
