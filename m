From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 4/5] GRE: Add support for GRO/GSO of IPv6 GRE
 traffic
Date: Thu, 14 Apr 2016 15:33:58 -0400
Message-ID: <20160414193358.12934.80013.stgit@ahduyck-xeon-server>
References: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jesse@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35852 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcDNTeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 15:34:05 -0400
Received: by mail-pf0-f178.google.com with SMTP id e128so48736426pfe.3
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 12:34:04 -0700 (PDT)
In-Reply-To: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since GRE doesn't really care about L3 protocol we can support IPv4 and
IPv6 using the same offloads.  With that being the case we can add a call
to register the offloads for IPv6 as a part of our GRE offload
initialization.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/gre_offload.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 20557f211408..e88190a8699a 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -292,6 +292,18 @@ static const struct net_offload gre_offload = {
 
 static int __init gre_offload_init(void)
 {
-	return inet_add_offload(&gre_offload, IPPROTO_GRE);
+	int err;
+
+	err = inet_add_offload(&gre_offload, IPPROTO_GRE);
+#if IS_ENABLED(CONFIG_IPV6)
+	if (err)
+		return err;
+
+	err = inet6_add_offload(&gre_offload, IPPROTO_GRE);
+	if (err)
+		inet_del_offload(&gre_offload, IPPROTO_GRE);
+#endif
+
+	return err;
 }
 device_initcall(gre_offload_init);
