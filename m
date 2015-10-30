From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2015-10-30
Date: Fri, 30 Oct 2015 07:16:25 +0100
Message-ID: <1446185790-24214-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39769 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355AbbJ3GQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 02:16:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) The flow cache is limited by the flow cache limit which
   depends on the number of cpus and the xfrm garbage collector
   threshold which is independent of the number of cpus. This
   leads to the fact that on systems with more than 16 cpus
   we hit the xfrm garbage collector limit and refuse new
   allocations, so new flows are dropped. On systems with 16
   or less cpus, we hit the flowcache limit. In this case, we
   shrink the flow cache instead of refusing new flows. 

   We increase the xfrm garbage collector threshold to INT_MAX
   to get the same behaviour, independent of the number of cpus.

2) Fix some unaligned accesses on sparc systems.
   From Sowmini Varadhan.

3) Fix some header checks in _decode_session4. We may call
   pskb_may_pull with a negative value converted to unsigened
   int from pskb_may_pull. This can lead to incorrect policy
   lookups. We fix this by a check of the data pointer position
   before we call pskb_may_pull.

4) Reload skb header pointers after calling pskb_may_pull
   in _decode_session4 as this may change the pointers into
   the packet. 

5) Add a missing statistic counter on inner mode errors.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 8a4683a5e06efda7e1f327213678d4dcafc0d894:

  net: help compiler generate better code in eth_get_headlen (2015-09-28 22:51:15 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to cb866e3298cd7412503fc7e2c265753c853fab9d:

  xfrm: Increment statistic counter on inner mode error (2015-10-23 07:52:58 +0200)

----------------------------------------------------------------
Sowmini Varadhan (1):
      xfrm: Fix unaligned access to stats in copy_to_user_state()

Steffen Klassert (4):
      xfrm: Let the flowcache handle its size by default.
      xfrm4: Fix header checks in _decode_session4.
      xfrm4: Reload skb header pointers after calling pskb_may_pull.
      xfrm: Increment statistic counter on inner mode error

 Documentation/networking/ip-sysctl.txt |  6 ++--
 net/ipv4/xfrm4_policy.c                | 50 +++++++++++++++++++++++++---------
 net/ipv6/xfrm6_policy.c                |  2 +-
 net/xfrm/xfrm_input.c                  |  4 ++-
 net/xfrm/xfrm_user.c                   |  5 +++-
 5 files changed, 49 insertions(+), 18 deletions(-)
