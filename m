From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 3/3] net: ipconfig: drop inter-device timeout
Date: Fri, 29 Jul 2016 11:30:39 +0200
Message-ID: <1469784639-15705-4-git-send-email-u.kleine-koenig@pengutronix.de>
References: <20160728112613.n72e6pein3b5lm4b@pengutronix.de>
 <1469784639-15705-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Chris Friesen <cfriesen@nortel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:54348 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751123AbcG2JbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2016 05:31:11 -0400
In-Reply-To: <1469784639-15705-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that ipconfig learned to handle "delayed replies" in the previous
commit, there is no reason any more to delay sending a first request pe=
r
device.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 net/ipv4/ipconfig.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 5af6736bd384..42cf629357b5 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -85,7 +85,6 @@
 /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
 #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
 #define CONF_SEND_RETRIES 	6	/* Send six requests per open */
-#define CONF_INTER_TIMEOUT	(HZ)	/* Inter-device timeout: 1 second */
 #define CONF_BASE_TIMEOUT	(HZ*2)	/* Initial timeout: 2 seconds */
 #define CONF_TIMEOUT_RANDOM	(HZ)	/* Maximum amount of randomization */
 #define CONF_TIMEOUT_MULT	*7/4	/* Rate of timeout growth */
@@ -1225,9 +1224,11 @@ static int __init ic_dynamic(void)
 			ic_rarp_send_if(d);
 #endif
=20
-		jiff =3D jiffies + (d->next ? CONF_INTER_TIMEOUT : timeout);
-		while (time_before(jiffies, jiff) && !ic_got_reply)
-			schedule_timeout_uninterruptible(1);
+		if (!d->next) {
+			jiff =3D jiffies + timeout;
+			while (time_before(jiffies, jiff) && !ic_got_reply)
+				schedule_timeout_uninterruptible(1);
+		}
 #ifdef IPCONFIG_DHCP
 		/* DHCP isn't done until we get a DHCPACK. */
 		if ((ic_got_reply & IC_BOOTP) &&
--=20
2.8.1
