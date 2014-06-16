From: Chris Mason <clm@fb.com>
Subject: perf regression from ipv6: use net->rt_genid to check dst validity
Date: Mon, 16 Jun 2014 17:31:15 -0400
Message-ID: <539F6223.4040006@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:16606 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754312AbaFPV0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 17:26:06 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id s5GLPhJM014557
	for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 14:26:04 -0700
Received: from mail.thefacebook.com (mailwest.thefacebook.com [173.252.71.148])
	by mx0b-00082601.pphosted.com with ESMTP id 1mga64p8aq-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 14:26:04 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I tracked down a perf regression last week in our 3.10-stable based
kernel.  fib6_lookup_1 was at the top of the profiles, being called very
frequently during sends.  The 2.6.38 kernel we were comparing
against only called fib6_lookup_1 during recv.

The call chain was doing the lookups because we were always tossing the
destination cache.  A little trial and error led me to this commit:

	commit 6f3118b571b8a4c06c7985dc3172c3526cb86253
	Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
	Date:   Mon Sep 10 22:09:46 2012 +0000

	    ipv6: use net->rt_genid to check dst validity

The workload was our in memory database, and dropping this commit gave
us a 10% boost to overall queries per second.

Moving up to mainline, it looks like we're still failing the validity
check most of the time.  A few printks show when we do fail, it's always
this line:

       if (rt->rt6i_genid != rt_genid_ipv6(dev_net(rt->dst.dev)))

The cached dst had a genid of 2 and the dev_net version was 3.

What I haven't done yet is fully reproduce the 10% hit on mainline.  I
have a few patches to port in and I'll get a workload running on 3.15.
But it doesn't look like this part has changed.  Somehow we're hanging
onto a destination cache with an old genid and we're hammering on lookups
because of it.

Any ideas before I shower things with printk?

-chris
