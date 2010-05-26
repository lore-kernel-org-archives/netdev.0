From: arno@natisbad.org (Arnaud Ebalard)
Subject: [REGRESSION,BISECTED] MIPv6 support broken by f4f914b58019f0
Date: Wed, 26 May 2010 19:01:55 +0200
Message-ID: <87zkzmppfg.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, Jiri Olsa <jolsa@redhat.com>,
	Scott Otto <scott.otto@alcatel-lucent.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:55796 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933199Ab0EZRUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 13:20:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I just updated my laptop's kernel to 2.6.34 (previously running .33 and
configured to act as an IPsec/IKE-protected MIPv6 Mobile Node using
racoon and umip): after rebooting on the new kernel, the transport mode
SA protecting MIPv6 signaling traffic are missing.

I bisected the issue down to f4f914b58019f0e50d521bbbadfaee260d766f95
(net: ipv6 bind to device issue) which was added after 2.6.34-rc5: 

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c2438e8..05ebd78 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -815,7 +815,7 @@ struct dst_entry * ip6_route_output(struct net *net, struct sock *sk,
 {
        int flags = 0;
 
-       if (rt6_need_strict(&fl->fl6_dst))
+       if (fl->oif || rt6_need_strict(&fl->fl6_dst))
                flags |= RT6_LOOKUP_F_IFACE;
 
        if (!ipv6_addr_any(&fl->fl6_src))

Reverting the patch on a 2.6.34 gives me a working kernel.

With MIPv6, the Home Address is bound to a tunnel interface but the
routing/XFRM code will not always send packet via this virtual device
(in fact, I would say never when IPsec is used for protecting signaling
and data traffic):

 - Signaling traffic will be sent using a Care-of Address from another
   interface (with the addition of a Home Address Option in a
   Destination Option Header)
 - Data traffic (when protected by tunnel mode IPsec) will also be sent
   via another interface.

I *suspect* that previous commit somehow changes the lose coupling
between the address and the device to enforce a strict routing via
associated interface.

I will try and take a look at the code tomorrow to understand what
really happens but if someone has ideas, I am interested.

Cheers,

a+

ps: I use the same working setup for all kernels since 2.6.28
