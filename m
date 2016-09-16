From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH] net: ipv6: Disable forwarding per interface via sysctl
Date: Fri, 16 Sep 2016 13:47:56 +0100
Message-ID: <1474030076-24809-1-git-send-email-mmanning@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:37829 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932698AbcIPMsp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 08:48:45 -0400
Received: from pps.filterd (m0000542.ppops.net [127.0.0.1])
        by mx0a-000f0801.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8GCmi3V016109
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 05:48:44 -0700
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
        by mx0a-000f0801.pphosted.com with ESMTP id 25chk1enve-20
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 05:48:44 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disabling forwarding per interface via sysctl continues to allow
forwarding. This is contrary to the sysctl documentation stating that
the forwarding sysctl is per interface, whereas currently it is only
the sysctl for all interfaces that has an effect on forwarding. The
solution is to drop any received packets instead of forwarding them
if the ingress device has a per-device forwarding sysctl that is unset.

Signed-off-by: Mike Manning <mmanning@brocade.com>
---
 net/ipv6/ip6_output.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1dfc402..37cd1d0 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -380,11 +380,15 @@ int ip6_forward(struct sk_buff *skb)
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct inet6_skb_parm *opt = IP6CB(skb);
 	struct net *net = dev_net(dst->dev);
+	struct inet6_dev *idev = __in6_dev_get(skb->dev);
 	u32 mtu;
 
 	if (net->ipv6.devconf_all->forwarding == 0)
 		goto error;
 
+	if (idev && !idev->cnf.forwarding)
+		goto error;
+
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
-- 
1.7.10.4
