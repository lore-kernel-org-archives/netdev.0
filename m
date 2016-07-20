From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next] samples: Add an IPv6 '-6' option to the pktgen scripts
Date: Wed, 20 Jul 2016 15:48:43 -0700
Message-ID: <1469054923-4178431-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:25295 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932084AbcGTWsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 18:48:45 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6KMg02f001680
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 15:48:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24ahysg4c1-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 15:48:44 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 1c444ce64ecc11e6abaa0002c992ebde-dcbfcaf0 for <netdev@vger.kernel.org>;	Wed,
 20 Jul 2016 15:48:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a '-6' option to the sample pktgen scripts for sending out
IPv6 packets.

[root@kerneldev010.prn1 ~/pktgen]# ./pktgen_sample03_burst_single_flow.sh -i eth0 -s 64 -d fe80::f652:14ff:fec2:a14c -m f4:52:14:c2:a1:4c -b 32 -6

[root@kerneldev011.prn1 ~]# tcpdump -i eth0 -nn -c3 port 9
tcpdump: WARNING: eth0: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
14:38:51.815297 IP6 fe80::f652:14ff:fec2:2ad2.9 > fe80::f652:14ff:fec2:a14c.9: UDP, length 16
14:38:51.815311 IP6 fe80::f652:14ff:fec2:2ad2.9 > fe80::f652:14ff:fec2:a14c.9: UDP, length 16
14:38:51.815313 IP6 fe80::f652:14ff:fec2:2ad2.9 > fe80::f652:14ff:fec2:a14c.9: UDP, length 16

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 samples/pktgen/parameters.sh                           | 7 ++++++-
 samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh | 6 ++++--
 samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh    | 6 ++++--
 samples/pktgen/pktgen_sample01_simple.sh               | 6 ++++--
 samples/pktgen/pktgen_sample02_multiqueue.sh           | 6 ++++--
 samples/pktgen/pktgen_sample03_burst_single_flow.sh    | 6 ++++--
 6 files changed, 26 insertions(+), 11 deletions(-)

diff --git a/samples/pktgen/parameters.sh b/samples/pktgen/parameters.sh
index 33b70fd..f70ea7d 100644
--- a/samples/pktgen/parameters.sh
+++ b/samples/pktgen/parameters.sh
@@ -14,12 +14,13 @@ function usage() {
     echo "  -b : (\$BURST)     HW level bursting of SKBs"
     echo "  -v : (\$VERBOSE)   verbose"
     echo "  -x : (\$DEBUG)     debug"
+    echo "  -6 : (\$IP6)       IPv6"
     echo ""
 }
 
 ##  --- Parse command line arguments / parameters ---
 ## echo "Commandline options:"
-while getopts "s:i:d:m:t:c:b:vxh" option; do
+while getopts "s:i:d:m:t:c:b:vxh6" option; do
     case $option in
         i) # interface
           export DEV=$OPTARG
@@ -59,6 +60,10 @@ while getopts "s:i:d:m:t:c:b:vxh" option; do
           export DEBUG=yes
           info "Debug mode: DEBUG=$DEBUG"
           ;;
+	6)
+	  export IP6=6
+	  info "IP6: IP6=$IP6"
+	  ;;
         h|?|*)
           usage;
           err 2 "[ERROR] Unknown parameters!!!"
diff --git a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
index cb15903..f3e1bed 100755
--- a/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
+++ b/samples/pktgen/pktgen_bench_xmit_mode_netif_receive.sh
@@ -34,7 +34,9 @@ root_check_run_with_sudo "$@"
 source ${basedir}/parameters.sh
 # Using invalid DST_MAC will cause the packets to get dropped in
 # ip_rcv() which is part of the test
