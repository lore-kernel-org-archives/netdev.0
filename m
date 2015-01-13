From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mISDN: avoid arch specific __builtin_return_address call
Date: Tue, 13 Jan 2015 17:10:58 +0100
Message-ID: <1816278.9Bv8N8K5IB@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Karsten Keil <isdn@linux-pingi.de>, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not all architectures are able to call __builtin_return_address().
On ARM, the mISDN code produces this warning:

hardware/mISDN/w6692.c: In function 'w6692_dctrl':
hardware/mISDN/w6692.c:1181:75: warning: unsupported argument to '__builtin_return_address'
  pr_debug("%s: %s dev(%d) open from %p\n", card->name, __func__,
                                                                           ^
hardware/mISDN/mISDNipac.c: In function 'open_dchannel':
hardware/mISDN/mISDNipac.c:759:75: warning: unsupported argument to '__builtin_return_address'
  pr_debug("%s: %s dev(%d) open from %p\n", isac->name, __func__,
                                                                           ^

In a lot of cases, this is relatively easy to work around by
passing the value of __builtin_return_address(0) from the
callers into the functions that want it. One exception is
the indirect 'open' function call in struct isac_hw. While it
would be possible to fix this as well, this patch only addresses
the other callers properly and lets this one return the direct
parent function, which should be good enough.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index ccd7d851be26..a77eea594b69 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -754,10 +754,10 @@ dbusy_timer_handler(struct isac_hw *isac)
 }
 
 static int
-open_dchannel(struct isac_hw *isac, struct channel_req *rq)
+open_dchannel_caller(struct isac_hw *isac, struct channel_req *rq, void *caller)
 {
 	pr_debug("%s: %s dev(%d) open from %p\n", isac->name, __func__,
-		 isac->dch.dev.id, __builtin_return_address(1));
+		 isac->dch.dev.id, caller);
 	if (rq->protocol != ISDN_P_TE_S0)
 		return -EINVAL;
 	if (rq->adr.channel == 1)
@@ -771,6 +771,12 @@ open_dchannel(struct isac_hw *isac, struct channel_req *rq)
 	return 0;
 }
 
+static int
+open_dchannel(struct isac_hw *isac, struct channel_req *rq)
+{
+	return open_dchannel_caller(isac, rq, __builtin_return_address(0));
+}
+
 static const char *ISACVer[] =
 {"2086/2186 V1.1", "2085 B1", "2085 B2",
  "2085 V2.3"};
@@ -1548,7 +1554,7 @@ ipac_dctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	case OPEN_CHANNEL:
 		rq = arg;
 		if (rq->protocol == ISDN_P_TE_S0)
-			err = open_dchannel(isac, rq);
+			err = open_dchannel_caller(isac, rq, __builtin_return_address(0));
 		else
 			err = open_bchannel(ipac, rq);
 		if (err)
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index de69f6828c76..741675525b53 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -1176,10 +1176,10 @@ w6692_l1callback(struct dchannel *dch, u32 cmd)
 }
 
 static int
-open_dchannel(struct w6692_hw *card, struct channel_req *rq)
+open_dchannel(struct w6692_hw *card, struct channel_req *rq, void *caller)
 {
 	pr_debug("%s: %s dev(%d) open from %p\n", card->name, __func__,
-		 card->dch.dev.id, __builtin_return_address(1));
+		 card->dch.dev.id, caller);
 	if (rq->protocol != ISDN_P_TE_S0)
 		return -EINVAL;
 	if (rq->adr.channel == 1)
@@ -1207,7 +1207,7 @@ w6692_dctrl(struct mISDNchannel *ch, u32 cmd, void *arg)
 	case OPEN_CHANNEL:
 		rq = arg;
 		if (rq->protocol == ISDN_P_TE_S0)
-			err = open_dchannel(card, rq);
+			err = open_dchannel(card, rq, __builtin_return_address(0));
 		else
 			err = open_bchannel(card, rq);
 		if (err)
