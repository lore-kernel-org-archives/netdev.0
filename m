From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next v3 0/4] Route ICMPv6 errors with the flow when ECMP in use
Date: Wed, 23 Aug 2017 09:58:27 +0200
Message-ID: <20170823075831.27031-1-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37046 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753420AbdHWH6f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 03:58:35 -0400
Received: by mail-wm0-f49.google.com with SMTP id b189so9766813wmd.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 00:58:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set is another take at making Path MTU Discovery work when
server nodes are behind a router employing multipath routing in a
load-balance or anycast setup (that is, when not every end-node can be
reached by every path). The problem has been well described in RFC 7690
[1], but in short - in such setups ICMPv6 PTB errors are not guaranteed
to be routed back to the server node that sent a reply that exceeds path
MTU.

The proposed solution is two-fold:

 (1) on the server side - reflect the Flow Label [2]. This can be done
     without modifying the application using a new per-netns sysctl knob
     that has been proposed independently of this patchset in the patch
     entitled "ipv6: Add sysctl for per namespace flow label
     reflection" [3].

 (2) on the ECMP router - make the ipv6 routing subsystem look into the
     ICMPv6 error packets and compute the flow-hash from its payload,
     i.e. the offending packet that triggered the error. This is the
     same behavior as ipv4 stack has already.

With both parts in place Path MTU Discovery can work past the ECMP
router when using IPv6.

[1] https://tools.ietf.org/html/rfc7690
[2] https://tools.ietf.org/html/draft-wang-6man-flow-label-reflection-01
[3] http://patchwork.ozlabs.org/patch/804870/

v1 -> v2:
 - don't use "extern" in external function declaration in header file
 - style change, put as many arguments as possible on the first line of
   a function call, and align consecutive lines to the first argument
 - expand the cover letter based on the feedback

v2 -> v3:
 - switch to computing flow-hash using flow dissector to align with
   recent changes to multipath routing in ipv4 stack
 - add a sysctl knob for enabling flow label reflection per netns

---

Testing has covered multipath routing of ICMPv6 PTB errors in forward
and local output path in a simple use-case of an HTTP server sending a
reply which is over the path MTU size [3]. I have also checked if the
flows get evenly spread over multiple paths (i.e. if there are no
regressions) [4].

[3] https://github.com/jsitnicki/tools/tree/master/net/tests/ecmp/pmtud
[4] https://github.com/jsitnicki/tools/tree/master/net/tests/ecmp/load-balance


Jakub Sitnicki (4):
  net: Extend struct flowi6 with multipath hash
  ipv6: Compute multipath hash for ICMP errors from offending packet
  ipv6: Fold rt6_info_hash_nhsfn() into its only caller
  ipv6: Use multipath hash from flow info if available

 include/net/flow.h      |  1 +
 include/net/ip6_route.h |  1 +
 net/ipv6/icmp.c         |  1 +
 net/ipv6/route.c        | 68 +++++++++++++++++++++++++++++++++++++++++--------
 4 files changed, 60 insertions(+), 11 deletions(-)

-- 
2.9.4
