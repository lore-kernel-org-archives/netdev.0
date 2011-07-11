From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: CAN: major update for the Controller Area Network LTP tests
Date: Mon, 11 Jul 2011 19:32:27 +0200
Message-ID: <4E1B33AB.7020301@hartkopp.net>
References: <20090512094631.26592.81609.sendpatchset@subratamodak.linux.ibm.com> <4E19987B.2030507@hartkopp.net> <20110711161513.GB31575@saboteur.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Subrata Modak <subrata@linux.vnet.ibm.com>,
	ltp-list <ltp-list@lists.sf.net>,
	socketcan-users@lists.berlios.de,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: Cyril Hrubis <chrubis@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:53147 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758257Ab1GKRcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 13:32:32 -0400
In-Reply-To: <20110711161513.GB31575@saboteur.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CAN: major update for the Controller Area Network LTP tests

This update for the LTP tests are dealing with CAN filters and the
CAN frame flow down to the CAN netdevice and vice versa.

The patch removes all the obsolete stuff from the source code directory
that has been originally used to pick the tests from. The two new tools
also reside in the SocketCAN SVN svn://svn.berlios.de/socketcan/trunk/test

tst-filter: New filter test tool in *one* programm (easy to use & handle)
tst-rcv-own-msgs: Checks the CAN frame flow inside the networking stack

Additionally the virtual CAN driver needs to be loaded with a special
commandline option to perform the CAN frame flow test correctly.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

---

diff --git a/testcases/network/can/filter-tests/Makefile b/testcases/network/can/filter-tests/Makefile
index 192c3b0..c88f704 100644
--- a/testcases/network/can/filter-tests/Makefile
+++ b/testcases/network/can/filter-tests/Makefile
@@ -1,43 +1,6 @@
 #
 #  $Id: Makefile,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
 #
-#  Copyright (c) 2002-2007 Volkswagen Group Electronic Research
-#  All rights reserved.
-#
-#  Redistribution and use in source and binary forms, with or without
-#  modification, are permitted provided that the following conditions
-#  are met:
-#  1. Redistributions of source code must retain the above copyright
-#     notice, this list of conditions, the following disclaimer and
-#     the referenced file 'COPYING'.
-#  2. Redistributions in binary form must reproduce the above copyright
-#     notice, this list of conditions and the following disclaimer in the
-#     documentation and/or other materials provided with the distribution.
-#  3. Neither the name of Volkswagen nor the names of its contributors
-#     may be used to endorse or promote products derived from this software
-#     without specific prior written permission.
-#
-#  Alternatively, provided that this notice is retained in full, this
-#  software may be distributed under the terms of the GNU General
-#  Public License ("GPL") version 2 as distributed in the 'COPYING'
-#  file from the main directory of the linux kernel source.
-#
-#  The provided data structures and external interfaces from this code
-#  are not restricted to be used by modules with a GPL compatible license.
-#
-#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
-#  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
-#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
-#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
-#  DAMAGE.
-#
 #  Send feedback to <socketcan-users@lists.berlios.de>
 
 CFLAGS    = -O2 -Wall -Wno-parentheses \
@@ -46,25 +9,7 @@ CFLAGS    = -O2 -Wall -Wno-parentheses \
 	-DPF_CAN=29 \
 	-DAF_CAN=PF_CAN
 
-PROGRAMS =      tst-raw           \
-                tst-raw-filter    \
-                tst-err           \
-                tst-raw-sendto    \
-                tst-packet        \
-                tst-filter-master \
-                tst-filter-server \
-                tst-bcm-cycle     \
-                tst-bcm-server    \
-                tst-bcm-tx_read   \
-                tst-bcm-rtr       \
-                tst-bcm-single    \
-                tst-bcm-filter    \
-                tst-bcm-throttle  \
-                tst-bcm-rx-sendto \
-                tst-bcm-tx-sendto \
-                tst-bcm-dump      \
-                tst-proc          \
-                canecho
+PROGRAMS =      tst-filter tst-rcv-own-msgs
 
 all: $(PROGRAMS)
 
@@ -72,8 +17,8 @@ install:
 	cp -f $(PROGRAMS) /usr/local/bin
 
 clean:
-	rm -f $(PROGRAMS) output_ltp-can.txt output_ltp-can-verify.txt /etc/modprobe.d/vcan
+	rm -f $(PROGRAMS)
 
 distclean:
-	rm -f $(PROGRAMS) *~ output_ltp-can.txt output_ltp-can-verify.txt /etc/modprobe.d/vcan
+	rm -f $(PROGRAMS) *~
 
