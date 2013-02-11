From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] cfg80211: configuration for WoWLAN over TCP
Date: Mon, 11 Feb 2013 16:34:13 +0100
Message-ID: <1360596853-13610-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:43661 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754209Ab3BKPeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 10:34:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Intel Wireless devices are able to make a TCP connection
after suspending, sending some data and waking up when
the connection receives wakeup data (or breaks). Add the
WoWLAN configuration and feature advertising API for it.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/cfg80211.h       |  55 +++++++-
 include/uapi/linux/nl80211.h | 125 ++++++++++++++++++
 net/wireless/core.h          |   3 +
 net/wireless/nl80211.c       | 293 ++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 472 insertions(+), 4 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 825230c..423ea68 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -19,6 +19,7 @@
 #include <linux/nl80211.h>
 #include <linux/if_ether.h>
 #include <linux/ieee80211.h>
+#include <linux/net.h>
 #include <net/regulatory.h>
 
 /**
@@ -1586,6 +1587,41 @@ struct cfg80211_wowlan_trig_pkt_pattern {
 };
 
 /**
+ * struct cfg80211_wowlan_tcp - TCP connection parameters
+ *
+ * @sock: (internal) socket for source port allocation
+ * @src: source IP address
+ * @dst: destination IP address
+ * @dst_mac: destination MAC address
+ * @src_port: source port
+ * @dst_port: destination port
+ * @payload_len: data payload length
+ * @payload: data payload buffer
+ * @payload_seq: payload sequence stamping configuration
+ * @data_interval: interval at which to send data packets
+ * @wake_len: wakeup payload match length
+ * @wake_data: wakeup payload match data
+ * @wake_mask: wakeup payload match mask
+ * @tokens_size: length of the tokens buffer
+ * @payload_tok: payload token usage configuration
+ */
+struct cfg80211_wowlan_tcp {
+	struct socket *sock;
+	__be32 src, dst;
+	u16 src_port, dst_port;
+	u8 dst_mac[ETH_ALEN];
+	int payload_len;
+	const u8 *payload;
+	struct nl80211_wowlan_tcp_data_seq payload_seq;
+	u32 data_interval;
+	u32 wake_len;
+	const u8 *wake_data, *wake_mask;
+	u32 tokens_size;
+	/* must be last, variable member */
+	struct nl80211_wowlan_tcp_data_token payload_tok;
+};
+
+/**
  * struct cfg80211_wowlan - Wake on Wireless-LAN support info
  *
  * This structure defines the enabled WoWLAN triggers for the device.
@@ -1599,12 +1635,15 @@ struct cfg80211_wowlan_trig_pkt_pattern {
  * @eap_identity_req: wake up on EAP identity request packet
  * @four_way_handshake: wake up on 4-way handshake
  * @rfkill_release: wake up when rfkill is released
+ * @tcp: TCP connection establishment/wakeup parameters, see nl80211.h.
+ *	NULL if not configured.
  */
 struct cfg80211_wowlan {
 	bool any, disconnect, magic_pkt, gtk_rekey_failure,
 	     eap_identity_req, four_way_handshake,
 	     rfkill_release;
 	struct cfg80211_wowlan_trig_pkt_pattern *patterns;
+	struct cfg80211_wowlan_tcp *tcp;
 	int n_patterns;
 };
 
