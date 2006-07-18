From: jamal <hadi@cyberus.ca>
Subject: [IPROUTE2]: update documentation on mirred and IFB
Date: Tue, 18 Jul 2006 08:56:40 -0400
Message-ID: <1153227400.5283.62.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ZW3aeiy5ZZVNB2rSrKOL"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.znyx.com ([208.2.156.141]:36363 "EHLO mailhub.znyx.com")
	by vger.kernel.org with ESMTP id S932188AbWGRM44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 08:56:56 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ZW3aeiy5ZZVNB2rSrKOL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

About two more or so to complete these..

cheers,
jamal



--=-ZW3aeiy5ZZVNB2rSrKOL
Content-Disposition: attachment; filename=act_help_p2
Content-Type: text/plain; name=act_help_p2; charset=UTF-8
Content-Transfer-Encoding: 7bit

Clean up some documentation on mirred and IFB

---
commit a067bda2c7c9972ad77ac174830a245896d18897
tree a1430a246e5607ec01b31795dd5b12b2e455f5d4
parent a31787bf2939fd9eb11396e3765c78c4d1e744a1
author Jamal Hadi Salim <hadi@cyberus.ca> Tue, 18 Jul 2006 07:45:13 -0400
committer Jamal Hadi Salim <hadi@jzny2.(none)> Tue, 18 Jul 2006 07:45:13 -0400

 doc/actions/dummy-README |  155 ----------------------------------------------
 doc/actions/ifb-README   |   48 +++-----------
 doc/actions/mirred-usage |   88 ++++++++++++++++++++++++--
 3 files changed, 90 insertions(+), 201 deletions(-)

