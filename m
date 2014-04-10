From: Edward Cree <ecree@solarflare.com>
Subject: [RFC PATCH] udp: allow busy_poll on some unconnected sockets
Date: Thu, 10 Apr 2014 19:04:47 +0100
Message-ID: <alpine.LFD.2.03.1404101856170.27143@solarflare.com>
References: <53455581.7060209@solarflare.com> <20140409145129.GA4002@sbohrermbp13-local.rgmadvisors.com> <53457334.1030602@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Jonathan Cooper <jcooper@solarflare.com>,
	<eric.dumazet@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40496 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbaDJSE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 14:04:58 -0400
In-Reply-To: <53457334.1030602@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Specifically, if the socket has been bound to a local address, and the
 net_device only uses a single NAPI context, then we don't need to be
 connected for busy_poll to do the right thing, since all our received
 packets have to come through the same NAPI context.

[ I previously thought we would need a flag in the skb to determine if the
  net_device uses single NAPI, but in fact we can just follow skb->dev. ]

Being bound to a local address is determined by the sk's inet_saddr,
 since that appears to be set to 0 when binding to a multicast or
 broadcast address (which is what we want, because they might get packets
 from any interface).  But I'm not entirely confident this is correct.

Only implemented for IPv4, because I'm even less sure about the "are we
 bound to a real unicast address" logic in the IPv6 case.

Tested by setting IFF_SINGLE_NAPI in sfc; a UDP ping-pong test showed a
 performance benefit from sysctl net.core.busy_{read,poll}=50 in both the
 connected and unconnected case, where previously it only saw the benefit
 when the socket had been connected.
---
 include/linux/netdevice.h |  3 +++
 net/ipv4/udp.c            | 11 +++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 775cc95..d63e10e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1173,6 +1173,7 @@ struct net_device_ops {
  * @IFF_LIVE_ADDR_CHANGE: device supports hardware address
  *	change when it's running
  * @IFF_MACVLAN: Macvlan device
+ * @IFF_SINGLE_NAPI: device uses a single NAPI context for all rx queues
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1197,6 +1198,7 @@ enum netdev_priv_flags {
 	IFF_SUPP_NOFCS			= 1<<19,
 	IFF_LIVE_ADDR_CHANGE		= 1<<20,
 	IFF_MACVLAN			= 1<<21,
+	IFF_SINGLE_NAPI			= 1<<22,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1221,6 +1223,7 @@ enum netdev_priv_flags {
 #define IFF_SUPP_NOFCS			IFF_SUPP_NOFCS
 #define IFF_LIVE_ADDR_CHANGE		IFF_LIVE_ADDR_CHANGE
 #define IFF_MACVLAN			IFF_MACVLAN
+#define IFF_SINGLE_NAPI			IFF_SINGLE_NAPI
 
 /*
  *	The DEVICE structure.
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4468e1a..f4561fa 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1420,14 +1420,21 @@ static void udp_v4_rehash(struct sock *sk)
 	udp_lib_rehash(sk, new_hash);
 }
 
+/* If the device only uses one NAPI context for all receive queues, then
+ * we only need to be bound, not connected, to safely sk_mark_napi_id */
+static inline bool udp_single_napi(struct sock *sk, struct sk_buff *skb)
+{
+	return inet_sk(sk)->inet_saddr && (skb->dev->priv_flags & IFF_SINGLE_NAPI);
+}
+
 static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 {
 	int rc;
 
-	if (inet_sk(sk)->inet_daddr) {
+	if (inet_sk(sk)->inet_daddr)
 		sock_rps_save_rxhash(sk, skb);
+	if (inet_sk(sk)->inet_daddr || udp_single_napi(sk, skb))
 		sk_mark_napi_id(sk, skb);
-	}
 
 	rc = sock_queue_rcv_skb(sk, skb);
 	if (rc < 0) {
-- 
1.7.11.7
