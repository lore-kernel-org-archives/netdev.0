From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 2/2] ipvlan: implement VEPA mode
Date: Thu, 26 Oct 2017 15:09:25 -0700
Message-ID: <20171026220925.34829-1-mahesh@bandewar.net>
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Changgong Li <chonggangli@google.com>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:45784 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932400AbdJZWJ3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 18:09:29 -0400
Received: by mail-oi0-f68.google.com with SMTP id f66so8152680oib.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 15:09:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

This is very similar to the Macvlan VEPA mode, however, there is some
difference. IPvlan uses the mac-address of the lower device, so the VEPA
mode has implications of ICMP-redirects for packets destined for its
immediate neighbors sharing same master since the packets will have same
source and dest mac. The external switch/router will send redirect msg.

Having said that, this will be useful tool in terms of debugging
since IPvlan will not switch packets within its slaves and rely completely
on the external entity as intended in 802.1Qbg.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 Documentation/networking/ipvlan.txt | 12 +++++++++++-
 drivers/net/ipvlan/ipvlan.h         | 15 +++++++++++++++
 drivers/net/ipvlan/ipvlan_core.c    | 17 ++++++++++-------
 drivers/net/ipvlan/ipvlan_main.c    | 13 +++++++++++--
 include/uapi/linux/if_link.h        |  1 +
 5 files changed, 48 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/ipvlan.txt b/Documentation/networking/ipvlan.txt
index bfa91c77a4c9..812ef003e0a8 100644
--- a/Documentation/networking/ipvlan.txt
+++ b/Documentation/networking/ipvlan.txt
@@ -25,7 +25,7 @@ using IProute2/ip utility.
     ip link add link <master> name <slave> type ipvlan [ mode MODE ] [ FLAGS ]
        where
          MODE: l3 (default) | l3s | l2
-         FLAGS: bridge (default) | private
+         FLAGS: bridge (default) | private | vepa
 
     e.g.
     (a) Following will create IPvlan link with eth0 as master in
@@ -35,6 +35,8 @@ using IProute2/ip utility.
           bash# ip link add link eth0 name ipvl0 type ipvlan mode l2 bridge
     (c) This command will create an IPvlan device in L2 private mode.
           bash# ip link add link eth0 name ipvlan type ipvlan mode l2 private
+    (d) This command will create an IPvlan device in L2 vepa mode.
+          bash# ip link add link eth0 name ipvlan type ipvlan mode l2 vepa
 
 
 4. Operating modes:
@@ -77,6 +79,14 @@ themseleves apart from talking through the master device.
 	If this option is added to the command-line, the port is set in private
 mode. i.e. port wont allow cross communication between slaves.
 
+5.3 vepa:
+	If this is added to the command-line, the port is set in VEPA mode.
+i.e. port will offload switching functionality to the external entity as
+described in 802.1Qbg
+Note: VEPA mode in IPvlan has limitations. IPvlan uses the mac-address of the
+master-device, so the packets which are emitted in this mode for the adjacent
+neighbor will have source and destination mac same. This will make the switch /
+router send the redirect message.
 
 6. What to choose (macvlan vs. ipvlan)?
 	These two devices are very similar in many regards and the specific use
diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 9941851bcc13..5166575a164d 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -139,6 +139,21 @@ static inline void ipvlan_clear_private(struct ipvl_port *port)
 	port->flags &= ~IPVLAN_F_PRIVATE;
 }
 
+static inline bool ipvlan_is_vepa(const struct ipvl_port *port)
+{
+	return !!(port->flags & IPVLAN_F_VEPA);
+}
+
+static inline void ipvlan_mark_vepa(struct ipvl_port *port)
+{
+	port->flags |= IPVLAN_F_VEPA;
+}
+
+static inline void ipvlan_clear_vepa(struct ipvl_port *port)
+{
+	port->flags &= ~IPVLAN_F_VEPA;
+}
+
 void ipvlan_init_secret(void);
 unsigned int ipvlan_mac_hash(const unsigned char *addr);
 rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb);
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 72fd56de9c00..034ae4c57196 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -514,13 +514,15 @@ static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 	if (!lyr3h)
 		goto out;
 
-	addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
-	if (addr) {
-		if (ipvlan_is_private(ipvlan->port)) {
-			consume_skb(skb);
-			return NET_XMIT_DROP;
+	if (!ipvlan_is_vepa(ipvlan->port)) {
+		addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
+		if (addr) {
+			if (ipvlan_is_private(ipvlan->port)) {
+				consume_skb(skb);
+				return NET_XMIT_DROP;
+			}
+			return ipvlan_rcv_frame(addr, &skb, true);
 		}
-		return ipvlan_rcv_frame(addr, &skb, true);
 	}
 out:
 	ipvlan_skb_crossing_ns(skb, ipvlan->phy_dev);
@@ -535,7 +537,8 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 	void *lyr3h;
 	int addr_type;
 
-	if (ether_addr_equal(eth->h_dest, eth->h_source)) {
+	if (!ipvlan_is_vepa(ipvlan->port) &&
+	    ether_addr_equal(eth->h_dest, eth->h_source)) {
 		lyr3h = ipvlan_get_L3_hdr(skb, &addr_type);
 		if (lyr3h) {
 			addr = ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 4368afb1934c..a266aa435d4d 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -478,6 +478,11 @@ static int ipvlan_nl_changelink(struct net_device *dev,
 			ipvlan_mark_private(port);
 		else
 			ipvlan_clear_private(port);
+
+		if (flags & IPVLAN_F_VEPA)
+			ipvlan_mark_vepa(port);
+		else
+			ipvlan_clear_vepa(port);
 	}
 
 	return err;
@@ -506,8 +511,12 @@ static int ipvlan_nl_validate(struct nlattr *tb[], struct nlattr *data[],
 	if (data[IFLA_IPVLAN_FLAGS]) {
 		u16 flags = nla_get_u16(data[IFLA_IPVLAN_FLAGS]);
 
-		/* Only one bit is used at this moment. */
-		if (flags & ~IPVLAN_F_PRIVATE)
+		/* Only two bits are used at this moment. */
+		if (flags & ~(IPVLAN_F_PRIVATE | IPVLAN_F_VEPA))
+			return -EINVAL;
+		/* Also both flags can't be active at the same time. */
+		if ((flags & (IPVLAN_F_PRIVATE | IPVLAN_F_VEPA)) ==
+		    (IPVLAN_F_PRIVATE | IPVLAN_F_VEPA))
 			return -EINVAL;
 	}
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 052e32cd584c..81f26473d728 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -479,6 +479,7 @@ enum ipvlan_mode {
 };
 
 #define IPVLAN_F_PRIVATE	0x01
+#define IPVLAN_F_VEPA		0x02
 
 /* VXLAN section */
 enum {
-- 
2.15.0.rc2.357.g7e34df9404-goog