diff --git a/doc/actions/dummy-README b/doc/actions/dummy-README
deleted file mode 100644
index 3ef9f21..0000000
--- a/doc/actions/dummy-README
+++ /dev/null
@@ -1,155 +0,0 @@
-
-Advantage over current IMQ; cleaner in particular in in SMP;
-with a _lot_ less code.
-Old Dummy device functionality is preserved while new one only
-kicks in if you use actions.
-
-IMQ USES
---------
-As far as i know the reasons listed below is why people use IMQ. 
-It would be nice to know of anything else that i missed.
-
-1) qdiscs/policies that are per device as opposed to system wide.
-IMQ allows for sharing.
-
-2) Allows for queueing incoming traffic for shaping instead of
-dropping. I am not aware of any study that shows policing is 
-worse than shaping in achieving the end goal of rate control.
-I would be interested if anyone is experimenting.
-
-3) Very interesting use: if you are serving p2p you may wanna give 
-preference to your own localy originated traffic (when responses come back)
-vs someone using your system to do bittorent. So QoSing based on state
-comes in as the solution. What people did to achive this was stick
-the IMQ somewhere prelocal hook.
-I think this is a pretty neat feature to have in Linux in general.
-(i.e not just for IMQ).
-But i wont go back to putting netfilter hooks in the device to satisfy
-this.  I also dont think its worth it hacking dummy some more to be 
-aware of say L3 info and play ip rule tricks to achieve this.
---> Instead the plan is to have a contrack related action. This action will
-selectively either query/create contrack state on incoming packets. 
-Packets could then be redirected to dummy based on what happens -> eg 
-on incoming packets; if we find they are of known state we could send to 
-a different queue than one which didnt have existing state. This
-all however is dependent on whatever rules the admin enters.
-
-At the moment this function does not exist yet. I have decided instead
-of sitting on the patch to release it and then if theres pressure i will
-add this feature.
-
-What you can do with dummy currently with actions
---------------------------------------------------
-
-Lets say you are policing packets from alias 192.168.200.200/32
-you dont want those to exceed 100kbps going out.
-
-tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
-match ip src 192.168.200.200/32 flowid 1:2 \
-action police rate 100kbit burst 90k drop
-
-If you run tcpdump on eth0 you will see all packets going out
-with src 192.168.200.200/32 dropped or not
-Extend the rule a little to see only the ones that made it out:
-
-tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
-match ip src 192.168.200.200/32 flowid 1:2 \
-action police rate 10kbit burst 90k drop \
-action mirred egress mirror dev dummy0 
-
-Now fire tcpdump on dummy0 to see only those packets ..
-tcpdump -n -i dummy0 -x -e -t 
-
-Essentially a good debugging/logging interface.
-
-If you replace mirror with redirect, those packets will be
-blackholed and will never make it out. This redirect behavior
-changes with new patch (but not the mirror). 
-
-What you can do with the patch to provide functionality
-that most people use IMQ for below:
-
---------
-export TC="/sbin/tc"
-
-$TC qdisc add dev dummy0 root handle 1: prio 
-$TC qdisc add dev dummy0 parent 1:1 handle 10: sfq
-$TC qdisc add dev dummy0 parent 1:2 handle 20: tbf rate 20kbit buffer 1600 limit 3000
-$TC qdisc add dev dummy0 parent 1:3 handle 30: sfq                                
-$TC filter add dev dummy0 protocol ip pref 1 parent 1: handle 1 fw classid 1:1
-$TC filter add dev dummy0 protocol ip pref 2 parent 1: handle 2 fw classid 1:2
-
-ifconfig dummy0 up
-
-$TC qdisc add dev eth0 ingress
-
-# redirect all IP packets arriving in eth0 to dummy0 
-# use mark 1 --> puts them onto class 1:1
-$TC filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
-match u32 0 0 flowid 1:1 \
-action ipt -j MARK --set-mark 1 \
-action mirred egress redirect dev dummy0
-
---------
-
-
-Run A Little test:
-
-from another machine ping so that you have packets going into the box:
------
-[root@jzny action-tests]# ping 10.22
-PING 10.22 (10.0.0.22): 56 data bytes
-64 bytes from 10.0.0.22: icmp_seq=0 ttl=64 time=2.8 ms
-64 bytes from 10.0.0.22: icmp_seq=1 ttl=64 time=0.6 ms
-64 bytes from 10.0.0.22: icmp_seq=2 ttl=64 time=0.6 ms
-
---- 10.22 ping statistics ---
-3 packets transmitted, 3 packets received, 0% packet loss
-round-trip min/avg/max = 0.6/1.3/2.8 ms
-[root@jzny action-tests]# 
------
-Now look at some stats:
-
----
-[root@jmandrake]:~# $TC -s filter show parent ffff: dev eth0
-filter protocol ip pref 10 u32 
-filter protocol ip pref 10 u32 fh 800: ht divisor 1 
-filter protocol ip pref 10 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1 
-  match 00000000/00000000 at 0
-        action order 1: tablename: mangle  hook: NF_IP_PRE_ROUTING 
-        target MARK set 0x1  
-        index 1 ref 1 bind 1 installed 4195sec  used 27sec 
-         Sent 252 bytes 3 pkts (dropped 0, overlimits 0) 
-
-        action order 2: mirred (Egress Redirect to device dummy0) stolen
-        index 1 ref 1 bind 1 installed 165 sec used 27 sec
-         Sent 252 bytes 3 pkts (dropped 0, overlimits 0) 
-
-[root@jmandrake]:~# $TC -s qdisc
-qdisc sfq 30: dev dummy0 limit 128p quantum 1514b 
- Sent 0 bytes 0 pkts (dropped 0, overlimits 0) 
-qdisc tbf 20: dev dummy0 rate 20Kbit burst 1575b lat 2147.5s 
- Sent 210 bytes 3 pkts (dropped 0, overlimits 0) 
-qdisc sfq 10: dev dummy0 limit 128p quantum 1514b 
- Sent 294 bytes 3 pkts (dropped 0, overlimits 0) 
-qdisc prio 1: dev dummy0 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
- Sent 504 bytes 6 pkts (dropped 0, overlimits 0) 
-qdisc ingress ffff: dev eth0 ---------------- 
- Sent 308 bytes 5 pkts (dropped 0, overlimits 0) 
-
-[root@jmandrake]:~# ifconfig dummy0
-dummy0    Link encap:Ethernet  HWaddr 00:00:00:00:00:00  
-          inet6 addr: fe80::200:ff:fe00:0/64 Scope:Link
-          UP BROADCAST RUNNING NOARP  MTU:1500  Metric:1
-          RX packets:6 errors:0 dropped:3 overruns:0 frame:0
-          TX packets:3 errors:0 dropped:0 overruns:0 carrier:0
-          collisions:0 txqueuelen:32 
-          RX bytes:504 (504.0 b)  TX bytes:252 (252.0 b)
------
-
-Dummy continues to behave like it always did.
-You send it any packet not originating from the actions it will drop them.
-[In this case the three dropped packets were ipv6 ndisc].
-
-cheers,
-jamal
diff --git a/doc/actions/ifb-README b/doc/actions/ifb-README
index 02581a8..3d01179 100644
--- a/doc/actions/ifb-README
+++ b/doc/actions/ifb-README
@@ -1,16 +1,16 @@
 
