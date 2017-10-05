From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] net: enable interface alias removal via rtnl
Date: Thu,  5 Oct 2017 12:19:40 +0200
Message-ID: <20171005101940.28550-1-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Oliver Hartkopp <oliver@hartkopp.net>,
        Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:46490 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751421AbdJEKT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:19:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFLA_IFALIAS is defined as NLA_STRING. It means that the minimal length of
the attribute is 1 ("\0"). However, to remove an alias, the attribute
length must be 0 (see dev_set_alias()).

Let's define the type to NLA_BINARY, so that the alias can be removed.

Example:
$ ip l s dummy0 alias foo
$ ip l l dev dummy0
5: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether ae:20:30:4f:a7:f3 brd ff:ff:ff:ff:ff:ff
    alias foo

Before the patch:
$ ip l s dummy0 alias ""
RTNETLINK answers: Numerical result out of range

After the patch:
$ ip l s dummy0 alias ""
$ ip l l dev dummy0
5: dummy0: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether ae:20:30:4f:a7:f3 brd ff:ff:ff:ff:ff:ff

CC: Oliver Hartkopp <oliver@hartkopp.net>
CC: Stephen Hemminger <stephen@networkplumber.org>
Fixes: 96ca4a2cc145 ("net: remove ifalias on empty given alias")
Reported-by: Julien FLoret <julien.floret@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d4bcdcc68e92..570092cee902 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1483,7 +1483,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 	[IFLA_NET_NS_FD]	= { .type = NLA_U32 },
-	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
+	[IFLA_IFALIAS]	        = { .type = NLA_BINARY, .len = IFALIASZ - 1 },
 	[IFLA_VFINFO_LIST]	= {. type = NLA_NESTED },
 	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
 	[IFLA_PORT_SELF]	= { .type = NLA_NESTED },
-- 
2.13.2
