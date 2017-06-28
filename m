From: Florian Westphal <fw@strlen.de>
Subject: [RFC ipsec-next] flow cache removal
Date: Wed, 28 Jun 2017 15:26:43 +0200
Message-ID: <20170628132652.1275-1-fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:34200 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751087AbdF1N0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 09:26:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is an updated version of the flow cache removal
set.

Changes since last iteration:
 - rebase
 - split removal into multiple gradual chunks to ease review
 - add a small pcpu xdst cache to reduce alloc/free overhead
   when subsequent packet can re-use previous xdst

I did some sanity testing and ran a few netperf tests.
The most severe hit is with pure UDP_RR workload.
TCP_STREAM is ok-ish, UDP_STREAM is marginally faster with
the simpler pcpu cache (we only instantiate one xfrm_dst and then
reuse it).

We can discuss fine print and possible further work (avoid this_cpu_xchg,
xfrm_genid removal, etc) at NFWS if needed.

Thanks,
Florian

 Documentation/networking/ip-sysctl.txt |    6 
 /include/net/flow.h                     |   34 --
 /include/net/netns/xfrm.h               |   11 
 /include/net/xfrm.h                     |    9 
 /net/core/Makefile                      |    1 
 /net/ipv4/ip_vti.c                      |   31 -
 /net/ipv4/xfrm4_policy.c                |   11 
 /net/ipv6/ip6_vti.c                     |   31 -
 /net/ipv6/xfrm6_policy.c                |   11 
 /net/key/af_key.c                       |    4 
 /net/xfrm/xfrm_device.c                 |    3 
 /net/xfrm/xfrm_policy.c                 |  334 ++++----------------
 /net/xfrm/xfrm_user.c                   |    2 
 /security/selinux/include/xfrm.h        |    4 
 include/net/flowcache.h                  |   25 -
 net/core/flow.c                          |  516 -------------------------------
 16 files changed, 82 insertions(+), 951 deletions(-)
