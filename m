From: Sami Farin <safari-kernel@safari.iki.fi>
Subject: Linux 2.6.27.5 / SFQ/HTB scheduling problems
Date: Tue, 11 Nov 2008 17:17:22 +0200
Message-ID: <20081111151722.2fxd73nd67slyqac@m.safari.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux Networking Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-out.inet.fi ([195.156.147.13]:39273 "EHLO kirsi2.inet.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755531AbYKKPR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 10:17:26 -0500
Received: from safari.iki.fi (80.223.84.180) by kirsi2.inet.fi (8.5.014)
        id 48FC5B890120EB67 for netdev@vger.kernel.org; Tue, 11 Nov 2008 17:17:23 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

idle:
--- 84.250.192.1 ping statistics ---
50 packets transmitted, 50 received, 0% packet loss, time 1218ms
rtt min/avg/max/mdev = 22.293/24.351/41.672/3.776 ms, pipe 2, ipg/ewma 24.876/24.431 ms

(also similar results with Linux 2.6.25.17 when uploading.)
Bother kernels have e1000-8.0.6.

But with Linux 2.6.27.5, only uploading a 3 MiB file using TCP/IP+HTTP,
I get over one second latencies when pinging etc, whereas with
2.6.25.17 I got about 25 ms.

However, when upstream bandwidth is taken by only DNS packets
(maybe 70-100 bytes each), latencies are just fine?!

This is the simplified init script:

--- 8< ---
SENDRATE="460Kbit"
PATH=/sbin:/usr/bin:/usr/sbin
DEV="eth0"
ATM="overhead 12 linklayer atm"
QDISC="sfq"

tc qdisc del dev $DEV root
tc qdisc del dev $DEV ingress
tc qdisc add dev $DEV root handle 1: htb default 19 r2q 1

# :12 is TCP ACKs, :15 is ICMP
tc class add dev $DEV parent 1: classid 1:1 htb rate $SENDRATE ceil $SENDRATE $ATM
tc class add dev $DEV parent 1:1  classid 1:12 htb rate  60Kbit prio 0 ceil 150Kbit $ATM
tc class add dev $DEV parent 1:1  classid 1:15 htb rate  30Kbit prio 0 ceil 150Kbit $ATM
tc class add dev $DEV parent 1:1  classid 1:19 htb rate 370Kbit prio 3 ceil $SENDRATE $ATM
tc qdisc add dev $DEV parent 1:12 handle 12: $QDISC
tc qdisc add dev $DEV parent 1:15 handle 15: $QDISC
tc qdisc add dev $DEV parent 1:19 handle 19: $QDISC
--- 8< ---

idle:
(why overhead is 0b?  linklayer not shown?  iproute2 is the latest git.)

class htb 1:19 parent 1:1 leaf 19: prio 3 quantum 46250 rate 370000bit ceil 460000bit burst 1599b/8 mpu 0b overhead 0b cburst 1599b/8 mpu 0b overhead 0b level 0 
 Sent 108 bytes 2 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 2 borrowed: 0 giants: 0
 tokens: 31546 ctokens: 25374

class htb 1:1 root rate 460000bit ceil 460000bit burst 1599b/8 mpu 0b overhead 0b cburst 1599b/8 mpu 0b overhead 0b level 7 
 Sent 108 bytes 2 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 0 borrowed: 0 giants: 0
 tokens: 25374 ctokens: 25374

class htb 1:12 parent 1:1 leaf 12: prio 0 quantum 7500 rate 60000bit ceil 150000bit burst 1599b/8 mpu 0b overhead 0b cburst 1599b/8 mpu 0b overhead 0b level 0 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 0 borrowed: 0 giants: 0
 tokens: 208333 ctokens: 83333

class htb 1:15 parent 1:1 leaf 15: prio 0 quantum 3750 rate 30000bit ceil 150000bit burst 1599b/8 mpu 0b overhead 0b cburst 1599b/8 mpu 0b overhead 0b level 0 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 0 borrowed: 0 giants: 0
 tokens: 416666 ctokens: 83333


qdisc htb 1: root r2q 1 default 19 direct_packets_stat 0 ver 3.17
 Sent 465 bytes 7 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc sfq 12: parent 1:12 limit 127p quantum 1486b flows 127/1024 
 Sent 66 bytes 1 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc sfq 15: parent 1:15 limit 127p quantum 1486b flows 127/1024 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc sfq 19: parent 1:19 limit 127p quantum 1486b flows 127/1024 
 Sent 399 bytes 6 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 


--------
uploading:

where did those "class sfq 19:XXX" come from?

--- 84.250.192.1 ping statistics ---
20 packets transmitted, 20 received, 0% packet loss, time 13656ms
rtt min/avg/max/mdev = 24.705/627.912/1156.690/366.291 ms, pipe 2, ipg/ewma 718.754/739.444 ms


class htb 1:19 parent 1:1 leaf 19: prio 3 quantum 46250 rate 370000bit ceil 460000bit burst 1599b/8 mpu 0b overhead 0b cburst 1599b/8 mpu 0b overhead 0b level 0 
 Sent 4094513 bytes 2993 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 408744bit 37pps backlog 0b 41p requeues 0 
 lended: 214 borrowed: 99 giants: 0
 tokens: -1504233 ctokens: -1235857

class htb 1:1 root rate 460000bit ceil 460000bit burst 1599b/8 mpu 0b overhead 0b cburst 1599b/8 mpu 0b overhead 0b level 7 
 Sent 3991086 bytes 4220 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 429992bit 39pps backlog 0b 0p requeues 0 
 lended: 99 borrowed: 0 giants: 0
 tokens: -1049505 ctokens: -1049505

class htb 1:12 parent 1:1 leaf 12: prio 0 quantum 7500 rate 60000bit ceil 150000bit burst 1599b/8 mpu 0b overhead 0b cburst 1599b/8 mpu 0b overhead 0b level 0 
 Sent 92980 bytes 1356 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 120bit 0pps backlog 0b 0p requeues 0 
 lended: 1356 borrowed: 0 giants: 0
 tokens: 194532 ctokens: 77813

class htb 1:15 parent 1:1 leaf 15: prio 0 quantum 3750 rate 30000bit ceil 150000bit burst 1599b/8 mpu 0b overhead 0b cburst 1599b/8 mpu 0b overhead 0b level 0 
 Sent 4834 bytes 47 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 88bit 0pps backlog 0b 0p requeues 0 
 lended: 47 borrowed: 0 giants: 0
 tokens: 336369 ctokens: 69286

class sfq 19:f parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:11 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 0 

class sfq 19:12 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:c2 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:c9 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot 0 

class sfq 19:ec parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:106 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:19a parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:19d parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:1d3 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:249 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 0 

class sfq 19:281 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:2a1 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:2ce parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot 1486 

class sfq 19:2f6 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 0 

class sfq 19:31a parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 2p requeues 0 
 allot 0 

class sfq 19:324 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 4p requeues 0 
 allot 0 

class sfq 19:34a parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:36a parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:372 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:3ae parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 7p requeues 0 
 allot 4828 

class sfq 19:3ed parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 

class sfq 19:3f5 parent 19: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 1p requeues 0 
 allot 0 


qdisc htb 1: root r2q 1 default 19 direct_packets_stat 0 ver 3.17
 Sent 4456655 bytes 4605 pkt (dropped 0, overlimits 1029 requeues 0) 
 rate 0bit 0pps backlog 0b 60p requeues 0 
qdisc sfq 12: parent 1:12 limit 127p quantum 1486b flows 127/1024 
 Sent 92980 bytes 1356 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc sfq 15: parent 1:15 limit 127p quantum 1486b flows 127/1024 
 Sent 4834 bytes 47 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc sfq 19: parent 1:19 limit 127p quantum 1486b flows 127/1024 
 Sent 4358841 bytes 383 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 137239b 60p requeues 0 

(testmy.net speed test reports 28 KiB/s)

----------

STILL, if I limit bandwidth to 256Kbit (half of the link's capacity):

--- 84.250.192.1 ping statistics ---
20 packets transmitted, 20 received, 0% packet loss, time 9896ms
rtt min/avg/max/mdev = 22.259/396.306/1095.908/407.372 ms, pipe 3, ipg/ewma 520.890/432.970 ms

(testmy.net reports 16 KiB/s)

-- 
"None are so old as those who have outlived enthusiasm."
 - Henry David Thoreau

