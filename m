From: Saurabh Mohan <saurabh@cplanenetworks.com>
Subject: [PATCH net-next 2/2] Support outside netns for gre & vti tunnels
Date: Mon, 4 Jan 2016 10:45:47 -0800
Message-ID: <1451933147-17266-2-git-send-email-saurabh@cplanenetworks.com>
References: <1451933147-17266-1-git-send-email-saurabh@cplanenetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saurabh Mohan <saurabh@cplanenetworks.com>
To: <netdev@vger.kernel.org>, <stephen@networkplumber.org>,
	<davem@davemloft.net>, <pshelar@nicira.com>, <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0113.outbound.protection.outlook.com ([157.56.110.113]:22592
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752251AbcADSqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 13:46:15 -0500
In-Reply-To: <1451933147-17266-1-git-send-email-saurabh@cplanenetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enchances a tunnel interface, like gre, to have the tunnel
encap/decap be in the context of a network namespace that is different from 
the namespace of the tunnel interface.

>From userspace this feature may be configured using the new 'onetns' keyword:
ip netns exec custa ip link add dev tun1 type gre local 10.0.0.1 \
 remote 10.0.0.2 onetns outside 

In the above example the tunnel would be in the 'custa' namespace and the 
tunnel endpoints would be in the 'outside' namespace.

Also, proposing the use of netns name 'global' to specify the global namespace.

If this patch set is accepted then I will add support for other tunnels as
well.

This patches gre and vti

Signed-off-by: Saurabh Mohan <saurabh@cplanenetworks.com>
---
 net/ipv4/ip_gre.c | 23 +++++++++++++++++++++++
 net/ipv4/ip_vti.c | 21 +++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7c51c4e..8376795 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -995,6 +995,16 @@ static void ipgre_netlink_parms(struct net_device *dev,
 
 		t->collect_md = true;
 	}
+	if (data[IFLA_GRE_ONETNS_FLAGS])
+		parms->o_net.o_netns_flag = nla_get_u8(
+						data[IFLA_GRE_ONETNS_FLAGS]);
+	if (data[IFLA_GRE_ONETNS_FD])
+		parms->o_net.o_netns_fd = nla_get_u32(
+						data[IFLA_GRE_ONETNS_FD]);
+	if (data[IFLA_GRE_ONETNS_NAME])
+		nla_strlcpy(parms->o_net.netns,
+			    data[IFLA_GRE_ONETNS_NAME],
+			    sizeof(parms->o_net.netns));
 }
 
 /* This function returns true when ENCAP attributes are present in the nl msg */
@@ -1128,6 +1138,12 @@ static size_t ipgre_get_size(const struct net_device *dev)
 		nla_total_size(2) +
 		/* IFLA_GRE_COLLECT_METADATA */
 		nla_total_size(0) +
+		/* IFLA_GRE_ONETNS_FLAGS */
+		nla_total_size(1) +
+		/* IFLA_GRE_ONETNS_FD */
+		nla_total_size(4) +
+		/* IFLA_GRE_ONETNS_NAME */
+		nla_total_size(NAME_MAX) +
 		0;
 }
 
@@ -1164,6 +1180,13 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 			goto nla_put_failure;
 	}
 
+	if (p->o_net.o_netns_flag) {
+		if (nla_put_u8(skb, IFLA_GRE_ONETNS_FLAGS,
+			       p->o_net.o_netns_flag) ||
+		    nla_put_string(skb, IFLA_GRE_ONETNS_NAME, p->o_net.netns))
+			goto nla_put_failure;
+	}
+
 	return 0;
 
 nla_put_failure:
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 5cf10b7..14b1015 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -466,6 +466,15 @@ static void vti_netlink_parms(struct nlattr *data[],
 	if (data[IFLA_VTI_REMOTE])
 		parms->iph.daddr = nla_get_in_addr(data[IFLA_VTI_REMOTE]);
 
+	if (data[IFLA_VTI_ONETNS_FLAGS])
+		parms->o_net.o_netns_flag = nla_get_u8(
+						data[IFLA_VTI_ONETNS_FLAGS]);
+	if (data[IFLA_VTI_ONETNS_FD])
+		parms->o_net.o_netns_fd = nla_get_u32(data[IFLA_VTI_ONETNS_FD]);
+	if (data[IFLA_VTI_ONETNS_NAME])
+		nla_strlcpy(parms->o_net.netns, data[IFLA_VTI_ONETNS_NAME],
+			    sizeof(parms->o_net.netns));
+
 }
 
 static int vti_newlink(struct net *src_net, struct net_device *dev,
@@ -499,6 +508,12 @@ static size_t vti_get_size(const struct net_device *dev)
 		nla_total_size(4) +
 		/* IFLA_VTI_REMOTE */
 		nla_total_size(4) +
+		/* IFLA_VTI_ONETNS_FLAGS */
+		nla_total_size(1) +
+		/* IFLA_VTI_ONENTS_FD */
+		nla_total_size(4) +
+		/* IFLA_VTI_ONETNS_NAME */
+		nla_total_size(NAME_MAX) +
 		0;
 }
 
@@ -512,6 +527,12 @@ static int vti_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	nla_put_be32(skb, IFLA_VTI_OKEY, p->o_key);
 	nla_put_in_addr(skb, IFLA_VTI_LOCAL, p->iph.saddr);
 	nla_put_in_addr(skb, IFLA_VTI_REMOTE, p->iph.daddr);
+	if (p->o_net.o_netns_flag) {
+		if (nla_put_u8(skb, IFLA_VTI_ONETNS_FLAGS,
+			       p->o_net.o_netns_flag) ||
+		    nla_put_string(skb, IFLA_VTI_ONETNS_NAME, p->o_net.netns))
+			return -EMSGSIZE;
+	}
 
 	return 0;
 }
-- 
1.9.1
