From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net 0/3] ipv6: Fix a potential deadlock when creating pcpu rt
Date: Fri, 14 Aug 2015 11:05:51 -0700
Message-ID: <1439575554-3823839-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	FB Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:26090 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754730AbbHNSVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 14:21:09 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7EIL3WV024619
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 11:21:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1w9m8m86e9-5
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 11:21:09 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 21cc24c242b111e5aa2524be05956610-583f52b0 for <netdev@vger.kernel.org>;	Fri,
 14 Aug 2015 11:20:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1 -> v2:
A minor change in the commit message of patch 2.

This patch series fixes a potential deadlock when creating a pcpu rt.
It happens when dst_alloc() decided to run gc. Something like this:

read_lock(&table->tb6_lock);
ip6_rt_pcpu_alloc()
=> dst_alloc()
=> ip6_dst_gc()
=> write_lock(&table->tb6_lock); /* oops */

Patch 1 and 2 are some prep works.
Patch 3 is the fix.

Original report: https://bugzilla.kernel.org/show_bug.cgi?id=102291
