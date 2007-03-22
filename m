From: "Denys" <denys@visp.net.lb>
Subject: Re: iproute2-2.6.20-070313 bug ?
Date: Thu, 22 Mar 2007 14:46:03 +0200
Message-ID: <20070322124533.M79867@visp.net.lb>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:41003 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbXCVMqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 08:46:20 -0400
In-Reply-To: <46026717.9060909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Sir

Already i sent. I will copy here also

Normal "patched by me" iproute2 

/sbin/tc qdisc del dev ppp0 root 
/sbin/tc qdisc add dev ppp0 root handle 1: prio 
/sbin/tc qdisc add dev ppp0 parent 1:1 handle 2: tbf buffer 1024kb latency 
500ms rate 128kbit peakrate 256kbit minburst 16384 
/sbin/tc filter add dev ppp0 parent 1:0 protocol ip prio 10 u32 match ip dst 
0.0.0.0/0 flowid 2:1 

tc(patched) monitor output 
deleted qdisc prio 1: dev ppp0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1 
qdisc prio 1: dev ppp0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 
qdisc tbf 2: dev ppp0 parent 1:1 rate 128000bit burst 1024Kb peakrate 
256000bit minburst 16Kb lat 500.0ms 
filter dev ppp0 parent 1: protocol ip pref 10 u32 fh 800::800 order 2048 key 
ht 800 bkt 0 flowid 2:1 
 match 00000000/00000000 at 16 

VISP-Office ~ #cat /proc/net/psched 
00000001 00000001 000f4240 000003e8 

Now running tc2, it is "stock" version 

/sbin/tc2 qdisc del dev ppp0 root 
/sbin/tc2 qdisc add dev ppp0 root handle 1: prio 
/sbin/tc2 qdisc add dev ppp0 parent 1:1 handle 2: tbf buffer 1024kb latency 
500ms rate 128kbit peakrate 256kbit minburst 16384 
/sbin/tc2 filter add dev ppp0 parent 1:0 protocol ip prio 10 u32 match ip dst 
0.0.0.0/0 flowid 2:1 

Monitor output: 
deleted qdisc prio 1: dev ppp0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 
1 1 1 1 
qdisc prio 1: dev ppp0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 
qdisc tbf 2: dev ppp0 parent 1:1 rate 128000bit burst 1024Kb peakrate 
256000bit minburst 16Kb lat 500.0ms 
filter dev ppp0 parent 1: protocol ip pref 10 u32 fh 800::800 order 2048 key 
ht 800 bkt 0 flowid 2:1 
 match 00000000/00000000 at 16 

VISP-Office ~ #cat /proc/net/psched 
00000001 00000001 000f4240 000003e8 

Sure when i run tc2 - i see in stats, when it stopped (tc - normal, tc2 - 
buggy): 
VISP-Office ~ #tc -s qdisc show dev ppp0 
qdisc ingress ffff: ---------------- 
Sent 184893 bytes 2311 pkt (dropped 0, overlimits 0 requeues 0) 
rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc prio 1: bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 
Sent 7765 bytes 64 pkt (dropped 0, overlimits 0 requeues 0) 
rate 0bit 0pps backlog 0b 64p requeues 0 
qdisc tbf 2: parent 1:1 rate 128000bit burst 4294932937b peakrate 256000bit 
minburst 16Kb lat 4.2s 
Sent 7765 bytes 64 pkt (dropped 0, overlimits 64 requeues 0) 
rate 0bit 0pps backlog 0b 64p requeues 0 
VISP-Office ~ #tc2 -s qdisc show dev ppp0 
qdisc ingress ffff: ---------------- 
Sent 186423 bytes 2324 pkt (dropped 0, overlimits 0 requeues 0) 
rate 0bit 0pps backlog 0b 0p requeues 0 
qdisc prio 1: bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1 
Sent 8677 bytes 77 pkt (dropped 0, overlimits 0 requeues 0) 
rate 0bit 0pps backlog 0b 77p requeues 0 
qdisc tbf 2: parent 1:1 rate 128000bit burst 4294932937b peakrate 256000bit 
minburst 16Kb lat 4.2s 
Sent 8677 bytes 77 pkt (dropped 0, overlimits 77 requeues 0) 
rate 0bit 0pps backlog 0b 77p requeues 0 

I wish this will be enough information. Thanks for your help!



On Thu, 22 Mar 2007 12:23:03 +0100, Patrick McHardy wrote
> Denys wrote:
> > Possible i discovered bug, but maybe specific to my setup. 
> > 
> > In your sources (tc/tc_core.h) i notice 
> > #define TIME_UNITS_PER_SEC    1000000000 
> > When i change it to 
> > #define TIME_UNITS_PER_SEC      1000000.0 
> > (it was value before in sources) 
> > everythign works fine. Otherwise tbf not working at all, it is dropping 
all 
> > packets.
> > 
> > Did anyone test new iproute2 with tbf?
> 
> Yes, please send the commands you use.


--
Virtual ISP S.A.L.

