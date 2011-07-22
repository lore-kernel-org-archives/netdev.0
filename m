From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/5] bridge: send proper message_age in config BPDU
Date: Fri, 22 Jul 2011 10:47:06 -0700
Message-ID: <20110722174757.764377577@vyatta.com>
References: <20110722174705.144993799@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davmeloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46796 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754108Ab1GVRur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 13:50:47 -0400
Content-Disposition: inline; filename=br-stp-bpdu-messageage.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bridge topology with three systems:

      +------+  +------+
      | A(2) |--| B(1) |
      +------+  +------+
           \    /
          +------+
          | C(3) |
          +------+

What is supposed to happen:
 * bridge with the lowest ID is elected root (for example: B)
 * C detects that A->C is higher cost path and puts in blocking state

What happens. Bridge with lowest id (B) is elected correctly as
root and things start out fine initially. But then config BPDU
doesn't get transmitted from A -> C. Because of that 
the link from A-C is transistioned to the forwarding state.

The root cause of this is that the configuration messages
is generated with bogus message age, and dropped before
sending.

In the standardmessage_age is supposed to be:
  the time since the generation of the Configuration BPDU by
  the Root that instigated the generation of this Configuration BPDU.

Reimplement this by recording the timestamp (age + jiffies) when
recording config information. The old code incorrectly used the time
elapsed on the ageing timer which was incorrect.

See also:
  https://bugzilla.vyatta.com/show_bug.cgi?id=7164

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next-2.6.
Obviously needs to go to stable and 3.0 if stil open.


--- a/net/bridge/br_private.h	2011-04-29 16:16:03.000000000 -0700
+++ b/net/bridge/br_private.h	2011-07-21 20:13:31.651989371 -0700
@@ -124,6 +124,7 @@ struct net_bridge_port
 	bridge_id			designated_bridge;
 	u32				path_cost;
 	u32				designated_cost;
+	unsigned long			designated_age;
 
 	struct timer_list		forward_delay_timer;
 	struct timer_list		hold_timer;
--- a/net/bridge/br_stp.c	2011-07-20 09:06:24.519997816 -0700
+++ b/net/bridge/br_stp.c	2011-07-21 20:13:31.651989371 -0700
@@ -164,8 +164,7 @@ void br_transmit_config(struct net_bridg
 	else {
 		struct net_bridge_port *root
 			= br_get_port(br, br->root_port);
-		bpdu.message_age = br->max_age
-			- (root->message_age_timer.expires - jiffies)
+		bpdu.message_age = (jiffies - root->designated_age)
 			+ MESSAGE_AGE_INCR;
 	}
 	bpdu.max_age = br->max_age;
@@ -189,6 +188,7 @@ static inline void br_record_config_info
 	p->designated_cost = bpdu->root_path_cost;
 	p->designated_bridge = bpdu->bridge_id;
 	p->designated_port = bpdu->port_id;
+	p->designated_age = jiffies + bpdu->message_age;
 
 	mod_timer(&p->message_age_timer, jiffies
 		  + (p->br->max_age - bpdu->message_age));


