From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Packet timestamps (was: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20)
Date: Tue, 6 Mar 2007 16:25:51 +0300
Message-ID: <20070306132551.GB8412@tentacle.sectorb.msk.ru>
References: <200609181850.22851.ak@suse.de> <20060919.124751.24100694.davem@davemloft.net> <20060922153517.GB24866@ms2.inr.ac.ru> <200609221743.40053.ak@suse.de> <4514147D.5040803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Andi Kleen <ak@suse.de>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>, hawk@diku.dk,
	harry@atmos.washington.edu, linux-kernel@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tentacle.s2s.msu.ru ([193.232.119.109]:54519 "EHLO
	tentacle.sectorb.msk.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030584AbXCFNZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 08:25:54 -0500
Content-Disposition: inline
In-Reply-To: <4514147D.5040803@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 09:51:09AM -0700, Rick Jones wrote:
> >That came from named. It opens lots of sockets with SIOCGSTAMP.
> >No idea what it needs that many for.
> 
> IIRC ISC BIND named opens a socket for each IP it finds on the system. 
> Presumeably in this way it "knows" implicitly the destination IP without 
> using platform-specific recvfrom/whatever extensions and gets some 
> additional parallelism in the stack on SMP systems.
> 
> Why it needs/wants the timestamps I've no idea, I don't think it gets 
> them that way on all platforms.  I suppose the next time I do some named 
> benchmarking I can try to take a closer look in the source.
> 

Returning to the discussion about packet timestamps, I just
use the following patch now:

diff -ur ../linux-2.6.20.1/include/linux/sysctl.h linux-2.6.20.1-ts/include/linux/sysctl.h
--- ../linux-2.6.20.1/include/linux/sysctl.h	2007-02-20 09:34:32.000000000 +0300
+++ linux-2.6.20.1-ts/include/linux/sysctl.h	2007-03-04 19:10:36.000000000 +0300
@@ -280,6 +280,7 @@
 	NET_CORE_BUDGET=19,
 	NET_CORE_AEVENT_ETIME=20,
 	NET_CORE_AEVENT_RSEQTH=21,
+	NET_CORE_ACCURATE_TIMESTAMPS=99,
 };
 
 /* /proc/sys/net/ethernet */
diff -ur ../linux-2.6.20.1/net/core/dev.c linux-2.6.20.1-ts/net/core/dev.c
--- ../linux-2.6.20.1/net/core/dev.c	2007-02-20 09:34:32.000000000 +0300
+++ linux-2.6.20.1-ts/net/core/dev.c	2007-03-04 19:09:44.000000000 +0300
@@ -1043,9 +1043,11 @@
 }
 EXPORT_SYMBOL(__net_timestamp);
 
+int sysctl_accurate_timestamps = 1;
+
 static inline void net_timestamp(struct sk_buff *skb)
 {
-	if (atomic_read(&netstamp_needed))
+	if (sysctl_accurate_timestamps && atomic_read(&netstamp_needed))
 		__net_timestamp(skb);
 	else {
 		skb->tstamp.off_sec = 0;
diff -ur ../linux-2.6.20.1/net/core/sysctl_net_core.c linux-2.6.20.1-ts/net/core/sysctl_net_core.c
--- ../linux-2.6.20.1/net/core/sysctl_net_core.c	2007-02-20 09:34:32.000000000 +0300
+++ linux-2.6.20.1-ts/net/core/sysctl_net_core.c	2007-03-04 19:05:11.000000000 +0300
@@ -21,6 +21,8 @@
 
 extern int sysctl_core_destroy_delay;
 
+extern int sysctl_accurate_timestamps;
+
 #ifdef CONFIG_XFRM
 extern u32 sysctl_xfrm_aevent_etime;
 extern u32 sysctl_xfrm_aevent_rseqth;
@@ -136,6 +138,14 @@
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec
 	},
+	{
+		.ctl_name	= NET_CORE_ACCURATE_TIMESTAMPS,
+		.procname	= "accurate_timestamps",
+		.data		= &sysctl_accurate_timestamps,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
 	{ .ctl_name = 0 }
 };
 

May I ask about integrating this or a similar solution for those
like me who values routing performance (with bind9 running) over
minor convinience of having tcpdump always display accurate
timestamps?

And why current kernel (2.6.20.1) still ignores parameter
clocksource=tsc ? I think with idle=poll TSC is safe to use on my setup,
it had ran with TSC for many months without a problem.

~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 

