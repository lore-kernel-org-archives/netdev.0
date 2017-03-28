From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, net] isdn: kcapi: avoid uninitialized data
Date: Tue, 28 Mar 2017 12:11:07 +0200
Message-ID: <20170328101120.4086874-1-arnd@arndb.de>
Cc: "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-7 points out that the AVMB1_ADDCARD ioctl results in an unintialized
value ending up in the cardnr parameter:

drivers/isdn/capi/kcapi.c: In function 'old_capi_manufacturer':
drivers/isdn/capi/kcapi.c:1042:24: error: 'cdef.cardnr' may be used uninitialized in this function [-Werror=maybe-uninitialized]
   cparams.cardnr = cdef.cardnr;

This has been broken since before the start of the git history, so
either the value is not used for anything important, or the ioctl
command doesn't get called in practice.

Setting the cardnr to zero avoids the warning and makes sure
we have consistent behavior.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/isdn/capi/kcapi.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index 1dfd1085a04f..9ca691d6c13b 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -1032,6 +1032,7 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 						     sizeof(avmb1_carddef))))
 				return -EFAULT;
 			cdef.cardtype = AVM_CARDTYPE_B1;
+			cdef.cardnr = 0;
 		} else {
 			if ((retval = copy_from_user(&cdef, data,
 						     sizeof(avmb1_extcarddef))))
-- 
2.9.0
