From: Glenn FEUNTEUN <glenn.feunteun@telecom-bretagne.eu>
Subject: [PATCH 1/1] Bridge mirroring function
Date: Thu, 21 Nov 2013 23:37:55 +0100 (CET)
Message-ID: <44581f24-c5fd-4344-950f-746bb857c384@zmail220>
References: <3968895e-7775-4b2b-8209-db349184e64a@zmail220>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zproxy210.enst-bretagne.fr ([192.108.117.8]:50964 "EHLO
	zproxy210.enst-bretagne.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753927Ab3KUWsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 17:48:13 -0500
In-Reply-To: <3968895e-7775-4b2b-8209-db349184e64a@zmail220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace patch for the bridge mirroring function made against bridge-utils 1.5

diff -urBb old/brctl/brctl_cmd.c new1/brctl/brctl_cmd.c
--- old/brctl/brctl_cmd.c	2013-11-13 10:37:48.635728832 +0100
+++ new1/brctl/brctl_cmd.c	2013-11-13 10:59:58.915775559 +0100
@@ -438,6 +438,56 @@
 	return err != 0;
 }
 
+static int br_cmd_mirror(int argc, char *const* argv)
+{
+ 	int mirror_state = 0, err;
+ 	const char *brname = *++argv;
+ 	const char *ifname = *++argv;
+ 	const char *ifmode = *++argv;
+ 
+ 	if (!strcmp(ifmode, "dst") || !strcmp(ifmode, "destination")
+ 	    || !strcmp(ifmode, "4"))
+ 		mirror_state |= BR_MIRROR_DST ;
+ 
+ 	else if (!strcmp(ifmode, "both") || !strcmp(ifmode, "all")
+ 	    || !strcmp(ifmode, "3"))
+ 		mirror_state |= (BR_MIRROR_RX | BR_MIRROR_TX);
+ 
+ 	else if (!strcmp(ifmode, "tx") || !strcmp(ifmode, "egress")
+ 	    || !strcmp(ifmode, "2"))
+ 		mirror_state |= BR_MIRROR_TX;
+ 
+ 	else if (!strcmp(ifmode, "rx") || !strcmp(ifmode, "ingress")
+ 	    || !strcmp(ifmode, "1"))
+ 		mirror_state |= BR_MIRROR_RX;
+ 
+ 	else if (!strcmp(ifmode, "off") || !strcmp(ifmode, "no")
+ 		 || !strcmp(ifmode, "0"))
+ 		mirror_state &= BR_MIRROR_OFF;
+ 
+ 	else {
+ 		fprintf(stderr, "expect rx/tx/both/off/dst for argument\n");
+ 		return 1;
+ 	}
+ 	if (if_nametoindex(ifname) == 0) {
+ 		fprintf(stderr, "interface %s does not exist!\n",
+ 			ifname);
+ 		return 1;
+ 	} else if (if_nametoindex(brname) == 0) {
+ 		fprintf(stderr, "bridge %s does not exist!\n",
+ 			brname);
+ 		return 1;
+ 	}
+ 
+ 	err = br_set_mirror_state(brname, ifname, mirror_state);
+ 
+ 	if (err) {
+ 		fprintf(stderr, "can't set %s to %s state on bridge %s: %s\n",
+ 			ifname,ifmode,brname, strerror(err));
+ 	}
+	return err != 0;
+}
+
 static const struct command commands[] = {
 	{ 1, "addbr", br_cmd_addbr, "<bridge>\t\tadd bridge" },
 	{ 1, "delbr", br_cmd_delbr, "<bridge>\t\tdelete bridge" },
@@ -469,6 +519,8 @@
 	  "<bridge>\t\tshow bridge stp info"},
 	{ 2, "stp", br_cmd_stp,
 	  "<bridge> {on|off}\tturn stp on/off" },
+	{ 3, "mirror", br_cmd_mirror,
+	  "<bridge> <interface> {rx|tx|both|off|dst}\tset interface mirroring state" },
 };
 
 const struct command *command_lookup(const char *cmd)
diff -urBb old/libbridge/libbridge_devif.c new1/libbridge/libbridge_devif.c
--- old/libbridge/libbridge_devif.c	2013-11-13 10:37:39.767722700 +0100
+++ new1/libbridge/libbridge_devif.c	2013-11-13 11:05:23.431777935 +0100
@@ -272,6 +272,7 @@
 	fetch_tv(path, "forward_delay_timer", &info->forward_delay_timer_value);
 	fetch_tv(path, "hold_timer", &info->hold_timer_value);
 	info->hairpin_mode = fetch_int(path, "hairpin_mode");
+	info->mirror_state = fetch_int(path, "mirror_state");
 
 	closedir(d);
 
@@ -388,6 +389,11 @@
 	return port_set(bridge, port, "hairpin_mode", hairpin_mode, 0);
 }
 
+int br_set_mirror_state(const char *bridge, const char *port, int mirror_state)
+{
+	return port_set(bridge, port, "mirror_state", mirror_state, 0);
+}
+
 static inline void __copy_fdb(struct fdb_entry *ent, 
 			      const struct __fdb_entry *f)
 {
diff -urBb old/libbridge/libbridge.h new1/libbridge/libbridge.h
--- old/libbridge/libbridge.h	2013-11-13 10:51:53.359776785 +0100
+++ new1/libbridge/libbridge.h	2013-11-13 11:09:32.159787057 +0100
@@ -82,8 +82,14 @@
 	struct timeval forward_delay_timer_value;
 	struct timeval hold_timer_value;
 	unsigned char hairpin_mode;
+	unsigned char mirror_state;
 };
 
+#define BR_MIRROR_OFF 0x00
+#define BR_MIRROR_RX 0x01
+#define BR_MIRROR_TX 0x02
+#define BR_MIRROR_DST 0x04
+
 extern int br_init(void);
 extern int br_refresh(void);
 extern void br_shutdown(void);
@@ -117,4 +123,6 @@
 		       unsigned long skip, int num);
 extern int br_set_hairpin_mode(const char *bridge, const char *dev,
 			       int hairpin_mode);
+extern int br_set_mirror_state(const char *brname, const char *dev,
+                               int mirror_state);
 #endif
