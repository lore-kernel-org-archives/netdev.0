From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH 2] isdn: fix 'and' typo's
Date: Fri, 26 Oct 2007 19:20:49 +0200
Message-ID: <472221F1.9030601@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.tiscali.nl ([195.241.79.176]:52210 "EHLO
	smtp-out1.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756558AbXJZRUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 13:20:55 -0400
Received: from [82.171.216.234] (helo=[192.168.1.2])
	by smtp-out1.tiscali.nl with esmtp (Tiscali http://www.tiscali.nl)
	id 1IlSrc-0004pB-4c
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 19:20:53 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is similar to the former, but affects isdn drivers.
also note these changes in drivers/isdn/i4l/isdn_ttyfax.c:
-		if (!info->faxonline & 1)	/* not outgoing connection */
+		if (!info->faxonline)	/* not outgoing connection */
...
-			if ((f->phase != ISDN_FAX_PHASE_D) || (!info->faxonline & 1))
+			if ((f->phase != ISDN_FAX_PHASE_D) || (!info->faxonline))
rationale: not already makes it binary

The condition '!x & y,' does make little sense: the '!' has a higher
priority than '&'. It behaves therefore like '!x && y'. In the case 
bitanding flags, however, '!(x & y)' appears to be desired.

Warning: the change of '!x & y,' to '!(x & y)' may change behavior. if
not desired, I propose changing this to '!x && y', to make it explicitly
clear.
--
    Fix priority mistakes similar to '!x & y'
    
    Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/isdn/act2000/module.c b/drivers/isdn/act2000/module.c
index ee2b0b9..8325022 100644
--- a/drivers/isdn/act2000/module.c
+++ b/drivers/isdn/act2000/module.c
@@ -310,7 +310,7 @@ act2000_command(act2000_card * card, isdn_ctrl * c)
 			}
 			break;
 		case ISDN_CMD_DIAL:
-			if (!card->flags & ACT2000_FLAGS_RUNNING)
+			if (!(card->flags & ACT2000_FLAGS_RUNNING))
 				return -ENODEV;
 			if (!(chan = find_channel(card, c->arg & 0x0f)))
 				break;
@@ -339,7 +339,7 @@ act2000_command(act2000_card * card, isdn_ctrl * c)
 			}
 			return ret;
 		case ISDN_CMD_ACCEPTD:
-			if (!card->flags & ACT2000_FLAGS_RUNNING)
+			if (!(card->flags & ACT2000_FLAGS_RUNNING))
 				return -ENODEV;
 			if (!(chan = find_channel(card, c->arg & 0x0f)))
 				break;
@@ -347,11 +347,11 @@ act2000_command(act2000_card * card, isdn_ctrl * c)
 				actcapi_select_b2_protocol_req(card, chan);
 			return 0;
 		case ISDN_CMD_ACCEPTB:
-			if (!card->flags & ACT2000_FLAGS_RUNNING)
+			if (!(card->flags & ACT2000_FLAGS_RUNNING))
 				return -ENODEV;
 			return 0;
 		case ISDN_CMD_HANGUP:
-			if (!card->flags & ACT2000_FLAGS_RUNNING)
+			if (!(card->flags & ACT2000_FLAGS_RUNNING))
 				return -ENODEV;
 			if (!(chan = find_channel(card, c->arg & 0x0f)))
 				break;
@@ -366,7 +366,7 @@ act2000_command(act2000_card * card, isdn_ctrl * c)
 			}
 			return 0;
 		case ISDN_CMD_SETEAZ:
-			if (!card->flags & ACT2000_FLAGS_RUNNING)
+			if (!(card->flags & ACT2000_FLAGS_RUNNING))
 				return -ENODEV;
 			if (!(chan = find_channel(card, c->arg & 0x0f)))
 				break;
@@ -386,7 +386,7 @@ act2000_command(act2000_card * card, isdn_ctrl * c)
 			actcapi_listen_req(card);
 			return 0;
 		case ISDN_CMD_CLREAZ:
