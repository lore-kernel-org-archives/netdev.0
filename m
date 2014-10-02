From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 3/6] openvswitch: Add support for matching on OAM packets.
Date: Thu,  2 Oct 2014 01:04:42 -0700
Message-ID: <1412237085-27215-4-git-send-email-azhou@nicira.com>
References: <1412237085-27215-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:46007 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752075AbaJBILE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 04:11:04 -0400
Received: by mail-pa0-f51.google.com with SMTP id lj1so1810171pab.24
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 01:11:03 -0700 (PDT)
In-Reply-To: <1412237085-27215-1-git-send-email-azhou@nicira.com>
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
 net/openvswitch/flow_netlink.c   |   17 ++++++++++++-----
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index f7fc507..7c06106 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -309,6 +309,7 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_TTL,                /* u8 Tunnel IP TTL. */
 	OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT,      /* No argument, set DF. */
 	OVS_TUNNEL_KEY_ATTR_CSUM,               /* No argument. CSUM packet. */
+	OVS_TUNNEL_KEY_ATTR_OAM,                /* No argument. OAM frame.  */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 9e3a2fa..f6bd93d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -369,6 +369,7 @@ static size_t key_attr_size(void)
 		  + nla_total_size(1)   /* OVS_TUNNEL_KEY_ATTR_TTL */
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT */
 		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_CSUM */
+		  + nla_total_size(0)   /* OVS_TUNNEL_KEY_ATTR_OAM */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_IN_PORT */
 		+ nla_total_size(4)   /* OVS_KEY_ATTR_SKB_MARK */
 		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index f4c8daa..22c855f 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -346,6 +346,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 			[OVS_TUNNEL_KEY_ATTR_TTL] = 1,
 			[OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT] = 0,
 			[OVS_TUNNEL_KEY_ATTR_CSUM] = 0,
+			[OVS_TUNNEL_KEY_ATTR_OAM] = 0,
 		};
 
 		if (type > OVS_TUNNEL_KEY_ATTR_MAX) {
@@ -390,6 +391,9 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
 		case OVS_TUNNEL_KEY_ATTR_CSUM:
 			tun_flags |= TUNNEL_CSUM;
 			break;
+		case OVS_TUNNEL_KEY_ATTR_OAM:
+			tun_flags |= TUNNEL_OAM;
+			break;
 		default:
 			return -EINVAL;
 		}
@@ -431,21 +435,24 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
 	    nla_put_be64(skb, OVS_TUNNEL_KEY_ATTR_ID, output->tun_id))
 		return -EMSGSIZE;
 	if (output->ipv4_src &&
-		nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC, output->ipv4_src))
+	    nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_SRC, output->ipv4_src))
 		return -EMSGSIZE;
 	if (output->ipv4_dst &&
-		nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST, output->ipv4_dst))
+	    nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_IPV4_DST, output->ipv4_dst))
 		return -EMSGSIZE;
 	if (output->ipv4_tos &&
-		nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->ipv4_tos))
+	    nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TOS, output->ipv4_tos))
 		return -EMSGSIZE;
 	if (nla_put_u8(skb, OVS_TUNNEL_KEY_ATTR_TTL, output->ipv4_ttl))
 		return -EMSGSIZE;
 	if ((output->tun_flags & TUNNEL_DONT_FRAGMENT) &&
-		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT))
+	    nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_DONT_FRAGMENT))
 		return -EMSGSIZE;
 	if ((output->tun_flags & TUNNEL_CSUM) &&
-		nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_CSUM))
+	    nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_CSUM))
+		return -EMSGSIZE;
+	if ((output->tun_flags & TUNNEL_OAM) &&
+	    nla_put_flag(skb, OVS_TUNNEL_KEY_ATTR_OAM))
 		return -EMSGSIZE;
 
 	nla_nest_end(skb, nla);
-- 
1.7.9.5
