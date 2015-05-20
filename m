From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v4 0/10] ipv6: Only create RTF_CACHE route after encountering pmtu exception
Date: Wed, 20 May 2015 15:52:19 -0700
Message-ID: <1432162349-788789-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:4819 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752819AbbETWxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 18:53:17 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4KMquY5021113
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 15:53:16 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1uh2kyr5hw-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 20 May 2015 15:53:16 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 ff7f0b52ff4211e4b29c0002c95209d8-f94d53a0 for <netdev@vger.kernel.org>;	Wed,
 20 May 2015 15:53:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v3 -> v4:
- Patch 8 is new. It keeps track of the DST_NOCACHE routes in a list to handle
  the iface down/unregister event.

- Remove rcu from the newly added rt6i_pcpu variable.  It is not needed
  because it has already been protected by the existing reader/writer lock.

- Thanks to 'Julian Anastasov <ja@ssi.bg>' for testing the FLOWI_FLAG_KNOWN_NH
  patches.

v2 -> v3:
- Patch 5 to 7 are new.  They take care of cases where the daddr in
  skb is not the one used to do the route look-up.  There is also
  related changes to rt6_nexthop() since v2 which is in patch 2/9.
  Thanks to 'Julian Anastasov <ja@ssi.bg>' for pointing it out.

- Fix a few problems in __ip6_rt_update_pmtu(), like setting the expire
  and mtu before inserting to the tree and don't do dst_destroy() after
  tree insertion failure.  Also update the rt6i_pmtu in fib6_add_rt2node().
  Thanks to 'Steffen Klassert <steffen.klassert@secunet.com>' for pointing
  it out.

- Merge ip6_pmtu_rt_cache_alloc() into ip6_rt_cache_alloc().

v1 -> v2:
- Move the /128 route bug fixes to another series (accepted).
- Create a function for checking (rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)).
- Avoid shuffling the skb network_header.  Instead, change the function
  signature to take iph instead of skb.

- Many Thanks to 'Hannes Frederic Sowa <hannes@stressinduktion.org>' on
  reviewing v1 and v2 and giving advice.

--Martin

~~~ start: v1 compose message (with the out-dated parts removed) ~~~

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

The following patches added percpu rt to compensate the performance loss after
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

~~~ end: v1 compose message ~~~