+IFB is intended to replace IMQ.
 Advantage over current IMQ; cleaner in particular in in SMP;
 with a _lot_ less code.
-Old Dummy device functionality is preserved while new one only
-kicks in if you use actions.
 
-IMQ USES
---------
+Known IMQ/IFB USES
+------------------
+
 As far as i know the reasons listed below is why people use IMQ. 
 It would be nice to know of anything else that i missed.
 
 1) qdiscs/policies that are per device as opposed to system wide.
-IMQ allows for sharing.
+IFB allows for sharing.
 
 2) Allows for queueing incoming traffic for shaping instead of
 dropping. I am not aware of any study that shows policing is 
@@ -34,40 +34,11 @@ on incoming packets; if we find they are
 a different queue than one which didnt have existing state. This
 all however is dependent on whatever rules the admin enters.
 
-At the moment this function does not exist yet. I have decided instead
-of sitting on the patch to release it and then if theres pressure i will
-add this feature.
-
-What you can do with ifb currently with actions
---------------------------------------------------
-
-Lets say you are policing packets from alias 192.168.200.200/32
-you dont want those to exceed 100kbps going out.
-
-tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
-match ip src 192.168.200.200/32 flowid 1:2 \
-action police rate 100kbit burst 90k drop
-
-If you run tcpdump on eth0 you will see all packets going out
-with src 192.168.200.200/32 dropped or not
-Extend the rule a little to see only the ones that made it out:
-
-tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
-match ip src 192.168.200.200/32 flowid 1:2 \
-action police rate 10kbit burst 90k drop \
-action mirred egress mirror dev ifb0 
-
-Now fire tcpdump on ifb0 to see only those packets ..
-tcpdump -n -i ifb0 -x -e -t 
-
-Essentially a good debugging/logging interface.
-
-If you replace mirror with redirect, those packets will be
-blackholed and will never make it out. This redirect behavior
-changes with new patch (but not the mirror). 
+At the moment this 3rd function does not exist yet. I have decided that
+instead of sitting on the patch for another year, to release it and then 
+if theres pressure i will add this feature.
 
-What you can do with the patch to provide functionality
-that most people use IMQ for below:
+An example, to provide functionality that most people use IMQ for below:
 
 --------
 export TC="/sbin/tc"
@@ -147,7 +118,6 @@ ifb0    Link encap:Ethernet  HWaddr 00:0
           RX bytes:504 (504.0 b)  TX bytes:252 (252.0 b)
 -----
 
-Dummy continues to behave like it always did.
 You send it any packet not originating from the actions it will drop them.
 [In this case the three dropped packets were ipv6 ndisc].
 
diff --git a/doc/actions/mirred-usage b/doc/actions/mirred-usage
index aa942e5..03ea9d0 100644
--- a/doc/actions/mirred-usage
+++ b/doc/actions/mirred-usage
@@ -12,12 +12,59 @@ ACTION := <mirror | redirect>
 INDEX is the specific policy instance id
 DEVICENAME is the devicename
 
+Direction Ingress is not supported at the moment. It will be in the
+future as well as mirror/redirecting to a socket.
 
 Mirroring essentially takes a copy of the packet whereas redirecting
 steals the packet and redirects to specified destination.
 
