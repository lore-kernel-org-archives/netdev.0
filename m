From: Tim Gardner <timg@tpi.com>
Subject: CBQ quits when HZ=1000
Date: Thu, 16 Sep 2004 21:04:12 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095390252.3932.38.camel@tim.rtg.net>
Reply-To: timg@tpi.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-vAEaIfk+1qDMsT9RzRZi"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-vAEaIfk+1qDMsT9RzRZi
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I have a reasonably simple setup that shapes traffic to/from one address
on a bridge. When HZ=100, everything works great. When HZ=1000, CBQ
stops all traffic to this address forever as soon as throughput hits the
CBQ limit, 1Mbit in this case. See attached rules. Has anyone else
observed similar behavior?

The kernel is 2.4.22 on an SC1100 (x86).
PSCHED_CLOCK_SOURCE==PSCHED_JIFFIES

rtg
-- 
timg@tpi.com http://www.tpi.com
406-443-5357(MT) 503-601-0234(OR)

--=-vAEaIfk+1qDMsT9RzRZi
Content-Disposition: attachment; filename=cbqsetup
Content-Type: text/x-sh; name=cbqsetup; charset=UTF-8
Content-Transfer-Encoding: 7bit

#!/bin/sh
#
tc qdisc del dev eth0 root > /dev/null 2>&1
tc qdisc del dev eth1 root > /dev/null 2>&1
tc qdisc del dev eth0 ingress > /dev/null 2>&1
tc qdisc del dev eth1 ingress > /dev/null 2>&1
# ===============================
#download ********************************************************************
tc qdisc add dev eth0 root handle 1:0 cbq bandwidth 100Mbit avpkt 1024 cell 8 mpu 64
tc class add dev eth0 parent 1:0 classid 1:10 cbq bandwidth 100Mbit rate 100Mbit isolated weight 1Mbit prio 5 allot 1514 cell 8 maxburst 100 avpkt 1024 bounded mpu 64 minburst 2 minidle 20
# ===============================
tc qdisc add dev eth0 parent 1:10 handle 10: sfq perturb 5
# Client 1 Download **********************************************************
tc class add dev eth0 parent 1:10 classid 1:101 cbq bandwidth 100Mbit bounded isolated rate 1024Kbit weight 102Kbit prio 5 allot 1522 cell 8 maxburst 102 avpkt 1024 mpu 64 minburst 10 minidle 51
tc qdisc add dev eth0 parent 1:101 handle 101: sfq perturb 5
tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip dst 10.0.2.4 flowid 1:101
# ===============================
#upload **********************************************************************
tc qdisc add dev eth1 root handle 1:0 cbq bandwidth 7Mbit avpkt 1024 cell 8 mpu 64
tc class add dev eth1 parent 1:0 classid 1:10 cbq bandwidth 7Mbit rate 7Mbit isolated weight 0.7Mbit prio 5 allot 1514 cell 8 maxburst 100 avpkt 1024 bounded mpu 64 minburst 2 minidle 20
# ===============================
tc qdisc add dev eth1 parent 1:10 handle 10: sfq perturb 5
# Client 1 Upload ************************************************************
tc class add dev eth1 parent 1:10 classid 1:101 cbq bandwidth 7Mbit bounded isolated rate 1024Kbit weight 102Kbit prio 5 allot 1522 cell 8 maxburst 102 avpkt 1024 mpu 64 minburst 10 minidle 51
tc qdisc add dev eth1 parent 1:101 handle 101: sfq perturb 5
tc filter add dev eth1 parent 1:0 protocol ip prio 1 u32 match ip src 10.0.2.4 flowid 1:101

--=-vAEaIfk+1qDMsT9RzRZi--
