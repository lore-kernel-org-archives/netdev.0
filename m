From: Tom Herbert <tom@herbertland.com>
Subject: [RFC net-next 4/6] net: ILA use special route hook
Date: Wed, 3 Jun 2015 12:58:20 -0700
Message-ID: <1433361502-3478761-5-git-send-email-tom@herbertland.com>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <agartrell@fb.com>, <maheshb@google.com>,
	<tgraf@suug.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57286 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933268AbbFCT7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 15:59:38 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t53JxUBb013299
	for <netdev@vger.kernel.org>; Wed, 3 Jun 2015 12:59:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ut7d8r5b5-7
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 12:59:37 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 f232579a0a2a11e5ba1d0002c95209d8-e1ed5280 for <netdev@vger.kernel.org>;	Wed,
 03 Jun 2015 12:58:47 -0700
In-Reply-To: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register hooks from ILA.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/ipv6/ila.c b/net/ipv6/ila.c
index 54a215d..d6fce77 100644
--- a/net/ipv6/ila.c
+++ b/net/ipv6/ila.c
@@ -11,11 +11,16 @@
 #include <net/genetlink.h>
 #include <net/ila.h>
 #include <net/ip.h>
+#include <net/ip6_route.h>
 #include <net/netns/generic.h>
 #include <net/protocol.h>
 #include <uapi/linux/genetlink.h>
 #include <uapi/linux/ila.h>
 
+static bool special_route;
+module_param(special_route, bool, 0644);
+MODULE_PARM_DESC(special_route, "Set up special route hook");
+
 struct ila_map {
 	u64	identifier;
 	u64	locator;
@@ -370,12 +375,19 @@ static struct pernet_operations ila_net_ops = {
 	.size = sizeof(struct ila_net),
 };
 
+struct special_route ila_route_special = {
+	.input = ila_xlat_incoming,
+	.output = ila_xlat_outgoing,
+};
+
 static int __init ila_init(void)
 {
 	int ret;
 
 	ila_init_secret();
 
+	ip6_route_special_add(&ila_route_special);
+
 	ret = register_pernet_device(&ila_net_ops);
 	if (ret)
 		goto exit;
@@ -444,6 +456,7 @@ static void nat_locator(struct sk_buff *skb, struct ipv6hdr *ip6h, u64 locator)
 
 static void __exit ila_fini(void)
 {
+	ip6_route_special_remove(&ila_route_special);
 	genl_unregister_family(&ila_nl_family);
 	unregister_pernet_device(&ila_net_ops);
 }
-- 
1.8.1
