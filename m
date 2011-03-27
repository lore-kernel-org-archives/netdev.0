From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] kstrtox: convert drivers/isdn/
Date: Sun, 27 Mar 2011 15:58:35 +0300
Message-ID: <20110327125835.GA5820@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: t.schmidt@phoenixsoftware.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34805 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab1C0N6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 09:58:41 -0400
Received: by bwz15 with SMTP id 15so1863312bwz.19
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 06:58:39 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/isdn/gigaset/ev-layer.c    |   26 +++++++++-----------------
 drivers/isdn/hysdn/hysdn_proclog.c |   11 ++++-------
 2 files changed, 13 insertions(+), 24 deletions(-)

--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -390,12 +390,12 @@ static const struct zsau_resp_t {
  */
 static int cid_of_response(char *s)
 {
-	unsigned long cid;
+	int cid;
 	int rc;
 
 	if (s[-1] != ';')
 		return 0;	/* no CID separator */
-	rc = strict_strtoul(s, 10, &cid);
+	rc = kstrtoint(s, 10, &cid);
 	if (rc)
 		return 0;	/* CID not numeric */
 	if (cid < 1 || cid > 65535)
@@ -566,27 +566,19 @@ void gigaset_handle_modem_response(struct cardstate *cs)
 		case RT_ZCAU:
 			event->parameter = -1;
 			if (curarg + 1 < params) {
-				unsigned long type, value;
-
-				i = strict_strtoul(argv[curarg++], 16, &type);
-				j = strict_strtoul(argv[curarg++], 16, &value);
+				u8 type, value;
 
-				if (i == 0 && type < 256 &&
-				    j == 0 && value < 256)
+				i = kstrtou8(argv[curarg++], 16, &type);
+				j = kstrtou8(argv[curarg++], 16, &value);
+				if (i == 0 && j == 0)
 					event->parameter = (type << 8) | value;
 			} else
 				curarg = params - 1;
 			break;
 		case RT_NUMBER:
-			event->parameter = -1;
-			if (curarg < params) {
-				unsigned long res;
-				int rc;
-
-				rc = strict_strtoul(argv[curarg++], 10, &res);
-				if (rc == 0)
-					event->parameter = res;
-			}
+			if (curarg >= params ||
+			    kstrtoint(argv[curarg++], 10, &event->parameter))
+				event->parameter = -1;
 			gig_dbg(DEBUG_EVENT, "parameter==%d", event->parameter);
 			break;
 		}
--- a/drivers/isdn/hysdn/hysdn_proclog.c
+++ b/drivers/isdn/hysdn/hysdn_proclog.c
@@ -155,7 +155,6 @@ put_log_buffer(hysdn_card * card, char *cp)
 static ssize_t
 hysdn_log_write(struct file *file, const char __user *buf, size_t count, loff_t * off)
 {
-	unsigned long u = 0;
 	int rc;
 	unsigned char valbuf[128];
 	hysdn_card *card = file->private_data;
@@ -167,12 +166,10 @@ hysdn_log_write(struct file *file, const char __user *buf, size_t count, loff_t
 
 	valbuf[count] = 0;	/* terminating 0 */
 
-	rc = strict_strtoul(valbuf, 0, &u);
-
-	if (rc == 0) {
-		card->debug_flags = u;	/* remember debug flags */
-		hysdn_addlog(card, "debug set to 0x%lx", card->debug_flags);
-	}
+	rc = kstrtoul(valbuf, 0, &card->debug_flags);
+	if (rc < 0)
+		return rc;
+	hysdn_addlog(card, "debug set to 0x%lx", card->debug_flags);
 	return (count);
 }				/* hysdn_log_write */
 