-			if (!card->flags & ACT2000_FLAGS_RUNNING)
+			if (!(card->flags & ACT2000_FLAGS_RUNNING))
 				return -ENODEV;
 			if (!(chan = find_channel(card, c->arg & 0x0f)))
 				break;
@@ -394,14 +394,14 @@ act2000_command(act2000_card * card, isdn_ctrl * c)
 			actcapi_listen_req(card);
 			return 0;
 		case ISDN_CMD_SETL2:
-			if (!card->flags & ACT2000_FLAGS_RUNNING)
+			if (!(card->flags & ACT2000_FLAGS_RUNNING))
 				return -ENODEV;
 			if (!(chan = find_channel(card, c->arg & 0x0f)))
 				break;
 			chan->l2prot = (c->arg >> 8);
 			return 0;
 		case ISDN_CMD_SETL3:
-			if (!card->flags & ACT2000_FLAGS_RUNNING)
+			if (!(card->flags & ACT2000_FLAGS_RUNNING))
 				return -ENODEV;
 			if ((c->arg >> 8) != ISDN_PROTO_L3_TRANS) {
 				printk(KERN_WARNING "L3 protocol unknown\n");
@@ -524,7 +524,7 @@ if_writecmd(const u_char __user *buf, int len, int id, int channel)
         act2000_card *card = act2000_findcard(id);
 
         if (card) {
-                if (!card->flags & ACT2000_FLAGS_RUNNING)
+                if (!(card->flags & ACT2000_FLAGS_RUNNING))
                         return -ENODEV;
                 return (len);
         }
@@ -539,7 +539,7 @@ if_readstatus(u_char __user * buf, int len, int id, int channel)
         act2000_card *card = act2000_findcard(id);
 	
         if (card) {
-                if (!card->flags & ACT2000_FLAGS_RUNNING)
+                if (!(card->flags & ACT2000_FLAGS_RUNNING))
                         return -ENODEV;
                 return (act2000_readstatus(buf, len, card));
         }
@@ -554,7 +554,7 @@ if_sendbuf(int id, int channel, int ack, struct sk_buff *skb)
         act2000_card *card = act2000_findcard(id);
 	
         if (card) {
-                if (!card->flags & ACT2000_FLAGS_RUNNING)
+                if (!(card->flags & ACT2000_FLAGS_RUNNING))
                         return -ENODEV;
 		return (act2000_sendbuf(card, channel, ack, skb));
         }
diff --git a/drivers/isdn/i4l/isdn_ttyfax.c b/drivers/isdn/i4l/isdn_ttyfax.c
index a943d07..d854f22 100644
--- a/drivers/isdn/i4l/isdn_ttyfax.c
+++ b/drivers/isdn/i4l/isdn_ttyfax.c
@@ -834,7 +834,7 @@ isdn_tty_cmd_FCLASS2(char **p, modem_info * info)
 		char *rp = &f->resolution;
 
 		p[0] += 2;
-		if (!info->faxonline & 1)	/* not outgoing connection */
+		if (!info->faxonline)	/* not outgoing connection */
 			PARSE_ERROR1;
 
 		for (i = 0; (((*p[0] >= '0') && (*p[0] <= '9')) || (*p[0] == ',')) && (i < 4); i++) {
@@ -906,7 +906,7 @@ isdn_tty_cmd_FCLASS2(char **p, modem_info * info)
 			sprintf(rs, "\r\n0-2");
 			isdn_tty_at_cout(rs, info);
 		} else {
-			if ((f->phase != ISDN_FAX_PHASE_D) || (!info->faxonline & 1))
+			if ((f->phase != ISDN_FAX_PHASE_D) || (!info->faxonline))
 				PARSE_ERROR1;
 			par = isdn_getnum(p);
 			if ((par < 0) || (par > 2))
diff --git a/drivers/isdn/icn/icn.c b/drivers/isdn/icn/icn.c
index 82d957b..bf7997a 100644
--- a/drivers/isdn/icn/icn.c
+++ b/drivers/isdn/icn/icn.c
@@ -1302,7 +1302,7 @@ icn_command(isdn_ctrl * c, icn_card * card)
 			}
 			break;
 		case ISDN_CMD_DIAL:
-			if (!card->flags & ICN_FLAGS_RUNNING)
+			if (!(card->flags & ICN_FLAGS_RUNNING))
 				return -ENODEV;
 			if (card->leased)
 				break;
@@ -1328,7 +1328,7 @@ icn_command(isdn_ctrl * c, icn_card * card)
 			}
 			break;
 		case ISDN_CMD_ACCEPTD:
