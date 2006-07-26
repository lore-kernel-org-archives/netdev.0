From: Jamal Hadi Salim <hadi@znyx.com>
Subject: [IPROUTE2]:  documentation bug fix on mirred
Date: Wed, 26 Jul 2006 07:52:09 -0400
Message-ID: <1153914729.5202.21.camel@jzny2>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-7iej9A0SYVK6tRw8TJOL"
Cc: netdev@vger.kernel.org, lists@andyfurniss.entadsl.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.znyx.com ([208.2.156.141]:4620 "EHLO mailhub.znyx.com")
	by vger.kernel.org with ESMTP id S1030242AbWGZLwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2006 07:52:30 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-7iej9A0SYVK6tRw8TJOL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Stephen,

Heres another on top of the others i sent. If you get the time, can
update your git tree with these patches?
If you are planning to make a release soon, please ping me - I have at
least one more patch that i need to work on.

cheers,
jamal


--=-7iej9A0SYVK6tRw8TJOL
Content-Disposition: attachment; filename=ipr-doc-mirred-p
Content-Type: text/plain; name=ipr-doc-mirred-p; charset=UTF-8
Content-Transfer-Encoding: 7bit

Update mirred usage to fix a bug noticed by
Andy Furniss <lists@andyfurniss.entadsl.com>
Also make it a little more readable.

---
commit e2e0fac73a39bc6878f93cd7698f4c823ef85546
tree cfdad9a98fa1925237128b307d8ddd77b86a09a7
parent a067bda2c7c9972ad77ac174830a245896d18897
author Jamal Hadi Salim <hadi@cyberus.ca> Wed, 26 Jul 2006 07:45:25 -0400
committer Jamal Hadi Salim <hadi@jzny2.(none)> Wed, 26 Jul 2006 07:45:25 -0400

 doc/actions/mirred-usage |   59 ++++++++++++++++++++++++++++++----------------
 1 files changed, 39 insertions(+), 20 deletions(-)

diff --git a/doc/actions/mirred-usage b/doc/actions/mirred-usage
index 03ea9d0..2622c43 100644
--- a/doc/actions/mirred-usage
+++ b/doc/actions/mirred-usage
@@ -1,7 +1,11 @@
 
 Very funky action. I do plan to add to a few more things to it
 This is the basic stuff. Idea borrowed from the way ethernet switches
-mirror and redirect packets.
+mirror and redirect packets. The main difference with say a vannila
+ethernet switch is that you can use u32 classifier to select a
+flow to be mirrored. High end switches typically can select based
+on more than just a port (eg a 5 tuple classifier). They may also be
+capable of redirecting.
 
 Usage: 
 
@@ -12,11 +16,15 @@ ACTION := <mirror | redirect>
 INDEX is the specific policy instance id
 DEVICENAME is the devicename
 
-Direction Ingress is not supported at the moment. It will be in the
-future as well as mirror/redirecting to a socket.
+Direction:
+- Ingress is not supported at the moment. It will be in the
+future as well as mirror/redirecting to a socket. 
 
-Mirroring essentially takes a copy of the packet whereas redirecting
-steals the packet and redirects to specified destination.
+Action:
+- Mirror takes a copy of the packet and sends it to specified
+dev ("port" in ethernet switch/bridging terminology)
+- redirect
+steals the packet and redirects to specified destination dev.
 
 What NOT to do if you dont want your machine to crash:
 ------------------------------------------------------
@@ -34,7 +42,7 @@ In the future if there are easy ways to 
 without affecting other packets not interested in this feature
 I will add them. At the moment that is not clear.
 
-Some examples of bad things to do:
+Some examples of bad things NOT to do:
 1) redirecting eth0 to eth0
 2) eth0->eth1-> eth0
 3) eth0->lo-> eth1-> eth0
@@ -43,7 +51,7 @@ B) Do not redirect from one IFB device t
 Remember that IFB is a very specialized case of packet redirecting
 device. Instead of redirecting it puts packets at the exact spot
 on the stack it found them from.
