From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] isdn: Constify some function parameters
Date: Fri, 16 Dec 2016 13:40:47 -0800
Message-ID: <20161216214047.GA90306@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Emese Revfy <re.emese@gmail.com>,
        netdev@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:34166 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933692AbcLPVkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 16:40:49 -0500
Received: by mail-pg0-f46.google.com with SMTP id a1so13266794pgf.1
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 13:40:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emese Revfy <re.emese@gmail.com>

The coming initify gcc plugin expects const pointer types, and caught
some __printf arguments that weren't const yet. This fixes those.

Signed-off-by: Emese Revfy <re.emese@gmail.com>
[kees: expanded commit message]
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/isdn/hisax/config.c | 16 ++++++++--------
 drivers/isdn/hisax/hisax.h  |  4 ++--
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index bf04d2a3cf4a..2d12c6ceeb89 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -659,7 +659,7 @@ int jiftime(char *s, long mark)
 
 static u_char tmpbuf[HISAX_STATUS_BUFSIZE];
 
-void VHiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt,
+void VHiSax_putstatus(struct IsdnCardState *cs, char *head, const char *fmt,
 		      va_list args)
 {
 	/* if head == NULL the fmt contains the full info */
@@ -669,23 +669,24 @@ void VHiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt,
 	u_char		*p;
 	isdn_ctrl	ic;
 	int		len;
+	const u_char	*data;
 
 	if (!cs) {
 		printk(KERN_WARNING "HiSax: No CardStatus for message");
 		return;
 	}
 	spin_lock_irqsave(&cs->statlock, flags);
-	p = tmpbuf;
 	if (head) {
+		p = tmpbuf;
 		p += jiftime(p, jiffies);
 		p += sprintf(p, " %s", head);
 		p += vsprintf(p, fmt, args);
 		*p++ = '\n';
 		*p = 0;
 		len = p - tmpbuf;
-		p = tmpbuf;
+		data = tmpbuf;
 	} else {
-		p = fmt;
+		data = fmt;
 		len = strlen(fmt);
 	}
 	if (len > HISAX_STATUS_BUFSIZE) {
@@ -699,13 +700,12 @@ void VHiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt,
 	if (i >= len)
 		i = len;
 	len -= i;
-	memcpy(cs->status_write, p, i);
+	memcpy(cs->status_write, data, i);
 	cs->status_write += i;
 	if (cs->status_write > cs->status_end)
 		cs->status_write = cs->status_buf;
-	p += i;
 	if (len) {
-		memcpy(cs->status_write, p, len);
+		memcpy(cs->status_write, data + i, len);
 		cs->status_write += len;
 	}
 #ifdef KERNELSTACK_DEBUG
@@ -729,7 +729,7 @@ void VHiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt,
 	}
 }
 
-void HiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt, ...)
+void HiSax_putstatus(struct IsdnCardState *cs, char *head, const char *fmt, ...)
 {
 	va_list args;
 
diff --git a/drivers/isdn/hisax/hisax.h b/drivers/isdn/hisax/hisax.h
index 6ead6314e6d2..338d0408b377 100644
--- a/drivers/isdn/hisax/hisax.h
+++ b/drivers/isdn/hisax/hisax.h
@@ -1288,9 +1288,9 @@ int jiftime(char *s, long mark);
 int HiSax_command(isdn_ctrl *ic);
 int HiSax_writebuf_skb(int id, int chan, int ack, struct sk_buff *skb);
 __printf(3, 4)
-void HiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt, ...);
+void HiSax_putstatus(struct IsdnCardState *cs, char *head, const char *fmt, ...);
 __printf(3, 0)
-void VHiSax_putstatus(struct IsdnCardState *cs, char *head, char *fmt, va_list args);
+void VHiSax_putstatus(struct IsdnCardState *cs, char *head, const char *fmt, va_list args);
 void HiSax_reportcard(int cardnr, int sel);
 int QuickHex(char *txt, u_char *p, int cnt);
 void LogFrame(struct IsdnCardState *cs, u_char *p, int size);
-- 
2.7.4


-- 
Kees Cook
Nexus Security