-			if (!card->flags & ICN_FLAGS_RUNNING)
+			if (!(card->flags & ICN_FLAGS_RUNNING))
 				return -ENODEV;
 			if (c->arg < ICN_BCH) {
 				a = c->arg + 1;
@@ -1348,7 +1348,7 @@ icn_command(isdn_ctrl * c, icn_card * card)
 			}
 			break;
 		case ISDN_CMD_ACCEPTB:
-			if (!card->flags & ICN_FLAGS_RUNNING)
+			if (!(card->flags & ICN_FLAGS_RUNNING))
 				return -ENODEV;
 			if (c->arg < ICN_BCH) {
 				a = c->arg + 1;
@@ -1366,7 +1366,7 @@ icn_command(isdn_ctrl * c, icn_card * card)
 			}
 			break;
 		case ISDN_CMD_HANGUP:
-			if (!card->flags & ICN_FLAGS_RUNNING)
+			if (!(card->flags & ICN_FLAGS_RUNNING))
 				return -ENODEV;
 			if (c->arg < ICN_BCH) {
 				a = c->arg + 1;
@@ -1375,7 +1375,7 @@ icn_command(isdn_ctrl * c, icn_card * card)
 			}
 			break;
 		case ISDN_CMD_SETEAZ:
-			if (!card->flags & ICN_FLAGS_RUNNING)
+			if (!(card->flags & ICN_FLAGS_RUNNING))
 				return -ENODEV;
 			if (card->leased)
 				break;
@@ -1391,7 +1391,7 @@ icn_command(isdn_ctrl * c, icn_card * card)
 			}
 			break;
 		case ISDN_CMD_CLREAZ:
-			if (!card->flags & ICN_FLAGS_RUNNING)
+			if (!(card->flags & ICN_FLAGS_RUNNING))
 				return -ENODEV;
 			if (card->leased)
 				break;
@@ -1405,7 +1405,7 @@ icn_command(isdn_ctrl * c, icn_card * card)
 			}
 			break;
 		case ISDN_CMD_SETL2:
-			if (!card->flags & ICN_FLAGS_RUNNING)
+			if (!(card->flags & ICN_FLAGS_RUNNING))
 				return -ENODEV;
 			if ((c->arg & 255) < ICN_BCH) {
 				a = c->arg;
@@ -1424,7 +1424,7 @@ icn_command(isdn_ctrl * c, icn_card * card)
 			}
 			break;
 		case ISDN_CMD_SETL3:
-			if (!card->flags & ICN_FLAGS_RUNNING)
+			if (!(card->flags & ICN_FLAGS_RUNNING))
 				return -ENODEV;
 			return 0;
 		default:
@@ -1471,7 +1471,7 @@ if_writecmd(const u_char __user *buf, int len, int id, int channel)
 	icn_card *card = icn_findcard(id);
 
 	if (card) {
-		if (!card->flags & ICN_FLAGS_RUNNING)
+		if (!(card->flags & ICN_FLAGS_RUNNING))
 			return -ENODEV;
 		return (icn_writecmd(buf, len, 1, card));
 	}
@@ -1486,7 +1486,7 @@ if_readstatus(u_char __user *buf, int len, int id, int channel)
 	icn_card *card = icn_findcard(id);
 
 	if (card) {
-		if (!card->flags & ICN_FLAGS_RUNNING)
+		if (!(card->flags & ICN_FLAGS_RUNNING))
 			return -ENODEV;
 		return (icn_readstatus(buf, len, card));
 	}
