From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3]ipv6:fix the outgoing interface selection order
 in udpv6_sendmsg()
Date: Wed, 10 Dec 2008 17:41:14 +0800
Message-ID: <493F8EBA.7070907@cn.fujitsu.com>
References: <20081209.221611.26561529.davem@davemloft.net>	<493F62D7.3080000@cn.fujitsu.com>	<493F63E1.3030800@cn.fujitsu.com> <20081210.011514.120756807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57269 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751489AbYLJJjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2008 04:39:45 -0500
In-Reply-To: <20081210.011514.120756807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Yang Hongyang <yanghy@cn.fujitsu.com>
> Date: Wed, 10 Dec 2008 14:38:25 +0800
> 
...snip...
>>>>
>>> Hum..can we just ignore the sync of the sticky option and the SO_BINDTODEVICE,
>>> when send a message,first check sk_bound_dev_if,If it is specified,use it,otherwise
>>> use sticky option?This was what i ment. and in my patch ,the outgoing interface 
>>> specified by sticky options will be overrided by the interface specified by 
>>> SO_BINDTODEVICE.
>> If this is the solution, i'll post a updated patch.
> 
> Please do, this sounds like the correct approach.
> 

Thanks for your comment,here is the updated patch:

1.When no interface is specified in an IPV6_PKTINFO ancillary data
  item, the interface specified in an IPV6_PKTINFO sticky optionis 
  is used.

RFC3542:
6.7.  Summary of Outgoing Interface Selection

   This document and [RFC-3493] specify various methods that affect the
   selection of the packet's outgoing interface.  This subsection
   summarizes the ordering among those in order to ensure deterministic
   behavior.

   For a given outgoing packet on a given socket, the outgoing interface
   is determined in the following order:

   1. if an interface is specified in an IPV6_PKTINFO ancillary data
      item, the interface is used.

   2. otherwise, if an interface is specified in an IPV6_PKTINFO sticky
      option, the interface is used.

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 net/ipv6/udp.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 8b48512..6b06421 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -763,6 +763,9 @@ do_udp_sendmsg:
 	if (!fl.oif)
 		fl.oif = sk->sk_bound_dev_if;
 
+	if (!fl.oif)
+		fl.oif = np->sticky_pktinfo.ipi6_ifindex;
+
 	if (msg->msg_controllen) {
 		opt = &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
-- 
1.6.0.1