@@ -1624,11 +1663,15 @@ struct cfg80211_wowlan {
  *	frame triggers an 802.3 frame should be reported, for
  *	disconnect due to deauth 802.11 frame. This indicates which
  *	it is.
+ * @tcp_match: TCP wakeup packet received
+ * @tcp_connlost: TCP connection lost or failed to establish
+ * @tcp_nomoretokens: TCP data ran out of tokens
  */
 struct cfg80211_wowlan_wakeup {
 	bool disconnect, magic_pkt, gtk_rekey_failure,
 	     eap_identity_req, four_way_handshake,
-	     rfkill_release, packet_80211;
+	     rfkill_release, packet_80211,
+	     tcp_match, tcp_connlost, tcp_nomoretokens;
 	s32 pattern_idx;
 	u32 packet_present_len, packet_len;
 	const void *packet;
@@ -2283,6 +2326,14 @@ enum wiphy_wowlan_support_flags {
 	WIPHY_WOWLAN_RFKILL_RELEASE	= BIT(7),
 };
 
+struct wiphy_wowlan_tcp_support {
+	const struct nl80211_wowlan_tcp_data_token_feature *tok;
+	u32 data_payload_max;
+	u32 data_interval_max;
+	u32 wake_payload_max;
+	bool seq;
+};
+
 /**
  * struct wiphy_wowlan_support - WoWLAN support data
  * @flags: see &enum wiphy_wowlan_support_flags
@@ -2290,12 +2341,14 @@ enum wiphy_wowlan_support_flags {
  *	(see nl80211.h for the pattern definition)
  * @pattern_max_len: maximum length of each pattern
  * @pattern_min_len: minimum length of each pattern
+ * @tcp: TCP wakeup support information
  */
 struct wiphy_wowlan_support {
 	u32 flags;
 	int n_patterns;
 	int pattern_max_len;
 	int pattern_min_len;
+	const struct wiphy_wowlan_tcp_support *tcp;
 };
 
 /**
diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
index 9a2ecdc..c9e3040 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -2985,6 +2985,17 @@ struct nl80211_wowlan_pattern_support {
  * @NL80211_WOWLAN_TRIG_WAKEUP_PKT_8023_LEN: Original length of the 802.3
  *	packet, may be bigger than the @NL80211_WOWLAN_TRIG_WAKEUP_PKT_8023
  *	attribute if the packet was truncated somewhere.
+ * @NL80211_WOWLAN_TRIG_TCP_CONNECTION: TCP connection wake, see DOC section
+ *	"TCP connection wakeup" for more details. This is a nested attribute
+ *	containing the exact information for establishing and keeping alive
+ *	the TCP connection.
+ * @NL80211_WOWLAN_TRIG_TCP_WAKEUP_MATCH: For wakeup reporting only, the
+ *	wakeup packet was received on the TCP connection
+ * @NL80211_WOWLAN_TRIG_WAKEUP_TCP_CONNLOST: For wakeup reporting only, the
+ *	TCP connection was lost or failed to be established
+ * @NL80211_WOWLAN_TRIG_WAKEUP_TCP_NOMORETOKENS: For wakeup reporting only,
+ *	the TCP connection ran out of tokens to use for data to send to the
+ *	service
  * @NUM_NL80211_WOWLAN_TRIG: number of wake on wireless triggers
  * @MAX_NL80211_WOWLAN_TRIG: highest wowlan trigger attribute number
  *
@@ -3006,6 +3017,10 @@ enum nl80211_wowlan_triggers {
 	NL80211_WOWLAN_TRIG_WAKEUP_PKT_80211_LEN,
 	NL80211_WOWLAN_TRIG_WAKEUP_PKT_8023,
 	NL80211_WOWLAN_TRIG_WAKEUP_PKT_8023_LEN,
+	NL80211_WOWLAN_TRIG_TCP_CONNECTION,
+	NL80211_WOWLAN_TRIG_WAKEUP_TCP_MATCH,
+	NL80211_WOWLAN_TRIG_WAKEUP_TCP_CONNLOST,
+	NL80211_WOWLAN_TRIG_WAKEUP_TCP_NOMORETOKENS,
 
 	/* keep last */
 	NUM_NL80211_WOWLAN_TRIG,
@@ -3013,6 +3028,116 @@ enum nl80211_wowlan_triggers {
 };
 
 /**
+ * DOC: TCP connection wakeup
+ *
+ * Some devices can establish a TCP connection in order to be woken up by a
+ * packet coming in from outside their network segment, or behind NAT. If
+ * configured, the device will establish a TCP connection to the given
+ * service, and periodically send data to that service. The first data
+ * packet is usually transmitted after SYN/ACK, also ACKing the SYN/ACK.
+ * The data packets can optionally include a (little endian) sequence
+ * number (in the TCP payload!) that is generated by the device, and, also
+ * optionally, a token from a list of tokens. This serves as a keep-alive
+ * with the service, and for NATed connections, etc.
+ *
+ * During this keep-alive period, the server doesn't send any data to the
+ * client. When receiving data, it is compared against the wakeup pattern
+ * (and mask) and if it matches, the host is woken up. Similarly, if the
+ * connection breaks or cannot be established to start with, the host is
+ * also woken up.
+ *
+ * Developer's note: ARP offload is required for this, otherwise TCP
+ * response packets might not go through correctly.
+ */
+
+/**
+ * struct nl80211_wowlan_tcp_data_seq - WoWLAN TCP data sequence
+ * @start: starting value
+ * @offset: offset of sequence number in packet
+ * @len: length of the sequence value to write, 1 through 4
+ *
+ * Note: don't confuse with the TCP sequence number(s), this is for the
+ * keepalive packet payload. The actual value is written into the packet
+ * in little endian.
+ */
+struct nl80211_wowlan_tcp_data_seq {
+	__u32 start, offset, len;
+};
+
+/**
+ * struct nl80211_wowlan_tcp_data_token - WoWLAN TCP data token config
+ * @offset: offset of token in packet
+ * @len: length of each token
+ * @token_stream: stream of data to be used for the tokens, the length must
+ *	be a multiple of @len for this to make sense
+ */
+struct nl80211_wowlan_tcp_data_token {
+	__u32 offset, len;
+	__u8 token_stream[];
+};
+
+/**
+ * struct nl80211_wowlan_tcp_data_token_feature - data token features
+ * @min_len: minimum token length
+ * @max_len: maximum token length
+ * @bufsize: total available token buffer size (max size of @token_stream)
+ */
+struct nl80211_wowlan_tcp_data_token_feature {
+	__u32 min_len, max_len, bufsize;
+};
+
+/**
+ * enum nl80211_wowlan_tcp_attrs - WoWLAN TCP connection parameters
+ * @__NL80211_WOWLAN_TCP_INVALID: invalid number for nested attributes
+ * @NL80211_WOWLAN_TCP_SRC_IPV4: source IPv4 address (in network byte order)
+ * @NL80211_WOWLAN_TCP_DST_IPV4: destination IPv4 address
+ *	(in network byte order)
+ * @NL80211_WOWLAN_TCP_DST_MAC: destination MAC address, this is given because
+ *	route lookup when configured might be invalid by the time we suspend,
+ *	and doing a route lookup when suspending is no longer possible as it
+ *	might require ARP querying.
+ * @NL80211_WOWLAN_TCP_SRC_PORT: source port (u16); optional, if not given a
+ *	socket and port will be allocated
+ * @NL80211_WOWLAN_TCP_DST_PORT: destination port (u16)
+ * @NL80211_WOWLAN_TCP_DATA_PAYLOAD: data packet payload, at least one byte.
+ *	For feature advertising, a u32 attribute holding the maximum length
+ *	of the data payload.
+ * @NL80211_WOWLAN_TCP_DATA_PAYLOAD_SEQ: data packet sequence configuration
+ *	(if desired), a &struct nl80211_wowlan_tcp_data_seq. For feature
+ *	advertising it is just a flag
+ * @NL80211_WOWLAN_TCP_DATA_PAYLOAD_TOKEN: data packet token configuration,
+ *	see &struct nl80211_wowlan_tcp_data_token and for advertising see
+ *	&struct nl80211_wowlan_tcp_data_token_feature.
+ * @NL80211_WOWLAN_TCP_DATA_INTERVAL: data interval in seconds, maximum
+ *	interval in feature advertising (u32)
+ * @NL80211_WOWLAN_TCP_WAKE_PAYLOAD: wake packet payload, for advertising a
+ *	u32 attribute holding the maximum length
+ * @NL80211_WOWLAN_TCP_WAKE_MASK: Wake packet payload mask, not used for
+ *	feature advertising. The mask works like @NL80211_WOWLAN_PKTPAT_MASK
+ *	but on the TCP payload only.
+ * @NUM_NL80211_WOWLAN_TCP: number of TCP attributes
+ * @MAX_NL80211_WOWLAN_TCP: highest attribute number
+ */
+enum nl80211_wowlan_tcp_attrs {
+	__NL80211_WOWLAN_TCP_INVALID,
+	NL80211_WOWLAN_TCP_SRC_IPV4,
+	NL80211_WOWLAN_TCP_DST_IPV4,
+	NL80211_WOWLAN_TCP_DST_MAC,
+	NL80211_WOWLAN_TCP_SRC_PORT,
+	NL80211_WOWLAN_TCP_DST_PORT,
+	NL80211_WOWLAN_TCP_DATA_PAYLOAD,
+	NL80211_WOWLAN_TCP_DATA_PAYLOAD_SEQ,
+	NL80211_WOWLAN_TCP_DATA_PAYLOAD_TOKEN,
+	NL80211_WOWLAN_TCP_DATA_INTERVAL,
+	NL80211_WOWLAN_TCP_WAKE_PAYLOAD,
+	NL80211_WOWLAN_TCP_WAKE_MASK,
+
+	/* keep last */
+	NUM_NL80211_WOWLAN_TCP,
+	MAX_NL80211_WOWLAN_TCP = NUM_NL80211_WOWLAN_TCP - 1
+};
+
+/**
  * enum nl80211_iface_limit_attrs - limit attributes
  * @NL80211_IFACE_LIMIT_UNSPEC: (reserved)
  * @NL80211_IFACE_LIMIT_MAX: maximum number of interfaces that
diff --git a/net/wireless/core.h b/net/wireless/core.h
index 37d70dc..949c957 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -108,6 +108,9 @@ cfg80211_rdev_free_wowlan(struct cfg80211_registered_device *rdev)
 	for (i = 0; i < rdev->wowlan->n_patterns; i++)
 		kfree(rdev->wowlan->patterns[i].mask);
 	kfree(rdev->wowlan->patterns);
+	if (rdev->wowlan->tcp && rdev->wowlan->tcp->sock)
+		sock_release(rdev->wowlan->tcp->sock);
+	kfree(rdev->wowlan->tcp);
 	kfree(rdev->wowlan);
 }
 
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index 93bc63e..b0193fc 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -19,6 +19,7 @@
 #include <net/genetlink.h>
 #include <net/cfg80211.h>
 #include <net/sock.h>
+#include <net/inet_connection_sock.h>
 #include "core.h"
 #include "nl80211.h"
 #include "reg.h"
@@ -399,6 +400,26 @@ nl80211_wowlan_policy[NUM_NL80211_WOWLAN_TRIG] = {
 	[NL80211_WOWLAN_TRIG_EAP_IDENT_REQUEST] = { .type = NLA_FLAG },
 	[NL80211_WOWLAN_TRIG_4WAY_HANDSHAKE] = { .type = NLA_FLAG },
 	[NL80211_WOWLAN_TRIG_RFKILL_RELEASE] = { .type = NLA_FLAG },
+	[NL80211_WOWLAN_TRIG_TCP_CONNECTION] = { .type = NLA_NESTED },
+};
+
+static const struct nla_policy
+nl80211_wowlan_tcp_policy[NUM_NL80211_WOWLAN_TCP] = {
+	[NL80211_WOWLAN_TCP_SRC_IPV4] = { .type = NLA_U32 },
+	[NL80211_WOWLAN_TCP_DST_IPV4] = { .type = NLA_U32 },
+	[NL80211_WOWLAN_TCP_DST_MAC] = { .len = ETH_ALEN },
+	[NL80211_WOWLAN_TCP_SRC_PORT] = { .type = NLA_U16 },
+	[NL80211_WOWLAN_TCP_DST_PORT] = { .type = NLA_U16 },
+	[NL80211_WOWLAN_TCP_DATA_PAYLOAD] = { .len = 1 },
+	[NL80211_WOWLAN_TCP_DATA_PAYLOAD_SEQ] = {
+		.len = sizeof(struct nl80211_wowlan_tcp_data_seq)
+	},
+	[NL80211_WOWLAN_TCP_DATA_PAYLOAD_TOKEN] = {
+		.len = sizeof(struct nl80211_wowlan_tcp_data_token)
+	},
+	[NL80211_WOWLAN_TCP_DATA_INTERVAL] = { .type = NLA_U32 },
+	[NL80211_WOWLAN_TCP_WAKE_PAYLOAD] = { .len = 1 },
+	[NL80211_WOWLAN_TCP_WAKE_MASK] = { .len = 1 },
 };
 
 /* policy for GTK rekey offload attributes */
@@ -872,6 +893,48 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
+#ifdef CONFIG_PM
+static int nl80211_send_wowlan_tcp_caps(struct cfg80211_registered_device *rdev,
+					struct sk_buff *msg)
+{
+	const struct wiphy_wowlan_tcp_support *tcp = rdev->wiphy.wowlan.tcp;
+	struct nlattr *nl_tcp;
+
+	if (!tcp)
+		return 0;
+
+	nl_tcp = nla_nest_start(msg, NL80211_WOWLAN_TRIG_TCP_CONNECTION);
+	if (!nl_tcp)
+		return -ENOBUFS;
+
+	if (nla_put_u32(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD,
+			tcp->data_payload_max))
+		return -ENOBUFS;
+
+	if (nla_put_u32(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD,
+			tcp->data_payload_max))
+		return -ENOBUFS;
+
+	if (tcp->seq && nla_put_flag(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD_SEQ))
+		return -ENOBUFS;
+
+	if (tcp->tok && nla_put(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD_TOKEN,
+				sizeof(*tcp->tok), tcp->tok))
+		return -ENOBUFS;
+
+	if (nla_put_u32(msg, NL80211_WOWLAN_TCP_DATA_INTERVAL,
+			tcp->data_interval_max))
+		return -ENOBUFS;
+
+	if (nla_put_u32(msg, NL80211_WOWLAN_TCP_WAKE_PAYLOAD,
+			tcp->wake_payload_max))
+		return -ENOBUFS;
+
+	nla_nest_end(msg, nl_tcp);
+	return 0;
+}
+#endif
+
 static int nl80211_send_wiphy(struct sk_buff *msg, u32 portid, u32 seq, int flags,
 			      struct cfg80211_registered_device *dev)
 {
@@ -1244,6 +1307,9 @@ static int nl80211_send_wiphy(struct sk_buff *msg, u32 portid, u32 seq, int flag
 				goto nla_put_failure;
 		}
 
+		if (nl80211_send_wowlan_tcp_caps(dev, msg))
+			goto nla_put_failure;
+
 		nla_nest_end(msg, nl_wowlan);
 	}
 #endif
@@ -6895,16 +6961,67 @@ static int nl80211_leave_mesh(struct sk_buff *skb, struct genl_info *info)
 }
 
 #ifdef CONFIG_PM
+static int nl80211_send_wowlan_tcp(struct sk_buff *msg,
+				   struct cfg80211_wowlan_tcp *tcp)
+{
+	struct nlattr *nl_tcp;
+
+	if (!tcp)
+		return 0;
+
+	nl_tcp = nla_nest_start(msg, NL80211_WOWLAN_TRIG_TCP_CONNECTION);
+	if (!nl_tcp)
+		return -ENOBUFS;
+
+	if (nla_put_be32(msg, NL80211_WOWLAN_TCP_SRC_IPV4, tcp->src) ||
+	    nla_put_be32(msg, NL80211_WOWLAN_TCP_DST_IPV4, tcp->dst) ||
+	    nla_put(msg, NL80211_WOWLAN_TCP_DST_MAC, ETH_ALEN, tcp->dst_mac) ||
+	    nla_put_u16(msg, NL80211_WOWLAN_TCP_SRC_PORT, tcp->src_port) ||
+	    nla_put_u16(msg, NL80211_WOWLAN_TCP_DST_PORT, tcp->dst_port) ||
+	    nla_put(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD,
+		    tcp->payload_len, tcp->payload) ||
+	    nla_put_u32(msg, NL80211_WOWLAN_TCP_DATA_INTERVAL,
+			tcp->data_interval) ||
+	    nla_put(msg, NL80211_WOWLAN_TCP_WAKE_PAYLOAD,
+		    tcp->wake_len, tcp->wake_data) ||
+	    nla_put(msg, NL80211_WOWLAN_TCP_WAKE_MASK,
+		    DIV_ROUND_UP(tcp->wake_len, 8), tcp->wake_mask))
+		return -ENOBUFS;
+
+	if (tcp->payload_seq.len &&
+	    nla_put(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD_SEQ,
+		    sizeof(tcp->payload_seq), &tcp->payload_seq))
+		return -ENOBUFS;
+
+	if (tcp->payload_tok.len &&
+	    nla_put(msg, NL80211_WOWLAN_TCP_DATA_PAYLOAD_TOKEN,
+		    sizeof(tcp->payload_tok) + tcp->tokens_size,
+		    &tcp->payload_tok))
+		return -ENOBUFS;
+
+	return 0;
+}
+
 static int nl80211_get_wowlan(struct sk_buff *skb, struct genl_info *info)
 {
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
 	struct sk_buff *msg;
 	void *hdr;
+	u32 size = NLMSG_DEFAULT_SIZE;
 
-	if (!rdev->wiphy.wowlan.flags && !rdev->wiphy.wowlan.n_patterns)
+	if (!rdev->wiphy.wowlan.flags && !rdev->wiphy.wowlan.n_patterns &&
+	    !rdev->wiphy.wowlan.tcp)
 		return -EOPNOTSUPP;
 
-	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (rdev->wowlan && rdev->wowlan->tcp) {
+		/* adjust size to have room for all the data */
+		size += rdev->wowlan->tcp->tokens_size +
+			rdev->wowlan->tcp->payload_len +
+			rdev->wowlan->tcp->wake_len +
+			rdev->wowlan->tcp->wake_len / 8;
+	}
+
+	msg = nlmsg_new(size, GFP_KERNEL);
 	if (!msg)
 		return -ENOMEM;
 
@@ -6961,6 +7078,9 @@ static int nl80211_get_wowlan(struct sk_buff *skb, struct genl_info *info)
 			nla_nest_end(msg, nl_pats);
 		}
 
+		if (nl80211_send_wowlan_tcp(msg, rdev->wowlan->tcp))
+			goto nla_put_failure;
+
 		nla_nest_end(msg, nl_wowlan);
 	}
 
