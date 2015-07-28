From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v5 0/2] af_mpls: fix undefined reference to ip6_route_output with CONFIG_IPV6=n
Date: Tue, 28 Jul 2015 15:27:39 -0700
Message-ID: <1438122461-8350-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, hannes@stressinduktion.org,
	rshearma@brocade.com, stephen@networkplumber.org,
	kuznet@ms2.inr.ac.ru, jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36241 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbG1W1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:27:47 -0400
Received: by pdjr16 with SMTP id r16so78951568pdj.3
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:27:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch series uses ipv6_stub_impl.ipv6_dst_lookup instead of 
ip6_route_output. Follows the vxlan drivers usage of
ipv6_stub_impl.ipv6_dst_lookup.

There is no sk in the af_mpls context from where
ipv6_stub_impl.ipv6_dst_lookup is used. sk appears to be needed
to get the namespace 'net' and is optional otherwise. This patch series
changes ipv6_stub_impl.ipv6_dst_lookup to take net argument. sk remains
optional.

The case of CONFIG_IPV6=m and MPLS_ROUTING=y is covered by checking
if ipv6_stub is not NULL. I have tested this case for proper return
values to the user. (I dont see an ipv6_stub null check in
the vxlan driver. I will test it separately and submit a patch
for vxlan driver if needed).

v1 - v2: use IS_BUILTIN

v2 - v3: Use new Kconfig option that depends on (IPV6 || IPV6=n) as
	 suggested by Dave. Also uses IS_ERR as suggested by Thomas.

v3 - v4: Include missed case of (MPLS_ROUTING=y && IPV6=m) reported by
         Dave.

v4 - v5: Use ipv6_stub_impl.ipv6_dst_lookup as suggested by Hannes


Dave, v4 uses a new Kconfig option and v5 uses ipv6_stub_impl.ipv6_dst_lookup
which looks like was added for vxlan driver for similar use case. Thanks and
apologies for the iterations on this.

Roopa Prabhu (2):
  ipv6: change ipv6_stub_impl.ipv6_dst_lookup to take net argument
  af_mpls: fix undefined reference to ip6_route_output

 drivers/net/vxlan.c    |    2 +-
 include/net/addrconf.h |    4 ++--
 include/net/ipv6.h     |    3 ++-
 net/ipv6/icmp.c        |    6 +++---
 net/ipv6/ip6_output.c  |   15 ++++++++-------
 net/mpls/af_mpls.c     |   39 +++++++++++++++++++++++++++++++--------
 net/tipc/udp_media.c   |    3 ++-
 7 files changed, 49 insertions(+), 23 deletions(-)

-- 
1.7.10.4
