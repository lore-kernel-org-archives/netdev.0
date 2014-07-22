From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 07/10] openvswitch: Add support for matching on OAM packets.
Date: Tue, 22 Jul 2014 03:19:50 -0700
Message-ID: <1406024393-6778-8-git-send-email-azhou@nicira.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:60071 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754504AbaGVKct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 06:32:49 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so11001606pdj.2
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 03:32:49 -0700 (PDT)
In-Reply-To: <1406024393-6778-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>

Some tunnel formats have mechanisms for indicating that packets are
OAM frames that should be handled specially (either as high priority or
not forwarded beyond an endpoint). This provides support for allowing
those types of packets to be matched.

Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/uapi/linux/openvswitch.h |    1 +
 net/openvswitch/datapath.c       |    1 +
 net/openvswitch/flow_netlink.c   |    7 +++++++
 3 files changed, 9 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 0b979ee..5e83a95 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -301,6 +301,7 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_TTL,                /* u8 Tunnel IP TTL. */
 	OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT,      /* No argument, set DF. */
 	OVS_TUNNEL_KEY_ATTR_CSUM,               /* No argument. CSUM packet. */
+	OVS_TUNNEL_KEY_ATTR_OAM,                /* No argument. OAM frame.  */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 20f59b6..0ddb189 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -375,6 +375,7 @@ static size_t key_attr_size(void)
 		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TTL */
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_CSUM */
+		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_OAM */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d757848..d5837d3 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -344,6 +344,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			[OVS_TUNNEL_KEY_ATTR_TTL] = 1,
 			[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = 0,
 			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
+			[OVS_TUNNEL_KEY_ATTR_OAM] = 0,
 		};
 
 		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
@@ -388,6 +389,9 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		case OVS_TUNNEL_KEY_ATTR_CSUM:
 			tun_flags |= TUNNEL_CSUM;
 			break;
+		case OVS_TUNNEL_KEY_ATTR_OAM:
+			tun_flags |= TUNNEL_OAM;
+			break;
 		default:
 			return -EINVAL;
 		}
@@ -445,6 +449,9 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 	if ((output->tun_flags & TUNNEL_CSUM) &&
 		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_CSUM))
 		return -EMSGSIZE;
+	if ((output->tun_flags & TUNNEL_OAM) &&
+		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_OAM))
+		return -EMSGSIZE;
 
 	nla_nest_end(skb, nla);
 	return 0;
-- 
1.7.9.5
