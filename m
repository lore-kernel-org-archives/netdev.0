From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: adding tcpdump/OAM support to usb ATM devices
Date: Tue, 29 Apr 2008 08:04:41 -0400
Message-ID: <200804291204.m3TC4f7g012862@cmf.nrl.navy.mil>
References: <1209398082.8768.257.camel@ragnarok>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: Jeremy Jackson <jerj@coplanar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:47627 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbYD2MLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 08:11:11 -0400
In-reply-to: <1209398082.8768.257.camel@ragnarok>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1209398082.8768.257.camel@ragnarok>,Jeremy Jackson writes:
>good to hear!  I'd love to label ATM as legacy and forget it... but
>we're stuck with ATM on ADSL (VDSL has packet mode with HDLC-like
>framing) since no hardware vendor has implemented the packet mode for
>ADSL2/2+ even though it's part of the spec.

simply because of dsl and your local phone company, i suspect atm will
remain around for a few more years yet.  i also belive that verizon's
fios has atm in it somewhere.

>Can you send me some patches?  It would be good for discussion and
>experimentation.

attached is the kernel side of the atm oamd.  the userspace side
is in the linux-atm sourceforge repository.  i had some example
netlink code, but i cant find it.

>I think there are 2 cases, packet socket support for ATM, for
>libpcap/tcpdump etc, and control functions (presently ioctl) switched to
>use netlink.  Generating OAM cells might belong to a control function on
>netlink, but I wonder about PF_RAWATM, the present setup with pcv/svc
>sockets is a bit wierd, you set the qos type to AAL0 to mean raw.
>Perhaps there should be a PF_RAWATM instead.

packet socket support for tcpdump might be troublesome.  in aal5, the
atm headers are added/subtracted by the adapters themselves.  additionally,
there isnt a single queue for all the incoming/outgoing atm traffic
(although this isnt a huge challenge).

the present setup with pvc/svc and a single atm socket family type
somewhat matches the atm socket api.  adding a raw type might make
is easier to figure out which could be sent to tcpdump as 'raw atm'
data.

however, with a properly functioning oamd you should need to tcpdump
the link.  if you use netlink, you should be able to snoop the
oam traffic from userspace, and write your own oam ping type utility.

diff -X /root/diff-no-incluir -uNr ../linux-atm-2.5/src/oamd/atmoamd.c linux-atm-2.4.1/src/oamd/atmoamd.c
--- ../linux-atm-2.5/src/oamd/atmoamd.c	2004-02-21 16:31:40.000000000 +0100
+++ linux-atm-2.4.1/src/oamd/atmoamd.c	2004-02-26 20:24:26.000000000 +0100
@@ -1,3 +1,12 @@
+/* 
+ *	atmoamd.c	OAM daemon
+ *
+ *	Written 2003-2004 by Jorge Boncompte (jorge@dti2.net), DTI2
+ *	
+ *	Code based on the atmarpd daemon by Werner Almerberger
+ *	
+*/
+
 #if HAVE_CONFIG_H
 #include <config.h>
 #endif
@@ -10,6 +19,7 @@
 #include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/time.h>
+#include <sys/wait.h>
 #include <signal.h>
 #include <atm.h>
 
@@ -22,7 +32,7 @@
 static void
 usage(const char *name)
 {
-    fprintf(stderr, "usage: %s [-b] [-d]\n", name);
+    fprintf(stderr, "usage: %s [-b] [-d] [-i [itf.]vpi.vci]\n", name);
     fprintf(stderr, "%6s %s -V\n", "", name);
     exit(1);
 }
@@ -36,17 +46,28 @@
 	signal(SIGALRM, sig_handler);
 	alarm(1);
     }
