From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH 2.6.31-rc5] can: fix oops caused by wrong rtnl newlink usage
Date: Tue, 11 Aug 2009 14:41:24 +0200
Message-ID: <4A8166F4.6040204@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090703060101040109080408"
Cc: Patrick McHardy <kaber@trash.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:53313 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbZHKMla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 08:41:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090703060101040109080408
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

For 'real' hardware CAN devices the netlink interface is used to set CAN
specific communication parameters. Real CAN hardware can not be created with
the ip tool ...

The invocation of 'ip link add type can' lead to an oops as the standard rtnl
newlink function was called:

http://bugzilla.kernel.org/show_bug.cgi?id=13954

This patch adds a private newlink function for the CAN device driver interface
that unconditionally returns -EOPNOTSUPP.

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
Reported-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
CC: Wolfgang Grandegger <wg@grandegger.com>

---

--------------090703060101040109080408
Content-Type: text/x-patch;
 name="can_newlink_oops_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can_newlink_oops_fix.patch"

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index 9e4283a..e1a4f82 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -611,11 +611,18 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static int can_newlink(struct net_device *dev,
+		       struct nlattr *tb[], struct nlattr *data[])
+{
+	return -EOPNOTSUPP;
+}
+
 static struct rtnl_link_ops can_link_ops __read_mostly = {
 	.kind		= "can",
 	.maxtype	= IFLA_CAN_MAX,
 	.policy		= can_policy,
 	.setup		= can_setup,
+	.newlink	= can_newlink,
 	.changelink	= can_changelink,
 	.fill_info	= can_fill_info,
 	.fill_xstats	= can_fill_xstats,

--------------090703060101040109080408--
