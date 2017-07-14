From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 19/22] block: DAC960: shut up format-overflow warning
Date: Fri, 14 Jul 2017 14:07:11 +0200
Message-ID: <20170714120720.906842-20-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>
To: linux-kernel@vger.kernel.org, Jens Axboe <axboe@fb.com>,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:52184 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932070AbdGNMNv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 08:13:51 -0400
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc-7 points out that a large controller number would overflow the
string length for the procfs name and the firmware version string:

drivers/block/DAC960.c: In function 'DAC960_Probe':
drivers/block/DAC960.c:6591:38: warning: 'sprintf' may write a terminating nul past the end of the destination [-Wformat-overflow=]
drivers/block/DAC960.c: In function 'DAC960_V1_ReadControllerConfiguration':
drivers/block/DAC960.c:1681:40: error: '%02d' directive writing between 2 and 3 bytes into a region of size between 2 and 5 [-Werror=format-overflow=]
drivers/block/DAC960.c:1681:40: note: directive argument in the range [0, 255]
drivers/block/DAC960.c:1681:3: note: 'sprintf' output between 10 and 14 bytes into a destination of size 12

Both of these seem appropriately sized, and using snprintf()
instead of sprintf() improves this by ensuring that even
incorrect data won't cause undefined behavior here.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/block/DAC960.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/block/DAC960.c b/drivers/block/DAC960.c
index 245a879b036e..255591ab3716 100644
--- a/drivers/block/DAC960.c
+++ b/drivers/block/DAC960.c
@@ -1678,9 +1678,12 @@ static bool DAC960_V1_ReadControllerConfiguration(DAC960_Controller_T
       Enquiry2->FirmwareID.FirmwareType = '0';
       Enquiry2->FirmwareID.TurnID = 0;
     }
-  sprintf(Controller->FirmwareVersion, "%d.%02d-%c-%02d",
-	  Enquiry2->FirmwareID.MajorVersion, Enquiry2->FirmwareID.MinorVersion,
-	  Enquiry2->FirmwareID.FirmwareType, Enquiry2->FirmwareID.TurnID);
+  snprintf(Controller->FirmwareVersion, sizeof(Controller->FirmwareVersion),
+	   "%d.%02d-%c-%02d",
+	   Enquiry2->FirmwareID.MajorVersion,
+	   Enquiry2->FirmwareID.MinorVersion,
+	   Enquiry2->FirmwareID.FirmwareType,
+	   Enquiry2->FirmwareID.TurnID);
   if (!((Controller->FirmwareVersion[0] == '5' &&
 	 strcmp(Controller->FirmwareVersion, "5.06") >= 0) ||
 	(Controller->FirmwareVersion[0] == '4' &&
@@ -6588,7 +6591,8 @@ static void DAC960_CreateProcEntries(DAC960_Controller_T *Controller)
 			    &dac960_proc_fops);
 	}
 
-	sprintf(Controller->ControllerName, "c%d", Controller->ControllerNumber);
+	snprintf(Controller->ControllerName, sizeof(Controller->ControllerName),
+		 "c%d", Controller->ControllerNumber);
 	ControllerProcEntry = proc_mkdir(Controller->ControllerName,
 					 DAC960_ProcDirectoryEntry);
 	proc_create_data("initial_status", 0, ControllerProcEntry, &dac960_initial_status_proc_fops, Controller);
-- 
2.9.0