+    if (signo == SIGCHLD) {
+	signal(SIGCHLD, sig_handler);
+	while (waitpid(-1, NULL, WNOHANG) > 0)
+	{
+	}
+    }
 }
 
 int
 main(int argc, char **argv)
 {
+    struct sockaddr_atmpvc addr;
     int c, background = 0;
 
     set_application("atmoamd");
     set_verbosity(NULL,DIAG_INFO);
 
-    while ((c = getopt(argc,argv,"bdV")) != EOF)
+    addr.sap_addr.itf = 0;
+    addr.sap_addr.vpi = 8;
+    addr.sap_addr.vci = 32;
+    
+    while ((c = getopt(argc,argv,"bdi:V")) != EOF)
 	switch (c) {
 	    case 'b':
 		background = 1;
@@ -55,13 +76,21 @@
 		set_verbosity(NULL,DIAG_DEBUG);
 		debug = 1;
 		break;
+	    case 'i':
+		memset(&addr,0,sizeof(addr));
+		if (text2atm(optarg,(struct sockaddr *) &addr, sizeof(addr),
+    		    T2A_PVC | T2A_UNSPEC | T2A_WILDCARD) < 0) usage(argv[0]);
+		break;
 	    case 'V':
 		printf("%s\n",VERSION);
 		return 0;
 	    default:
 		usage(argv[0]);
 	}
-    if (argc != optind) usage(argv[0]);
+
+    if (argc != optind)
+	usage(argv[0]);
+
     diag(COMPONENT,DIAG_INFO,"Linux ATM OAM, version " VERSION);
 
     open_kernel();
@@ -73,15 +102,18 @@
 	pid = fork();
 	if (pid < 0) diag(COMPONENT,DIAG_FATAL,"fork: %s",strerror(errno));
 	if (pid) {
-	    diag(COMPONENT,DIAG_DEBUG,"Backgrounding (PID %d)",pid);
+	    diag(COMPONENT,DIAG_DEBUG,"Backgrounding (PID %d)", pid);
 	    exit(0);
 	}
     }
 
     signal(SIGALRM, sig_handler);
+    signal(SIGCHLD, sig_handler);
     alarm(1);
 
-    poll_loop();
+    diag(COMPONENT,DIAG_INFO,"Started for Itf %d VPI/VCI %d/%d",
+	    addr.sap_addr.itf, addr.sap_addr.vpi, addr.sap_addr.vci);
+    poll_loop(&addr);
 
     close_kernel();
 
diff -X /root/diff-no-incluir -uNr ../linux-atm-2.5/src/oamd/crc10.c linux-atm-2.4.1/src/oamd/crc10.c
--- ../linux-atm-2.5/src/oamd/crc10.c	2004-02-21 16:31:40.000000000 +0100
+++ linux-atm-2.4.1/src/oamd/crc10.c	2004-02-26 15:14:29.000000000 +0100
@@ -1,3 +1,12 @@
+/* 
+ *	crc10.c	CRC10 calculation routines
+ *
+ *	Written 2003-2004 by Jorge Boncompte (jorge@dti2.net), DTI2
+ *	
+ *	The CRC10 table and sum routine are from the f4loopbackd.c source
+ *	from Alex Zeffertt.
+*/
+
 #include <atm.h>
 
 #include "crc10.h"
diff -X /root/diff-no-incluir -uNr ../linux-atm-2.5/src/oamd/crc10.h linux-atm-2.4.1/src/oamd/crc10.h
--- ../linux-atm-2.5/src/oamd/crc10.h	2004-02-21 16:31:40.000000000 +0100
+++ linux-atm-2.4.1/src/oamd/crc10.h	2004-02-26 15:13:52.000000000 +0100
@@ -1,9 +1,10 @@
 /* 
  *	crc10.h	CRC10
  *
- *	Written 2003 by Jorge Boncompte, DTI2
+ *	Written 2003-2004 by Jorge Boncompte (jorge@dti2.net), DTI2
  *	
  *	The CRC10 table and sum routine are from the f4loopbackd.c source
+ *	from Alex Zeffertt.
 */
 
 #ifndef CRC10_H
diff -X /root/diff-no-incluir -uNr ../linux-atm-2.5/src/oamd/io.c linux-atm-2.4.1/src/oamd/io.c
--- ../linux-atm-2.5/src/oamd/io.c	2004-02-21 16:31:40.000000000 +0100
+++ linux-atm-2.4.1/src/oamd/io.c	2004-02-26 20:30:50.000000000 +0100
@@ -1,6 +1,11 @@
-/* io.c - I/O operations */
-
-/* Written 1995-2000 by Werner Almesberger, EPFL-LRC/ICA */
+/* 
+ *	io.c	I/O operations
+ *
+ *	Written 2003-2004 by Jorge Boncompte (jorge@dti2.net), DTI2
+ *	
+ *	Code based on the atmarpd daemon by Werner Almesberger
+ *	
+*/
 
 #if HAVE_CONFIG_H
 #include <config.h>
