From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-2.6 PATCH 1/2] netlink: bug fix: don't overrun skbs on vf_port
	dump
Date: Fri, 28 May 2010 00:15:46 -0700
Message-ID: <20100528071546.4058.1332.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, netdev@vger.kernel.org, kaber@trash.net,
	arnd@arndb.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:32699 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754121Ab0E1HQC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 03:16:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>

Noticed by Patrick McHardy: was continuing to fill skb after a
nla_put_failure, ignoring the size calculated by upper layer.  Now,
return -EMSGSIZE on any overruns, but also allow netdev to
fail ndo_get_vf_port with error other than -EMSGSIZE, thus unwinding
nest.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 net/core/rtnetlink.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7ab86f3..7331bb2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -722,14 +722,13 @@ static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
 
 	for (vf = 0; vf < dev_num_vf(dev->dev.parent); vf++) {
 		vf_port = nla_nest_start(skb, IFLA_VF_PORT);
-		if (!vf_port) {
-			nla_nest_cancel(skb, vf_ports);
-			return -EMSGSIZE;
-		}
+		if (!vf_port)
+			goto nla_put_failure;
 		NLA_PUT_U32(skb, IFLA_PORT_VF, vf);
 		err = dev->netdev_ops->ndo_get_vf_port(dev, vf, skb);
+		if (err == -EMSGSIZE)
+			goto nla_put_failure;
 		if (err) {
-nla_put_failure:
 			nla_nest_cancel(skb, vf_port);
 			continue;
 		}
@@ -739,6 +738,10 @@ nla_put_failure:
 	nla_nest_end(skb, vf_ports);
 
 	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, vf_ports);
+	return -EMSGSIZE;
 }
 
 static int rtnl_port_self_fill(struct sk_buff *skb, struct net_device *dev)
@@ -753,7 +756,7 @@ static int rtnl_port_self_fill(struct sk_buff *skb, struct net_device *dev)
 	err = dev->netdev_ops->ndo_get_vf_port(dev, PORT_SELF_VF, skb);
 	if (err) {
 		nla_nest_cancel(skb, port_self);
-		return err;
+		return (err == -EMSGSIZE) ? err : 0;
 	}
 
 	nla_nest_end(skb, port_self);