+What NOT to do if you dont want your machine to crash:
+------------------------------------------------------
+
+Do not create loops! 
+Loops are not hard to create in the egress qdiscs.
+
+Here are simple rules to follow if you dont want to get
+hurt:
+A) Do not have the same packet go to same netdevice twice
+in a single graph of policies. Your machine will just hang!
+This is design intent _not a bug_ to teach you some lessons. 
+
+In the future if there are easy ways to do this in the kernel
+without affecting other packets not interested in this feature
+I will add them. At the moment that is not clear.
+
+Some examples of bad things to do:
+1) redirecting eth0 to eth0
+2) eth0->eth1-> eth0
+3) eth0->lo-> eth1-> eth0
+
+B) Do not redirect from one IFB device to another.
+Remember that IFB is a very specialized case of packet redirecting
+device. Instead of redirecting it puts packets at the exact spot
+on the stack it found them from.
+This bad policy will actually not crash your machine but your 
+packets will all be dropped (this is much simpler to detect
+and resolve and is only affecting users of ifb as opposed to the
+whole stack).
+
+In the case of A) the problem has to do with a recursive contention
+for the devices queue lock and in the second case for the transmit lock.
+
 Some examples:
-Host A is hooked  up to us on eth0
+------------
+
+1) Mirror all packets arriving on eth0 to be sent out on eth1.
+You may have a sniffer or some accounting box hooked up on eth1.
+ 
+tc qdisc add dev lo eth0
+tc filter add dev eth0 parent ffff: protocol ip prio 10 u32 \
+match u32 0 0 flowid 1:2 action mirred egress mirror dev eth1
+
+If you replace "mirror" with "redirect" then not a copy but rather
+the original packet is sent to eth1.
+
+2) Host A is hooked  up to us on eth0
 
 tc qdisc add dev lo ingress
 # redirect all packets arriving on ingress of lo to eth0
@@ -28,7 +75,7 @@ On host A start a tcpdump on interface c
 
 on our host ping -c 2 127.0.0.1
 
-Ping would fail sinc all packets are heading out eth0
+Ping would fail since all packets are heading out eth0
 tcpudmp on host A would show them
 
 if you substitute the redirect with mirror above as in:
@@ -38,7 +85,7 @@ match u32 0 0 flowid 1:2 action mirred e
 Then you should see the packets on both host A and the local
 stack (i.e ping would work).
 
-Even more funky example:
+3) Even more funky example:
 
 #
 #allow 1 out 10 packets to randomly make it to the 
@@ -49,11 +96,10 @@ match u32 0 0 flowid 1:2 \
 action drop random determ ok 10\
 action mirred egress mirror dev eth0
 
-------
-Example 2:
+4)
 # for packets coming from 10.0.0.9:
-#Redirect packets on egress (to ISP A) if you exceed a certain rate
-# to eth1 (to ISP B) if you exceed a certain rate
+#Redirect packets on egress, if exceeding a 100Kbps rate,
+# to eth1 
 #
 
 tc qdisc add dev eth0 handle 1:0 root prio
@@ -69,3 +115,31 @@ A more interesting example is when you m
 so you could tcpdump them (dummy by defaults drops all packets it sees).
 This is a very useful debug feature.
 
+Lets say you are policing packets from alias 192.168.200.200/32
+you dont want those to exceed 100kbps going out.
+
+tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
+match ip src 192.168.200.200/32 flowid 1:2 \
+action police rate 100kbit burst 90k drop
+
+If you run tcpdump on eth0 you will see all packets going out
+with src 192.168.200.200/32 dropped or not
+Extend the rule a little to see only the ones that made it out:
+
+tc filter add dev eth0 parent 1: protocol ip prio 10 u32 \
+match ip src 192.168.200.200/32 flowid 1:2 \
+action police rate 10kbit burst 90k drop \
+action mirred egress mirror dev dummy0
+
+Now fire tcpdump on dummy0 to see only those packets ..
+tcpdump -n -i dummy0 -x -e -t
+
+Essentially a good debugging/logging interface (sort of like
+BSDs speacialized log device does without needing one).
+
+If you replace mirror with redirect, those packets will be
+blackholed and will never make it out. This redirect behavior
+changes with new patch (but not the mirror).
+
+cheers,
+jamal

--=-ZW3aeiy5ZZVNB2rSrKOL--