@@ -6972,6 +7092,150 @@ nla_put_failure:
 	return -ENOBUFS;
 }
 
+static int nl80211_parse_wowlan_tcp(struct cfg80211_registered_device *rdev,
+				    struct nlattr *attr,
+				    struct cfg80211_wowlan *trig)
+{
+	struct nlattr *tb[NUM_NL80211_WOWLAN_TCP];
+	struct cfg80211_wowlan_tcp *cfg;
+	struct nl80211_wowlan_tcp_data_token *tok = NULL;
+	struct nl80211_wowlan_tcp_data_seq *seq = NULL;
+	u32 size;
+	u32 data_size, wake_size, tokens_size = 0, wake_mask_size;
+	int err, port;
+
+	if (!rdev->wiphy.wowlan.tcp)
+		return -EINVAL;
+
+	err = nla_parse(tb, MAX_NL80211_WOWLAN_TCP,
+			nla_data(attr), nla_len(attr),
+			nl80211_wowlan_tcp_policy);
+	if (err)
+		return err;
+
+	if (!tb[NL80211_WOWLAN_TCP_SRC_IPV4] ||
+	    !tb[NL80211_WOWLAN_TCP_DST_IPV4] ||
+	    !tb[NL80211_WOWLAN_TCP_DST_MAC] ||
+	    !tb[NL80211_WOWLAN_TCP_DST_PORT] ||
+	    !tb[NL80211_WOWLAN_TCP_DATA_PAYLOAD] ||
+	    !tb[NL80211_WOWLAN_TCP_DATA_INTERVAL] ||
+	    !tb[NL80211_WOWLAN_TCP_WAKE_PAYLOAD] ||
+	    !tb[NL80211_WOWLAN_TCP_WAKE_MASK])
+		return -EINVAL;
+
+	data_size = nla_len(tb[NL80211_WOWLAN_TCP_DATA_PAYLOAD]);
+	if (data_size > rdev->wiphy.wowlan.tcp->data_payload_max)
+		return -EINVAL;
+
+	if (nla_get_u32(tb[NL80211_WOWLAN_TCP_DATA_INTERVAL]) >
+			rdev->wiphy.wowlan.tcp->data_interval_max)
+		return -EINVAL;
+
+	wake_size = nla_len(tb[NL80211_WOWLAN_TCP_WAKE_PAYLOAD]);
+	if (wake_size > rdev->wiphy.wowlan.tcp->wake_payload_max)
+		return -EINVAL;
+
+	wake_mask_size = nla_len(tb[NL80211_WOWLAN_TCP_WAKE_MASK]);
+	if (wake_mask_size != DIV_ROUND_UP(wake_size, 8))
+		return -EINVAL;
+
+	if (tb[NL80211_WOWLAN_TCP_DATA_PAYLOAD_TOKEN]) {
+		u32 tokln = nla_len(tb[NL80211_WOWLAN_TCP_DATA_PAYLOAD_TOKEN]);
+
+		tok = nla_data(tb[NL80211_WOWLAN_TCP_DATA_PAYLOAD_TOKEN]);
+		tokens_size = tokln - sizeof(*tok);
+
+		if (!tok->len || tokens_size % tok->len)
+			return -EINVAL;
+		if (!rdev->wiphy.wowlan.tcp->tok)
+			return -EINVAL;
+		if (tok->len > rdev->wiphy.wowlan.tcp->tok->max_len)
+			return -EINVAL;
+		if (tok->len < rdev->wiphy.wowlan.tcp->tok->min_len)
+			return -EINVAL;
+		if (tokens_size > rdev->wiphy.wowlan.tcp->tok->bufsize)
+			return -EINVAL;
+		if (tok->offset + tok->len > data_size)
+			return -EINVAL;
+	}
+
+	if (tb[NL80211_WOWLAN_TCP_DATA_PAYLOAD_SEQ]) {
+		seq = nla_data(tb[NL80211_WOWLAN_TCP_DATA_PAYLOAD_SEQ]);
+		if (!rdev->wiphy.wowlan.tcp->seq)
+			return -EINVAL;
+		if (seq->len == 0 || seq->len > 4)
+			return -EINVAL;
+		if (seq->len + seq->offset > data_size)
+			return -EINVAL;
+	}
+
+	size = sizeof(*cfg);
+	size += data_size;
+	size += wake_size + wake_mask_size;
+	size += tokens_size;
+
+	cfg = kzalloc(size, GFP_KERNEL);
+	if (!cfg)
+		return -ENOMEM;
+	cfg->src = nla_get_be32(tb[NL80211_WOWLAN_TCP_SRC_IPV4]);
+	cfg->dst = nla_get_be32(tb[NL80211_WOWLAN_TCP_DST_IPV4]);
+	memcpy(cfg->dst_mac, nla_data(tb[NL80211_WOWLAN_TCP_DST_MAC]),
+	       ETH_ALEN);
+	if (tb[NL80211_WOWLAN_TCP_SRC_PORT])
+		port = nla_get_u16(tb[NL80211_WOWLAN_TCP_SRC_PORT]);
+	else
+		port = 0;
+#ifdef CONFIG_INET
+	/* allocate a socket and port for it and use it */
+	err = __sock_create(wiphy_net(&rdev->wiphy), PF_INET, SOCK_STREAM,
+			    IPPROTO_TCP, &cfg->sock, 1);
+	if (err) {
+		kfree(cfg);
+		return err;
+	}
+	if (inet_csk_get_port(cfg->sock->sk, port)) {
+		sock_release(cfg->sock);
+		kfree(cfg);
+		return -EADDRINUSE;
+	}
+	cfg->src_port = inet_sk(cfg->sock->sk)->inet_num;
+#else
+	if (!port) {
+		kfree(cfg);
+		return -EINVAL;
+	}
+	cfg->src_port = port;
+#endif
+
+	cfg->dst_port = nla_get_u16(tb[NL80211_WOWLAN_TCP_DST_PORT]);
+	cfg->payload_len = data_size;
+	cfg->payload = (u8 *)cfg + sizeof(*cfg) + tokens_size;
+	memcpy((void *)cfg->payload,
+	       nla_data(tb[NL80211_WOWLAN_TCP_DATA_PAYLOAD]),
+	       data_size);
+	if (seq)
+		cfg->payload_seq = *seq;
+	cfg->data_interval = nla_get_u32(tb[NL80211_WOWLAN_TCP_DATA_INTERVAL]);
+	cfg->wake_len = wake_size;
+	cfg->wake_data = (u8 *)cfg + sizeof(*cfg) + tokens_size + data_size;
+	memcpy((void *)cfg->wake_data,
+	       nla_data(tb[NL80211_WOWLAN_TCP_WAKE_PAYLOAD]),
+	       wake_size);
+	cfg->wake_mask = (u8 *)cfg + sizeof(*cfg) + tokens_size +
+			 data_size + wake_size;
+	memcpy((void *)cfg->wake_mask,
+	       nla_data(tb[NL80211_WOWLAN_TCP_WAKE_MASK]),
+	       wake_mask_size);
+	if (tok) {
+		cfg->tokens_size = tokens_size;
+		memcpy(&cfg->payload_tok, tok, sizeof(*tok) + tokens_size);
+	}
+
+	trig->tcp = cfg;
+
+	return 0;
+}
+
 static int nl80211_set_wowlan(struct sk_buff *skb, struct genl_info *info)
 {
 	struct cfg80211_registered_device *rdev = info->user_ptr[0];
@@ -6982,7 +7246,8 @@ static int nl80211_set_wowlan(struct sk_buff *skb, struct genl_info *info)
 	int err, i;
 	bool prev_enabled = rdev->wowlan;
 
-	if (!rdev->wiphy.wowlan.flags && !rdev->wiphy.wowlan.n_patterns)
+	if (!rdev->wiphy.wowlan.flags && !rdev->wiphy.wowlan.n_patterns &&
+	    !rdev->wiphy.wowlan.tcp)
 		return -EOPNOTSUPP;
 
 	if (!info->attrs[NL80211_ATTR_WOWLAN_TRIGGERS]) {
@@ -7100,6 +7365,14 @@ static int nl80211_set_wowlan(struct sk_buff *skb, struct genl_info *info)
 		}
 	}
 
