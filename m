From: Marcela Maslanova <mmaslano@redhat.com>
Subject: [PATCH] /sbin/ifcfg assumes ip, arping and rdisc are in $PATH
Date: Fri, 25 Apr 2008 12:05:26 +0200
Message-ID: <4811ACE6.7020908@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000407070902030802060203"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759716AbYDYKHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 06:07:46 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m3PA7j9J016879
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 06:07:45 -0400
Received: from pobox.stuttgart.redhat.com (pobox.stuttgart.redhat.com [172.16.2.10])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m3PA7i4U000377
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 06:07:45 -0400
Received: from caladan.englab.brq.redhat.com (caladan.englab.brq.redhat.com [10.34.32.66])
	by pobox.stuttgart.redhat.com (8.13.1/8.13.1) with ESMTP id m3PA7iKA003196
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 06:07:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000407070902030802060203
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

Patch from Ville Skyttä.
/sbin/ifcfg assumes that ip, arping, and rdisc are in $PATH which is not the
case eg. after "sudo -s" from a non-root user.  

-- 
Marcela Ma¹láòová
BaseOS team Brno


--------------000407070902030802060203
Content-Type: text/x-patch;
 name="paths.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="paths.patch"

diff -up iproute2-2.6.23/ip/routel~ iproute2-2.6.23/ip/routel
--- iproute2-2.6.23/ip/routel~	2007-10-17 00:27:42.000000000 +0300
+++ iproute2-2.6.23/ip/routel	2008-04-24 20:22:50.000000000 +0300
@@ -14,7 +14,7 @@ test "X-h" = "X$1" && echo "Usage: $0 [t
 
 test -z "$*" && set 0
 
-ip route list table "$@" |
+/sbin/ip route list table "$@" |
  while read network rest
  do set xx $rest
     shift
diff -up iproute2-2.6.23/ip/ifcfg~ iproute2-2.6.23/ip/ifcfg
--- iproute2-2.6.23/ip/ifcfg~	2007-10-17 00:27:42.000000000 +0300
+++ iproute2-2.6.23/ip/ifcfg	2008-04-24 20:25:39.000000000 +0300
@@ -15,7 +15,7 @@ CheckForwarding () {
 }
 
 RestartRDISC () {
-  killall -HUP rdisc || rdisc -fs
+  killall -HUP rdisc || /sbin/rdisc -fs
 }
 
 ABCMaskLen () {
@@ -56,7 +56,7 @@ stop)
     echo "Cannot stop alias $ldev" 1>&2
     exit 1;
   fi
-  ip -4 addr flush dev $dev $label || exit 1
+  /sbin/ip -4 addr flush dev $dev $label || exit 1
   if [ $fwd -eq 0 ]; then RestartRDISC; fi
   exit 0 ;;
 del*)
@@ -102,45 +102,45 @@ if [ "$ldev" = "$dev" -a "$ipaddr" != ""
 fi
 
 if [ $deleting -ne 0 ]; then
-  ip addr del $pfx dev $dev $label || exit 1
+  /sbin/ip addr del $pfx dev $dev $label || exit 1
   if [ $fwd -eq 0 ]; then RestartRDISC; fi
   exit 0
 fi
 
 
-if ! ip link set up dev $dev ; then
+if ! /sbin/ip link set up dev $dev ; then
   echo "Error: cannot enable interface $dev." 1>&2
   exit 1
 fi
 if [ "$ipaddr" = "" ]; then exit 0; fi
 
-if ! arping -q -c 2 -w 3 -D -I $dev $ipaddr ; then
+if ! /sbin/arping -q -c 2 -w 3 -D -I $dev $ipaddr ; then
   echo "Error: some host already uses address $ipaddr on $dev." 1>&2
   exit 1
 fi
 
-if ! ip address add $pfx brd + dev $dev $label; then
+if ! /sbin/ip address add $pfx brd + dev $dev $label; then
   echo "Error: failed to add $pfx on $dev." 1>&2
   exit 1
 fi
 
-arping -q -A -c 1 -I $dev $ipaddr
+/sbin/arping -q -A -c 1 -I $dev $ipaddr
 noarp=$?
 ( sleep 2 ;
-  arping -q -U -c 1 -I $dev $ipaddr ) >& /dev/null </dev/null &
+  /sbin/arping -q -U -c 1 -I $dev $ipaddr ) >& /dev/null </dev/null &
 
-ip route add unreachable 224.0.0.0/24 >& /dev/null
-ip route add unreachable 255.255.255.255 >& /dev/null
-if [ `ip link ls $dev | grep -c MULTICAST` -ge 1 ]; then
-  ip route add 224.0.0.0/4 dev $dev scope global >& /dev/null
+/sbin/ip route add unreachable 224.0.0.0/24 >& /dev/null
+/sbin/ip route add unreachable 255.255.255.255 >& /dev/null
+if [ `/sbin/ip link ls $dev | grep -c MULTICAST` -ge 1 ]; then
+  /sbin/ip route add 224.0.0.0/4 dev $dev scope global >& /dev/null
 fi
 
 if [ $fwd -eq 0 ]; then
   if [ $noarp -eq 0 ]; then
-    ip ro append default dev $dev metric 30000 scope global
+    /sbin/ip ro append default dev $dev metric 30000 scope global
   elif [ "$peer" != "" ]; then
     if ping -q -c 2 -w 4 $peer ; then
-      ip ro append default via $peer dev $dev metric 30001
+      /sbin/ip ro append default via $peer dev $dev metric 30001
     fi
   fi
   RestartRDISC
diff -up iproute2-2.6.23/ip/routef~ iproute2-2.6.23/ip/routef
--- iproute2-2.6.23/ip/routef~	2007-10-17 00:27:42.000000000 +0300
+++ iproute2-2.6.23/ip/routef	2008-04-24 20:23:20.000000000 +0300
@@ -1,7 +1,7 @@
 #! /bin/sh
 
 if [ -z "$*" ] ; then
-	exec ip -4 ro flush  scope global  type unicast
+	exec /sbin/ip -4 ro flush  scope global  type unicast
 else
 	echo "Usage: routef"
 	echo

--------------000407070902030802060203--
