From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] ISDN cmx: Avoid potential NULL deref in dsp_cmx_send_member()
 and shrink code size.
Date: Sat, 18 Dec 2010 23:33:40 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012182322330.17400@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia@diku.dk>, Tejun Heo <tj@kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andreas Eversberg <jolly@eversberg.eu>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,

In drivers/isdn/mISDN/dsp_cmx.c::dsp_cmx_send_member() we currently have 
this code:

           if (dsp->conf && dsp->conf->software && dsp->conf->hardware)
                   tx_data_only = 1;
           if (dsp->conf->software && dsp->echo.hardware)
                   tx_data_only = 1;

The first line implies that 'dsp->conf' may be NULL. If it is, then the 
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

diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index 76d9e67..f76f595 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1326,10 +1326,9 @@ dsp_cmx_send_member(struct dsp *dsp, int len, s32 *c, int members)
 			dsp->last_tx = 0;
 			return;
 		}
-		if (dsp->conf && dsp->conf->software && dsp->conf->hardware)
-			tx_data_only = 1;
-		if (dsp->conf->software && dsp->echo.hardware)
-			tx_data_only = 1;
+		if (dsp->conf && dsp->conf->software)
+			if (dsp->conf->hardware || dsp->echo.hardware)
+				tx_data_only = 1;
 	}
 
 #ifdef CMX_DEBUG



-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
