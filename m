From: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Subject: tc drop stats different between bond and slave interfaces
Date: Tue, 26 May 2015 01:35:08 -0400 (EDT)
Message-ID: <616929303.117745.1432618508227.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net>
Reply-To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.197]:64439 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbbEZFfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2015 01:35:09 -0400
Received: from oxuslxltgw05.lxa.perfora.net ([172.19.206.7]) by
 mrelay.perfora.net (mreueus002) with ESMTPSA (Nemesis) id
 0LvBum-1Z6i1W28eY-010Jmu for <netdev@vger.kernel.org>; Tue, 26 May 2015
 07:35:08 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I'm troubleshooting why tunneled performance is degrade on one of
our Internet connections.  Eric Dumazet was very helpful in some earlier issues.
We replace SFQ with fq_codel as the leaf qdisc on our HFSC classes and we no
longer have drops on the ifb interfaces.
 
However, now, we are seeing drops on the physical interfaces.  These are bonded
using 802.3ad.  I assume we are correct to execute the tc commands against the
bond interface.  However, I was surprised to see the drop statistics different
between the bond interface and the slave interfaces.
 
On one side, we see no errors on the bond interface and none on one slave but
quite a number on the other slave:

root@gwhq-2:~# tc -s qdisc show dev bond1
qdisc prio 2: root refcnt 17 bands 2 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
Sent 62053402767 bytes 41315883 pkt (dropped 0, overlimits 0 requeues 0)
backlog 0b 0p requeues 0
qdisc ingress ffff: parent ffff:fff1 ----------------
Sent 7344131114 bytes 11437274 pkt (dropped 0, overlimits 0 requeues 0)
backlog 0b 0p requeues 0

root@gwhq-2:~# tc -s qdisc show dev eth8
qdisc mq 0: root 
 Sent 62044791989 bytes 41310334 pkt (dropped 5700, overlimits 0 requeues 2488) 
 backlog 0b 0p requeues 2488 
qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 18848 bytes 152 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :5 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 62044765871 bytes 41310027 pkt (dropped 5700, overlimits 0 requeues 2487) 
 backlog 0b 0p requeues 2487 
qdisc pfifo_fast 0: parent :6 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 5754 bytes 137 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :7 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :8 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 1516 bytes 18 pkt (dropped 0, overlimits 0 requeues 1) 
 backlog 0b 0p requeues 1 

I was also surprised to see that, although we are using a prio qdisc on the
bond, the physical interface is showing pfifo_fast.

On the other side, we show drops on the bond but none on either physical:

qdisc prio 2: root refcnt 17 bands 2 priomap  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 Sent 7744366990 bytes 11438167 pkt (dropped 8, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc ingress ffff: parent ffff:fff1 ---------------- 
 Sent 59853360604 bytes 41423515 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 


root@lcppeppr-labc02:~# tc -s qdisc show dev eth7
qdisc mq 0: root 
 Sent 7744152748 bytes 11432931 pkt (dropped 0, overlimits 0 requeues 69) 
 backlog 0b 0p requeues 69 
qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 71342010 bytes 844547 pkt (dropped 0, overlimits 0 requeues 10) 
 backlog 0b 0p requeues 10 
qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 104260672 bytes 1298159 pkt (dropped 0, overlimits 0 requeues 4) 
 backlog 0b 0p requeues 4 
qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 58931075 bytes 708986 pkt (dropped 0, overlimits 0 requeues 1) 
 backlog 0b 0p requeues 1 
qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 7288852140 bytes 5677457 pkt (dropped 0, overlimits 0 requeues 14) 
 backlog 0b 0p requeues 14 
qdisc pfifo_fast 0: parent :5 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 42372833 bytes 506483 pkt (dropped 0, overlimits 0 requeues 1) 
 backlog 0b 0p requeues 1 
qdisc pfifo_fast 0: parent :6 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 36524401 bytes 395709 pkt (dropped 0, overlimits 0 requeues 30) 
 backlog 0b 0p requeues 30 
qdisc pfifo_fast 0: parent :7 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 121978491 bytes 1737068 pkt (dropped 0, overlimits 0 requeues 5) 
 backlog 0b 0p requeues 5 
qdisc pfifo_fast 0: parent :8 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 13336774 bytes 184341 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :9 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 2553156 bytes 38393 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :a bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 676410 bytes 7091 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :b bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo_fast 0: parent :c bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 3324786 bytes 34697 pkt (dropped 0, overlimits 0 requeues 4) 
 backlog 0b 0p requeues 4 

So why the difference and why the pfifo_fast qdiscs on the physical interfaces?
Thanks - John
