From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/15] flow_dissector: change port array into src,dst tuple
Date: Sat,  9 May 2015 15:10:37 +0200
Message-ID: <1431177038-11555-15-git-send-email-jiri@resnulli.us>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:34211 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbbEINLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 09:11:36 -0400
Received: by wgic8 with SMTP id c8so66900348wgi.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 06:11:35 -0700 (PDT)
In-Reply-To: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/cisco/enic/enic_clsf.c    | 4 ++--
 drivers/net/ethernet/cisco/enic/enic_ethtool.c | 4 ++--
 include/net/flow_dissector.h                   | 9 ++++++---
 include/net/ip.h                               | 4 ++--
 include/net/ipv6.h                             | 4 ++--
 net/core/flow_dissector.c                      | 4 ++--
 net/sched/cls_flow.c                           | 4 ++--
 7 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index d3d25c7..6739ebc 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -35,8 +35,8 @@ int enic_addfltr_5t(struct enic *enic, struct flow_keys *keys, u16 rq)
 	data.type = FILTER_IPV4_5TUPLE;
 	data.u.ipv4.src_addr = ntohl(keys->addrs.src);
 	data.u.ipv4.dst_addr = ntohl(keys->addrs.dst);
-	data.u.ipv4.src_port = ntohs(keys->ports.port16[0]);
-	data.u.ipv4.dst_port = ntohs(keys->ports.port16[1]);
+	data.u.ipv4.src_port = ntohs(keys->ports.src);
+	data.u.ipv4.dst_port = ntohs(keys->ports.dst);
 	data.u.ipv4.flags = FILTER_FIELDS_IPV4_5TUPLE;
 
 	spin_lock_bh(&enic->devcmd_lock);
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 7588f8d..117c096 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -352,10 +352,10 @@ static int enic_grxclsrule(struct enic *enic, struct ethtool_rxnfc *cmd)
 	fsp->h_u.tcp_ip4_spec.ip4dst = n->keys.addrs.dst;
 	fsp->m_u.tcp_ip4_spec.ip4dst = (__u32)~0;
 
-	fsp->h_u.tcp_ip4_spec.psrc = n->keys.ports.port16[0];
+	fsp->h_u.tcp_ip4_spec.psrc = n->keys.ports.src;
 	fsp->m_u.tcp_ip4_spec.psrc = (__u16)~0;
 
-	fsp->h_u.tcp_ip4_spec.pdst = n->keys.ports.port16[1];
+	fsp->h_u.tcp_ip4_spec.pdst = n->keys.ports.dst;
 	fsp->m_u.tcp_ip4_spec.pdst = (__u16)~0;
 
 	fsp->ring_cookie = n->rq_id;
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 5eac987..bac9c14 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -34,13 +34,16 @@ struct flow_dissector_key_addrs {
 /**
  * flow_dissector_key_tp_ports:
  *	@ports: port numbers of Transport header
- *		port16[0]: src port number
- *		port16[1]: dst port number
+ *		src: source port number
+ *		dst: destination port number
  */
 struct flow_dissector_key_ports {
 	union {
 		__be32 ports;
-		__be16 port16[2];
+		struct {
+			__be16 src;
+			__be16 dst;
+		};
 	};
 };
 
diff --git a/include/net/ip.h b/include/net/ip.h
index b0443d4..0ed6d76 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -362,8 +362,8 @@ static inline void inet_set_txhash(struct sock *sk)
 
 	keys.addrs.src = inet->inet_saddr;
 	keys.addrs.dst = inet->inet_daddr;
-	keys.ports.port16[0] = inet->inet_sport;
-	keys.ports.port16[1] = inet->inet_dport;
+	keys.ports.src = inet->inet_sport;
+	keys.ports.dst = inet->inet_dport;
 
 	sk->sk_txhash = flow_hash_from_keys(&keys);
 }
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 9eed976..aab8190 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -700,8 +700,8 @@ static inline void ip6_set_txhash(struct sock *sk)
 
 	keys.addrs.src = (__force __be32)ipv6_addr_hash(&np->saddr);
 	keys.addrs.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
-	keys.ports.port16[0] = inet->inet_sport;
-	keys.ports.port16[1] = inet->inet_dport;
+	keys.ports.src = inet->inet_sport;
+	keys.ports.dst = inet->inet_dport;
 
 	sk->sk_txhash = flow_hash_from_keys(&keys);
 }
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 7a0b391..204d09c 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -385,9 +385,9 @@ static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
 	/* get a consistent hash (same value on both flow directions) */
 	if (((__force u32)keys->addrs.dst < (__force u32)keys->addrs.src) ||
 	    (((__force u32)keys->addrs.dst == (__force u32)keys->addrs.src) &&
-	     ((__force u16)keys->ports.port16[1] < (__force u16)keys->ports.port16[0]))) {
+	     ((__force u16)keys->ports.dst < (__force u16)keys->ports.src))) {
 		swap(keys->addrs.dst, keys->addrs.src);
-		swap(keys->ports.port16[0], keys->ports.port16[1]);
+		swap(keys->ports.src, keys->ports.dst);
 	}
 
 	hash = __flow_hash_3words((__force u32)keys->addrs.dst,
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 4b3e3e3..b435992 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -88,7 +88,7 @@ static u32 flow_get_proto(const struct sk_buff *skb, const struct flow_keys *flo
 static u32 flow_get_proto_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
 	if (flow->ports.ports)
-		return ntohs(flow->ports.port16[0]);
+		return ntohs(flow->ports.src);
 
 	return addr_fold(skb->sk);
 }
@@ -96,7 +96,7 @@ static u32 flow_get_proto_src(const struct sk_buff *skb, const struct flow_keys
 static u32 flow_get_proto_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
 	if (flow->ports.ports)
-		return ntohs(flow->ports.port16[1]);
+		return ntohs(flow->ports.dst);
 
 	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
 }
-- 
1.9.3
