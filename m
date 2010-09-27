From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: Implement Any-IP support for IPv6.
Date: Mon, 27 Sep 2010 03:07:02 -0700
Message-ID: <1285582022-30787-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:43090 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942Ab0I0KHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 06:07:13 -0400
Received: by pzk34 with SMTP id 34so1134166pzk.19
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 03:07:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

AnyIP is the capability to receive packets and establish incoming
connections on IPs we have not explicitly configured on the machine.

An example use case is to configure a machine to accept all incoming
traffic on eth0, and leave the policy of whether traffic for a given IP
should be delivered to the machine up to the load balancer.

Can be setup as follows:
  ip -6 rule from all iif eth0 lookup 200
  ip -6 route add local default dev lo table 200
(in this case for all IPv6 addresses)

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/ipv6/route.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d126365..3a74f90 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1169,6 +1169,8 @@ int ip6_route_add(struct fib6_config *cfg)
=20
 	if (addr_type & IPV6_ADDR_MULTICAST)
 		rt->dst.input =3D ip6_mc_input;
+	else if (cfg->fc_flags & RTF_LOCAL)
+		rt->dst.input =3D ip6_input;
 	else
 		rt->dst.input =3D ip6_forward;
=20
@@ -1190,7 +1192,8 @@ int ip6_route_add(struct fib6_config *cfg)
 	   they would result in kernel looping; promote them to reject routes
 	 */
 	if ((cfg->fc_flags & RTF_REJECT) ||
-	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBA=
CK))) {
+	    (dev && (dev->flags&IFF_LOOPBACK) && !(addr_type&IPV6_ADDR_LOOPBA=
CK)
+					      && !(cfg->fc_flags&RTF_LOCAL))) {
 		/* hold loopback dev/idev if we haven't done so. */
 		if (dev !=3D net->loopback_dev) {
 			if (dev) {
@@ -2082,6 +2085,9 @@ static int rtm_to_fib6_config(struct sk_buff *skb=
, struct nlmsghdr *nlh,
 	if (rtm->rtm_type =3D=3D RTN_UNREACHABLE)
 		cfg->fc_flags |=3D RTF_REJECT;
=20
+	if (rtm->rtm_type =3D=3D RTN_LOCAL)
+		cfg->fc_flags |=3D RTF_LOCAL;
+
 	cfg->fc_nlinfo.pid =3D NETLINK_CB(skb).pid;
 	cfg->fc_nlinfo.nlh =3D nlh;
 	cfg->fc_nlinfo.nl_net =3D sock_net(skb->sk);
@@ -2202,6 +2208,8 @@ static int rt6_fill_node(struct net *net,
 	NLA_PUT_U32(skb, RTA_TABLE, table);
 	if (rt->rt6i_flags&RTF_REJECT)
 		rtm->rtm_type =3D RTN_UNREACHABLE;
+	else if (rt->rt6i_flags&RTF_LOCAL)
+		rtm->rtm_type =3D RTN_LOCAL;
 	else if (rt->rt6i_dev && (rt->rt6i_dev->flags&IFF_LOOPBACK))
 		rtm->rtm_type =3D RTN_LOCAL;
 	else
--=20
1.7.2.3

