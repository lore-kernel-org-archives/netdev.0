From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] rtnetlink: reject non-IFLA_VF_PORT attributes inside IFLA_VF_PORTS
Date: Mon, 13 Jul 2015 00:06:02 +0200
Message-ID: <b6917238569c4f53d4516b71b8206e8d02e2ac21.1436736717.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36650 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbbGLWGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2015 18:06:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly as in commit 4f7d2cdfdde7 ("rtnetlink: verify IFLA_VF_INFO
attributes before passing them to driver"), we have a double nesting
of netlink attributes, i.e. IFLA_VF_PORTS only contains IFLA_VF_PORT
that is nested itself. While IFLA_VF_PORTS is a verified attribute
from ifla_policy[], we only check if the IFLA_VF_PORTS container has
IFLA_VF_PORT attributes and then pass the attribute's content itself
via nla_parse_nested(). It would be more correct to reject inner types
other than IFLA_VF_PORT instead of continuing parsing and also similarly
as in commit 4f7d2cdfdde7, to check for a minimum of NLA_HDRLEN.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
Cc: Scott Feldman <sfeldma@gmail.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
---
 ( This was still a follow-up I found while working on 4f7d2cdfdde7,
   could also go to net-next, at your preference. )

 net/core/rtnetlink.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9e433d5..dc004b1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1804,10 +1804,13 @@ static int do_setlink(const struct sk_buff *skb,
 			goto errout;
 
 		nla_for_each_nested(attr, tb[IFLA_VF_PORTS], rem) {
-			if (nla_type(attr) != IFLA_VF_PORT)
-				continue;
-			err = nla_parse_nested(port, IFLA_PORT_MAX,
-				attr, ifla_port_policy);
+			if (nla_type(attr) != IFLA_VF_PORT ||
+			    nla_len(attr) < NLA_HDRLEN) {
+				err = -EINVAL;
+				goto errout;
+			}
+			err = nla_parse_nested(port, IFLA_PORT_MAX, attr,
+					       ifla_port_policy);
 			if (err < 0)
 				goto errout;
 			if (!port[IFLA_PORT_VF]) {
-- 
1.9.3
