From: Patrick McHardy <kaber@trash.net>
Subject: gre: minor cleanups in netlink interface
Date: Fri, 10 Oct 2008 18:04:52 +0200
Message-ID: <48EF7D24.6040400@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080303020205060208030005"
To: Herbert Xu <herbert.xu@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57859 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761063AbYJJQE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 12:04:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080303020205060208030005
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Some minor cleanups, there doesn't seem to be a reason for not
using the typeful helpers everywhere.

I noticed the interface expects to always get a full configuration
on change requests. Is there are particular reason for not
supporting incremental changes, lets say

"ip link change dev gre0 type gre remote <new remote>"

? It looks easy enough to change, so I could take care of this.

--------------080303020205060208030005
Content-Type: text/x-patch;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit 5a00d521ffc35f3168bf72b9f0e398ae60793c50
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Oct 10 17:58:17 2008 +0200

    gre: minor cleanups in netlink interface
    
    - use typeful helpers for IFLA_GRE_LOCAL/IFLA_GRE_REMOTE
    - replace magic value by FIELD_SIZEOF
    - use MODULE_ALIAS_RTNL_LINK macro
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index c0755e9..05ebce2 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1368,10 +1368,10 @@ static void ipgre_netlink_parms(struct nlattr *data[],
 		parms->o_key = nla_get_be32(data[IFLA_GRE_OKEY]);
 
 	if (data[IFLA_GRE_LOCAL])
-		memcpy(&parms->iph.saddr, nla_data(data[IFLA_GRE_LOCAL]), 4);
+		parms->iph.saddr = nla_get_be32(data[IFLA_GRE_LOCAL]);
 
 	if (data[IFLA_GRE_REMOTE])
-		memcpy(&parms->iph.daddr, nla_data(data[IFLA_GRE_REMOTE]), 4);
+		parms->iph.daddr = nla_get_be32(data[IFLA_GRE_REMOTE]);
 
 	if (data[IFLA_GRE_TTL])
 		parms->iph.ttl = nla_get_u8(data[IFLA_GRE_TTL]);
@@ -1541,8 +1541,8 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	NLA_PUT_BE16(skb, IFLA_GRE_OFLAGS, p->o_flags);
 	NLA_PUT_BE32(skb, IFLA_GRE_IKEY, p->i_key);
 	NLA_PUT_BE32(skb, IFLA_GRE_OKEY, p->o_key);
-	NLA_PUT(skb, IFLA_GRE_LOCAL, 4, &p->iph.saddr);
-	NLA_PUT(skb, IFLA_GRE_REMOTE, 4, &p->iph.daddr);
+	NLA_PUT_BE32(skb, IFLA_GRE_LOCAL, p->iph.saddr);
+	NLA_PUT_BE32(skb, IFLA_GRE_REMOTE, p->iph.daddr);
 	NLA_PUT_U8(skb, IFLA_GRE_TTL, p->iph.ttl);
 	NLA_PUT_U8(skb, IFLA_GRE_TOS, p->iph.tos);
 	NLA_PUT_U8(skb, IFLA_GRE_PMTUDISC, !!(p->iph.frag_off & htons(IP_DF)));
@@ -1559,8 +1559,8 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_OFLAGS]	= { .type = NLA_U16 },
 	[IFLA_GRE_IKEY]		= { .type = NLA_U32 },
 	[IFLA_GRE_OKEY]		= { .type = NLA_U32 },
-	[IFLA_GRE_LOCAL]	= { .len = 4 },
-	[IFLA_GRE_REMOTE]	= { .len = 4 },
+	[IFLA_GRE_LOCAL]	= { .len = FIELD_SIZEOF(struct iphdr, saddr) },
+	[IFLA_GRE_REMOTE]	= { .len = FIELD_SIZEOF(struct iphdr, daddr) },
 	[IFLA_GRE_TTL]		= { .type = NLA_U8 },
 	[IFLA_GRE_TOS]		= { .type = NLA_U8 },
 	[IFLA_GRE_PMTUDISC]	= { .type = NLA_U8 },
@@ -1643,5 +1643,5 @@ static void __exit ipgre_fini(void)
 module_init(ipgre_init);
 module_exit(ipgre_fini);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("rtnl-link-gre");
-MODULE_ALIAS("rtnl-link-gretap");
+MODULE_ALIAS_RTNL_LINK("gre");
+MODULE_ALIAS_RTNL_LINK("gretap");

--------------080303020205060208030005--
