From: akpm@linux-foundation.org
Subject: [patch 2/3] i4l: silence compiler warnings for array access in Eicon DIVA ISDN driver
Date: Thu, 11 Mar 2010 14:07:24 -0800
Message-ID: <201003112207.o2BM7OZg013459@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	imunsie@au.ibm.com, mac@melware.de, sgayda2@uiuc.edu
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36951 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758264Ab0CKWHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 17:07:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Munsie <imunsie@au.ibm.com>

When compiling this driver, the compiler throws the following warnings:

drivers/isdn/hardware/eicon/message.c:8426: warning: array subscript is above array bounds
drivers/isdn/hardware/eicon/message.c:8427: warning: array subscript is above array bounds
drivers/isdn/hardware/eicon/message.c:8434: warning: array subscript is above array bounds
drivers/isdn/hardware/eicon/message.c:8435: warning: array subscript is above array bounds
drivers/isdn/hardware/eicon/message.c:8436: warning: array subscript is above array bounds
drivers/isdn/hardware/eicon/message.c:8447: warning: array subscript is above array bounds

This arises from the particular semantics the driver is using to write to
the nlc array (static byte[256]).  The array has a length in byte 0
followed by a T30_INFO struct starting at byte 1.

The T30_INFO struct has a number of variable length strings after the
station_id entry, which cannot be explicitly defined in the struct and the
driver accesses them with an array index to station_id beyond the length
of station_id.

This patch merely changes the semantics that the driver uses to access the
entries after the station_id entry to use the original 256 byte nlc array
taking the offset and length of the station_id entry to calculate where to
write in the array, thereby silencing the warning.

Signed-off-by: Ian Munsie <imunsie@au.ibm.com>
Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Stoyan Gaydarov <sgayda2@uiuc.edu>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/eicon/message.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff -puN drivers/isdn/hardware/eicon/message.c~i4l-silence-compiler-warnings-for-array-access-in-eicon-diva-isdn-driver drivers/isdn/hardware/eicon/message.c
--- a/drivers/isdn/hardware/eicon/message.c~i4l-silence-compiler-warnings-for-array-access-in-eicon-diva-isdn-driver
+++ a/drivers/isdn/hardware/eicon/message.c
@@ -8423,17 +8423,17 @@ static word add_b23(PLCI *plci, API_PARS
             pos = 0;
           else
           {
-            ((T30_INFO *)&nlc[1])->station_id[20 + pos++] = ' ';
-            ((T30_INFO *)&nlc[1])->station_id[20 + pos++] = ' ';
+            nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ' ';
+            nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ' ';
             len = (byte)b3_config_parms[2].length;
             if (len > 20)
               len = 20;
             if (CAPI_MAX_DATE_TIME_LENGTH + 2 + len + 2 + b3_config_parms[3].length <= CAPI_MAX_HEAD_LINE_SPACE)
             {
               for (i = 0; i < len; i++)
-                ((T30_INFO *)&nlc[1])->station_id[20 + pos++] = ((byte   *)b3_config_parms[2].info)[1+i];
-              ((T30_INFO *)&nlc[1])->station_id[20 + pos++] = ' ';
-              ((T30_INFO *)&nlc[1])->station_id[20 + pos++] = ' ';
+                nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ((byte   *)b3_config_parms[2].info)[1+i];
+              nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ' ';
+              nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] = ' ';
             }
           }
         }
@@ -8444,9 +8444,8 @@ static word add_b23(PLCI *plci, API_PARS
         ((T30_INFO *)&nlc[1])->head_line_len = (byte)(pos + len);
         nlc[0] += (byte)(pos + len);
         for (i = 0; i < len; i++)
-          ((T30_INFO *)&nlc[1])->station_id[20 + pos++] = ((byte   *)b3_config_parms[3].info)[1+i];
-        }
-      else
+          nlc[1 + offsetof(T30_INFO, station_id) + 20 + pos++] =  ((byte   *)b3_config_parms[3].info)[1+i];
+      } else
         ((T30_INFO *)&nlc[1])->head_line_len = 0;
 
       plci->nsf_control_bits = 0;
_