diff --git a/testcases/network/can/filter-tests/canecho.c b/testcases/network/can/filter-tests/canecho.c
deleted file mode 100644
index e87f063..0000000
--- a/testcases/network/can/filter-tests/canecho.c
+++ /dev/null
@@ -1,163 +0,0 @@
-/*
- *  $Id: canecho.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * canecho.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-#include <signal.h>
-#include <libgen.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-
-extern int optind, opterr, optopt;
-
-static int      s = -1;
-static int      running = 1;
-
-void print_usage(char *prg)
-{
-        fprintf(stderr, "Usage: %s [can-interface]\n", prg);
-}
-
-void sigterm(int signo)
-{
-        printf("got signal %d\n", signo);
-        running = 0;
-}
-
-int main(int argc, char **argv)
-{
-        int family = PF_CAN, type = SOCK_RAW, proto = CAN_RAW;
-        int opt;
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-        struct can_frame frame;
-        int nbytes, i;
-        int verbose = 0;
-
-        signal(SIGTERM, sigterm);
-        signal(SIGHUP, sigterm);
-
-        while ((opt = getopt(argc, argv, "f:t:p:v")) != -1) {
-                switch (opt) {
-                case 'f':
-                        family = atoi(optarg);
-                        break;
-
-                case 't':
-                        type = atoi(optarg);
-                        break;
-
-                case 'p':
-                        proto = atoi(optarg);
-                        break;
-
-                case 'v':
-                        verbose = 1;
-                        break;
-
-                case '?':
-                        break;
-
-                default:
-                        fprintf(stderr, "Unknown option %c\n", opt);
-                        break;
-                }
-        }
-
-        if (optind == argc) {
-                print_usage(basename(argv[0]));
-                exit(0);
-        }
-
-        printf("interface = %s, family = %d, type = %d, proto = %d\n",
-               argv[optind], family, type, proto);
-        if ((s = socket(family, type, proto)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        addr.can_family = family;
-        strcpy(ifr.ifr_name, argv[optind]);
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("bind");
-                return 1;
-        }
-
-        while (running) {
-                if ((nbytes = read(s, &frame, sizeof(frame))) < 0) {
-                        perror("read");
-                        return 1;
-                }
-                if (verbose) {
-                        printf("%03X: ", frame.can_id & CAN_EFF_MASK);
-                        if (frame.can_id & CAN_RTR_FLAG) {
-                                printf("remote request");
-                        } else {
-                                printf("[%d]", frame.can_dlc);
-                                for (i = 0; i < frame.can_dlc; i++) {
-                                        printf(" %02X", frame.data[i]);
-                                }
-                        }
-                        printf("\n");
-                }
-                frame.can_id++;
-                write(s, &frame, sizeof(frame));
-        }
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/run_ltp-can_tests.sh b/testcases/network/can/filter-tests/run_ltp-can_tests.sh
index 6d7aafc..8070c9a 100644
--- a/testcases/network/can/filter-tests/run_ltp-can_tests.sh
+++ b/testcases/network/can/filter-tests/run_ltp-can_tests.sh
@@ -1,6 +1,6 @@
 #!/bin/sh
 ################################################################################
-## Copyright (c) Oliver Hartkopp <oliver.hartkopp@volkswagen.de>, 2009        ##
+## Copyright (c) Oliver Hartkopp <oliver.hartkopp@volkswagen.de>, 2011        ##
 ## Copyright (c) International Business Machines  Corp., 2009                 ##
 ##                                                                            ##
 ## This program is free software;  you can redistribute it and#or modify      ##
@@ -24,25 +24,34 @@ if [ $(id -ru) -ne 0 ]; then
      exit 1
 fi
 
-cat <<-EOF > /etc/modprobe.d/vcan
-# protocol family PF_CAN
-alias net-pf-29 can
-# protocols in PF_CAN
-alias can-proto-1 can-raw
-alias can-proto-2 can-bcm
-alias can-proto-3 can-tp16
-alias can-proto-4 can-tp20
-alias can-proto-5 can-mcnet
-alias can-proto-6 can-isotp
-EOF
-
+# load needed CAN networklayer modules
 modprobe -f can
 modprobe -f can_raw
-modprobe -f vcan
-ip link add dev vcan0 type vcan
-ifconfig vcan0 up
 
-./tst-filter-server > output_ltp-can.txt &
-./tst-filter-master | tee output_ltp-can-verify.txt
+# ensure the vcan driver to perform the ECHO on driver level
+modprobe -r vcan
+modprobe -f vcan echo=1
+
+VCAN=vcan0
+
+# create virtual CAN device
+ip link add dev $VCAN type vcan || exit 1
+ifconfig $VCAN up
+
+# check precondition for CAN frame flow test
+HAS_ECHO=`ip link show $VCAN | grep -c ECHO`
+
+if [ $HAS_ECHO -ne 1 ]
+then
+    exit 1
+fi
+
+# test of CAN filters on af_can.c 
+./tst-filter $VCAN || exit 1
+
+# test of CAN frame flow down to the netdevice and up again
+./tst-rcv-own-msgs $VCAN || exit 1
+
+exit 0
 
 
diff --git a/testcases/network/can/filter-tests/tst-bcm-cycle.c b/testcases/network/can/filter-tests/tst-bcm-cycle.c
deleted file mode 100644
index 7f4c8ac..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-cycle.c
+++ /dev/null
@@ -1,137 +0,0 @@
-/*
- *  $Id: tst-bcm-cycle.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-cycle.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-#define U64_DATA(p) (*(unsigned long long*)(p)->data)
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame[4];
-        } msg;
-
-        if ((s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        addr.can_family = PF_CAN;
-        strcpy(ifr.ifr_name, "vcan2");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-        msg.msg_head.opcode  = TX_SETUP;
-        msg.msg_head.can_id  = 0x42;
-        msg.msg_head.flags   = SETTIMER|STARTTIMER;
-        msg.msg_head.nframes = 1;
-        msg.msg_head.count = 10;
-        msg.msg_head.ival1.tv_sec = 1;
-        msg.msg_head.ival1.tv_usec = 0;
-        msg.msg_head.ival2.tv_sec = 0;
-        msg.msg_head.ival2.tv_usec = 0;
-        msg.frame[0].can_id    = 0x42;
-        msg.frame[0].can_dlc   = 8;
-        U64_DATA(&msg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        if (write(s, &msg, sizeof(msg)) < 0)
-                perror("write");
-
-        printf("Press any key to stop the cycle ...\n");
-
-        getchar();
-
-        msg.msg_head.opcode  = TX_SETUP;
-        msg.msg_head.can_id  = 0x42;
-        msg.msg_head.flags   = SETTIMER|STARTTIMER;
-        msg.msg_head.nframes = 1;
-        msg.msg_head.count = 0;
-        msg.msg_head.ival1.tv_sec = 0;
-        msg.msg_head.ival1.tv_usec = 0;
-        msg.msg_head.ival2.tv_sec = 0;
-        msg.msg_head.ival2.tv_usec = 0;
-        msg.frame[0].can_id    = 0x42;
-        msg.frame[0].can_dlc   = 8;
-        U64_DATA(&msg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        if (write(s, &msg, sizeof(msg)) < 0)
-                perror("write");
-
-        printf("Press any key to close the socket ...\n");
-
-        getchar();
-
-        close(s);
-
-        printf("Press any key to end the program ...\n");
-
-        getchar();
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-bcm-dump.c b/testcases/network/can/filter-tests/tst-bcm-dump.c
deleted file mode 100644
index 5004d3a..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-dump.c
+++ /dev/null
@@ -1,200 +0,0 @@
-/*
- *  $Id: tst-bcm-dump.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-dump.c
- *
- * Copyright (c) 2008 Oliver Hartkopp
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the version 2 of the GNU General Public License
- * as published by the Free Software Foundation
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-#include <time.h>
-#include <libgen.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/time.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-#define DEFAULT_IFACE "vcan0"
-#define DEFAULT_CANID 0x42
-
-void print_usage(char *prg)
-{
-        fprintf(stderr, "\nUsage: %s [options]\n", prg);
-        fprintf(stderr, "Options: -i <interface> (CAN interface. Default: '%s')\n", DEFAULT_IFACE);
-        fprintf(stderr, "         -c <can_id>    (used CAN ID. Default: 0x%03X)\n", DEFAULT_CANID);
-        fprintf(stderr, "         -o <timeout>   (Timeout value in nsecs. Default: 0)\n");
-        fprintf(stderr, "         -t <throttle>  (Throttle value in nsecs. Default: 0)\n");
-        fprintf(stderr, "         -q <msgs>      (Quit after receiption of #msgs)\n");
-        fprintf(stderr, "         -s             (set STARTTIMER flag. Default: off)\n");
-        fprintf(stderr, "\n");
-}
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct sockaddr_can addr;
-        int nbytes;
-        int i;
-        struct ifreq ifr;
-        char *ifname = DEFAULT_IFACE;
-        canid_t canid = DEFAULT_CANID;
-        int opt;
-        struct timeval tv;
-        unsigned long starttimer = 0;
-        unsigned long long timeout = 0;
-        unsigned long long throttle = 0;
-        unsigned long msgs = 0;
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame;
-        } msg;
-
-        while ((opt = getopt(argc, argv, "i:c:o:t:q:s")) != -1) {
-                switch (opt) {
-
-                case 'i':
-                        ifname = optarg;
-                        break;
-
-                case 'c':
-                        canid = strtoul(optarg, (char **)NULL, 16);
-                        break;
-
-                case 'o':
-                        timeout = strtoull(optarg, (char **)NULL, 10);
-                        break;
-
-                case 't':
-                        throttle = strtoull(optarg, (char **)NULL, 10);
-                        break;
-
-                case 'q':
-                        msgs = strtoul(optarg, (char **)NULL, 10);
-                        break;
-
-                case 's':
-                        starttimer = STARTTIMER;
-                        break;
-
-                case '?':
-                default:
-                        print_usage(basename(argv[0]));
-                        exit(1);
-                        break;
-                }
-        }
-
-        if ((s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        if (strcmp(ifname, "any") == 0)
-                addr.can_ifindex = 0;
-        else {
-                strcpy(ifr.ifr_name, ifname);
-                if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
-                        perror("SIOCGIFINDEX");
-                        return 1;
-                }
-                addr.can_ifindex = ifr.ifr_ifindex;
-        }
-
-        addr.can_family = PF_CAN;
-
-        if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-        msg.msg_head.opcode             = RX_SETUP;
-        msg.msg_head.can_id             = canid;
-        msg.msg_head.flags              = SETTIMER|RX_FILTER_ID|starttimer;
-        msg.msg_head.ival1.tv_sec       = timeout / 1000000;
-        msg.msg_head.ival1.tv_usec      = timeout % 1000000;
-        msg.msg_head.ival2.tv_sec       = throttle / 1000000;
-        msg.msg_head.ival2.tv_usec      = throttle % 1000000;
-        msg.msg_head.nframes    = 0;
-
-        gettimeofday(&tv, NULL);
-        printf("[%ld.%06ld] ", tv.tv_sec, tv.tv_usec);
-        printf("Writing RX_SETUP with RX_FILTER_ID for can_id <%03X>\n",
-               msg.msg_head.can_id);
-
-        if (write(s, &msg, sizeof(msg)) < 0)
-                perror("write");
-
-        while (1) {
-
-                nbytes = read(s, &msg, sizeof(msg));
-                if (nbytes < 0) {
-                        perror("read");
-                        return 1;
-                }
-                gettimeofday(&tv, NULL);
-                printf("[%ld.%06ld] ", tv.tv_sec, tv.tv_usec);
-
-                if (nbytes == sizeof(msg)) {
-
-                        if (ioctl(s, SIOCGSTAMP, &tv) < 0)
-                                perror("SIOCGSTAMP");
-                        else
-                                printf("(%ld.%06ld) ", tv.tv_sec, tv.tv_usec);
-
-                        if (msg.msg_head.opcode != RX_CHANGED) {
-                                printf("missing RX_CHANGED.\n");
-                                return 1;
-                        }
-
-                        printf("RX_CHANGED ");
-
-                        for (i=0; i < msg.frame.can_dlc; i++)
-                                printf("%02X ", msg.frame.data[i]);
-
-                } else {
-
-                        if (msg.msg_head.opcode != RX_TIMEOUT) {
-                                printf("missing RX_TIMEOUT.\n");
-                                return 1;
-                        }
-
-                        printf("RX_TIMEOUT");
-                }
-
-                printf("\n");
-                fflush(stdout);
-
-                if (msgs && !(--msgs))
-                        break;
-        }
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-bcm-filter.c b/testcases/network/can/filter-tests/tst-bcm-filter.c
deleted file mode 100644
index 873e871..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-filter.c
+++ /dev/null
@@ -1,515 +0,0 @@
-/*
- *  $Id: tst-bcm-filter.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-filter.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-#define U64_DATA(p) (*(unsigned long long*)(p)->data)
-
-int main(int argc, char **argv)
-{
-        int s,nbytes;
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-
-        struct timeval tv;
-
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame[4];
-        } txmsg, rxmsg;
-
-        if ((s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        addr.can_family = PF_CAN;
-        strcpy(ifr.ifr_name, "vcan2");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x042;
-        txmsg.msg_head.flags   = SETTIMER|RX_FILTER_ID;
-        txmsg.msg_head.ival1.tv_sec = 1;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 0;
-        txmsg.msg_head.ival2.tv_usec = 0;
-        txmsg.msg_head.nframes = 0;
-
-        printf("<*>Writing RX_SETUP with RX_FILTER_ID for can_id <%03X>\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        /* test for RX_DELETE */
-        txmsg.msg_head.opcode  = RX_DELETE;
-        txmsg.msg_head.can_id  = 0x042; /* everything we need for RX_DELETE */
-
-        printf("<*>Writing RX_DELETE for can_id <%03X>\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x042;
-        txmsg.msg_head.flags   = SETTIMER|RX_FILTER_ID;
-        txmsg.msg_head.ival1.tv_sec = 1;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 0;
-        txmsg.msg_head.ival2.tv_usec = 0;
-        txmsg.msg_head.nframes = 0;
-
-        printf("<*>Writing RX_SETUP with RX_FILTER_ID for can_id <%03X>\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        /* obsolete for TX_SEND ... */
-#if 0
-        txmsg.msg_head.can_id  = 0x43;
-        txmsg.msg_head.flags   = SETTIMER|STARTTIMER|TX_CP_CAN_ID;
-        txmsg.msg_head.count = 0;
-        txmsg.msg_head.ival1.tv_sec = 0;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 0;
-        txmsg.msg_head.ival2.tv_usec = 0;
-#endif
-        txmsg.frame[0].can_id    = 0x43;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<2>Writing TX_SEND with wrong can_id <%03X>\n",
-               txmsg.frame[0].can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<3>Writing TX_SEND with correct can_id <%03X>\n",
-               txmsg.frame[0].can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        ioctl(s, SIOCGSTAMP, &tv);
-        printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<3>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        /* growing number of nframes => RX_DELETE instead of simple update */
-        txmsg.msg_head.opcode  = RX_DELETE;
-        txmsg.msg_head.can_id  = 0x042; /* everything we need for RX_DELETE */
-
-        printf("<*>Writing RX_DELETE for can_id <%03X>\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x042;
-        txmsg.msg_head.flags   = SETTIMER|RX_CHECK_DLC;
-        txmsg.msg_head.ival1.tv_sec = 1;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 0;
-        txmsg.msg_head.ival2.tv_usec = 0;
-        txmsg.msg_head.nframes = 1;
-        /* txmsg.frame[0].can_dlc   = 8; obsolete for RX_SETUP */
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xFF00000000000000ULL;
-
-        printf("<*>Writing simple RX_SETUP for can_id <%03X> with msgbits 0x%016llX\n",
-               txmsg.msg_head.can_id, U64_DATA(&txmsg.frame[0]));
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<5>Writing TX_SEND with correct can_id <%03X>\n",
-               txmsg.frame[0].can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        ioctl(s, SIOCGSTAMP, &tv);
-        printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<5>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<6>Writing TX_SEND with correct can_id <%03X> ",
-               txmsg.frame[0].can_id);
-        printf("no changed data\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        /* no change here */
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<7>Writing TX_SEND with correct can_id <%03X> ",
-               txmsg.frame[0].can_id);
-        printf("changed relevant msgbits\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        ioctl(s, SIOCGSTAMP, &tv);
-        printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<7>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<8>Writing TX_SEND with correct can_id <%03X> ",
-               txmsg.frame[0].can_id);
-        printf("changed irrelevant msgbits\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 7;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<9>Writing TX_SEND with correct can_id <%03X> ",
-               txmsg.frame[0].can_id);
-        printf("changed Data Length Code DLC\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        ioctl(s, SIOCGSTAMP, &tv);
-        printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<9>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = RX_DELETE;
-        txmsg.msg_head.can_id  = 0x042; /* everything we need for RX_DELETE */
-
-        printf("<*>Writing RX_DELETE for can_id <%03X> for RX_SETUP with growing nframes\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        /* no problems ;-) but NOW we try MUX messages ... and timeouts */
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x042;
-        txmsg.msg_head.flags   = SETTIMER|RX_CHECK_DLC;
-        txmsg.msg_head.ival1.tv_sec = 1;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.nframes = 3;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xFF00000000000000ULL;
-        U64_DATA(&txmsg.frame[1]) = (__u64) 0x01000000000000FFULL;
-        U64_DATA(&txmsg.frame[2]) = (__u64) 0x02000000000000FFULL;
-
-        printf("<*>Writing multiplex RX_SETUP for can_id <%03X>\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x4200000000000000ULL;
-
-        printf("<A>Writing TX_SEND with wrong MUX ID 42\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0100000000000000ULL;
-
-        printf("<B>Writing TX_SEND with correct MUX ID 01\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        ioctl(s, SIOCGSTAMP, &tv);
-        printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<B>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0100000000000000ULL;
-
-        printf("<C>Writing TX_SEND with correct MUX ID 01 but no data change\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0100001234567800ULL;
-
-        printf("<D>Writing TX_SEND with correct MUX ID 01 but no relevant data change\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0100001234567801ULL;
-
-        printf("<E>Writing TX_SEND with correct MUX ID 01 with relevant data change\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        ioctl(s, SIOCGSTAMP, &tv);
-        printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<E>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0200000000000000ULL;
-
-        printf("<F>Writing TX_SEND with correct MUX ID 02\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        ioctl(s, SIOCGSTAMP, &tv);
-        printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<F>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0200000000000001ULL;
-
-        printf("<10>Writing TX_SEND with correct MUX ID 02 with relevant data change\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        ioctl(s, SIOCGSTAMP, &tv);
-        printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<10>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 7;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0200000000000001ULL;
-
-        printf("<11>Writing TX_SEND with correct MUX ID 02 no data change but DLC\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<11>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 7;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0300000000000001ULL;
-
-        printf("<12>Writing TX_SEND with wrong MUX ID 03\n");
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        ioctl(s, SIOCGSTAMP, &tv);
-        printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-        if (rxmsg.msg_head.opcode == RX_TIMEOUT &&
-            nbytes == sizeof(struct bcm_msg_head) &&
-            rxmsg.msg_head.can_id == 0x42) {
-                printf("<-->Received correct RX_TIMEOUT message for can_id <%03X> >> OK!\n",
-                       rxmsg.msg_head.can_id);
-        }
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-bcm-rtr.c b/testcases/network/can/filter-tests/tst-bcm-rtr.c
deleted file mode 100644
index 955864d..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-rtr.c
+++ /dev/null
@@ -1,145 +0,0 @@
-/*
- *  $Id: tst-bcm-rtr.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-rtr.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-#define RTR_SETUP
-
-int main(int argc, char **argv)
-{
-        int s,nbytes;
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-
-        struct timeval tv;
-
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame;
-        } txmsg, rxmsg;
-
-        if ((s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        addr.can_family = PF_CAN;
-        strcpy(ifr.ifr_name, "vcan2");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-#ifdef RTR_SETUP
-        /* specify CAN-Frame to send as reply to a RTR-request */
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x359 | CAN_RTR_FLAG;
-        txmsg.msg_head.flags   = RX_RTR_FRAME; /* | TX_CP_CAN_ID */;
-        txmsg.msg_head.ival1.tv_sec = 0; /* no timers in RTR-mode */
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 0;
-        txmsg.msg_head.ival2.tv_usec = 0;
-        txmsg.msg_head.nframes = 1; /* exact 1 */
-
-        /* the frame to send as reply ... */
-        txmsg.frame.can_id = 0x359; /* 'should' be the same */
-        txmsg.frame.can_dlc = 3;
-        txmsg.frame.data[0] = 0x12;
-        txmsg.frame.data[1] = 0x34;
-        txmsg.frame.data[2] = 0x56;
-
-#else
-        /* normal receiption of RTR-frames in Userspace */
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x359 | CAN_RTR_FLAG;
-        txmsg.msg_head.flags   = RX_FILTER_ID;
-        txmsg.msg_head.ival1.tv_sec = 0;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 0;
-        txmsg.msg_head.ival2.tv_usec = 0;
-        txmsg.msg_head.nframes = 0;
-#endif
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        while (1) {
-
-                if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                        perror("read");
-
-                ioctl(s, SIOCGSTAMP, &tv);
-                printf("(%ld.%06ld)   ", tv.tv_sec, tv.tv_usec);
-
-                if (rxmsg.msg_head.opcode == RX_CHANGED &&
-                    nbytes == sizeof(struct bcm_msg_head) + sizeof(struct can_frame) &&
-                    (rxmsg.msg_head.can_id & CAN_SFF_MASK) == 0x359 &&
-                    (rxmsg.frame.can_id & CAN_SFF_MASK) == 0x359) {
-                        printf("RX_CHANGED message for can_id <%03X> RTR = %d\n",
-                               rxmsg.frame.can_id, (rxmsg.frame.can_id & CAN_RTR_FLAG)?1:0);
-                }
-        }
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-bcm-rx-sendto.c b/testcases/network/can/filter-tests/tst-bcm-rx-sendto.c
deleted file mode 100644
index 7d3dcaf..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-rx-sendto.c
+++ /dev/null
@@ -1,162 +0,0 @@
-/*
- *  $Id: tst-bcm-rx-sendto.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-rx-sendto.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-int main(int argc, char **argv)
-{
-        int s,nbytes;
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-
-        struct timeval tv;
-
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame;
-        } txmsg, rxmsg;
-
-        if ((s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        addr.can_family = PF_CAN;
-        addr.can_ifindex = 0; /* bind to 'any' device */
-
-        if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-        memset(&txmsg, 0, sizeof(txmsg)); /* clear timers, nframes, etc. */
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x123;
-        txmsg.msg_head.flags   = RX_FILTER_ID;
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        addr.can_family = PF_CAN;
-        strcpy(ifr.ifr_name, "vcan2");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x321;
-        txmsg.msg_head.flags   = RX_FILTER_ID;
-
-        if (sendto(s, &txmsg, sizeof(txmsg), 0, (struct sockaddr*)&addr, sizeof(addr)) < 0)
-                perror("sendto");
-
-        addr.can_family = PF_CAN;
-        strcpy(ifr.ifr_name, "vcan1");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x424;
-        txmsg.msg_head.flags   = RX_FILTER_ID;
-
-        if (sendto(s, &txmsg, sizeof(txmsg), 0, (struct sockaddr*)&addr, sizeof(addr)) < 0)
-                perror("sendto");
-
-        while (1) {
-                socklen_t len = sizeof(addr);
-                nbytes = recvfrom(s, &rxmsg, sizeof(rxmsg),
-                                  0, (struct sockaddr*)&addr, &len);
-                if (nbytes < 0) {
-                        perror("recvfrom");
-                        return 1;
-                } else if (nbytes < sizeof(rxmsg)) {
-                        fprintf(stderr, "recvfrom: incomplete BCM message from iface %d\n",
-                                addr.can_ifindex);
-                        return 1;
-                } else {
-                        int i;
-
-                        ioctl(s, SIOCGSTAMP, &tv);
-                        printf("(%ld.%06ld) ", tv.tv_sec, tv.tv_usec);
-
-                        ifr.ifr_ifindex = addr.can_ifindex;
-                        ioctl(s, SIOCGIFNAME, &ifr);
-
-                        printf(" %-5s ", ifr.ifr_name);
-                        if (rxmsg.frame.can_id & CAN_EFF_FLAG)
-                                printf("%8X  ", rxmsg.frame.can_id & CAN_EFF_MASK);
-                        else
-                                printf("%3X  ", rxmsg.frame.can_id & CAN_SFF_MASK);
-
-                        printf("[%d] ", rxmsg.frame.can_dlc);
-
-                        for (i = 0; i < rxmsg.frame.can_dlc; i++) {
-                                printf("%02X ", rxmsg.frame.data[i]);
-                        }
-                        if (rxmsg.frame.can_id & CAN_RTR_FLAG)
-                                printf("remote request");
-                        printf("\n");
-                        fflush(stdout);
-                }
-        }
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-bcm-server.c b/testcases/network/can/filter-tests/tst-bcm-server.c
deleted file mode 100644
index c057780..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-server.c
+++ /dev/null
@@ -1,263 +0,0 @@
-/*
- *  $Id: tst-bcm-server.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-server.c
- *
- * Test programm that implements a socket server which understands ASCII
- * messages for simple broadcast manager frame send commands.
- *
- * < interface command ival_s ival_us can_id can_dlc [data]* >
- *
- * The commands are 'A'dd, 'U'pdate, 'D'elete and 'S'end.
- * e.g.
- *
- * Send the CAN frame 123#1122334455667788 every second on vcan1
- * < vcan1 A 1 0 123 8 11 22 33 44 55 66 77 88 >
- *
- * Send the CAN frame 123#1122334455667788 every 10 usecs on vcan1
- * < vcan1 A 0 10 123 8 11 22 33 44 55 66 77 88 >
- *
- * Send the CAN frame 123#42424242 every 20 msecs on vcan1
- * < vcan1 A 0 20000 123 4 42 42 42 42 >
- *
- * Update the CAN frame 123#42424242 with 123#112233 - no change of timers
- * < vcan1 U 0 0 123 3 11 22 33 >
- *
- * Delete the cyclic send job from above
- * < vcan1 D 0 0 123 0 >
- *
- * Send a single CAN frame without cyclic transmission
- * < can0 S 0 0 123 0 >
- *
- * When the socket is closed the cyclic transmissions are terminated.
- *
- * Authors:
- * Andre Naujoks (the socket server stuff)
- * Oliver Hartkopp (the rest)
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-#include <errno.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-#include <netinet/in.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-void readmsg(int sock, char *buf, int maxlen) {
-
-        int ptr = 0;
-
-        while (read(sock, buf+ptr, 1) == 1) {
-
-                if (ptr) {
-                        if (*(buf+ptr) == '>') {
-                                *(buf+ptr+1) = 0;
-                                return;
-                        }
-                        if (++ptr > maxlen-2)
-                                ptr = 0;
-                }
-                else
-                        if (*(buf+ptr) == '<')
-                                ptr++;
-        }
-
-        *buf = 0;
-}
-
-int main(int argc, char **argv)
-{
-
-        int sl, sa, sc;
-        struct sockaddr_in  saddr, clientaddr;
-        struct sockaddr_can caddr;
-        struct ifreq ifr;
-        socklen_t sin_size = sizeof(clientaddr);
-
-        char buf[100];
-
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame;
-        } msg;
-
-        if ((sl = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
-                perror("inetsocket");
-                exit(1);
-        }
-
-        saddr.sin_family = AF_INET;
-        saddr.sin_addr.s_addr = htonl(INADDR_ANY);
-        saddr.sin_port = htons(28600);
-
-        while (bind(sl,(struct sockaddr*)&saddr, sizeof(saddr)) < 0) {
-                printf(".");fflush(NULL);
-                usleep(100000);
-        }
-
-        if (listen(sl,3) != 0) {
-                perror("listen");
-                exit(1);
-        }
-
-        while (1) {
-                sa = accept(sl,(struct sockaddr *)&clientaddr, &sin_size);
-                if (sa > 0) {
-
-                        if (fork())
-                                close(sa);
-                        else
-                                break;
-                }
-                else {
-                        if (errno != EINTR) {
-                                /*
-                                 * If the cause for the error was NOT the signal from
-                                 * a dying child, than give an error
-                                 */
-                                perror("accept");
-                                exit(1);
-                        }
-                }
-        }
-
-        /* open BCM socket */
-
-        if ((sc = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("bcmsocket");
-                return 1;
-        }
-
-        caddr.can_family = PF_CAN;
-        caddr.can_ifindex = 0; /* any device => need for sendto() */
-
-        if (connect(sc, (struct sockaddr *)&caddr, sizeof(caddr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-        /* prepare stable settings */
-        msg.msg_head.nframes       = 1;
-        msg.msg_head.count         = 0;
-        msg.msg_head.ival1.tv_sec  = 0;
-        msg.msg_head.ival1.tv_usec = 0;
-
-        while (1) {
-
-                char cmd;
-                int items;
-
-                readmsg(sa, buf, sizeof(buf));
-
-                // printf("read '%s'\n", buf);
-
-                items = sscanf(buf, "< %6s %c %lu %lu %x %hhu "
-                               "%hhx %hhx %hhx %hhx %hhx %hhx %hhx %hhx >",
-                               ifr.ifr_name,
-                               &cmd,
-                               &msg.msg_head.ival2.tv_sec,
-                               &msg.msg_head.ival2.tv_usec,
-                               &msg.msg_head.can_id,
-                               &msg.frame.can_dlc,
-                               &msg.frame.data[0],
-                               &msg.frame.data[1],
-                               &msg.frame.data[2],
-                               &msg.frame.data[3],
-                               &msg.frame.data[4],
-                               &msg.frame.data[5],
-                               &msg.frame.data[6],
-                               &msg.frame.data[7]);
-
-                if (items < 6)
-                        break;
-                if (msg.frame.can_dlc > 8)
-                        break;
-                if (items != 6 + msg.frame.can_dlc)
-                        break;
-
-                msg.frame.can_id = msg.msg_head.can_id;
-
-                switch (cmd) {
-                case 'S':
-                        msg.msg_head.opcode = TX_SEND;
-                        break;
-                case 'A':
-                        msg.msg_head.opcode = TX_SETUP;
-                        msg.msg_head.flags |= SETTIMER|STARTTIMER;
-                        break;
-                case 'U':
-                        msg.msg_head.opcode = TX_SETUP;
-                        msg.msg_head.flags  = 0;
-                        break;
-                case 'D':
-                        msg.msg_head.opcode = TX_DELETE;
-                        break;
-
-                default:
-                        printf("unknown command '%c'.\n", cmd);
-                        exit(1);
-                }
-
-                if (!ioctl(sc, SIOCGIFINDEX, &ifr)) {
-                        caddr.can_ifindex = ifr.ifr_ifindex;
-                        sendto(sc, &msg, sizeof(msg), 0,
-                               (struct sockaddr*)&caddr, sizeof(caddr));
-                }
-
-        }
-
-        close(sc);
-        close(sa);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-bcm-single.c b/testcases/network/can/filter-tests/tst-bcm-single.c
deleted file mode 100644
index 829343c..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-single.c
+++ /dev/null
@@ -1,110 +0,0 @@
-/*
- *  $Id: tst-bcm-single.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-single.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame;
-        } msg;
-
-        if ((s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        addr.can_family = PF_CAN;
-        strcpy(ifr.ifr_name, "vcan2");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-        msg.msg_head.opcode  = TX_SEND;
-        msg.msg_head.can_id  = 0x760;
-        msg.msg_head.flags   = 0;
-        msg.msg_head.nframes = 1;
-        msg.msg_head.count = 0;
-        msg.msg_head.ival1.tv_sec = 0;
-        msg.msg_head.ival1.tv_usec = 0;
-        msg.msg_head.ival2.tv_sec = 0;
-        msg.msg_head.ival2.tv_usec = 0;
-        msg.frame.can_id    = 0x760;
-        msg.frame.can_dlc   = 6;
-        msg.frame.data[0] = 0xA1;
-        msg.frame.data[1] = 0x0F;
-        msg.frame.data[2] = 0x10;
-        msg.frame.data[3] = 0x00;
-        msg.frame.data[4] = 0x00;
-        msg.frame.data[5] = 0x00;
-
-        if (write(s, &msg, sizeof(msg)) < 0)
-                perror("write");
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-bcm-throttle.c b/testcases/network/can/filter-tests/tst-bcm-throttle.c
deleted file mode 100644
index 8585ade..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-throttle.c
+++ /dev/null
@@ -1,464 +0,0 @@
-/*
- *  $Id: tst-bcm-throttle.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-throttle.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-#define U64_DATA(p) (*(unsigned long long*)(p)->data)
-#define BCM_1FRAME_LEN (sizeof(struct bcm_msg_head) + sizeof(struct can_frame))
-int main(int argc, char **argv)
-{
-        int s,nbytes;
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame[3];
-        } txmsg, rxmsg;
-
-        if ((s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        addr.can_family = PF_CAN;
-        strcpy(ifr.ifr_name, "vcan2");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x042;
-        txmsg.msg_head.flags   = SETTIMER|RX_FILTER_ID;
-        txmsg.msg_head.ival1.tv_sec = 4;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 2;
-        txmsg.msg_head.ival2.tv_usec = 0;
-        txmsg.msg_head.nframes = 0;
-
-        printf("<*>Writing RX_SETUP with RX_FILTER_ID for can_id <%03X>\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(struct bcm_msg_head)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        /* obsolete for TX_SEND ... */
-#if 0
-        txmsg.msg_head.can_id  = 0x43;
-        txmsg.msg_head.flags   = SETTIMER|STARTTIMER|TX_CP_CAN_ID;
-        txmsg.msg_head.count = 0;
-        txmsg.msg_head.ival1.tv_sec = 0;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 0;
-        txmsg.msg_head.ival2.tv_usec = 0;
-#endif
-        txmsg.frame[0].can_id    = 0x43;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<2>Writing TX_SEND with wrong can_id <%03X>\n",
-               txmsg.frame[0].can_id);
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<3>Writing TX_SEND with correct can_id <%03X>\n",
-               txmsg.frame[0].can_id);
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == BCM_1FRAME_LEN &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<3>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        /* growing number of nframes => RX_DELETE instead of simple update */
-        txmsg.msg_head.opcode  = RX_DELETE;
-        txmsg.msg_head.can_id  = 0x042; /* everything we need for RX_DELETE */
-
-        printf("<*>Writing RX_DELETE for can_id <%03X>\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(struct bcm_msg_head)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x042;
-        txmsg.msg_head.flags   = SETTIMER|RX_CHECK_DLC;
-        txmsg.msg_head.ival1.tv_sec = 4;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 2;
-        txmsg.msg_head.ival2.tv_usec = 0;
-        txmsg.msg_head.nframes = 1;
-        /* txmsg.frame[0].can_dlc   = 8; obsolete for RX_SETUP */
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xFF00000000000000ULL;
-
-        printf("<*>Writing simple RX_SETUP for can_id <%03X> with msgbits 0x%016llX\n",
-               txmsg.msg_head.can_id, U64_DATA(&txmsg.frame[0]));
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<5>Writing TX_SEND with correct can_id <%03X>\n",
-               txmsg.frame[0].can_id);
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == BCM_1FRAME_LEN &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<5>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<6>Writing TX_SEND with correct can_id <%03X> ",
-               txmsg.frame[0].can_id);
-        printf("no changed data\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        /* no change here */
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<7>Writing TX_SEND with correct can_id <%03X> ",
-               txmsg.frame[0].can_id);
-        printf("changed relevant msgbits\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == BCM_1FRAME_LEN &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<7>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<8>Writing TX_SEND with correct can_id <%03X> ",
-               txmsg.frame[0].can_id);
-        printf("changed irrelevant msgbits\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 7;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        printf("<9>Writing TX_SEND with correct can_id <%03X> ",
-               txmsg.frame[0].can_id);
-        printf("changed Data Length Code DLC\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == BCM_1FRAME_LEN &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<9>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        /* no problems ;-) but NOW we try MUX messages ... and timeouts */
-
-        /* growing number of nframes => RX_DELETE instead of simple update */
-        txmsg.msg_head.opcode  = RX_DELETE;
-        txmsg.msg_head.can_id  = 0x042; /* everything we need for RX_DELETE */
-
-        printf("<*>Writing RX_DELETE for can_id <%03X>\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(struct bcm_msg_head)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = RX_SETUP;
-        txmsg.msg_head.can_id  = 0x042;
-        txmsg.msg_head.flags   = SETTIMER|RX_CHECK_DLC;
-        txmsg.msg_head.ival1.tv_sec = 4;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 2;
-        txmsg.msg_head.ival2.tv_usec = 0;
-        txmsg.msg_head.nframes = 3;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0xFF00000000000000ULL;
-        U64_DATA(&txmsg.frame[1]) = (__u64) 0x01000000000000FFULL;
-        U64_DATA(&txmsg.frame[2]) = (__u64) 0x02000000000000FFULL;
-
-        printf("<*>Writing multiplex RX_SETUP for can_id <%03X>\n",
-               txmsg.msg_head.can_id);
-
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x4200000000000000ULL;
-
-        printf("<A>Writing TX_SEND with wrong MUX ID 42\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0100000000000000ULL;
-
-        printf("<B>Writing TX_SEND with correct MUX ID 01\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == BCM_1FRAME_LEN &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<B>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0100000000000000ULL;
-
-        printf("<C>Writing TX_SEND with correct MUX ID 01 but no data change\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0100001234567800ULL;
-
-        printf("<D>Writing TX_SEND with correct MUX ID 01 but no relevant data change\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0100001234567801ULL;
-
-        printf("<E>Writing TX_SEND with correct MUX ID 01 with relevant data change\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == BCM_1FRAME_LEN &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<E>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0200000000000000ULL;
-
-        printf("<F>Writing TX_SEND with correct MUX ID 02\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == BCM_1FRAME_LEN &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<F>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 8;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0200000000000001ULL;
-
-        printf("<10>Writing TX_SEND with correct MUX ID 02 with relevant data change\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == BCM_1FRAME_LEN &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<10>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 7;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0200000000000001ULL;
-
-        printf("<11>Writing TX_SEND with correct MUX ID 02 no data change but DLC\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_CHANGED &&
-            nbytes == BCM_1FRAME_LEN &&
-            rxmsg.msg_head.can_id == 0x42 && rxmsg.frame[0].can_id == 0x42) {
-                printf("<11>Received correct RX_CHANGED message for can_id <%03X> >> OK!\n",
-                       rxmsg.frame[0].can_id);
-        }
-
-        txmsg.msg_head.opcode  = TX_SEND;
-        txmsg.msg_head.nframes = 1;
-        txmsg.frame[0].can_id    = 0x42;
-        txmsg.frame[0].can_dlc   = 7;
-        U64_DATA(&txmsg.frame[0]) = (__u64) 0x0300000000000001ULL;
-
-        printf("<12>Writing TX_SEND with wrong MUX ID 03\n");
-
-        if (write(s, &txmsg, BCM_1FRAME_LEN) < 0)
-                perror("write");
-
-        if ((nbytes = read(s, &rxmsg, sizeof(rxmsg))) < 0)
-                perror("read");
-
-        if (rxmsg.msg_head.opcode == RX_TIMEOUT &&
-            nbytes == sizeof(struct bcm_msg_head) &&
-            rxmsg.msg_head.can_id == 0x42) {
-                printf("<-->Received correct RX_TIMEOUT message for can_id <%03X> >> OK!\n",
-                       rxmsg.msg_head.can_id);
-        }
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-bcm-tx-sendto.c b/testcases/network/can/filter-tests/tst-bcm-tx-sendto.c
deleted file mode 100644
index bb2dbef..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-tx-sendto.c
+++ /dev/null
@@ -1,122 +0,0 @@
-/*
- *  $Id: tst-bcm-tx-sendto.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-tx-sendto.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-#define U64_DATA(p) (*(unsigned long long*)(p)->data)
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame;
-        } txmsg;
-
-        if ((s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        addr.can_family = PF_CAN;
-        addr.can_ifindex = 0; /* bind to 'any' device */
-
-        if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-        txmsg.msg_head.opcode  = TX_SETUP;
-        txmsg.msg_head.can_id  = 0x42;
-        txmsg.msg_head.flags   = SETTIMER|STARTTIMER;
-        txmsg.msg_head.nframes = 1;
-        txmsg.msg_head.count = 10;
-        txmsg.msg_head.ival1.tv_sec = 1;
-        txmsg.msg_head.ival1.tv_usec = 0;
-        txmsg.msg_head.ival2.tv_sec = 0;
-        txmsg.msg_head.ival2.tv_usec = 0;
-        txmsg.frame.can_id    = 0x42;
-        txmsg.frame.can_dlc   = 8;
-        U64_DATA(&txmsg.frame) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        /* should cause an error due to ifindex = 0 */
-        if (write(s, &txmsg, sizeof(txmsg)) < 0)
-                perror("write");
-
-        printf("Press any key to send on valid device ...\n");
-        getchar();
-
-        addr.can_family = PF_CAN;
-        strcpy(ifr.ifr_name, "vcan2");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        if (sendto(s, &txmsg, sizeof(txmsg), 0, (struct sockaddr*)&addr, sizeof(addr)) < 0)
-                perror("sendto");
-
-        printf("Press any key to close the socket ...\n");
-        getchar();
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-bcm-tx_read.c b/testcases/network/can/filter-tests/tst-bcm-tx_read.c
deleted file mode 100644
index 39e9400..0000000
--- a/testcases/network/can/filter-tests/tst-bcm-tx_read.c
+++ /dev/null
@@ -1,158 +0,0 @@
-/*
- *  $Id: tst-bcm-tx_read.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-bcm-tx_read.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/bcm.h>
-
-#define U64_DATA(p) (*(unsigned long long*)(p)->data)
-
-int main(int argc, char **argv)
-{
-        int s,i,nbytes;
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-
-        struct {
-                struct bcm_msg_head msg_head;
-                struct can_frame frame[4];
-        } msg;
-
-        if ((s = socket(PF_CAN, SOCK_DGRAM, CAN_BCM)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        addr.can_family = PF_CAN;
-        strcpy(ifr.ifr_name, "vcan2");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        addr.can_ifindex = ifr.ifr_ifindex;
-
-        if (connect(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("connect");
-                return 1;
-        }
-
-        msg.msg_head.opcode  = TX_SETUP;
-        msg.msg_head.can_id  = 0x42;
-        msg.msg_head.flags   = SETTIMER|STARTTIMER|TX_CP_CAN_ID|TX_COUNTEVT;
-        msg.msg_head.nframes = 1;
-        msg.msg_head.count = 2;
-        msg.msg_head.ival1.tv_sec = 3;
-        msg.msg_head.ival1.tv_usec = 0;
-        msg.msg_head.ival2.tv_sec = 5;
-        msg.msg_head.ival2.tv_usec = 0;
-        msg.frame[0].can_id    = 0xAA;
-        msg.frame[0].can_dlc   = 8;
-        U64_DATA(&msg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        if (write(s, &msg, sizeof(msg)) < 0)
-                perror("write");
-
-        printf("Press any key to stop the cycle ...\n");
-
-        getchar();
-
-        msg.msg_head.opcode  = TX_SETUP;
-        msg.msg_head.can_id  = 0x42;
-        msg.msg_head.flags   = SETTIMER|STARTTIMER|TX_CP_CAN_ID;
-        msg.msg_head.nframes = 1;
-        msg.msg_head.count = 0;
-        msg.msg_head.ival1.tv_sec = 0;
-        msg.msg_head.ival1.tv_usec = 0;
-        msg.msg_head.ival2.tv_sec = 0;
-        msg.msg_head.ival2.tv_usec = 0;
-        msg.frame[0].can_id    = 0xAA;
-        msg.frame[0].can_dlc   = 8;
-        U64_DATA(&msg.frame[0]) = (__u64) 0xdeadbeefdeadbeefULL;
-
-        if (write(s, &msg, sizeof(msg)) < 0)
-                perror("write");
-
-        printf("Press any key to read the entry ...\n");
-
-        getchar();
-
-        msg.msg_head.opcode  = TX_READ;
-        msg.msg_head.can_id  = 0x42;
-        msg.msg_head.nframes = 0;
-
-        if (write(s, &msg, sizeof(msg)) < 0)
-                perror("write");
-
-        printf("Press any key to read from the socket ...\n");
-
-        getchar();
-
-        if ((nbytes = read(s, &msg, sizeof(msg))) < 0)
-                perror("read");
-        for (i = 0; i < nbytes; i++)
-                printf(" %02x", ((unsigned char*)&msg)[i]);
-        putchar('\n');
-
-        printf("Press any key to close the socket ...\n");
-
-        getchar();
-
-        close(s);
-
-        printf("Press any key to end the program ...\n");
-
-        getchar();
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-err.c b/testcases/network/can/filter-tests/tst-err.c
deleted file mode 100644
index 86d0ad1..0000000
--- a/testcases/network/can/filter-tests/tst-err.c
+++ /dev/null
@@ -1,166 +0,0 @@
-/*
- *  $Id: tst-err.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-err.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/raw.h>
-#include <linux/can/error.h>
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct sockaddr_can addr;
-        struct can_filter rfilter;
-        struct can_frame frame;
-        can_err_mask_t err_mask = CAN_ERR_MASK; /* all */
-        int nbytes;
-        struct ifreq ifr;
-        char *ifname = "vcan2";
-        int ifindex;
-        int opt;
-        struct timeval tv;
-
-        while ((opt = getopt(argc, argv, "i:m:")) != -1) {
-                switch (opt) {
-                case 'i':
-                        ifname = optarg;
-                        break;
-                case 'm':
-                        err_mask = strtoul(optarg, (char **)NULL, 16);
-                        break;
-                default:
-                        fprintf(stderr, "Unknown option %c\n", opt);
-                        break;
-                }
-        }
-
-        if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        rfilter.can_id   = CAN_INV_FILTER; /* no normal CAN frames */
-        rfilter.can_mask = 0; /* all: INV(all) == nothing */
-        setsockopt(s, SOL_CAN_RAW, CAN_RAW_FILTER, &rfilter, sizeof(rfilter));
-
-        setsockopt(s, SOL_CAN_RAW, CAN_RAW_ERR_FILTER, &err_mask, sizeof(err_mask));
-
-        strcpy(ifr.ifr_name, ifname);
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        ifindex = ifr.ifr_ifindex;
-
-        addr.can_family = AF_CAN;
-        addr.can_ifindex = ifindex;
-
-        if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("bind");
-                return 1;
-        }
-
-        while (1) {
-
-                if ((nbytes = read(s, &frame, sizeof(struct can_frame))) < 0) {
-                        perror("read");
-                        return 1;
-                } else if (nbytes < sizeof(struct can_frame)) {
-                        fprintf(stderr, "read: incomplete CAN frame\n");
-                        return 1;
-                } else {
-                        if (ioctl(s, SIOCGSTAMP, &tv) < 0)
-                                perror("SIOCGSTAMP");
-                        else
-                                printf("(%ld.%06ld) ", tv.tv_sec, tv.tv_usec);
-
-                        if (frame.can_id & CAN_ERR_BUSOFF)
-                                printf("(bus off) ");
-
-                        if (frame.can_id & CAN_ERR_TX_TIMEOUT)
-                                printf("(tx timeout) ");
-
-                        if (frame.can_id & CAN_ERR_ACK)
-                                printf("(ack) ");
-
-                        if (frame.can_id & CAN_ERR_LOSTARB) {
-                                printf("(lost arb)");
-                                if (frame.data[0])
-                                        printf("[%d]", frame.data[0]);
-                                printf(" ");
-                        }
-
-                        if (frame.can_id & CAN_ERR_CRTL) {
-                                printf("(crtl)");
-                                if (frame.data[1] & CAN_ERR_CRTL_RX_OVERFLOW)
-                                        printf("[RX buffer overflow]");
-                                if (frame.data[1] & CAN_ERR_CRTL_TX_OVERFLOW)
-                                        printf("[TX buffer overflow]");
-                                if (frame.data[1] & CAN_ERR_CRTL_RX_WARNING)
-                                        printf("[RX warning]");
-                                if (frame.data[1] & CAN_ERR_CRTL_TX_WARNING)
-                                        printf("[TX warning]");
-                                printf(" ");
-                        }
-
-                        /* to be continued */
-
-                        printf("\n");
-                        fflush(stdout);
-                }
-        }
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-filter-master.c b/testcases/network/can/filter-tests/tst-filter-master.c
deleted file mode 100644
index 42d6e53..0000000
--- a/testcases/network/can/filter-tests/tst-filter-master.c
+++ /dev/null
@@ -1,165 +0,0 @@
-/*
- *  $Id: tst-filter-master.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-filter-master.c
- *
- * Copyright (c) 2008 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/raw.h>
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct sockaddr_can addr;
-        struct can_filter rfilter;
-        struct can_frame frame;
-        int testcase;
-        int nbytes;
-        struct ifreq ifr;
-        int ifindex;
-
-        if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        strcpy(ifr.ifr_name, "vcan0");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        ifindex = ifr.ifr_ifindex;
-
-        addr.can_family = AF_CAN;
-        addr.can_ifindex = ifindex;
-
-        rfilter.can_id   = 0xFA; /* receive only the filter ack */
-        rfilter.can_mask = CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG;
-        setsockopt(s, SOL_CAN_RAW, CAN_RAW_FILTER, &rfilter, sizeof(rfilter));
-
-        if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("bind");
-                return 1;
-        }
-
-        /* send testcases 0 .. 17 and a terminating 18 to quit */
-        for (testcase = 0; testcase < 19; testcase++) {
-
-                printf("Sending testcase %2d ... ", testcase);
-                frame.can_id = 0x0F;
-                frame.can_dlc = 1;
-                frame.data[0] = testcase;
-
-                if (write(s, &frame, sizeof(frame)) < 0) {
-                        perror("write");
-                        exit(1);
-                }
-
-                /* wait for ACK from server */
-                if ((nbytes = read(s, &frame, sizeof(struct can_frame))) < 0) {
-                        perror("read");
-                        exit(1);
-                }
-
-                if (nbytes < sizeof(struct can_frame)) {
-                        fprintf(stderr, "read: incomplete CAN frame\n");
-                        exit(1);
-                }
-
-                if ((frame.can_id != 0xFA) || (frame.can_dlc != 1) ||
-                    (frame.data[0] != testcase)) {
-                        fprintf(stderr, "\nWrong answer from server!\n");
-                        exit(1);
-                }
-
-                printf("acked. ");
-                if (testcase > 17)
-                        break;
-
-                /* interactive mode, when there is any commandline option */
-                if (argc == 2) {
-                        printf("[press enter] ");
-                        getchar();
-                }
-
-                printf("Sending patterns ... ");
-
-                frame.can_dlc = 0;
-
-                frame.can_id = 0x123;
-                if (write(s, &frame, sizeof(frame)) < 0) {
-                        perror("write");
-                        exit(1);
-                }
-                frame.can_id = (0x123 | CAN_RTR_FLAG);
-                if (write(s, &frame, sizeof(frame)) < 0) {
-                        perror("write");
-                        exit(1);
-                }
-                frame.can_id = (0x123 | CAN_EFF_FLAG);
-                if (write(s, &frame, sizeof(frame)) < 0) {
-                        perror("write");
-                        exit(1);
-                }
-                frame.can_id = (0x123 | CAN_EFF_FLAG | CAN_RTR_FLAG);
-                if (write(s, &frame, sizeof(frame)) < 0) {
-                        perror("write");
-                        exit(1);
-                }
-
-                printf("ok\n");
-        }
-
-        printf("Filtertest done.\n");
-
-        close(s);
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-filter-server.c b/testcases/network/can/filter-tests/tst-filter-server.c
deleted file mode 100644
index 46903a5..0000000
--- a/testcases/network/can/filter-tests/tst-filter-server.c
+++ /dev/null
@@ -1,210 +0,0 @@
-/*
- *  $Id: tst-filter-server.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-filter-server.c
- *
- * Copyright (c) 2008 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/raw.h>
-
-#define ID  0x123
-#define FIL 0x7FF
-#define EFF CAN_EFF_FLAG
-#define RTR CAN_RTR_FLAG
-
-canid_t calc_id(int testcase)
-{
-        canid_t id = ID;
-
-        if (testcase & 1)
-                id |= EFF;
-        if (testcase & 2)
-                id |= RTR;
-
-        return id;
-}
-
-canid_t calc_mask(int testcase)
-{
-        canid_t mask = FIL;
-
-        if (testcase > 15)
-                return (CAN_EFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG);
-
-        if (testcase & 4)
-                mask |= EFF;
-        if (testcase & 8)
-                mask |= RTR;
-
-        return mask;
-}
-
-int main(int argc, char **argv)
-{
-        fd_set rdfs;
-        int s, t;
-        struct sockaddr_can addr;
-        struct can_filter rfilter;
-        struct can_frame frame;
-        int testcase = 0;
-        int nbytes, ret;
-        struct ifreq ifr;
-        int ifindex;
-
-        if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
-                perror("socket");
-                return 1;
-        }
-        if ((t = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        strcpy(ifr.ifr_name, "vcan0");
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        ifindex = ifr.ifr_ifindex;
-
-        addr.can_family = AF_CAN;
-        addr.can_ifindex = ifindex;
-
-        if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("bind");
-                return 1;
-        }
-        if (bind(t, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("bind");
-                return 1;
-        }
-
-        rfilter.can_id   = 0xF; /* receive only the filter requests */
-        rfilter.can_mask = CAN_SFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG;
-        setsockopt(s, SOL_CAN_RAW, CAN_RAW_FILTER, &rfilter, sizeof(rfilter));
-
-        /* disable default receive filter on the test socket */
-        setsockopt(t, SOL_CAN_RAW, CAN_RAW_FILTER, NULL, 0);
-
-        while (1) {
-
-                FD_ZERO(&rdfs);
-                FD_SET(s, &rdfs);
-                FD_SET(t, &rdfs);
-
-                if ((ret = select(t+1, &rdfs, NULL, NULL, NULL)) < 0) {
-                        perror("select");
-                        break;
-                }
-
-                if (FD_ISSET(s, &rdfs)) {
-
-                        if ((nbytes = read(s, &frame, sizeof(struct can_frame))) < 0) {
-                                perror("read");
-                                exit(1);
-                        }
-
-                        if (nbytes < sizeof(struct can_frame)) {
-                                fprintf(stderr, "read: incomplete CAN frame\n");
-                                exit(1);
-                        }
-
-                        if ((frame.can_id != 0xF) || (frame.can_dlc != 1)) {
-                                fprintf(stderr, "\nWrong request from master!\n");
-                                exit(1);
-                        }
-
-                        testcase = frame.data[0];
-
-                        if (testcase < 18) {
-                                rfilter.can_id   = calc_id(testcase);
-                                rfilter.can_mask = calc_mask(testcase);
-                                setsockopt(t, SOL_CAN_RAW, CAN_RAW_FILTER,
-                                           &rfilter, sizeof(rfilter));
-
-                                printf("testcase %2d : can_id = 0x%08X can_mask = 0x%08X\n",
-                                       testcase, rfilter.can_id, rfilter.can_mask);
-                        }
-
-                        frame.can_id = 0xFA; /* filter ack */
-
-                        if (write(s, &frame, sizeof(frame)) < 0) {
-                                perror("write");
-                                exit(1);
-                        }
-
-                        if (testcase > 17)
-                                break;
-                }
-
-                if (FD_ISSET(t, &rdfs)) {
-
-                        if ((nbytes = read(t, &frame, sizeof(struct can_frame))) < 0) {
-                                perror("read");
-                                exit(1);
-                        }
-
-                        if (nbytes < sizeof(struct can_frame)) {
-                                fprintf(stderr, "read: incomplete CAN frame\n");
-                                exit(1);
-                        }
-
-                        printf ("%08X\n", frame.can_id);
-                }
-        }
-
-        printf("testcase %2d : Filtertest done.\n", testcase);
-
-        close(s);
-        close(t);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-filter.c b/testcases/network/can/filter-tests/tst-filter.c
new file mode 100644
index 0000000..a2d46f1
--- /dev/null
+++ b/testcases/network/can/filter-tests/tst-filter.c
@@ -0,0 +1,244 @@
+/*
+ *  $Id: tst-filter.c 1263 2011-07-09 18:00:41Z hartkopp $
+ */
+
+/*
+ * tst-filter.c
+ *
+ * Copyright (c) 2011 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the name of Volkswagen nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2, in which case the provisions of the
+ * GPL apply INSTEAD OF those given above.
+ *
+ * The provided data structures and external interfaces from this code
+ * are not restricted to be used by modules with a GPL compatible license.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
+ * DAMAGE.
+ *
+ * Send feedback to <socketcan-users@lists.berlios.de>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <sys/ioctl.h>
+#include <sys/time.h>
+#include <net/if.h>
+
+#include <linux/can.h>
+#include <linux/can/raw.h>
+
+#define ID 0x123
+#define TC 18 /* # of testcases */
+
+const int rx_res[TC] = {4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1};
+const int rxbits_res[TC] = {4369, 4369, 4369, 4369, 17, 4352, 17, 4352, 257, 257, 4112, 4112, 1, 256, 16, 4096, 1, 256};
+
+canid_t calc_id(int testcase)
+{
+	canid_t id = ID;
+
+	if (testcase & 1)
+		id |= CAN_EFF_FLAG;
+	if (testcase & 2)
+		id |= CAN_RTR_FLAG;
+
+	return id;
+}
+
+canid_t calc_mask(int testcase)
+{
+	canid_t mask = CAN_SFF_MASK;
+
+	if (testcase > 15)
+		return (CAN_EFF_MASK | CAN_EFF_FLAG | CAN_RTR_FLAG);
+
+	if (testcase & 4)
+		mask |= CAN_EFF_FLAG;
+	if (testcase & 8)
+		mask |= CAN_RTR_FLAG;
+
+	return mask;
+}
+
+int main(int argc, char **argv)
+{
+	fd_set rdfs;
+        struct timeval tv;
+	int s;
+	struct sockaddr_can addr;
+	struct can_filter rfilter;
+	struct can_frame frame;
+	int testcase;
+	int have_rx;
+	int rx;
+	int rxbits, rxbitval;
+	int ret;
+	int recv_own_msgs = 1;
+	struct ifreq ifr;
+
+	/* check command line options */
+	if (argc != 2) {
+		fprintf(stderr, "Usage: %s <device>\n", argv[0]);
+		return 1;
+	}
+
+	if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
+		perror("socket");
+		return 1;
+	}
+
+	strcpy(ifr.ifr_name, argv[1]);
+	if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
+		perror("SIOCGIFINDEX");
+		return 1;
+	}
+	addr.can_family = AF_CAN;
+	addr.can_ifindex = ifr.ifr_ifindex;
+
+	setsockopt(s, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS,
+		   &recv_own_msgs, sizeof(recv_own_msgs));
+
+	if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
+		perror("bind");
+		return 1;
+	}
+
+	printf("---\n");
+
+	for (testcase = 0; testcase < TC; testcase++) {
+		
+		rfilter.can_id   = calc_id(testcase);
+		rfilter.can_mask = calc_mask(testcase);
+		setsockopt(s, SOL_CAN_RAW, CAN_RAW_FILTER,
+			   &rfilter, sizeof(rfilter));
+
+		printf("testcase %2d filters : can_id = 0x%08X can_mask = 0x%08X\n",
+		       testcase, rfilter.can_id, rfilter.can_mask);
+
+		printf("testcase %2d sending patterns ... ", testcase);
+
+		frame.can_dlc = 1;
+		frame.data[0] = testcase;
+
+		frame.can_id = ID;
+		if (write(s, &frame, sizeof(frame)) < 0) {
+			perror("write");
+			exit(1);
+		}
+		frame.can_id = (ID | CAN_RTR_FLAG);
+		if (write(s, &frame, sizeof(frame)) < 0) {
+			perror("write");
+			exit(1);
+		}
+		frame.can_id = (ID | CAN_EFF_FLAG);
+		if (write(s, &frame, sizeof(frame)) < 0) {
+			perror("write");
+			exit(1);
+		}
+		frame.can_id = (ID | CAN_EFF_FLAG | CAN_RTR_FLAG);
+		if (write(s, &frame, sizeof(frame)) < 0) {
+			perror("write");
+			exit(1);
+		}
+
+		printf("ok\n");
+
+		have_rx = 1;
+		rx = 0;
+		rxbits = 0;
+
+		while (have_rx) {
+
+			have_rx = 0;
+			FD_ZERO(&rdfs);
+			FD_SET(s, &rdfs);
+			tv.tv_sec = 0;
+			tv.tv_usec = 50000; /* 50ms timeout */
+
+			ret = select(s+1, &rdfs, NULL, NULL, &tv);
+			if (ret < 0) {
+				perror("select");
+				exit(1);
+			}
+
+			if (FD_ISSET(s, &rdfs)) {
+				have_rx = 1;
+				ret = read(s, &frame, sizeof(struct can_frame));
+				if (ret < 0) {
+					perror("read");
+					exit(1);
+				}
+				if ((frame.can_id & CAN_SFF_MASK) != ID) {
+					fprintf(stderr, "received wrong can_id!\n");
+					exit(1);
+				}
+				if (frame.data[0] != testcase) {
+					fprintf(stderr, "received wrong testcase!\n");
+					exit(1);
+				}
+
+				/* test & calc rxbits */
+				rxbitval = 1 << ((frame.can_id & (CAN_EFF_FLAG|CAN_RTR_FLAG|CAN_ERR_FLAG)) >> 28);
+
+				/* only receive a rxbitval once */
+				if ((rxbits & rxbitval) == rxbitval) {
+					fprintf(stderr, "received rxbitval %d twice!\n", rxbitval);
+					exit(1);
+				}
+				rxbits |= rxbitval;
+				rx++;
+
+				printf("testcase %2d rx : can_id = 0x%08X rx = %d rxbits = %d\n",
+				       testcase, frame.can_id, rx, rxbits);
+			}
+		}
+		/* rx timed out -> check the received results */
+		if (rx_res[testcase] != rx) {
+			fprintf(stderr, "wrong rx value in testcase %d : %d (expected %d)\n",
+				testcase, rx, rx_res[testcase]);
+			exit(1);
+		}
+		if (rxbits_res[testcase] != rxbits) {
+			fprintf(stderr, "wrong rxbits value in testcase %d : %d (expected %d)\n",
+				testcase, rxbits, rxbits_res[testcase]);
+			exit(1);
+		}
+		printf("testcase %2d ok\n---\n", testcase);
+	}
+
+	close(s);
+
+	return 0;
+}
diff --git a/testcases/network/can/filter-tests/tst-packet.c b/testcases/network/can/filter-tests/tst-packet.c
deleted file mode 100644
index 12432bb..0000000
--- a/testcases/network/can/filter-tests/tst-packet.c
+++ /dev/null
@@ -1,167 +0,0 @@
-/*
- *  $Id: tst-packet.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-packet.c - send and receive CAN frames via PF_PACKET sockets
- *
- * Remark: The sending of CAN frames via PF_PACKET does not work for
- * virtual CAN devices (vcan) as the packet type is not set to
- * PACKET_LOOPBACK by the packet socket, so you'll never get something
- * back (btw the outgoing vcan packet counters are updated correctly).
- *
- * Copyright (c) 2002-2009 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <net/if.h>
-#include <netinet/in.h>         /* for htons() */
-
-#include <linux/if_packet.h>
-#include <linux/if_ether.h>     /* for ETH_P_CAN */
-#include <linux/can.h>          /* for struct can_frame */
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct can_frame frame;
-        int nbytes, i;
-        static struct ifreq ifr;
-        static struct sockaddr_ll sll;
-        char *ifname = "vcan2";
-        int ifindex;
-        int opt;
-        int send_one_frame = 0;
-
-        while ((opt = getopt(argc, argv, "i:s")) != -1) {
-                switch (opt) {
-
-                case 'i':
-                        ifname = optarg;
-                        break;
-
-                case 's':
-                        send_one_frame = 1;
-                        break;
-
-                default:
-                        fprintf(stderr, "Unknown option %c\n", opt);
-                        break;
-                }
-        }
-
-        s = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_CAN));
-        if (s < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        if (strcmp(ifname, "any") == 0)
-                ifindex = 0;
-        else {
-                strcpy(ifr.ifr_name, ifname);
-                ioctl(s, SIOCGIFINDEX, &ifr);
-                ifindex = ifr.ifr_ifindex;
-        }
-
-        sll.sll_family   = AF_PACKET;
-        sll.sll_ifindex  = ifindex;
-        sll.sll_protocol = htons(ETH_P_CAN);
-
-        if (bind(s, (struct sockaddr *)&sll, sizeof(sll)) < 0) {
-                perror("bind");
-                return 1;
-        }
-
-        if (send_one_frame) {
-
-                frame.can_id  = 0x123;
-                frame.can_dlc = 2;
-                frame.data[0] = 0x11;
-                frame.data[1] = 0x22;
-
-                nbytes = write(s, &frame, sizeof(struct can_frame));
-                if (nbytes < 0) {
-                        perror("write");
-                        return 1;
-                }
-                if (nbytes != sizeof(struct can_frame)) {
-                        perror("write_len");
-                        return 1;
-                }
-        }
-
-        while (1) {
-
-                if ((nbytes = read(s, &frame, sizeof(struct can_frame))) < 0) {
-                        perror("read");
-                        return 1;
-                } else if (nbytes < sizeof(struct can_frame)) {
-                        fprintf(stderr, "read: incomplete CAN frame\n");
-                        return 1;
-                } else {
-                        if (frame.can_id & CAN_EFF_FLAG)
-                                printf("%8X  ", frame.can_id & CAN_EFF_MASK);
-                        else
-                                printf("%3X  ", frame.can_id & CAN_SFF_MASK);
-
-                        printf("[%d] ", frame.can_dlc);
-
-                        for (i = 0; i < frame.can_dlc; i++) {
-                                printf("%02X ", frame.data[i]);
-                        }
-                        if (frame.can_id & CAN_RTR_FLAG)
-                                printf("remote request");
-                        printf("\n");
-                        fflush(stdout);
-                }
-        }
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-proc.c b/testcases/network/can/filter-tests/tst-proc.c
deleted file mode 100644
index a33c600..0000000
--- a/testcases/network/can/filter-tests/tst-proc.c
+++ /dev/null
@@ -1,120 +0,0 @@
-/*
- *  $Id: tst-proc.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-proc.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <sys/uio.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/raw.h>
-
-#define MAX_RAW 800
-
-int main(int argc, char **argv)
-{
-        int s[MAX_RAW];
-        struct sockaddr_can addr;
-        struct ifreq ifr;
-        int i,numsock;
-
-        if (argc != 2) {
-                fprintf(stderr, "Error: Wrong number of arguments. Try %s <number of created sockets>.\n", argv[0]);
-                exit(1);
-        }
-
-        numsock = atoi(argv[1]);
-
-        if (numsock >= MAX_RAW) {
-                fprintf(stderr, "Error: more than %d sockets to open (see #define MAX_RAW).\n", MAX_RAW);
-                exit(1);
-        }
-
-        printf("\ncreating %d raw sockets ... ", numsock);
-
-        if (numsock) {
-                for (i=0; i < numsock; i++) {
-                        if ((s[i] = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
-                                perror("socket");
-                                return 1;
-                        }
-
-                        addr.can_family = PF_CAN;
-                        strcpy(ifr.ifr_name, "vcan2");
-                        ioctl(s[i], SIOCGIFINDEX, &ifr);
-                        addr.can_ifindex = ifr.ifr_ifindex;
-
-                        if (bind(s[i], (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                                perror("connect");
-                                return 1;
-                        }
-                }
-        }
-
-        printf("done.\n");
-
-        printf("Waiting for keyboard input ...");
-
-        getchar();
-
-        printf("closing %d raw sockets ... ", numsock);
-
-        if (numsock)
-                for (i=0; i < numsock; i++)
-                        close(s[i]);
-
-        printf("done.\n\n");
-
-    return 0;
-
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-raw-filter.c b/testcases/network/can/filter-tests/tst-raw-filter.c
deleted file mode 100644
index a244ead..0000000
--- a/testcases/network/can/filter-tests/tst-raw-filter.c
+++ /dev/null
@@ -1,177 +0,0 @@
-/*
- *  $Id: tst-raw-filter.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-raw-filter.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/raw.h>
-
-#define MAXFILTERS 32
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct sockaddr_can addr;
-        struct can_filter rfilter[MAXFILTERS];
-        struct can_frame frame;
-        int nbytes, i;
-        struct ifreq ifr;
-        char *ifname = "any";
-        int ifindex;
-        int opt;
-        int peek = 0;
-        int nfilters = 0;
-        int deflt = 0;
-
-        while ((opt = getopt(argc, argv, "i:p:f:d")) != -1) {
-                switch (opt) {
-                case 'i': /* specify different interface than default */
-                        ifname = optarg;
-                        break;
-                case 'p': /* MSG_PEEK 'p' times before consuming the frame */
-                        peek = atoi(optarg);
-                        break;
-                case 'd': /* use default settings from CAN_RAW socket */
-                        deflt = 1;
-                        break;
-                case 'f': /* add this filter can_id:can_mask */
-                        if (nfilters >= MAXFILTERS) {
-                                fputs("too many filters\n", stderr);
-                                break;
-                        }
-                        rfilter[nfilters].can_id = strtoul(strtok(optarg, ":"), NULL, 16);
-                        rfilter[nfilters].can_mask = strtoul(strtok(NULL, ":"), NULL, 16);
-                        nfilters++;
-                        break;
-                default:
-                        fprintf(stderr, "Unknown option %c\n", opt);
-                        break;
-                }
-        }
-
-        if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        if (deflt) {
-                printf("%s: using CAN_RAW socket default filter.\n", argv[0]);
-        } else {
-                printf("%s: setting %d CAN filter(s).\n", argv[0], nfilters);
-                setsockopt(s, SOL_CAN_RAW, CAN_RAW_FILTER, &rfilter,
-                           sizeof(*rfilter) * nfilters);
-        }
-
-        if (strcmp(ifname, "any") == 0)
-                ifindex = 0;
-        else {
-                strcpy(ifr.ifr_name, ifname);
-                ioctl(s, SIOCGIFINDEX, &ifr);
-                ifindex = ifr.ifr_ifindex;
-        }
-
-        addr.can_family = AF_CAN;
-        addr.can_ifindex = ifindex;
-
-        if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("bind");
-                return 1;
-        }
-
-        while (1) {
-                socklen_t len = sizeof(addr);
-                int flags;
-
-                if (peek && peek--)
-                        flags = MSG_PEEK;
-                else
-                        flags = 0;
-
-                nbytes = recvfrom(s, &frame, sizeof(struct can_frame),
-                                  flags, (struct sockaddr*)&addr, &len);
-                if (nbytes < 0) {
-                        perror("read");
-                        return 1;
-                } else if (nbytes < sizeof(struct can_frame)) {
-                        fprintf(stderr, "read: incomplete CAN frame from iface %d\n",
-                                addr.can_ifindex);
-                        return 1;
-                } else {
-                        ifr.ifr_ifindex = addr.can_ifindex;
-                        ioctl(s, SIOCGIFNAME, &ifr);
-                        printf(" %-5s ", ifr.ifr_name);
-                        if (frame.can_id & CAN_EFF_FLAG)
-                                printf("%8X  ", frame.can_id & CAN_EFF_MASK);
-                        else
-                                printf("%3X  ", frame.can_id & CAN_SFF_MASK);
-
-                        printf("[%d] ", frame.can_dlc);
-
-                        for (i = 0; i < frame.can_dlc; i++) {
-                                printf("%02X ", frame.data[i]);
-                        }
-                        if (frame.can_id & CAN_RTR_FLAG)
-                                printf("remote request");
-                        if (flags & MSG_PEEK)
-                                printf(" (MSG_PEEK)");
-                        printf("\n");
-                        fflush(stdout);
-                }
-        }
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-raw-sendto.c b/testcases/network/can/filter-tests/tst-raw-sendto.c
deleted file mode 100644
index 94808b4..0000000
--- a/testcases/network/can/filter-tests/tst-raw-sendto.c
+++ /dev/null
@@ -1,115 +0,0 @@
-/*
- *  $Id: tst-raw-sendto.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-raw-sendto.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/raw.h>
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct sockaddr_can addr;
-        struct can_frame frame;
-        int nbytes;
-        struct ifreq ifr;
-        char *ifname = "vcan2";
-        int ifindex;
-        int opt;
-
-        while ((opt = getopt(argc, argv, "i:")) != -1) {
-                switch (opt) {
-                case 'i':
-                        ifname = optarg;
-                        break;
-                default:
-                        fprintf(stderr, "Unknown option %c\n", opt);
-                        break;
-                }
-        }
-
-        if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        strcpy(ifr.ifr_name, ifname);
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        ifindex = ifr.ifr_ifindex;
-
-        addr.can_family  = AF_CAN;
-        addr.can_ifindex = 0; /* bind to all interfaces */
-
-        if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("bind");
-                return 1;
-        }
-
-        /* fill CAN frame */
-        frame.can_id  = 0x123;
-        frame.can_dlc = 3;
-        frame.data[0] = 0x11;
-        frame.data[1] = 0x22;
-        frame.data[2] = 0x33;
-
-        addr.can_family  = AF_CAN;
-        addr.can_ifindex = ifindex; /* send via this interface */
-
-        nbytes = sendto(s, &frame, sizeof(struct can_frame), 0, (struct sockaddr*)&addr, sizeof(addr));
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-raw.c b/testcases/network/can/filter-tests/tst-raw.c
deleted file mode 100644
index fd3958f..0000000
--- a/testcases/network/can/filter-tests/tst-raw.c
+++ /dev/null
@@ -1,186 +0,0 @@
-/*
- *  $Id: tst-raw.c,v 1.1 2009/03/02 15:33:55 subrata_modak Exp $
- */
-
-/*
- * tst-raw.c
- *
- * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of Volkswagen nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * Alternatively, provided that this notice is retained in full, this
- * software may be distributed under the terms of the GNU General
- * Public License ("GPL") version 2, in which case the provisions of the
- * GPL apply INSTEAD OF those given above.
- *
- * The provided data structures and external interfaces from this code
- * are not restricted to be used by modules with a GPL compatible license.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
- * DAMAGE.
- *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <string.h>
-
-#include <sys/types.h>
-#include <sys/socket.h>
-#include <sys/ioctl.h>
-#include <net/if.h>
-
-#include <linux/can.h>
-#include <linux/can/raw.h>
-
-int main(int argc, char **argv)
-{
-        int s;
-        struct sockaddr_can addr;
-        struct can_filter rfilter[4];
-        struct can_frame frame;
-        int nbytes, i;
-        struct ifreq ifr;
-        char *ifname = "vcan2";
-        int ifindex;
-        int opt;
-
-        /* sockopt test */
-        int loopback = 0;
-        int set_loopback = 0;
-        int recv_own_msgs = 0;
-        int set_recv_own_msgs = 0;
-        int send_one_frame = 0;
-        int ignore_errors = 0;
-
-        while ((opt = getopt(argc, argv, "i:l:r:se")) != -1) {
-                switch (opt) {
-
-                case 'i':
-                        ifname = optarg;
-                        break;
-
-                case 'l':
-                        loopback = atoi(optarg);
-                        set_loopback = 1;
-                        break;
-
-                case 'r':
-                        recv_own_msgs = atoi(optarg);
-                        set_recv_own_msgs = 1;
-                        break;
-
-                case 's':
-                        send_one_frame = 1;
-                        break;
-
-                case 'e':
-                        ignore_errors = 1;
-                        break;
-
-                default:
-                        fprintf(stderr, "Unknown option %c\n", opt);
-                        break;
-                }
-        }
-
-        if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
-                perror("socket");
-                return 1;
-        }
-
-        rfilter[0].can_id   = 0x123;
-        rfilter[0].can_mask = CAN_SFF_MASK;
-        rfilter[1].can_id   = 0x200;
-        rfilter[1].can_mask = 0x700;
-        rfilter[2].can_id   = 0x80123456;
-        rfilter[2].can_mask = 0x1FFFF000;
-        rfilter[3].can_id   = 0x80333333;
-        rfilter[3].can_mask = CAN_EFF_MASK;
-
-        setsockopt(s, SOL_CAN_RAW, CAN_RAW_FILTER, &rfilter, sizeof(rfilter));
-
-        if (set_loopback)
-                setsockopt(s, SOL_CAN_RAW, CAN_RAW_LOOPBACK, &loopback, sizeof(loopback));
-
-        if (set_recv_own_msgs)
-                setsockopt(s, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS, &recv_own_msgs, sizeof(recv_own_msgs));
-
-        strcpy(ifr.ifr_name, ifname);
-        ioctl(s, SIOCGIFINDEX, &ifr);
-        ifindex = ifr.ifr_ifindex;
-
-        addr.can_family = AF_CAN;
-        addr.can_ifindex = ifindex;
-
-        if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
-                perror("bind");
-                return 1;
-        }
-
-        if (send_one_frame) {
-
-                frame.can_id  = 0x123;
-                frame.can_dlc = 2;
-                frame.data[0] = 0x11;
-                frame.data[1] = 0x22;
-
-                nbytes = write(s, &frame, sizeof(struct can_frame));
-        }
-
-        while (1) {
-
-                if ((nbytes = read(s, &frame, sizeof(struct can_frame))) < 0) {
-                        perror("read");
-                        if (!ignore_errors)
-                                return 1;
-                } else if (nbytes < sizeof(struct can_frame)) {
-                        fprintf(stderr, "read: incomplete CAN frame\n");
-                        return 1;
-                } else {
-                        if (frame.can_id & CAN_EFF_FLAG)
-                                printf("%8X  ", frame.can_id & CAN_EFF_MASK);
-                        else
-                                printf("%3X  ", frame.can_id & CAN_SFF_MASK);
-
-                        printf("[%d] ", frame.can_dlc);
-
-                        for (i = 0; i < frame.can_dlc; i++) {
-                                printf("%02X ", frame.data[i]);
-                        }
-                        if (frame.can_id & CAN_RTR_FLAG)
-                                printf("remote request");
-                        printf("\n");
-                        fflush(stdout);
-                }
-        }
-
-        close(s);
-
-    return 0;
-}
\ No newline at end of file
diff --git a/testcases/network/can/filter-tests/tst-rcv-own-msgs.c b/testcases/network/can/filter-tests/tst-rcv-own-msgs.c
new file mode 100644
index 0000000..593e9fb
--- /dev/null
+++ b/testcases/network/can/filter-tests/tst-rcv-own-msgs.c
@@ -0,0 +1,247 @@
+/*
+ *  $Id: tst-rcv-own-msgs.c 1193 2010-08-09 14:00:21Z hartkopp $
+ */
+
+/*
+ * tst-rcv-own-msgs.c
+ *
+ * Copyright (c) 2010 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions and the following disclaimer.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the name of Volkswagen nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2, in which case the provisions of the
+ * GPL apply INSTEAD OF those given above.
+ *
+ * The provided data structures and external interfaces from this code
+ * are not restricted to be used by modules with a GPL compatible license.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
+ * DAMAGE.
+ *
+ * Send feedback to <socketcan-users@lists.berlios.de>
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <string.h>
+
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <sys/ioctl.h>
+#include <sys/time.h>
+#include <net/if.h>
+
+#include <linux/can.h>
+#include <linux/can/raw.h>
+
+
+#define max(a,b) (a > b ? a : b)
+
+struct rxs {
+	int s;
+	int t;
+};
+
+struct rxs test_sockets(int s, int t, canid_t can_id)
+{
+	fd_set rdfs;
+	struct timeval tv;
+	int m = max(s,t)+1;
+	int have_rx = 1;
+	struct can_frame frame;
+	struct rxs rx;
+	int ret;
+
+	frame.can_id = can_id;
+	frame.can_dlc = 0;
+	if (write(s, &frame, sizeof(frame)) < 0) {
+		perror("write");
+		exit(1);
+	}
+
+	rx.s = rx.t = 0;
+
+	while (have_rx) {
+
+		FD_ZERO(&rdfs);
+		FD_SET(s, &rdfs);
+		FD_SET(t, &rdfs);
+		tv.tv_sec = 0;
+		tv.tv_usec = 50000; /* 50ms timeout */
+		have_rx = 0;
+
+		ret = select(m, &rdfs, NULL, NULL, &tv);
+		if (ret < 0) {
+			perror("select");
+			exit(1);
+		}
+
+		if (FD_ISSET(s, &rdfs)) {
+
+			have_rx = 1;
+			ret = read(s, &frame, sizeof(struct can_frame));
+			if (ret < 0) {
+				perror("read");
+				exit(1);
+			}
+			if (frame.can_id != can_id) {
+				fprintf(stderr, "received wrong can_id!\n");
+				exit(1);
+			}
+			rx.s++;
+		}
+
+		if (FD_ISSET(t, &rdfs)) {
+
+			have_rx = 1;
+			ret = read(t, &frame, sizeof(struct can_frame));
+			if (ret < 0) {
+				perror("read");
+				exit(1);
+			}
+			if (frame.can_id != can_id) {
+				fprintf(stderr, "received wrong can_id!\n");
+				exit(1);
+			}
+			rx.t++;
+		}
+	}
+
+	/* timeout */
+
+	return rx;
+}
+
+void setopts(int s, int loopback, int recv_own_msgs)
+{
+	setsockopt(s, SOL_CAN_RAW, CAN_RAW_LOOPBACK,
+		   &loopback, sizeof(loopback));
+	setsockopt(s, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS,
+		   &recv_own_msgs, sizeof(recv_own_msgs));
+
+	printf("check loopback %d recv_own_msgs %d ... ",
+	       loopback, recv_own_msgs);
+}
+
+
+int main(int argc, char **argv)
+{
+	int s, t;
+	struct sockaddr_can addr;
+	struct ifreq ifr;
+	struct rxs rx;
+
+	/* check command line options */
+	if (argc != 2) {
+		fprintf(stderr, "Usage: %s <device>\n", argv[0]);
+		return 1;
+	}
+
+	if ((s = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
+		perror("socket");
+		return 1;
+	}
+	if ((t = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
+		perror("socket");
+		return 1;
+	}
+
+	strcpy(ifr.ifr_name, argv[1]);
+	if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
+		perror("SIOCGIFINDEX");
+		return 1;
+	}
+	addr.can_ifindex = ifr.ifr_ifindex;
+	addr.can_family = AF_CAN;
+
+	if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
+		perror("bind");
+		return 1;
+	}
+	if (bind(t, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
+		perror("bind");
+		return 1;
+	}
+
+	printf("Starting PF_CAN frame flow test.\n");
+	printf("checking socket default settings ... ");
+	rx = test_sockets(s, t, 0x340);
+	if (rx.s == 0 && rx.t == 1)
+		printf("ok.\n");
+	else {
+		printf("failure!\n");
+		return 1;
+	}
+
+	/* check loopback 0 recv_own_msgs 0 */
+	setopts(s, 0, 0);
+	rx = test_sockets(s, t, 0x341);
+	if (rx.s == 0 && rx.t == 0)
+		printf("ok.\n");
+	else {
+		printf("failure!\n");
+		return 1;
+	}
+
+	/* check loopback 0 recv_own_msgs 1 */
+	setopts(s, 0, 1);
+	rx = test_sockets(s, t, 0x342);
+	if (rx.s == 0 && rx.t == 0)
+		printf("ok.\n");
+	else {
+		printf("failure!\n");
+		return 1;
+	}
+
+	/* check loopback 1 recv_own_msgs 0 */
+	setopts(s, 1, 0);
+	rx = test_sockets(s, t, 0x343);
+	if (rx.s == 0 && rx.t == 1)
+		printf("ok.\n");
+	else {
+		printf("failure!\n");
+		return 1;
+	}
+
+	/* check loopback 1 recv_own_msgs 1 */
+	setopts(s, 1, 1);
+	rx = test_sockets(s, t, 0x344);
+	if (rx.s == 1 && rx.t == 1)
+		printf("ok.\n");
+	else {
+		printf("failure!\n");
+		return 1;
+	}
+
+	printf("PF_CAN frame flow test was successful.\n");
+
+	close(s);
+	close(t);
+
+	return 0;
+}
