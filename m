From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 07/11] net: Add routes to the table associated with the device
Date: Thu, 13 Aug 2015 14:59:06 -0600
Message-ID: <1439499551-90231-8-git-send-email-dsa@cumulusnetworks.com>
References: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com,
	ebiederm@xmission.com, davem@davemloft.net, svaidya@brocade.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34310 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173AbbHMVAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 17:00:06 -0400
Received: by igui7 with SMTP id i7so91464310igu.1
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 14:00:05 -0700 (PDT)
In-Reply-To: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a device associated with a VRF is brought up or down routes
should be added to/removed from the table associated with the VRF.
fib_magic defaults to using the main or local tables. Have it use
the table with the device if there is one.

A part of this is directing prefsrc validations to the correct
table as well.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/fib_frontend.c  |  8 ++++----
 net/ipv4/fib_semantics.c | 25 +++++++++++++++++++------
 2 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index c55723ec4c3e..7fa277176c33 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -800,6 +800,7 @@ static int inet_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifaddr *ifa)
 {
 	struct net *net = dev_net(ifa->ifa_dev->dev);
+	int tb_id = vrf_dev_table_rtnl(ifa->ifa_dev->dev);
 	struct fib_table *tb;
 	struct fib_config cfg = {
 		.fc_protocol = RTPROT_KERNEL,
@@ -814,11 +815,10 @@ static void fib_magic(int cmd, int type, __be32 dst, int dst_len, struct in_ifad
 		},
 	};
 
-	if (type == RTN_UNICAST)
-		tb = fib_new_table(net, RT_TABLE_MAIN);
-	else
-		tb = fib_new_table(net, RT_TABLE_LOCAL);
+	if (!tb_id)
+		tb_id = (type == RTN_UNICAST) ? RT_TABLE_MAIN : RT_TABLE_LOCAL;
 
+	tb = fib_new_table(net, tb_id);
 	if (!tb)
 		return;
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 410ddb67221e..85e9a8abf15c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -838,6 +838,23 @@ __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh)
 	return nh->nh_saddr;
 }
 
+static bool fib_valid_prefsrc(struct fib_config *cfg, __be32 fib_prefsrc)
+{
+	if (cfg->fc_type != RTN_LOCAL || !cfg->fc_dst ||
+	    fib_prefsrc != cfg->fc_dst) {
+		int tb_id = cfg->fc_table;
+
+		if (tb_id == RT_TABLE_MAIN)
+			tb_id = RT_TABLE_LOCAL;
+
+		if (inet_addr_type_table(cfg->fc_nlinfo.nl_net,
+					 fib_prefsrc, tb_id) != RTN_LOCAL) {
+			return false;
+		}
+	}
+	return true;
+}
+
 struct fib_info *fib_create_info(struct fib_config *cfg)
 {
 	int err;
@@ -1033,12 +1050,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 			fi->fib_flags |= RTNH_F_LINKDOWN;
 	}
 
-	if (fi->fib_prefsrc) {
-		if (cfg->fc_type != RTN_LOCAL || !cfg->fc_dst ||
-		    fi->fib_prefsrc != cfg->fc_dst)
-			if (inet_addr_type(net, fi->fib_prefsrc) != RTN_LOCAL)
-				goto err_inval;
-	}
+	if (fi->fib_prefsrc && !fib_valid_prefsrc(cfg, fi->fib_prefsrc))
+		goto err_inval;
 
 	change_nexthops(fi) {
 		fib_info_update_nh_saddr(net, nexthop_nh);
-- 
2.3.2 (Apple Git-55)
