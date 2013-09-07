From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: ovs: flow: fix potential illegal memory access in __parse_flow_nlattrs
Date: Sat,  7 Sep 2013 09:41:34 +0200
Message-ID: <1378539694-3635-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2666 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089Ab3IGHl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Sep 2013 03:41:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function __parse_flow_nlattrs(), we check for condition
(type > OVS_KEY_ATTR_MAX) and if true, print an error, but we do
not return from this function as in other checks. It seems this
has been forgotten, as otherwise, we could access beyond the
memory of ovs_key_lens, which is of ovs_key_lens[OVS_KEY_ATTR_MAX + 1].
Hence, a maliciously prepared nla_type from user space could access
beyond this upper limit.

Introduced by 03f0d916a ("openvswitch: Mega flow implementation").

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/flow.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index fb36f85..410db90 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -1178,6 +1178,7 @@ static int __parse_flow_nlattrs(const struct nlattr *attr,
 		if (type > OVS_KEY_ATTR_MAX) {
 			OVS_NLERR("Unknown key attribute (type=%d, max=%d).\n",
 				  type, OVS_KEY_ATTR_MAX);
+			return -EINVAL;
 		}
 
 		if (attrs & (1 << type)) {
-- 
1.7.11.7