@@ -1501,7 +1501,7 @@ if_sendbuf(int id, int channel, int ack, struct sk_buff *skb)
 	icn_card *card = icn_findcard(id);
 
 	if (card) {
-		if (!card->flags & ICN_FLAGS_RUNNING)
+		if (!(card->flags & ICN_FLAGS_RUNNING))
 			return -ENODEV;
 		return (icn_sendbuf(channel, ack, skb, card));
 	}
diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index bb92e3c..a335c85 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -1184,7 +1184,7 @@ isdnloop_command(isdn_ctrl * c, isdnloop_card * card)
 			}
 			break;
 		case ISDN_CMD_DIAL:
-			if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+			if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 				return -ENODEV;
 			if (card->leased)
 				break;
@@ -1210,7 +1210,7 @@ isdnloop_command(isdn_ctrl * c, isdnloop_card * card)
 			}
 			break;
 		case ISDN_CMD_ACCEPTD:
-			if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+			if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 				return -ENODEV;
 			if (c->arg < ISDNLOOP_BCH) {
 				a = c->arg + 1;
@@ -1238,7 +1238,7 @@ isdnloop_command(isdn_ctrl * c, isdnloop_card * card)
 			}
 			break;
 		case ISDN_CMD_ACCEPTB:
-			if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+			if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 				return -ENODEV;
 			if (c->arg < ISDNLOOP_BCH) {
 				a = c->arg + 1;
@@ -1264,7 +1264,7 @@ isdnloop_command(isdn_ctrl * c, isdnloop_card * card)
 				i = isdnloop_writecmd(cbuf, strlen(cbuf), 0, card);
 				break;
 		case ISDN_CMD_HANGUP:
-				if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+				if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 					return -ENODEV;
 				if (c->arg < ISDNLOOP_BCH) {
 					a = c->arg + 1;
@@ -1273,7 +1273,7 @@ isdnloop_command(isdn_ctrl * c, isdnloop_card * card)
 				}
 				break;
 		case ISDN_CMD_SETEAZ:
-				if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+				if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 					return -ENODEV;
 				if (card->leased)
 					break;
@@ -1289,7 +1289,7 @@ isdnloop_command(isdn_ctrl * c, isdnloop_card * card)
 				}
 				break;
 		case ISDN_CMD_CLREAZ:
-				if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+				if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 					return -ENODEV;
 				if (card->leased)
 					break;
@@ -1303,7 +1303,7 @@ isdnloop_command(isdn_ctrl * c, isdnloop_card * card)
 				}
 				break;
 		case ISDN_CMD_SETL2:
-				if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+				if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 					return -ENODEV;
 				if ((c->arg & 255) < ISDNLOOP_BCH) {
 					a = c->arg;
@@ -1333,7 +1333,7 @@ isdnloop_command(isdn_ctrl * c, isdnloop_card * card)
 				}
 				break;
 		case ISDN_CMD_SETL3:
-				if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+				if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 					return -ENODEV;
 				return 0;
 		default:
@@ -1380,7 +1380,7 @@ if_writecmd(const u_char __user *buf, int len, int id, int channel)
 	isdnloop_card *card = isdnloop_findcard(id);
 
 	if (card) {
-		if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+		if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 			return -ENODEV;
 		return (isdnloop_writecmd(buf, len, 1, card));
 	}
@@ -1395,7 +1395,7 @@ if_readstatus(u_char __user *buf, int len, int id, int channel)
 	isdnloop_card *card = isdnloop_findcard(id);
 
 	if (card) {
-		if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+		if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 			return -ENODEV;
 		return (isdnloop_readstatus(buf, len, card));
 	}
@@ -1410,7 +1410,7 @@ if_sendbuf(int id, int channel, int ack, struct sk_buff *skb)
 	isdnloop_card *card = isdnloop_findcard(id);
 
 	if (card) {
-		if (!card->flags & ISDNLOOP_FLAGS_RUNNING)
+		if (!(card->flags & ISDNLOOP_FLAGS_RUNNING))
 			return -ENODEV;
 		/* ack request stored in skb scratch area */
 		*(skb->head) = ack;
