From: Fan Du <fan.du@intel.com>
Subject: [PATCHv3 ipsec-next] xfrm: Do not parse 32bits compiled xfrm netlink msg on 64bits host
Date: Tue, 27 Jan 2015 17:00:29 +0800
Message-ID: <1422349230-17394-1-git-send-email-fan.du@intel.com>
References: <20150127.001226.711259930266409202.davem () davemloft ! net>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org, fengyuleidian0615@gmail.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29096 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbbA0JEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 04:04:33 -0500
In-Reply-To: <20150127.001226.711259930266409202.davem () davemloft ! net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

structure like xfrm_usersa_info or xfrm_userpolicy_info
has different sizeof when compiled as 32bits and 64bits
due to not appending pack attribute in their definition.
This will result in broken SA and SP information when user
trying to configure them through netlink interface.

Inform user land about this situation instead of keeping
silent, the upper test scripts would behave accordingly.

Quotes from: http://marc.info/?l=linux-netdev&m=142226348715503&w=2
>
> Before a clean solution show up, I think it's better to warn user in some way
> like http://patchwork.ozlabs.org/patch/323842/ did. Otherwise, many people
> who stuck there will always spend time and try to fix this issue in whatever way.

Yes, this is the first thing we should do. I'm willing to accept a patch

Signed-off-by: Fan Du <fan.du@intel.com>
---
ChangeLog:
v3:
  - Use -ENOTSUPP to honor error code rules 
v2:
  - Rebase with latest tree

---
 net/xfrm/xfrm_user.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8128594..f960bd9 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2419,6 +2419,11 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 	const struct xfrm_link *link;
 	int type, err;
 
+#ifdef CONFIG_COMPAT
+	if (is_compat_task())
+		return -ENOTSUPP;
+#endif
+
 	type = nlh->nlmsg_type;
 	if (type > XFRM_MSG_MAX)
 		return -EINVAL;
-- 
1.7.9.5
