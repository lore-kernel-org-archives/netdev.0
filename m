From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Do not parse 32bits compiled xfrm netlink msg on 64bits host
Date: Thu, 9 Apr 2015 12:33:08 +0200
Message-ID: <1428575588-24962-2-git-send-email-steffen.klassert@secunet.com>
References: <1428575588-24962-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43799 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755075AbbDIKdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 06:33:20 -0400
In-Reply-To: <1428575588-24962-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>

structure like xfrm_usersa_info or xfrm_userpolicy_info
has different sizeof when compiled as 32bits and 64bits
due to not appending pack attribute in their definition.
This will result in broken SA and SP information when user
trying to configure them through netlink interface.

Inform user land about this situation instead of keeping
silent, the upper test scripts would behave accordingly.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 7de2ed9..2091664 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2423,6 +2423,11 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
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
1.9.1
