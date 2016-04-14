From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 2/5] ip6gretap: Fix MTU to allow for Ethernet header
Date: Thu, 14 Apr 2016 15:33:45 -0400
Message-ID: <20160414193345.12934.21014.stgit@ahduyck-xeon-server>
References: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jesse@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34212 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcDNTdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 15:33:52 -0400
Received: by mail-pa0-f49.google.com with SMTP id ot11so47594509pab.1
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 12:33:51 -0700 (PDT)
In-Reply-To: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we were creating an ip6gretap interface the MTU was about 6 bytes
short of what was needed.  It turns out we were not taking the Ethernet
header into account and as a result we were eating into the 8 bytes
reserved for the encap limit.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv6/ip6_gre.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 4e636e60a360..2be66e7b4a78 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -987,6 +987,8 @@ static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
 				dev->mtu = rt->dst.dev->mtu - addend;
 				if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 					dev->mtu -= 8;
+				if (dev->type == ARPHRD_ETHER)
+					dev->mtu -= ETH_HLEN;
 
 				if (dev->mtu < IPV6_MIN_MTU)
 					dev->mtu = IPV6_MIN_MTU;
