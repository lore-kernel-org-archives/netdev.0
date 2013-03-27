From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: sch_generic: missing u64 in psched_ratecfg_precompute()?
Date: Wed, 27 Mar 2013 15:00:06 +0200
Message-ID: <4306359.Sd6orIF4zo@tuxracer.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nextPart2389811.VlZ5zP96i8"
Content-Transfer-Encoding: 7Bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback2.mail.ru ([94.100.176.87]:58627 "EHLO
	fallback2.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab3C0NBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 09:01:25 -0400
Received: from smtp1.mail.ru (smtp1.mail.ru [94.100.176.129])
	by fallback2.mail.ru (mPOP.Fallback_MX) with ESMTP id 525B1D1A003B
	for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 17:00:43 +0400 (MSK)
Received: from [195.234.68.4] (port=38575 helo=tuxracer.localdomain)
	by smtp1.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1UKpxe-0005af-BX
	for netdev@vger.kernel.org; Wed, 27 Mar 2013 17:00:16 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--nextPart2389811.VlZ5zP96i8
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hello!

It seems that commit

  commit 292f1c7ff6cc10516076ceeea45ed11833bb71c7                                                                                             
  Author: Jiri Pirko <jiri@resnulli.us>                                                                                                       
  Date:   Tue Feb 12 00:12:03 2013 +0000                                                                                                      
                                                                                                                                            
      sch: make htb_rate_cfg and functions around that generic

adds little regression.

Before
----
# tc qdisc add dev eth0 root handle 1: htb default ffff
# tc class add dev eth0 classid 1:ffff htb rate 5Gbit
# tc -s class show dev eth0
class htb 1:ffff root prio 0 rate 5000Mbit ceil 5000Mbit burst 625b cburst 
625b 
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 0bit 0pps backlog 0b 0p requeues 0 
 lended: 0 borrowed: 0 giants: 0
 tokens: 31 ctokens: 31

After
----
# tc qdisc add dev eth0 root handle 1: htb default ffff
# tc class add dev eth0 classid 1:ffff htb rate 5Gbit
# tc -s class show dev eth0
class htb 1:ffff root prio 0 rate 1544Mbit ceil 1544Mbit burst 625b cburst 
625b
 Sent 5073 bytes 41 pkt (dropped 0, overlimits 0 requeues 0)
 rate 1976bit 2pps backlog 0b 0p requeues 0
 lended: 41 borrowed: 0 giants: 0
 tokens: 1802 ctokens: 1802

This probably due to lost u64 cast of rate parameter in 
psched_ratecfg_precompute() (net/sched/sch_generic.c).

Simple patch attached. Tested and found working for me at least
on amd64.

-- 
SP5474-RIPE
Sergey Popovich

--nextPart2389811.VlZ5zP96i8
Content-Disposition: attachment; filename="sch_generic-add-missing-u64-cast.patch"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-patch; charset="utf-8"; name="sch_generic-add-missing-u64-cast.patch"

diff -purN a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2013-03-27 14:52:27.419643015 +0200
+++ b/net/sched/sch_generic.c	2013-03-20 12:02:08.569366312 +0200
@@ -921,7 +921,7 @@ void psched_ratecfg_precompute(struct ps
 	u64 mult;
 	int shift;
 
-	r->rate_bps = rate << 3;
+	r->rate_bps = (u64)rate << 3;
 	r->shift = 0;
 	r->mult = 1;
 	/*

--nextPart2389811.VlZ5zP96i8--
