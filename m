From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 14/43] drivers/net/bonding: fix sparse warnings: context
	imbalance
Date: Sat, 14 Feb 2009 22:15:33 +0100
Message-ID: <20090214211525.23489.61644.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:59358 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156AbZBNVPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:15:39 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Attribute functions with __acquires(...) and/or __releases(...).

Fix this sparse warnings:
  drivers/net/bonding/bond_alb.c:1675:9: warning: context imbalance in 'bond_alb_handle_active_change' - unexpected unlock
  drivers/net/bonding/bond_alb.c:1742:9: warning: context imbalance in 'bond_alb_set_mac_address' - unexpected unlock
  drivers/net/bonding/bond_main.c:1025:17: warning: context imbalance in 'bond_do_fail_over_mac' - unexpected unlock
  drivers/net/bonding/bond_main.c:3195:13: warning: context imbalance in 'bond_info_seq_start' - wrong count at exit
  drivers/net/bonding/bond_main.c:3234:13: warning: context imbalance in 'bond_info_seq_stop' - unexpected unlock

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/bonding/bond_alb.c  |    8 ++++++++
 drivers/net/bonding/bond_main.c |    8 ++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 409b140..8dc6fbb 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1628,6 +1628,10 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
  * no other locks may be held.
  */
 void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave)
+	__releases(&bond->curr_slave_lock)
+	__releases(&bond->lock)
+	__acquires(&bond->lock)
+	__acquires(&bond->curr_slave_lock)
 {
 	struct slave *swap_slave;
 	int i;
@@ -1704,6 +1708,10 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
  * Called with RTNL
  */
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
+	__releases(&bond->curr_slave_lock)
+	__releases(&bond->lock)
+	__acquires(&bond->lock)
+	__acquires(&bond->curr_slave_lock)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 4ec7c93..45f6d6a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1002,6 +1002,10 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
 static void bond_do_fail_over_mac(struct bonding *bond,
 				  struct slave *new_active,
 				  struct slave *old_active)
+	__releases(&bond->curr_slave_lock)
+	__releases(&bond->lock)
+	__acquires(&bond->lock)
+	__acquires(&bond->curr_slave_lock)
 {
 	u8 tmp_mac[ETH_ALEN];
 	struct sockaddr saddr;
@@ -3193,6 +3197,8 @@ out:
 #ifdef CONFIG_PROC_FS
 
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(&dev_base_lock)
+	__acquires(&bond->lock)
 {
 	struct bonding *bond = seq->private;
 	loff_t off = 0;
@@ -3232,6 +3238,8 @@ static void *bond_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void bond_info_seq_stop(struct seq_file *seq, void *v)
+	__releases(&bond->lock)
+	__releases(&dev_base_lock)
 {
 	struct bonding *bond = seq->private;
 

