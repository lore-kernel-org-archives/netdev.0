From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: [PATCH 0/3] xfrm: add incoming interface to selector
Date: Mon, 28 Nov 2011 21:14:49 +0100
Message-ID: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6.sophos.com ([213.31.172.36]:58162 "EHLO mx6.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754296Ab1K1UVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 15:21:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current implementation allows to match IPsec policies based
on the outgoing interface. This however is kind of broken:
 a) decode_session will not fill oif and is therefore always set to zero and
    will never match (see patch #2).
 b) its not possible to match the incoming interface. This makes it impossible,
    to create redundant IPsec tunnels over two uplink interfaces.

Over a year ago there was a discussion about adding the incoming interface to
the xfrm selector. See the following thread for more details:
http://kerneltrap.org/mailarchive/linux-netdev/2010/3/31/6273708


The first patch will reuse the user attribute in the xfrm selector as
incoming interface. Yes, this breaks the ABI. But user in xfrm selector was
never used and user space programs set it to zero. The alternative would
be to have different xfrm_selector structs in kernel and user space.

Second patch makes matching outgoing and incoming interfaces operational by
setting oif and iif in flowi struct. Local generated packets will have iif
set to loopback interface.

Third patch allows to override the incoming interface of decrypted packets.
This allows to create virtual IPsec devices for redundant IPsec tunnels, when
only one Internet uplink is available (e.g. used by Amazon VPC Connector).

Ulrich Weber (3):
  xfrm: add incoming interface to selector
  route: set iif and oif information in flowi struct
  xfrm: allow to overwrite incoming dev after decryption

 include/linux/xfrm.h    |    5 +++--
 include/net/xfrm.h      |    6 +++++-
 net/ipv4/route.c        |    4 ++++
 net/ipv4/xfrm4_policy.c |   19 +++++++++++++++++--
 net/ipv4/xfrm4_state.c  |    3 ++-
 net/ipv6/fib6_rules.c   |   10 ++++++++--
 net/ipv6/mip6.c         |    3 ++-
 net/ipv6/xfrm6_policy.c |   18 ++++++++++++++++--
 net/ipv6/xfrm6_state.c  |    3 ++-
 net/key/af_key.c        |    2 +-
 net/xfrm/xfrm_input.c   |    5 +++++
 net/xfrm/xfrm_policy.c  |    6 ++++--
 net/xfrm/xfrm_state.c   |   44 +++++++++++++++++++++++++++++++++++++++-----
 net/xfrm/xfrm_user.c    |   14 +++++++++++++-
 14 files changed, 121 insertions(+), 21 deletions(-)

-- 
1.7.4.1
