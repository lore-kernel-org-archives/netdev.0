From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM] don't export llc_oui
Date: Mon, 08 Sep 2003 16:50:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309082050.h88KoUSa003672@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com, mitch@sfgoth.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

llc_oui[] is only used in two places.  the overhead of exporting
probably isnt worth the effort.  please apply to 2.6. -- thanks!

[ATM]: exporting llc_oui[] isn't worth it (from mitch@sfgoth.com)

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1423  -> 1.1424 
#	  net/atm/ipcommon.c	1.2     -> 1.3    
#	 net/sched/sch_atm.c	1.13    -> 1.14   
#	include/linux/atmclip.h	1.1     -> 1.2    
#	      net/atm/clip.c	1.25    -> 1.26   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/04	chas@relax.cmf.nrl.navy.mil	1.1424
# [ATM]: exporting llc_oui[] isn't worth it (from mitch@sfgoth.com)
# --------------------------------------------
#
diff -Nru a/include/linux/atmclip.h b/include/linux/atmclip.h
--- a/include/linux/atmclip.h	Mon Sep  8 16:38:01 2003
+++ b/include/linux/atmclip.h	Mon Sep  8 16:38:01 2003
@@ -18,8 +18,4 @@
 
 #define	SIOCMKCLIP	_IO('a',ATMIOC_CLIP)	/* create IP interface */
 
-#ifdef __KERNEL__
-extern const unsigned char llc_oui[6];
-#endif
-
 #endif
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Mon Sep  8 16:38:01 2003
+++ b/net/atm/clip.c	Mon Sep  8 16:38:01 2003
@@ -193,6 +193,13 @@
 	return 0;
 }
 
+static const unsigned char llc_oui[] = {
+	0xaa,	/* DSAP: non-ISO */
+	0xaa,	/* SSAP: non-ISO */
+	0x03,	/* Ctrl: Unnumbered Information Command PDU */
+	0x00,	/* OUI: EtherType */
+	0x00,
+	0x00 };
 
 static void clip_push(struct atm_vcc *vcc,struct sk_buff *skb)
 {
diff -Nru a/net/atm/ipcommon.c b/net/atm/ipcommon.c
--- a/net/atm/ipcommon.c	Mon Sep  8 16:38:01 2003
+++ b/net/atm/ipcommon.c	Mon Sep  8 16:38:01 2003
@@ -22,15 +22,6 @@
 #endif
 
 
-const unsigned char llc_oui[] = {
-	0xaa,	/* DSAP: non-ISO */
-	0xaa,	/* SSAP: non-ISO */
-	0x03,	/* Ctrl: Unnumbered Information Command PDU */
-	0x00,	/* OUI: EtherType */
-	0x00,
-	0x00 };
-
-
 /*
  * skb_migrate appends the list at "from" to "to", emptying "from" in the
  * process. skb_migrate is atomic with respect to all other skb operations on
@@ -67,5 +58,4 @@
 }
 
 
-EXPORT_SYMBOL(llc_oui);
 EXPORT_SYMBOL(skb_migrate);
diff -Nru a/net/sched/sch_atm.c b/net/sched/sch_atm.c
--- a/net/sched/sch_atm.c	Mon Sep  8 16:38:01 2003
+++ b/net/sched/sch_atm.c	Mon Sep  8 16:38:01 2003
@@ -216,6 +216,13 @@
 	tasklet_schedule(&p->task);
 }
 
+static const u8 llc_oui_ip[] = {
+	0xaa,		/* DSAP: non-ISO */
+	0xaa,		/* SSAP: non-ISO */
+	0x03,		/* Ctrl: Unnumbered Information Command PDU */
+	0x00,		/* OUI: EtherType */
+	0x00, 0x00,
+	0x08, 0x00 };	/* Ethertype IP (0800) */
 
 static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
     struct rtattr **tca, unsigned long *arg)
@@ -322,11 +329,10 @@
 	flow->next = p->link.next;
 	p->link.next = flow;
 	flow->hdr_len = hdr_len;
-	if (hdr) memcpy(flow->hdr,hdr,hdr_len);
-	else {
-		memcpy(flow->hdr,llc_oui,sizeof(llc_oui));
-		((u16 *) flow->hdr)[3] = htons(ETH_P_IP);
-	}
+	if (hdr)
+		memcpy(flow->hdr,hdr,hdr_len);
+	else
+		memcpy(flow->hdr,llc_oui_ip,sizeof(llc_oui_ip));
 	*arg = (unsigned long) flow;
 	return 0;
 err_out:
