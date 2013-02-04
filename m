From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: TCP connection in suspend (to RAM)
Date: Mon, 04 Feb 2013 15:53:23 +0100
Message-ID: <1359989603.10311.5.camel@jlt4.sipsolutions.net>
References: <1359374145.8120.8.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1359374145.8120.8.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-01-28 at 12:55 +0100, Johannes Berg wrote:

>  2) I'm making userspace configure the source port, and while some
>     special cases might want this it seems like normally the kernel
>     should pick an unused port. Does it seem acceptable to create a
>     socket at configuration time, use inet_csk_get_port() to get an
>     unused port and hang on to it until the configuration is removed
>     again some time later (after suspend/resume)?

Ok so let's get the question down to something technical -- Does the
below seem like a reasonable use of the socket APIs?

johannes

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
@@ -7104,7 +7105,6 @@ static int nl80211_parse_wowlan_tcp(struct cfg80211_registered_device *rdev,
 	if (!tb[NL80211_WOWLAN_TCP_SRC_IPV4] ||
 	    !tb[NL80211_WOWLAN_TCP_DST_IPV4] ||
 	    !tb[NL80211_WOWLAN_TCP_DST_MAC] ||
-	    !tb[NL80211_WOWLAN_TCP_SRC_PORT] ||
 	    !tb[NL80211_WOWLAN_TCP_DST_PORT] ||
 	    !tb[NL80211_WOWLAN_TCP_DATA_PAYLOAD] ||
 	    !tb[NL80211_WOWLAN_TCP_DATA_INTERVAL] ||
@@ -7170,7 +7170,24 @@ static int nl80211_parse_wowlan_tcp(struct cfg80211_registered_device *rdev,
 	cfg->dst = nla_get_be32(tb[NL80211_WOWLAN_TCP_DST_IPV4]);
 	memcpy(cfg->dst_mac, nla_data(tb[NL80211_WOWLAN_TCP_DST_MAC]),
 	       ETH_ALEN);
-	cfg->src_port = nla_get_u16(tb[NL80211_WOWLAN_TCP_SRC_PORT]);
+	if (tb[NL80211_WOWLAN_TCP_SRC_PORT]) {
+		cfg->src_port = nla_get_u16(tb[NL80211_WOWLAN_TCP_SRC_PORT]);
+	} else {
+		/* allocate a socket and port for it and use it */
+		err = __sock_create(wiphy_net(&rdev->wiphy), PF_INET, SOCK_STREAM,
+				    IPPROTO_TCP, &cfg->sock, 1);
+		if (err) {
+			kfree(cfg);
+			return err;
+		}
+		if (inet_csk_get_port(cfg->sock->sk, 0)) {
+			sock_release(cfg->sock);
+			kfree(cfg);
+			return -ENOSPC;
+		}
+		cfg->src_port = inet_sk(cfg->sock->sk)->inet_num;
+		printk(KERN_DEBUG "allocated socket with port %d\n", cfg->src_port);
+	}
 	cfg->dst_port = nla_get_u16(tb[NL80211_WOWLAN_TCP_DST_PORT]);
 	cfg->payload_len = data_size;
 	cfg->payload = (u8 *)cfg + sizeof(*cfg) + tokens_size;
@@ -7354,6 +7371,8 @@ static int nl80211_set_wowlan(struct sk_buff *skb, struct genl_info *info)
 	for (i = 0; i < new_triggers.n_patterns; i++)
 		kfree(new_triggers.patterns[i].mask);
 	kfree(new_triggers.patterns);
+	if (new_triggers.tcp && new_triggers.tcp->sock)
+		sock_release(new_triggers.tcp->sock);
 	kfree(new_triggers.tcp);
 	return err;
 }
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -19,6 +19,7 @@
 #include <linux/nl80211.h>
 #include <linux/if_ether.h>
 #include <linux/ieee80211.h>
+#include <linux/net.h>
 #include <net/regulatory.h>
 
 /**
@@ -1576,6 +1577,7 @@ struct cfg80211_wowlan_trig_pkt_pattern {
 /**
  * struct cfg80211_wowlan_tcp - TCP connection parameters
  *
+ * @sk: (internal) port allocated if source port was automatically selected
  * @src: source IP address
  * @dst: destination IP address
  * @dst_mac: destination MAC address
@@ -1592,6 +1594,7 @@ struct cfg80211_wowlan_trig_pkt_pattern {
  * @payload_tok: payload token usage configuration
  */
 struct cfg80211_wowlan_tcp {
+	struct socket *sock;
 	__be32 src, dst;
 	u16 src_port, dst_port;
 	u8 dst_mac[ETH_ALEN];
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -3092,7 +3092,8 @@ struct nl80211_wowlan_tcp_data_token_feature {
  *	route lookup when configured might be invalid by the time we suspend,
  *	and doing a route lookup when suspending is no longer possible as it
  *	might require ARP querying.
- * @NL80211_WOWLAN_TCP_SRC_PORT: source port (u16)
+ * @NL80211_WOWLAN_TCP_SRC_PORT: source port (u16); optional, if not given a
+ *	socket and port will be allocated
  * @NL80211_WOWLAN_TCP_DST_PORT: destination port (u16)
  * @NL80211_WOWLAN_TCP_DATA_PAYLOAD: data packet payload, at least one byte.
  *	For feature advertising, a u32 attribute holding the maximum length
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -109,6 +109,8 @@ cfg80211_rdev_free_wowlan(struct cfg80211_registered_device *rdev)
 	for (i = 0; i < rdev->wowlan->n_patterns; i++)
 		kfree(rdev->wowlan->patterns[i].mask);
 	kfree(rdev->wowlan->patterns);
+	if (rdev->wowlan->tcp && rdev->wowlan->tcp->sock)
+		sock_release(rdev->wowlan->tcp->sock);
 	kfree(rdev->wowlan->tcp);
 	kfree(rdev->wowlan);
 }


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
