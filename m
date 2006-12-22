From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] igmp: spin_lock_bh in timer (Re: BUG: soft lockup detected on CPU#0!)
Date: Fri, 22 Dec 2006 08:13:08 +0100
Message-ID: <20061222071308.GA1791@ff.dom.local>
References: <45889C53.8000307@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tur.go2.pl ([193.17.41.50]:32814 "EHLO tur.go2.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945952AbWLVHgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Dec 2006 02:36:37 -0500
Received: from poczta.o2.pl (mx10.go2.pl [193.17.41.74])
	by tur.go2.pl (o2.pl Mailer 2.0.1) with ESMTP id 352A82301BD
	for <netdev@vger.kernel.org>; Fri, 22 Dec 2006 08:13:01 +0100 (CET)
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <45889C53.8000307@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20-12-2006 03:13, Ben Greear wrote:
> This is from 2.6.18.2 kernel with my patch set.  The MAC-VLANs are in 
> active use.
>  From the backtrace, I am thinking this might be a generic problem, 
> however.
> 
> Any ideas about what this could be?  It seems to be reproducible every 
> day or
> two, but no known way to make it happen quickly...
> 
> Kernel is SMP, PREEMPT.
> 
> 
> Dec 19 04:49:33 localhost kernel: BUG: soft lockup detected on CPU#0!
> Dec 19 04:49:33 localhost kernel:  [<78104252>] show_trace+0x12/0x20
> Dec 19 04:49:33 localhost kernel:  [<78104929>] dump_stack+0x19/0x20
> Dec 19 04:49:33 localhost kernel:  [<7814c88b>] softlockup_tick+0x9b/0xd0
> Dec 19 04:49:33 localhost kernel:  [<7812a992>] run_local_timers+0x12/0x20
> Dec 19 04:49:33 localhost kernel:  [<7812ac08>] 
> update_process_times+0x38/0x80
> Dec 19 04:49:33 localhost kernel:  [<78112796>] 
> smp_apic_timer_interrupt+0x66/0x70
> Dec 19 04:49:33 localhost kernel:  [<78103baa>] 
> apic_timer_interrupt+0x2a/0x30
> Dec 19 04:49:33 localhost kernel:  [<78354e8c>] _read_lock+0x3c/0x50
> Dec 19 04:49:33 localhost kernel:  [<78331f42>] ip_check_mc+0x22/0xb0
> Dec 19 04:49:33 localhost kernel:  [<783068bf>] ip_route_input+0x17f/0xef0
> Dec 19 04:49:33 localhost kernel:  [<78309c59>] ip_rcv+0x349/0x580

Hello,

This log isn't probably enough to tell with certainty
which lock is to blame. We can see it's taken from
some timer during ip_check_mc() but this
read_lock(&in_dev->mc_list_lock) doesn't seem to
be used in timers for writing.
Maybe if you would wait a few minutes or tried
SysRq a oops could tell more.

Looking at igmp.c I've found one suspicious place
and here is a patch proposal included, but it may
be not your case. Anyway you could also try to
change this above mentioned read_lock and
read_unlock to _bh versions - maybe I missed
something.

If it doesn't help, I hope lockdep will be more
precise when you'll upgrade to 2.6.19 or higher.
 
Regards,
Jarek P.
---
[PATCH] igmp: spin_lock_bh in timer

igmp_timer_expire() uses spin_lock(&im->lock)
but this lock is also taken by other igmp timers,
so it should be changed to bh version.

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
---

diff -Nurp linux-2.6.20-rc1-/net/ipv4/igmp.c linux-2.6.20-rc1/net/ipv4/igmp.c
--- linux-2.6.20-rc1-/net/ipv4/igmp.c	2006-12-16 20:37:18.000000000 +0100
+++ linux-2.6.20-rc1/net/ipv4/igmp.c	2006-12-21 22:57:30.000000000 +0100
@@ -727,7 +727,7 @@ static void igmp_timer_expire(unsigned l
 	struct ip_mc_list *im=(struct ip_mc_list *)data;
 	struct in_device *in_dev = im->interface;
 
-	spin_lock(&im->lock);
+	spin_lock_bh(&im->lock);
 	im->tm_running=0;
 
 	if (im->unsolicit_count) {
@@ -735,7 +735,7 @@ static void igmp_timer_expire(unsigned l
 		igmp_start_timer(im, IGMP_Unsolicited_Report_Interval);
 	}
 	im->reporter = 1;
-	spin_unlock(&im->lock);
+	spin_unlock_bh(&im->lock);
 
 	if (IGMP_V1_SEEN(in_dev))
 		igmp_send_report(in_dev, im, IGMP_HOST_MEMBERSHIP_REPORT);
