From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc drop stats different between bond and slave interfaces
Date: Mon, 25 May 2015 23:04:23 -0700
Message-ID: <1432620263.4060.229.camel@edumazet-glaptop2.roam.corp.google.com>
References: <616929303.117745.1432618508227.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34708 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbbEZGGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 02:06:06 -0400
Received: by pabru16 with SMTP id ru16so84942684pab.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 23:04:26 -0700 (PDT)
In-Reply-To: <616929303.117745.1432618508227.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 01:35 -0400, jsullivan@opensourcedevel.com wrote:
> Hello, all.  I'm troubleshooting why tunneled performance is degrade on one of
> our Internet connections.  Eric Dumazet was very helpful in some earlier issues.
> We replace SFQ with fq_codel as the leaf qdisc on our HFSC classes and we no
> longer have drops on the ifb interfaces.
>  
> However, now, we are seeing drops on the physical interfaces.  These are bonded
> using 802.3ad.  I assume we are correct to execute the tc commands against the
> bond interface.  However, I was surprised to see the drop statistics different
> between the bond interface and the slave interfaces.

On TX I presume ?

Each qdisc is totally independent. You could have drops on bonding, (and
obviously these dropped packets would not reach a slave)

You also could have drops on a slave. It all depends on how you setup
your qdisc(s)

Most people do not install qdisc on bond, unless they want to control
(shaping) exact bandwidth per class/group/ of traffic.

A typical setup is to use HTB on the bonding, and sch_fq on the slave(s)
to get TCP/pacing and per socket SO_MAX_PACING_RATE support.

>  
> On one side, we see no errors on the bond interface and none on one slave but
> quite a number on the other slave:
> 
> root@gwhq-2:~# tc -s qdisc show dev bond1
> qdisc prio 2: root refcnt 17 bands 2 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> Sent 62053402767 bytes 41315883 pkt (dropped 0, overlimits 0 requeues 0)
> backlog 0b 0p requeues 0
> qdisc ingress ffff: parent ffff:fff1 ----------------
> Sent 7344131114 bytes 11437274 pkt (dropped 0, overlimits 0 requeues 0)
> backlog 0b 0p requeues 0
> 
> root@gwhq-2:~# tc -s qdisc show dev eth8
> qdisc mq 0: root 
>  Sent 62044791989 bytes 41310334 pkt (dropped 5700, overlimits 0 requeues 2488) 
>  backlog 0b 0p requeues 2488 

> qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 18848 bytes 152 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :5 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 62044765871 bytes 41310027 pkt (dropped 5700, overlimits 0 requeues 2487) 
>  backlog 0b 0p requeues 2487 

It look all your packets do through a single queue/qdisc.

> qdisc pfifo_fast 0: parent :6 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 5754 bytes 137 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :7 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :8 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 1516 bytes 18 pkt (dropped 0, overlimits 0 requeues 1) 
>  backlog 0b 0p requeues 1 
> 
> I was also surprised to see that, although we are using a prio qdisc on the
> bond, the physical interface is showing pfifo_fast.

bond1 is a virtual device (normally no qdisc on it by default) , you
chose to install a qdisc on it, it did not automatically removed the
qdisc on the slave(s)

> 
> On the other side, we show drops on the bond but none on either physical:
> 
> qdisc prio 2: root refcnt 17 bands 2 priomap  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
>  Sent 7744366990 bytes 11438167 pkt (dropped 8, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc ingress ffff: parent ffff:fff1 ---------------- 
>  Sent 59853360604 bytes 41423515 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> 
> 

> root@lcppeppr-labc02:~# tc -s qdisc show dev eth7
> qdisc mq 0: root 
>  Sent 7744152748 bytes 11432931 pkt (dropped 0, overlimits 0 requeues 69) 
>  backlog 0b 0p requeues 69 
> qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 71342010 bytes 844547 pkt (dropped 0, overlimits 0 requeues 10) 
>  backlog 0b 0p requeues 10 
> qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 104260672 bytes 1298159 pkt (dropped 0, overlimits 0 requeues 4) 
>  backlog 0b 0p requeues 4 
> qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 58931075 bytes 708986 pkt (dropped 0, overlimits 0 requeues 1) 
>  backlog 0b 0p requeues 1 
> qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 7288852140 bytes 5677457 pkt (dropped 0, overlimits 0 requeues 14) 
>  backlog 0b 0p requeues 14 
> qdisc pfifo_fast 0: parent :5 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 42372833 bytes 506483 pkt (dropped 0, overlimits 0 requeues 1) 
>  backlog 0b 0p requeues 1 
> qdisc pfifo_fast 0: parent :6 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 36524401 bytes 395709 pkt (dropped 0, overlimits 0 requeues 30) 
>  backlog 0b 0p requeues 30 
> qdisc pfifo_fast 0: parent :7 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 121978491 bytes 1737068 pkt (dropped 0, overlimits 0 requeues 5) 
>  backlog 0b 0p requeues 5 
> qdisc pfifo_fast 0: parent :8 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 13336774 bytes 184341 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :9 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 2553156 bytes 38393 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :a bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 676410 bytes 7091 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :b bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 0p requeues 0 
> qdisc pfifo_fast 0: parent :c bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 3324786 bytes 34697 pkt (dropped 0, overlimits 0 requeues 4) 
>  backlog 0b 0p requeues 4 
> 
> So why the difference and why the pfifo_fast qdiscs on the physical interfaces?
> Thanks - John

On this host packets seem to be distributed among the 8 TX queues.
 
