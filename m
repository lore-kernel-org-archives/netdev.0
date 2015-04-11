From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC PATCH net-next 00/10] ipv6: Only create RTF_CACHE route after encountering pmtu exception
Date: Fri, 10 Apr 2015 18:59:26 -0700
Message-ID: <1428717576-1040383-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	<kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:23162 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753508AbbDKB7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 21:59:49 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3B1xGHI008207
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:59:48 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1tpqk1gcgc-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 18:59:48 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 6d1ed68edfee11e4b27b0002c991e86a-ed7d72c0 for <netdev@vger.kernel.org>;	Fri,
 10 Apr 2015 18:59:45 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Just a re-sent of the last one with the net-next tag]

Hi,

This series is to avoid creating a RTF_CACHE route whenever we are consulting
the fib6 tree with a new destination.  Instead, only create RTF_CACHE route
when we see a pmtu exception.

Out of all ipv6 RTF_CACHE routes that are created, the percentage that has a
different mtu is very small. In one of our end-user facing proxy server,
only 1k out of 80k RTF_CACHE routes have a smaller MTU.  For our DC
traffic, there is no mtu exception.

A large fib6 tree has problems like, 'ip -6 r show' takes a long time.
gc may kick in too often.  Also, when a service has restarted and a lot
of new TCP conn requests come in, it creates pressure on the tree by inserting
a lot of RTF_CACHE in a short time and it currently requires a write lock
to do that.

The first few patches are prep works to remove assumption that the
returned rt is always RTF_CACHE.

The patch 'ipv6: Only create RTF_CACHE routes after encountering pmtu exception'
do the lazy RTF_CACHE route creation.

The next few patches fix the /128 via gateway route issue.  One of them
is by "Steffen Klassert <steffen.klassert@secunet.com>" which I pulled off
from netdev.

The last two patches added percpu rt to compensate the performance loss after
doing the RTF_CACHE lazy creation.

Here is some numbers of the udpflood test.  The udpflood has been
slightly modified to have a time limit instead of count limit.

A /64 via gateway route is used for the test. Each udpflood uses 10000 dst
addresses.  The dst addresses of different udpflood processes do not overlap
with each other.

# of udpflood        # of trans (patched)        # of trans (upstream)

1                    16M                          15M
10                   61M                          61M
20                   65M                          62M
40                   88M                          83M


Many thanks to "Hannes Frederic Sowa <hannes@stressinduktion.org>" on
reviewing the patches and giving advice.

--Martin
