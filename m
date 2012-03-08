From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] openvswitch: Fix checksum update for actions
	on UDP packets.
Date: Wed,  7 Mar 2012 18:56:08 -0800
Message-ID: <1331175368-32692-3-git-send-email-jesse@nicira.com>
References: <1331175368-32692-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1331175368-32692-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

When modifying IP addresses or ports on a UDP packet we don't
correctly follow the rules for unchecksummed packets.  This meant
that packets without a checksum can be given a incorrect new checksum
and packets with a checksum can become marked as being unchecksummed.
This fixes it to handle those requirements.

Signed-off-by: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
---
 net/openvswitch/actions.c |   44 ++++++++++++++++++++++++++++++++------------
 1 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 2725d1b..48badff 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007-2011 Nicira Networks.
+ * Copyright (c) 2007-2012 Nicira Networks.
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -145,9 +145,16 @@ static void set_ip_addr(struct sk_buff *skb, struct iphdr *nh,
 			inet_proto_csum_replace4(&tcp_hdr(skb)->check, skb,
 						 *addr, new_addr, 1);
 	} else if (nh->protocol == IPPROTO_UDP) {
-		if (likely(transport_len >= sizeof(struct udphdr)))
-			inet_proto_csum_replace4(&udp_hdr(skb)->check, skb,
-						 *addr, new_addr, 1);
+		if (likely(transport_len >= sizeof(struct udphdr))) {
+			struct udphdr *uh = udp_hdr(skb);
+
+			if (uh->check || skb->ip_summed == CHECKSUM_PARTIAL) {
+				inet_proto_csum_replace4(&uh->check, skb,
+							 *addr, new_addr, 1);
+				if (!uh->check)
+					uh->check = CSUM_MANGLED_0;
+			}
+		}
 	}
 
 	csum_replace4(&nh->check, *addr, new_addr);
@@ -197,8 +204,22 @@ static void set_tp_port(struct sk_buff *skb, __be16 *port,
 	skb->rxhash = 0;
 }
 
-static int set_udp_port(struct sk_buff *skb,
-			const struct ovs_key_udp *udp_port_key)
+static void set_udp_port(struct sk_buff *skb, __be16 *port, __be16 new_port)
+{
+	struct udphdr *uh = udp_hdr(skb);
+
+	if (uh->check && skb->ip_summed != CHECKSUM_PARTIAL) {
+		set_tp_port(skb, port, new_port, &uh->check);
+
+		if (!uh->check)
+			uh->check = CSUM_MANGLED_0;
+	} else {
+		*port = new_port;
+		skb->rxhash = 0;
+	}
+}
+
+static int set_udp(struct sk_buff *skb, const struct ovs_key_udp *udp_port_key)
 {
 	struct udphdr *uh;
 	int err;
@@ -210,16 +231,15 @@ static int set_udp_port(struct sk_buff *skb,
 
 	uh = udp_hdr(skb);
 	if (udp_port_key->udp_src != uh->source)
-		set_tp_port(skb, &uh->source, udp_port_key->udp_src, &uh->check);
+		set_udp_port(skb, &uh->source, udp_port_key->udp_src);
 
 	if (udp_port_key->udp_dst != uh->dest)
-		set_tp_port(skb, &uh->dest, udp_port_key->udp_dst, &uh->check);
+		set_udp_port(skb, &uh->dest, udp_port_key->udp_dst);
 
 	return 0;
 }
 
-static int set_tcp_port(struct sk_buff *skb,
-			const struct ovs_key_tcp *tcp_port_key)
+static int set_tcp(struct sk_buff *skb, const struct ovs_key_tcp *tcp_port_key)
 {
 	struct tcphdr *th;
 	int err;
@@ -328,11 +348,11 @@ static int execute_set_action(struct sk_buff *skb,
 		break;
 
 	case OVS_KEY_ATTR_TCP:
-		err = set_tcp_port(skb, nla_data(nested_attr));
+		err = set_tcp(skb, nla_data(nested_attr));
 		break;
 
 	case OVS_KEY_ATTR_UDP:
-		err = set_udp_port(skb, nla_data(nested_attr));
+		err = set_udp(skb, nla_data(nested_attr));
 		break;
 	}
 
-- 
1.7.5.4
