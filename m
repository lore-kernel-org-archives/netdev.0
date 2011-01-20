From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH] rtnetlink: fix link attribute validation with IFLA_GROUP
Date: Thu, 20 Jan 2011 14:00:42 +0100
Message-ID: <4D3831FA.2010806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040308090106060403070903"
Cc: NetDev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35605 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924Ab1ATNAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jan 2011 08:00:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040308090106060403070903
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Fix a few semantic problems with the new IFLA_GROUP attribute.

Vlad, could you please give this is a try to see whether it
still behaves as expected?

--------------040308090106060403070903
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="x"

commit e4b31d565a45e06ed2e51a005f5c00ff1d00725c
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jan 20 13:55:25 2011 +0100

    rtnetlink: fix link attribute validation with IFLA_GROUP
    
    rtnl_group_changelink() is invoked by rtnl_newlink() before the link
    attributes have been validated. Additionally the group changes are
    performed even if NLM_F_CREATE is specified and a new link is
    created, while more reasonable semantics would be to set the group
    value on the newly created link.
    
    Fix both problems by moving the rtnl_group_changelink() invocation
    down to the handling of non-existant links without NLM_F_CREATE()
    and add a dev_set_group() call to rtnl_create_link().
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a0b2eeb..310eb80 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1548,6 +1548,8 @@ struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
 		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 	if (tb[IFLA_LINKMODE])
 		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
+	if (tb[IFLA_GROUP])
+		dev_set_group(dev, nla_get_u32(tb[IFLA_GROUP]));
 
 	return dev;
 
@@ -1606,10 +1608,6 @@ replay:
 	else {
 		if (ifname[0])
 			dev = __dev_get_by_name(net, ifname);
-		else if (tb[IFLA_GROUP])
-			return rtnl_group_changelink(net,
-					nla_get_u32(tb[IFLA_GROUP]),
-					ifm, tb);
 		else
 			dev = NULL;
 	}
@@ -1676,8 +1674,13 @@ replay:
 			return do_setlink(dev, ifm, tb, ifname, modified);
 		}
 
-		if (!(nlh->nlmsg_flags & NLM_F_CREATE))
+		if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
+			if (ifm->ifi_index == 0 && tb[IFLA_GROUP])
+				return rtnl_group_changelink(net,
+						nla_get_u32(tb[IFLA_GROUP]),
+						ifm, tb);
 			return -ENODEV;
+		}
 
 		if (ifm->ifi_index)
 			return -EOPNOTSUPP;

--------------040308090106060403070903--
