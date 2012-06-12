From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHv2 net-next] ipv4: Add interface option to enable routing of
 127.0.0.0/8
Date: Tue, 12 Jun 2012 06:44:01 -0400
Message-ID: <20120612104401.GH28598@canuck.infradead.org>
References: <20120608101859.GH32152@canuck.infradead.org>
 <20120611.165740.419299184892679723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51903 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab2FLKoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 06:44:05 -0400
Content-Disposition: inline
In-Reply-To: <20120611.165740.419299184892679723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Routing of 127/8 is tradtionally forbidden, we consider
packets from that address block martian when routing and do
not process corresponding ARP requests.

This is a sane default but renders a huge address space
practically unuseable.

The RFC states that no address within the 127/8 block should
ever appear on any network anywhere but it does not forbid
the use of such addresses outside of the loopback device in
particular. For example to address a pool of virtual guests
behind a load balancer.

This patch adds a new interface option 'route_localnet'
enabling routing of the 127/8 address block and processing
of ARP requests on a specific interface.

Note that for the feature to work, the default local route
covering 127/8 dev lo needs to be removed.

Example:
  $ sysctl -w net.ipv4.conf.eth0.route_localnet=1
  $ ip route del 127.0.0.0/8 dev lo table local
  $ ip addr add 127.1.0.1/16 dev eth0
  $ ip route flush cache

V2: Fix invalid check to auto flush cache (thanks davem)

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 Documentation/networking/ip-sysctl.txt |    5 +++++
 include/linux/inetdevice.h             |    2 ++
 net/ipv4/arp.c                         |    3 ++-
 net/ipv4/devinet.c                     |    5 ++++-
 net/ipv4/route.c                       |   30 +++++++++++++++++++++---------
 5 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 6f896b9..99d0e05 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -862,6 +862,11 @@ accept_local - BOOLEAN
 	local interfaces over the wire and have them accepted properly.
 	default FALSE
 
+route_localnet - BOOLEAN
+	Do not consider loopback addresses as martian source or destination
+	while routing. This enables the use of 127/8 for local routing purposes.
+	default FALSE
+
 rp_filter - INTEGER
 	0 - No source validation.
 	1 - Strict mode as defined in RFC3704 Strict Reverse Path
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index 597f4a9..67f9dda 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -38,6 +38,7 @@ enum
 	IPV4_DEVCONF_ACCEPT_LOCAL,
 	IPV4_DEVCONF_SRC_VMARK,
 	IPV4_DEVCONF_PROXY_ARP_PVLAN,
+	IPV4_DEVCONF_ROUTE_LOCALNET,
 	__IPV4_DEVCONF_MAX
 };
 
@@ -131,6 +132,7 @@ static inline void ipv4_devconf_setall(struct in_device *in_dev)
 #define IN_DEV_PROMOTE_SECONDARIES(in_dev) \
 					IN_DEV_ORCONF((in_dev), \
 						      PROMOTE_SECONDARIES)
+#define IN_DEV_ROUTE_LOCALNET(in_dev)	IN_DEV_ORCONF(in_dev, ROUTE_LOCALNET)
 
 #define IN_DEV_RX_REDIRECTS(in_dev) \
 	((IN_DEV_FORWARD(in_dev) && \
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index cda37be..2e560f0 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -790,7 +790,8 @@ static int arp_process(struct sk_buff *skb)
  *	Check for bad requests for 127.x.x.x and requests for multicast
  *	addresses.  If this is one such, delete it.
  */
-	if (ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
+	if (ipv4_is_multicast(tip) ||
+	    (!IN_DEV_ROUTE_LOCALNET(in_dev) && ipv4_is_loopback(tip)))
 		goto out;
 
 /*
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 10e15a1..44bf82e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1500,7 +1500,8 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 
 		if (cnf == net->ipv4.devconf_dflt)
 			devinet_copy_dflt_conf(net, i);
-		if (i == IPV4_DEVCONF_ACCEPT_LOCAL - 1)
+		if (i == IPV4_DEVCONF_ACCEPT_LOCAL - 1 ||
+		    i == IPV4_DEVCONF_ROUTE_LOCALNET - 1)
 			if ((new_value == 0) && (old_value != 0))
 				rt_cache_flush(net, 0);
 	}
@@ -1617,6 +1618,8 @@ static struct devinet_sysctl_table {
 					      "force_igmp_version"),
 		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
 					      "promote_secondaries"),
+		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
+					      "route_localnet"),
 	},
 };
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 842510d..655506a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1960,9 +1960,13 @@ static int ip_route_input_mc(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		return -EINVAL;
 
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr) ||
-	    ipv4_is_loopback(saddr) || skb->protocol != htons(ETH_P_IP))
+	    skb->protocol != htons(ETH_P_IP))
 		goto e_inval;
 
+	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev)))
+		if (ipv4_is_loopback(saddr))
+			goto e_inval;
+
 	if (ipv4_is_zeronet(saddr)) {
 		if (!ipv4_is_local_multicast(daddr))
 			goto e_inval;
@@ -2203,8 +2207,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   by fib_lookup.
 	 */
 
-	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr) ||
-	    ipv4_is_loopback(saddr))
+	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
 		goto martian_source;
 
 	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
@@ -2216,9 +2219,17 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_zeronet(saddr))
 		goto martian_source;
 
-	if (ipv4_is_zeronet(daddr) || ipv4_is_loopback(daddr))
+	if (ipv4_is_zeronet(daddr))
 		goto martian_destination;
 
+	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev))) {
+		if (ipv4_is_loopback(daddr))
+			goto martian_destination;
+
+		if (ipv4_is_loopback(saddr))
+			goto martian_source;
+	}
+
 	/*
 	 *	Now we are ready to route packet.
 	 */
@@ -2457,9 +2468,14 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	u16 type = res->type;
 	struct rtable *rth;
 
-	if (ipv4_is_loopback(fl4->saddr) && !(dev_out->flags & IFF_LOOPBACK))
+	in_dev = __in_dev_get_rcu(dev_out);
+	if (!in_dev)
 		return ERR_PTR(-EINVAL);
 
+	if (likely(!IN_DEV_ROUTE_LOCALNET(in_dev)))
+		if (ipv4_is_loopback(fl4->saddr) && !(dev_out->flags & IFF_LOOPBACK))
+			return ERR_PTR(-EINVAL);
+
 	if (ipv4_is_lbcast(fl4->daddr))
 		type = RTN_BROADCAST;
 	else if (ipv4_is_multicast(fl4->daddr))
@@ -2470,10 +2486,6 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	in_dev = __in_dev_get_rcu(dev_out);
-	if (!in_dev)
-		return ERR_PTR(-EINVAL);
-
 	if (type == RTN_BROADCAST) {
 		flags |= RTCF_BROADCAST | RTCF_LOCAL;
 		fi = NULL;
