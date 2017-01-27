From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [net] ISDN: eicon: silence misleading array-bounds warning
Date: Fri, 27 Jan 2017 13:32:14 +0100
Message-ID: <20170127123225.3728707-1-arnd@arndb.de>
Cc: Nicholas Mc Guire <der.herr@hofr.at>,
        kernel-build-reports@lists.linaro.org,
        Arnd Bergmann <arnd@arndb.de>, stable@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Armin Schindler <mac@melware.de>,
        Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With some gcc versions, we get a warning about the eicon driver,
and that currently shows up as the only remaining warning in one
of the build bots:

In file included from ../drivers/isdn/hardware/eicon/message.c:30:0:
eicon/message.c: In function 'mixer_notify_update':
eicon/platform.h:333:18: warning: array subscript is above array bounds [-Warray-bounds]

The code is easily changed to open-code the unusual PUT_WORD() line
causing this to avoid the warning.

Cc: stable@vger.kernel.org
Link: http://arm-soc.lixom.net/buildlogs/stable-rc/v4.4.45/
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/isdn/hardware/eicon/message.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
index 1a1d99704fe6..296f1411fe84 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -11297,7 +11297,8 @@ static void mixer_notify_update(PLCI *plci, byte others)
 				((CAPI_MSG *) msg)->header.ncci = 0;
 				((CAPI_MSG *) msg)->info.facility_req.Selector = SELECTOR_LINE_INTERCONNECT;
 				((CAPI_MSG *) msg)->info.facility_req.structs[0] = 3;
-				PUT_WORD(&(((CAPI_MSG *) msg)->info.facility_req.structs[1]), LI_REQ_SILENT_UPDATE);
+				((CAPI_MSG *) msg)->info.facility_req.structs[1] = LI_REQ_SILENT_UPDATE & 0xff;
+				((CAPI_MSG *) msg)->info.facility_req.structs[2] = LI_REQ_SILENT_UPDATE >> 8;
 				((CAPI_MSG *) msg)->info.facility_req.structs[3] = 0;
 				w = api_put(notify_plci->appl, (CAPI_MSG *) msg);
 				if (w != _QUEUE_FULL)
-- 
2.9.0
