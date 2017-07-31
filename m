From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ISDN: eicon: fix array-bounds warning properly
Date: Mon, 31 Jul 2017 11:04:29 +0200
Message-ID: <20170731090438.458392-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Armin Schindler <mac@melware.de>,
        Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I patched a variant of this warning before, but now saw it come back
in a different configuration with gcc-7 and UBSAN:

drivers/isdn/hardware/eicon/message.c: In function 'mixer_notify_update':
drivers/isdn/hardware/eicon/message.c:11162:54: error: array subscript is above array bounds [-Werror=array-bounds]
     ((CAPI_MSG *) msg)->info.facility_req.structs[1] = LI_REQ_SILENT_UPDATE & 0xff;
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/isdn/hardware/eicon/message.c:11163:54: error: array subscript is above array bounds [-Werror=array-bounds]
     ((CAPI_MSG *) msg)->info.facility_req.structs[2] = LI_REQ_SILENT_UPDATE >> 8;
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/isdn/hardware/eicon/message.c:11164:54: error: array subscript is above array bounds [-Werror=array-bounds]
     ((CAPI_MSG *) msg)->info.facility_req.structs[3] = 0;
     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~

I spent a long time narrowing down what caused this, as I suspected
yet another false-positive warning in gcc. However, this time it
turned out to be an ancient kernel bug, which probably prevented
this from ever working on 64-bit machines, causing a stack
buffer overflow as indicated by the warning originally.

The problem is that having a 64-bit pointer inside of the CAPI_MSG->info
union leads to the start of the union to become 64-bit aligned by adding
four padding bytes. The structure is however aliased to a fixed-length
array on the stack in mixer_notify_update(), and later copied directly
to the hardware, so both go wrong.

This just removes the fields that were apparently added in a misguided
attempt to make the driver work on 64-bit machines but never actually
used.

Fixes: 950eabbd6dde ("ISDN: eicon: silence misleading array-bounds warning")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/isdn/hardware/eicon/capi20.h | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/capi20.h b/drivers/isdn/hardware/eicon/capi20.h
index 391e4175b0b5..7b97cd576485 100644
--- a/drivers/isdn/hardware/eicon/capi20.h
+++ b/drivers/isdn/hardware/eicon/capi20.h
@@ -301,14 +301,6 @@ typedef struct {
 	word          Number;
 	word          Flags;
 } _DAT_B3_REQP;
-/* DATA-B3-REQUEST 64 BIT Systems                           */
-typedef struct {
-	dword         Data;
-	word          Data_Length;
-	word          Number;
-	word          Flags;
-	void          *pData;
-} _DAT_B3_REQ64P;
 /* DATA-B3-CONFIRM                                          */
 typedef struct {
 	word          Number;
@@ -321,14 +313,6 @@ typedef struct {
 	word          Number;
 	word          Flags;
 } _DAT_B3_INDP;
-/* DATA-B3-INDICATION  64 BIT Systems                       */
-typedef struct {
-	dword         Data;
-	word          Data_Length;
-	word          Number;
-	word          Flags;
-	void          *pData;
-} _DAT_B3_IND64P;
 /* DATA-B3-RESPONSE                                         */
 typedef struct {
 	word          Number;
@@ -409,10 +393,8 @@ struct _API_MSG {
 		_DIS_B3_INDP        disconnect_b3_ind;
 		_DIS_B3_RESP        disconnect_b3_res;
 		_DAT_B3_REQP        data_b3_req;
-		_DAT_B3_REQ64P      data_b3_req64;
 		_DAT_B3_CONP        data_b3_con;
 		_DAT_B3_INDP        data_b3_ind;
-		_DAT_B3_IND64P      data_b3_ind64;
 		_DAT_B3_RESP        data_b3_res;
 		_RES_B3_REQP        reset_b3_req;
 		_RES_B3_CONP        reset_b3_con;
-- 
2.9.0
