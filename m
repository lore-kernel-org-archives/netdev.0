From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] genetlink: add auto module loading
Date: Wed, 28 Dec 2011 10:19:58 -0800
Message-ID: <20111228101958.2326b7cc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48794 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754045Ab1L1SUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 13:20:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When testing L2TP support, I discovered that the l2tp module is not autoloaded
as are other netlink interfaces. There is because of lack of hook in genetlink to call
request_module and load the module.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/netlink/genetlink.c	2011-12-24 11:13:44.373214171 -0800
+++ b/net/netlink/genetlink.c	2011-12-24 11:13:59.361360729 -0800
@@ -792,6 +792,15 @@ static int ctrl_getfamily(struct sk_buff
 
 		name = nla_data(info->attrs[CTRL_ATTR_FAMILY_NAME]);
 		res = genl_family_find_byname(name);
+#ifdef CONFIG_MODULES
+		if (res == NULL) {
+			genl_unlock();
+			request_module("net-pf-%d-proto-%d-type-%s",
+				       PF_NETLINK, NETLINK_GENERIC, name);
+			genl_lock();
+			res = genl_family_find_byname(name);
+		}
+#endif
 		err = -ENOENT;
 	}
 
