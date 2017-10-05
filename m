From: William Tu <u9012063@gmail.com>
Subject: [PATCHv2 net-next] openvswitch: Add erspan tunnel support.
Date: Wed,  4 Oct 2017 17:03:12 -0700
Message-ID: <1507161792-18340-1-git-send-email-u9012063@gmail.com>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37933 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdJEADY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 20:03:24 -0400
Received: by mail-pg0-f68.google.com with SMTP id y192so14492044pgd.5
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 17:03:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add erspan netlink interface for OVS.

Signed-off-by: William Tu <u9012063@gmail.com>
Cc: Pravin B Shelar <pshelar@ovn.org>
---
v1->v2: remove unnecessary compat code.
---
 include/uapi/linux/openvswitch.h |  1 +
 net/openvswitch/flow_netlink.c   | 51 +++++++++++++++++++++++++++++++++++++++-
 2 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 156ee4cab82e..efdbfbfd3ee2 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -359,6 +359,7 @@ enum ovs_tunnel_key_attr {
 	OVS_TUNNEL_KEY_ATTR_IPV6_SRC,		/* struct in6_addr src IPv6 address. */
 	OVS_TUNNEL_KEY_ATTR_IPV6_DST,		/* struct in6_addr dst IPv6 address. */
 	OVS_TUNNEL_KEY_ATTR_PAD,
+	OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS,	/* be32 ERSPAN index. */
 	__OVS_TUNNEL_KEY_ATTR_MAX
 };
 
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index e8eb427ce6d1..fc0ca9a89b8e 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -48,6 +48,7 @@
 #include <net/ndisc.h>
 #include <net/mpls.h>
 #include <net/vxlan.h>
+#include <net/erspan.h>
 
 #include "flow_netlink.h"
 
@@ -319,7 +320,8 @@ size_t ovs_tun_key_attr_size(void)
 		 * OVS_TUNNEL_KEY_ATTR_GENEVE_OPTS and covered by it.
 		 */
 		+ nla_total_size(2)    /* OVS_TUNNEL_KEY_ATTR_TP_SRC */
-		+ nla_total_size(2);   /* OVS_TUNNEL_KEY_ATTR_TP_DST */
+		+ nla_total_size(2)    /* OVS_TUNNEL_KEY_ATTR_TP_DST */
+		+ nla_total_size(4);   /* OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS */
 }
 
 size_t ovs_key_attr_size(void)
@@ -371,6 +373,7 @@ static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1]
 						.next = ovs_vxlan_ext_key_lens },
 	[OVS_TUNNEL_KEY_ATTR_IPV6_SRC]      = { .len = sizeof(struct in6_addr) },
 	[OVS_TUNNEL_KEY_ATTR_IPV6_DST]      = { .len = sizeof(struct in6_addr) },
+	[OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS]   = { .len = sizeof(u32) },
 };
 
 /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
@@ -593,6 +596,33 @@ static int vxlan_tun_opt_from_nlattr(const struct nlattr *attr,
 	return 0;
 }
 
+static int erspan_tun_opt_from_nlattr(const struct nlattr *attr,
+				      struct sw_flow_match *match, bool is_mask,
+				      bool log)
+{
+	unsigned long opt_key_offset;
+	struct erspan_metadata opts;
+
+	BUILD_BUG_ON(sizeof(opts) > sizeof(match->key->tun_opts));
+
+	memset(&opts, 0, sizeof(opts));
+	opts.index = nla_get_be32(attr);
+
+	/* Index has only 20-bit */
+	if (ntohl(opts.index) & ~INDEX_MASK) {
+		OVS_NLERR(log, "ERSPAN index number %x too large.",
+			  ntohl(opts.index));
+		return -EINVAL;
+	}
+
+	SW_FLOW_KEY_PUT(match, tun_opts_len, sizeof(opts), is_mask);
+	opt_key_offset = TUN_METADATA_OFFSET(sizeof(opts));
+	SW_FLOW_KEY_MEMCPY_OFFSET(match, opt_key_offset, &opts, sizeof(opts),
+				  is_mask);
+
+	return 0;
+}
+
 static int ip_tun_from_nlattr(const struct nlattr *attr,
 			      struct sw_flow_match *match, bool is_mask,
 			      bool log)
@@ -700,6 +730,19 @@ static int ip_tun_from_nlattr(const struct nlattr *attr,
 			break;
 		case OVS_TUNNEL_KEY_ATTR_PAD:
 			break;
+		case OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS:
+			if (opts_type) {
+				OVS_NLERR(log, "Multiple metadata blocks provided");
+				return -EINVAL;
+			}
+
+			err = erspan_tun_opt_from_nlattr(a, match, is_mask, log);
+			if (err)
+				return err;
+
+			tun_flags |= TUNNEL_ERSPAN_OPT;
+			opts_type = type;
+			break;
 		default:
 			OVS_NLERR(log, "Unknown IP tunnel attribute %d",
 				  type);
@@ -824,6 +867,10 @@ static int __ip_tun_to_nlattr(struct sk_buff *skb,
 		else if (output->tun_flags & TUNNEL_VXLAN_OPT &&
 			 vxlan_opt_to_nlattr(skb, tun_opts, swkey_tun_opts_len))
 			return -EMSGSIZE;
+		else if (output->tun_flags & TUNNEL_ERSPAN_OPT &&
+			 nla_put_be32(skb, OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS,
+				      ((struct erspan_metadata *)tun_opts)->index))
+			return -EMSGSIZE;
 	}
 
 	return 0;
@@ -2195,6 +2242,8 @@ static int validate_and_copy_set_tun(const struct nlattr *attr,
 			break;
 		case OVS_TUNNEL_KEY_ATTR_VXLAN_OPTS:
 			break;
+		case OVS_TUNNEL_KEY_ATTR_ERSPAN_OPTS:
+			break;
 		}
 	};
 
-- 
2.7.4
