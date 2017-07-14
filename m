From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 08/22] isdn: divert: fix sprintf buffer overflow warning
Date: Fri, 14 Jul 2017 14:07:00 +0200
Message-ID: <20170714120720.906842-9-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org
To: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
        Geliang Tang <geliangtang@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One string we pass into the cs->info buffer might be too long,
as pointed out by gcc:

drivers/isdn/divert/isdn_divert.c: In function 'll_callback':
drivers/isdn/divert/isdn_divert.c:488:22: error: '%d' directive writing between 1 and 3 bytes into a region of size between 1 and 69 [-Werror=format-overflow=]
 sprintf(cs->info, "%d 0x%lx %s %s %s %s 0x%x 0x%x %d %d %s\n",
                   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
drivers/isdn/divert/isdn_divert.c:488:22: note: directive argument in the range [0, 255]
drivers/isdn/divert/isdn_divert.c:488:4: note: 'sprintf' output 25 or more bytes (assuming 129) into a destination of size 90

This is unlikely to actually cause problems, so let's use snprintf
as a simple workaround to shut  up the warning and truncate the
buffer instead.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/isdn/divert/isdn_divert.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/divert/isdn_divert.c b/drivers/isdn/divert/isdn_divert.c
index 060d357f107f..6f423bc49d0d 100644
--- a/drivers/isdn/divert/isdn_divert.c
+++ b/drivers/isdn/divert/isdn_divert.c
@@ -485,18 +485,19 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 				cs->deflect_dest[0] = '\0';
 				retval = 4; /* only proceed */
 			}
-			sprintf(cs->info, "%d 0x%lx %s %s %s %s 0x%x 0x%x %d %d %s\n",
-				cs->akt_state,
-				cs->divert_id,
-				divert_if.drv_to_name(cs->ics.driver),
-				(ic->command == ISDN_STAT_ICALLW) ? "1" : "0",
-				cs->ics.parm.setup.phone,
-				cs->ics.parm.setup.eazmsn,
-				cs->ics.parm.setup.si1,
-				cs->ics.parm.setup.si2,
-				cs->ics.parm.setup.screen,
-				dv->rule.waittime,
-				cs->deflect_dest);
+			snprintf(cs->info, sizeof(cs->info),
+				 "%d 0x%lx %s %s %s %s 0x%x 0x%x %d %d %s\n",
+				 cs->akt_state,
+				 cs->divert_id,
+				 divert_if.drv_to_name(cs->ics.driver),
+				 (ic->command == ISDN_STAT_ICALLW) ? "1" : "0",
+				 cs->ics.parm.setup.phone,
+				 cs->ics.parm.setup.eazmsn,
+				 cs->ics.parm.setup.si1,
+				 cs->ics.parm.setup.si2,
+				 cs->ics.parm.setup.screen,
+				 dv->rule.waittime,
+				 cs->deflect_dest);
 			if ((dv->rule.action == DEFLECT_REPORT) ||
 			    (dv->rule.action == DEFLECT_REJECT)) {
 				put_info_buffer(cs->info);
-- 
2.9.0
