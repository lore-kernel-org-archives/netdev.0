From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next v2 0/5] Route ICMPv6 errors with the flow when ECMP in use
Date: Fri, 28 Oct 2016 14:32:30 +0200
Message-ID: <1477657955-5157-1-git-send-email-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:32912 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756275AbcJ1Mci (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 08:32:38 -0400
Received: by mail-wm0-f47.google.com with SMTP id 79so13213821wmy.0
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 05:32:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The motivation for this series is to route ICMPv6 error messages
together with the flow they belong to when multipath routing is in
use. It intends to bring the ECMP routing in IPv6 stack on par with
IPv4.

This enables the use of tools that rely on ICMP error messages such as
traceroute and makes PMTU discovery work both ways. However, for it to
work IPv6 flow labels have to be same in both directions
(i.e. reflected) or need to be chosen in a manner that ensures that
the flow going in the opposite direction would actually be routed to a
given path.

Even though we generally don't expect this, as receiving and sending
IPv6 are free to choose flow labels at will, we make an assumption
here that the enitity in charge of configuring ECMP routing will also
be in control of the server hosts, and can set up flow label
reflection. However, if this is not the case, the patchset doesn't
make the situation worse.

One potential user of the changes here would be an anycast service
hosted behind an ECMP router(s).

Changes have been tested in a virtual setup with a topology as below:

                  Re1 --- Hs1
                 /
 Hc --- Ri --- Rc
                 \
                  Re1 --- Hs2

 Hc  - client host
 HsX - server host
 Rc  - core router
 ReX - edge router
 Ri  - intermediate router

To test the changes, traceroute in UDP mode to the client host, with
flow label set, has been run from one of the server hosts. Full test
is available at [1].

-Jakub

[1] https://github.com/jsitnicki/tools/blob/master/net/tests/ecmp/test-ecmp-icmpv6-error-routing.sh

v1 -> v2:
 - don't use "extern" in external function declaration in header file,
   pointed out by David Miller;
 - style change, put as many arguments as possible on the first line of
   a function call, and align consecutive lines to the first argument,
   pointed out by David Miller;
 - expand the cover letter based on the feedback from David Miller and
   Hannes Sowa;

Jakub Sitnicki (5):
  ipv6: Fold rt6_info_hash_nhsfn() into its only caller
  net: Extend struct flowi6 with multipath hash
  ipv6: Use multipath hash from flow info if available
  ipv6: Compute multipath hash for sent ICMP errors from offending
    packet
  ipv6: Compute multipath hash for forwarded ICMP errors from offending
    packet

 include/linux/icmpv6.h |  2 ++
 include/net/flow.h     |  1 +
 net/ipv6/icmp.c        | 21 +++++++++++++++++++++
 net/ipv6/route.c       | 40 +++++++++++++++++++++++++++++-----------
 4 files changed, 53 insertions(+), 11 deletions(-)

-- 
2.7.4
