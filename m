From: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
Subject: [PATCH net] isdn: Partially revert debug format string usage clean up
Date: Wed, 25 Nov 2015 07:47:40 +0100
Message-ID: <1448433910@msgid.manchmal.in-ulm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from manchmal.in-ulm.de ([217.10.9.201]:35526 "EHLO
	manchmal.in-ulm.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbbKYG4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 01:56:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 35a4a57 ("isdn: clean up debug format string usage") introduced
a safeguard to avoid accidential format string interpolation of data
when calling debugl1 or HiSax_putstatus. This did however not take into
account VHiSax_putstatus (called by HiSax_putstatus) does *not* call
vsprintf if the head parameter is NULL - the format string is treated
as plain text then instead. As a result, the string "%s" is processed
literally, and the actual information is lost. This affects the isdnlog
userspace program which stopped logging information since that commit.

So revert the HiSax_putstatus invocations to the previous state.

Fixes: 35a4a5733b0a ("isdn: clean up debug format string usage")
Cc: Kees Cook <keescook@chromium.org>
Cc: Karsten Keil <isdn@linux-pingi.de>
Signed-off-by: Christoph Biedl <linux-kernel.bfrz@manchmal.in-ulm.de>
---
 drivers/isdn/hisax/config.c  | 2 +-
 drivers/isdn/hisax/hfc_pci.c | 2 +-
 drivers/isdn/hisax/hfc_sx.c  | 2 +-
 drivers/isdn/hisax/q931.c    | 6 +++---
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index b33f53b..bf04d2a 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -1896,7 +1896,7 @@ static void EChannel_proc_rcv(struct hisax_d_if *d_if)
 				ptr--;
 				*ptr++ = '\n';
 				*ptr = 0;
-				HiSax_putstatus(cs, NULL, "%s", cs->dlog);
+				HiSax_putstatus(cs, NULL, cs->dlog);
 			} else
 				HiSax_putstatus(cs, "LogEcho: ",
 						"warning Frame too big (%d)",
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index 4a48255..90449e1 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -901,7 +901,7 @@ Begin:
 					ptr--;
 					*ptr++ = '\n';
 					*ptr = 0;
-					HiSax_putstatus(cs, NULL, "%s", cs->dlog);
+					HiSax_putstatus(cs, NULL, cs->dlog);
 				} else
 					HiSax_putstatus(cs, "LogEcho: ", "warning Frame too big (%d)", total - 3);
 			}
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index b1fad81..13b2151 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -674,7 +674,7 @@ receive_emsg(struct IsdnCardState *cs)
 					ptr--;
 					*ptr++ = '\n';
 					*ptr = 0;
-					HiSax_putstatus(cs, NULL, "%s", cs->dlog);
+					HiSax_putstatus(cs, NULL, cs->dlog);
 				} else
 					HiSax_putstatus(cs, "LogEcho: ", "warning Frame too big (%d)", skb->len);
 			}
diff --git a/drivers/isdn/hisax/q931.c b/drivers/isdn/hisax/q931.c
index b420f8b..ba4beb2 100644
--- a/drivers/isdn/hisax/q931.c
+++ b/drivers/isdn/hisax/q931.c
@@ -1179,7 +1179,7 @@ LogFrame(struct IsdnCardState *cs, u_char *buf, int size)
 		dp--;
 		*dp++ = '\n';
 		*dp = 0;
-		HiSax_putstatus(cs, NULL, "%s", cs->dlog);
+		HiSax_putstatus(cs, NULL, cs->dlog);
 	} else
 		HiSax_putstatus(cs, "LogFrame: ", "warning Frame too big (%d)", size);
 }
@@ -1246,7 +1246,7 @@ dlogframe(struct IsdnCardState *cs, struct sk_buff *skb, int dir)
 	}
 	if (finish) {
 		*dp = 0;
-		HiSax_putstatus(cs, NULL, "%s", cs->dlog);
+		HiSax_putstatus(cs, NULL, cs->dlog);
 		return;
 	}
 	if ((0xfe & buf[0]) == PROTO_DIS_N0) {	/* 1TR6 */
@@ -1509,5 +1509,5 @@ dlogframe(struct IsdnCardState *cs, struct sk_buff *skb, int dir)
 		dp += sprintf(dp, "Unknown protocol %x!", buf[0]);
 	}
 	*dp = 0;
-	HiSax_putstatus(cs, NULL, "%s", cs->dlog);
+	HiSax_putstatus(cs, NULL, cs->dlog);
 }
-- 
2.1.4