+	if (tb[NL80211_WOWLAN_TRIG_TCP_CONNECTION]) {
+		err = nl80211_parse_wowlan_tcp(
+			rdev, tb[NL80211_WOWLAN_TRIG_TCP_CONNECTION],
+			&new_triggers);
+		if (err)
+			goto error;
+	}
+
 	ntrig = kmemdup(&new_triggers, sizeof(new_triggers), GFP_KERNEL);
 	if (!ntrig) {
 		err = -ENOMEM;
@@ -7117,6 +7390,9 @@ static int nl80211_set_wowlan(struct sk_buff *skb, struct genl_info *info)
 	for (i = 0; i < new_triggers.n_patterns; i++)
 		kfree(new_triggers.patterns[i].mask);
 	kfree(new_triggers.patterns);
+	if (new_triggers.tcp && new_triggers.tcp->sock)
+		sock_release(new_triggers.tcp->sock);
+	kfree(new_triggers.tcp);
 	return err;
 }
 #endif
@@ -9398,6 +9674,17 @@ void cfg80211_report_wowlan_wakeup(struct wireless_dev *wdev,
 				wakeup->pattern_idx))
 			goto free_msg;
 
+		if (wakeup->tcp_match)
+			nla_put_flag(msg, NL80211_WOWLAN_TRIG_WAKEUP_TCP_MATCH);
+
+		if (wakeup->tcp_connlost)
+			nla_put_flag(msg,
+				     NL80211_WOWLAN_TRIG_WAKEUP_TCP_CONNLOST);
+
+		if (wakeup->tcp_nomoretokens)
+			nla_put_flag(msg,
+				NL80211_WOWLAN_TRIG_WAKEUP_TCP_NOMORETOKENS);
+
 		if (wakeup->packet) {
 			u32 pkt_attr = NL80211_WOWLAN_TRIG_WAKEUP_PKT_80211;
 			u32 len_attr = NL80211_WOWLAN_TRIG_WAKEUP_PKT_80211_LEN;
-- 
1.8.0
