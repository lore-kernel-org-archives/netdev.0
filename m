From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ip6_gre: Fix MTU setting
Date: Mon, 9 May 2016 15:28:29 -0700
Message-ID: <1462832909-553684-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46310 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751626AbcEIW2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 18:28:41 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u49MPpbw004415
	for <netdev@vger.kernel.org>; Mon, 9 May 2016 15:28:41 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22u1ymgdsq-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 09 May 2016 15:28:41 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 613b4662163511e69fe30002c9dfb610-afee4c50 for <netdev@vger.kernel.org>;	Mon,
 09 May 2016 15:28:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ip6gre_tnl_link_config set t->tun_len and t->hlen correctly for the
configuration. For hard_header_len and mtu calculation include
IPv6 header and encapsulation overhead.

In ip6gre_tunnel_init_common set t->tun_len and t->hlen correctly for
the configuration. Revert to setting hard_header_len instead of
needed_headroom.

Tested:

./ip link add name tun8 type ip6gretap remote \
2401:db00:20:911a:face:0:27:0 local \
2401:db00:20:911a:face:0:25:0 ttl 225

Gives MTU of 1434. That is equal to 1500 - 40 - 14 - 4 - 8.

./ip link add name tun8 type ip6gretap remote \
2401:db00:20:911a:face:0:27:0 local \
2401:db00:20:911a:face:0:25:0 ttl 225 okey 123

Gives MTU of 1430. That is equal to 1500 - 40 - 14 - 4 - 8 - 4.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ip6_gre.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 47b671a..6d0aa94 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -700,7 +700,7 @@ static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
 	struct net_device *dev = t->dev;
 	struct __ip6_tnl_parm *p = &t->parms;
 	struct flowi6 *fl6 = &t->fl.u.ip6;
-	int addend = sizeof(struct ipv6hdr) + 4;
+	int t_hlen;
 
 	if (dev->type != ARPHRD_ETHER) {
 		memcpy(dev->dev_addr, &p->laddr, sizeof(struct in6_addr));
@@ -727,16 +727,11 @@ static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
 	else
 		dev->flags &= ~IFF_POINTOPOINT;
 
-	/* Precalculate GRE options length */
-	if (t->parms.o_flags&(GRE_CSUM|GRE_KEY|GRE_SEQ)) {
-		if (t->parms.o_flags&GRE_CSUM)
-			addend += 4;
-		if (t->parms.o_flags&GRE_KEY)
-			addend += 4;
-		if (t->parms.o_flags&GRE_SEQ)
-			addend += 4;
-	}
-	t->hlen = addend;
+	t->tun_hlen = gre_calc_hlen(t->parms.o_flags);
+
+	t->hlen = t->tun_hlen;
+
+	t_hlen = t->hlen + sizeof(struct ipv6hdr);
 
 	if (p->flags & IP6_TNL_F_CAP_XMIT) {
 		int strict = (ipv6_addr_type(&p->raddr) &
@@ -750,10 +745,11 @@ static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
 			return;
 
 		if (rt->dst.dev) {
-			dev->hard_header_len = rt->dst.dev->hard_header_len + addend;
+			dev->hard_header_len = rt->dst.dev->hard_header_len +
+					       t_hlen;
 
 			if (set_mtu) {
-				dev->mtu = rt->dst.dev->mtu - addend;
+				dev->mtu = rt->dst.dev->mtu - t_hlen;
 				if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 					dev->mtu -= 8;
 				if (dev->type == ARPHRD_ETHER)
@@ -1027,11 +1023,12 @@ static int ip6gre_tunnel_init_common(struct net_device *dev)
 
 	tunnel->tun_hlen = gre_calc_hlen(tunnel->parms.o_flags);
 
-	t_hlen = tunnel->hlen + sizeof(struct ipv6hdr);
+	tunnel->hlen = tunnel->tun_hlen;
 
-	dev->needed_headroom	= LL_MAX_HEADER + t_hlen + 4;
-	dev->mtu		= ETH_DATA_LEN - t_hlen - 4;
+	t_hlen = tunnel->hlen + sizeof(struct ipv6hdr);
 
+	dev->hard_header_len = LL_MAX_HEADER + t_hlen;
+	dev->mtu = ETH_DATA_LEN - t_hlen;
 	if (!(tunnel->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 		dev->mtu -= 8;
 
-- 
2.8.0.rc2
