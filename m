From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] rtnl: don't account unused struct ifla_port_vsi in rtnl_port_size
Date: Fri, 17 Feb 2017 01:56:11 +0100
Message-ID: <8edb70077925c6924eac17dfc3c23cbc31c0529a.1487292448.git.daniel@iogearbox.net>
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53573 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754986AbdBQA4Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 19:56:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When allocating rtnl dump messages, struct ifla_port_vsi is never dumped,
so we can save header plus payload in rtnl_port_size(). Infact, attribute
IFLA_PORT_VSI_TYPE and struct ifla_port_vsi are not used anywhere in
the kernel. We only need to keep the nla policy should applications in
user space be filling this out. Same NLA_BINARY issue exists as was fixed
in 364d5716a7ad ("rtnetlink: ifla_vf_policy: fix misuses of NLA_BINARY")
and others, but then again IFLA_PORT_VSI_TYPE is not used anywhere, so
just add a comment that it's unused.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 ( Found while reviewing NLA_BINARY longer time ago. )

 net/core/rtnetlink.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index adfb54b..ed1ab03 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -876,8 +876,6 @@ static size_t rtnl_port_size(const struct net_device *dev,
 {
 	size_t port_size = nla_total_size(4)		/* PORT_VF */
 		+ nla_total_size(PORT_PROFILE_MAX)	/* PORT_PROFILE */
-		+ nla_total_size(sizeof(struct ifla_port_vsi))
-							/* PORT_VSI_TYPE */
 		+ nla_total_size(PORT_UUID_MAX)		/* PORT_INSTANCE_UUID */
 		+ nla_total_size(PORT_UUID_MAX)		/* PORT_HOST_UUID */
 		+ nla_total_size(1)			/* PROT_VDP_REQUEST */
@@ -1491,14 +1489,19 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	[IFLA_PORT_VF]		= { .type = NLA_U32 },
 	[IFLA_PORT_PROFILE]	= { .type = NLA_STRING,
 				    .len = PORT_PROFILE_MAX },
-	[IFLA_PORT_VSI_TYPE]	= { .type = NLA_BINARY,
-				    .len = sizeof(struct ifla_port_vsi)},
 	[IFLA_PORT_INSTANCE_UUID] = { .type = NLA_BINARY,
 				      .len = PORT_UUID_MAX },
 	[IFLA_PORT_HOST_UUID]	= { .type = NLA_STRING,
 				    .len = PORT_UUID_MAX },
 	[IFLA_PORT_REQUEST]	= { .type = NLA_U8, },
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
+
+	/* Unused, but we need to keep it here since user space could
+	 * fill it. It's also broken with regard to NLA_BINARY use in
+	 * combination with structs.
+	 */
+	[IFLA_PORT_VSI_TYPE]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_port_vsi) },
 };
 
 static const struct nla_policy ifla_xdp_policy[IFLA_XDP_MAX + 1] = {
-- 
1.9.3