-[ -z "$DEST_IP" ] && DEST_IP="198.18.0.42"
+if [ -z "$DEST_IP" ]; then
+    [ -z "$IP6" ] && DEST_IP="198.18.0.42" || DEST_IP="FD00::1"
+fi
 [ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
 [ -z "$BURST" ] && BURST=1024
 
@@ -64,7 +66,7 @@ for ((thread = 0; thread < $THREADS; thread++)); do
 
     # Destination
     pg_set $dev "dst_mac $DST_MAC"
-    pg_set $dev "dst $DEST_IP"
+    pg_set $dev "dst$IP6 $DEST_IP"
 
     # Inject packet into RX path of stack
     pg_set $dev "xmit_mode netif_receive"
diff --git a/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
index 4e4e92b..cc102e9 100755
--- a/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
+++ b/samples/pktgen/pktgen_bench_xmit_mode_queue_xmit.sh
@@ -13,7 +13,9 @@ root_check_run_with_sudo "$@"
 
 # Parameter parsing via include
 source ${basedir}/parameters.sh
-[ -z "$DEST_IP" ] && DEST_IP="198.18.0.42"
+if [ -z "$DEST_IP" ]; then
+    [ -z "$IP6" ] && DEST_IP="198.18.0.42" || DEST_IP="FD00::1"
+fi
 [ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
 
 # Burst greater than 1 are invalid for queue_xmit mode
@@ -47,7 +49,7 @@ for ((thread = 0; thread < $THREADS; thread++)); do
 
     # Destination
     pg_set $dev "dst_mac $DST_MAC"
-    pg_set $dev "dst $DEST_IP"
+    pg_set $dev "dst$IP6 $DEST_IP"
 
     # Inject packet into TX qdisc egress path of stack
     pg_set $dev "xmit_mode queue_xmit"
diff --git a/samples/pktgen/pktgen_sample01_simple.sh b/samples/pktgen/pktgen_sample01_simple.sh
index 8c9d318..29ef4ba 100755
--- a/samples/pktgen/pktgen_sample01_simple.sh
+++ b/samples/pktgen/pktgen_sample01_simple.sh
@@ -14,7 +14,9 @@ root_check_run_with_sudo "$@"
 source ${basedir}/parameters.sh
 #
 # Set some default params, if they didn't get set
-[ -z "$DEST_IP" ] && DEST_IP="198.18.0.42"
+if [ -z "$DEST_IP" ]; then
+    [ -z "$IP6" ] && DEST_IP="198.18.0.42" || DEST_IP="FD00::1"
+fi
 [ -z "$CLONE_SKB" ] && CLONE_SKB="0"
 # Example enforce param "-m" for dst_mac
 [ -z "$DST_MAC" ] && usage && err 2 "Must specify -m dst_mac"
@@ -54,7 +56,7 @@ pg_set $DEV "flag NO_TIMESTAMP"
 
 # Destination
 pg_set $DEV "dst_mac $DST_MAC"
-pg_set $DEV "dst $DEST_IP"
+pg_set $DEV "dst$IP6 $DEST_IP"
 
 # Setup random UDP port src range
 pg_set $DEV "flag UDPSRC_RND"
diff --git a/samples/pktgen/pktgen_sample02_multiqueue.sh b/samples/pktgen/pktgen_sample02_multiqueue.sh
index 32467ae..c88a161 100755
--- a/samples/pktgen/pktgen_sample02_multiqueue.sh
+++ b/samples/pktgen/pktgen_sample02_multiqueue.sh
@@ -23,7 +23,9 @@ UDP_MIN=9
 UDP_MAX=109
 
 # (example of setting default params in your script)
-[ -z "$DEST_IP" ] && DEST_IP="198.18.0.42"
+if [ -z "$DEST_IP" ]; then
+    [ -z "$IP6" ] && DEST_IP="198.18.0.42" || DEST_IP="FD00::1"
+fi
 [ -z "$DST_MAC" ] && DST_MAC="90:e2:ba:ff:ff:ff"
 
 # General cleanup everything since last run
@@ -54,7 +56,7 @@ for ((thread = 0; thread < $THREADS; thread++)); do
 
     # Destination
     pg_set $dev "dst_mac $DST_MAC"
-    pg_set $dev "dst $DEST_IP"
+    pg_set $dev "dst$IP6 $DEST_IP"
 
     # Setup random UDP port src range
     pg_set $dev "flag UDPSRC_RND"
diff --git a/samples/pktgen/pktgen_sample03_burst_single_flow.sh b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
index 775f5d0..80cf8f5 100755
--- a/samples/pktgen/pktgen_sample03_burst_single_flow.sh
+++ b/samples/pktgen/pktgen_sample03_burst_single_flow.sh
@@ -25,7 +25,9 @@ root_check_run_with_sudo "$@"
 # Parameter parsing via include
 source ${basedir}/parameters.sh
 # Set some default params, if they didn't get set
-[ -z "$DEST_IP" ]   && DEST_IP="198.18.0.42"
+if [ -z "$DEST_IP" ]; then
+    [ -z "$IP6" ] && DEST_IP="198.18.0.42" || DEST_IP="FD00::1"
+fi
 [ -z "$DST_MAC" ]   && DST_MAC="90:e2:ba:ff:ff:ff"
 [ -z "$BURST" ]     && BURST=32
 [ -z "$CLONE_SKB" ] && CLONE_SKB="100000"
@@ -55,7 +57,7 @@ for ((thread = 0; thread < $THREADS; thread++)); do
 
     # Destination
     pg_set $dev "dst_mac $DST_MAC"
-    pg_set $dev "dst $DEST_IP"
+    pg_set $dev "dst$IP6 $DEST_IP"
 
     # Setup burst, for easy testing -b 0 disable bursting
     # (internally in pktgen default and minimum burst=1)
-- 
2.5.1
