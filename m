From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: hsr: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 01:46:16 -0700
Message-ID: <20171024084616.GA23889@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arvid Brodin <arvid.brodin@alten.se>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:52013 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932339AbdJXIqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 04:46:19 -0400
Received: by mail-pg0-f66.google.com with SMTP id p9so13969777pgc.8
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 01:46:19 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Arvid Brodin <arvid.brodin@alten.se>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/hsr/hsr_device.c   | 9 ++++-----
 net/hsr/hsr_framereg.c | 6 ++----
 net/hsr/hsr_framereg.h | 2 +-
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 172d8309f89e..b8cd43c9ed5b 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -328,12 +328,12 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
 
 /* Announce (supervision frame) timer function
  */
-static void hsr_announce(unsigned long data)
+static void hsr_announce(struct timer_list *t)
 {
 	struct hsr_priv *hsr;
 	struct hsr_port *master;
 
-	hsr = (struct hsr_priv *) data;
+	hsr = from_timer(hsr, t, announce_timer);
 
 	rcu_read_lock();
 	master = hsr_port_get_hsr(hsr, HSR_PT_MASTER);
@@ -463,9 +463,8 @@ int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *slave[2],
 	hsr->sequence_nr = HSR_SEQNR_START;
 	hsr->sup_sequence_nr = HSR_SUP_SEQNR_START;
 
-	setup_timer(&hsr->announce_timer, hsr_announce, (unsigned long)hsr);
-
-	setup_timer(&hsr->prune_timer, hsr_prune_nodes, (unsigned long)hsr);
+	timer_setup(&hsr->announce_timer, hsr_announce, 0);
+	timer_setup(&hsr->prune_timer, hsr_prune_nodes, 0);
 
 	ether_addr_copy(hsr->sup_multicast_addr, def_multicast_addr);
 	hsr->sup_multicast_addr[ETH_ALEN - 1] = multicast_spec;
diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index 284a9b820df8..286ceb41ac0c 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -365,16 +365,14 @@ static struct hsr_port *get_late_port(struct hsr_priv *hsr,
 /* Remove stale sequence_nr records. Called by timer every
  * HSR_LIFE_CHECK_INTERVAL (two seconds or so).
  */
-void hsr_prune_nodes(unsigned long data)
+void hsr_prune_nodes(struct timer_list *t)
 {
-	struct hsr_priv *hsr;
+	struct hsr_priv *hsr = from_timer(hsr, t, prune_timer);
 	struct hsr_node *node;
 	struct hsr_port *port;
 	unsigned long timestamp;
 	unsigned long time_a, time_b;
 
-	hsr = (struct hsr_priv *) data;
-
 	rcu_read_lock();
 	list_for_each_entry_rcu(node, &hsr->node_db, mac_list) {
 		/* Shorthand */
diff --git a/net/hsr/hsr_framereg.h b/net/hsr/hsr_framereg.h
index 4e04f0e868e9..370b45998121 100644
--- a/net/hsr/hsr_framereg.h
+++ b/net/hsr/hsr_framereg.h
@@ -33,7 +33,7 @@ void hsr_register_frame_in(struct hsr_node *node, struct hsr_port *port,
 int hsr_register_frame_out(struct hsr_port *port, struct hsr_node *node,
 			   u16 sequence_nr);
 
-void hsr_prune_nodes(unsigned long data);
+void hsr_prune_nodes(struct timer_list *t);
 
 int hsr_create_self_node(struct list_head *self_node_db,
 			 unsigned char addr_a[ETH_ALEN],
-- 
2.7.4


-- 
Kees Cook
Pixel Security