@@ -72,9 +77,10 @@
 	}
 
 	diag(COMPONENT, DIAG_DEBUG,
-	     "OAM %s Cell received on Intf %d VPI/VCI %d/%d (Vcc %p)",
+	     "OAM %s(%d) Cell received on Intf %d VPI/VCI %d/%d (Vcc %p)",
 	     ctrl.pti == 5 ? "F5-E2E" : (ctrl.pti == 4 ? "F5-SEG" : "UNK"),
-	     ctrl.number, ctrl.vpi, ctrl.vci, *(struct atm_vcc **) &ctrl.vcc);
+	     ctrl.pti, ctrl.itf, ctrl.vpi, ctrl.vci,
+	     *(struct atm_vcc **) &ctrl.vcc);
 
 	oam_process(&ctrl);
 }
@@ -86,7 +92,7 @@
 }
 
 void
-poll_loop(void)
+poll_loop(struct sockaddr_atmpvc *addr)
 {
 	struct pollfd pollfds;
 
@@ -94,10 +100,10 @@
 	pollfds.events = POLLIN;	/* Que eventos queremos, solo entradas */
 
 	for (;;) {
-		oam_state_print();
+//		oam_state_print();
 
 		if (run_fsm) {
-			oam_fsm();
+			oam_fsm(addr);
 			run_fsm = 0;
 		}
 
diff -X /root/diff-no-incluir -uNr ../linux-atm-2.5/src/oamd/io.h linux-atm-2.4.1/src/oamd/io.h
--- ../linux-atm-2.5/src/oamd/io.h	2004-02-21 16:31:40.000000000 +0100
+++ linux-atm-2.4.1/src/oamd/io.h	2004-02-26 20:31:01.000000000 +0100
@@ -1,7 +1,11 @@
-/* io.h - I/O operations */
- 
-/* Written 1995-1999 by Werner Almesberger, EPFL-LRC/ICA */
- 
+/* 
+ *	io.h	I/O operations
+ *
+ *	Written 2003-2004 by Jorge Boncompte (jorge@dti2.net), DTI2
+ *	
+ *	Code based on the atmarpd daemon by Werner Almesberger
+ *	
+*/
 
 #ifndef IO_H
 #define IO_H
@@ -10,11 +14,11 @@
 #include <sys/socket.h> /* for struct sockaddr */
 #include <atm.h> /* for struct sockaddr_atmsvc */
 #include <atmd.h>
-#include <linux/atmoam.h>
+#include <atmoam.h>
 
 void open_kernel(void);
 void recv_kernel(void);
 int send_kernel(struct atmoam_ctrl *);
 void close_kernel(void);
-void poll_loop(void);
+void poll_loop(struct sockaddr_atmpvc *);
 #endif
Los ficheros binarios ../linux-atm-2.5/src/oamd/.libs/atmoamd y linux-atm-2.4.1/src/oamd/.libs/atmoamd son distintos
diff -X /root/diff-no-incluir -uNr ../linux-atm-2.5/src/oamd/Makefile.am linux-atm-2.4.1/src/oamd/Makefile.am
--- ../linux-atm-2.5/src/oamd/Makefile.am	2004-02-21 16:31:40.000000000 +0100
+++ linux-atm-2.4.1/src/oamd/Makefile.am	2003-12-17 15:52:26.000000000 +0100
@@ -1,6 +1,6 @@
 sbin_PROGRAMS = atmoamd
 
+LDADD = $(top_builddir)/src/lib/libatm.la
+
 atmoamd_SOURCES = atmoamd.c io.c io.h oam.c oam.h crc10.c crc10.h
 
-atmoamd_LDADD = $(top_builddir)/src/lib/libatm.la
-atmoamd_DEPENDENCIES = $(zeppelin_LDADD)
diff -X /root/diff-no-incluir -uNr ../linux-atm-2.5/src/oamd/oam.c linux-atm-2.4.1/src/oamd/oam.c
--- ../linux-atm-2.5/src/oamd/oam.c	2004-02-21 16:31:40.000000000 +0100
+++ linux-atm-2.4.1/src/oamd/oam.c	2004-02-26 20:23:55.000000000 +0100
@@ -1,9 +1,17 @@
+/* 
+ *	oam.c - OAM cell processing
+ *
+ *	Written 2003-2004 by Jorge Boncompte (jorge@dti2.net), DTI2
+ *
+*/
+
 #include <stdio.h>
 #include <stdlib.h>
 #include <sys/types.h>
 #include <errno.h>
 #include <atm.h>
-#include <linux/atmoam.h>
+#include <atmoam.h>
+#include <syslog.h>
 
 #include "oam.h"
 #include "io.h"
@@ -18,21 +26,39 @@
 void
 handle_circuit_state(int state)
 {
+    char itf[8], vpi[8], vci[8], itftype[16];
+
+    snprintf(itf, sizeof(itf), "%u", vcc.ctrl.itf);
+    snprintf(vpi, sizeof(vpi), "%u", vcc.ctrl.vpi);
+    snprintf(vci, sizeof(vci), "%u", vcc.ctrl.vci);
+    snprintf(itftype, sizeof(itftype), "ATM");
+
     vcc.state = state;
     diag(COMPONENT, DIAG_DEBUG, "VCC STATE CHANGE: %s",
 	vcc.state ? "DOWN" : "UP");
+
     if (vcc.state == VCC_UP) {
-	system("backuprdsi stop&");
+	syslog(LOG_DAEMON|LOG_NOTICE, "ATM VCC %d.%d.%d STATE CHANGED TO UP\n",
+		vcc.ctrl.itf, vcc.ctrl.vpi, vcc.ctrl.vci);
+	if (!fork()) {
+	    execlp(ATM_UP_SCRIPT, ATM_UP_SCRIPT, itf, vpi, vci, itftype, 0);
+	    syslog(LOG_DAEMON|LOG_NOTICE, "EXEC failed\n");
+	    exit(1);
+	}
     } else if (vcc.state == VCC_DOWN) {
-	system("backuprdsi start&");
+	syslog(LOG_DAEMON|LOG_NOTICE, "ATM VCC %d.%d.%d STATE CHANGED TO DOWN\n",
+		vcc.ctrl.itf, vcc.ctrl.vpi, vcc.ctrl.vci);
+	if (!fork()) {
+	    execlp(ATM_DOWN_SCRIPT, ATM_DOWN_SCRIPT, itf, vpi, vci, itftype, 0);
+	    syslog(LOG_DAEMON|LOG_NOTICE, "EXEC failed\n");
+	    exit(1);
+	}
     }
 }
 
 void
 oam_state_print(void)
 {
-	return;
-
 	printf
 	    ("-------------------------------------------------------------------\n");
 	printf("T: %d UP: %d DOWN: %d STATE: %d VCCSTATE %d CTag: %lx\n", timer,
@@ -80,7 +106,7 @@
 oam_send(struct atmoam_ctrl *ctrl)
 {
     int error;
-    
+
     error = send_kernel(ctrl);
     if (error > 0) {
 	fsm.state = OAM_SENT;
@@ -160,14 +186,14 @@
 		     oampayload->LoopBackInd ==
 		     1 ? "Loopback" : "Loopback reply", ctag);
 
-		if (pdu[1] == 1) {	/* Celda de Loopback */
+		if (pdu[1] == 1) {	/* Loopback cell */
 			vcc.stats.F5.InEndLoop++;
-			pdu[1] = 0;	/* Clear Loopback but */
+			pdu[1] = 0;	/* Clear Loopback bit */
 
 			/* Recalculate CRC10 */
 			crc10(pdu);
 
-			/* Volvemos a enviar la celda */
+			/* Sent the cell */
 			return 1;
 		}
 		if (pdu[1] == 0) {	/* Loopback reply */
@@ -186,11 +212,12 @@
 						return 0;
 					}
 				}
-				/* Desde aqui deberiamos ir a ESPERAR a 10 */
+				/* WAIT 10 seconds */
 				OAM_WAIT_10_S;
 				return 0;
 			} else {
-				printf("Wrong Correlation Tag\n");
+				syslog(LOG_DAEMON|LOG_ERR,
+					"Wrong Correlation Tag\n");
 				vcc.stats.CTagErrors++;
 				OAM_INC_DOWNRETRY;
 				if (fsm.downretry >= OAM_DOWNRETRY) {
@@ -205,7 +232,7 @@
 						return 0;
 					}
 				}
-				/* Desde aqui deberiamos ir a ESPERAR a 10 */
+				/* WAIT 10 seconds */
 				OAM_WAIT_10_S;
 				return 0;
 			}
@@ -221,7 +248,9 @@
 
 	if (crc10_check(ctrl->cell.payload) != 0) {
 		diag(COMPONENT, DIAG_ERROR,
-		     "Received OAM cell, failed CRC-10 check");
+		     "Received OAM cell failed CRC-10 check");
+		syslog(LOG_DAEMON|LOG_ERR,
+			"Received OAM cell failed CRC-10 check\n");
 		vcc.stats.CrcErrors++;
 		OAM_INC_DOWNRETRY;
 		if (fsm.downretry >= OAM_DOWNRETRY) {
@@ -252,14 +281,14 @@
 }
 
 void
-oam_fsm(void)
+oam_fsm(struct sockaddr_atmpvc *addr)
 {
 	switch (fsm.state) {
 	case OAM_INIT:
 		timer = 0;
-		vcc.ctrl.number = 0;
-		vcc.ctrl.vpi = 8;
-		vcc.ctrl.vci = 32;
+		vcc.ctrl.itf = addr->sap_addr.itf;
+		vcc.ctrl.vpi = addr->sap_addr.vpi;
+		vcc.ctrl.vci = addr->sap_addr.vci;
 		vcc.ctrl.pti = 5;
 		vcc.CTag = oam_build_lb_cell(&vcc.ctrl);
 		oam_send(&vcc.ctrl);
@@ -276,7 +305,7 @@
 				return;
 			}
 		}
-		/* Desde aqui deberiamos ir a ESPERAR a 10 */
+		/* WAIT 10 seconds */
 		OAM_WAIT_10_S;
 		break;
 	case OAM_WAIT10:
diff -X /root/diff-no-incluir -uNr ../linux-atm-2.5/src/oamd/oam.h linux-atm-2.4.1/src/oamd/oam.h
--- ../linux-atm-2.5/src/oamd/oam.h	2004-02-21 16:31:40.000000000 +0100
+++ linux-atm-2.4.1/src/oamd/oam.h	2004-02-26 15:54:58.000000000 +0100
@@ -1,7 +1,7 @@
 /* 
  *	oam.h - OAM cell processing
  *
- *	Written 2003 by Jorge Boncompte, DTI2
+ *	Written 2003-2004 by Jorge Boncompte (jorge@dti2.net), DTI2
  *
 */
 
@@ -24,6 +24,9 @@
 #define OAM_INC_DOWNRETRY	fsm.downretry++; fsm.upretry=0
 #define OAM_WAIT_10_S		timer = 0; fsm.state = OAM_WAIT10
 
+#define ATM_UP_SCRIPT "/etc/atm/atm-up"
+#define ATM_DOWN_SCRIPT "/etc/atm/atm-down"
+
 struct oamfsm {
 	int state;
 	short upretry;
@@ -43,17 +46,17 @@
 	    struct {
 		unsigned long InEndLoop;
 		unsigned long InSegLoop;
-//		unsigned long InAIS;
-//		unsigned long InRDI;
+		unsigned long InAIS;
+		unsigned long InRDI;
 		unsigned long OutEndLoop;
 		unsigned long OutSegLoop;
-//	        unsigned long OutRDI;
+	        unsigned long OutRDI;
 	    } F5;
 	} stats;
 };
 
 void oam_process(struct atmoam_ctrl *ctrl);
-void oam_fsm(void);
+void oam_fsm(struct sockaddr_atmpvc *);
 void oam_state_print(void);
 
 #endif