-This bad policy will actually not crash your machine but your 
+Redirecting from ifbX->ifbY will actually not crash your machine but your 
 packets will all be dropped (this is much simpler to detect
 and resolve and is only affecting users of ifb as opposed to the
 whole stack).
@@ -52,24 +60,28 @@ In the case of A) the problem has to do 
 for the devices queue lock and in the second case for the transmit lock.
 
 Some examples:
-------------
+-------------
 
 1) Mirror all packets arriving on eth0 to be sent out on eth1.
 You may have a sniffer or some accounting box hooked up on eth1.
  
-tc qdisc add dev lo eth0
+---
+tc qdisc add dev eth0 ingress
 tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
 match u32 0 0 flowid 1:2 action mirred egress mirror dev eth1
+---
 
 If you replace "mirror" with "redirect" then not a copy but rather
 the original packet is sent to eth1.
 
 2) Host A is hooked  up to us on eth0
 
-tc qdisc add dev lo ingress
 # redirect all packets arriving on ingress of lo to eth0
+---
+tc qdisc add dev lo ingress
 tc filter add dev lo parent ffff: protocol ip prio 10 u32 \
 match u32 0 0 flowid 1:2 action mirred egress redirect dev eth0
+---
 
 On host A start a tcpdump on interface connecting to us.
 
@@ -88,27 +100,28 @@ stack (i.e ping would work).
 3) Even more funky example:
 
 #
-#allow 1 out 10 packets to randomly make it to the 
+#allow 1 out 10 packets on ingress of lo to randomly make it to the 
 # host A (Randomness uses the netrand generator)
 #
+---
 tc filter add dev lo parent ffff: protocol ip prio 10 u32 \
 match u32 0 0 flowid 1:2 \
 action drop random determ ok 10\
 action mirred egress mirror dev eth0
+---
 
 4)
-# for packets coming from 10.0.0.9:
-#Redirect packets on egress, if exceeding a 100Kbps rate,
-# to eth1 
+# for packets from 10.0.0.9 going out on eth0 (could be local 
+# IP or something # we are forwarding) - 
+# if exceeding a 100Kbps rate, then redirect to eth1 
 #
 
+---
 tc qdisc add dev eth0 handle 1:0 root prio
-
 tc filter add dev eth0 parent 1:0 protocol ip prio 6 u32 \
 match ip src 10.0.0.9/32 flowid 1:16 \
 action police rate 100kbit burst 90k ok \
 action mirred egress mirror dev eth1
-
 ---
 
 A more interesting example is when you mirror flows to a dummy device
@@ -118,18 +131,25 @@ This is a very useful debug feature.
 Lets say you are policing packets from alias 192.168.200.200/32
 you dont want those to exceed 100kbps going out.
 
+---
+tc qdisc add dev eth0 handle 1:0 root prio
 tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
 match ip src 192.168.200.200/32 flowid 1:2 \
 action police rate 100kbit burst 90k drop
+---
 
 If you run tcpdump on eth0 you will see all packets going out
-with src 192.168.200.200/32 dropped or not
-Extend the rule a little to see only the ones that made it out:
+with src 192.168.200.200/32 dropped or not (since tcpdump shows
+all packets being egressed).
+Extend the rule a little to see only the packets making it out.
 
+---
+tc qdisc add dev eth0 handle 1:0 root prio
 tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
 match ip src 192.168.200.200/32 flowid 1:2 \
 action police rate 10kbit burst 90k drop \
 action mirred egress mirror dev dummy0
+---
 
 Now fire tcpdump on dummy0 to see only those packets ..
 tcpdump -n -i dummy0 -x -e -t
@@ -138,8 +158,7 @@ Essentially a good debugging/logging int
 BSDs speacialized log device does without needing one).
 
 If you replace mirror with redirect, those packets will be
-blackholed and will never make it out. This redirect behavior
-changes with new patch (but not the mirror).
+blackholed and will never make it out. 
 
 cheers,
 jamal

--=-7iej9A0SYVK6tRw8TJOL--

