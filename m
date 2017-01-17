From: Josef Bacik <jbacik@fb.com>
Subject: [PATCH 0/6 net-next][V4] Rework inet_csk_get_port
Date: Tue, 17 Jan 2017 07:51:00 -0800
Message-ID: <20170117155106.22637-1-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <hannes@stressinduktion.org>,
        <kraigatgoog@gmail.com>, <eric.dumazet@gmail.com>,
        <tom@herbertland.com>, <netdev@vger.kernel.org>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54533 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750741AbdAQPvX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 10:51:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V3->V4:
-Removed the random include of addrconf.h that is no longer needed.

V2->V3:
-Dropped the fastsock from the tb and instead just carry the saddrs, family, and
 ipv6 only flag.
-Reworked the helper functions to deal with this change so I could still use
 them when checking the fast path.
-Killed tb->num_owners as per Eric's request.
-Attached a reproducer to the bottom of this email.

V1->V2:
-Added a new patch 'inet: collapse ipv4/v6 rcv_saddr_equal functions into one'
 at Hannes' suggestion.
-Dropped ->bind_conflict and just use the new helper.
-Fixed a compile bug from the original ->bind_conflict patch.

The original description of the series follows

=========================================================

At some point recently the guys working on our load balancer added the ability
to use SO_REUSEPORT.  When they restarted their app with this option enabled
they immediately hit a softlockup on what appeared to be the
inet_bind_bucket->lock.  Eventually what all of our debugging and discussion led
us to was the fact that the application comes up without SO_REUSEPORT, shuts
down which creates around 100k twsk's, and then comes up and tries to open a
bunch of sockets using SO_REUSEPORT, which meant traversing the inet_bind_bucket
owners list under the lock.  Since this lock is needed for dealing with the
twsk's and basically anything else related to connections we would softlockup,
and sometimes not ever recover.

To solve this problem I did what you see in Path 5/5.  Once we have a
SO_REUSEPORT socket on the tb->owners list we know that the socket has no
conflicts with any of the other sockets on that list.  So we can add a copy of
the sock_common (really all we need is the recv_saddr but it seemed ugly to copy
just the ipv6, ipv4, and flag to indicate if we were ipv6 only in there so I've
copied the whole common) in order to check subsequent SO_REUSEPORT sockets.  If
they match the previous one then we can skip the expensive
inet_csk_bind_conflict check.  This is what eliminated the soft lockup that we
were seeing.

Patches 1-4 are cleanups and re-workings.  For instance when we specify port ==
0 we need to find an open port, but we would do two passes through
inet_csk_bind_conflict every time we found a possible port.  We would also keep
track of the smallest_port value in order to try and use it if we found no
port our first run through.  This however made no sense as it would have had to
fail the first pass through inet_csk_bind_conflict, so would not actually pass
the second pass through either.  Finally I split the function into two functions
in order to make it easier to read and to distinguish between the two behaviors.

I have tested this on one of our load balancing boxes during peak traffic and it
hasn't fallen over.  But this is not my area, so obviously feel free to point
out where I'm being stupid and I'll get it fixed up and retested.  Thanks,

Josef
